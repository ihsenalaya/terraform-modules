variable "name" {
})
}


variable "node_pools" {
description = "Pools additionnels (clé = nom du pool)"
type = map(object({
vm_size = string
mode = optional(string, "User") # System | User
node_count = optional(number)
enable_auto_scaling = optional(bool, true)
min_count = optional(number, 1)
max_count = optional(number, 3)
os_type = optional(string, "Linux") # Linux | Windows
max_pods = optional(number)
vnet_subnet_id = optional(string)
zones = optional(list(string), [])
node_labels = optional(map(string), {})
node_taints = optional(list(string), [])
orchestrator_version = optional(string)
os_disk_size_gb = optional(number)
os_disk_type = optional(string)
priority = optional(string) # Regular | Spot
eviction_policy = optional(string) # Delete | Deallocate (si Spot)
spot_max_price = optional(number)
enable_ultra_ssd = optional(bool)
kubelet_config = optional(object({
cpu_manager_policy = optional(string)
cpu_cfs_quota_enabled = optional(bool)
cpu_cfs_quota_period = optional(string)
image_gc_high_threshold = optional(number)
image_gc_low_threshold = optional(number)
pod_max_pids = optional(number)
topology_manager_policy = optional(string)
}))
linux_os_config = optional(object({
swap_file_size_mb = optional(number)
sysctl_config = optional(object({
fs_aio_max_nr = optional(number)
fs_file_max = optional(number)
fs_inotify_max_user_watches = optional(number)
net_core_rmem_default = optional(number)
net_core_rmem_max = optional(number)
net_core_wmem_default = optional(number)
net_core_wmem_max = optional(number)
net_ipv4_tcp_tw_recycle = optional(bool)
vm_max_map_count = optional(number)
}))
}))
}))
default = {}
}


variable "monitoring" {
description = "Intégration Log Analytics et Azure Policy"
type = object({
enable_oms_agent = optional(bool, true)
log_analytics_workspace_id = optional(string)
azure_policy_enabled = optional(bool, false)
enable_kv_secrets_provider = optional(bool, false)
})
default = {}
}


variable "automatic_channel_upgrade" {
description = "Canal de mise à niveau automatique (none, patch, stable, rapid)"
type = string
default = null
}


variable "attach_acr_id" {
description = "ID de l'ACR à attacher (Role AcrPull sur l'identité kubelet)"
type = string
default = null
}