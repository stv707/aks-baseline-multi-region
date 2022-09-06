# Prerequisites

This is the starting point for the instructions on deploying the [AKS baseline multi cluster reference implementation](../../README.md). There is required access and tooling you'll need in order to accomplish this. Follow the instructions below and on the subsequent pages so that you can get your environment ready to proceed with the creation of the AKS clusters.

## Steps

1. Latest [Azure CLI installed](https://docs.microsoft.com/cli/azure/install-azure-cli?view=azure-cli-latest) (must be at least 2.37), or you can perform this from Azure Cloud Shell by clicking below.

   [![Launch Azure Cloud Shell](https://docs.microsoft.com/azure/includes/media/cloud-shell-try-it/launchcloudshell.png)](https://shell.azure.com)

1. Login into your Azure subscription, and save your Azure subscription's tenant id.

   > :warning: The user or service principal initiating the deployment process _must_ have the following minimal set of Azure Role-Based Access Control (RBAC) roles:
   >
   > - [Contributor role](https://docs.microsoft.com/azure/role-based-access-control/built-in-roles#contributor) is _required_ at the subscription level to have the ability to create resource groups and perform deployments.
   > - [User Access Administrator role](https://docs.microsoft.com/azure/role-based-access-control/built-in-roles#user-access-administrator) is _required_ at the subscription level since you'll be performing role assignments to managed identities across various resource groups.

   ```bash
   az login
   TENANTID_AZURERBAC=$(az account show --query tenantId -o tsv)
   TENANTS=$(az rest --method get --url https://management.azure.com/tenants?api-version=2020-01-01 --query 'value[].{TenantId:tenantId,Name:displayName}' -o table)
   ```

   :bulb: If you don't have an Azure subscription, you can create a [free account](https://azure.microsoft.com/free).

1. Validate your saved Azure subscription's tenant id is correct

   ```bash
   echo "${TENANTS}" | grep -z ${TENANTID_AZURERBAC}
   ```

   :warning: Do not procced if the tenant highlighted in red is not correct. Start over by `az login` into the proper Azure subscription

1. While the following feature(s) are still in _preview_, please enable them in your target subscription.

   1. [Register the OIDC Issuer preview feature = `EnableOIDCIssuerPreview`](https://docs.microsoft.com/azure/aks/cluster-configuration#oidc-issuer-preview)

   1. [Register the Federated Identity Credentials preview feature = `FederatedIdentityCredentials`](https://TODO)

   1. [Register the Workload Identity preview feature = `EnableWorkloadIdentityPreview`](https://TODO)

    ```bash
   az feature register --namespace "Microsoft.ContainerService" -n "EnableOIDCIssuerPreview"
   az feature register --namespace "Microsoft.ManagedIdentity" -n "FederatedIdentityCredentials"
   az feature register --namespace "Microsoft.ContainerService" -n "EnableWorkloadIdentityPreview"

   # Keep running until all say "Registered." (This may take up to 20 minutes.)
   az feature list -o table --query "[?name=='Microsoft.ContainerService/EnableOIDCIssuerPreview' || name=='Microsoft.ManagedIdentity/FederatedIdentityCredentials' || name=='Microsoft.ContainerService/EnableWorkloadIdentityPreview'].{Name:name,State:properties.state}"
   
   # When all say "Registered" then re-register the AKS and related resource providers
   az provider register --namespace Microsoft.ContainerService
   az provider register --namespace Microsoft.ManagedIdentity
   ```

1. Install [GitHub CLI](https://github.com/cli/cli/#installation)

1. Login GitHub Cli

   ```bash
   gh auth login -s "repo,admin:org"
   ```

1. Fork the repository first, and clone it

   ```bash
   gh repo fork mspnp/aks-baseline-multi-region --clone=true --remote=false
   cd aks-baseline-multi-region
   git remote remove upstream
   ```

   > :bulb: The steps shown here and elsewhere in the reference implementation use Bash shell commands. On Windows, you can use the [Windows Subsystem for Linux](https://docs.microsoft.com/windows/wsl/about#what-is-wsl-2) to run Bash.

1. Get your GitHub user name

   ```bash
   GITHUB_USER_NAME=$(echo $(gh auth status 2>&1) | sed "s#.*as \(.*\) (.*#\1#")
   ```

1. Ensure the following tooling is also installed:
   1. [OpenSSL](https://github.com/openssl/openssl#download). In order to generate self-signed certs used in this implementation. _OpenSSL is already installed in Azure Cloud Shell._

      > :warning: Some shells may have the `openssl` command aliased for LibreSSL. LibreSSL will not work with the instructions found here. You can check this by running `openssl version` and you should see output that says `OpenSSL <version>` and not `LibreSSL <version>`.

   1. [Certbot](https://certbot.eff.org/). Certbot is a free, open source software tool for automatically using Let’s Encrypt certificates on manually-administrated websites to enable HTTPS.

### Next step

:arrow_forward: [Prep for Azure Active Directory integration](./02-aad.md)
