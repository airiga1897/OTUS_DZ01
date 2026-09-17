variable "cloud_id" {
  description = "Идентификатор облака Yandex Cloud; не является секретом."
  type        = string
}

variable "folder_id" {
  description = "Идентификатор существующего отдельного каталога для стенда."
  type        = string
}

variable "zone" {
  description = "Зона доступности в российском регионе."
  type        = string
  default     = "ru-central1-a"
}

variable "name" {
  description = "Префикс имён ресурсов стенда."
  type        = string
  default     = "otus-dz01"
}

variable "ssh_public_key_path" {
  description = "Путь к существующему публичному ключу OpenSSH (.pub), а не к приватному ключу."
  type        = string
  validation {
    condition     = can(regex("^ssh-ed25519 [A-Za-z0-9+/=]+", trimspace(file(pathexpand(var.ssh_public_key_path)))))
    error_message = "Укажите доступный для чтения непустой публичный ключ OpenSSH ed25519."
  }
}

variable "ssh_allowed_cidr" {
  description = "Публичный IPv4-адрес источника SSH-соединения с маской /32."
  type        = string
  validation {
    condition     = can(cidrnetmask(var.ssh_allowed_cidr)) && endswith(var.ssh_allowed_cidr, "/32")
    error_message = "Укажите один публичный IPv4-адрес с маской /32."
  }
}
