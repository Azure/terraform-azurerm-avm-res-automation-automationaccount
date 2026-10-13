# Automation Account

Deploys an Automation Account and its optional automation resources and private endpoints.

This module requires AzureRM v4. Consumers using v3 or v5 must select a compatible v4 provider; existing resource addresses are unchanged. Provider compatibility with existing v5 state must be reviewed before applying.

Private endpoint IP configurations accept a per-IP `member_name`, falling back to the endpoint's `subresource_name`. Optional endpoint locks and role assignments are implemented with AzAPI in either DNS-management mode. Endpoint role assignments do not perform an Azure Active Directory lookup, so `skip_service_principal_aad_check` is retained for the common interface but has no effect.
