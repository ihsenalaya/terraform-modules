variable "kubernetes_version" {
  type    = string
  default = null
}

variable "name" {
  type = string
}
variable "location" {
  type = string
}
variable "resource_group_name" {
  type = string
}
variable "dns_prefix" {
  type = string
}
variable "sku_tier" {
  type    = string
  default = "Free"
}

variable "node_resource_group_name" {
  type    = string
  default = null
}

variable "private_cluster_enabled" {
  type    = bool
  default = false
}

variable "private_dns_zone_id" {
  type    = string
  default = null
}

variable "api_server_authorized_ip_ranges" {
  type    = list(string)
  default = []
}

variable "identity" {
  type = object({
    type         = string                 # SystemAssigned | UserAssigned
    identity_ids = optional(list(string))
  })
}

variable "rbac" {
  type = object({
    enabled                = bool
    tenant_id              = optional(string)
    admin_group_object_ids = optional(list(string))
    azure_rbac_enabled     = optional(bool)
    local_account_disabled = optional(bool)
  })
  default = { enabled = true }
}

variable "workload_identity" {
  type = object({
    oidc_issuer_enabled       = optional(bool, true)
    workload_identity_enabled = optional(bool, true)
  })
  default = {}
}

# Dataplane / CNI mode
variable "network_data_plane" {
  description = "Dataplane: azure | cilium"
  type        = string
  default     = null
}

variable "network_plugin_mode" {
  description = "Plugin mode pour Azure CNI (ex: overlay)"
  type        = string
  default     = null
}

# Réseau (NB: vnet_subnet_id/pod_subnet_id sont sur les pools)
variable "network" {
  type = object({
    network_plugin    = string
    network_policy    = optional(string)
    outbound_type     = optional(string)
    load_balancer_sku = optional(string, "standard")
    pod_cidr          = optional(string)      # requis en overlay
    service_cidr      = optional(string)
    dns_service_ip    = optional(string)

    load_balancer_profile = optional(object({
      managed_outbound_ip_count   = optional(number)
      managed_outbound_ipv6_count = optional(number)
      outbound_ip_prefix_ids      = optional(list(string))
      outbound_ip_address_ids     = optional(list(string))
      outbound_ports_allocated    = optional(number)
      idle_timeout_in_minutes     = optional(number)
    }))

    nat_gateway_profile = optional(object({
      managed_outbound_ip_count = optional(number)
      idle_timeout_in_minutes   = optional(number)
    }))
  })
}

# Cluster Autoscaler
variable "auto_scaler_profile" {
  type = object({
    balance_similar_node_groups    = optional(bool)
    expander                       = optional(string)
    max_graceful_termination_sec   = optional(number)
    max_node_provisioning_time     = optional(string)
    max_unready_nodes              = optional(number)
    max_unready_percentage         = optional(number)
    new_pod_scale_up_delay         = optional(string)
    scale_down_delay_after_add     = optional(string)
    scale_down_after_delete        = optional(string)
    scale_down_after_failure       = optional(string)
    scale_down_unneeded            = optional(string)
    scale_down_unready             = optional(string)
    scan_interval                  = optional(string)
    skip_nodes_with_local_storage  = optional(bool)
    skip_nodes_with_system_pods    = optional(bool)
  })
  default = null
}

# Default pool
variable "default_pool" {
  type = object({
    name                  = optional(string, "system")
    vm_size               = string
    node_count            = optional(number)
    auto_scaling_enabled  = optional(bool, true)
    min_count             = optional(number)
    max_count             = optional(number)
    max_pods              = optional(number)
    orchestrator_version  = optional(string)
    zones                 = optional(list(string))
    os_disk_size_gb       = optional(number)
    os_disk_type          = optional(string) # Managed | Ephemeral
    fips_enabled          = optional(bool)
    ultra_ssd_enabled     = optional(bool)
    node_labels           = optional(map(string))

    # BYO VNet / Advanced
    vnet_subnet_id        = optional(string)
    pod_subnet_id         = optional(string)

    kubelet_config = optional(object({
      cpu_manager_policy      = optional(string)
      cpu_cfs_quota_enabled   = optional(bool)
      cpu_cfs_quota_period    = optional(string)
      image_gc_high_threshold = optional(number)
      image_gc_low_threshold  = optional(number)
      pod_max_pid             = optional(number)
      topology_manager_policy = optional(string)
    }))

    linux_os_config = optional(object({
      swap_file_size_mb = optional(number)
      sysctl_config = optional(object({
        fs_aio_max_nr               = optional(number)
        fs_file_max                 = optional(number)
        fs_inotify_max_user_watches = optional(number)
        net_core_rmem_default       = optional(number)
        net_core_rmem_max           = optional(number)
        net_core_wmem_default       = optional(number)
        net_core_wmem_max           = optional(number)
        vm_max_map_count            = optional(number)
      }))
    }))

    upgrade_max_surge = optional(string)  # ex: "33%"
  })
}

