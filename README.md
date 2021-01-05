Building agones environment on EKS by terraform.

## Preparation (macOS)
1. Install local utilities
    ```bash
    brew install kubectl aws-iam-authenticator helm`
    ```

2. Install Agones to k8s from Helm
    ```bash
    helm install agones \
        --namespace agones-system \
        --set "agones.ping.udp.expose=false" \
        agones/agones
    ```
