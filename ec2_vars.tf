variable "pub_key" {
  type = string
  description = "Public SSH key"
}

variable "pvt_key" {
  type = string
  description = "Private SSH key"
}

variable "ec2_ami" {
  type = string
  description = "Image to use for EC2 instances"
}
