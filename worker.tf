############################################################################################################
                                          #  EKS Worker nodes
############################################################################################################
resource "aws_eks_node_group" "worker_node" {
  cluster_name = aws_eks_cluster.eks.name
  node_group_name = "worker-node"
  node_role_arn = aws_iam_role.worker_role.arn
  subnet_ids = [ aws_subnet.private_1.id, aws_subnet.private_2.id]       # Note:=> in this project we will run worker node within private subnets.

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }
  version = "1.32"
  ami_type       = "AL2_x86_64"
  instance_types = [ "t3.medium" ]
  capacity_type = "ON_DEMAND"
  disk_size = 20  # 20 Gib
  force_update_version = false 
  labels = {
    role = "worker-node"
  }

  depends_on = [ 
    aws_iam_role_policy_attachment.eks_worker_policy,
    aws_iam_role_policy_attachment.eks_worker_cni_policy,
    aws_iam_role_policy_attachment.eks_worker_container_registry
   ] 

}