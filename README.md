### Дипломный практикум в YandexCloud

### [Полное Задание](TASK.md)

#### Цели:

Зарегистрировать доменное имя (любое на ваш выбор в любой доменной зоне).

Подготовить инфраструктуру с помощью Terraform на базе облачного провайдера YandexCloud.

Настроить внешний Reverse Proxy на основе Nginx и LetsEncrypt.

Настроить кластер MySQL.

Установить WordPress.

Развернуть Gitlab CE и Gitlab Runner.

Настроить CI/CD для автоматического развёртывания приложения.

Настроить мониторинг инфраструктуры с помощью стека: Prometheus, Alert Manager и Grafana.

### Введение

Для решения поставленных задач будут использованы следующие инструменты:

- Terraform 1.3.0
- Ansible 2.13.2, python 3.8.10, jinja 3.1.2
- ansible-lint 6.4.0
- Yandex Cloud CLI 0.93.0 
- Git 2.25.1
- IDE PyCharm Community Edition 2022.2.2
- ОС Linux Ubuntu 20.04 LTS

Перечислены только основные рабочие инструменты.

По условиям задания нужно повсеместно использовать IaaC подход с широким использованием инструментов для автоматизации.
Так же хотелось бы написать работу, которую можно в дальнейшем использовать как основу для других проектов.

Поэтому, был выбран подход с хранением параметров проекта в terraform. Это достаточно удобно для дальнейшего использования работы в других проектах, так как не требует ревью всего кода для изменения параметров.
Кроме того, terraform контролирует состояние ресурсов проекта и хранит данные о состоянии в разделяемой среде, что удобно для совместного использования.
Переменные проекта хранятся в следующих файлах:

1. [variables.tf](./terraform/variables.tf)
2. `secrets.tf` - не загружается в репозиторий

Повсеместно выполняется запуск ansible из terraform. Terraform создает ресурсы в облаке, и по мере их готовности запускает ansible для дальнейшей настройки.

Файлы c переменными, описанием ресурсов terraform хранятся в папке [terraform](./terraform)

Плейбуки, роли, промежуточные файлы ansible хранятся в папке [ansible](./ansible)

Для запуска ansible необходимо создать файл с inventory. Это делается так же из terraform, по готовности VPC

[ansible.tf](./terraform/ansible.tf)

Необходимая начальная конфигурация ansible

[ansible.cfg](./terraform/ansible.cfg)

Для реализации проекта выбран дистрибутив ОС Linux Ubuntu 20.04 LTS, как наиболее мне знакомый из находящихся в активном развитии.
Так же практически все ПО, находящееся в активном развитии, имеет либо готовые репозитории под данный дистрибутив, либо готовые пакеты.
Это позволяет использовать последние версии ПО, устанавливая их пакет-менеджером, без ручного устранения зависимостей.
Кроме того, Yandex Cloud имеет собственные образы данного дистрибутива.

Так же опытным путем установлено, что использование Ubuntu 22.04 LTS потребует изменение ролей для настройки UFW и NAT. 

### Этапы выполнения:

### 1. Регистрация доменного имени

#### Цель:

Получить возможность выписывать TLS сертификаты для веб-сервера.  

#### Ожидаемые результаты:

У вас есть доступ к личному кабинету на сайте регистратора.

Вы зарезистрировали домен и можете им управлять (редактировать dns записи в рамках этого домена).

---

#### Решение

Зарегистрировано доменное имя:

`eladmin.ru`

Доступ к личному кабинету регистратора есть.

Регистратор:

https://reg.ru

1. Зарегистрироваться на Yandex Cloud, привязать платежную карту. Результат - `cloud_id`
2. Установить утилиту для работы в cli. https://cloud.yandex.ru/docs/cli/quickstart
3. Создать папку для инфраструктуры - создана папка netology. Результат - `folder_id`

Зона DNS делегирована от регистратора к Yandex Cloud для автоматического создания записей при работе terraform.

https://cloud.yandex.ru/docs/dns/operations/zone-create-public

