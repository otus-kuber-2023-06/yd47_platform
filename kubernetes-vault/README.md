# Выполнено ДЗ № 11

 - [x] Основное ДЗ
 - [ ] Задание со *

## В процессе сделано:
 - Установлен Consul и Vault

## Как проверить работоспособность:
#### Установим vault
вывод helm status vault - добавьте в README.md
```
$ helm status vault
NAME: vault
LAST DEPLOYED: Sat Feb 24 18:02:25 2024
NAMESPACE: default
STATUS: deployed
REVISION: 1
NOTES:
Thank you for installing HashiCorp Vault!
```

#### Инициализируем vault
сохраните ключи, полученные при инициализации, вывод добавьте в README.md
```
{
  "unseal_keys_b64": [
    "PyOOoxQOYaCCgP/YVUoVVcYFzuuWfGOV0JKZgi5Bako="
  ],
  "unseal_keys_hex": [
    "3f238ea3140e61a08280ffd8554a1555c605ceeb967c6395d09299822e416a4a"
  ],
  "unseal_shares": 1,
  "unseal_threshold": 1,
  "recovery_keys_b64": [],
  "recovery_keys_hex": [],
  "recovery_keys_shares": 0,
  "recovery_keys_threshold": 0,
  "root_token": "hvs.mzJzjaW9sP6fWMBEIx6Vhuqi"
}
```

#### Распечатаем vault
добавьте выдачу vault status в README.md

```
Key             Value
---             -----
Seal Type       shamir
Initialized     true
Sealed          false
Total Shares    1
Threshold       1
Version         1.15.1
Build Date      2024-02-24T18:02:25Z
Storage Type    consul
Cluster Name    vault-cluster-244c5e9d
Cluster ID      e8a03d9b-34af-f8cf-7ec6-3c2c8ca3d314
HA Enabled      true
HA Cluster      https://vault-0.vault-internal:8201
HA Mode         active
Active Since    2024-02-24T22:13:43.760536567Z
```

#### Залогинимся в vault (у нас есть root token)
вывод сохранить в README.md
```
Success! You are now authenticated. The token information displayed below
is already stored in the token helper. You do NOT need to run "vault login"
again. Future Vault requests will automatically use this token.

Key                  Value
---                  -----
token                hvs.mzJzjaW9sP6fWMBEIx6Vhuqi
token_accessor       HZkMyPgfH6zFpRXhHadG4YIw
token_duration       ∞
token_renewable      false
token_policies       ["root"]
identity_policies    []
policies             ["root"]
```

#### Заведем секреты
вывод команды чтения секрета добавить в README.md
```
Path      Type     Accessor               Description                Version
----      ----     --------               -----------                -------
token/    token    auth_token_34abe3f4    token based credentials    n/a
```

#### Включим авторизацию черерз k8s
обновленный список авторизаций - добавить в README.md
```
Path           Type          Accessor                    Description                Version
----           ----          --------                    -----------                -------
kubernetes/    kubernetes    auth_kubernetes_252859d2    n/a                        n/a
token/         token         auth_token_1cbd2ddb         token based credentials    n/a
```

#### Создадим yaml для ClusterRoleBinding
файл должен быть приложен в ДЗ
`artifacts/vault-clusterrole.yaml`

#### Разберемся с ошибками при записи
ответы на вопросы добавить в README.md

Согласно установленной раннее политике "otus-policy":

в "otus/otus-ro/" разрешены только чтение и перечисление
в "otus/otus-rw/" разрешены чтение, перечисление и создание
Поэтому чтобы произвести обновление секрета (перезапись) в "otus/otus-rw/config", нужно добавить в полититку для "otus/otus-rw/" право "update".

#### nginx, проверка
законнектится к поду nginx и вытащить оттуда index.html

```
root@vault-agent-example:/# cat /usr/share/nginx/html/index.html
  <html>
  <body>
  <p>Some secrets:</p>
  <ul>
  <li><pre>username: otus</pre></li>
  <li><pre>password: asajkjkahs</pre></li>
  </ul>

  </body>
  </html>
```

#### Создадим и отзовем новые сертификаты
выдачу при создании сертификата добавить в README.md

```
Key                 Value
---                 -----
ca_chain            [-----BEGIN CERTIFICATE-----
MIIDuTCCAqGgAwIBAgIUcZxD0IrG312D1A6fAuayW9U2OwMwDQYJKoZIhvcNAQEL
...обрезано..
yRv/8T3eaPuB1wONIEXf0JlYKbz9QGyrBVtybr4IE+BNvT5KSw4EkrAzvWVt
-----END CERTIFICATE----- -----BEGIN CERTIFICATE-----
MIIDOzCCAiOgAwIBAgIUKdl/ImJEFCG10HzHC5ovqlDMnsUwDQYJKoZIhvcNAQEL
...обрезано..
7CkYrU2Kkn3V/pZR3UR4
-----END CERTIFICATE-----]
certificate         -----BEGIN CERTIFICATE-----
MIID6zCCAtOgAwIBAgIUdE/LKnyRbTrRYof2JFBq16PACTUwDQYJKoZIhvcNAQEL
...обрезано..
LGlDgZRoeRG4Y0Fg3ialvI5IgibXwrmZaKT3yTOoX83T/uazuJ4EhgqaTooDOBA=
-----END CERTIFICATE-----
expiration          1700395588
issuing_ca          -----BEGIN CERTIFICATE-----
MIIDuTCCAqGgAwIBAgIUcZxD0IrG312D1A6fAuayW9U2OwMwDQYJKoZIhvcNAQEL
...обрезано..
yRv/8T3eaPuB1wONIEXf0JlYKbz9QGyrBVtybr4IE+BNvT5KSw4EkrAzvWVt
-----END CERTIFICATE-----
private_key         -----BEGIN RSA PRIVATE KEY-----
MIIEogIBAAKCAQEAmmd1GLq7EntH3AuxILGqResijK0u3An6fjrXd1W+9E/Kn0ch
...обрезано..
qDwJdYPkgicVJXBc79CqxEQA3NuEAISlxFMvbxAVUb+xZ3/IhQ4=
-----END RSA PRIVATE KEY-----
private_key_type    rsa
serial_number       74:4f:cb:2a:7c:91:6d:3a:d1:62:87:f6:24:50:6a:d7:a3:c0:09:35
```

## PR checklist:
 - [ ] Выставлен label с темой домашнего задания
