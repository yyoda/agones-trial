Building agones environment on EKS by terraform.

## Preparation (macOS)
1. `brew install kubectl aws-iam-authenticator helm`
2. install agones
    ```bash
    helm upgrade agones-release \
        --namespace agones-system \
        --set "agones.ping.udp.expose=false" \
        agones/agones
    ```
