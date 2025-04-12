################################################################################################################
#                               Network config (vpc,subnets,igw,sg,...etc)     
################################################################################################################

############## VPC main ########################
resource "aws_vpc" "main" {
  cidr_block = "192.168.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = true           # Required for EKS
  enable_dns_support = true             # Required for EKS
  assign_generated_ipv6_cidr_block = false 

  tags = {
    Name = "EKS VPC"
  }
}

################# Internet-Gateway ###############
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "EKS IGW"
  }
  
}

# Note:=> We Will create 4-subnets = 2 public & 2 Private

###### TWO Public Subnets ###############

## public_subnet_1
resource "aws_subnet" "public_1" {
    vpc_id = aws_vpc.main.id
    cidr_block = "192.168.0.0/18"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = true 

   tags = {
     Name = "EKS Public_1"
    "kubernetes.io/cluster/eks"   = "shared"
    "kubernetes.io/role/elb"      = "1"
  }

}

## Public_subnet_2
resource "aws_subnet" "public_2" {
  vpc_id = aws_vpc.main.id
  cidr_block = "192.168.64.0/18"        # Note:=> public_subnet_1 started from 192.168.0.0 to 192.168.63.255 (Last ip), then this subnet will start from 192.168.64.0
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true 

  tags = {
    Name = "EKS Public_2"
    "kubernetes.io/cluster/eks"   = "shared"
    "kubernetes.io/role/elb"      = "1"

  }
}

###### Two Private Subnets ###############

## Private Subnet_1
resource "aws_subnet" "private_1" {
  vpc_id = aws_vpc.main.id
  cidr_block = "192.168.128.0/18"
  availability_zone = "us-east-1a"  # Note:=> Public_1 & Private_1 inside in the same AZ
  map_public_ip_on_launch = false 

  tags = {
    Name = "EKS Private_1"
    "kubernetes.io/cluster/eks" = "shared"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

## Private Subnet_2
resource "aws_subnet" "private_2" {
  vpc_id = aws_vpc.main.id
  cidr_block = "192.168.192.0/18"
  availability_zone = "us-east-1b"  
  map_public_ip_on_launch = false 

  tags = {
    Name = "EKS Private_2"
    "kubernetes.io/cluster/eks" = "shared"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

####################### Elastic ip address #############

# First eip
resource "aws_eip" "nat_1" {
  depends_on = [ aws_internet_gateway.main ]
}

# Second eip
resource "aws_eip" "nat_2" {
  depends_on = [ aws_internet_gateway.main ]
}

####################### Two Nat Gateway #############

# First nat
resource "aws_nat_gateway" "gw_1" {
  allocation_id = aws_eip.nat_1.id
  subnet_id = aws_subnet.public_1.id

  tags = {
    Name = "EKS NAT_1"
  }
}

# Second nat
resource "aws_nat_gateway" "gw_2" {
  allocation_id = aws_eip.nat_2.id
  subnet_id = aws_subnet.public_2.id

  tags = {
    Name = "EKS NAT_2"
  }
}

####################### Three Route Tables #############
# one RT for Public Subnet (one igw) & two RTs for private subnets(two nats)

# First RT for Public subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route{
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "Public RT"
  }
}

# Second RT for private_1 (nat1)
resource "aws_route_table" "private_1" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.gw_1.id
  }

  tags = {
    Name = "Private_1 RT"
  }
}

# Third RT for private_2 (nat2)
resource "aws_route_table" "private_2" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.gw_2.id
  }

  tags = {
    Name = "Private_2 RT"
  }
}

#######################   Four Route Tables Associations #############
# Note:=> We will create 4 RT Associacion because we have 4 subnets

# First RT-ass public subnet_1
resource "aws_route_table_association" "public_1" {
  subnet_id = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

# Second RT-ass public subnet_2
resource "aws_route_table_association" "public_2" {
  subnet_id = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

# Third RT-ass private subnet_1
resource "aws_route_table_association" "private_1" {
  subnet_id = aws_subnet.private_1.id
  route_table_id = aws_route_table.private_1.id
}

# Fourth RT-ass private subnet_2
resource "aws_route_table_association" "private_2" {
  subnet_id = aws_subnet.private_2.id
  route_table_id = aws_route_table.private_2.id
}



# ###
# ######## Security Group for eks ######
# resource "aws_security_group" "eks_sg" {
#     name = "eks_sg"
#     description = "Cluster communication with worker nodes"
#     vpc_id = aws_vpc.main.id  
#     egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# resource "aws_security_group_rule" "eks_ingress_cluster" {
#   description       = "Allow workstation to communicate with the cluster API Server"
#   cidr_blocks = [ "0.0.0.0/0" ]
#   from_port = 443
#   to_port = 443
#   protocol = "tcp"
#   security_group_id = aws_security_group.eks_sg.id
#   type = "ingress"

# }

# ###### Security Group for Worker node #########
# resource "aws_security_group" "worker_sg" {
#   name = "worker_sg"
#   description = "Security group for all nodes in the cluster"
#   vpc_id = aws_vpc.main.id

#   egress {
#     from_port = 0
#     to_port = 0
#     protocol = "-1"
#     cidr_blocks = [ "0.0.0.0/0" ]

#   }

#   tags = {
#     "kubernetes.io/cluster/samy_eks" = "owned"
#   }
# }

# resource "aws_security_group_rule" "worker_ingress_self" {
#   description              = "Allow node to communicate with each other"
#   from_port = 0
#   to_port = 65535
#   protocol = "-1"
#   security_group_id = aws_security_group.worker_sg.id
#   source_security_group_id = aws_security_group.worker_sg.id
#   type = "ingress"
# }

# resource "aws_security_group_rule" "worker_ingress_cluster" {
#   description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
#   from_port = 1025
#   to_port = 65535
#   protocol = "tcp"
#   security_group_id = aws_security_group.worker_sg.id
#   source_security_group_id = aws_security_group.eks_sg.id   ### Note: source from master to worker
#   type = "ingress"
# }

# resource "aws_security_group_rule" "eks-cluster-ingress-node-https" {
#   description              = "Allow pods to communicate with the cluster API Server"
#   from_port = 443
#   to_port = 443
#   protocol = "tcp"
#   security_group_id = aws_security_group.worker_sg.id
#   source_security_group_id = aws_security_group.eks_sg.id
#   type = "ingress"

# }

