# yd47_platform
yd47 Platform repository

## Worklog

Урок 2. [kubernetes-intro](#kubernetes-intro)

Урок 3. [kubernetes-controllers](#kubernetes-controllers)

## kubernetes-intro
2023-07-09 Сделал задания из kubernetes-intro: 
```
Изучил:
  - базовую архитектуру (control plane, worker node);
  - поднял кластер в minikube;
  - познакомился как проверять состояние кластера, состояние компонент, список pod;
  - создавать pod из манифеста;
  - смотреть логи и события по pod'am (describe, logs)
  - запускать предполетные :) подготовки с директивой initContainers

```
## kubernetes-controllers
2023-07-15 Сделал занятия из kubernetes-controllers:
```
Изучил:
  - Работу с selector: матчинг ресурсов по key/value;
  - Probes: проверки, что приложение живое, а не поймало deadlock;
  - Зачем нужен Deployment и почему не обойтись ReplicaSet;
  - Daemonset - pod'ы, которые всегда будут добавляться на ноды кластера;
  - Обновление приложений с помощью Deployment, проверка успешности, откаты;
  - Стратегии обновления приложений
```