Создание и удаление записей в DNS зоне делается из terraform, по готовности VPC. По условиям задания это A записи.

[dnszone.tf](./terraform/dnszone.tf)

Ожидаемый результат достигнут.

---

### 2. Создание инфраструктуры  

Для начала необходимо подготовить инфраструктуру в YC при помощи Terraform.

#### Цель:

Повсеместно применять IaaC подход при организации (эксплуатации) инфраструктуры.  

Иметь возможность быстро создавать (а также удалять) виртуальные машины и сети. С целью экономии денег на вашем аккаунте в YandexCloud.  

#### Ожидаемые результаты:

Terraform сконфигурирован и создание инфраструктуры посредством Terraform возможно без дополнительных ручных действий.

---

#### Решение

Версия terraform

```commandline
$ terraform --version
Terraform v1.3.0
on linux_amd64
```

Настройки провайдера Yandex Cloud находятся в файлах
- [provider.tf](./terraform/provider.tf)
- `key.json` - файл не загружается в репозиторий

Для корректной работы кода необходимо:
 
4. В папке создать сервисный аккаунт с ролью `editor`. https://cloud.yandex.ru/docs/iam/operations/sa/create
5. Создать статический ключ доступа для сервисного аккаунта. Это необходимо для доступа terraform к S3 бакету. Ключ сохраняется в переменных окружания `AWS_ACCESS_KEY_ID = key_id` и `AWS_SECRET_ACCESS_KEY = secret` для постоянного хранения переменных окружения можно использовать файл `~/.bashrc` https://cloud.yandex.ru/docs/iam/operations/sa/create-access-key
6. Создать авторизированный ключ для сервисного аккаунта в файле `key.json` - он используется для доступа terraform к API Yandex Cloud при работе с инфраструктурой. https://cloud.yandex.ru/docs/iam/operations/authorized-key/create
7. Создать Object Storage, он же S3 бакет. Размер можно самый минимальный, установлен 1 Гб. Результат в настройке бакета - bucket

Делаем

```commandline
terraform init
terraform workspace new prod
terraform workspace new stage
terraform workspace select stage
```

Скачиваются необходимые провайдеры terraform и файл состояния terraform хранится в бакете.

Создаются workspaces stage и prod

Дальнейшая работа будет использовать workspace stage. Использование workspace prod занесем в [TODO](./TODO.md)

Сетевая инфраструктура описана в файле [network.tf](./terraform/network.tf)

Возможно создание VPC в разных зонах доступности.

Terraform сконфигурирован и создание инфраструктуры посредством Terraform возможно без дополнительных ручных действий.

Вся инфраструктура разворачивается и настраивается одним запуском Terraform

```commandline
$ cd terraform
$ terraform apply --auto-approve
```

Развертывание и настройка занимает около 20 минут.

Уничтожение инфраструктуры так же одним запуском Terraform

```commandline
$ cd terraform
$ terraform destroy --auto-approve
```

Уничтожение инфраструктуры занимает около 2 минут.

Ожидаемый результат достигнут.

---

### 3. Установка Nginx и LetsEncrypt

#### Рекомендации:

• Имя сервера: `eladmin.ru`, добавлено имя хоста `nginx.eladmin.ru` 

• Характеристики: 2vCPU, 2 RAM, External address (Public) и Internal address.

#### Цель:

Создать reverse proxy с поддержкой TLS для обеспечения безопасного доступа к веб-сервисам по HTTPS.  

#### Ожидаемые результаты:

В вашей доменной зоне настроены все A-записи на внешний адрес этого сервера:

https://www.eladmin.ru (WordPress)

https://gitlab.eladmin.ru (Gitlab)

https://grafana.eladmin.ru (Grafana)

https://prometheus.eladmin.ru (Prometheus)

https://alertmanager.eladmin.ru (Alert Manager)

Настроены все upstream для выше указанных URL, куда они сейчас ведут на этом шаге не важно, позже вы их отредактируете и укажите верные значения.

---

