# Module AKS générique (privé/public) avec pools dynamiques


## Caractéristiques
- Compatible clusters **privés** et **publics**
- **Pools dynamiques** via `node_pools` (Linux/Windows, Spot, labels/taints, zones, etc.)
- Profil réseau flexible (Azure CNI/Kubenet/Overlay selon support), LB/NAT GW
- RBAC + AAD managé, **OIDC** et **Workload Identity**
- Autoscaler global + autoscaling par pool
- Intégrations: **Log Analytics**, **Azure Policy**, **Key Vault Secrets Provider**
- Option d'attacher un **ACR** (rôle AcrPull sur l'identité kubelet)


## Entrées majeures
- `name`, `location`, `resource_group_name`, `dns_prefix`
- `private_cluster_enabled`, `public_network_access_enabled`, `api_server_authorized_ip_ranges`
- `identity` (System/User Assigned)
- `rbac` (AAD managé, Azure RBAC, groupes admins)
- `workload_identity` (OIDC/Workload Identity)
- `network` (plugin/policy, subnets, CIDR, LB/NAT profils)
- `default_pool`, `node_pools`
- `monitoring` (OMS/Policy/KV)
- `attach_acr_id`


## Sorties
- `id`, `name`, `kube_config` (sensible), `kubelet_identity_object_id`, `fqdn`, `private_fqdn`


## Bonnes pratiques
- Séparer pools **System** et **User**; limiter workloads aux User pools.
- Utiliser des **taints/labels** pour l'isolement.
- Activer **OIDC/Workload Identity** pour supprimer les secrets.
- Pour privé: prévoir **Private DNS Zone** et **points de terminaison privés** selon votre réseau.


## Notes
- Le provider `azurerm` évolue: adaptez les champs si l'API change.
- Ce module **n'administre pas** le Resource Group : il doit exister (créé par un autre module).
- Privilégier **Azure CNI** (ou CNI Overlay) pour entreprises; Kubenet pour cas simples.