#!/bin/bash 


function gen1()
{
cat <<EOF
apiVersion: "aadpodidentity.k8s.io/v1"
kind: AzureIdentity
metadata:
  name: podmi-ingress-controller-identity
  namespace: a0042
spec:
  type: 0
  resourceID: $TRAEFIK_USER_ASSIGNED_IDENTITY_RESOURCE_ID_BU0001A0042_03
  clientID: $TRAEFIK_USER_ASSIGNED_IDENTITY_CLIENT_ID_BU0001A0042_03
---
apiVersion: aadpodidentity.k8s.io/v1
kind: AzureIdentityBinding
metadata:
  name: podmi-ingress-controller-binding
  namespace: a0042
spec:
  azureIdentity: podmi-ingress-controller-identity
  selector: podmi-ingress-controller
EOF
} 

function gen2()
{
cat <<EOF
apiVersion: secrets-store.csi.x-k8s.io/v1alpha1
kind: SecretProviderClass
metadata:
  name: aks-ingress-contoso-com-tls-secret-csi-akv
  namespace: a0042
spec:
  provider: azure
  parameters:
    usePodIdentity: "true"
    keyvaultName: $KEYVAULT_NAME_BU0001A0042_03
    objects:  |
      array:
        - |
          objectName: traefik-ingress-internal-aks-ingress-contoso-com-tls
          objectAlias: tls.crt
          objectType: cert
        - |
          objectName: traefik-ingress-internal-aks-ingress-contoso-com-tls
          objectAlias: tls.key
          objectType: secret
    tenantId: $TENANTID_AZURERBAC
EOF

}

gen1 > file1.yaml
gen2 > file2.yaml