#### Решение

Так как сервер NGINX является единственным сервером в инфраструктуре с внешним адресом в интернете он должен решать следующие задачи:

1. Обратный прокси к сервисам, запущенным на серверах без внешнего адреса.
2. Для прокси генерируются TLS сертификаты Let’s Encrypt. Включен редирект http на https для всех конфигураций NGINX. С серверами обмен по http.
3. Межсетевой экран с функцией PAT и DNAT для доступа серверов из внутренней сети в интернет. А так же для доступа из интернета к внутренним сервисам, которые нельзя пропустить через NGINX. Например, ssh к Gitlab для работы git.
4. Данный сервер будет промежуточным ssh хостом для доступа к инфраструктуре. Поэтому, на нем создается ssh ключ, публичная часть которого потом копируется по всей инфраструктуре .

Создание сервера `nginx.eladmin.ru` описано в [node_proxy.tf](./terraform/node_proxy.tf)

Настройка сервера `nginx.eladmin.ru` в [ansible_proxy.tf](./terraform/ansible_proxy.tf)

Запуск ansible из terraform по мере готовности ресурсов.

Ожидаемый результат достигнут.

---

### 4. Установка кластера MySQL

Необходимо разработать Ansible роль для установки кластера MySQL.

#### Рекомендации:

• Имена серверов: `db01.eladmin.ru` и `db02.eladmin.ru`

• Характеристики: 4vCPU, 4 RAM, Internal address.

#### Цель:

Получить отказоустойчивый кластер баз данных MySQL.

#### Ожидаемые результаты:

MySQL работает в режиме репликации Master/Slave.  

В кластере автоматически создаётся база данных c именем `wordpress`.  

В кластере автоматически создаётся пользователь `wordpress` с полными правами на базу `wordpress` и паролем `wordpress`.  

---

#### Решение

Создание серверов `db01.eladmin.ru` и `db02.eladmin.ru` описано в [node_mysql.tf](./terraform/node_mysql.tf)

Настройка серверов `db01.eladmin.ru` и `db02.eladmin.ru` в [ansible_mysql.tf](./terraform/ansible_mysql.tf)

Запуск ansible из terraform по мере готовности ресурсов.

Создана БД `wordpress` с заданными параметрами и пользователем. Запущена репликация.

Ожидаемый результат достигнут.

---

### 5. Установка WordPress

Необходимо разработать Ansible роль для установки WordPress.

#### Рекомендации:

• Имя сервера: `app.eladmin.ru`

• Характеристики: 4vCPU, 4 RAM, Internal address.

#### Цель:

Установить WordPress. Это система управления содержимым сайта (CMS) с открытым исходным кодом.  


#### Ожидаемые результаты:

Виртуальная машина на которой установлен WordPress и Nginx/Apache (на ваше усмотрение).  

В вашей доменной зоне настроена A-запись на внешний адрес reverse proxy:

https://www.eladmin.ru (WordPress)

На сервере `eladmin.ru` отредактирован upstream для выше указанного URL и он смотрит на виртуальную машину на которой установлен WordPress.  

В браузере можно открыть URL https://www.eladmin.ru и увидеть главную страницу WordPress.

---

#### Решение

Под код приложения создан отдельный репозиторий. Это необходимо для развертывания приложения и быстрого импорта данного репозитория в GitLab.

https://github.com/malzew/wordpress

Для обеспечения отказоустойчивой работы с кластером БД подключен плагин HyperDB  

https://wordpress.org/plugins/hyperdb/

Приложение запускается в docker контейнере.

