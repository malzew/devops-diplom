# После готовности всех нод, рестарта прокси на сервере мониторинга создаются части конфигурации prometheus, для каждого сервиса из переменной terraform monitoring
# В дальнейшем эти части будут слиты в единый конфиг. Данный подход позволяет из terraform изменять количество нод для мониторинга
resource "null_resource" "prometheus_config" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ../ansible/inventory ../ansible/prometheus_config.yml --extra-vars 'monitoring_target=${each.value}'"
  }

  for_each = var.monitoring

  depends_on = [
    null_resource.proxy_restart
  ]
}

# После установки и готовности всех сервисов запускается настройка мониторинга
# В данной работе alertmanager отправляет оповещения через заранее подготовленный Telegram Bot в заранее созданный Telegram чат.
# Параметры прописаны в переменных terraform telega_bot_token, telega_chat_id которые хранятся в файле secrets.tf. Он не загружается в репозиторий.
# Инструкции по созданию telegram бота и получению chat_id можно взять здесь https://sarafian.github.io/low-code/2020/03/24/create-private-telegram-chatbot.html
# Настройка https://qna.habr.com/q/1134068
resource "null_resource" "monitoring_install" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ../ansible/inventory ../ansible/monitoring_install.yml --extra-vars 'telega_bot_token=${var.telega_bot_token} telega_chat_id=${var.telega_chat_id}'"
  }

  depends_on = [
    null_resource.app_deploy,
    null_resource.gitlab_install,
    null_resource.mysql_replication_slave,
    null_resource.proxy_restart,
    null_resource.runner_install,
    null_resource.prometheus_config
  ]
}
