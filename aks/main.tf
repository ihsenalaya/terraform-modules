

locals {
  tags = merge({
    "managed-by" = "terraform"
    "module"     = "aks-generic"
  }, var.tags)
}

# ---------------------------------------------------------------------------
# AKS Cluster (compatible azurerm >= 4.44.0)
# ---------------------------------------------------------------------------
resource "azurerm_kubernetes_cluster" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix

  kubernetes_version  = var.kubernetes_version
  sku_tier            = var.sku_tier

  node_resource_group   = var.node_resource_group_name
  private_cluster_enabled = var.private_cluster_enabled
  private_dns_zone_id     = var.private_dns_zone_id  # null => géré par AKS

  network_data_plane  = var.network_data_plane      # azure | cilium
  network_plugin_mode = var.network_plugin_mode     # ex: "overlay"

  # API server access (si API publique et IPs autorisées)
  dynamic "api_server_access_profile" {
    for_each = length(var.api_server_authorized_ip_ranges) > 0 ? [1] : []
    content {
      authorized_ip_ranges = var.api_server_authorized_ip_ranges
    }
  }

  # Identity
  identity {
    type         = var.identity.type              # SystemAssigned | UserAssigned
    identity_ids = try(var.identity.identity_ids, null)
  }

  # RBAC / Entra ID (AAD) — plus de 'managed' en 4.x
  role_based_access_control_enabled = var.rbac.enabled
  dynamic "azure_active_directory_role_based_access_control" {
    for_each = var.rbac.enabled ? [1] : []
    content {
      tenant_id              = try(var.rbac.tenant_id, null)
      admin_group_object_ids = try(var.rbac.admin_group_object_ids, null)
      azure_rbac_enabled     = try(var.rbac.azure_rbac_enabled, null)
    }
  }

  # OIDC / Workload Identity
  oidc_issuer_enabled       = try(var.workload_identity.oidc_issuer_enabled, true)
  workload_identity_enabled = try(var.workload_identity.workload_identity_enabled, true)

  # Network profile (4.x : pas de docker_bridge_cidr)
  network_profile {
    network_plugin    = var.network.network_plugin               # kubenet | azure | azure_overlay
    network_policy    = try(var.network.network_policy, null)
    outbound_type     = try(var.network.outbound_type, null)     # loadBalancer | userDefinedRouting | managedNATGateway
    load_balancer_sku = try(var.network.load_balancer_sku, null)
    pod_cidr          = try(var.network.pod_cidr, null)
    pod_subnet_id = try(var.network.pod_subnet_id, null)
    service_cidr      = try(var.network.service_cidr, null)
    dns_service_ip    = try(var.network.dns_service_ip, null)

    dynamic "load_balancer_profile" {
      for_each = try(var.network.load_balancer_profile, null) == null ? [] : [var.network.load_balancer_profile]
      content {
        managed_outbound_ip_count   = try(load_balancer_profile.value.managed_outbound_ip_count, null)
        managed_outbound_ipv6_count = try(load_balancer_profile.value.managed_outbound_ipv6_count, null)
        outbound_ip_prefix_ids      = try(load_balancer_profile.value.outbound_ip_prefix_ids, null)
        outbound_ip_address_ids     = try(load_balancer_profile.value.outbound_ip_address_ids, null)
        outbound_ports_allocated    = try(load_balancer_profile.value.outbound_ports_allocated, null) # (ex-allocated_outbound_ports)
        idle_timeout_in_minutes     = try(load_balancer_profile.value.idle_timeout_in_minutes, null)
      }
    }

    dynamic "nat_gateway_profile" {
      for_each = try(var.network.nat_gateway_profile, null) == null ? [] : [var.network.nat_gateway_profile]
      content {
        managed_outbound_ip_count = try(nat_gateway_profile.value.managed_outbound_ip_count, null)
        idle_timeout_in_minutes   = try(nat_gateway_profile.value.idle_timeout_in_minutes, null)
      }
    }
  }

  # Default node pool (4.x : auto_scaling_enabled ; pas de node_taints ici)
  default_node_pool {
    name       = try(var.default_pool.name, "system")
    vm_size    = var.default_pool.vm_size
    node_count = try(var.default_pool.node_count, null)

    auto_scaling_enabled = try(var.default_pool.auto_scaling_enabled, true)
    min_count            = try(var.default_pool.min_count, null)
    max_count            = try(var.default_pool.max_count, null)
    max_pods             = try(var.default_pool.max_pods, null)

    orchestrator_version = try(var.default_pool.orchestrator_version, null)

    # Subnet uniquement si CNI Azure/Overlay
    vnet_subnet_id = contains(["azure", "azure_overlay"], var.network.network_plugin) ? try(var.network.vnet_subnet_id, null) : null

    zones             = try(var.default_pool.zones, null)
    os_disk_size_gb   = try(var.default_pool.os_disk_size_gb, null)
    os_disk_type      = try(var.default_pool.os_disk_type, null)
    node_labels       = try(var.default_pool.node_labels, null)
    fips_enabled      = try(var.default_pool.fips_enabled, null)
    ultra_ssd_enabled = try(var.default_pool.ultra_ssd_enabled, null)

    dynamic "kubelet_config" {
      for_each = try(var.default_pool.kubelet_config, null) == null ? [] : [var.default_pool.kubelet_config]
      content {
        cpu_manager_policy      = try(kubelet_config.value.cpu_manager_policy, null)
        cpu_cfs_quota_enabled   = try(kubelet_config.value.cpu_cfs_quota_enabled, null)
        cpu_cfs_quota_period    = try(kubelet_config.value.cpu_cfs_quota_period, null)
        image_gc_high_threshold = try(kubelet_config.value.image_gc_high_threshold, null)
        image_gc_low_threshold  = try(kubelet_config.value.image_gc_low_threshold, null)
        pod_max_pid             = try(kubelet_config.value.pod_max_pid, null) # (ex pod_max_pids)
        topology_manager_policy = try(kubelet_config.value.topology_manager_policy, null)
      }
    }

    dynamic "linux_os_config" {
      for_each = try(var.default_pool.linux_os_config, null) == null ? [] : [var.default_pool.linux_os_config]
      content {
        swap_file_size_mb = try(linux_os_config.value.swap_file_size_mb, null)
        dynamic "sysctl_config" {
          for_each = try(linux_os_config.value.sysctl_config, null) == null ? [] : [linux_os_config.value.sysctl_config]
          content {
            fs_aio_max_nr               = try(sysctl_config.value.fs_aio_max_nr, null)
            fs_file_max                 = try(sysctl_config.value.fs_file_max, null)
            fs_inotify_max_user_watches = try(sysctl_config.value.fs_inotify_max_user_watches, null)
            net_core_rmem_default       = try(sysctl_config.value.net_core_rmem_default, null)
            net_core_rmem_max           = try(sysctl_config.value.net_core_rmem_max, null)
            net_core_wmem_default       = try(sysctl_config.value.net_core_wmem_default, null)
            net_core_wmem_max           = try(sysctl_config.value.net_core_wmem_max, null)
            vm_max_map_count            = try(sysctl_config.value.vm_max_map_count, null)
          }
        }
      }
    }

upgrade_settings {
  max_surge = "33%"
}

  tags = local.tags
}

  # Cluster Autoscaler (niveau cluster)
  dynamic "auto_scaler_profile" {
    for_each = var.auto_scaler_profile == null ? [] : [var.auto_scaler_profile]
    content {
      balance_similar_node_groups    = try(auto_scaler_profile.value.balance_similar_node_groups, null)
      expander                       = try(auto_scaler_profile.value.expander, null)
      max_graceful_termination_sec   = try(auto_scaler_profile.value.max_graceful_termination_sec, null)
      max_node_provisioning_time     = try(auto_scaler_profile.value.max_node_provisioning_time, null)
      max_unready_nodes              = try(auto_scaler_profile.value.max_unready_nodes, null)
      max_unready_percentage         = try(auto_scaler_profile.value.max_unready_percentage, null)
      new_pod_scale_up_delay         = try(auto_scaler_profile.value.new_pod_scale_up_delay, null)
      scale_down_delay_after_add     = try(auto_scaler_profile.value.scale_down_delay_after_add, null)
      scale_down_delay_after_delete  = try(auto_scaler_profile.value.scale_down_delay_after_delete, null)
      scale_down_delay_after_failure = try(auto_scaler_profile.value.scale_down_delay_after_failure, null)
      scan_interval                  = try(auto_scaler_profile.value.scan_interval, null)
      scale_down_unneeded            = try(auto_scaler_profile.value.scale_down_unneeded, null)
      scale_down_unready             = try(auto_scaler_profile.value.scale_down_unready, null)
      skip_nodes_with_local_storage  = try(auto_scaler_profile.value.skip_nodes_with_local_storage, null)
      skip_nodes_with_system_pods    = try(auto_scaler_profile.value.skip_nodes_with_system_pods, null)
    }
  }

  # Add-ons
  dynamic "oms_agent" {
    for_each = try(var.monitoring.enable_oms_agent, false) ? [1] : []
    content {
      log_analytics_workspace_id = var.monitoring.log_analytics_workspace_id
    }
  }

  azure_policy_enabled = try(var.monitoring.azure_policy_enabled, false)

