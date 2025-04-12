############################################################################################################
                                          #  EKS cluster
############################################################################################################
resource "aws_eks_cluster" "eks" {
  name = "eks"
  role_arn = aws_iam_role.eks_role.arn
  version = "1.32"                    # Note:=> it is the latest version of k8s at 12/4/2025 
  vpc_config {
    endpoint_private_access = false 
    endpoint_public_access = true 
    subnet_ids = [ 
                  aws_subnet.public_1.id,
                  aws_subnet.public_2.id,
                  aws_subnet.private_1.id,
                  aws_subnet.private_2.id
    ]
    #security_group_ids = [ aws_security_group.eks_sg.id ]
  }
 
  enabled_cluster_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]
depends_on = [ 
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_iam_role_policy_attachment.eks_service_policy,
 ]

}