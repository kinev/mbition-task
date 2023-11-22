variable client_vpc_cidr_block {
    type = string
    description = "VPC CIDR Block for client"
}

variable client_public_subnet {
    type = string
    description = "Public Subnet CIDR Block for client"
}

variable client_private_subnet {
    type = string
    description = "Private Subnet CIDR Block for client"
}

variable client_demo_instance_ami {
    type = string
    description = "AMI for the demo instance"
    default = "ami-0e8a34246278c21e4"
}

variable client_demo_instance_type {
    type = string
    description = "Instance type for the demo instance"
    default = "t2.medium"
}

variable availability_zone {
    type = string
    description = "Availability zone for resources to be created in"
}

variable client_demo_instance_ebs_size {
    type = number
    description = "The size of the EBS attached to the instance"
}

variable client {
    type = string
    description = "The name of the client"
}