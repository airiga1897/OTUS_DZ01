output "public_ip" {
  description = "Публичный IPv4-адрес созданной ВМ."
  value       = yandex_compute_instance.lab.network_interface[0].nat_ip_address
}

output "instance_id" {
  value = yandex_compute_instance.lab.id
}

output "image_id" {
  description = "Идентификатор образа Ubuntu, выбранного для создания ВМ."
  value       = data.yandex_compute_image.ubuntu.id
}

output "ssh_command" {
  description = "Команда SSH; при необходимости добавьте -i с путём к соответствующему приватному ключу."
  value       = "ssh ubuntu@${yandex_compute_instance.lab.network_interface[0].nat_ip_address}"
}
