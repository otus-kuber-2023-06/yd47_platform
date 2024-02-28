
### kubectl debug
 - утилита уже есть в kubectl

Выполняем установку Daemonset в cluster:

```
km apply -f https://raw.githubusercontent.com/aylei/kubectl-debug/dd7e4965e4ae5c4f53e6cf9fd17acc964274ca5c/scripts/agent_daemonset.yml
```

И ничего не работает:

```
error: resource mapping not found for name: "debug-agent" namespace: "" from "https://.../agent_daemonset.yml": no matches for kind "DaemonSet" in version "extensions/v1beta1"
ensure CRDs are installed first
```

Выкачиваем файл и меняем apiVersion:

```
wget https://.../agent_daemonset.yml

$ head agent_daemonset.yml 
apiVersion: apps/v1
kind: DaemonSet
metadata:
  labels:
    app: debug-agent
...
```

Daemonset создался:

```
daemonset.apps/debug-agent created
```

##### Приходит осознание, понимаем, что daemonset не нужон и удаляем его

Запустим тестовый pod с nginx:

```
km apply -f strace/dp-nginx.yaml

$ km get po
NAME                     READY   STATUS    RESTARTS   AGE
hw8-dp-ccf7d6d66-h77vk   2/2     Running   0          9m42s
```

Подцепляемся к контейнеру:
```
km debug -it hw8-dp-ccf7d6d66-h77vk --image=ubuntu:20.04 --target=hw8-container

hw8-dp-ccf7d6d66-h77vk - имя pod;
--target=hw8-container - имя контейнера в pod
```

Установим strace:
```
apt update && apt install -y strace
```

Пробуем подключиться к процессу:

```
# strace -c -p 1
strace: Could not attach to process. If your uid matches the uid of the target process, check the setting of /proc/sys/kernel/yama/ptrace_scope, or try again as the root user. For more details, see /etc/sysctl.d/10-ptrace.conf: Operation not permitted
strace: attach: ptrace(PTRACE_SEIZE, 1): Operation not permitted
```

Запускаем с другим profile:

```
km debug -it hw8-dp-ccf7d6d66-h77vk --image=ubuntu:20.04 --target=hw8-container --profile=general

root@hw8-dp-ccf7d6d66-h77vk:/# strace -c -p 1
strace: Process 1 attached
```

### iptables-tailer

Можно установить kit:
```
git clone git@github.com:box/kube-iptables-tailer.git
make container
```

но можно и забить, потому что далее в сниппетах используется нужный образ, в котором включена C-Go опция (для связывания с
C-библиотекой, которая обеспечивает чтение журнала systemd)

Далее предлагается установить [netperf-operator](https://github.com/piontec/netperf-operator) но он не подходит для современных версий кубера, а учить deprecated инструмент я не вижу смысла, поэтому пропускаю этот этап.

Создаём daemonset для kit, предварительно поправив ds-iptables-tailer.yaml. Следует дополнить `.spec.selector` для совпадения с `spec.template.metadata.labels`. Иначе Config with these two not matching will be rejected by the API.

Но ds не запускается:
```
Events:
  Type     Reason        Age                   From                  Message
  ----     ------        ----                  ----                  -------
  Warning  FailedCreate  53s (x16 over 3m37s)  daemonset-controller  Error creating: pods "kube-iptables-tailer-" is forbidden: error looking up service account kube-system/kube-iptables-tailer: serviceaccount "kube-iptables-tailer" not found
```

Создаём сервисный аккаунт, роль и бинд:
```
km apply -f kit-serviceaccount.yaml
km apply -f kit-clusterrole.yaml
km apply -f kit-clusterrolebinding.yaml
```

ds запустился:
```
$ km get ds -n kube-system | grep iptables
kube-iptables-tailer    4    4    4    4    4    <none>    39s
```

Но в выводе `km get events -A -w` ничего интересного. Поменяем переменные в ds:

```
env: 
  - name: "IPTABLES_LOG_PATH"    <---- было JOURNAL_DIRECTORY
    value: "/var/log/syslog"     <---- было /var/log/journal
    ...
  - name: "IPTABLES_LOG_PREFIX"
    # log prefix defined in your iptables chains
    value: "calico-packet:"        <---- оставим так, поскольку предлагаемое `calico-drop` в логах отсутствует;
```

и переустановим ds:
```
km apply -f ds-iptables-tailer.yaml
```

запустим тестовый контейнер c nginx:
```
km create deployment nginx --image=nginx
km expose deployment nginx --port=80
```

запустим еще один, из которого будем пытаться получить доступ к nginx:
```
km run access --rm -ti --image ubuntu:20.04 /bin/bash
apt update && apt install wget -y
```

Протестируем доступ:
```
wget -q --timeout=5 nginx -O -

<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>
...
```

После чего применим сетевую политику:
```
km apply -f nginx-calico-policy.yaml
```

И проверим:
```
wget -q --timeout=5 nginx -O -
Connecting to nginx (nginx)|10.96.165.206|:80... failed: Connection timed out.
Giving up.
```

Внутри контейнера kube-iptables-tailer события в логах есть:
```
Feb 26 12:03:37 worker-b-igyx kernel: [ 3161.662745] calico-packet: IN=eth0 OUT=cali21f32b9552e MAC=d0:0d:12:d5:03:14:00:00:5e:00:01:00:08:00 SRC=10.112.128.73 DST=10.112.131.53 LEN=60 TOS=0x00 PREC=0x00 TTL=59 ID=27873 DF PROTO=TCP SPT=57812 DPT=80 WINDOW=64240 RES=0x00 SYN URGP=0 
Feb 26 12:03:38 worker-b-igyx kernel: [ 3162.680331] calico-packet: IN=eth0 OUT=cali21f32b9552e MAC=d0:0d:12:d5:03:14:00:00:5e:00:01:00:08:00 SRC=10.112.128.73 DST=10.112.131.53 LEN=60 TOS=0x00 PREC=0x00 TTL=59 ID=27874 DF PROTO=TCP SPT=57812 DPT=80 WINDOW=64240 RES=0x00 SYN URGP=0 
Feb 26 12:03:40 worker-b-igyx kernel: [ 3164.696240] calico-packet: IN=eth0 OUT=cali21f32b9552e MAC=d0:0d:12:d5:03:14:00:00:5e:00:01:00:08:00 SRC=10.112.128.73 DST=10.112.131.53 LEN=60 TOS=0x00 PREC=0x00 TTL=59 ID=27875 DF PROTO=TCP SPT=57812 DPT=80 WINDOW=64240 RES=0x00 SYN URGP=0 
```

Смотрим в events, но там ничего, проверяем лог контейнера, а там:
```
E0226 12:41:38.511187       1 parser.go:31] Error retrieving log time to check expiration: parsing time "Feb" as "2006-01-02T15:04:05.000000-07:00": cannot parse "Feb" as "2006"
E0226 12:41:38.511234       1 parser.go:31] Error retrieving log time to check expiration: parsing time "Feb" as "2006-01-02T15:04:05.000000-07:00": cannot parse "Feb" as "2006"
```

а это значит, что либо надо дорабатывать kube-iptables-tailer, либо править формат лога со стороны ноды, что невозможно сделать в managed cluster, поэтому инструмент подходит только для on-premise решения. Ну либо можно залезть в kit и переделать его под себя. 
