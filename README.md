Building agones environment on EKS by terraform.

## Preparation (macOS)
1. Install local utilities
    ```bash
    brew install kubectl aws-iam-authenticator helm`
    ```

2. Install Agones to k8s from Helm
    ```bash
    kubectl create namespace agones-system
    helm install agones --namespace agones-system --set "agones.ping.udp.expose=false" agones/agones
    ```

3. Create server
    ```bash
    kubectl create -f https://raw.githubusercontent.com/googleforgames/agones/release-1.11.0/examples/simple-tcp/gameserver.yaml
    ```
