# Final Mastery Quiz

This is the capstone quiz for the DevOps Learning Labs. It covers **all** tracks: Docker, Kubernetes, Helm, multi-region, sidecars, GitOps with Flux, observability, security, and troubleshooting. It is designed to be challenging — expect scenario-based questions, multi-select answers, and fill-in-the-blank facts from the labs.

---

## Docker & Containerization

<quiz>
In a multi-stage Dockerfile, which of the following are true?
- [x] The final image only contains layers copied from the last stage.
- [ ] All build tools used in earlier stages remain in the final image unless you run `apk del`.
- [x] It can significantly reduce the final image size.
- [ ] It requires the `scratch` base image to work.

Multi-stage builds let you compile or install in one stage and copy only the artifacts into a smaller runtime stage.
</quiz>

<quiz>
What is the primary purpose of `docker build --cache-from`?
- [ ] To force a fresh build without reusing layers
- [x] To use an existing image as a source for layer cache
- [ ] To tag the image with a cache label
- [ ] To compress the final image
</quiz>

<quiz>
A container that was running as PID 1 is stopped and its writable layer is discarded. This is an example of a container being **[[ephemeral]]**.
</quiz>

---

## Kubernetes Core & Workloads

<quiz>
Which Kubernetes controllers are best matched to these use cases?
- [x] A logging agent that must run on every node: **DaemonSet**
- [ ] A replicated, stateless API: **DaemonSet**
- [x] A single-instance, ordered database: **StatefulSet**
- [x] A horizontally scalable, stateless web app: **Deployment**

StatefulSet provides stable network identity and persistent storage; DaemonSet runs one pod per node; Deployment is for stateless, interchangeable pods.
</quiz>

<quiz>
What happens during a rolling update when `maxSurge: 1` and `maxUnavailable: 0`?
- [ ] Kubernetes replaces all old pods at once
- [x] A new pod is created before an old pod is removed, keeping full capacity
- [ ] At least one pod is always unavailable to speed up the update
- [ ] The update is rejected because the two settings conflict
</quiz>

<quiz>
Fill in the missing field: the smallest schedulable unit in Kubernetes is a **[[Pod]]**.
</quiz>

<quiz>
A pod is stuck in `Pending` for 5 minutes. Which commands help you diagnose why?
- [x] `kubectl describe pod <name>`
- [x] `kubectl get events`
- [ ] `helm rollback <release>`
- [ ] `docker logs <container-id>`

`describe` and `events` show scheduler and resource issues; `helm rollback` is for already-deployed releases; `docker logs` is not for Kubernetes pods.
</quiz>

---

## Kubernetes Networking & Storage

<quiz>
Which Service types expose the application outside the cluster?
- [ ] ClusterIP
- [x] NodePort
- [x] LoadBalancer
- [ ] Headless Service with `clusterIP: None`

ClusterIP and headless services are internal-only.
</quiz>

<quiz>
Which objects are required for a Pod to use durable storage in Kubernetes?
- [x] PersistentVolume (PV)
- [x] PersistentVolumeClaim (PVC)
- [ ] EmptyDir volume
- [ ] ConfigMap

The PVC requests storage; the PV is the actual storage resource. EmptyDir is ephemeral.
</quiz>

<quiz>
In the FQDN `my-svc.my-ns.svc.cluster.local`, what is the first label `my-svc`?
- [ ] The namespace
- [x] The service name
- [ ] The cluster domain
- [ ] The pod name
</quiz>

---

## Helm

<quiz>
Which command is idempotent for installing or upgrading a Helm release?
- [ ] `helm install myapp ./chart`
- [x] `helm upgrade --install myapp ./chart`
- [ ] `helm rollback myapp`
- [ ] `helm lint myapp`
</quiz>

<quiz>
In Helm, the file that defines default configuration values is **[[values.yaml]]**.
</quiz>

<quiz>
Which statements about Helm chart dependencies are true?
- [x] Dependencies can be declared in `Chart.yaml`.
- [ ] Dependencies must be copied into `templates/`.
- [x] `helm dependency update` downloads and packages sub-charts.
- [ ] Helm cannot resolve dependencies from remote repositories.
</quiz>

---

## Multi-Region & Advanced Patterns

