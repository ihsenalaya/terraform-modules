module "aks" {
  source = "git::https://github.com/ihsenalaya/terraform-modules.git//aks-complet?ref=main"

  name                = "${local.prefix}-private"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = local.prefix

  kubernetes_version = null
  sku_tier           = "Free"

  # ---- PRIVÉ ----
  private_cluster_enabled         = true
  private_dns_zone_id             = "System"
  api_server_authorized_ip_ranges = []

  identity = { type = "SystemAssigned" }

  # RBAC / Entra ID
  rbac = {
    enabled                = true
    admin_group_object_ids = []
    azure_rbac_enabled     = false
  }

  workload_identity = {
    oidc_issuer_enabled       = true
    workload_identity_enabled = true
  }

  # ======== Cilium + Azure CNI Overlay ========
  network_data_plane  = "cilium"
  network_plugin_mode = "overlay"

  network = {
    network_plugin    = "azure"
    network_policy    = "cilium"
    vnet_subnet_id    = azurerm_subnet.snet_aks.id  # subnet des NODES
    service_cidr      = "10.20.0.0/16"
    dns_service_ip    = "10.20.0.10"
    pod_cidr          = "10.244.0.0/16"             # overlay CIDR des PODS
    load_balancer_sku = "standard"

    load_balancer_profile = {
      managed_outbound_ip_count = 1
      idle_timeout_in_minutes   = 30
      outbound_ports_allocated  = 1024
    }
  }

  auto_scaler_profile = {
    balance_similar_node_groups  = true
    expander                     = "random"
    max_graceful_termination_sec = 600
    scale_down_delay_after_add   = "10m"
    scale_down_unneeded          = "10m"
    scan_interval                = "10s"
    skip_nodes_with_system_pods  = false
  }

  default_pool = {
    name                  = "system"
    vm_size               = "Standard_D2as_v6"
    auto_scaling_enabled  = true
    min_count             = 1
    max_count             = 3
    zones                 = ["1"]
    os_disk_size_gb       = 128
    os_disk_type          = "Managed"
    node_labels           = { role = "system" }

    kubelet_config = {
      cpu_manager_policy      = "static"
      cpu_cfs_quota_enabled   = true
      cpu_cfs_quota_period    = "200ms"
      image_gc_high_threshold = 85
      image_gc_low_threshold  = 80
      pod_max_pid             = 4096
      topology_manager_policy = "best-effort"
    }

    linux_os_config = {
      swap_file_size_mb = 0
      sysctl_config = {
        fs_aio_max_nr               = 65536
        fs_file_max                 = 2097152
        fs_inotify_max_user_watches = 1048576
        net_core_rmem_default       = 262144
        net_core_rmem_max           = 4194304
        net_core_wmem_default       = 262144
        net_core_wmem_max           = 4194304
        vm_max_map_count            = 262144
      }
    }
  }

  node_pools = {
    apps = {
      vm_size              = "Standard_D2as_v6"
      mode                 = "User"
      auto_scaling_enabled = true
      min_count            = 0
      max_count            = 5
      node_labels          = { purpose = "apps" }
      node_taints          = []
      zones                = ["1"]
    }

    batch_spot = {
      vm_size              = "Standard_D2as_v6"
      mode                 = "User"
      priority             = "Spot"
      eviction_policy      = "Delete"
      spot_max_price       = -1
      auto_scaling_enabled = true
      min_count            = 0
      max_count            = 10
      node_labels          = { purpose = "batch" }
      node_taints          = ["batch=true:NoSchedule"]
      zones                = ["1"]
    }
  }

  # Add-ons / Policy / CSI / KV
  monitoring = {
    enable_oms_agent            = true
    log_analytics_workspace_id  = azurerm_log_analytics_workspace.law.id
    azure_policy_enabled        = true                      # <- Azure Policy activé
    enable_kv_secrets_provider  = true
    kv_secret_rotation_enabled  = true                      # requis par le provider
  }

  storage_profile = {                                        # <- CSI drivers
    disk_driver_enabled         = true
    file_driver_enabled         = true
    blob_driver_enabled         = false
    snapshot_controller_enabled = true
  }

  attach_acr    = true
  attach_acr_id = azurerm_container_registry.acr.id

  tags = local.tags
}
