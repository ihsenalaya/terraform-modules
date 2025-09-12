locals {
zones = try(each.value.zones, null)
node_labels = try(each.value.node_labels, null)
node_taints = try(each.value.node_taints, null)
orchestrator_version= try(each.value.orchestrator_version, null)
os_disk_size_gb = try(each.value.os_disk_size_gb, null)
os_disk_type = try(each.value.os_disk_type, null)
priority = try(each.value.priority, null)
eviction_policy = try(each.value.eviction_policy, null)
spot_max_price = try(each.value.spot_max_price, null)
enable_ultra_ssd = try(each.value.enable_ultra_ssd, null)


dynamic "kubelet_config" {
for_each = try(each.value.kubelet_config, null) == null ? [] : [each.value.kubelet_config]
content {
cpu_manager_policy = try(kubelet_config.value.cpu_manager_policy, null)
cpu_cfs_quota_enabled = try(kubelet_config.value.cpu_cfs_quota_enabled, null)
cpu_cfs_quota_period = try(kubelet_config.value.cpu_cfs_quota_period, null)
image_gc_high_threshold = try(kubelet_config.value.image_gc_high_threshold, null)
image_gc_low_threshold = try(kubelet_config.value.image_gc_low_threshold, null)
pod_max_pids = try(kubelet_config.value.pod_max_pids, null)
topology_manager_policy = try(kubelet_config.value.topology_manager_policy, null)
}
}


dynamic "linux_os_config" {
for_each = try(each.value.linux_os_config, null) == null ? [] : [each.value.linux_os_config]
content {
swap_file_size_mb = try(linux_os_config.value.swap_file_size_mb, null)
dynamic "sysctl_config" {
for_each = try(linux_os_config.value.sysctl_config, null) == null ? [] : [linux_os_config.value.sysctl_config]
content {
fs_aio_max_nr = try(sysctl_config.value.fs_aio_max_nr, null)
fs_file_max = try(sysctl_config.value.fs_file_max, null)
fs_inotify_max_user_watches = try(sysctl_config.value.fs_inotify_max_user_watches, null)
net_core_rmem_default = try(sysctl_config.value.net_core_rmem_default, null)
net_core_rmem_max = try(sysctl_config.value.net_core_rmem_max, null)
net_core_wmem_default = try(sysctl_config.value.net_core_wmem_default, null)
net_core_wmem_max = try(sysctl_config.value.net_core_wmem_max, null)
net_ipv4_tcp_tw_recycle = try(sysctl_config.value.net_ipv4_tcp_tw_recycle, null)
vm_max_map_count = try(sysctl_config.value.vm_max_map_count, null)
}
}
}
}


upgrade_settings {
max_surge = "33%"
}


tags = local.tags
}


# Attribution du rôle AcrPull à l'identité kubelet (si demandé)
resource "azurerm_role_assignment" "acr_pull" {
count = var.attach_acr_id == null ? 0 : 1
scope = var.attach_acr_id
role_definition_name = "AcrPull"
principal_id = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
}