<quiz>
You are running two Minikube clusters for `east` and `west`. How do you switch between them with `kubectl`?
- [ ] `kubectl use-context east`
- [x] `kubectl config use-context east`
- [ ] `minikube switch east`
- [ ] `kubectl set cluster east`
</quiz>

<quiz>
A sidecar container in the same pod always shares which namespaces with the app container by default?
- [x] Network namespace
- [x] IPC and storage volumes (when configured)
- [ ] Its own PID namespace
- [ ] Its own UTS namespace

Containers in a pod share the network namespace by default; volumes and IPC are shared when declared.
</quiz>

<quiz>
What is a key trade-off of a multi-region Kubernetes deployment compared to a single-region one?
- [x] Higher complexity and cost for better availability and reduced latency
- [ ] Simpler networking because cross-region latency is lower
- [ ] No need for data replication because each region is independent
- [ ] Single control plane is mandatory
</quiz>

---

## GitOps & Flux

<quiz>
In a pull-based GitOps model such as Flux, which of these are true?
- [x] The cluster watches Git for desired state.
- [x] Manual `kubectl` changes can be detected and reverted.
- [ ] A Jenkins pipeline must run `helm upgrade` after every push.
- [x] Git commit history provides an audit trail.
</quiz>

<quiz>
Which Flux controllers are matched to these responsibilities?
- [x] Fetches from Git: **Source Controller**
- [x] Reconciles Helm charts: **Helm Controller**
- [ ] Builds container images: **Kustomize Controller**
- [x] Applies Kustomize overlays: **Kustomize Controller**

Flux does not build images; it only deploys them.
</quiz>

<quiz>
To roll back a Flux-managed HelmRelease to a previous state, the cleanest action is **[[git revert]]** the offending commit.
</quiz>

<quiz>
What is the function of `interval: 5m` inside a `HelmRelease`?
- [ ] How long the pod has to start before Kubernetes kills it
- [x] How often Flux re-reconciles the Helm release
- [ ] The Helm chart version retention period
- [ ] The maximum time a job is allowed to run
</quiz>

---

## Observability

<quiz>
The three pillars of observability are **[[metrics]]**, **[[logs]]**, and **[[traces]]**.
</quiz>

<quiz>
Which tool in the open-source observability stack is responsible for each task below?
- [x] Collect and store numeric time-series: **Prometheus**
- [x] Visualize dashboards: **Grafana**
- [x] Aggregate logs: **Loki**
- [ ] Define NetworkPolicies: **Grafana**
</quiz>

<quiz>
A 99.9% SLO for a service means the error budget is roughly **[[0.1]]** percent over the budget window.
</quiz>

---

## Security & Operations

<quiz>
Which of these improve Kubernetes secret security from dev to production?
- [ ] Using `ConfigMap` for all credentials
- [x] Enabling encryption at rest for etcd
- [x] Using Sealed Secrets or an external Vault
- [ ] Storing secrets in plain YAML in a public Git repo
</quiz>

<quiz>
A NetworkPolicy that denies all ingress and egress until explicitly allowed is the foundation of a **[[zero-trust]]** network model.
</quiz>

---

## Troubleshooting & Scenarios

<quiz>
A pod is in `CrashLoopBackOff`. Which checks are in the correct order?
- [ ] Scale to zero and back to one, then delete the node
- [x] Read pod logs → inspect `kubectl describe` events → verify image, config, and resources
- [ ] Immediately rebuild the Docker image without checking logs
- [ ] Delete the Deployment and recreate with a new name
</quiz>

<quiz>
Your API latency suddenly jumps from 50 ms to 2 s after a Helm chart update. What should you investigate first?
- [x] The new image tag, resource requests/limits, and readiness probe changes
- [ ] The Git repository commit messages
- [ ] The Grafana dashboard theme
- [ ] The number of labels on each pod
</quiz>

<quiz>
A Helm release is failing with `HelmRelease not ready` in Flux. Which commands give the most useful next clues?
- [x] `flux logs --level=error`
- [x] `kubectl describe helmrelease <name>`
- [ ] `docker system prune -a`
- [ ] `minikube delete`
</quiz>

---

## Wrap-up

Well done! Once you finish all questions above, the quiz plugin will show your score and save your progress. Review any missed questions by revisiting the relevant [theory modules](theory/01-devops-fundamentals.md) and [labs](labs/labs-overview.md).