# Node pools additionnels
variable "node_pools" {
  type = map(object({
    vm_size               = string
    mode                  = optional(string, "User")
    node_count            = optional(number)
    auto_scaling_enabled  = optional(bool, true)
    min_count             = optional(number)
    max_count             = optional(number)
    max_pods              = optional(number)
    os_type               = optional(string, "Linux")
    vnet_subnet_id        = optional(string)   # nodes subnet
    pod_subnet_id         = optional(string)   # pods subnet (Advanced)
    zones                 = optional(list(string))
    node_labels           = optional(map(string))
    node_taints           = optional(list(string))
    orchestrator_version  = optional(string)
    os_disk_size_gb       = optional(number)
    os_disk_type          = optional(string)
    priority              = optional(string)        # Regular | Spot
    eviction_policy       = optional(string)        # Delete | Deallocate
    spot_max_price        = optional(number)
    enable_ultra_ssd      = optional(bool)

    kubelet_config = optional(object({
      cpu_manager_policy      = optional(string)
      cpu_cfs_quota_enabled   = optional(bool)
      cpu_cfs_quota_period    = optional(string)
      image_gc_high_threshold = optional(number)
      image_gc_low_threshold  = optional(number)
      pod_max_pid             = optional(number)
      topology_manager_policy = optional(string)
    }))

    linux_os_config = optional(object({
      swap_file_size_mb = optional(number)
      sysctl_config = optional(object({
        fs_aio_max_nr               = optional(number)
        fs_file_max                 = optional(number)
        fs_inotify_max_user_watches = optional(number)
        net_core_rmem_default       = optional(number)
        net_core_rmem_max           = optional(number)
        net_core_wmem_default       = optional(number)
        net_core_wmem_max           = optional(number)
        vm_max_map_count            = optional(number)
      }))
    }))
  }))
  default = {}
}

# Monitoring / Add-ons
variable "monitoring" {
  type = object({
    enable_oms_agent            = optional(bool, false)
    log_analytics_workspace_id  = optional(string)
    azure_policy_enabled        = optional(bool, false)

    enable_kv_secrets_provider  = optional(bool, false)
    kv_secret_rotation_enabled  = optional(bool)
    kv_secret_rotation_interval = optional(string)
  })
  default = {}
}

# CSI storage drivers
variable "storage_profile" {
  type = object({
    blob_driver_enabled         = optional(bool)
    disk_driver_enabled         = optional(bool)
    file_driver_enabled         = optional(bool)
    snapshot_controller_enabled = optional(bool)
  })
  default = null
}

# KMS / etcd
variable "kms" {
  type = object({
    key_vault_key_id         = string
    key_vault_network_access = optional(string) # Public | Private
  })
  default = null
}

# Istio add-on
variable "service_mesh" {
  type = object({
    mode                             = optional(string, "Istio")
    internal_ingress_gateway_enabled = optional(bool)
    external_ingress_gateway_enabled = optional(bool)
    revisions                        = optional(list(string)) # requis si activé
  })
  default = null
}

# DES
variable "disk_encryption_set_id" {
  type    = string
  default = null
}

# ACR
variable "attach_acr" {
  type    = bool
  default = false
}
variable "attach_acr_id" {
  type    = string
  default = null
}

variable "tags" {
  type    = map(string)
  default = {}
}
