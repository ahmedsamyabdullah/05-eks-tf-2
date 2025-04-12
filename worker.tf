# resource "aws_eks_node_group" "worker_node" {
#   cluster_name = aws_eks_cluster.eks_cluster.name
#   node_group_name = "samy_worker"
#   node_role_arn = aws_iam_role.worker_role.arn
#   subnet_ids = [ aws_subnet.public.id, aws_subnet.private.id ]
#   ami_type       = "AL2_x86_64"
#   instance_types = [ "t3.medium" ]
#   ssh_key_name = "jenkins-key"
#   remote_access {
#     ec2_ssh_key = "jenkins-key"
#     source_security_group_ids = [aws_security_group.worker_sg.id]
#   }
    
#   scaling_config {
#     desired_size = 2
#     max_size     = 3
#     min_size     = 1
#   }
# }