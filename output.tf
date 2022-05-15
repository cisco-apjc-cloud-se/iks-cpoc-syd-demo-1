### Shared Kube Config ###
output "kube_config" {
  // value = data.intersight_kubernetes_cluster.cluster.results[0].kube_config
  # value = data.intersight_kubernetes_cluster.iks.results[0].k8s_cluster_kubeconfig
  value = module.terraform-intersight-iks.k8s_cluster_kubeconfig
  sensitive = true
}

// output "cluster_moid" {
//   value = module.terraform-intersight-iks.cluster_moid
//   sensitive = false
// }
