variable "aws_region" {
  default = "us-east-1"
}

variable "cluster_name" {
  default = "flask-task-manager-eks"
}

variable "node_group_name" {
  default = "flask-task-manager-nodes"
}

variable "desired_capacity" {
  default = 2
}

variable "max_capacity" {
  default = 3
}

variable "min_capacity" {
  default = 1
}

variable "instance_type" {
  default = "t3.medium"
}
