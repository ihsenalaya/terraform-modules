variable "name" {
description = "Nom du cluster AKS"
type = string
}

variable "location" {
description = "Région Azure (ex: westeurope)"
type = string
}

variable "resource_group_name" {
description = "Nom du Resource Group déjà existant pour AKS (créé par un autre module)."
type = string
}

variable "tags" {
description = "Tags communs"
type = map(string)
default = {}
}

variable "kubernetes_version" {
description = "Version de Kubernetes (optionnel — sinon version par défaut)"
type = string
default = null
}

variable "sku_tier" {
description = "SKU du control plane (Free ou Paid)"
type = string
default = "Free"
}


variable "dns_prefix" {
description = "Préfixe DNS du cluster (requis par AKS même en privé)"
type = string
}


variable "private_cluster_enabled" {
description = "Active le cluster privé"
type = bool
default = false
}


variable "private_dns_zone_id" {
description = "ID d'une zone privée personnalisée (optionnel si 'System')"
type = string
default = null
}

variable "public_network_access_enabled" {
description = "Permettre l'accès public à l'API (true/false)"
type = bool
default = true
}


variable "api_server_authorized_ip_ranges" {
description = "Liste d'IP autorisées à joindre l'API (si accès public)"
type = list(string)
default = []
}


variable "node_resource_group_name" {
description = "Nom du node resource group (optionnel)"
type = string
default = null
}


variable "identity" {
description = "Configuration Managed Identity"
type = object({
type = string # SystemAssigned | UserAssigned
identity_ids = optional(list(string), []) # requis si UserAssigned
})
}


variable "rbac" {
description = "RBAC & AAD"
type = object({
enabled = bool
managed_aad = optional(bool, true) # géré par AKS (AAD managé)
admin_group_object_ids = optional(list(string), [])
azure_rbac_enabled = optional(bool, false) # Azure RBAC pour K8s
})
default = {
enabled = true
managed_aad = true
admin_group_object_ids = []
azure_rbac_enabled = false
}
}


variable "workload_identity" {
description = "OIDC & Workload Identity"
type = object({
oidc_issuer_enabled = optional(bool, true)
workload_identity_enabled = optional(bool, true)
})
default = {}
}


variable "network" {
description = "Profil réseau du cluster"
type = object({
network_plugin = string # azure | kubenet | azure_overlay (selon support)
network_policy = optional(string) # azure | calico (selon plugin)
outbound_type = optional(string, "loadBalancer") # loadBalancer | userDefinedRouting | managedNATGateway
load_balancer_sku = optional(string, "standard")
pod_cidr = optional(string)
service_cidr = optional(string)
dns_service_ip = optional(string)
docker_bridge_cidr = optional(string)
vnet_subnet_id = string # subnet pour le default node pool


load_balancer_profile = optional(object({
idle_timeout_in_minutes = optional(number)
managed_outbound_ip_count = optional(number)
outbound_ip_prefix_ids = optional(list(string))
outbound_ip_address_ids = optional(list(string))
allocated_outbound_ports = optional(number)
idle_timeout_in_minutes_lb = optional(number) # alias toléré
}))


nat_gateway_profile = optional(object({
idle_timeout_in_minutes = optional(number)
managed_outbound_ip_count = optional(number)
effective_outbound_ips = optional(list(string))
}))
})
}

variable "auto_scaler_profile" {
description = "Réglages globaux du cluster autoscaler"
type = object({
balance_similar_node_groups = optional(bool)
expander = optional(string)
max_graceful_termination_sec = optional(number)
max_node_provisioning_time = optional(string)
max_unready_nodes = optional(number)
max_unready_percentage = optional(number)
new_pod_scale_up_delay = optional(string)
scale_down_delay_after_add = optional(string)
scale_down_delay_after_delete = optional(string)
scale_down_delay_after_failure = optional(string)
scan_interval = optional(string)
scale_down_unneeded = optional(string)
scale_down_unready = optional(string)
skip_nodes_with_local_storage = optional(bool)
skip_nodes_with_system_pods = optional(bool)
})
default = {}
}


variable "default_pool" {
description = "Paramètres du pool par défaut"
type = object({
name = optional(string, "system")
vm_size = string
node_count = optional(number)
enable_auto_scaling = optional(bool, true)
min_count = optional(number, 1)
max_count = optional(number, 3)
max_pods = optional(number)
os_disk_size_gb = optional(number)
os_disk_type = optional(string)
zones = optional(list(string), [])
node_labels = optional(map(string), {})
node_taints = optional(list(string), [])
orchestrator_version = optional(string)
fips_enabled = optional(bool)
ultra_ssd_enabled = optional(bool)
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