[Dockerfile](https://github.com/malzew/wordpress/blob/main/Dockerfile)

Контейнер собирается на базе контейнера `ubuntu:20.04` Используется apache2, php. Запускается контейнер с помощью [docker-compose.yml](https://github.com/malzew/wordpress/blob/main/docker-compose.yml)

На хост смонтирован порт 8080 и папка из контейнера `/var/www/wordpress/wp-content/uploads`. Она нужна для сохранения контента, загруженного пользователями сервиса, при деплое новой версии приложения и замене контейнера.
Остальной необходимый код, плагины, темы и т.д. сохраняются в образе, который собирается из репозитория при деплое новой версии.

Данный подход хорош тем, что приложение находится в изолированном окружении. Деплой методом замены контейнера, старая версия образа сохраняется, получая тег `wordpress:old`, новая версия `wordpress:latest`
Это дает возможность быстро откатиться при ошибках в новой версии, просто перезапустить контейнер из предыдущего образа.

Кроме того, для последующего автоматического деплоя приложения из GitLab нужно создать ssh ключи и скачать файл с закрытым ключом. Что и делается на этой ноде.

Создание сервера WordPress `app.eladmin.ru` описано в [node_app.tf](./terraform/node_app.tf)

Настройка сервера WordPress `app.eladmin.ru` в [ansible_app.tf](./terraform/ansible_app.tf)

Запуск ansible из terraform по мере готовности ресурсов.

Ожидаемый результат достигнут.

---

### 6. Установка Gitlab CE и Gitlab Runner

Необходимо настроить CI/CD систему для автоматического развертывания приложения при изменении кода.

#### Рекомендации:

• Имена серверов: `gitlab.eladmin.ru` и `runner.eladmin.ru`  

• Характеристики: 4vCPU, 4 RAM, Internal address.

#### Цель:

Построить pipeline доставки кода в среду эксплуатации, то есть настроить автоматический деплой на сервер app.eladmin.ru при коммите в репозиторий с WordPress.  

#### Ожидаемый результат:

Интерфейс Gitlab доступен по https.  

В вашей доменной зоне настроена A-запись на внешний адрес reverse proxy:

https://gitlab.eladmin.ru (Gitlab)

На сервере `eladmin.ru` отредактирован upstream для выше указанного URL и он смотрит на виртуальную машину на которой установлен Gitlab.  

При любом коммите в репозиторий с WordPress и создании тега (например, v1.0.0) происходит деплой на виртуальную машину.

---

#### Решение

Создание сервера GitLab CE `gitlab.eladmin.ru` описано в [node_gitlab.tf](./terraform/node_gitlab.tf)

Настройка сервера GitLab CE `gitlab.eladmin.ru` в [ansible_gitlab.tf](./terraform/ansible_gitlab.tf)

Создание сервера GitLab runner `runner.eladmin.ru` описано в [node_runner.tf](./terraform/node_runner.tf)

Настройка сервера GitLab runner `runner.eladmin.ru` в [ansible_runner.tf](./terraform/ansible_runner.tf)

Запуск ansible из terraform по мере готовности ресурсов.

GitLab CE запускается в docker контейнере из образа `gitlab/gitlab-ce:15.4.2-ce.0` с докерхаба. Параметрами запуска устанавливается URL, ssh порт, пароль пользователя root и токен для регистрации runner. Все хранится в переменных terraform.
Скачивание контейнера и запуск занимает около 12 минут.

Кроме того, опытным путем установлено, что 4 Гб оперативы и 4 ядра мало для GitLab.
Установлено 6 ядер и 6 Гб оперативной памяти на ноде с GitLab, только тогда все задачи выполняются нормально.

После установки и первоначального запуска GitLab готов к регистрации runner, по заранее заданному токену. Это делается по мере готовности gitlab и gitlab runner.

GitLab требует дополнительной ручной настройки.

1. Создать проект `wordpress`
2. Импортировать проект с репозитория на github. Метод импорта - внешний URL. `https://github.com/malzew/wordpress.git`
3. После импорта в проекте создать 3 переменные:
    - ID_RSA - Type File, Protected. В данные записать содержимое файла [./ansible/files/app_id_rsa](./ansible/files/app_id_rsa) который был создан на предыдущем шаге. Он не загружается в репозиторий и содержит приватный ключ ssh, необходимый для деплоя. Или использовать любой другой авторизованный на сервере приложений ключ пользователя ubuntu.
    - SERVER_IP - Type Variable, Protected. В значение записать `app` - хост сервера приложения.
    - SERVER_USER - Type Variable, Protected. В значение записать `ubuntu` - пользователь для деплоя с правами на папки и доступ к демону docker. 

![](assets/Screenshot_gitlab3.png)

4. Описать защищенные теги по маске `v*` - при установке тега будет происходить деплой приложения на сервер.

![](assets/Screenshot_gitlab2.png)

CI/CD pipeline заранее создан в репозитории приложения https://github.com/malzew/wordpress/blob/main/.gitlab-ci.yml

Включает в себя 2 этапа:
1. Тестирование. Включает в себя сборку контейнера из [Dockerfile](https://github.com/malzew/wordpress/blob/main/Dockerfile) и простой тест на запрос заглавной страницы с проверкой содержания строки `WordPress` в ответе.
Простая проверка на то, что контейнер собирается, внутри запускается apache2 и доступны файлы приложения. База данных не подключается.
Тест запускается если выполняется коммит в ветку с заранее созданным merge request. В merge request видны результаты тестирования, можно сделать ревью и принять решение о слиянии с основной веткой.
2. Деплой. Выполняется при простановке любого тега. Но, так как переменные созданы защищенными пайплайн нормально отработает только при простановке защищенного тега. Деплой происходит запуском команд с runner через ssh на сервере приложения.
Удаляется старый репозиторий, с GitLab клонируется новый. Останавливается контейнер с приложением, На предыдущий образ контейнера устанавливается тег `:old`, удаляется старый контейнер (образ остается). Собирается и запускается новый контейнер с тегом `:latest`

Таким образом, если для изменения кода создавать новые ветки и использовать merge request для слияния с основной веткой - будет запускаться тестирование и результаты будут видны в интерфейсе GitLab перед слиянием.

После проставления тега будет запущен деплой приложения. В процессе деплоя будет сохранен предыдущий образ контейнера, который можно использовать для быстрого отката к предыдущей версии на сервере приложения.

Доступ к репозиторию на GitLab возможен как по ssh, так и по https.

Можно скачать к себе локально репозиторий и работать с ним как обычно в любой IDE или из командной строки. Для работы по ssh необходимо добавить свой публичный ключ в профиль пользователя GitLab. 

Дальнейшая автоматизация развертывания GitLab возможна при создании на установке [персонального токена](https://docs.gitlab.com/ee/user/profile/personal_access_tokens.html#create-a-personal-access-token-programmatically) для root. Это возможно и перенесено в [TODO](./TODO.md) 

Ожидаемый результат достигнут.

---

### 7. Установка Prometheus, Alert Manager, Node Exporter и Grafana

Необходимо разработать Ansible роль для установки Prometheus, Alert Manager и Grafana.

#### Рекомендации:

• Имя сервера: `monitoring.eladmin.ru`  

• Характеристики: 4vCPU, 4 RAM, Internal address.

#### Цель:

Получение метрик со всей инфраструктуры.

#### Ожидаемые результаты:

Интерфейсы Prometheus, Alert Manager и Grafana доступены по https.  

В вашей доменной зоне настроены A-записи на внешний адрес reverse proxy:

• https://grafana.eladmin.ru (Grafana)

• https://prometheus.eladmin.ru (Prometheus)

• https://alertmanager.eladmin.ru (Alert Manager)

На сервере `eladmin.ru` отредактированы upstreams для выше указанных URL и они смотрят на виртуальную машину на которой установлены Prometheus, Alert Manager и Grafana.  

На всех серверах установлен Node Exporter и его метрики доступны Prometheus.  

У Alert Manager есть необходимый набор правил для создания алертов.  

В Grafana есть дашборд отображающий метрики из Node Exporter по всем серверам.  

В Grafana есть дашборд отображающий метрики из MySQL (*).

В Grafana есть дашборд отображающий метрики из WordPress (*).

Примечание: дашборды со звёздочкой являются опциональными заданиями повышенной сложности их выполнение желательно, но не обязательно.

---

#### Решение

Создание сервера `monitoring.eladmin.ru` описано в [node_monitoring.tf](./terraform/node_monitoring.tf)

Настройка сервера `monitoring.eladmin.ru` в [ansible_monitoring.tf](./terraform/ansible_monitoring.tf)

Запуск ansible из terraform по мере готовности ресурсов.

На первом этапе, по готовности VPC на ноде мониторинга создаются заготовки для конфигурации prometheus.
Данный подход позволяет из terraform задавать состав нод для мониторинга.

Дальнейшая настройка начинается после готовности всех сервисов, чтобы параллельным выполнением не нагружать ноды и не вызввать конфликтов у менеджера пакетов.

Для оповещения в alertmanager настраивается спользование Telegram. Для этого заранее созбается бот и телеграм канал. Настройки хранятся в terraform в файле `secerts.tf`, который не загружается в репозиторий из соображений безопасности.

Инструкции по созданию telegram бота и получению chat_id можно взять здесь https://sarafian.github.io/low-code/2020/03/24/create-private-telegram-chatbot.html

Настройка https://qna.habr.com/q/1134068

Файл `secrets.tf` выглядит следующим образом:

```terraform
# File with secret data, dont store in git. Added to .gitignore
# About create telegram bot https://sarafian.github.io/low-code/2020/03/24/create-private-telegram-chatbot.html
# And there https://qna.habr.com/q/1134068

variable "telega_bot_token" {
  type = string
  default = "<token>"
}

variable "telega_chat_id" {
  type = string
  default = "<chat_id>"
}
```

Задания со звездочками не выполнены и помещены в [TODO](./TODO.md)

Ожидаемый результат достигнут.

---

### Что необходимо для сдачи задания?

Репозиторий со всеми Terraform манифестами и готовность продемонстрировать создание всех ресурсов с нуля.

Репозиторий со всеми Ansible ролями и готовность продемонстрировать установку всех сервисов с нуля.

Скриншоты веб-интерфейсов всех сервисов работающих по HTTPS на вашем доменном имени.

https://www.eladmin.ru (WordPress)

https://gitlab.eladmin.ru (Gitlab)

https://grafana.eladmin.ru (Grafana)

https://prometheus.eladmin.ru (Prometheus)

https://alertmanager.eladmin.ru (Alert Manager)

Все репозитории рекомендуется хранить на одном из ресурсов (github.com или gitlab.com).

---

#### Решение

[Репозитарий с кодом terraform и ansible](https://github.com/malzew/devops-diplom)

[Репозитарий с кодом wordpress](https://github.com/malzew/wordpress)

Вся инфраструктура разворачивается и настраивается одним запуском Terraform

```commandline
$ cd terraform
$ terraform apply --auto-approve
```

Развертывание и настройка занимает около 20 минут.

Уничтожение инфраструктуры так же одним запуском Terraform

```commandline
$ cd terraform
$ terraform destroy --auto-approve
```

Уничтожение инфраструктуры занимает около 2 минут.

Ожидаемый результат достигнут.

Скриншоты

https://www.eladmin.ru (WordPress)

![](assets/Screenshot_wordpress1.png)

![](assets/Screenshot_wordpress2.png)

https://gitlab.eladmin.ru (Gitlab)

![](assets/Screenshot_gitlab1.png)

![](assets/Screenshot_gitlab2.png)

![](assets/Screenshot_gitlab3.png)

![](assets/Screenshot_gitlab4.png)

https://grafana.eladmin.ru (Grafana)

![](assets/Screenshot_grafana1.png)

![](assets/Screenshot_grafana2.png)

![](assets/Screenshot_grafana3.png)

https://prometheus.eladmin.ru (Prometheus)

![](assets/Screenshot_prometheus1.png)

![](assets/Screenshot_prometheus2.png)

https://alertmanager.eladmin.ru (Alert Manager)

![](assets/Screenshot_alertmanager1.png)

![](assets/Screenshot_alertmanager2.png)

---