dynamic "key_vault_secrets_provider" {
  for_each = try(var.monitoring.enable_kv_secrets_provider, false) ? [1] : []
  content {
    # au moins un des deux doit être présent
    secret_rotation_enabled  = try(var.monitoring.kv_secret_rotation_enabled, true)
    secret_rotation_interval = try(var.monitoring.kv_secret_rotation_interval, null)
  }
}

  # NOTE: 'automatic_channel_upgrade' retiré en 4.x du provider => ne pas utiliser ici.

  tags = local.tags
}

# ---------------------------------------------------------------------------
# Node Pools additionnels (User/System)
# ---------------------------------------------------------------------------
resource "azurerm_kubernetes_cluster_node_pool" "extra" {
  for_each              = var.node_pools
 
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id
name = substr(
  replace("np${lower(each.key)}", "/[^a-z0-9]/", ""),
  0,
  12
)
  vm_size              = each.value.vm_size
  mode                 = try(each.value.mode, "User")
  node_count           = try(each.value.node_count, null)
  auto_scaling_enabled = try(each.value.auto_scaling_enabled, true)
  min_count            = try(each.value.min_count, null)
  max_count            = try(each.value.max_count, null)

  os_type  = try(each.value.os_type, "Linux")
  max_pods = try(each.value.max_pods, null)

  vnet_subnet_id = try(each.value.vnet_subnet_id, null)

  zones                 = try(each.value.zones, null)
  node_labels           = try(each.value.node_labels, null)
  node_taints           = try(each.value.node_taints, null)   # OK sur pools extra
  orchestrator_version  = try(each.value.orchestrator_version, null)
  os_disk_size_gb       = try(each.value.os_disk_size_gb, null)
  os_disk_type          = try(each.value.os_disk_type, null)

  priority        = try(each.value.priority, null)            # Regular | Spot
  eviction_policy = try(each.value.eviction_policy, null)     # Delete | Deallocate
  spot_max_price  = try(each.value.spot_max_price, null)

  # enable_ultra_ssd = try(each.value.enable_ultra_ssd, null)

  dynamic "kubelet_config" {
    for_each = try(each.value.kubelet_config, null) == null ? [] : [each.value.kubelet_config]
    content {
      cpu_manager_policy      = try(kubelet_config.value.cpu_manager_policy, null)
      cpu_cfs_quota_enabled   = try(kubelet_config.value.cpu_cfs_quota_enabled, null)
      cpu_cfs_quota_period    = try(kubelet_config.value.cpu_cfs_quota_period, null)
      image_gc_high_threshold = try(kubelet_config.value.image_gc_high_threshold, null)
      image_gc_low_threshold  = try(kubelet_config.value.image_gc_low_threshold, null)
      pod_max_pid             = try(kubelet_config.value.pod_max_pid, null) # renommé
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
          fs_aio_max_nr               = try(sysctl_config.value.fs_aio_max_nr, null)
          fs_file_max                 = try(sysctl_config.value.fs_file_max, null)
          fs_inotify_max_user_watches = try(sysctl_config.value.fs_inotify_max_user_watches, null)
          net_core_rmem_default       = try(sysctl_config.value.net_core_rmem_default, null)
          net_core_rmem_max           = try(sysctl_config.value.net_core_rmem_max, null)
          net_core_wmem_default       = try(sysctl_config.value.net_core_wmem_default, null)
          net_core_wmem_max           = try(sysctl_config.value.net_core_wmem_max, null)
          vm_max_map_count            = try(sysctl_config.value.vm_max_map_count, null)
        }
      }
    }
  }

 dynamic "upgrade_settings" {
  for_each = try(each.value.priority, "Regular") == "Spot" ? [] : [1]
  content {
    max_surge = "33%"
  }
}


  tags = local.tags
}

# ---------------------------------------------------------------------------
# Optionnel : ACR pull (si un ACR est fourni)
# ---------------------------------------------------------------------------
resource "azurerm_role_assignment" "acr_pull" {
  count                = var.attach_acr ? 1 : 0
  scope                = var.attach_acr_id                    # peut être inconnu au plan
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
}

