
resource "azurerm_role_assignment" "object_id" {
  for_each = {
    for key in lookup(var.keys, "object_ids", {}) : key => key
  }

  scope                = var.scope
  role_definition_name = var.role_definition_name
  principal_id         = each.value
}

resource "azurerm_role_assignment" "azuread_apps" {
  for_each = {
    for key in lookup(var.keys, "azuread_app_keys", {}) : key => key
  }

  scope                = var.scope
  role_definition_name = var.role_definition_name
  principal_id         = var.azuread_apps.aad_apps[each.key].azuread_service_principal.object_id
}

resource "azurerm_role_assignment" "azuread_group" {
  for_each = {
    for key in lookup(var.keys, "azuread_group_keys", {}) : key => key
  }

  scope                = var.scope
  role_definition_name = var.role_definition_name
  principal_id         = var.azuread_groups[each.key].id
}

resource "azurerm_role_assignment" "msi" {
  for_each = {
    for key in lookup(var.keys, "managed_identity_keys", {}) : key => key
  }

  scope                = var.scope
  role_definition_name = var.role_definition_name
  principal_id         = var.managed_identities[each.key].principal_id
}