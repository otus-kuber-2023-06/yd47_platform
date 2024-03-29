# yd47_platform
yd47 Platform repository

## Worklog

- Урок 2. [kubernetes-intro](#kubernetes-intro)
- Урок 3. [kubernetes-controllers](#kubernetes-controllers)
- Урок 4. [kubernetes-networks](#kubernetes-networks)
- Урок 5. [kubernetes-volumes](#kubernetes-volumes)
- Урок 6. [kubernetes-security](#kubernetes-security)
- Урок 7. [kubernetes-templating](#kubernetes-templating)
- Урок 8. [kubernetes-operators](#kubernetes-operators)
- Урок 9. [kubernetes-monitoring](#kubernetes-monitoring)
- Урок 10. [kubernetes-logging](#kubernetes-logging)
- Урок 11. [kubernetes-gitops](#kubernetes-gitops)

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
2023-07-15 Сделал задания из kubernetes-controllers:
```
Изучил:
  - Работу с selector: матчинг ресурсов по key/value;
  - Probes: проверки, что приложение живое, а не поймало deadlock;
  - Зачем нужен Deployment и почему не обойтись ReplicaSet;
  - Daemonset - pod'ы, которые всегда будут добавляться на ноды кластера;
  - Обновление приложений с помощью Deployment, проверка успешности, откаты;
  - Стратегии обновления приложений
```

## kubernetes-networks
2023-07-22 Сделал задания из kubernetes-networks:
```
Изучил:
  - readinessProbe (готовность принимать запросы) и livenessProbe (что процесс живой);
  - Создание Service: ClusterIP, Ingress и доступ к приложениям через эти сервисы;
  - Включение балансировщика IPVS (работает на 4 ур TCP/IP); 
  - Установку MetalLB;
  - Установку kubernetes-dashboard;
  - Канареечный деплой
```

## kubernetes-volumes
2023-07-23 Сделал задания из kubernetes-volumes:
```
Изучил:
  - StatefulSet;
  - работу с secret;
  - типы volumes; 
  - создание pv и pvc;
  - политики переиспользования PV, режимы доступа
```

## kubernetes-security
2023-07-25 Сделал задания из kubernetes-security:
```
Изучил:
  - создание Roles и clusterRole - доступ/ограничение к ресурсам в рамках ns/cluster;
  - RBAC: связку ServiceAccount и Role через ClusterRoleBinding
```

## kubernetes-templating
2023-08-19 Сделал задания из kubernetes-templating:
```
Изучил:
  - работу с helm, helmfile, kubecfg, kustomize;
  - научился работать с cert-manager и chartmuseum
```

## kubernetes-operators
2023-08-28 Сделал задания из kubernetes-operators:
```
Изучил:
  - создание CR и описание его в CRD;
  - создание k8s оператора
```

## kubernetes-monitoring
2023-11 Сделал задания из kubernetes-monitoring:
```
Изучил:
  - деплой prometheus стека в кубер;
  - автообнаружение сервисов и pod'ов через оператор
```

## kubernetes-logging
2023-12 Сделал задания из kubernetes-logging:
```
Изучил:
  - создание managed-cluster в ручном режиме в ЯОблаке;
  - проклятие нод через taints и толерантность pod'ов к проклятиям;
  - познакомился с возможность упереться в квоты ЯО;
  - установку EFK стека в k8s;
  - еще раз посмотрел на деплой prometheus, подключение ServiceMonitor и static_configs
```

## kubernetes-gitops
2024-02 Сделал задания из kubernetes-gitops
```
Изучил:
  - работу с flux для организации Continious Delivery 
```
