# terraform-azurerm-avm-template

This is a template repo for Terraform Azure Verified Modules.

Things to do:

1. Set up a GitHub repo environment called `test`.
1. Configure environment protection rule to ensure that approval is required before deploying to this environment.
1. Create a user-assigned managed identity in your test subscription.
1. Create a role assignment for the managed identity on your test subscription, use the minimum required role.
1. Configure federated identity credentials on the user assigned managed identity. Use the GitHub environment.
1. Create the following environment secrets on the `test` environment:
   1. AZURE_CLIENT_ID
   1. AZURE_TENANT_ID
   1. AZURE_SUBSCRIPTION_ID

## Availability zone selection

This example explicitly places its supporting VM in availability zone `1`. Confirm that the VM SKU and zone are available in the deployment subscription and region before running E2E tests. Adding or changing a zone can require recreating an existing VM; a single zonal VM is not a multi-zone high-availability deployment.

Availability of `Standard_B1s` in `centralindia`, including individual zones, depends on subscription restrictions. Verify the SKU before deployment and select an available SKU or test environment when required; passing policy checks does not remove subscription restrictions.
