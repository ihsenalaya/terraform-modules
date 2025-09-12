variable "name" {
  description = "Nom du cluster AKS"
  type        = string
}

variable "location" {
  description = "Région Azure (ex: westeurope, eastus)"
  type        = string
}

variable "resource_group_name" {
  description = "Nom du Resource Group existant (créé par un autre module)"
  type        = string
}

variable "tags" {
  description = "Tags communs"
  type        = map(string)
  default     = {}
}

variable "kubernetes_version" {
  description = "Version de Kubernetes (null = default stable)"
  type        = string
  default     = null
}

variable "sku_tier" {
  description = "SKU du control plane (Free | Paid)"
  type        = string
  default     = "Free"
}

variable "dns_prefix" {
  description = "Préfixe DNS du cluster"
  type        = string
}

variable "private_cluster_enabled" {
  description = "Active un cluster privé"
  type        = bool
  default     = false
}

variable "private_dns_zone_id" {
  description = "ID d'une zone DNS privée personnalisée (null => gérée par AKS)"
  type        = string
  default     = null
}

variable "api_server_authorized_ip_ranges" {
  description = "Liste d'IP autorisées à joindre l'API (si API publique)"
  type        = list(string)
  default     = []
}

variable "node_resource_group_name" {
  description = "Nom du Node Resource Group (optionnel)"
  type        = string
  default     = null
}

variable "identity" {
  description = "Configuration Managed Identity"
  type = object({
    type         = string                 # SystemAssigned | UserAssigned
    identity_ids = optional(list(string)) # requis si UserAssigned
  })
}

variable "rbac" {
  description = "RBAC & Entra ID (AAD)"
  type = object({
    enabled                 = bool
    tenant_id               = optional(string)
    admin_group_object_ids  = optional(list(string), [])
    azure_rbac_enabled      = optional(bool, false)
  })
  default = {
    enabled                = true
    admin_group_object_ids = []
    azure_rbac_enabled     = false
  }
}

variable "workload_identity" {
  description = "OIDC & Workload Identity"
  type = object({
    oidc_issuer_enabled        = optional(bool, true)
    workload_identity_enabled  = optional(bool, true)
  })
  default = {}
}

variable "network" {
  description = "Profil réseau du cluster"
  type = object({
    network_plugin          = string                      # azure | kubenet | azure_overlay (si supporté)
    network_policy          = optional(string)            # azure | calico (selon plugin)
    outbound_type           = optional(string)            # loadBalancer | userDefinedRouting | managedNATGateway
    load_balancer_sku       = optional(string, "standard")
    pod_cidr                = optional(string)
    service_cidr            = optional(string)
    dns_service_ip          = optional(string)
    vnet_subnet_id          = optional(string)            # requis si Azure CNI/Overlay

    load_balancer_profile = optional(object({
      managed_outbound_ip_count   = optional(number)
      managed_outbound_ipv6_count = optional(number)
      outbound_ip_prefix_ids      = optional(list(string))
      outbound_ip_address_ids     = optional(list(string))
      outbound_ports_allocated    = optional(number)      # renommé (ex allocated_outbound_ports)
      idle_timeout_in_minutes     = optional(number)
    }))

    nat_gateway_profile = optional(object({
      managed_outbound_ip_count = optional(number)
      idle_timeout_in_minutes   = optional(number)
    }))
  })
}

variable "auto_scaler_profile" {
  description = "Réglages globaux du Cluster Autoscaler"
  type = object({
    balance_similar_node_groups      = optional(bool)
    expander                         = optional(string)
    max_graceful_termination_sec     = optional(number)
    max_node_provisioning_time       = optional(string)
    max_unready_nodes                = optional(number)
    max_unready_percentage           = optional(number)
    new_pod_scale_up_delay           = optional(string)
    scale_down_delay_after_add       = optional(string)
    scale_down_delay_after_delete    = optional(string)
    scale_down_delay_after_failure   = optional(string)
    scan_interval                    = optional(string)
    scale_down_unneeded              = optional(string)
    scale_down_unready               = optional(string)
    skip_nodes_with_local_storage    = optional(bool)
    skip_nodes_with_system_pods      = optional(bool)
  })
  default = null
}

variable "default_pool" {
  description = "Paramètres du pool par défaut (system)"
  type = object({
    name                  = optional(string, "system")
    vm_size               = string
    node_count            = optional(number)

    auto_scaling_enabled  = optional(bool, true)   # 4.x
    min_count             = optional(number)
    max_count             = optional(number)

    max_pods              = optional(number)
    orchestrator_version  = optional(string)

    os_disk_size_gb       = optional(number)
    os_disk_type          = optional(string)
    zones                 = optional(list(string), [])
    node_labels           = optional(map(string), {})
    fips_enabled          = optional(bool)
    ultra_ssd_enabled     = optional(bool)

    kubelet_config = optional(object({
      cpu_manager_policy      = optional(string)
      cpu_cfs_quota_enabled   = optional(bool)
      cpu_cfs_quota_period    = optional(string)
      image_gc_high_threshold = optional(number)
      image_gc_low_threshold  = optional(number)
      pod_max_pid             = optional(number)  # renommé (ex pod_max_pids)
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
  })
}

variable "node_pools" {
  description = "Pools additionnels (clé = nom du pool)"
  type = map(object({
    vm_size               = string
    mode                  = optional(string, "User")     # System | User
    node_count            = optional(number)
    auto_scaling_enabled  = optional(bool, true)          # 4.x
    min_count             = optional(number)
    max_count             = optional(number)
    os_type               = optional(string, "Linux")     # Linux | Windows
    max_pods              = optional(number)
    vnet_subnet_id        = optional(string)
    zones                 = optional(list(string), [])
    node_labels           = optional(map(string), {})
    node_taints           = optional(list(string), [])    # autorisé sur pools extra
    orchestrator_version  = optional(string)
    os_disk_size_gb       = optional(number)
    os_disk_type          = optional(string)
    priority              = optional(string)              # Regular | Spot
    eviction_policy       = optional(string)              # Delete | Deallocate
    spot_max_price        = optional(number)
    enable_ultra_ssd      = optional(bool)

    kubelet_config = optional(object({
      cpu_manager_policy      = optional(string)
      cpu_cfs_quota_enabled   = optional(bool)
      cpu_cfs_quota_period    = optional(string)
      image_gc_high_threshold = optional(number)
      image_gc_low_threshold  = optional(number)
      pod_max_pid             = optional(number)          # renommé
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

variable "monitoring" {
  description = "Intégrations monitoring"
  type = object({
    enable_oms_agent              = optional(bool, false)
    log_analytics_workspace_id    = optional(string)
    azure_policy_enabled          = optional(bool, false)
    enable_kv_secrets_provider    = optional(bool, false)

    # >>> nouveaux champs pour 4.44.0
    kv_secret_rotation_enabled    = optional(bool)   # ex: true
    kv_secret_rotation_interval   = optional(string) # ex: "2m"
  })
  default = {}
}

variable "automatic_channel_upgrade" {
  description = "Canal de mise à niveau automatique (none | patch | stable | rapid)"
  type        = string
  default     = null
}

variable "attach_acr_id" {
  description = "ID d'un ACR à attacher (rôle AcrPull sur l'identité kubelet)"
  type        = string
  default     = null
}
