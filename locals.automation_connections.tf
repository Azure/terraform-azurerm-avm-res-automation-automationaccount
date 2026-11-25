locals {
  automation_connection_overrides = {
    for connection in concat(
      [
        for certificate in values(var.automation_connection_certificates) : {
          connection_key = certificate.connection_key
          type           = "Azure"
          values = {
            AutomationCertificateName = certificate.automation_certificate_name
            SubscriptionID            = certificate.subscription_id
          }
        }
      ],
      [
        for principal in values(var.automation_connection_service_principals) : {
          connection_key = principal.connection_key
          type           = "AzureServicePrincipal"
          values = {
            ApplicationId         = principal.application_id
            CertificateThumbprint = principal.certificate_thumbprint
            SubscriptionId        = principal.subscription_id
            TenantId              = principal.tenant_id
          }
        }
      ],
      [
        for certificate in values(var.automation_connection_classic_certificates) : {
          connection_key = certificate.connection_key
          type           = "AzureClassicCertificate"
          values = {
            CertificateAssetName = certificate.certificate_asset_name
            SubscriptionId       = certificate.subscription_id
            SubscriptionName     = certificate.subscription_name
          }
        }
      ],
    ) : connection.connection_key => connection...
  }
  automation_connections = {
    for key, connection in var.automation_connections : key => merge(connection, {
      values = merge(
        connection.values,
        [for override in lookup(local.automation_connection_overrides, key, []) : override.values]...
      )
    })
  }
}
