resource "null_resource" "runner_install" {
  provisioner "local-exec" {
    command = "ANSIBLE_FORCE_COLOR=1 ansible-playbook -i ../ansible/inventory ../ansible/gitlab_runner.yml"
  }

  depends_on = [
    null_resource.wait
  ]
}
