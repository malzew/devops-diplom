### TODO list

1. Использовать workspace prod. Возможно создать в другой зоне облака следующую инфраструктуру:
    - Прокси
    - Сервер приложений
    - Сервер БД - мастер. Настроить мастер - мастер репликацию между зонами доступности. По архитектуре БД нужно подумать.
    - Сервер БД - слейв. (?)
    - Сервер мониторинга
    - Нагрузку между зонами доступности балансировать [Yandex network balancer](https://cloud.yandex.ru/docs/network-load-balancer/?from=int-console-empty-state), dns записи отдать ему, кроме gitlab.
2. В Grafana есть дашборд отображающий метрики из MySQL (*). + алерты
3. В Grafana есть дашборд отображающий метрики из WordPress (*). + алерты
4. Метрики и алерты из NGINX в prometheus
5. Дальнейшая автоматизация установки GitLab. [Создание персонального токена](https://docs.gitlab.com/ee/user/profile/personal_access_tokens.html#create-a-personal-access-token-programmatically). Возможно [использовать terraform](https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs) для настройки GitLab.