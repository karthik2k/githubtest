variable "location" {
  description = "The default location for resources"
  type        = string
}

variable "aptmgmtuser_pw" {
  description = "The API VM Password"
  type        = string
}

variable "api_username" {
  description = "The API VM username"
  type        = string
}
variable "ssh_key" {
  description = "Path to the public key to be used for ssh access to the VM."
  type        = string
  default     = "id_rsa.pub"
}