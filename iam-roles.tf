#####################################################################################################################
                                                # Iam Roles 
#####################################################################################################################

################## iam roles for eks cluster control plane ###################################

resource "aws_iam_role" "eks_role" {
  name = "eks_role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement": [{
      "Effect"   : "Allow",
      "Principal": { "Service": "eks.amazonaws.com" },
      "Action"   : "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role = aws_iam_role.eks_role.name

}

resource "aws_iam_role_policy_attachment" "eks_service_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role = aws_iam_role.eks_role.name
}

 ##### IAM Roles for Worker nodes ########

resource "aws_iam_role" "worker_role" {
  name = "worker_role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement": [{
      "Effect"   : "Allow",
      "Principal": { "Service": "ec2.amazonaws.com" },
      "Action"   : "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_worker_policy" {
  policy_arn =  "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role = aws_iam_role.worker_role.name
}

resource "aws_iam_role_policy_attachment" "eks_worker_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role = aws_iam_role.worker_role.name
}

resource "aws_iam_role_policy_attachment" "eks_worker_container_registry" {
  policy_arn =  "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role = aws_iam_role.worker_role.name
}