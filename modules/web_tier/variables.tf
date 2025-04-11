# **`./modules/web_tier/variables.tf`:**
variable "web_resource_group_name" {
  type = string

}

variable "location" {
  type = string
}

variable "web_subnet_id" {
  type = string
}

variable "web_server_scale_set_name" {
  type = string
}

variable "web_server_sku" {
  type = string
}

variable "web_server_image" {
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })

}

variable "web_server_instance_count" {
  type = number

}

variable "web_lb_name" {
  type = string

}

variable "web_lb_backend_port" {
  type = number

}


variable "web_admin_username" {
  type = string
}

variable "web_admin_password" {
  type = string
}

