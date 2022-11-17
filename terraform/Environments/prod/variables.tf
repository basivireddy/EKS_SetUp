variable "region" {
  description = "Region where resources need to be deployed"
  type        = string
}
variable "profile" {
  description = "Profile where resources need to be deployed"
  type        = string
}



variable "vpc_name" {
  description = "Name of the Kubernetes cluster. This string is used to contruct the AWS IAM permissions and roles. If targeting EKS, the corresponsing managed cluster name must match as well."
  type        = string
}

variable "cluster_name" {
  description = "Key Pair name for users to connect to EC2"
  type        = string
}

variable "cluster_version" {
  description = "Key Pair name for users to connect to EC2"
  type        = string
}


# variable "vpc_id" {
#   description = "Key Pair name for users to connect to EC2"
#   type        = string
# }

variable "instance_type" {
  description = "Key Pair name for users to connect to EC2"
  type        = string
}

variable "desired_size" {
  type  = number
  description = "value for nodegroup desired size"
}

variable "min_size" {
  type  = number
  description = "value for nodegroup min size"
}

variable "max_size" {
  type  = number
  description = "value for nodegroup max size of nodes"
}

variable "k8s_cluster_name" {
  description = "Name of the Kubernetes cluster. This string is used to contruct the AWS IAM permissions and roles. If targeting EKS, the corresponsing managed cluster name must match as well."
  type        = string
}

variable "key_name" {
  type        = string
}
