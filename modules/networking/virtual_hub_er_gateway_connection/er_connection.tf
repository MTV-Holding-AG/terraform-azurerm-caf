locals {
  arm_filename = "${path.module}/arm_vhub_er_connection.json"

  template_content = templatefile(
    local.arm_filename,
    {
      resource_name = format("%s/%s",local.express_route_gateway_name, local.express_route_connection_name)
      express_route_circuit_peering_id = local.express_route_circuit_peering_id
      authorization_key = local.authorization_key
      routing_weight = local.routing_weight
      enable_internet_security = local.enable_internet_security
      associatedRouteTable = jsonencode(local.associatedRouteTable)
      propagated_route_tables = jsonencode(local.propagated_route_tables)
      vnet_routes = jsonencode(local.vnet_routes)
    }
  )


  express_route_gateway_name = var.settings.express_route_gateway_name
  express_route_connection_name = var.settings.name
  express_route_circuit_peering_id = var.express_route_circuit_id
  authorization_key = var.authorization_key
  routing_weight = try(var.settings.routing_weight, 0)
  enable_internet_security = try(var.settings.enable_internet_security, false)

  associatedRouteTable = {
    id = coalesce(
      try(var.virtual_hub_route_tables[try(var.settings.route_table.lz_key, var.client_config.landingzone_key)][var.settings.route_table.key].id, ""),
      try(var.settings.route_table.id, "")
    )
  }

  propagated_route_tables = {
    Labels = try(var.settings.propagated_route_tables.labels, [])
    Ids = coalesce(
      flatten(
        [
          for key in try(var.settings.propagated_route_tables.ids, []) : {
            Id = key
          }
        ]
      ),
      flatten(
        [
          for key in try(var.settings.propagated_route_tables.keys, []) : {
            Id = var.virtual_hub_route_tables[try(var.settings.propagated_route_tables.lz_key, var.client_config.landingzone_key)][key].id
          }
        ]
      )
    )
  }

  vnet_routes = {
    staticRoutes = flatten(
      [
        for key, value in var.settings.vnet_routes : {
          name = value.name
          addressPrefixes = value.address_prefixes
          nextHopIpAddress = value.next_hop_ip_address
        }
      ]
    )
  }

}