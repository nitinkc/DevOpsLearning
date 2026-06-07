*[ClusterIP]: The default Kubernetes Service type. Exposes the Service only inside the cluster using an internal virtual IP.
*[NodePort]: A Kubernetes Service type that exposes the app on the same static port on every node, so traffic can reach it from outside the cluster.
*[LoadBalancer]: A Kubernetes Service type that asks a cloud provider or local load balancer integration to provision an external load balancer for the Service.
*[Ingress]: A Kubernetes API resource for HTTP and HTTPS routing. It sends web traffic to different Services based on hostnames and paths.
*[DNS]: Domain Name System. In Kubernetes, CoreDNS creates names for Services so pods can find each other without hardcoding IPs.
*[PersistentVolume]: Durable cluster storage that outlives pod restarts.
*[PersistentVolumes]: Durable cluster storage resources that outlive pod restarts.
*[PV]: PersistentVolume.
*[PersistentVolumeClaim]: A request for storage made by a workload, similar to how a pod requests CPU or memory.
*[PersistentVolumeClaims]: Requests for storage made by workloads.
*[PVC]: PersistentVolumeClaim.
*[PVCs]: PersistentVolumeClaims.
*[ConfigMap]: A Kubernetes object used to store non-sensitive configuration like hostnames, flags, and config files.
*[ConfigMaps]: Kubernetes objects used to store non-sensitive configuration like hostnames, flags, and config files.
*[Secret]: A Kubernetes object used to store sensitive data such as passwords, tokens, or keys.
*[Secrets]: Kubernetes objects used to store sensitive data such as passwords, tokens, or keys.
*[NetworkPolicy]: A Kubernetes resource that controls which pods may send traffic to or receive traffic from other pods.
*[Network Policies]: Kubernetes resources that control which pods may send traffic to or receive traffic from other pods.
*[Sidecar]: A helper container that runs in the same pod as the main app and shares its network and storage context.

