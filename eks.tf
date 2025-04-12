# resource "aws_eks_cluster" "eks_cluster" {
#   name = "samy_eks"
#   role_arn = aws_iam_role.eks_role.arn
#   vpc_config {
#     subnet_ids = [  ]
#     security_group_ids = [ aws_security_group.eks_sg.id ]
#   }
#   version = "1.26"
#   enabled_cluster_log_types = [
#     "api",
#     "audit",
#     "authenticator",
#     "controllerManager",
#     "scheduler"
#   ]
# depends_on = [ 
#     aws_iam_role_policy_attachment.eks_cluster_policy,
#     aws_iam_role_policy_attachment.eks_service_policy,
#  ]

#   tags = {
#     Environment = "PoC"
#     Owner       = "Terraform"
#   }
# }