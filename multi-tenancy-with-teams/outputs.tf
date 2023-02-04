output "admin_team_update_kubeconfig" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = "aws eks --region ${local.region} update-kubeconfig --name ${module.eks.cluster_name} --role-arn ${module.admin_team.iam_role_arn}"
}

output "red_team_update_kubeconfig" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = "aws eks --region ${local.region} update-kubeconfig --name ${module.eks.cluster_name} --role-arn ${module.red_team.iam_role_arn}"
}

output "blue_team_update_kubeconfig" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value = [for team in module.blue_teams :
    "aws eks --region ${local.region} update-kubeconfig --name ${module.eks.cluster_name} --role-arn ${team.iam_role_arn}"
  ]
}
