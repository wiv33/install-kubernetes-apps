variable "ssh_key" {
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDPpggx0yA9T31g6gWjx5ZEMrwR1ZArXXwmWnvWKeo9hSMI2NoaT31TKHkh0h0B840qI1JsYopFs3vN9K1qySlhw8UDj5IaMERTmB+9JOLskejtfQls12n9A3/XUkqWRb9lPB8SDYe8GWkp85UHaElzFPY3tsXusN7Jlg2f5svRYBH+2ybCFONTYhnEY7yogYb2xe/UQpZbyKtJxC0pkVWI81yeVhd3q+WUJHECZN6/ym8RQM3HD9JOomS8q5ylb/r9e8JNlQrF/xQk8vXO6rKrmihRvm2dgGANrdFS4Ekc3cR9UO2Wxfz1IjHoHVUag4wzILcWzuhf0PucOTs2Qsnx nhn@AL01590622.local"
}

variable "proxmox_host" {
  default = ["shinwhatc"]
  type    = list(string)
}
variable "template_name" {
#    default = "ubuntu2310-ct"
#    default = "local:vztmpl/ubuntu2310-ct"
#  default = "local:vztmpl/ubuntu-23.10-standard_23.10-1_amd64.tar.zst"
}

variable "username" {
  default = "shin"
}

variable "password" {
  default = "Asdfqwer1!"
}