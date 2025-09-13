variable "name"        { type = string }
variable "location"    { type = string }
variable "resource_group_name" { type = string }
variable "dns_prefix"  { type = string }

variable "kubernetes_version" { type = string, default = null }
variable "sku_tier"           { type = string, default = "Free" } # Free | Paid

variable "node_resource_group_name" { type = string, default = null }

variable "private_cluster_enabled" { type = bool, default = false }
variable "private_dns_zone_id"     { type = string, default = null } # "System" | zone ID | null
variable "api_server_authorized_ip_ranges" {
  type    = list(string)
  default = []
}

variable "identity" {
  type = object({
    type         = string                 # SystemAssigned | UserAssigned
    identity_ids = optional(list(string)) # requis si UserAssigned
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
  default = {
    enabled = true
  }
}

variable "workload_identity" {
  type = object({
    oidc_issuer_enabled       = optional(bool, true)
    workload_identity_enabled = optional(bool, true)
  })
  default = {}
}

# --------- Réseau / Cilium / Overlay / Advanced ---------
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

variable "network" {
  description = "Paramètres réseau"
  type = object({
    network_plugin    = string                            # azure | kubenet | azure_overlay
    network_policy    = optional(string)                  # azure | calico | cilium
    outbound_type     = optional(string)                  # loadBalancer | userDefinedRouting | managedNATGateway
    load_balancer_sku = optional(string, "standard")
    pod_cidr          = optional(string)
    service_cidr      = optional(string)
    dns_service_ip    = optional(string)
    vnet_subnet_id    = optional(string)                  # subnet NODES
    pod_subnet_id     = optional(string)                  # subnet PODS (advanced)

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

# --------- Autoscaler (cluster) ---------
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
    scale_down_delay_after_delete  = optional(string)
    scale_down_delay_after_failure = optional(string)
    scale_down_unneeded            = optional(string)
    scale_down_unready             = optional(string)
    scan_interval                  = optional(string)
    skip_nodes_with_local_storage  = optional(bool)
    skip_nodes_with_system_pods    = optional(bool)
  })
  default = null
}

# --------- Default pool ---------
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

# --------- Node pools additionnels ---------
variable "node_pools" {
  description = "Pools supplémentaires (map)"
  type = map(object({
    vm_size               = string
    mode                  = optional(string, "User")
    node_count            = optional(number)
    auto_scaling_enabled  = optional(bool, true)
    min_count             = optional(number)
    max_count             = optional(number)
    max_pods              = optional(number)
    os_type               = optional(string, "Linux")
    vnet_subnet_id        = optional(string)
    pod_subnet_id         = optional(string)
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

# --------- Add-ons / Monitoring ---------
variable "monitoring" {
  description = "Intégrations monitoring & addons"
  type = object({
    enable_oms_agent            = optional(bool, false)
    log_analytics_workspace_id  = optional(string)
    azure_policy_enabled        = optional(bool, false)

    enable_kv_secrets_provider  = optional(bool, false)
    kv_secret_rotation_enabled  = optional(bool)   # requis si enable_kv_secrets_provider=true (un des deux)
    kv_secret_rotation_interval = optional(string) # ex "2m"
  })
  default = {}
}

# --------- Storage / CSI ---------
variable "storage_profile" {
  description = "CSI drivers"
  type = object({
    blob_driver_enabled         = optional(bool)
    disk_driver_enabled         = optional(bool)
    file_driver_enabled         = optional(bool)
    snapshot_controller_enabled = optional(bool)
  })
  default = null
}

# --------- KMS / etcd ---------
variable "kms" {
  description = "KMS (Key Vault) pour chiffrement etcd"
  type = object({
    key_vault_key_id         = string
    key_vault_network_access = optional(string) # Public | Private
  })
  default = null
}

# --------- Istio service mesh add-on ---------
variable "service_mesh" {
  description = "Istio-based service mesh add-on"
  type = object({
    internal_ingress_gateway_enabled = optional(bool)
    external_ingress_gateway_enabled = optional(bool)
  })
  default = null
}

# --------- Disk Encryption Set ---------
variable "disk_encryption_set_id" {
  description = "DES pour nœuds/volumes (CMK)"
  type        = string
  default     = null
}

# --------- ACR ---------
variable "attach_acr" {
  description = "Créer l'assignation AcrPull pour l'identité kubelet"
  type        = bool
  default     = false
}
variable "attach_acr_id" {
  description = "ID de l'ACR (scope) à attacher"
  type        = string
  default     = null
}

variable "tags" {
  type    = map(string)
  default = {}
}
