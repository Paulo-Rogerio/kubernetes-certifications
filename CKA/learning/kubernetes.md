# 🚀 Menu

- [Command Line - Contexts](#-command-line---contexts)
- [Command Line - Nodes](#-command-line---nodes)
- [Command Line - Explorando API](#-command-line---explorando-api)
- [Create Object - Pod](#-create-object---pod)
- [Create Object - StaticPod](#-create-object---staticpod)
- [Create Object - Init Containers](#-create-object---init-containers)
- [Create Object - Replace Entrypoint](#-create-object---replace-entrypoint)
- [Create Object - Multi Containers](#-create-object---multi-containers)
- [Create Object - Accessing Pod Without Kubectl Via Nsenter](#-create-object---accessing-pod-without-kubectl-via-nsenter)
- [Create Object - Pod Lifecycle](#-create-object---pod-lifecycle)
- [Create Object - Namespace](#-create-object---namespace)
- [Create Object - Deployment](#-create-object---deployment)
- [Create Object - Scale Deployment](#-create-object---scale-deployment)
- [Create Object - Request Limits](#-create-object---request-limits)
- [Create Object - Resources Limits](#-create-object---resources-limits)
- [Create Object - ReplicaSet](#-create-object---replicaset)
- [Create Object - ReplicaSet Rollout](#-create-object---replicaset-rollout)
- [Create Object - Rollout maxSurge / maxUnavailable](#-create-object---rollout-maxsurge--maxunavailable)
- [Create Object - Liveness / Readness Probes](#-create-object---liveness--readness-probes)
- [Create Object - Daemonset](#-create-object---daemonset)
- [Create Object - Statefullset](#-create-object---statefullset)
- [Create Object - PDB / PodDisruptionBudget](#-create-object---pdb--poddisruptionbudget)
- [Create Object - Jobs](#-create-object---jobs)
- [Create Object - CronJobs](#-create-object---cronjobs)
- [Create Object - Services Tipos](#-create-object---services-tipos)
- [Create Object - Ipvs Vs Iptables](#-create-object---ipvs-vs-iptables)
- [Create Object - Manutenção em Membros do Cluster](#-create-object---manutenção-em-membros-do-cluster)
- [Create Object - External Name](#-create-object---external-name)
- [Create Object - Trafic Policy](#-create-object---trafic-policy)
- [Create Object - Estratégias Deploy](#-create-object---estratégias-deploy)
- [Create Object - Deploy Canary](#-create-object---deploy-canary)
- [Create Object - Deploy Blue Green](#-create-object---deploy-blue-green)
- [Create Object - Ingress Controller](#-create-object---ingress-controller)
- [Create Object - Ingress Múltiplos Paths](#-create-object---ingress-múltiplos-paths)
- [Create Object - Ingress Error 503](#-create-object---ingress-error-503)
- [Create Object - Ingress TLS](#-create-object---ingress-tls)
- [Create Object - ConfigMap Vs Secrets](#-create-object---configmap-vs-secrets)
- [Create Object - ConfigMap](#-create-object---configmap)
- [Create Object - ConfigMap Vhost Ingress](#-create-object---configmap-vhost-ingress)
- [Create Object - Secrets](#-create-object---secrets)
- [Create Object - Storage PV / PVC / StorageClass](#-create-object---storage-pv--pvc--storageclass--accessmode)
- [Create Object - Reclaim Policy PVC / StorageClass](#-create-object---reclaim-policy-pvc--storageclass)
- [Create Object - HPA / VPA](#-create-object---hpa--vpa)
- [Create Object - CNI](#-create-object---cni)
- [Create Object - DNS](#-create-object---dns)
- [Create Object - Network Policies](#-create-object---network-policies)
- [Create Object - RBAC / CRB / RB](#-create-object---rbac--crb--rb)
- [Create Object - RBAC / Create User](#-create-object---rbac--create-user)
- [Create Object - RBAC / Create Context](#-create-object---rbac--create-context)
- [Create Object - RBAC / Configurando Autorização](#-create-object---rbac--configurando-autorização)
- [Create Object - RBAC / Role ServiceAccount + RolingBindgings](#-create-object---rbac--role-serviceaccount--rolingbindgings)
- [Create Object - Affinity / Node-Selector Labels](#-create-object---affinity--node-selector-labels)
- [Create Object - Affinity / Node-Affinity](#-create-object---affinity--node-affinity)
- [Create Object - Affinity / Pod-Affinity](#-create-object---affinity--pod-affinity)
- [Create Object - Affinity / PodAntiAffinity](#-create-object---affinity--podantiaffinity)
- [Create Object - Affinity / Tolerations](#-create-object---affinity--tolerations)
- [Create Object - Affinity / Pod Topology Spread Constraints](#-create-object---affinity--pod-topology-spread-constraints)
- [Cluster Upgrade - Ferramentas e Boas Práticas](#-cluster-upgrade---ferramentas-e-boas-práticas)
- [Cluster Upgrade - Control Plane / Masters](#-cluster-upgrade---control-plane--masters)
- [Cluster Upgrade - Control Data / Workers](#-cluster-upgrade---control-data--workers)
- [Dicas - CrashLoopBackOff](#-dicas---crashloopbackoff)
- [Dicas - ImagePullBackOff](#-dicas---imagepullbackoff)
- [Dicas - Node NotReady](#-dicas---node-notready)
- [Explorando Documentação - Kubectl](#-explorando-documentação---kubectl)
- [Plugins](#-plugins)

# 🚀 Command Line - Contexts

```bash
k config get-contexts
k config set-context <name-context> --namespace='<namespace>'
k config set-context kubernetes-admin@kubernetes --namespace='metallb-system'
k config set-context kubernetes-admin@kubernetes --namespace=''
k config use-context estagiario

# Applies to the current context
k config set-context --current --namespace=default

# Which user is logged in (authenticated)
k auth whoami

# Logged in user can see pods
k auth can-i get pods --as=r
k auth can-i list pods --as=r

# Merge 2 kubeconfig
kubectl config view --flatten

KUBECONFIG=~/.kube/config:~/.kube/kube_outro_cluster_config kubectl config view --flatten > ~/.kube/kube-merge

# AWS ( EKS )
aws eks update-kubeconfig --dry-run --name paulo --region us-east-2
```
[Menu](#-menu)

# 🚀 Command Line - Nodes

```bash
k get nodes

# Ip Node
k get nodes -o wide

# Manifests Node
k get nodes -o yaml

# Needed in Metric Server.
# Having MetalLB deployed allows you to use ExternalIP
k top nodes

helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm repo update
helm upgrade \
  --install \
  --namespace kube-system \
  --create-namespace metrics-server metrics-server/metrics-server \
  --set-string args[0]=--kubelet-insecure-tls \
  --set-string args[1]="--kubelet-preferred-address-types=InternalIP\,Hostname\,ExternalIP"

# Define Label
nodes=$(k get nodes --no-headers | awk '$3 == "<none>" {print $1}')
for i in ${nodes[@]}
do
  k label node ${i} node-role.kubernetes.io/worker=""
done

# Do not schedule any pods on the worker
k cordon worker01
k uncordon worker01
```
[Menu](#-menu)

# 🚀 Command Line - Explorer API

```bash
# Verbosity level + high
k get pods -A -v9

# Viewing the Certificates
k config view --raw -o jsonpath='{.users[?(@.name=="kind-prgs")].user.client-certificate-data}' \
| base64 -d \
| openssl x509 -text -noout

# Extracting Certificates
base64 -d <<< $(k config view --raw -o jsonpath='{.users[?(@.name=="kind-prgs")].user.client-key-data}') > prgs.key

base64 -d <<< $(k config view --raw -o jsonpath='{.users[?(@.name=="kind-prgs")].user.client-certificate-data}') > prgs.crt

base64 -d <<< $(k config view --raw -o jsonpath='{.clusters[?(@.name=="kind-prgs")].cluster.certificate-authority-data}') > ca.crt

port=$(docker inspect prgs-control-plane \
  --format='{{(index (index .NetworkSettings.Ports "6443/tcp") 0).HostPort}}')

curl --cacert ca.crt --cert prgs.crt --key prgs.key  "https://127.0.0.1:${port}/api/v1/pods?limit=500"

# Consulting API
k config view --raw -o jsonpath='{.users[0].user.client-certificate-data}' | base64 -d > /tmp/cert.crt
k config view --raw -o jsonpath='{.users[0].user.client-key-data}' | base64 -d > /tmp/cert.key
curl \
  -k \
  --cert /tmp/cert.crt \
  --key /tmp/cert.key \
  --cacert /etc/kubernetes/pki/ca.crt \
  https://127.0.0.1:6443/api/v1/pods?limit=500

openssl x509 -in /tmp/cert.crt -text

# Consultando Usando Rotas anonymous
curl -k https://127.0.0.1:6443/version
curl -k https://127.0.0.1:6443/healthz
curl -k https://127.0.0.1:6443/livez
curl -k https://127.0.0.1:6443/readyz

# Check if Cluster accepts anonymous routes
cat /etc/kubernetes/manifests/kube-apiserver.yaml | grep anonymous

# List Pods
k get pod

# List all Pods
k get pod -A

# Extract manifests
k get pods -n kube-system etcd-master01 -o json
k get pods -n kube-system etcd-master01 -o yaml

# Labels
k get pod -A --show-labels
k get pod -n kube-system etcd-master01
k get pod -A -l <label>=<value>
k get pod -A -l component=etcd

# Ip Pods.
k get pod -A -o wide

# "Watch" changes in real time.
k get pod -A -w

k edit pod -n kube-system etcd-master01
k describe pod -n kube-system etcd-master01
k delete pod -n kube-system etcd-master01

# Logs
k logs -n <namespace> <pod>
k logs -n kube-system etcd-master01

# Connect container
k exec -it -n <namespace> <pod> -- bash
k exec -it -n kube-flannel kube-flannel-ds-77m55 -- bash
k exec -it -n kube-flannel kube-flannel-ds-77m55 -- bash -c "pwd; ls"
```

[Menu](#-menu)

# 🚀 Create Object - Pod

# Some examples below make use of plugins, for more details see [Plugins](#-plugins).

```bash
# Create Resources
k apply -f <file-name.yml>

# Apply all manifests the diretory current.
k apply -f .
k apply -f ./<dir>

# Apply all manifeste by URL
k apply -f https://<url>

# Returns a list of objects and whether they are Global or linked to a namespace
kubectl api-resources

# Creates the Pod, and when closed, deletes it
k run <pod-name> --image=<image-name> --rm
# Ex:
k run demo --image alpine --rm -it -- sh

# Create a YAML of a Pod deployment with a service of type ClusterIP
# By default, when specifying --expose, only IP Clusters are created
k run demo --image nginx --port=80 --expose --dry-run=client -o yaml

# If I want to create service to type NodePort?
# After created, apply patch to determine a high port.
# Default:30000-32767
#
k run demo --image nginx --port=80
k expose pod demo --port=80 --target-port=80 --type=NodePort
k patch svc demo -p '{"spec":{"ports":[{"port":80,"targetPort":80,"nodePort":30007}]}}'

# If I need to change the range?
# kubectl get pods -n kube-system kube-apiserver-master01 -o yaml
# Add entry
- --service-node-port-range=20000-40000
```
[Menu](#-menu)

# 🚀 Create Object - StaticPod

```bash

# Every pod that contains a yaml manifest in this path is a staticPod
ls /etc/kubernetes/manifests/

# Static Pods, not managed by the scheduler (api server), as this is an exclusive kubelet process
# The kubelete (component that rotates on the node) is the pilot that controls the Nodes.

systemctl list-units --type=service --state=active
systemctl status kubelet

# Kubelete is programmed to read any existing manifest in /etc/kubernetes/manifests
# Observe that in workers (workers), this directory is empty.

# If we place any manifest inside this worker directory, it will start immediately
# If you try to kill him he is recreated

# Using specifically by the controlplane. Because it is static within the worker , IT IS NOT SCALABLE.
```
[Menu](#-menu)

# 🚀 Create Object - Init Containers

```bash

# What are init Containers?
# Container init, they are not part of the main pod process, they are generally actions that perform certain pre-requisite tasks (ex: cloning a repo).

# How to simulate?
# This busybox image is an image that contains the essential Linux binaries, but it is not a distro where you can run apt/yum/apk commands

k run --image busybox --rm -it demo sh

# Run while false
until ping -c 1 mymysql; do echo "Trying to resolve..."; echo; sleep 1; done

ping: bad address 'mymysql'
Trying to resolve...

ping: bad address 'mymysql'
Trying to resolve...

ping: bad address 'mymysql'
Trying to resolve...

ping: bad address 'mymysql'
Trying to resolve...

...
...

PING mymysql (10.97.106.196): 56 data bytes

# Create the service in another TTY
# After this action the script above starts responding.

k create service clusterip mymysql --tcp=80:80
k delete svc mymysql


# Applying the above scenario...

cat <<EOF | k apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
  - name: nginx
    image: nginx
    ports:
    - containerPort: 80
  initContainers:
  - name: waitfordns
    image: busybox
    command: [ "/bin/sh", "-c", "--" ]
    args: [ "echo 'Clone repo....'; sleep 40;" ]
EOF

# I can have several init containers, and only when it finishes (passes), will the application's real container be executed.

k get pods
nginx   0/1     Init:0/1   0          25s

k logs nginx
Defaulted container "nginx" out of: nginx, waitfordns (init)
Error from server (BadRequest): container "nginx" in pod "nginx" is waiting to start: PodInitializing

# In this context, 2 containers are created in the same pod (nginx => application and waitfordns which is my pre-deploy)
# For me to read the logs of this "pre-deploy" called waitfordns

k logs nginx -c waitfordns -f
Clone repo....
```
[Menu](#-menu)

# 🚀 Create Object - Replace Entrypoint

```bash
# Pod will rise and then die, as entrypoint waits for a command
# Ex: terraform plan , terraform apply
#
k neat <<< $(k run --image hashicorp/terraform terraform --dry-run=client -o yaml) | k apply -f -

# Set sleep big
cat <<EOF | k apply -f -
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: terraform
  name: terraform
spec:
  containers:
  - name: terraform
    image: hashicorp/terraform
    command:
      - "sleep"
      - "9999999"
EOF

# Set While true infinite
cat <<EOF | k apply -f -
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: terraform
  name: terraform
spec:
  containers:
  - name: terraform
    image: hashicorp/terraform
    command: [ "/bin/sh", "-c", "--" ]
    args: [ "while true; do sleep 30; done;" ]
EOF
```
[Menu](#-menu)

# 🚀 Create Object - Multi Containers

```bash

# Create multiple containers in the same Pod.

cat <<EOF | k apply -f -
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: multicontainers
  name: multicontainers
spec:
  containers:
  - image: nginx
    name: nginx
  - image: alpine
    name: debug
    command:
      - "sleep"
      - "99999"
EOF

# Logs
k logs multicontainers

k logs multicontainers -c nginx
k logs multicontainers -c debug

# Accessing debug container
k exec -it multicontainers -c debug -- sh
ps fax
```
[Menu](#-menu)

# 🚀 Create Object - Accessing Pod Without Kubectl Via Nsenter

```bash
# Where is the deployment running?
k get pods -o wide


# Install package jq
apt update && apt install jq
crictl ps | grep multicontainers

# Accessing a Pod without kubectl, to do this connect via ssh to the worker where the Pod is running
# Use crictl to access this Container directly from the Worker.
crictl ps | grep multicontainers

dfa92a11e4461       a40c03cbb81c5       22 hours ago        Running             debug               0                   73cd0774bbfec       multicontainers         default
84cdb66aba237       5cdef4ac3335f       22 hours ago        Running             nginx               0                   73cd0774bbfec       multicontainers         default

# Directly accessing the container
crictl exec -it dfa92a11e4461 sh

# Another way to access this pod is using ( nsenter )
# nsenter (Namespace Enter => If typed alone enter the prompt for the first container in the list)
# Network namespace => Run the command within the network namespace of this process
nsenter --help

# Accessing the Pod that runs the sleep process within the Pod's perspective, in the same network namespace.
#
# Query the container manifests and retrieve the PID
crictl inspect dfa92a11e4461 | jq -r '.info.pid'
148192

# ****NOTE: ****If you DO NOT PASS THE "-n" (container perspective, using the network namespace), the command will use
# the host's perspective (host network) and you will not be able to reach the service
nsenter -t 148192 -n ls /
nsenter -t 148192 -n curl localhost
```

[Menu](#-menu)

# 🚀 Create Object - Pod Lifecycle

```bash

# https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/

# A Pod is given a deadline to finish gracefully, which is 30 seconds by default. In other words, the application must go up in this time interval and exit with status code 0.

# After 30 seconds, the kubelet sends a sigkill signal to the application, and kills the process immediately.

# We can manipulate this life cycle, configure a yaml so that whenever a sigterm is received, an action is performed with a little more than the standard 30 seconds.

# Ex:
k get pods nginx -o wide
nginx   1/1     Running   0          42h   10.244.1.12   worker01   <none>           <none>

# Upload another deploy with lifecycle
# When closed, before closing this pod it will send a curl to Nginx
# It could be a notification on slack informing that Pod was recycled.

cat <<EOF | k apply -f -
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: pod-lifecycle
  name: pod-lifecycle
spec:
  terminationGracePeriodSeconds: 40
  containers:
  - image: nginx
    name: pod-lifecycle
    command:
      - "sleep"
      - "9999"
    lifecycle:
       preStop:
          exec:
            command:
              - sh
              - -c
              - curl 10.244.1.12
EOF

# Monitoring Logs
k logs nginx -f

# When killing the Pod ( pod-lifecycle ) I should receive a curl in the logs above.
k delete pod pod-lifecycle -n default

# You should receive a notification in the Nginx pod logs
10.244.1.16 - - [23/Feb/2026:14:27:47 +0000] "GET / HTTP/1.1" 200 615 "-" "curl/8.14.1" "-"

# If the command (curl/script) takes more than 30 seconds to execute, I can adjust this by setting
# a value that satisfies my need.
- terminationGracePeriodSeconds: 60

```
[Menu](#-menu)

# 🚀 Create Object - Namespace

```bash
cat <<EOF | k apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: prgs
EOF

# It is a Global object
k api-resources | grep namespace

# Creating by command line
k create ns familia

# If you don't remember how to declare the manifest
k neat <<< $(k create ns familia --dry-run=client -o yaml)
k neat <<< $(k create ns familia --dry-run=client -o yaml)
```
[Menu](#-menu)

# 🚀 Create Object - Deployment

```bash
# Deployment => Stateless application (Scalable applications)
# Stateless, does not depend on a state.
# Statless is the ability of the application to be scalable.

k create deployment --image=nginx nginx-paulo

k neat <<< $(k get deployment nginx-paulo -o yaml)

# Deployment ensures that the pod is recreated, even if the Pod is deleted.
k delete pod nginx-paulo-5b98995fcc-25zj6

k delete deployment nginx-paulo

# This is cleaner
k neat <<< $(k create deployment --image=nginx nginx-paulo --replicas=2 --dry-run=client -o yaml)

apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx-paulo
  name: nginx-paulo
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx-paulo
  template:
    metadata:
      labels:
        app: nginx-paulo
    spec:
      containers:
      - image: nginx
        name: nginx

k neat <<< $(k create deployment --image=nginx nginx-paulo --dry-run=client -o yaml) | k apply -f -
```
[Menu](#-menu)

# 🚀 Create Object - Scale Deployment

```bash
k scale --help
k scale deployment nginx-paulo --replicas 10
```
[Menu](#-menu)

# 🚀 Create Object - Request Limits

```bash
# Memoria => Limits   ( Hard ) => 1G
#         => Requests ( Soft ) => 200M

# CPU     => Limits   ( Hard )
#         => Requests ( Soft )

# Soft limit => It is the limit that the system actually applies at the moment.
# A process can open 1024 descriptors
ulimit -n
1024

ulimit -n 4096
4096

# Hard Limit => It is the maximum ceiling that Soft can reach.

# A process can have 1,048,576 simultaneous files/sockets
# This is the maximum ceiling that Soft can reach
ulimit -Hn
1048576

# ==========================================================================
# It is the resource available on the Worker (Where it will receive the workload)
# Note:
# Request is always used when a pod is placed inside a node.
# It is taken into account when choosing the node where the pod will be placed.
# Kube-schedules decides which worker my pod will run on, it evaluates the resources.
# ==========================================================================
#
# When I define the number of Requests, it is this number that the scheduler would take
# into account to determine which worker the pod
# go to work. Set to 200M for example, if the worker has 500MB free it would put ,
# because it is within the value that woker can support.

# Manifest Request: 1 cpu / 4 GB Ram
k apply -f manifesto.yaml

# The scheduler will only schedule this Pod on a node that has at least 1 CPU and 4 GB of Ram available

apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx-paulo
  name: nginx-paulo
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx-paulo
  template:
    metadata:
      labels:
        app: nginx-paulo
    spec:
      containers:
      - image: nginx
        name: nginx
        resources:
          requests:
            cpu: 1
            memory: 4G

# How to read Node capacity?
k get nodes
k describe node <node-name>
k top nodes

# CPU:
# It is reported in number, vcpu quantity or percentage
# 100m (10% of cpu) milicpu or millicore
# 0.1 (10% of cpu)
# Memory:
# It is reported in M/G ex: 500M
```
[Menu](#-menu)

# 🚀 Create Object - Resources Limits

```bash

k explain
k explain deployment.spec
k explain deployment.spec.template
k explain deployment.spec.template.spec
k explain deployment.spec.template.spec.containers
k explain deployment.spec.template.spec.containers.resources
k explain deployment.spec.template.spec.containers.resources.requests

# Cgroup => Container resource limits
#
# Cgroups (Control Groups) are a feature of the Linux kernel that allow:
# - Limit CPU
# - Limit memória
# - Limit I/O
# - Control number of processes
# - Measure consumption
# - Containers (Docker, containerd, CRI-O) use cgroups to enforce these limits.

# Nomenclature manifestos Yaml
# 100m ( 10 % da cpu ) mili-cpu / mili-core
# 0.1  ( 10% da cpu )
# Memory is Informed in M/G ex: 500M

# If the container exceeds the defined 64MB
# 👉 Kernel runs OOM Killer
# 👉 The container dies

# But what if you don't define limit?
# 👉 The container can consume all of the node’s memory
# 👉 May cause global OOM
# 👉 Can kill other pods

apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx-paulo
  name: nginx-paulo
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx-paulo
  template:
    metadata:
      labels:
        app: nginx-paulo
    spec:
      containers:
      - image: nginx
        name: nginx
        resources:
          requests:
            cpu: 100m
            memory: 64M
          limits:
            cpu: 1
            memory: 512M

```
[Menu](#-menu)

# 🚀 Create Object - ReplicaSet

```bash
# It is an object in the Cluster, responsible for ensuring a specific number of Pods are always running.

# Retrieve the manifest
k neat <<< $(k get deployment nginx-paulo -o yaml)

k get rs
NAME                    DESIRED   CURRENT   READY   AGE
nginx-paulo-78455bbb4   1         1         1       12m

# Replace Image, forces the replicaset to be changed.
k neat <<< $(k get deployment nginx-paulo -o yaml) | sed 's/image: nginx/image: httpd/' | k apply -f -

k get rs
NAME                     DESIRED   CURRENT   READY   AGE
nginx-paulo-78455bbb4    0         0         0       14m
nginx-paulo-7bd98bdb44   1         1         1       26s

# The zeroed replicaset is kept for restore purposes.
# Deployments are the ones who create the replicasets
#
# How does ReplicaSet know where to deploy?
# A: The labels are intended to guide the replicaset so that it identifies which Pod it will manage.
# It is also used to direct that a pod can deploy to a given worker.
# The deployment manages the Pods linked to a certain label, this is due to matchLabels.
#
# Label scope deployment

apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx-paulo
    environment: development
  name: nginx-paulo
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx-paulo
  template:
    metadata:
      labels:
        app: nginx-paulo
    spec:
      containers:
      - image: httpd
        name: nginx

# Show labels only for deployment scope
k get deployment --show-labels
NAME          READY   UP-TO-DATE   AVAILABLE   AGE   LABELS
nginx-paulo   1/1     1            1           27m   app=nginx-paulo,environment=development

k get pods --show-labels
NAME                           READY   STATUS    RESTARTS   AGE   LABELS
nginx-paulo-7bd98bdb44-p9qk8   1/1     Running   0          15m   app=nginx-paulo,pod-template-hash=7bd98bdb44

Se eu quiser add label para pod tenho que fazer isso abaixo do objeto spec

# Set Labels at Pod Scope

apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx-paulo
    environment: development
  name: nginx-paulo
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx-paulo
  template:
    metadata:
      labels:
        app: nginx-paulo
        environment: development
    spec:
      containers:
      - image: httpd
        name: nginx

# Filtering by label
k get pod -l app=nginx-paulo
k get pod -n kube-system -l k8s-app=kube-dns
```
[Menu](#-menu)

# 🚀 Create Object - ReplicaSet Rollout

```bash

# What are my replicasets?
k get rs
NAME                     DESIRED   CURRENT   READY   AGE
nginx-paulo-78455bbb4    0         0         0       38m
nginx-paulo-7bd98bdb44   1         1         1       24m

# History Rollout
k rollout history deployment/nginx-paulo
deployment.apps/nginx-paulo
REVISION  CHANGE-CAUSE
1         <none>
2         <none>

# If you want to follow a rollout in real time
watch k rollout status deployment/nginx-paulo

# Making background to go back to the previous version
k rollout undo deployment/nginx-paulo --to-revision=1
deployment.apps/nginx-paulo rolled back

# Check Rollout History again
k rollout history deployment/nginx-paulo
deployment.apps/nginx-paulo
REVISION  CHANGE-CAUSE
2         <none>
3         <none>

# What are my replicasets?
k get rs
NAME                     DESIRED   CURRENT   READY   AGE
nginx-paulo-78455bbb4    1         1         1       42m
nginx-paulo-7bd98bdb44   0         0         0       28m

# Checking that it returned to the httpd image.
k get pods nginx-paulo-78455bbb4-pssgv -o yaml | grep image:

# How to see the content of a revision?
k rollout history deployment/nginx-paulo --revision=2

deployment.apps/nginx-paulo with revision #2
Pod Template:
  Labels:	app=nginx-paulo
	pod-template-hash=7bd98bdb44
  Containers:
   nginx:
    Image:	httpd
    Port:	<none>
    Host Port:	<none>
    Environment:	<none>
    Mounts:	<none>
  Volumes:	<none>
  Node-Selectors:	<none>
  Tolerations:	<none>

# How to know which revision is running

k get rs
NAME                     DESIRED   CURRENT   READY   AGE
nginx-paulo-78455bbb4    0         0         0       38m
nginx-paulo-7bd98bdb44   1         1         1       24m

k get rs nginx-paulo-78455bbb4 -o yaml | grep deployment.kubernetes.io/revision
  deployment.kubernetes.io/revision: "3"
  deployment.kubernetes.io/revision-history: "1"

# Restart all nginx-paulo Deployment Pods
k rollout restart deployment/nginx-paulo
```

[Menu](#-menu)

# 🚀 Create Object - Rollout maxSurge / maxUnavailable

```bash
# By default, the rollout increases 25% of the pods (new release) and as these pods become healthy,
# it kills proportionally the same amount (25%) of the old replicaset.

# Summary:
# Starts 25% of new pods
# Finish 25% of old pods

# Imagine that we have 100 Pod running, in this scenario it would go up 25% more, that is, I would have 125 Pod running.
# And when these new pods reach health, then yes, it would kill the 25 old Pods.
# Suppose you want to customize this rollout when a new release goes live, and have the following characteristic:

# What I need to keep in mind is:

# maxSurge => Maximum number of pods that can be scheduled for rollout above the desired level, that is, if desired, it is 100
# this option would upload 100 new pods.
# Being:
# 100 Pods ( old replicaset ) + 100 Pods ( new replicaset ) = 200 Pods

# maxUnavailable => Number of pods that can be unavailable during a rollout.
# If set to 0 , it does not drop any pods until the new ones become heath.

# Object that handles the deployment strategy (Documentation)
k explain deployment.spec.strategy
k explain deployment.spec.strategy.rollingUpdate


# Good strategy
# Do not drop any pod while any of the new replicaset remains heath
# Make it 1 to 1 (replace)

apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx-paulo
    environment: development
  name: nginx-paulo
spec:
  strategy:
    rollingUpdate:
      maxSurge: 10%
      maxUnavailable: 0
  replicas: 5
  selector:
    matchLabels:
      app: nginx-paulo
  template:
    metadata:
      labels:
        app: nginx-paulo
        environment: development
    spec:
      containers:
      - image: nginx
        name: nginx
```
[Menu](#-menu)

# 🚀 Create Object - Liveness / Readness Probes

```bash
#==================================================
# ReadinessProbe => Ready to receive traffic.
#==================================================
#
# Ready guarantees that a get query on some "/health" route responds with status code 200 to start receiving traffic, so the Pod is transacted to 1/1. This happens at pod startup.

#==================================================
# LivenessProbe => Ensures that the application is still alive.
#==================================================
#
# Live, to ensure that the application remains live, monitors this "/health" route for the lifetime of the pod.
# If the app crashes for some reason and this guy who transacts the pod to 0/1.
# At this point the pod is restarted to return to 1/1


k explain deployment.spec.template.spec.containers

k explain deployment.spec.template.spec.containers.readinessProbe

k explain deployment.spec.template.spec.containers.readinessProbe.httpGet

k explain deployment.spec.template.spec.containers.livenessProbe

# Simulating Scenario - Readness

cat <<EOF | k apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx-paulo
    environment: development
  name: nginx-paulo
spec:
  strategy:
    rollingUpdate:
      maxSurge: 10%
      maxUnavailable: 0
  replicas: 1
  selector:
    matchLabels:
      app: nginx-paulo
  template:
    metadata:
      labels:
        app: nginx-paulo
        environment: development
    spec:
      containers:
      - image: nginx
        name: nginx
        readinessProbe:
          httpGet:
            path: "/health"
            port: 80
EOF

# Despite being Running, the pod will not be available until it is 1/1
# Why will it be like 0/1?
# This /health route is not a valid route, so this pod will never be 1/1
#
k get pods
NAME                           READY   STATUS    RESTARTS   AGE
nginx-paulo-5fd456976b-fffr6   0/1     Running   0          8s

k describe pod nginx-paulo-5fd456976b-fffr6 | grep -A 20 "Events"
Events:
  Type     Reason     Age                   From               Message
  ----     ------     ----                  ----               -------
  Normal   Scheduled  4m49s                 default-scheduler  Successfully assigned default/nginx-paulo-5fd456976b-fffr6 to worker01
  Normal   Pulling    4m48s                 kubelet            Pulling image "nginx"
  Normal   Pulled     4m47s                 kubelet            Successfully pulled image "nginx" in 1.292s (1.292s including waiting). Image size: 62944796 bytes.
  Normal   Created    4m47s                 kubelet            Created container: nginx
  Normal   Started    4m47s                 kubelet            Started container nginx
  Warning  Unhealthy  74s (x25 over 4m47s)  kubelet            Readiness probe failed: HTTP probe failed with statuscode: 404


# The fix is ​​to adjust the path to "/"

cat <<EOF | k apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx-paulo
    environment: development
  name: nginx-paulo
spec:
  strategy:
    rollingUpdate:
      maxSurge: 10%
      maxUnavailable: 0
  replicas: 1
  selector:
    matchLabels:
      app: nginx-paulo
  template:
    metadata:
      labels:
        app: nginx-paulo
        environment: development
    spec:
      containers:
      - image: nginx
        name: nginx
        readinessProbe:
          httpGet:
            path: "/"
            port: 80
        livenessProbe:
          httpGet:
            path: "/"
            port: 80
EOF

k get pods
NAME                           READY   STATUS    RESTARTS   AGE
nginx-paulo-699b6ff548-sprc2   1/1     Running   0          59s

# TO simulate the livesproble we will remove the html file from nginx to generate an error.
k exec -it nginx-paulo-699b6ff548-sprc2 -- bash -c "rm -f /usr/share/nginx/html/index.html"

# The pod will receive an error in the log, and liveness will try 3x and after that it will restart the Pod.
k get pods -w
nginx-paulo-699b6ff548-sprc2   0/1     Running   1 (2s ago)   2m3s

# Good practices

k explain deployment.spec.template.spec.containers
k explain deployment.spec.template.spec.containers.env

https://12factor.net/
```
[Menu](#-menu)

# 🚀 Create Object - Daemonset

```bash
#=====================================================================
# Features:
# Daemonset => 1 Pod on each Node (Usually log collectors)
# Daemonset does not define the number of replicas in the manifests.
# Daemonset will be equal to the number of nodes in a cluster.
# Daemonset does not pass through kube-scheduler
#
# Use case:
# Log Collector => needs to run at host level.
# CNI => Runs at host level
# Patch => Apply a particular patch
#=====================================================================

# For logs, the host's /var/log folder is usually mounted within the DaemonSet ( pod )

kubectl get nodes --show-labels | tr ',' '\n'

NAME       STATUS   ROLES           AGE     VERSION   LABELS
master01   Ready    control-plane   6d12h   v1.34.4   beta.kubernetes.io/arch=amd64
beta.kubernetes.io/os=linux
kubernetes.io/arch=amd64
kubernetes.io/hostname=master01
kubernetes.io/os=linux
node-role.kubernetes.io/control-plane=
node.kubernetes.io/exclude-from-external-load-balancers=
worker01   Ready    worker          6d12h   v1.34.4   beta.kubernetes.io/arch=amd64
beta.kubernetes.io/os=linux
kubernetes.io/arch=amd64
kubernetes.io/hostname=worker01
kubernetes.io/os=linux
node-role.kubernetes.io/worker=

# The label shows it like this ( kubernetes.io/hostname=worker01 ),
# but in the yaml declaration we define it like this ( kubernetes.io/hostname: "worker01" )

cat <<EOF | k apply -f -
apiVersion: apps/v1
kind: DaemonSet
metadata:
  labels:
    app: nginx-paulo
    environment: development
  name: nginx-paulo
spec:
  selector:
    matchLabels:
      app: nginx-paulo
  template:
    metadata:
      labels:
        app: nginx-paulo
        environment: development
    spec:
      containers:
      - image: nginx
        name: nginx
      nodeSelector:
        kubernetes.io/hostname: "worker01"
EOF

k get pods
NAME                READY   STATUS    RESTARTS   AGE
nginx-paulo-sr6q2   1/1     Running   0          31s

k get daemonset
NAME          DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR                     AGE
nginx-paulo   1         1         1       1            1           kubernetes.io/hostname=worker01   57s


# Running specific node.
k patch daemonset nginx-paulo -p '
spec:
  template:
    spec:
      nodeSelector:
        node-role.kubernetes.io/worker: ""
'
daemonset.apps/nginx-paulo patched


# Even applying the patch, k8s kept the 2 roles declared "Node Selector",
# this happens because K8s doesn't replace, it merges (append). NodeSelector is an AND and not an OR.
#
k get daemonset
NAME          DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR                                                     AGE
nginx-paulo   1         1         1       1            1           kubernetes.io/hostname=worker01,node-role.kubernetes.io/worker=   2m22s


# Leave only 1 Node Selector
k edit daemonsets nginx-paulo

# NOTE:
# Daemonset troubleshooting is the same as a Pod.
# Daemonset does not have Create subcommands.
# Daemonset does not have a Direct manager.
# You can create it as a deployment, but you must remove replicas and change the Kind to DaemonSet
#
# This will deploy to all Nodes
k neat <<< $(k create deployment --image=nginx nginx-paulo --dry-run=client -o yaml) | sed 's/Deployment/DaemonSet/;/replicas:/d' | k apply -f -

# As it was not made clear which node to run on, the pod was excheduled on both nodes.
k get ds
NAME          DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
nginx-paulo   2         2         2       2            2           <none>          3s


# Run on a specific node (Patch).
k patch daemonset nginx-paulo -p '
spec:
  template:
    spec:
      nodeSelector:
        node-role.kubernetes.io/worker: ""
'
daemonset.apps/nginx-paulo patched

# After apply patch
k get ds
NAME          DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR                     AGE
nginx-paulo   1         1         1       1            1           node-role.kubernetes.io/worker=   88s

k explain daemonset --recursive | less
k explain daemonset.spec
```
[Menu](#-menu)

# 🚀 Create Object - Statefullset

```bash
# StateFull => Totally depends on the state
# Ex: An application that authenticates users, and a certain logged in user has a section connected to a pod,
# when redirected to another pod, this authenticated session may not work.
#
# Redis to store user session would solve this problem.
#
# The application is completely state dependent.
# The more the app uses/depends on the file system, the more stateful it is.
#
# The tendency is to adapt the application so that it does not depend on these states and can be malleable.
#
# NOTE:
# Statefullset => Escalation has to be more careful, each pod has its volume, scales in the right order Ex: Database
# Statefullset => It is managed by kube-scheduler
# Statefullset => It is a controlled deployment. He always follows the order to climb one and kill one. Always one by one.
# Ex: Jenkins, safe
#
# How to identify a statefullset by doing a ( k get pods )?
# Usually the pod name has a prefix e.g. jenkins-0
# The names are always predictable, if my deployment calls nginx, the Pods will have names: (nginx-0, nginx-1)
# Statefullset => Each Pod with its respective PVC
#
# Even if the Pod (nginx-2) dies, when it comes up again, only it will access this data.
# nginx-1 => nginx-1 pvc
# nginx-2 => nginx-2 pvc
# nginx-3 => nginx-3 pvc
#
#============================================================
# Notes:
# An important detail is when I expose a statefullset,
# unlike a deployment when a service is created, this works differently,
# The service of a statefulset creates a Headless Service (A Service of Type ClusteIP, but WITHOUT IP),
# This service is a name resolver that knows all replicas (nginx-1, nginx-2, nginx-3), it does not have an IP.
# This DNS returns all statefull IPs ( nginx-1, nginx-2, nginx-3 ) and the client that requested
# choose which one he wants to connect to.
#============================================================

# Install Local-Path
# https://github.com/rancher/local-path-provisioner/tree/master/deploy/chart/local-path-provisioner

git clone https://github.com/rancher/local-path-provisioner.git
cd local-path-provisioner
helm install local-path-storage --create-namespace --namespace local-path-storage ./deploy/chart/local-path-provisioner/
helm list -A

# List StorageClass
k get sc -A

# Check StorageClass
k describe sc -n local-path-storage local-path

k edit sc -n local-path-storage local-path
storageclass.kubernetes.io/is-default-class: true

# Doc
# https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/

# Explain YAML construction of a PVC
k explain statefulsets.spec
k explain statefulsets.spec.volumeClaimTemplates
k explain statefulsets.spec.volumeClaimTemplates.spec
k explain statefulsets.spec.volumeClaimTemplates.metadata

# Access mode (Link)
k explain statefulsets.spec.volumeClaimTemplates.spec.accessModes

# Computational Resources (Link)
k explain statefulsets.spec.volumeClaimTemplates.spec.resources

#====================================================
# NOTE:
# StatefulSet itself automatically creates PVCs from volumeClaimTemplates
#====================================================

# Ex:
volumeClaimTemplates:
- metadata:
    name: nginx-html
  spec:
    accessModes: [ "ReadWriteOnce" ]
    resources:
      requests:
        storage: 1G


# Now within the spec I need to define how it will be mounted inside the container

k explain statefulsets.spec.template.spec.containers
k explain statefulsets.spec.template.spec.containers.volumeMounts

spec:
  containers:
  - image: nginx
    name: nginx
    volumeMounts:
    - name: nginx-html
      mountPath: "/usr/share/nginx/html"

# NOTE:
# StatefulSet troubleshooting is the same as a Pod.
# You can create it as a deployment, but you must change the Kind to StatefulSet
# StatefulSet has the order of creation and removal of Pods, unlike a Deployment.
#
# Veja o guia sobre ( Affinity )
k taint nodes master01 node-role.kubernetes.io/control-plane=:NoSchedule
k describe node master01 | grep Taint
#
# Gerando os manifestos
k neat <<< $(k create deployment --image=nginx nginx-paulo --dry-run=client -o yaml) | sed 's/Deployment/StatefulSet/'

k neat <<< $(k create service clusterip nginx --clusterip="None" --dry-run=client -o yaml)

cat <<EOF | k apply -f -
apiVersion: v1
kind: Service
metadata:
  labels:
    app: nginx
  name: nginx
spec:
  clusterIP: None
  ports:
  - name: nginx
    port: 80
  selector:
    app: nginx
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  labels:
    app: nginx
  name: nginx
spec:
  serviceName: "nginx"
  replicas: 2
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - image: nginx
        name: nginx
        volumeMounts:
        - name: nginx-html
          mountPath: "/usr/share/nginx/html"
  volumeClaimTemplates:
  - metadata:
      name: nginx-html
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 1G
EOF

NAME      READY   STATUS    RESTARTS   AGE
nginx-0   1/1     Running   0          92s
nginx-1   1/1     Running   0          86s

# ls /var/local-path-provisioner/
#
ssh root@worker01 ls /opt/local-path-provisioner
pvc-5e022a02-521f-4f6b-906b-870992018639_default_nginx-html-nginx-0
pvc-e7a97210-ef2c-488b-979a-9ae4bf75ecdd_default_nginx-html-nginx-1

# Note that there is no IP linked to the service.
# It just creates individual DNS records for each Pod
nginx-0.nginx.default.svc.cluster.local
nginx-1.nginx.default.svc.cluster.local

k get svc nginx
NAME    TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
nginx   ClusterIP   None         <none>        80/TCP    4d4h

# Insert data into Nginx-0 statefulset mount point
kubectl exec -it nginx-0 -- bash -c "echo 'abacate' > /usr/share/nginx/html/index.html"

# k port-forward pod/<pod-name> <Minha-Porta>:<Porta-App>
k port-forward pod/nginx-0 8181:80

# In another terminal, when doing a curl you will always get the response "avocado", as the forward was at the Pod level.

# Insert data into Nginx-1 statefulset mount point
kubectl exec -it nginx-1 -- bash -c "echo 'morango' > /usr/share/nginx/html/index.html"

k port-forward svc/nginx 8181:80

kubectl exec -it nginx-1 -- bash -c "echo 'abacate' > /usr/share/nginx/html/index.html"

# Test resolv Name containers
for i in 0 1; do kubectl exec "nginx-$i" -- sh -c 'hostname'; done

kubectl run -i --tty --image busybox dns-test --restart=Never --rm

# ping -c 2 nginx-1.nginx
PING nginx-1.nginx (10.244.1.52): 56 data bytes
64 bytes from 10.244.1.52: seq=0 ttl=64 time=0.138 ms
64 bytes from 10.244.1.52: seq=1 ttl=64 time=0.194 ms

# ping -c 2 nginx-0.nginx
PING nginx-0.nginx (10.244.1.50): 56 data bytes
64 bytes from 10.244.1.50: seq=0 ttl=64 time=0.110 ms
64 bytes from 10.244.1.50: seq=1 ttl=64 time=0.179 ms

nslookup nginx-0.nginx.default.svc.cluster.local
Server:		10.96.0.10
Address:	10.96.0.10:53

Name:	nginx-0.nginx.default.svc.cluster.local
Address: 10.244.1.50

nslookup nginx-1.nginx.default.svc.cluster.local
Server:		10.96.0.10
Address:	10.96.0.10:53

Name:	nginx-1.nginx.default.svc.cluster.local
Address: 10.244.1.52

kubectl run -it --image nginx dns-test --rm -- bash

root@dns-test:/# curl nginx-0.nginx
bacate
root@dns-test:/# curl nginx-1.nginx
morango

# Note: The service does round-robin between the 2 statefulset
#
root@dns-test:/# apt update && apt -y install iputils-ping

root@dns-test:/# ping -c 2 nginx
PING nginx.default.svc.cluster.local (10.244.1.57) 56(84) bytes of data.
64 bytes from nginx-1.nginx.default.svc.cluster.local (10.244.1.57): icmp_seq=1 ttl=64 time=0.093 ms
64 bytes from nginx-1.nginx.default.svc.cluster.local (10.244.1.57): icmp_seq=2 ttl=64 time=0.203 ms

root@dns-test:/# ping -c 2 nginx
PING nginx.default.svc.cluster.local (10.244.1.56) 56(84) bytes of data.
64 bytes from nginx-0.nginx.default.svc.cluster.local (10.244.1.56): icmp_seq=1 ttl=64 time=0.139 ms
64 bytes from nginx-0.nginx.default.svc.cluster.local (10.244.1.56): icmp_seq=2 ttl=64 time=0.218 ms


#=============================================================================
# If you don't create the PVCs before creating the Taint rule, what would happen?
#=============================================================================

kgp
NAME      READY   STATUS    RESTARTS   AGE
nginx-0   1/1     Running   0          4m19s
nginx-1   0/1     Pending   0          4m16s

k describe pod nginx-1
Events:
  Type     Reason            Age    From               Message
  ----     ------            ----   ----               -------
  Warning  FailedScheduling  3m57s  default-scheduler  0/2 nodes are available: 1 node(s) didn't match PersistentVolume's node affinity, 1 node(s) had untolerated taint(s). no new claims to deallocate, preemption: 0/2 nodes are available: 2 Preemption is not helpful for scheduling.

# Possible Problems...
# PVC accessModes: [ "ReadWriteOnce" ], does not have an explicit affinity node in the manifest,
# so PVC could not easily mount 2 different volumes on the same worker.

k get pvc
k describe pvc nginx-html-nginx-1
k get pv
k describe pv pvc-003a61ee-f231-474a-9902-9300cf230553

# PVC zuado....
# The problem was that there is an affinity rule for the PV, but we have a taint that blocks schedule in the control-plane
k describe pv pvc-003a61ee-f231-474a-9902-9300cf230553
Name:              pvc-003a61ee-f231-474a-9902-9300cf230553
Labels:            <none>
Annotations:       local.path.provisioner/selected-node: master01
                   pv.kubernetes.io/provisioned-by: cluster.local/local-path-storage-local-path-provisioner
Finalizers:        [kubernetes.io/pv-protection]
StorageClass:      local-path
Status:            Bound
Claim:             default/nginx-html-nginx-1
Reclaim Policy:    Delete
Access Modes:      RWO
VolumeMode:        Filesystem
Capacity:          1G
Node Affinity:
  Required Terms:
    Term 0:        kubernetes.io/hostname in [master01]
Message:
Source:
    Type:          HostPath (bare host directory volume)
    Path:          /opt/local-path-provisioner/pvc-003a61ee-f231-474a-9902-9300cf230553_default_nginx-html-nginx-1
    HostPathType:  DirectoryOrCreate
Events:            <none>
#=============================================================================
```
[Menu](#-menu)

# 🚀 Create Object - PDB / PodDisruptionBudget

```bash
# It is a cluster object that ensures that a POD is never unavailable
# Mostly used with statefulset

k api-resources | grep disrup
poddisruptionbudgets                pdb          policy/v1                         true         PodDisruptionBudget

# With this feature I can tell k8s that out of 100% of my pods I want 90% always available.
# Or how many unavailable replicas I can tolerate, Ex: if I have 3 replicas, I can tolerate the loss of 2 at most.
#
# This is a protection against the node being drained
#
# Doc:
https://kubernetes.io/docs/tasks/run-application/configure-pdb/

k explain poddisruptionbudget
k explain poddisruptionbudget.spec

# maxUnavailable => Maximum that I accept as unavailable
# minAvailable   => Minimum available

# Check if I have PBD enabled
k get pdb

# Check my pod labels
k get pod --show-labels
NAME      READY   STATUS    RESTARTS      AGE   LABELS
nginx-0   1/1     Running   1 (27m ago)   47h   app=nginx,apps.kubernetes.io/pod-index=0,controller-revision-hash=nginx-6cb5bc47cd,statefulset.kubernetes.io/pod-name=nginx-0
nginx-1   1/1     Running   1 (27m ago)   47h   app=nginx,apps.kubernetes.io/pod-index=1,controller-revision-hash=nginx-6cb5bc47cd,statefulset.kubernetes.io/pod-name=nginx-1

# List plus Clean
kubectl get pod --show-labels | tr ',' '\n'


#========================================================================
# THIS WAY I AM NOT INFERRING THAT ANYONE MAY BE UNAVAILABLE.
#========================================================================
cat <<EOF | k apply -f -
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: nginx-pdb
spec:
  maxUnavailable: 0
  selector:
    matchLabels:
      app: nginx
EOF

k get pdb
NAME        MIN AVAILABLE   MAX UNAVAILABLE   ALLOWED DISRUPTIONS   AGE
nginx-pdb   N/A             0                 0                     6s

# This guy applies the cordon (Marks the node to not accept new pods)
# Then start evicting (Get all the pods running on this worker and throw them to another node)
# The pod (statefulset) could not be migrated due to the pdb rule
#
k drain worker01 --ignore-daemonsets --delete-emptydir-data
node/worker01 cordoned
Warning: ignoring DaemonSet-managed Pods: kube-flannel/kube-flannel-ds-zzgvm, kube-system/kube-proxy-fg27m, metallb-system/metallb-speaker-rhs68
evicting pod local-path-storage/local-path-storage-local-path-provisioner-f555d4fc6-l4n2q
evicting pod default/nginx-1
evicting pod default/nginx-0

# The Node was marked not to receive any schedule
k get nodes
NAME       STATUS                     ROLES           AGE   VERSION
master01   Ready                      control-plane   12d   v1.34.4
worker01   Ready,SchedulingDisabled   worker          12d   v1.34.4

# Pods still running
k get pods
NAME      READY   STATUS    RESTARTS      AGE
nginx-0   1/1     Running   1 (38m ago)   2d
nginx-1   1/1     Running   1 (38m ago)   2d

# To solve this I must delete the PDB
k delete pdb nginx-pdb

# Now I can do the drain
k drain worker01 --ignore-daemonsets --delete-emptydir-data
node/worker01 already cordoned
Warning: ignoring DaemonSet-managed Pods: kube-system/kindnet-6vxfh, kube-system/kube-proxy-jrxg8, metallb-system/metallb-speaker-9vkng
evicting pod default/nginx-1
pod/nginx-1 evicted
node/worker01 drained

# After completing the process, ensure that the node can receive Pod schedules
k uncordon worker01
node/worker01 uncordoned

k get nodes
NAME       STATUS   ROLES           AGE   VERSION
master01   Ready    control-plane   12d   v1.34.4
worker01   Ready    worker          12d   v1.34.4
```

[Menu](#-menu)

# 🚀 Create Object - Jobs

```bash
# Batch Jobs (Executes 1x only)
# Job => Executes a Pod => During execution, its status is Running => Once finished, it transitions to Completed => and Bye
#
k get job -A

# The last 3 cronjob executions are always kept (k get pods)

# Doc
https://kubernetes.io/docs/concepts/workloads/controllers/job/

k api-resources | grep jobs
k explain
k explain jobs.spec
k explain jobs.spec.ttlSecondsAfterFinished
k explain jobs.spec.template
k explain jobs.spec.template.spec.restartPolicy

# Manifest
k neat <<< $(k create job my-job --image=alpine --dry-run=client -o yaml)

apiVersion: batch/v1
kind: Job
metadata:
  name: my-job
spec:
  template:
    spec:
      containers:
      - image: alpine
        name: my-job
      restartPolicy: Never

#============================================================================================
# Job is immutable, once created I cannot apply the manifest to override its content.
# It is necessary to delete the old content.
#
#============================================================================================

cat > Dockerfile <<EOF
FROM alpine
WORKDIR /app
RUN apk update && \
  apk add bash
COPY script.sh .
RUN chmod +x script.sh
CMD [ "bash","script.sh" ]
EOF

cat > script.sh <<EOF
#!/usr/bin/env bash
for _ in {1..10}; do echo "\$(date +%Y-%m-%d-%H:%M:%S) - Output..." && sleep 1; done
EOF

docker login
docker build -t prgs/alpine-jobs:latest .
docker push prgs/alpine-jobs:latest
docker run -it --rm prgs/alpine-jobs:latest bash -c "./script.sh"
2026-03-06-14:16:38 - Output...
2026-03-06-14:16:39 - Output...
2026-03-06-14:16:40 - Output...
2026-03-06-14:16:41 - Output...
2026-03-06-14:16:42 - Output...
2026-03-06-14:16:43 - Output...
2026-03-06-14:16:44 - Output...
2026-03-06-14:16:45 - Output...
2026-03-06-14:16:46 - Output...
2026-03-06-14:16:47 - Output...


k neat <<< $(k create job my-job --image=prgs/alpine-jobs:latest --dry-run=client -o yaml) | k apply -f -
k get job
NAME     STATUS     COMPLETIONS   DURATION   AGE
my-job   Complete   1/1           11s        12s

# Logs
k logs jobs/my-job
2026-03-05-11:17:32 - Output...

k neat <<< $(k create job my-job2 --image=prgs/alpine-jobs:latest --dry-run=client -o yaml) | k apply -f -
k get job -w
my-job    Complete             1/1           11s        2m13s
my-job2   Running              0/1           0s         0s
my-job2   Running              0/1           4s         4s
my-job2   Running              0/1           5s         5s
my-job2   SuccessCriteriaMet   0/1           6s         6s
my-job2   Complete             1/1           6s         6s

# Another way to view the Log
# Get the Pod Id generated by the Job
k logs $(k get pods -l job-name=my-job2 -o name)
```

[Menu](#-menu)

# 🚀 Create Object - CronJobs

```bash
# If I need to run this every day?
# CronJob => Create the Job => Create the Pod (Running) => Once finished, it transitions to Completed
#
# Example

https://github.com/mateusmuller/elasticsearch-delete-indices-7-days

k get cronjob -A

k explain cronjobs.spec

k neat <<< $(k create cronjob my-cronjob --image=prgs/alpine-jobs:latest --schedule="*/1 * * * *" --dry-run=client -o yaml) | k apply -f -

k get cronjob
k get job
k get pods -

# Another way to view the Log
# Get the Pod Id generated by the Job
k logs my-cronjob-29546778-4fr8t
2026-03-06-14:18:01 - Output...
2026-03-06-14:18:02 - Output...
2026-03-06-14:18:03 - Output...
2026-03-06-14:18:05 - Output...
2026-03-06-14:18:06 - Output...
2026-03-06-14:18:07 - Output...
2026-03-06-14:18:08 - Output...
2026-03-06-14:18:09 - Output...
2026-03-06-14:18:10 - Output...
2026-03-06-14:18:11 - Output...

# Grabbing dynamically
kubectl logs $(kubectl get jobs --sort-by=.metadata.creationTimestamp -o name | tail -1)
```

[Menu](#-menu)

# 🚀 Create Object - Services Tipos

```bash
# Internal communication within k8s and access does not happen directly in the Pod.
# Communication happens through a services.
# Internal communication (2 pods in the same namespace communicate through service Cluster IP).
# Service is the way I communicate with the cluster, whether internally or externally.
#
# DNS Name ( Service Discovery )

# ============================= Cluster IP ========================================
# Cluster IP is only for internal communication within the cluster.
# When creating the service, you indicate the selector and it already knows who to send the request to.
k get svc kubernetes -o yaml

# name => Name of my service ( rails-services ) this name that the cluster performs DNS lookup to discover the service.
# port => The port that the k8s service will listen to
# targetPort => The port that the application listens to. Here it redirects everything that arrives at 80 and sends it to 3000
# selector => This is what will match in Deployment, it is what defines where the request will be sent.
# This is done through labels
# Ex:
--port # (It is the service port)
--target-port # (It is the nginx port running in the container)

k get pods --show-labels
  selector:
    app: nginx

k explain svc.spec
k explain svc.spec.selector ( map => chave / valor )

# Ex:
k neat <<< $(k create service clusterip mymysql --tcp=80:80 --dry-run=client -o yaml)

apiVersion: v1
kind: Service
metadata:
  labels:
    app: mymysql
  name: mymysql
spec:
  ports:
  - name: mymysql-service
    port: 80
  selector:
    app: mymysql

k get svc mymysql
NAME      TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE
mymysql   ClusterIP   10.108.151.234   <none>        80/TCP    12d

k run --image alpine --rm -it teste-curl sh
/ # ping -c 2 mymysql.default.svc.cluster.local
PING mymysql.default.svc.cluster.local (10.108.151.234): 56 data bytes

/ # ping -c 2 mymysql
PING mymysql (10.108.151.234): 56 data bytes

#************************************************************************
# How does name resolution happen when I'm in another namespace?
#************************************************************************
#
# Apenas por FQDN
# Executando Pod no namespace kube-system
k run --namespace kube-system --image alpine --rm -it teste-curl sh

# This (OK)
ping -c 2 mymysql.default.svc.cluster.local

# That (Doesn't Respond)
ping -c 2 mymysql

#************************************************************************
# How to create a service via command line?
#************************************************************************
#
# Create deployment
k create deployment --image=nginx nginx-paulo
k expose deployment nginx-paulo --port=80 --type='ClusterIP' --target-port=80

#************************************************************************
# CoWhat does a service know how to get to a Pod?
#************************************************************************
#
# Through endpoints
# This command (endpoints) will be deprecated in future versions (1.33+)
k get endpoints nginx

k get endpointslices.discovery.k8s.io
NAME                ADDRESSTYPE   PORTS     ENDPOINTS                 AGE
demo-bx494          IPv4          <unset>   <unset>                   13d
kubernetes          IPv4          6443      10.100.100.11             14d
mymysql-wvtvv       IPv4          <unset>   <unset>                   12d
nginx-mjb56         IPv4          80        10.244.1.66,10.244.1.67   3d
nginx-paulo-hspkj   IPv4          80        10.244.1.129              5m10s


# ============================== Node Port ========================================
#
# Little used
# Range => 30000-32767
# If I choose port 30000, this port is opened on each of the nodes.
# To access I need to inform the Node IP:Port
# Purpose (tests and demos)

# ============================== LoadBalancer =====================================
#
# It is customary to have one L.B per application
# If you use this service to expose your app to the world, remember that each endpoint will have its L.B.
# Ideal for TCP/UDP (Layer 4)

# Note:
# If I am working in the http application layer (Layer 7)
# the Gateway Api e (Deceeded Ingress) is the best alternative, as it is only used
# a single LoabBalancer and creates access routes and endpoints.

# ============================== External Name ====================================
#
# Services => ( CNAME ) => DNS
# It is a service used to resolve names.
# Suppose you use AWS's RDS to give you a URL (Endpoint), but you don't want to use the DNS that AWS sent you,
# because if it changes you will have to redeploy all your apps.
#
# Then you can create this service (External Name) to create a valid DNS within the Cluster
#
# Service , it would be your service ex: "db" which is nothing more than a cname for (AWS DNS URL),
# so when your bank URL changes you only change this service and your app remains the same as before.
#
# All services are done on the node

# ============================== Headless Service =================================
#
# We have already talked about this service in (Create Object -Statefullset), but here we will deal with it in isolation.
#
# Headless Service, it is a clusterIP without IP, this is used specifically in statefullset and the search is performed by DNS
#
# The service continues to be a clusterIp, but I set (ClusterIP to None)

# Generating the manifests
k neat <<< $(k create deployment --image=nginx nginx-paulo --dry-run=client -o yaml) | sed 's/Deployment/StatefulSet/'

k neat <<< $(k create service clusterip nginx --clusterip="None" --dry-run=client -o yaml)

cat <<EOF | k apply -f -
apiVersion: v1
kind: Service
metadata:
  labels:
    app: nginx
  name: nginx
spec:
  clusterIP: None
  ports:
  - name: nginx
    port: 80
  selector:
    app: nginx
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  labels:
    app: nginx
  name: nginx
spec:
  serviceName: "nginx"
  replicas: 2
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - image: nginx
        name: nginx
EOF

k get pods
NAME      READY   STATUS    RESTARTS   AGE
nginx-0   1/1     Running   0          16s
nginx-1   1/1     Running   0          14s

k get svc
NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   78m
nginx        ClusterIP   None         <none>        80/TCP    28s

# This is not load balancing, as I solve it directly for the pod.
#
# The key to this working is to define the serviceName
spec:
  serviceName: "nginx"

# To consume ( Pod Name . Service Name ) Ex: nginx-0.nginx

kubectl run -i --tty --image alpine dns-test --restart=Never --rm

/ # apk add bind-tools
/ # host kubernetes
kubernetes.default.svc.cluster.local has address 10.96.0.1

/ # host nginx
nginx.default.svc.cluster.local has address 10.244.2.7
nginx.default.svc.cluster.local has address 10.244.1.7

/ # host nginx-0.nginx.default.svc.cluster.local
nginx-0.nginx.default.svc.cluster.local has address 10.244.1.7

/ # host nginx-1.nginx.default.svc.cluster.local
nginx-1.nginx.default.svc.cluster.local has address 10.244.2.7

/ # host nginx-0.nginx
nginx-0.nginx.default.svc.cluster.local has address 10.244.1.7

/ # host nginx-1.nginx
nginx-1.nginx.default.svc.cluster.local has address 10.244.2.7

/ # ping -c 1 nginx-0.nginx
PING nginx-0.nginx (10.244.1.7): 56 data bytes
64 bytes from 10.244.1.7: seq=0 ttl=63 time=0.130 ms

/ # ping -c 1 nginx-1.nginx
PING nginx-1.nginx (10.244.2.7): 56 data bytes
64 bytes from 10.244.2.7: seq=0 ttl=62 time=0.329 ms

/ # nslookup nginx-0.nginx
Server:    10.96.0.10
Address 1: 10.96.0.10 kube-dns.kube-system.svc.cluster.local

Name:      nginx-0.nginx
Address 1: 10.244.1.19 nginx-0.nginx.default.svc.cluster.local

/ # nslookup nginx-1.nginx
Server:    10.96.0.10
Address 1: 10.96.0.10 kube-dns.kube-system.svc.cluster.local

Name:      nginx-1.nginx
Address 1: 10.244.2.14 nginx-1.nginx.default.svc.cluster.local
```
[Menu](#-menu)

# 🚀 Create Object - Ipvs Vs Iptables

```bash
# Kubernetes Componetes
https://kubernetes.io/docs/concepts/overview/components/

# Kube-Proxy Comandos Referência
https://kubernetes.io/docs/reference/command-line-tools-reference/kube-proxy/

# =================================== IPVS ========================================
#
# How to check if you are using Iptables or Ipvs?
# -If you are using ipvs, the interface has the prefix ipvs
# -Here the interfaces have the name (ipvs)
ip a
#
#
apt update && apt install ipvsadm -y
ipvsadm -L -n
TCP  10.102.184.126:8080 rr ( Esse rr significa Round Robin )
  -> 10.244.1.117:80     Masq  1  0  0
  -> 10.244.1.118:80     Masq  1  0  0
  -> 10.244.1.119:80     Masq  1  0  0

# ================================= Iptables ======================================
#
# Cloud Provides ( AWS ) uses iptables to route traffic between pods
#
# ================================= How to Change =================================
#
# How to change the routing mode?
# Does the cloud provider support this?
#
# kube-proxy is configured via a configmap

k get cm -n kube-system
NAME                                                   DATA   AGE
coredns                                                1      4h13m
extension-apiserver-authentication                     6      4h13m
kube-apiserver-legacy-service-account-token-tracking   1      4h13m
kube-proxy                                             2      4h13m
kube-root-ca.crt                                       1      4h13m
kubeadm-config                                         1      4h13m
kubelet-config                                         1      4h13m

# By default, kind operates with Iptables
#
k neat <<< $(k get cm -n kube-system kube-proxy -o yaml) | grep mode
mode: iptables

# Ensure kernel modules are enabled
modprobe ip_vs
modprobe ip_vs_rr
modprobe ip_vs_wrr
modprobe ip_vs_sh
modprobe nf_conntrack

# Change requires recycling of pods.
k edit cm -n kube-system kube-proxy -o yaml

kubectl rollout restart daemonset kube-proxy -n kube-system

# ================================= Debug Iptables ==================================

# By default this image exposes port 80
k create deployment --image nginx --replicas 3 nginx

# Creating a service of type ClusterIP 8080 and redirects to port 80
kubectl expose deployment nginx --port=8080 --type='ClusterIP' --target-port=80

k get pod -o wide
NAME                     READY   STATUS    RESTARTS   AGE   IP            NODE                 NOMINATED NODE   READINESS GATES
nginx-66686b6766-9h4cw   1/1     Running   0          48s   10.244.0.22   prgs-control-plane   <none>           <none>
nginx-66686b6766-hq2h2   1/1     Running   0          48s   10.244.0.20   prgs-control-plane   <none>           <none>
nginx-66686b6766-kcbr2   1/1     Running   0          48s   10.244.0.21   prgs-control-plane   <none>           <none>

k get svc
NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
kubernetes   ClusterIP   10.96.0.1       <none>        443/TCP    17m
nginx        ClusterIP   10.96.175.117   <none>        8080/TCP   52s

k run --image alpine --rm -it teste-curl sh
apk add curl
ping nginx
ping nginx.default.svc.cluster.local
curl nginx:8080

<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
...
...

# =========================== Como Debugar ( ClusterIP ) ==========================
#
# The Debug method is the same, regardless of the service. I left it separated by service type, just for organization purposes.
#
docker exec -it prgs-control-plane bash

root@prgs-control-plane:/# iptables-save > /tmp/iptables
root@prgs-control-plane:/# egrep '10.96.175.117' /tmp/iptables

-A KUBE-SERVICES -d 10.96.175.117/32 -p tcp -m comment --comment "default/nginx cluster IP" -m tcp --dport 8080 -j KUBE-SVC-2CMXP7HKUVJN7L6M
-A KUBE-SVC-2CMXP7HKUVJN7L6M ! -s 10.244.0.0/16 -d 10.96.175.117/32 -p tcp -m comment --comment "default/nginx cluster IP" -m tcp --dport 8080 -j KUBE-MARK-MASQ

# Add rules at the end of the ruleset
iptables -A

# This rule here that does the redirection
# Iptables Rules on the Host (Worker)
# Packet destined for host 10.96.175.117/32 (Service) on port 8080 action (KUBE-SVC-2CMXP7HKUVJN7L6M)
-A KUBE-SERVICES -d 10.96.175.117/32 -p tcp -m comment --comment "default/nginx cluster IP" -m tcp --dport 8080 -j KUBE-SVC-2CMXP7HKUVJN7L6M

root@prgs-control-plane:/# egrep 'KUBE-SVC-2CMXP7HKUVJN7L6M' /tmp/iptables

-A KUBE-SERVICES -d 10.96.175.117/32 -p tcp -m comment --comment "default/nginx cluster IP" -m tcp --dport 8080 -j KUBE-SVC-2CMXP7HKUVJN7L6M
-A KUBE-SVC-2CMXP7HKUVJN7L6M ! -s 10.244.0.0/16 -d 10.96.175.117/32 -p tcp -m comment --comment "default/nginx cluster IP" -m tcp --dport 8080 -j KUBE-MARK-MASQ
-A KUBE-SVC-2CMXP7HKUVJN7L6M -m comment --comment "default/nginx -> 10.244.0.20:80" -m statistic --mode random --probability 0.33333333349 -j KUBE-SEP-BRZDTZFF2SFWJV4H
-A KUBE-SVC-2CMXP7HKUVJN7L6M -m comment --comment "default/nginx -> 10.244.0.21:80" -m statistic --mode random --probability 0.50000000000 -j KUBE-SEP-OI2S57TQ5WH5FOMC
-A KUBE-SVC-2CMXP7HKUVJN7L6M -m comment --comment "default/nginx -> 10.244.0.22:80" -j KUBE-SEP-473MVOWGJMIYYUKK

# This 10.244.0.0/16 is the CDIR that K8S will use for the Pods
# Here Everything that comes from this Chain (KUBE-SVC-2CMXP7HKUVJN7L6M) except the Pod network will be Masked to leave.
-A KUBE-SERVICES -d 10.96.175.117/32 -p tcp -m comment --comment "default/nginx cluster IP" -m tcp --dport 8080 -j KUBE-SVC-2CMXP7HKUVJN7L6M
-A KUBE-SVC-2CMXP7HKUVJN7L6M ! -s 10.244.0.0/16 -d 10.96.175.117/32 -p tcp -m comment --comment "default/nginx cluster IP" -m tcp --dport 8080 -j KUBE-MARK-MASQ

# Here That Balancedly Happens

# 30% of requests that arrive on this host will be forwarded to (10.244.0.20) -m statistic (load balancer module)
-A KUBE-SVC-2CMXP7HKUVJN7L6M -m comment --comment "default/nginx -> 10.244.0.20:80" -m statistic --mode random --probability 0.33333333349 -j KUBE-SEP-BRZDTZFF2SFWJV4H

# 50% of requests that arrive at this host will be forwarded to (10.244.0.21)
-A KUBE-SVC-2CMXP7HKUVJN7L6M -m comment --comment "default/nginx -> 10.244.0.21:80" -m statistic --mode random --probability 0.50000000000 -j KUBE-SEP-OI2S57TQ5WH5FOMC

# the remaining % of requests that arrive at this host will be forwarded to (10.244.0.22)
-A KUBE-SVC-2CMXP7HKUVJN7L6M -m comment --comment "default/nginx -> 10.244.0.22:80" -j KUBE-SEP-473MVOWGJMIYYUKK

# =========================== Como Debugar ( NodePort ) ===========================
#
--port # (It is the service port)
--target-port # (It is the nginx port running in the container)

k create deployment --image nginx --replicas 3 nginx
k expose deployment nginx --type=NodePort --name=nginx --port=80 --target-port=80

k get svc
NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
kubernetes   ClusterIP   10.96.0.1       <none>        443/TCP        99m
nginx        NodePort    10.106.211.96   <none>        80:32674/TCP   4s

# Essa Porta (32674) é aberta no Node ( Worker )
docker exec -it prgs-worker2 bash -c "curl localhost:32674"


# =========================  Local Port  ( Kind ) ===============================
k delete svc nginx

# If you are using Kind , you can redirect the NodePort port to your local machine
- role: worker
  kubeadmConfigPatches:
  - |
    kind: JoinConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "prgs/postgres=true"
  extraPortMappings:
  - containerPort: 30999
    hostPort: 30999
    listenAddress: "0.0.0.0"
    protocol: TCP

# No seu host local
netstat -an | grep 30999
tcp4       0      0  *.30999                *.*                    LISTEN

k create service nodeport nginx --node-port=30999 --tcp=80:80

k get svc
NAME         TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
kubernetes   ClusterIP   10.96.0.1        <none>        443/TCP        104m
nginx        NodePort    10.107.225.100   <none>        80:30999/TCP   3s

curl localhost:30999

# ============================== Debug ( LoadBalancer ) =========================
# The LoadBalancer is triggered by the cloud-controller (This guy talks to the cloud Provider (via api))

https://metallb.universe.tf/installation/
https://metallb.universe.tf/configuration/

k create deployment --image nginx --replicas 3 nginx
k expose deployment nginx --type=LoadBalancer --port=80 --target-port=80

k get svc
NAME         TYPE           CLUSTER-IP      EXTERNAL-IP      PORT(S)        AGE
kubernetes   ClusterIP      10.96.0.1       <none>           443/TCP        74m
nginx        LoadBalancer   10.109.124.25   172.18.255.201   80:30606/TCP   68m

iptables-save > /tmp/iptables

egrep '172.18.255.201' /tmp/iptables
-A KUBE-SERVICES -d 172.18.255.201/32 -p tcp -m comment --comment "default/nginx loadbalancer IP" -m tcp --dport 80 -j KUBE-EXT-2CMXP7HKUVJN7L6M

# Here it balances for ClusterIp ( KUBE-SVC-2CMXP7HKUVJN7L6M )

egrep 'KUBE-EXT-2CMXP7HKUVJN7L6M' /tmp/iptables
:KUBE-EXT-2CMXP7HKUVJN7L6M - [0:0]
-A KUBE-EXT-2CMXP7HKUVJN7L6M -m comment --comment "masquerade traffic for default/nginx external destinations" -j KUBE-MARK-MASQ
-A KUBE-EXT-2CMXP7HKUVJN7L6M -j KUBE-SVC-2CMXP7HKUVJN7L6M
-A KUBE-NODEPORTS -d 127.0.0.0/8 -p tcp -m comment --comment "default/nginx" -m tcp --dport 30606 -m nfacct --nfacct-name  localhost_nps_accepted_pkts -j KUBE-EXT-2CMXP7HKUVJN7L6M
-A KUBE-NODEPORTS -p tcp -m comment --comment "default/nginx" -m tcp --dport 30606 -j KUBE-EXT-2CMXP7HKUVJN7L6M
-A KUBE-SERVICES -d 172.18.255.201/32 -p tcp -m comment --comment "default/nginx loadbalancer IP" -m tcp --dport 80 -j KUBE-EXT-2CMXP7HKUVJN7L6M

egrep 'KUBE-SVC-2CMXP7HKUVJN7L6M' /tmp/iptables
:KUBE-SVC-2CMXP7HKUVJN7L6M - [0:0]
-A KUBE-EXT-2CMXP7HKUVJN7L6M -j KUBE-SVC-2CMXP7HKUVJN7L6M
-A KUBE-SERVICES -d 10.109.124.25/32 -p tcp -m comment --comment "default/nginx cluster IP" -m tcp --dport 80 -j KUBE-SVC-2CMXP7HKUVJN7L6M
-A KUBE-SVC-2CMXP7HKUVJN7L6M ! -s 10.244.0.0/16 -d 10.109.124.25/32 -p tcp -m comment --comment "default/nginx cluster IP" -m tcp --dport 80 -j KUBE-MARK-MASQ
-A KUBE-SVC-2CMXP7HKUVJN7L6M -m comment --comment "default/nginx -> 10.244.1.5:80" -m statistic --mode random --probability 0.33333333349 -j KUBE-SEP-IZW656N5ZXYN5BEC
-A KUBE-SVC-2CMXP7HKUVJN7L6M -m comment --comment "default/nginx -> 10.244.1.6:80" -m statistic --mode random --probability 0.50000000000 -j KUBE-SEP-C4VXQDW52UV45WW3
-A KUBE-SVC-2CMXP7HKUVJN7L6M -m comment --comment "default/nginx -> 10.244.2.6:80" -j KUBE-SEP-UOZCNMEBPO5JGMU4
```
[Menu](#-menu)

# 🚀 Create Object - Manutenção em Membros do Cluster

```bash
# Daemonset cannot be migrated (1 pod on each node)
# Take all Pods allocated to the worker (prgs-worker2) to another node.
k drain prgs-worker2
k drain prgs-worker2 --ignore-daemonsets
k drain prgs-worker2 --ignore-daemonsets --delete-emptydir-data
node/prgs-worker2 already cordoned
Warning: ignoring DaemonSet-managed Pods: kube-system/kindnet-6vxfh, kube-system/kube-proxy-jrxg8, metallb-system/metallb-speaker-9vkng
evicting pod kube-system/metrics-server-7bb58f4dcb-bxswj
evicting pod ingress-nginx/ingress-nginx-controller-5f4f4d9787-t7x8k
evicting pod default/nginx-1
evicting pod ingress-nginx/ingress-nginx-admission-patch-7w88w
pod/ingress-nginx-admission-patch-7w88w evicted
pod/ingress-nginx-controller-5f4f4d9787-t7x8k evicted
pod/nginx-1 evicted
pod/metrics-server-7bb58f4dcb-bxswj evicted
node/prgs-worker2 drained

# Maintaining worker2
# None Can be scheduled on worker2
k get node
NAME                 STATUS                     ROLES             AGE    VERSION
prgs-control-plane   Ready                      control-plane     172m   v1.31.2
prgs-worker          Ready                      worker-apps       172m   v1.31.2
prgs-worker2         Ready,SchedulingDisabled   worker-postgres   172m   v1.31.2

# It will remain pending as the stateful set cannot be migrated to another node.
# then I should delete it.
k get pod -o wide
NAME      READY   STATUS    RESTARTS   AGE     IP            NODE          NOMINATED NODE   READINESS GATES
nginx-0   1/1     Running   0          8m3s    10.244.1.26   prgs-worker   <none>           <none>
nginx-1   0/1     Pending   0          3m32s   <none>        <none>        <none>           <none>

# After maintenance I resurrect the Host
kubectl uncordon prgs-worker2

k get nodes
NAME                 STATUS   ROLES             AGE    VERSION
prgs-control-plane   Ready    control-plane     3h     v1.31.2
prgs-worker          Ready    worker-apps       179m   v1.31.2
prgs-worker2         Ready    worker-postgres   179m   v1.31.2

k get pods
NAME      READY   STATUS    RESTARTS   AGE
nginx-0   1/1     Running   0          12m
nginx-1   1/1     Running   0          7m53s
```

[Menu](#-menu)

# 🚀 Create Object - External Name

```bash
# ============================== External Name ====================================
#
# This is a type of service where a CNAME is created on the Kubernetes DNS Server.
#
# Services => (CNAME) => DNS
#
# It is a service used to resolve names.
# Suppose you use AWS's RDS to give you a URL (Endpoint), but you don't want to use the DNS that AWS sent you,
# because if it changes you will have to redeploy all your apps.
#
# Then you can create this service (External Name) to create a valid DNS within the Cluster
#
# Service , it would be your service ex: "db" which is nothing more than a cname for (AWS DNS URL),
# so when your bank URL changes you only change this service and your app remains the same as before.
#
# All services are done on the node
k neat <<< $(kubectl create service externalname url-remota --external-name bar.com --dry-run=client -o yaml)

# Result
apiVersion: v1
kind: Service
metadata:
  labels:
    app: url-remota
  name: url-remota
spec:
  externalName: paulo-rogerio.github.io
  type: ExternalName

# Apply
k neat <<< $(kubectl create service externalname url-remota --external-name paulo-rogerio.github.io --dry-run=client -o yaml) | k apply -f -

k get svc

NAME         TYPE           CLUSTER-IP   EXTERNAL-IP               PORT(S)   AGE
kubernetes   ClusterIP      10.96.0.1    <none>                    443/TCP   119m
url-remota   ExternalName   <none>       paulo-rogerio.github.io   <none>    3s

kubectl run -i --tty --image alpine apline --restart=Never --rm
/ # apk add bind-tools

/ # host paulo-rogerio.github.io
paulo-rogerio.github.io has address 185.199.110.153
paulo-rogerio.github.io has address 185.199.111.153
paulo-rogerio.github.io has address 185.199.109.153
paulo-rogerio.github.io has address 185.199.108.153

/ # host url-remota
url-remota.default.svc.cluster.local is an alias for paulo-rogerio.github.io.
paulo-rogerio.github.io has address 185.199.110.153
paulo-rogerio.github.io has address 185.199.111.153
paulo-rogerio.github.io has address 185.199.108.153
paulo-rogerio.github.io has address 185.199.109.153

/ # host -t cname url-remota
url-remota.default.svc.cluster.local is an alias for paulo-rogerio.github.io.

k delete svc url-remota
```
[Menu](#-menu)

# 🚀 Create Object - Trafic Policy

```bash
# This feature is interesting when we have critical applications that require performance.
#
# Traffic Policies, in a scenario with LoadBalancer, work as follows:
#
# Requests arrive via the LoadBalancer external IP and are received by a Node in the cluster.
# When entering the Node, traffic is directed to the Service (ClusterIP),
# From here, kube-proxy comes into action to decide which Pod will fulfill the request.
#
# To view the available Pods, we can list the EndpointSlices:
#
k get endpointslices.discovery.k8s.io
NAME         ADDRESSTYPE   PORTS   ENDPOINTS    AGE
kubernetes   IPv4          6443    172.17.0.2   27m

# These endpoints only inform which Pods are available for the Service.
#
# Routing operation
#
# The important point is that, by default, kube-proxy can forward the request to any Pod in the cluster,
# regardless of the Node it is running on.
#
# That is:
#
# The request can arrive at Node-A and be forwarded to a Pod on Node-B
#
# This ensures greater resilience and load distribution between Pods.
#
# How does this happen internally
#
# The kube-proxy, running on Node (not inside Pods), programs iptables rules into the operating system kernel.
#
# These rules load balance using probability, for example:
#
# Ex: 33% of requests served by this Pod.

-A KUBE-SVC-2CMXP7HKUVJN7L6M -m comment --comment "default/nginx -> 10.244.1.5:80" -m statistic --mode random --probability 0.33333333349 -j KUBE-SEP-IZW656N5ZXYN5BEC

# This means that approximately 33% of requests will be forwarded to this specific Pod.
#
# Network impact
#
# As this communication occurs within the cluster network, normally (same VPC or datacenter) this is not a relevant problem.
#
# However, it can become a problem when:
#
# The cluster is distributed across multiple zones or regions
# There is significant latency between Nodes
#
# In this case, a request that arrives at Node A may end up being served by a Pod on Node B, generating:
#
# Increased latency
# Higher network consumption
# Possible impact on response time sensitive applications
#
# In this mode:
#
# Traffic is only forwarded to Pods local to the Node
# Avoid traffic between Nodes
# Preserves the client's origin IP
#
# On the other hand:
#
# If there is no local Pod, the request may fail
# Global balancing between Pods becomes less efficient
#
# In a practical way

k create deployment --image nginx --replicas 4 nginx
k expose deployment nginx --type=LoadBalancer --port=80 --target-port=80

k get svc
NAME         TYPE           CLUSTER-IP      EXTERNAL-IP    PORT(S)        AGE
kubernetes   ClusterIP      10.96.0.1       <none>         443/TCP        44m
nginx        LoadBalancer   10.96.247.192   172.17.0.241   80:30340/TCP   2m7s


k get endpointslices.discovery.k8s.io
NAME          ADDRESSTYPE   PORTS   ENDPOINTS                                         AGE
kubernetes    IPv4          6443    172.17.0.2                                        43m
nginx-t9tfk   IPv4          80      10.244.0.23,10.244.0.22,10.244.0.24 + 1 more...   48s

kubectl run -i --tty --image alpine apline --restart=Never --rm
/ # apk add curl

# If I access the ClusterIP IP it will route traffic between all 4 Pods
curl -I http://10.96.247.192

k get pods
NAME                     READY   STATUS    RESTARTS   AGE
apline                   1/1     Running   0          2m30s
nginx-676b6c5bbc-8kggb   1/1     Running   0          4m37s
nginx-676b6c5bbc-n4slr   1/1     Running   0          4m37s
nginx-676b6c5bbc-pbmjh   1/1     Running   0          4m37s
nginx-676b6c5bbc-xkmqp   1/1     Running   0          4m37s

# Open 4 terminals
k logs nginx-676b6c5bbc-8kggb -f
k logs nginx-676b6c5bbc-n4slr -f
k logs nginx-676b6c5bbc-pbmjh -f
k logs nginx-676b6c5bbc-xkmqp -f

# Requests will arrive at all POds, even if these Pods are in other Workers
kubectl run -i --tty --image alpine apline --restart=Never --rm
apk add curl
while true; do curl -I http://10.96.247.192; done

# ======================= Configuring Trafic Policy ==============================

# How do I know the default Traffic Policies policy?
#
# The default is "Cluster", change it to "Local"

k get svc nginx -o yaml

spec:
  allocateLoadBalancerNodePorts: true
  clusterIP: 10.96.247.192
  clusterIPs:
  - 10.96.247.192
  externalTrafficPolicy: Cluster
  internalTrafficPolicy: Cluster
  ipFamilies:

# Change to Location
k neat <<< $(k get svc nginx -o yaml) > svc.yaml

  externalTrafficPolicy: Local
  internalTrafficPolicy: Local

# =========================== Debung Trafic Policy =================================

iptables-save > /tmp/iptables

egrep '172.17.0.241' /tmp/iptables
-A KUBE-SERVICES -d 172.17.0.241/32 -p tcp -m comment --comment "default/nginx loadbalancer IP" -m tcp --dport 80 -j KUBE-EXT-2CMXP7HKUVJN7L6M


egrep 'KUBE-EXT-2CMXP7HKUVJN7L6M' /tmp/iptables
:KUBE-EXT-2CMXP7HKUVJN7L6M - [0:0]
-A KUBE-EXT-2CMXP7HKUVJN7L6M -s 10.244.0.0/16 -m comment --comment "pod traffic for default/nginx external destinations" -j KUBE-SVC-2CMXP7HKUVJN7L6M
-A KUBE-EXT-2CMXP7HKUVJN7L6M -m comment --comment "masquerade LOCAL traffic for default/nginx external destinations" -m addrtype --src-type LOCAL -j KUBE-MARK-MASQ
-A KUBE-EXT-2CMXP7HKUVJN7L6M -m comment --comment "route LOCAL traffic for default/nginx external destinations" -m addrtype --src-type LOCAL -j KUBE-SVC-2CMXP7HKUVJN7L6M
-A KUBE-EXT-2CMXP7HKUVJN7L6M -j KUBE-SVL-2CMXP7HKUVJN7L6M
-A KUBE-NODEPORTS -d 127.0.0.0/8 -p tcp -m comment --comment "default/nginx" -m tcp --dport 30655 -m nfacct --nfacct-name  localhost_nps_accepted_pkts -j KUBE-EXT-2CMXP7HKUVJN7L6M
-A KUBE-NODEPORTS -p tcp -m comment --comment "default/nginx" -m tcp --dport 30655 -j KUBE-EXT-2CMXP7HKUVJN7L6M
-A KUBE-SERVICES -d 172.17.0.241/32 -p tcp -m comment --comment "default/nginx loadbalancer IP" -m tcp --dport 80 -j KUBE-EXT-2CMXP7HKUVJN7L6M

# Now routing is only for Pods belonging to the same Worker.

egrep 'KUBE-SVL-2CMXP7HKUVJN7L6M' /tmp/iptables
-A KUBE-SVL-2CMXP7HKUVJN7L6M -m comment --comment "default/nginx -> 10.244.1.6:80" -m statistic --mode random --probability 0.50000000000 -j KUBE-SEP-C4VXQDW52UV45WW3
-A KUBE-SVL-2CMXP7HKUVJN7L6M -m comment --comment "default/nginx -> 10.244.1.7:80" -j KUBE-SEP-DST4PJJC54MIXJRG

# Requests will only arrive in Pods on the same Node
#
kubectl run -i --tty --image alpine apline --restart=Never --rm
apk add curl
while true; do curl -I http://10.96.247.192; done

```

[Menu](#-menu)

# 🚀 Create Object - Estratégias Deploy

```bash
Deployment   => Aplicação stateless ( Aplicação escaláveis )

                           -----------
                           Deployment
                           -----------
                                |
                ________________|_____________
                |               |             |
                |               |             |
           ReplicaSet1     ReplicaSet2     ReplicaSet3
                |               |             |
                |               |             |
          -----------------------------------------------
           |    |   |       |   |   |      |   |    |
           |    |   |       |   |   |      |   |    |
         Pod1 Pod2 Pod3   Pod1 Pod2 Pod3  Pod1 Pod2 Pod3

# How does Deployment interact with replicasets?
O deployments orquestra os replicaset, e são os replicaset que cria os pods. Os Replicaset defini a quantidade de replicas que estaram rodando.

# What is a Rolling Update?
# It is a term used when I update my products ( pods ). Ex: My manifest (Deployment)
#
# Deployment creates 1 replicaset with 3 pods, now I need to change the manifest image.
#
# When applying the deployment, another replicaset ( replicaset2 ) will be created with 3 new Pods, this happens gradually.
#
# There are other ways to deploy Ex: canary, but in this format ( rolling Update ) Replicaset1 removes (-) a pod as the
# Replicaset2 adds (+) a pod.
#
# This allows me to UNDO another replicaset
```

[Menu](#-menu)

# 🚀 Create Object - Deploy Canary

```bash
Canary Deploy ( Root )

( Joao ) => LoadBalance
               |
               |
               |
         -----------------
        |                 |
        |                 |
        |                 |
    80%( v1/old )    20%( v2/new )

# Generating Model
k neat <<< $(k create deployment --image nginx --replicas 0 nginx-blue --dry-run=client -o yaml)

# Create 2 Deployments, blue with 1 replica and green with 9 replicas

cat <<EOF | k apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx-blue
  name: nginx-blue
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - image: nginx
        name: httpd
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx-green
  name: nginx-green
spec:
  replicas: 9
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - image: httpd
        name: nginx
---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: nginx
  name: nginx
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
  selector:
    app: nginx
  type: LoadBalancer
EOF

# All Pods enter the same Pool
selector:
  app: nginx


k get deployments.apps
NAME          READY   UP-TO-DATE   AVAILABLE   AGE
nginx-blue    1/1     1            1           38s
nginx-green   9/9     9            9           38s

kubectl run -i --tty --image alpine apline --restart=Never --rm
apk add curl

i=0; while [[ $i -le 10 ]]; do echo $i; curl nginx -I; let i=i+1; done

# Forcing each request to create a new TCP connection, each request 1 Pod
keep-alive     # → reuse connection → same pod
--no-keepalive # → new connection → new pod

i=0; while [[ $i -le 10 ]]; do echo $i; curl -s -I --no-keepalive nginx | grep nginx; let i=i+1; done

...
...

9
HTTP/1.1 200 OK
Server: nginx/1.29.8
Date: Tue, 14 Apr 2026 14:16:28 GMT
Content-Type: text/html
Content-Length: 896
Last-Modified: Tue, 07 Apr 2026 11:37:12 GMT
Connection: close
ETag: "69d4ec68-380"
Accept-Ranges: bytes

10
HTTP/1.1 200 OK
Date: Tue, 14 Apr 2026 14:16:28 GMT
Server: Apache/2.4.66 (Unix)
Last-Modified: Fri, 07 Nov 2025 08:23:08 GMT
ETag: "bf-642fce432f300"
Accept-Ranges: bytes
Content-Length: 191
Connection: close
Content-Type: text/html
```
[Menu](#-menu)

# 🚀 Create Object - Deploy Blue Green

```bash
# Blue-Green Deploy ( Root )
#
# I upload the entire application infrastructure to other Pods and switch the application to the Service selector.

cat <<EOF | k apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx-blue
  name: nginx-blue
spec:
  replicas: 5
  selector:
    matchLabels:
      app: nginx-blue-service
  template:
    metadata:
      labels:
        app: nginx-blue-service
    spec:
      containers:
      - image: httpd
        name: httpd
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx-green
  name: nginx-green
spec:
  replicas: 5
  selector:
    matchLabels:
      app: nginx-green-service
  template:
    metadata:
      labels:
        app: nginx-green-service
    spec:
      containers:
      - image: nginx
        name: nginx
---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: nginx
  name: nginx
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
  selector:
    app: nginx-blue-service
  type: LoadBalancer
EOF

k get deployments.apps
NAME          READY   UP-TO-DATE   AVAILABLE   AGE
nginx-blue    5/5     5            5           99s
nginx-green   5/5     5            5           99s

kubectl run -i --tty --image alpine apline --restart=Never --rm
apk add curl

# Blue represents apache

/ # i=0; while [[ $i -le 10 ]]; do curl -sSL nginx -I | grep Server; let i=i+1; done
Server: Apache/2.4.62 (Unix)
Server: Apache/2.4.62 (Unix)
Server: Apache/2.4.62 (Unix)
Server: Apache/2.4.62 (Unix)
Server: Apache/2.4.62 (Unix)
Server: Apache/2.4.62 (Unix)
Server: Apache/2.4.62 (Unix)
Server: Apache/2.4.62 (Unix)
Server: Apache/2.4.62 (Unix)
Server: Apache/2.4.62 (Unix)
Server: Apache/2.4.62 (Unix)

cat <<EOF | k apply -f -
apiVersion: v1
kind: Service
metadata:
  labels:
    app: nginx
  name: nginx
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
  selector:
    app: nginx-green-service
  type: LoadBalancer
EOF

# Green represents nginx

/ # i=0; while [[ $i -le 10 ]]; do curl -sSL nginx -I | grep Server; let i=i+1; done
Server: nginx/1.27.3
Server: nginx/1.27.3
Server: nginx/1.27.3
Server: nginx/1.27.3
Server: nginx/1.27.3
Server: nginx/1.27.3
Server: nginx/1.27.3
Server: nginx/1.27.3
Server: nginx/1.27.3
Server: nginx/1.27.3
Server: nginx/1.27.3
```
[Menu](#-menu)

# 🚀 Create Object - Ingress Controller

```bash
                 Usuário ( http://app.meudominio.com.br)
                                    |
                                    |
                         -----------------------
                            SVC - LoadBalancer
                         -----------------------
                                    |
                                    |
                         -----------------------
                         Pod Ingress - Resources
                         -----------------------
                                    |
                                    |
                         -----------------------
                             SVC - ClusterIP
                         -----------------------
                                    |
                                    |
                        ------------------------
                        |           |          |
                        |           |          |
                      -----       -----      -----
                       POD         POD        POD
                      -----       -----      -----

# Ingress is an application that needs to be deployed on the cluster.
# The LoadBalancer Service delivers requests to (Ingress Pod).
# DNS (app.demo.com) is resolved by LoadBalancer.
# When my yaml manifest creates an ingress, it adds an access rule to the ingress Resource.
#
# A virtual host is created in the Ingress Resource Pod (dynamically)
# Ingress, in turn, redirects to the application service (ClusterIP)
# Ingress is a reverse proxy

# Ingress Maintained by the F5 Nginx Corporation itself
https://docs.nginx.com/nginx-ingress-controller/

# Ingress maintained by the community (OpenSource)
https://kubernetes.github.io/ingress-nginx/

# As I'm using MetalLB to simulate L.B, I can download the yaml manifest and replace the service
# (NodePort by LoadBalancer).

curl -sSL https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.15.1/deploy/static/provider/baremetal/deploy.yaml | sed 's/NodePort/LoadBalancer/' | | k apply -f -

# Install by Helm
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx --set controller.service.type=LoadBalancer

# Check Install
k get pod -n ingress-nginx
NAME                                        READY   STATUS      RESTARTS   AGE
ingress-nginx-admission-create-p6hvd        0/1     Completed   0          53m
ingress-nginx-admission-patch-ffrmd         0/1     Completed   0          53m
ingress-nginx-controller-68697cf9d9-gntwb   1/1     Running     0          53m

k get svc -n ingress-nginx
NAME                                 TYPE           CLUSTER-IP       EXTERNAL-IP    PORT(S)                      AGE
ingress-nginx-controller             LoadBalancer   10.101.12.218    172.17.0.240   80:31168/TCP,443:30256/TCP   53m
ingress-nginx-controller-admission   ClusterIP      10.108.227.154   <none>         443/TCP                      53m

# Why did curl return 404, even though I have deployed the Ingress Controller?
# A: No resources have yet been deployed ( ingress resources )
#
curl -I http://172.17.0.240
HTTP/1.1 404 Not Found
Date: Fri, 17 Apr 2026 13:32:51 GMT
Content-Type: text/html
Content-Length: 146
Connection: keep-alive

# =============================== Ingress Class ====================================
#
# When creating my ingress resource, I define which ingress class will suit me.
# This is because I can have multiple ingress installed on the cluster.
k get ingressclasses
NAME    CONTROLLER             PARAMETERS   AGE
nginx   k8s.io/ingress-nginx   <none>       57m

# **NOTE:**
# If I do not inform the ingressclass, the creation of the ingress will be pending.
# To avoid this, I can set niginx with ingressclass default.

https://kubernetes.io/docs/concepts/services-networking/ingress/#ingress-class

# How is it defined?
# Through an annotation
k edit ingressclasses nginx
ingressclass.kubernetes.io/is-default-class: "true"

# Ex:
apiVersion: networking.k8s.io/v1
kind: IngressClass
metadata:
  labels:
    app.kubernetes.io/component: controller
  name: nginx
  annotations:
    ingressclass.kubernetes.io/is-default-class: "true"
spec:
  controller: k8s.io/ingress-nginx

# =============================== Created Recurso ==================================

k explain ingress.spec
k explain ingress.spec.rules.http

k create deployment --image nginx --replicas 3 nginx
k expose deployment nginx --type=ClusterIP --port=80

k get endpointslices.discovery.k8s.io
NAME          ADDRESSTYPE   PORTS   ENDPOINTS                            AGE
kubernetes    IPv4          6443    172.17.0.3                           69m
nginx-9slrs   IPv4          80      10.244.1.9,10.244.1.11,10.244.1.10   32s

#1) Resolves DNS (nginx.demo.com => LoadBalancer IP)
#2) When hitting this IP, it lands in the Ingress Controller Pod
#3) Ingress will check your conf entries to see if there is a virtual host defined and the path
#4) Forward to the backend running (nginx), to the Pod's clusterIp and this forwards to the Pod.

cat <<EOF | k apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: meu-nginx-ingress
spec:
  ingressClassName: nginx
  rules:
  - host: "nginx.demo.com"
    http:
      paths:
      - path: /
        pathType: ImplementationSpecific
        backend:
          service:
            name: nginx
            port:
              number: 80
EOF

kubectl get svc ingress-nginx-controller -n ingress-nginx
NAME                       TYPE           CLUSTER-IP      EXTERNAL-IP    PORT(S)                      AGE
ingress-nginx-controller   LoadBalancer   10.101.12.218   172.17.0.240   80:31168/TCP,443:30256/TCP   74m

k get ingress
NAME                CLASS   HOSTS            ADDRESS     PORTS   AGE
meu-nginx-ingress   nginx   nginx.demo.com   localhost   80      25s

# Simulating a call via Vhost
curl 172.17.0.240 -H "Host: nginx.demo.com"

<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }

# You could create an entry in ( /etc/host )
172.17.0.240 nginx.demo.com
curl nginx.demo.com

# =============================== Traefic ==================================

helm repo add traefik https://traefik.github.io/charts
helm repo update
helm install traefik traefik/traefik --namespace traefik --create-namespace --set logs.access.enabled=true
helm list -A
helm uninstall traefik -n traefik

k get ingressclass
k get svc -n traefik
NAME      TYPE           CLUSTER-IP      EXTERNAL-IP    PORT(S)                      AGE
traefik   LoadBalancer   10.98.226.102   172.17.0.241   80:32268/TCP,443:30421/TCP   57s

cat <<EOF | k apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: meu-nginx-ingress
spec:
  ingressClassName: traefik
  rules:
  - host: "nginx.demo.com"
    http:
      paths:
      - path: /
        pathType: ImplementationSpecific
        backend:
          service:
            name: nginx
            port:
              number: 80
EOF

# Check
k get ingress
NAME                CLASS     HOSTS            ADDRESS        PORTS   AGE
meu-nginx-ingress   traefik   nginx.demo.com   172.17.0.241   80      11m

# Testing
curl 172.17.0.241 -I -H "Host: nginx.demo.com"
HTTP/1.1 200 OK
Accept-Ranges: bytes
Content-Length: 896
Content-Type: text/html
Date: Fri, 17 Apr 2026 14:01:36 GMT
Etag: "69d4ec68-380"
Last-Modified: Tue, 07 Apr 2026 11:37:12 GMT
Server: nginx/1.29.8
```
[Menu](#-menu)

# 🚀 Create Object - Ingress Nginx Rewrite

```bash

# To exemplify this ingress functionality, let's create a simpler environment and adjust the paths and rewrite.

k create deployment --image nginx --replicas 3 nginx
k expose deployment nginx --type=ClusterIP --port=80 --target-port=80

k get endpointslices.discovery.k8s.io
NAME          ADDRESSTYPE   PORTS   ENDPOINTS                            AGE
kubernetes    IPv4          6443    172.17.0.2                           12m
nginx-28qhs   IPv4          80      10.244.1.11,10.244.1.9,10.244.1.10   11s


cat <<EOF | k apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: meu-nginx-ingress
spec:
  ingressClassName: nginx
  rules:
  - http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: nginx
            port:
              number: 80
EOF

k get ingress
NAME                CLASS   HOSTS   ADDRESS   PORTS   AGE
meu-nginx-ingress   nginx   *                 80      4s

k get svc -n ingress-nginx
NAME                                 TYPE           CLUSTER-IP      EXTERNAL-IP    PORT(S)                      AGE
ingress-nginx-controller             LoadBalancer   10.102.19.83    172.17.0.240   80:31519/TCP,443:31037/TCP   12m

# Why were hosts not specified?

  rules:
  - host: "nginx.demo.com"
    http:
      paths:
      - path: /
    ...
    ...
    ...

# When the "Host" field is specified in the manifest, Ingress creates a specific rule.
# Only route if the HTTP Host header is "nginx.demo.com".
# curl 172.17.0.241 -H "Host: nginx.demo.com" => This way I force the Header
#
# Ex:
server {
    server_name nginx.demo.com;
}

# When I DO NOT specify the "Host" field, ingress creates a Generic rule (catch-all)
# Accepts any Host
#
# This _ is the default server /catch-all
# Ex:
server {
    server_name _;
}


# This way I am accessing nginx from the Ingress Controller.
curl 172.17.0.240 -I
HTTP/1.1 200 OK
Date: Mon, 20 Apr 2026 13:11:25 GMT
Content-Type: text/html
Content-Length: 896
Connection: keep-alive
Last-Modified: Tue, 07 Apr 2026 11:37:12 GMT
ETag: "69d4ec68-380"
Accept-Ranges: bytes


# If I need to define a route? Ex: /nginx
# Would the Pod have to be able to work on this route too?
# Whenever you enter /nginx I want it to be redirected to the Nginx container
# I want the redirection to be based on the path and not based on the host.

cat <<EOF | k apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: meu-nginx-ingress
spec:
  ingressClassName: nginx
  rules:
  - http:
      paths:
      - path: /nginx
        pathType: ImplementationSpecific
        backend:
          service:
            name: nginx
            port:
              number: 80
EOF

k describe ingress meu-nginx-ingress
Name:             meu-nginx-ingress
Labels:           <none>
Namespace:        default
Address:          localhost
Ingress Class:    nginx
Default backend:  <default>
Rules:
  Host        Path  Backends
  ----        ----  --------
  *
              /nginx   nginx:80 (10.244.1.11:80,10.244.1.9:80,10.244.1.10:80)
Annotations:  <none>
Events:
  Type    Reason  Age                 From                      Message
  ----    ------  ----                ----                      -------
  Normal  Sync    117s (x3 over 19m)  nginx-ingress-controller  Scheduled for sync

# IT GOT BAD....

curl 172.17.0.240 -I
HTTP/1.1 404 Not Found
Date: Mon, 20 Apr 2026 13:29:21 GMT
Content-Type: text/html
Content-Length: 146
Connection: keep-alive

curl 172.17.0.240/nginx -I
HTTP/1.1 404 Not Found
Date: Mon, 20 Apr 2026 13:29:34 GMT
Content-Type: text/html
Content-Length: 153
Connection: keep-alive

# 1) Is the request arriving at the Pod?

NAME                     READY   STATUS    RESTARTS   AGE
nginx-66686b6766-r2njd   1/1     Running   0          29m
nginx-66686b6766-x99qp   1/1     Running   0          29m
nginx-66686b6766-xsxgz   1/1     Running   0          29m

k logs nginx-66686b6766-xsxgz

2026/04/20 13:02:03 [notice] 1#1: start worker process 43
2026/04/20 13:02:03 [notice] 1#1: start worker process 44
2026/04/20 13:02:03 [notice] 1#1: start worker process 45
2026/04/20 13:02:03 [notice] 1#1: start worker process 46
2026/04/20 13:02:03 [notice] 1#1: start worker process 47
10.244.1.5 - - [20/Apr/2026:13:11:25 +0000] "HEAD / HTTP/1.1" 200 0 "-" "curl/8.5.0" "10.244.1.1"
10.244.1.5 - - [20/Apr/2026:13:29:34 +0000] "HEAD /nginx HTTP/1.1" 404 0 "-" "curl/8.5.0" "10.244.1.1"
2026/04/20 13:29:34 [error] 37#37: *2 open() "/usr/share/nginx/html/nginx" failed (2: No such file or directory), client: 10.244.1.5, server: localhost, request: "HEAD /nginx HTTP/1.1", host: "172.17.0.240"


# He tried to open a folder called nginx in ( /usr/share/nginx/html/nginx ), this is because he tried a /nginx route


#=========================== What we really wanted? ==============================
#
# When accessing /nginx, the nginx controller should remove the "/nginx" from the request and forward
# it to the correct can in the "/"
#
# This error happened because the image does not have the /nginx path defined to respond to the request.
#
# We need to rewrite the Routes Path

https://kubernetes.github.io/ingress-nginx/

https://kubernetes.github.io/ingress-nginx/examples/rewrite/

# Annotations injects configurations (Nginx Behavior)

# Everything that starts with /nginx must go to the nginx service, but rewriting the URL before sending.
# nginx.ingress.kubernetes.io/use-regex: "true", Enables regex interpretation in path.
# Without this, /nginx(/|$)(.*) would be treated as a string literal.
#
# nginx.ingress.kubernetes.io/rewrite-target: /$2
# $2 = regex group → (.*)

# Internally, Nginx generates this...

location ~ /nginx(/|$)(.*) {
    rewrite ^ /$2 break;
    proxy_pass http://nginx-service;
}


| URL externa   | Vai virar internamente |
| --------------| ---------------------- |
| /nginx        | /                      |
| /nginx/       | /                      |
| /nginx/teste  | /teste                 |
| /nginx/api/v1 | /api/v1                |


cat <<EOF | k apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: meu-nginx-ingress
  annotations:
    nginx.ingress.kubernetes.io/use-regex: "true"
    nginx.ingress.kubernetes.io/rewrite-target: /$2
spec:
  ingressClassName: nginx
  rules:
  - http:
      paths:
      - path: /nginx(/|$)(.*)
        pathType: ImplementationSpecific
        backend:
          service:
            name: nginx
            port:
              number: 80
EOF

k get ingress
NAME                CLASS   HOSTS   ADDRESS     PORTS   AGE
meu-nginx-ingress   nginx   *       localhost   80      26m


k describe ingress meu-nginx-ingress
Name:             meu-nginx-ingress
Labels:           <none>
Namespace:        default
Address:          localhost
Ingress Class:    nginx
Default backend:  <default>
Rules:
  Host        Path  Backends
  ----        ----  --------
  *
              /nginx(/|$)(.*)   nginx:80 (10.244.1.11:80,10.244.1.9:80,10.244.1.10:80)
Annotations:  nginx.ingress.kubernetes.io/rewrite-target: /
              nginx.ingress.kubernetes.io/use-regex: true
Events:
  Type    Reason  Age                From                      Message
  ----    ------  ----               ----                      -------
  Normal  Sync    34s (x4 over 26m)  nginx-ingress-controller  Scheduled for sync

curl 172.17.0.240/nginx -I

HTTP/1.1 200 OK
Date: Mon, 20 Apr 2026 13:36:23 GMT
Content-Type: text/html
Content-Length: 896
Connection: keep-alive
Last-Modified: Tue, 07 Apr 2026 11:37:12 GMT
ETag: "69d4ec68-380"
Accept-Ranges: bytes


# Annotations influence the behavior of the Ingress Controller, but they are not what define the Ingress completely.
spec:
  rules:
  - host:
    http:
      paths:

# This defines:
# -who receives the request
# -where does she go (service)
# -paths and hosts

# Annotations (depend on the controller) -extra routes
# Annotations customize Ingress behavior

```

[Menu](#-menu)

# 🚀 Create Object - Ingress Múltiplos Paths

```bash
k create deployment --image nginx --replicas 3 nginx
k expose deployment nginx --type=ClusterIP --port=80 --target-port=80
k create deployment --image httpd --replicas 3 httpd
k expose deployment httpd --type=ClusterIP --port=80 --target-port=80

k get endpointslices.discovery.k8s.io
NAME          ADDRESSTYPE   PORTS   ENDPOINTS                             AGE
httpd-cqdhd   IPv4          80      10.244.1.12,10.244.1.13,10.244.1.14   31s
kubernetes    IPv4          6443    172.17.0.2                            4h20m
nginx-5g2r7   IPv4          80      10.244.1.11,10.244.1.9,10.244.1.10    39s

cat <<EOF | k apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: meu-nginx-ingress
  annotations:
    nginx.ingress.kubernetes.io/use-regex: "true"
    nginx.ingress.kubernetes.io/rewrite-target: /$2
spec:
  ingressClassName: nginx
  rules:
  - http:
      paths:
      - path: /nginx(/|$)(.*)
        pathType: ImplementationSpecific
        backend:
          service:
            name: nginx
            port:
              number: 80
  - http:
      paths:
      - path: /httpd(/|$)(.*)
        pathType: ImplementationSpecific
        backend:
          service:
            name: httpd
            port:
              number: 80
EOF


k get ingress
NAME                CLASS   HOSTS   ADDRESS     PORTS   AGE
meu-nginx-ingress   nginx   *       localhost   80      20s

curl 172.17.0.240/nginx -I
curl 172.17.0.240/httpd -I

# Another possibility is to expose via Virtual Host.

cat <<EOF | k apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: meu-nginx-ingress
spec:
  ingressClassName: nginx
  rules:
  - host: "nginx.demo.com"
    http:
      paths:
      - path: /
        pathType: ImplementationSpecific
        backend:
          service:
            name: nginx
            port:
              number: 80
  - host: "httpd.demo.com"
    http:
      paths:
      - path: /
        pathType: ImplementationSpecific
        backend:
          service:
            name: httpd
            port:
              number: 80
EOF

k get ingress
NAME                CLASS   HOSTS                           ADDRESS     PORTS   AGE
meu-nginx-ingress   nginx   nginx.demo.com,httpd.demo.com   localhost   80      3m49s

curl 172.17.0.240 -I -H "Host: nginx.demo.com"
curl 172.17.0.240 -I -H "Host: httpd.demo.com"

```
[Menu](#-menu)

# 🚀 Create Object - Ingress Error 503

```bash

# I assume here that the httpd service and deployment are running.

while true; do curl 172.17.0.240 -H "Host: httpd.demo.com"; sleep 1; echo "============"; done

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
<title>It works! Apache httpd</title>
</head>
<body>
<p>It works!</p>
</body>
</html>
============
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
<title>It works! Apache httpd</title>
</head>
<body>
<p>It works!</p>
</body>
</html>
============
...
...

k get svc
NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
httpd        ClusterIP   10.98.113.191   <none>        80/TCP    18m
kubernetes   ClusterIP   10.96.0.1       <none>        443/TCP   4h38m
nginx        ClusterIP   10.96.129.112   <none>        80/TCP    18m

k edit svc httpd

# Alterar o nome do selector app para forcar um erro 500
k patch svc httpd -p '{"spec":{"selector":{"app":"ui"}}}'

<html>
<head><title>503 Service Temporarily Unavailable</title></head>
<body>
<center><h1>503 Service Temporarily Unavailable</h1></center>
<hr><center>nginx</center>
</body>
</html>
============
<html>
<head><title>503 Service Temporarily Unavailable</title></head>
<body>
<center><h1>503 Service Temporarily Unavailable</h1></center>
<hr><center>nginx</center>
</body>
</html>
============

# Change the name of the app selector to httpd and back
k patch svc httpd -p '{"spec":{"selector":{"app":"httpd"}}}'

```

[Menu](#-menu)

# 🚀 Create Object - Ingress TLS

```bash
https://kubernetes.io/docs/concepts/services-networking/ingress/

# Generating Certificates -Self Signed
openssl req -x509 \
  -nodes \
  -days 365 \
  -newkey rsa:2048 \
  -keyout /tmp/tls.key \
  -out /tmp/tls.crt \
  -subj '/CN=*.prgs.corp/O=prgs' \
  -addext 'subjectAltName = DNS:*.prgs.corp'

openssl x509 -in /tmp/tls.crt -text

Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            25:c2:90:99:20:76:8f:0a:09:9f:03:fd:a4:d9:0b:c8:27:88:17:a2
        Signature Algorithm: sha256WithRSAEncryption
        Issuer: CN = *.prgs.corp, O = prgs
        Validity
            Not Before: Apr 20 19:52:06 2026 GMT
            Not After : Apr 20 19:52:06 2027 GMT
        Subject: CN = *.prgs.corp, O = prgs
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (2048 bit)
                Modulus:
                    00:e6:46:b0:c6:77:4b:e0:c1:4c:cf:f6:c3:28:61:
...
...
...

k create deployment --image nginx --replicas 3 nginx
k expose deployment nginx --type=ClusterIP --port=80 --target-port=80
k get endpointslices.discovery.k8s.io

cat <<EOF | k apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: meu-nginx-ingress
spec:
  ingressClassName: nginx
  rules:
  - host: "nginx.prgs.corp"
    http:
      paths:
      - path: /
        pathType: ImplementationSpecific
        backend:
          service:
            name: nginx
            port:
              number: 80
EOF

k get svc -n ingress-nginx
NAME                                 TYPE           CLUSTER-IP      EXTERNAL-IP    PORT(S)                      AGE
ingress-nginx-controller             LoadBalancer   10.102.19.83    172.17.0.240   80:31519/TCP,443:31037/TCP   7h4m

# Testing Http
curl 172.17.0.240 -H "Host: nginx.prgs.corp"

# Create Secrets
k create secret tls prgs-domain-secret --key /tmp/tls.key --cert /tmp/tls.crt

k get secrets
NAME                 TYPE                DATA   AGE
prgs-domain-secret   kubernetes.io/tls   2      6s

k describe secrets prgs-domain-secret
...
...
tls.crt:  1192 bytes
tls.key:  1708 bytes

# Rescue Certificated
k get secrets prgs-domain-secret -o yaml

# Decript Certificated
base64 -d <<< $(k get secrets prgs-domain-secret -o=jsonpath='{.data.tls\.crt}')

# This here injects TLS
  tls:
  - hosts:
    - *.demo.com
    secretName: demo-domain-secret


cat <<EOF | k apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: meu-nginx-ingress
spec:
  tls:
  - hosts:
    - "*.prgs.corp"
    secretName: prgs-domain-secret
  ingressClassName: nginx
  rules:
  - host: "nginx.prgs.corp"
    http:
      paths:
      - path: /
        pathType: ImplementationSpecific
        backend:
          service:
            name: nginx
            port:
              number: 80
EOF

k get ingress
NAME                CLASS   HOSTS             ADDRESS     PORTS     AGE
meu-nginx-ingress   nginx   nginx.prgs.corp   localhost   80, 443   169m

k describe ingress meu-nginx-ingress
Name:             meu-nginx-ingress
Labels:           <none>
Namespace:        default
Address:          localhost
Ingress Class:    nginx
Default backend:  <default>
TLS:
  prgs-domain-secret terminates *.prgs.corp
Rules:
  Host             Path  Backends
  ----             ----  --------
  nginx.prgs.corp
                   /   nginx:80 (10.244.1.16:80,10.244.1.15:80,10.244.1.17:80)
Annotations:       <none>
Events:
  Type    Reason  Age                 From                      Message
  ----    ------  ----                ----                      -------
  Normal  Sync    35s (x5 over 169m)  nginx-ingress-controller  Scheduled for sync


# Query made via http being redirected to https
curl 172.17.0.240 -I -H "Host: nginx.prgs.corp";
HTTP/1.1 308 Permanent Redirect
Date: Mon, 20 Apr 2026 20:15:07 GMT
Content-Type: text/html
Content-Length: 164
Connection: keep-alive
Location: https://nginx.prgs.corp

# Query made via https ( -L / -k )
curl 172.17.0.240 -k -I -L -H "Host: nginx.prgs.corp"

HTTP/1.1 308 Permanent Redirect
Date: Mon, 20 Apr 2026 20:19:49 GMT
Content-Type: text/html
Content-Length: 164
Connection: keep-alive
Location: https://nginx.prgs.corp

HTTP/2 200
date: Mon, 20 Apr 2026 20:19:49 GMT
content-type: text/html
content-length: 896
last-modified: Tue, 07 Apr 2026 11:37:12 GMT
etag: "69d4ec68-380"
accept-ranges: bytes
strict-transport-security: max-age=31536000; includeSubDomains

# Or if you prefer, you can define this in the query, forcing curl to resolve the Name.
# There is no redirect here, curl already talks via https.
curl -k -I -L \
  --resolve nginx.prgs.corp:443:172.17.0.240 \
  https://nginx.prgs.corp

HTTP/2 200
date: Mon, 20 Apr 2026 20:22:30 GMT
content-type: text/html
content-length: 896
last-modified: Tue, 07 Apr 2026 11:37:12 GMT
etag: "69d4ec68-380"
accept-ranges: bytes
strict-transport-security: max-age=31536000; includeSubDomains
```
[Menu](#-menu)

# 🚀 Create Object - ConfigMap Vs Secrets

```bash

# Configmap and Secrets => Kubernetes Objects
#
# Configmap => Composed of key=value
# Secrets => Key stored in base64 format
#
# Both inject data into a Pod.
#
# How to inject this into the Pod?
# -Environment Variables
# -Mount it as a file within the filesystem
# -A secret usually becomes a text file (Ex: Vault)
#
# Note: Secret is not encrypted, it is just encoded (base64)
```
[Menu](#-menu)

# 🚀 Create Object - ConfigMap

```bash
k get cm -n kube-system
NAME                                                   DATA   AGE
coredns                                                1      7h35m
extension-apiserver-authentication                     6      7h35m
kube-apiserver-legacy-service-account-token-tracking   1      7h35m
kube-proxy                                             2      7h35m
kube-root-ca.crt                                       1      7h35m
kubeadm-config                                         1      7h35m
kubelet-config                                         1      7h35m


k get cm -n kube-system coredns -o yaml | k neat
apiVersion: v1
data:
  Corefile: |
    .:53 {
        errors
        health {
           lameduck 5s
        }
        ready
        kubernetes cluster.local in-addr.arpa ip6.arpa {
           pods insecure
           fallthrough in-addr.arpa ip6.arpa
           ttl 30
        }
        prometheus :9153
        forward . /etc/resolv.conf {
           max_concurrent 1000
        }
        cache 30 {
           disable success cluster.local
           disable denial cluster.local
        }
        loop
        reload
        loadbalance
    }
kind: ConfigMap
metadata:
  name: coredns
  namespace: kube-system

# Corefile => Represents my key
# Everything after the "|" is the content (Multi line)

k create configmap --help
k create configmap my-config --from-literal=key1=config1 --from-literal=key2=config2

k get cm

k get cm my-config -o yaml
apiVersion: v1
data:
  key1: config1
  key2: config2
kind: ConfigMap
metadata:
  creationTimestamp: "2026-04-20T20:33:35Z"
  name: my-config
  namespace: default
  resourceVersion: "17859"
  uid: d13be0b6-a1c1-4951-9719-55a6341a656a

# Delete configmap
k delete cm my-config

https://kubernetes.io/docs/concepts/configuration/configmap/

# Generate model
k neat <<< $(k create deployment --image nginx --replicas 1 nginx --dry-run=client -o yaml)

cat <<EOF | k apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx
  name: nginx
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - image: nginx
        name: nginx
        env:
          - name: VHOSTS_PAULO
            valueFrom:
              configMapKeyRef:
                name: virtualhost
                key: nginx.prgs.corp
          - name: API_URL
            valueFrom:
              configMapKeyRef:
                  name: virtualhost
                  key: api.prgs.corp
EOF

# What if something is wrong?
NAME                    READY   STATUS                       RESTARTS   AGE
nginx-96b46d48d-h6ft2   0/1     CreateContainerConfigError   0          8s

# Get events
k describe pod nginx-96b46d48d-h6ft2

# The error occurred because the configmap was not defined

Events:
  Type     Reason     Age               From               Message
  ----     ------     ----              ----               -------
  Normal   Scheduled  56s               default-scheduler  Successfully assigned default/nginx-96b46d48d-h6ft2 to prgs-worker
  Normal   Pulled     54s               kubelet            Successfully pulled image "nginx" in 1.244s (1.244s including waiting). Image size: 62960006 bytes.
  Normal   Pulled     52s               kubelet            Successfully pulled image "nginx" in 1.679s (1.679s including waiting). Image size: 62960006 bytes.
  Normal   Pulled     40s               kubelet            Successfully pulled image "nginx" in 1.247s (1.247s including waiting). Image size: 62960006 bytes.
  Normal   Pulled     23s               kubelet            Successfully pulled image "nginx" in 1.383s (1.383s including waiting). Image size: 62960006 bytes.
  Normal   Pulling    9s (x5 over 56s)  kubelet            Pulling image "nginx"
  Warning  Failed     8s (x5 over 54s)  kubelet            Error: configmap "virtualhost" not found
  Normal   Pulled     8s                kubelet            Successfully pulled image "nginx" in 1.25s (1.25s including waiting). Image size: 62960006 bytes.


cat <<EOF | k apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: virtualhost
data:
  vhost: "prgs.corp"
  api_url: "https://api.prgs.corp"
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx
  name: nginx
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - image: nginx
        name: nginx
        env:
          - name: VHOSTS_PAULO
            valueFrom:
              configMapKeyRef:
                name: virtualhost
                key: vhost
          - name: API_URL
            valueFrom:
              configMapKeyRef:
                  name: virtualhost
                  key: api_url
EOF


# get Pod
k get pods -o=jsonpath='{range .items..metadata}{.name}{"\n"}{end}'

# Extract variables
k exec -it $(k get pods -o=jsonpath='{range .items..metadata}{.name}{"\n"}{end}') -- env | egrep 'VHOSTS_PAULO|API_URL'
VHOSTS_PAULO=prgs.corp
API_URL=https://api.prgs.corp

# Delete all
k delete deployments.apps nginx && k delete cm virtualhost

#============================= ConfigMap without SubPaths ==============================

# Generate model
k neat <<< $(k create deployment --image nginx --replicas 1 nginx --dry-run=client -o yaml)

cat <<EOF | k apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: virtualhost
data:
  vhost: "prgs.corp"
  api_url: "https://api.prgs.corp"
  index.html: |
    <html>
      <h1>
        Index.html Prgs Corp
      </h1>
    </html>
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx
  name: nginx
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - image: nginx
        name: nginx
        env:
           - name: VHOSTS_PAULO
             valueFrom:
               configMapKeyRef:
                  name: virtualhost
                  key: vhost
           - name: API_URL
             valueFrom:
                configMapKeyRef:
                   name: virtualhost
                   key: api_url
        volumeMounts:
        - name: index-html
          mountPath: "/usr/share/nginx/html"
          readOnly: true
      volumes:
      - name: index-html
        configMap:
          name: virtualhost
          items:
          - key: "index.html"
            path: "index.html"
EOF

# Create service
k expose deployment nginx --type=ClusterIP --port=80 --target-port=80

# This way all html contained in this directory ( /usr/share/nginx/html ) is replaced

kubectl run -i --tty --image alpine test --restart=Never --rm
apk add curl
curl nginx
<html>
  <h1>
    Index.html Prgs Corp
  </h1>
</html>

# Here is mounting the entire volume in the directory. Therefore, the entire contents of the original folder are replaced.
k exec -it $(k get pods -o=jsonpath='{range .items..metadata}{.name}{"\n"}{end}') -- ls /usr/share/nginx/html
index.html


#====================== ConfigMap With SubPaths - Avoid Replace =====================

# To avoid replacing the directory and replacing only the index.html we need to adjust the deployment.
# In this implementation, the folder is not overwritten.

cat <<EOF | k apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: virtualhost
data:
  vhost: "prgs.corp"
  api_url: "https://api.prgs.corp"
  index.html: |
    <html>
      <h1>
        Index.html Prgs Corp
      </h1>
    </html>
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx
  name: nginx
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - image: nginx
        name: nginx
        env:
           - name: VHOSTS_PAULO
             valueFrom:
               configMapKeyRef:
                  name: virtualhost
                  key: vhost
           - name: API_URL
             valueFrom:
                configMapKeyRef:
                   name: virtualhost
                   key: api_url
        volumeMounts:
        - name: index-html
          mountPath: "/usr/share/nginx/html/index.html"
          subPath: "index.html"
          readOnly: true
      volumes:
      - name: index-html
        configMap:
          name: virtualhost
          items:
          - key: "index.html"
            path: "index.html"
EOF


# Get Pod
k get pods -o=jsonpath='{range .items..metadata}{.name}{"\n"}{end}'

# Extract variables
k exec -it $(k get pods -o=jsonpath='{range .items..metadata}{.name}{"\n"}{end}') -- env | egrep 'VHOSTS_PAULO|API_URL'
VHOSTS_PAULO=prgs.corp
API_URL=https://api.prgs.corp

# As subPath was used, the file 50x.html (Original) remained
k exec -it $(k get pods -o=jsonpath='{range .items..metadata}{.name}{"\n"}{end}') -- ls /usr/share/nginx/html
50x.html  index.html

# Index.html content managed by configmap is replaced.
k exec -it $(k get pods -o=jsonpath='{range .items..metadata}{.name}{"\n"}{end}') -- cat /usr/share/nginx/html/index.html
<html>
  <h1>
    Index.html Prgs Corp
  </h1>
</html>
```
[Menu](#-menu)

# 🚀 Create Object - ConfigMap Vhost Ingress

```bash
k expose deployment nginx --type=ClusterIP --port=80 --target-port=80 --dry-run=client -o yaml

cat <<EOF | k apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: virtualhost
data:
  vhost: "prgs.corp"
  api_url: "https://api.prgs.corp"
  index.html: |
    <html>
      <h1>
        Chegou Index.html prgs.corp
      </h1>
    </html>
  index_app1.html: |
    <html>
      <h1>
        Sou o Index App1
      </h1>
    </html>
  vhost_app1.conf: |
    server {
        listen 80;
        listen [::]:80;
        server_name app.prgs.corp www.prgs.corp;
        root /usr/share/nginx/app1;
        index index.html index.htm index.nginx-debian.html;
    }
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx
  name: nginx
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - image: nginx
        name: nginx
        env:
           - name: VHOSTS_PAULO
             valueFrom:
               configMapKeyRef:
                  name: virtualhost
                  key: vhost
           - name: API_URL
             valueFrom:
                configMapKeyRef:
                   name: virtualhost
                   key: api_url
        volumeMounts:
        - name: index-html
          mountPath: "/usr/share/nginx/html/index.html"
          subPath: "index.html"
          readOnly: true
        - name: index-app1-html
          mountPath: "/usr/share/nginx/app1/index.html"
          subPath: "index.html"
          readOnly: true
        - name: vhost-app1-conf
          mountPath: "/etc/nginx/conf.d/vhost.conf"
          subPath: "vhost.conf"
      volumes:
        - name: index-html
          configMap:
            name: virtualhost
            items:
            - key: "index.html"
              path: "index.html"
        - name: index-app1-html
          configMap:
            name: virtualhost
            items:
            - key: "index_app1.html"
              path: "index.html"
        - name: vhost-app1-conf
          configMap:
            name: virtualhost
            items:
            - key: "vhost_app1.conf"
              path: "vhost.conf"
---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: nginx
  name: nginx
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
  selector:
    app: nginx
  type: ClusterIP
status:
  loadBalancer: {}
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: prgs-ingress
spec:
  ingressClassName: nginx
  rules:
  - host: "app.prgs.corp"
    http:
      paths:
      - path: /
        pathType: ImplementationSpecific
        backend:
          service:
            name: nginx
            port:
              number: 80
  - http:
      paths:
      - path: /
        pathType: ImplementationSpecific
        backend:
          service:
            name: nginx
            port:
              number: 80
EOF

k get svc -n ingress-nginx
NAME                                 TYPE           CLUSTER-IP      EXTERNAL-IP    PORT(S)                      AGE
ingress-nginx-controller             LoadBalancer   10.110.246.62   172.17.0.240   80:31548/TCP,443:30114/TCP   5m29

pod=$(k get pods -o=jsonpath='{range .items..metadata}{.name}{"\n"}{end}')
k exec -it $pod -- ls /etc/nginx/conf.d/vhost.conf
k exec -it $pod -- cat /etc/nginx/conf.d/vhost.conf
k exec -it $pod -- nginx -t
k exec -it $pod -- ls /usr/share/nginx/app1/index.html
k exec -it $pod -- cat /usr/share/nginx/app1/index.html


k get pod -o wide
NAME                     READY   STATUS    RESTARTS   AGE    IP            NODE          NOMINATED NODE   READINESS GATES
nginx-5b56d896c6-4b4rh   1/1     Running   0          4m6s   10.244.1.9    prgs-worker   <none>           <none>


kubectl run -i --tty --image alpine test --restart=Never --rm
apk add curl

# Consuming directly from the Pod -Without virtual Host
/ # curl 10.244.1.9
<html>
  <h1>
    Chegou Index.html prgs.corp
  </h1>
</html>

# Consuming directly from the Pod -With virtual Host
/ # curl 10.244.1.9 -H "Host: app.prgs.corp"
<html>
  <h1>
    Sou o Index App1
  </h1>
</html


# Hitting straight to Ingress -No virtual Host
curl 172.17.0.240
<html>
  <h1>
    Chegou Index.html prgs.corp
  </h1>
</html>

# Hitting straight to Ingress -With virtual Host
curl 172.17.0.240 -H "Host: app.prgs.corp"
<html>
  <h1>
    Sou o Index App1
  </h1>
</html>

#================================ Projected-Volumes =================================
#
# Allows you to mount 2 or more mount points pointing to the same file.
#
cat <<EOF | k apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: virtualhost
data:
  index.html: |
    <html>
      <h1>
        Chegou Index.html novo
      </h1>
    </html>
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx
  name: nginx
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - image: nginx
          name: nginx
          volumeMounts:
            - name: all-in-one
              mountPath: "/usr/share/nginx/html"
              readOnly: true
      volumes:
        - name: all-in-one
          projected:
            sources:
              - configMap:
                  name: virtualhost
                  items:
                    - key: "index.html"
                      path: "index.html"
                    - key: "index.html"
                      path: "index2.html"
EOF

k get pods
NAME                     READY   STATUS    RESTARTS   AGE
nginx-66d8fc6cdb-s9x7q   1/1     Running   0          13s

# We have 2 different files that reference the same source ( configmap )
k exec nginx-66d8fc6cdb-s9x7q -- bash -c "ls /usr/share/nginx/html"
index.html
index2.html
```

[Menu](#-menu)

# 🚀 Create Object - Secrets

```bash
k create secret --help

# Available Commands:
# docker-registry     Creates a secret to be used with the Docker Registry
# generic             Creates a secret "from a local file", directory, or literal value
# tls                 Creates a TLS type secret

k create secret generic credentials --from-literal=username=admin
k get secrets

base64 -d <<< $(k get secrets credentials -o=jsonpath='{.data.username}') && echo

https://kubernetes.io/docs/concepts/configuration/secret/#secret-types

apiVersion: v1
kind: Secret
metadata:
  name: secret-basic-auth
type: kubernetes.io/basic-auth
stringData:
  username: admin # required field for kubernetes.io/basic-auth
  password: t0p-Secret # required field for kubernetes.io/basic-auth

#================================ Secrets From File =================================
#
echo "password" > key.txt

# Define key name
k create secret generic sec-file-01 --from-file=password=./key.txt
k get secrets
k describe secrets sec-file-01
base64 -d <<< $(k get secrets sec-file-01 -o=jsonpath='{.data.password}')

# Since the key was not provided, the filename becomes the key.
k create secret generic sec-file-02 --from-file=./key.txt
k get secrets
k describe secrets sec-file-02
base64 -d <<< $(k get secrets sec-file-02 -o=jsonpath='{.data.key\.txt}')

# Mixing key name with file
k create secret generic sec-file-03 --from-literal=key=value --from-file=./key.txt
k get secrets
k describe secrets sec-file-03
base64 -d <<< $(k get secrets sec-file-03 -o=jsonpath='{.data.key\.txt}')
base64 -d <<< $(k get secrets sec-file-03 -o=jsonpath='{.data.key}')

#================================ Secrets Encode ====================================
#
# Generating a secret type manifest with encoded data
#
echo -n "segredo" | base64

k create secret \
  generic credentials \
  --from-literal=username=admin \
  --from-literal=password=admin \
  --type=kubernetes.io/basic-auth \
  --dry-run=client \
  -o yaml

cat <<EOF | k apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: credentials
type: kubernetes.io/basic-auth
data:
  password: YWRtaW4=
  username: YWRtaW4=
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: virtualhost
data:
  vhost: "prgs.com"
  api_url: "https://api.prgs.com"
  index.html: |
    <html>
      <h1>
        Chegou Index.html novo
      </h1>
    </html>
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx
  name: nginx
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - image: nginx
        name: nginx
        env:
           - name: VHOSTS_PAULO
             valueFrom:
               configMapKeyRef:
                  name: virtualhost
                  key: vhost
           - name: API_URL
             valueFrom:
                configMapKeyRef:
                   name: virtualhost
                   key: api_url
           - name: USERNAME
             valueFrom:
                secretKeyRef:
                   name: credentials
                   key: username
        volumeMounts:
        - name: index-html
          mountPath: "/usr/share/nginx/html/index.html"
          subPath: "index.html"
          readOnly: true
        - name: secret-password
          mountPath: "/segredo"
          readOnly: true
      volumes:
        - name: index-html
          configMap:
            name: virtualhost
            items:
            - key: "index.html"
              path: "index.html"
        - name: secret-password
          secret:
            secretName: credentials
EOF

k exec -it $(k get pods -o=jsonpath='{range .items..metadata}{.name}{"\n"}{end}') -- ls /

# Mount the directory ( /segredo ) and within this directory ( /segredo ) the file (username).

k exec -it $(k get pods -o=jsonpath='{range .items..metadata}{.name}{"\n"}{end}') -- cat /segredo/username && echo
admin
```

[Menu](#-menu)

# 🚀 Create Object - Storage PV / PVC / StorageClass / AccessMode

```bash
# Let's separate the storage block into 3 themes:
# -Dynamic Provisioning
# -Static Provisioning
# -Access Modes
#
#========================== Static Provisioning  ===============================
#
# In this model we consider:
                              POD
                                |
                                |
                              PVC
                                |
                                |
                               PV
                                |
                                |
(POD Controller) =>  PVC (Persistent Volume Clain) => PV ( Persistent Volume )

#
# Infra:
#
# Persistent Volume (PV) => We need (Persistent Volume Object), we can have several types of persistent Volumes
# and once created I can offer it to the pod.
#
# In Persistent Volume (PV), you as admin define the type, characteristics and size.
# This will now allow my cluster to have an Object to persist data.
#
# A common scenario is to have an external disk connected to one of the Nodes (Worker).
#
# On that specific node that has the disk attached, you can write the data to that volume.
# This type of provisioning is called "local". Ex: Create a 100GB PV
#
# PV => Storage that I am making available
#
# App:
#
# Persistent Volume Clain (PVC) => The app then asks for (clain), requests this volume,
# then this object (PVC) is used, a piece (Ex: 5GB) to serve the Pod.
#
# Note:
# The pod does not speak directly to PV
#
# PVC is a request for a part of this storage. Each App will have its PVC
#

https://kubernetes.io/docs/concepts/storage/volumes/

https://kubernetes.io/docs/concepts/storage/volumes/#local

# To illustrate, we will start with PV (PersistentVolume)
#
# PV is global, this means that it is not attached to ANY namespace.
#
k api-resources| grep persis
persistentvolumeclaims              pvc          v1                                true         PersistentVolumeClaim
persistentvolumes                   pv           v1                                false        PersistentVolume
#
#
# kubectl get nodes -o custom-columns=NAME:.metadata.name,LABELS:.metadata.labels
#
k get node --show-labels
NAME                 STATUS   ROLES           AGE     VERSION   LABELS
prgs-control-plane   Ready    control-plane   6m38s   v1.34.0   beta.kubernetes.io/arch=amd64,
                                                                beta.kubernetes.io/os=linux,
                                                                kubernetes.io/arch=amd64,
                                                                kubernetes.io/hostname=prgs-control-plane,
                                                                kubernetes.io/os=linux,
                                                                node-role.kubernetes.io/control-plane=
prgs-worker          Ready    worker-apps     13m     v1.34.0   beta.kubernetes.io/arch=amd64,
                                                                beta.kubernetes.io/os=linux,
                                                                kubernetes.io/arch=amd64,
                                                                kubernetes.io/hostname=prgs-worker,
                                                                kubernetes.io/os=linux,
                                                                kubernetes.io/role=worker-apps,prgs/apps=true


# In my environment, I only have 1 Node (Control Plane) and 1 Node (Control Data)
#
docker exec prgs-worker bash -c "mkdir -p /data"
docker exec prgs-worker bash -c "ls -la /"

###################
# Create PV
###################

cat <<EOF | k apply -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  name: prgs-worker-pv
spec:
  capacity:
    storage: 1Gi
  volumeMode: Filesystem
  accessModes:
  - ReadWriteOnce
  storageClassName: ""
  local:
    path: /data
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - prgs-worker
EOF

# RECLAIM POLICY => Retain (Will not delete data)
# STATUS         => Available (Available and not attached and no PVC)

k get pv
NAME             CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS   VOLUMEATTRIBUTESCLASS   REASON   AGE
prgs-worker-pv   1Gi        RWO            Retain           Available                          <unset>

###################
# Create PVC
###################

https://kubernetes.io/docs/concepts/storage/persistent-volumes/

https://kubernetes.io/docs/concepts/storage/persistent-volumes/#persistentvolumeclaims

# In my kind environment, the StorageClass is already provisioned, but IT WILL NOT BE informed when defining the PVC
# If I don't define the storageClassName, it will get it dynamically, it will get the cluster's default.
#
# Notes:
# So I NEED to leave the storageClassName empty, and I need to inform the PV created in the previous phase in the volumeName field.
#
k explain pvc.spec.storageClassName

k get sc
NAME                 PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
standard (default)   rancher.io/local-path   Delete          WaitForFirstConsumer   false                  150m


cat <<EOF | k apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: prgs-worker-pvc
spec:
  accessModes:
    - ReadWriteOnce
  volumeMode: Filesystem
  resources:
    requests:
      storage: 10Mi
  storageClassName: ""
  volumeName: prgs-worker-pv
EOF

k get pvc
NAME              STATUS   VOLUME           CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
prgs-worker-pvc   Bound    prgs-worker-pv   1Gi        RWO                           <unset>                 114s

# Kubernetes binds the PVC to the PV as soon as it finds a valid match.

k describe pvc prgs-worker-pvc

# Doc
k explain deployment.spec.template.spec
k explain deployment.spec.template.spec.volumes
k explain deployment.spec.template.spec.volumes | grep required
name	<string> -required-

k explain deployment.spec.template.spec.volumes.persistentVolumeClaim
k explain deployment.spec.template.spec.volumes.persistentVolumeClaim | grep required
claimName	<string> -required-

k explain deployment.spec.template.spec.containers.volumeMounts | grep required
mountPath	<string> -required-
name	<string> -required-

cat <<EOF | k apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx
  name: nginx
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - image: nginx
          name: nginx
          volumeMounts:
          - name: data
            mountPath: "/data"
      volumes:
        - name: data
          persistentVolumeClaim:
            claimName: prgs-worker-pvc
EOF

docker exec prgs-worker bash -c "ls -la /data"

pod=$(k get pods -o=jsonpath='{range .items..metadata}{.name}{"\n"}{end}')

k exec -it $pod -- bash -c "cd /data && for i in {1..20}; do dd if=/dev/zero of=foo.\$i bs=1MB count=1; done"

k exec -it $pod -- bash -c "du -hs /data"

# A 1GB PV was not created but a 10MB PV, how did it allow 20MB to be stored?
✅  PVC does not limit space by itself.
✅  Local PV has no quota (You must use LVM with PV limiting block capacity, or even StorageClass like Ceph (RBD) /Longhorn).
✅  Here the entire block where the PV is defined is used. Actual limit depends on the storage backend.
✅ It is expected behavior.

# And this excerpt below, shouldn't it do that?

resources:
  requests:
    storage: 10Mi

✅ No !! That's a hard limit, it's just a minimum requirement for binding.

k exec -it $pod -- bash -c "df -h"
Filesystem                         Size  Used Avail Use% Mounted on
overlay                            466G  255G  188G  58% /
tmpfs                               64M     0   64M   0% /dev
overlay                            466G  255G  188G  58% /data


#============================= Dynamic Provisioning =============================

                             POD
                              |
                              |
                        StorageClass
                              |
                              |
    (POD Controller) =>   Storage Class => ( NFS / Local Path)

# App
# It doesn't change anything compared to (Static Provisioning), that is, I need a PVC to request part of the storage.
#
# Each App will have its PVC.
#
# The change is that when creating a PVC there will be a field for me to inform the StorageClass, depending on the storageClass, its type will be defined.
#
# Storage Class is a shelf with several types of storage that I can use. Ex: (EFS which is AWS's NFS, EBS, NFS, Longhorn)
#
# The controller pod is responsible for managing this dynamism. He's the one who takes care of creating the PV.
#
# Every dynamic provisioning will have a controller involved doing the magic...
#
# StoragClasses => NOT specific to a namespace
#
# Advantages of Dynamic Volume, I just choose from the shelf which PVC will suit me and the rest k8s
# is responsible for doing this, which is mounting the PV.


k get storageclasses
NAME                 PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
standard (default)   rancher.io/local-path   Delete          WaitForFirstConsumer   false                  47m

https://artifacthub.io/packages/helm/kvaps/nfs-server-provisioner

https://medium.com/@dikkumburage/how-to-deploy-nfs-client-provionser-31407a3746c8

# I don't have to inform volumeName (PV) when working with dynamic volume
#
# I need to inform which storageClass
#
k get sc
NAME                 PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
standard (default)   rancher.io/local-path   Delete          WaitForFirstConsumer   false                  65m

cat <<EOF | k apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: prgs-control-plane-pvc
spec:
  accessModes:
    - ReadWriteOnce
  volumeMode: Filesystem
  resources:
    requests:
      storage: 10Mi
  storageClassName: standard
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx
  name: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - image: nginx
          name: nginx
          volumeMounts:
          - name: data
            mountPath: "/data"
      volumes:
        - name: data
          persistentVolumeClaim:
            claimName: prgs-control-plane-pvc
EOF


# Physically, the data is being persisted within the worker
docker exec prgs-control-plane bash -c "ls -la /var/local-path-provisioner"
drwxr-xr-x  3 root root 4096 Apr 23 13:06 .
drwxr-xr-x 12 root root 4096 Apr 23 13:06 ..
drwxrwxrwx  2 root root 4096 Apr 23 13:06 pvc-1f64a261-b8b2-4e36-a8a7-33969078cc41_default_prgs-control-plane-pvc


# Each pod wrote 10 .txt files on the same volume.
pods=$(k get pods -o=jsonpath='{range .items..metadata}{.name}{"\n"}{end}')

while IFS= read -r pod;
do
  k exec $pod -- bash -c 'for i in {1..10}; do touch "/data/${HOSTNAME}-$i.txt"; done'
done <<< "$pods"


# Read
while IFS= read -r pod;
do
  k exec $pod -- bash -c "ls /data"
  echo "-------------------"
done <<< "$pods"

# All Pods write to the volume.
nginx-7b98f58f85-rx2r8-1.txt
nginx-7b98f58f85-rx2r8-10.txt
nginx-7b98f58f85-rx2r8-2.txt
nginx-7b98f58f85-rx2r8-3.txt
nginx-7b98f58f85-rx2r8-4.txt
nginx-7b98f58f85-rx2r8-5.txt
nginx-7b98f58f85-rx2r8-6.txt
nginx-7b98f58f85-rx2r8-7.txt
nginx-7b98f58f85-rx2r8-8.txt
nginx-7b98f58f85-rx2r8-9.txt
nginx-7b98f58f85-s97b7-1.txt
nginx-7b98f58f85-s97b7-10.txt
nginx-7b98f58f85-s97b7-2.txt
nginx-7b98f58f85-s97b7-3.txt
nginx-7b98f58f85-s97b7-4.txt
nginx-7b98f58f85-s97b7-5.txt
nginx-7b98f58f85-s97b7-6.txt
nginx-7b98f58f85-s97b7-7.txt
nginx-7b98f58f85-s97b7-8.txt
nginx-7b98f58f85-s97b7-9.txt
nginx-7b98f58f85-wq6mg-1.txt
nginx-7b98f58f85-wq6mg-10.txt
nginx-7b98f58f85-wq6mg-2.txt
nginx-7b98f58f85-wq6mg-3.txt
nginx-7b98f58f85-wq6mg-4.txt
nginx-7b98f58f85-wq6mg-5.txt
nginx-7b98f58f85-wq6mg-6.txt
nginx-7b98f58f85-wq6mg-7.txt
nginx-7b98f58f85-wq6mg-8.txt
nginx-7b98f58f85-wq6mg-9.txt
-------------------


# By having this access mode (ReadWriteOnce) all Pods scheduled on this Node can write.
#
# That's why this directory was not mounted on the other worker ( prgs-worker )
#
✅ Meaning: the volume can be mounted in read/write mode by ONE NODE at a time
✅ Filesystem sharing within the same node, not cluster-wide.

#================================== Access Modes ====================================

# AccessModes => The defined PV (ReadWriteOnce) will have the disk attached to only one Node.
#
# I can even have more Pods reading the same disk, as long as these Pods run on the same worker.
#
# PersistentVolumeReclaimPolicy => When the PV is deleted, what behavior?
# All data will be deleted once the PV has already been removed (By setting this to Delete this will happen)
#
# Each type of storage will support different access modes.

https://kubernetes.io/docs/concepts/storage/persistent-volumes/#access-modes

# ReadWriteOnce ( RWO ) => I can even have more Pod reading the same disk/volume,
# as long as these POds run on the same worker, or storage is shared NFS.
#
# ReadWriteMany (RWX) => Mother Joana's house (Everyone can do anything)

cat <<EOF | k apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: prgs-worker-claim
spec:
  accessModes:
    - ReadWriteMany
  volumeMode: Filesystem
  resources:
    requests:
      storage: 10Mi
  storageClassName: standard
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx
  name: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - image: nginx
          name: nginx
          volumeMounts:
          - name: data
            mountPath: "/data"
      volumes:
        - name: data
          persistentVolumeClaim:
            claimName: prgs-worker-claim
EOF

# When trying to apply the manifest, the kube-scheduler will try to distribute the load among the cluster members.
# What will happen in this scenario above?

k describe pvc prgs-worker-claim

Events:
  Type     Reason                Age                From                                                                                                Message
  ----     ------                ----               ----                                                                                                -------
  Normal   WaitForFirstConsumer  30s                persistentvolume-controller                                                                         waiting for first consumer to be created before binding
  Normal   Provisioning          15s (x2 over 30s)  rancher.io/local-path_local-path-provisioner-57c5987fd4-m2f5m_840e8c44-e7d9-427b-93e5-a2b88ac268c5  External provisioner is provisioning volume for claim "default/prgs-worker-claim"
  Warning  ProvisioningFailed    15s (x2 over 30s)  rancher.io/local-path_local-path-provisioner-57c5987fd4-m2f5m_840e8c44-e7d9-427b-93e5-a2b88ac268c5  failed to provision volume with StorageClass "standard": Only support ReadWriteOnce access mode
  Normal   ExternalProvisioning  10s (x3 over 30s)  persistentvolume-controller                                                                         Waiting for a volume to be created either by the external provisioner 'rancher.io/local-path' or manually by the system administrator. If volume creation is delayed, please verify that the provisioner is running and correctly registered.

# The error is due to compatibility between the volume type and the access mode that was requested.

accessModes:
  - ReadWriteMany

# But the provisioner being used is local-path-provisioner, and it only supports: ReadWriteOnce (RWO)
# The message "Only support ReadWriteOnce access mode" makes this clear.
#
# How to fix?

accessModes:
  - ReadWriteOnce

# All pods will use separate volumes
# or the scheduler can focus on the same node.
#
# Use storage that supports RWX (recommended in this case)
# Ex:
# NFS
# CephFS
# Longhorn (com RWX habilitado)
# GlusterFS
```

[Menu](#-menu)

# 🚀 Create Object - Reclaim Policy PVC / StorageClass

```bash
https://kubernetes.io/docs/concepts/storage/persistent-volumes/#reclaim-policy

# Delete => Default (As soon as you delete the pvc resources, the data is deleted)
# Retain => Deletes the PVC, but the data is still there
#
# It is in the PVC definition that I apply the Policy type

reclaimPolicy: Retain

...
...
...
    spec:
      containers:
        - image: nginx
          name: nginx
          volumeMounts:
          - name: data
            mountPath: "/data"
      volumes:
        - name: data
          persistentVolumeClaim:
            claimName: volume-persistente

# This means that Deployments that use this PVC (persistent-volume) will not have their data deleted

# If I delete Deployment + PVC, my data is still intact,
# because the StorageClass of type Retain is guaranteeing this.

# The PV will still be there but with status ( Release )
# Notes:
# Notes:
# ******************************************************************
# Once in this state (Release), it can be attached again.
# ******************************************************************

k get pv

# To reuse this PV it is necessary to adjust the PVC deployment to "specify the PV" and leave the storageClass blank.
#
# Ex: pv-55be07b6-f39c-41e5-90bc-59885eecdc2d

kind: PersistentVolumeClaim
metadata:
  name: prgs-worker-claim
spec:
  accessModes:
    - ReadWriteOnce
  volumeMode: Filesystem
  resources:
    requests:
      storage: 10Mi
  storageClassName: ""
  volumeName: pv-55be07b6-f39c-41e5-90bc-59885eecdc2d

#================================== PVC Policy Retain ===============================
#
# Nothing prevents having multiple storageClass in your cluster. In the example below, a new PVC will be created
# manually, and it will be labeled that this PVC will have any name like StorageClass

# Create the directory
docker exec prgs-control-plane bash -c "mkdir -p /data"
docker exec prgs-control-plane bash -c "ls /data"

# For this laboratory, first create the PV
# As this PV has a specific affinity rule,
# it will only mount the pods with this volume on this node ( prgs-control-plane )

cat <<EOF | k apply -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  name: prgs-control-plane-pv
spec:
  capacity:
    storage: 10Mi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  storageClassName: prgs-control-plane-sc
  local:
    path: /data
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - prgs-control-plane
EOF

k get pv
NAME                    CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS            VOLUMEATTRIBUTESCLASS   REASON   AGE
prgs-control-plane-pv   10Mi       RWO            Retain           Available           prgs-control-plane-sc   <unset>                          3s

# Create PVC

cat <<EOF | k apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: prgs-control-plane-pvc
spec:
  storageClassName: prgs-control-plane-sc
  accessModes:
  - ReadWriteMany
  resources:
    requests:
      storage: 10Mi
EOF

# Check

k get pvc
NAME                     STATUS   VOLUME                  CAPACITY   ACCESS MODES   STORAGECLASS            VOLUMEATTRIBUTESCLASS   AGE
prgs-control-plane-pvc   Bound    prgs-control-plane-pv   10Mi       RWX            prgs-control-plane-sc   <unset>                 4s

# Although the PVC was labeled with StorageClass, called "prgs-control-plane-sc", this storageClass does not exist in K8S.

k get sc
NAME                 PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
standard (default)   rancher.io/local-path   Delete          WaitForFirstConsumer   false                  17m

cat <<EOF | k apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx
  name: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: kubernetes.io/hostname
                operator: In
                values:
                - prgs-control-plane
      containers:
        - image: nginx
          name: nginx
          volumeMounts:
          - name: data
            mountPath: "/data"
      volumes:
        - name: data
          persistentVolumeClaim:
            claimName: prgs-control-plane-pvc
EOF

pods=$(k get pods -o=jsonpath='{range .items..metadata}{.name}{"\n"}{end}')

while IFS= read -r pod;
do
  k exec $pod -- bash -c 'for i in {1..10}; do touch "/data/${HOSTNAME}-$i.txt"; done'
done <<< "$pods"


# Read
while IFS= read -r pod;
do
  k exec $pod -- bash -c "ls /data"
  echo "-------------------"
done <<< "$pods"

nginx-7b98f58f85-4trx6-1.txt
...
...
nginx-7b98f58f85-4trx6-10.txt
-------------------
nginx-7b98f58f85-4trx6-1.txt
...
...
nginx-7b98f58f85-4trx6-10.txt
-------------------
nginx-7b98f58f85-4trx6-1.txt
...
...
nginx-7b98f58f85-4trx6-10.txt
-------------------

# Reading in worker
docker exec prgs-control-plane bash -c "ls /data"
nginx-7b98f58f85-4trx6-1.txt
nginx-7b98f58f85-764fk-10.txt
...
...
nginx-7b98f58f85-764fk-1.txt
nginx-7b98f58f85-764fk-10.txt
...
...
nginx-7b98f58f85-jr46k-1.txt
nginx-7b98f58f85-jr46k-10.txt

# What if I delete everything?
#
k delete deployments.apps nginx
deployment.apps "nginx" deleted from default namespace

# Delete PVC
k delete pvc prgs-control-plane-pvc
persistentvolumeclaim "prgs-control-plane-pvc" deleted from default namespace

# Delete Pv
k delete pv prgs-control-plane-pv
persistentvolume "prgs-control-plane-pv" deleted

# Reading in worker
# The data is there
#
docker exec prgs-control-plane bash -c "ls /data"
nginx-7b98f58f85-4trx6-1.txt
nginx-7b98f58f85-764fk-10.txt
...
...
nginx-7b98f58f85-764fk-1.txt
nginx-7b98f58f85-764fk-10.txt
...
...
nginx-7b98f58f85-jr46k-1.txt
nginx-7b98f58f85-jr46k-10.txt

# If I Upgrade again (PV/PVC/Deployment) what happens?
k get pods
NAME                     READY   STATUS    RESTARTS   AGE
nginx-6767449f59-h58tb   1/1     Running   0          63s
nginx-6767449f59-pg2sl   1/1     Running   0          63s
nginx-6767449f59-vdxbp   1/1     Running   0          63s

# Reading via Pod
pods=$(k get pods -o=jsonpath='{range .items..metadata}{.name}{"\n"}{end}')

while IFS= read -r pod;
do
  k exec $pod -- bash -c "ls /data"
  echo "-------------------"
done <<< "$pods"

# Can mount and read data normally.
# This is because when creating the PVC it ​​was defined ( persistentVolumeReclaimPolicy: Retain )

nginx-7b98f58f85-4trx6-1.txt
...
...
nginx-7b98f58f85-4trx6-10.txt
-------------------
nginx-7b98f58f85-4trx6-1.txt
...
...
nginx-7b98f58f85-4trx6-10.txt
-------------------
nginx-7b98f58f85-4trx6-1.txt
...
...
nginx-7b98f58f85-4trx6-10.txt
-------------------

#============================= StoraClass Policy Retain =============================
#
# The idea here is to apply the same Retain rules made in PVC, but at the StorageClass level
#
# The pv is created by inheriting what was defined in StorgaClass
#
# It is in the StorageClass definition that I apply the Policy type
#
# Let's create a Custom StorageClass.

k neat <<< $(k get sc standard -o yaml) | sed 's/true/false/;s/standard/volume-persistente/;s/Delete/Retain/'

apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  annotations:
    storageclass.kubernetes.io/is-default-class: "false"
  name: volume-persistente
provisioner: rancher.io/local-path
reclaimPolicy: Retain
volumeBindingMode: WaitForFirstConsumer

k neat <<< $(k get sc standard -o yaml) | sed 's/true/false/;s/standard/volume-persistente/;s/Delete/Retain/' | k apply -f -

# List StorageClass
k get sc
NAME                 PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
standard (default)   rancher.io/local-path   Delete          WaitForFirstConsumer   false                  4h25m
volume-persistente   rancher.io/local-path   Retain          WaitForFirstConsumer   false                  3s

# Creating the PVC
#
# Note: Here it was defined that the access mode ...

accessModes:
  - ReadWriteOnce

✅ By having this access mode (ReadWriteOnce) all Pods scheduled on this Node can write/read.
✅ Volume can be mounted in read/write mode by ONE NODE at a time
✅ Filesystem sharing within the same node, not cluster-wide.
✅ The defined PV (ReadWriteOnce) will have the disk attached to only one Node.
✅ Multiple Pods can use the same volume if they are on the same node.

cat <<EOF | k apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: prgs-control-plane-pvc
spec:
  storageClassName: volume-persistente
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 10Mi
EOF

# Check
# NOTE: Here it will remain as Pending until a POD makes a request to use this PVC

k get pvc
NAME                     STATUS    VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS         VOLUMEATTRIBUTESCLASS   AGE
prgs-control-plane-pvc   Pending                                      volume-persistente   <unset>                 2s

# Create Deployment
cat <<EOF | k apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx
  name: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - image: nginx
          name: nginx
          volumeMounts:
          - name: data
            mountPath: "/data"
      volumes:
        - name: data
          persistentVolumeClaim:
            claimName: prgs-control-plane-pvc
EOF

# How was the assembly point inside the Worker?
#
docker exec prgs-control-plane bash -c "ls /var/local-path-provisioner"
pvc-25c56de4-a766-4d72-9ecf-566c0074cbfd_default_prgs-control-plane-pvc

k get pvc
NAME                     STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS         VOLUMEATTRIBUTESCLASS   AGE
prgs-control-plane-pvc   Bound    pvc-25c56de4-a766-4d72-9ecf-566c0074cbfd   10Mi       RWO            volume-persistente   <unset>                 9m8s


# Injecting Data
pods=$(k get pods -o=jsonpath='{range .items..metadata}{.name}{"\n"}{end}')

while IFS= read -r pod;
do
  k exec $pod -- bash -c 'for i in {1..10}; do touch "/data/${HOSTNAME}-$i.txt"; done'
done <<< "$pods"

# Listing directly from Worker
docker exec prgs-control-plane bash -c "ls /var/local-path-provisioner/pvc-25c56de4-a766-4d72-9ecf-566c0074cbfd_default_prgs-control-plane-pvc"
nginx-7b98f58f85-5lt9h-1.txt
nginx-7b98f58f85-5lt9h-10.txt
nginx-7b98f58f85-5lt9h-2.txt
nginx-7b98f58f85-5lt9h-3.txt
nginx-7b98f58f85-5lt9h-4.txt
nginx-7b98f58f85-5lt9h-5.txt
nginx-7b98f58f85-5lt9h-6.txt
nginx-7b98f58f85-5lt9h-7.txt
nginx-7b98f58f85-5lt9h-8.txt
nginx-7b98f58f85-5lt9h-9.txt
nginx-7b98f58f85-jrzn6-1.txt
nginx-7b98f58f85-jrzn6-10.txt
nginx-7b98f58f85-jrzn6-2.txt
nginx-7b98f58f85-jrzn6-3.txt
nginx-7b98f58f85-jrzn6-4.txt
nginx-7b98f58f85-jrzn6-5.txt
nginx-7b98f58f85-jrzn6-6.txt
nginx-7b98f58f85-jrzn6-7.txt
nginx-7b98f58f85-jrzn6-8.txt
nginx-7b98f58f85-jrzn6-9.txt
nginx-7b98f58f85-ph4cz-1.txt
nginx-7b98f58f85-ph4cz-10.txt
nginx-7b98f58f85-ph4cz-2.txt
nginx-7b98f58f85-ph4cz-3.txt
nginx-7b98f58f85-ph4cz-4.txt
nginx-7b98f58f85-ph4cz-5.txt
nginx-7b98f58f85-ph4cz-6.txt
nginx-7b98f58f85-ph4cz-7.txt
nginx-7b98f58f85-ph4cz-8.txt
nginx-7b98f58f85-ph4cz-9.txt

# What if I delete everything?
#
k delete deployments.apps nginx
deployment.apps "nginx" deleted from default namespace
#
k delete pvc prgs-control-plane-pvc
persistentvolumeclaim "prgs-control-plane-pvc" deleted from default namespace

# Listing directly from Worker
# The data is still there, due to the rule (Policy Retain)
#
docker exec prgs-control-plane bash -c "ls /var/local-path-provisioner/pvc-25c56de4-a766-4d72-9ecf-566c0074cbfd_default_prgs-control-plane-pvc"
nginx-7b98f58f85-5lt9h-1.txt
nginx-7b98f58f85-5lt9h-10.txt
...
...
nginx-7b98f58f85-jrzn6-1.txt
nginx-7b98f58f85-jrzn6-10.txt
...
...
nginx-7b98f58f85-ph4cz-1.txt
nginx-7b98f58f85-ph4cz-10.txt
...
...

# If I no longer have a PVC, but the data is physically mounted on this Worker
# with this NAME ( pvc-25c56de4-a766-4d72-9ecf-566c0074cbfd_default_prgs-control-plane-pvc ).
# How would I mount this PVC again?
#
# NOTE:
# NOTE: THIS IS ONLY POSSIBLE BECAUSE WHEN DELETING THE PVC, THE PV IS KEPT
# NOTE:

k get pv
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS     CLAIM                            STORAGECLASS         VOLUMEATTRIBUTESCLASS   REASON   AGE
pvc-25c56de4-a766-4d72-9ecf-566c0074cbfd   10Mi       RWO            Retain           Released   default/prgs-control-plane-pvc   volume-persistente   <unset>                          9m45s

# Recreating the PVC by matching the existing PV
#
# Note:
# The PV ID was defined in the PVC

cat <<EOF | k apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: prgs-control-plane-pvc
spec:
  storageClassName: "volume-persistente"
  volumeName: pvc-25c56de4-a766-4d72-9ecf-566c0074cbfd
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 10Mi
EOF

# List PVC
k get pvc
NAME                     STATUS    VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS         VOLUMEATTRIBUTESCLASS   AGE
prgs-control-plane-pvc   Pending   pvc-25c56de4-a766-4d72-9ecf-566c0074cbfd   0                         volume-persistente   <unset>                 9s

# Notes:
# If the PV is mounted on a specific node, it is better to define an affinity rule when mounting the deployment.

cat <<EOF | k apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx
  name: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: kubernetes.io/hostname
                operator: In
                values:
                - prgs-control-plane
      containers:
        - image: nginx
          name: nginx
          volumeMounts:
          - name: data
            mountPath: "/data"
      volumes:
        - name: data
          persistentVolumeClaim:
            claimName: prgs-control-plane-pvc
EOF

# Notes:
# Listing the Pod...
# Nothing went up!!!
#
NAME                     READY   STATUS    RESTARTS   AGE
nginx-6767449f59-2jhlp   0/1     Pending   0          2s
nginx-6767449f59-8blp8   0/1     Pending   0          2s
nginx-6767449f59-hrxn8   0/1     Pending   0          2s

# This happens because the PV is still linked to the old PVC that died
# The fact that the Status is (Released) points to this characteristic.
#
k get pv
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS     CLAIM                            STORAGECLASS         VOLUMEATTRIBUTESCLASS   REASON   AGE
pvc-25c56de4-a766-4d72-9ecf-566c0074cbfd   10Mi       RWO            Retain           Released   default/prgs-control-plane-pvc   volume-persistente   <unset>                          25m

# ---------------------- Hard Core -------------------------
# Another solution would be to do static provisioning.
# I define storageClass as ""
# I point out which pv I want to use using the volumeName object
#
# Another alternative would be to edit the PV and remove the ID linked to the PV
# Ex: Remove entry ( claimRef => uid: 0e436051-7441-42d5-83d9-3a8362ee0d34 )
# ---------------------------------------------------------

# Apply patch ...
# Notes.:
kubectl patch pv pvc-25c56de4-a766-4d72-9ecf-566c0074cbfd -p '{"spec":{"claimRef": null}}'

k delete deployments.apps nginx
k delete pvc prgs-control-plane-pvc

# Apply PVC again
cat <<EOF | k apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: prgs-control-plane-pvc
spec:
  storageClassName: "volume-persistente"
  volumeName: pvc-25c56de4-a766-4d72-9ecf-566c0074cbfd
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 10Mi
EOF

pods=$(k get pods -o=jsonpath='{range .items..metadata}{.name}{"\n"}{end}')

while IFS= read -r pod;
do
  k exec $pod -- bash -c "ls /data"
  echo "-------------------"
done <<< "$pods"


# Can mount and read data normally. This is because when creating the PVC it ​​was defined ( persistentVolumeReclaimPolicy: Retain )

nginx-7b98f58f85-4trx6-1.txt
...
...
nginx-7b98f58f85-4trx6-10.txt
-------------------
nginx-7b98f58f85-4trx6-1.txt
...
...
nginx-7b98f58f85-4trx6-10.txt
-------------------
nginx-7b98f58f85-4trx6-1.txt
...
...
nginx-7b98f58f85-4trx6-10.txt
-------------------

#================================= PV Policy Retain =================================
#
# I created StorageClass with Policy Retain, but killed the PV
# How is it?
#
k delete deployments.apps nginx
deployment.apps "nginx" deleted from default namespace

k delete pvc prgs-control-plane-pvc
persistentvolumeclaim "prgs-control-plane-pvc" deleted from default namespace

k delete pv pvc-25c56de4-a766-4d72-9ecf-566c0074cbfd
persistentvolume "pvc-25c56de4-a766-4d72-9ecf-566c0074cbfd" deleted

# My volume is orphaned
#
# However, the data still exists in my cluster
docker exec prgs-control-plane bash -c "ls /var/local-path-provisioner/pvc-25c56de4-a766-4d72-9ecf-566c0074cbfd_default_prgs-control-plane-pvc"
nginx-7b98f58f85-5lt9h-1.txt
nginx-7b98f58f85-5lt9h-10.txt
nginx-7b98f58f85-5lt9h-2.txt
nginx-7b98f58f85-5lt9h-3.txt
nginx-7b98f58f85-5lt9h-4.txt
nginx-7b98f58f85-5lt9h-5.txt
nginx-7b98f58f85-5lt9h-6.txt
nginx-7b98f58f85-5lt9h-7.txt
nginx-7b98f58f85-5lt9h-8.txt
nginx-7b98f58f85-5lt9h-9.txt
nginx-7b98f58f85-jrzn6-1.txt
nginx-7b98f58f85-jrzn6-10.txt
nginx-7b98f58f85-jrzn6-2.txt
nginx-7b98f58f85-jrzn6-3.txt
nginx-7b98f58f85-jrzn6-4.txt
nginx-7b98f58f85-jrzn6-5.txt
nginx-7b98f58f85-jrzn6-6.txt
nginx-7b98f58f85-jrzn6-7.txt
nginx-7b98f58f85-jrzn6-8.txt
nginx-7b98f58f85-jrzn6-9.txt
nginx-7b98f58f85-ph4cz-1.txt
nginx-7b98f58f85-ph4cz-10.txt
nginx-7b98f58f85-ph4cz-2.txt
nginx-7b98f58f85-ph4cz-3.txt
nginx-7b98f58f85-ph4cz-4.txt
nginx-7b98f58f85-ph4cz-5.txt
nginx-7b98f58f85-ph4cz-6.txt
nginx-7b98f58f85-ph4cz-7.txt
nginx-7b98f58f85-ph4cz-8.txt
nginx-7b98f58f85-ph4cz-9.txt

# The process of recovering an orphaned PV is manual.
#
# Creating PV
#
cat <<EOF | k apply -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-recuperado
spec:
  capacity:
    storage: 10Mi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: ""
  local:
    path: /var/local-path-provisioner/pvc-25c56de4-a766-4d72-9ecf-566c0074cbfd_default_prgs-control-plane-pvc
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - prgs-control-plane
EOF

# Creating PVC
#
cat <<EOF | k apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-recuperado
spec:
  volumeName: pv-recuperado
  storageClassName: ""
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Mi
EOF

# Listing PVC
k get pvc
NAME             STATUS    VOLUME          CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
pvc-recuperado   Pending   pv-recuperado   0                                        <unset>                 3s

# Creating App
cat <<EOF | k apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx
  name: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: kubernetes.io/hostname
                operator: In
                values:
                - prgs-control-plane
      containers:
        - image: nginx
          name: nginx
          volumeMounts:
          - name: data
            mountPath: "/data"
      volumes:
        - name: data
          persistentVolumeClaim:
            claimName: pvc-recuperado
EOF

k get pvc
NAME             STATUS   VOLUME          CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
pvc-recuperado   Bound    pv-recuperado   10Mi       RWO                           <unset>                 81s

# Listing content
#
pods=$(k get pods -o=jsonpath='{range .items..metadata}{.name}{"\n"}{end}')

while IFS= read -r pod;
do
  k exec $pod -- bash -c "ls /data"
  echo "-------------------"
done <<< "$pods"

# Can mount and read data normally. This is because when creating the PVC it ​​was defined ( persistentVolumeReclaimPolicy: Retain )

nginx-7b98f58f85-4trx6-1.txt
...
...
nginx-7b98f58f85-4trx6-10.txt
-------------------
nginx-7b98f58f85-4trx6-1.txt
...
...
nginx-7b98f58f85-4trx6-10.txt
-------------------
nginx-7b98f58f85-4trx6-1.txt
...
...
nginx-7b98f58f85-4trx6-10.txt
-------------------

```

[Menu](#-menu)

# 🚀 Create Object - HPA / VPA

```bash
#
# Vertical Scale X Horizontal Scale (Components that monitor resources)
#
#================================ Horizontal (HPA) =================================
#
# Deployment => ReplicaSet => Pod
#
# In Deployment we inject a new object called HPA, it will listen to some metrics (CPU /RAM),
# but you can use external metrics and once this threshold hits the defined limit, the HPA will scale the PODS.
#

https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/

https://kubernetes.io/docs/reference/command-line-tools-reference/kube-controller-manager/

# At start in kube-controller there are parameters listed in the link above that define HPA behaviors
# Ex: --horizontal-pod-autoscale-xxxx
#
# In managed environments, you will hardly adjust these behaviors as you have no control over the control plane.
#
# How does HPA collect metrics?

https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/#support-for-resource-metrics

✅ Custom Metrics (CPU-based Scalar)
✅ APi Metrics (Collects metrics from a Prometheus)
✅ Scaling based on request, SQS queue.. etc

# NOTE:
# I need metrics-server deployed on the cluster
#
# CPU-based Metric Server
metrics.k8s.io API

# Custom Metrics / How metrics are collected?
custom.metrics.k8s.io API.
external.metrics.k8s.io API.

# Resources consumed by the Node
k top nodes
NAME                 CPU(cores)   CPU(%)   MEMORY(bytes)   MEMORY(%)
prgs-control-plane   532m         4%       1570Mi          10%

# Resources consumed by Pods
k top pods -A
NAMESPACE            NAME                                                        CPU(cores)   MEMORY(bytes)
argocd               argo-cd-argocd-application-controller-0                     1m           28Mi
argocd               argo-cd-argocd-applicationset-controller-65f795bdf4-m4gdv   1m           28Mi
argocd               argo-cd-argocd-dex-server-76c9c5f56b-6lhdd                  1m           82Mi
argocd               argo-cd-argocd-notifications-controller-7d746d6f96-5vt4k    1m           22Mi
argocd               argo-cd-argocd-redis-9c859c655-qlm2v                        14m          5Mi
argocd               argo-cd-argocd-repo-server-6d9f79976f-9rcg7                 2m           24Mi
argocd               argo-cd-argocd-server-66b994c4fd-zrc8q                      1m           32Mi
argocd               gateway-nginx-8445d7855-9w4cw                               48m          42Mi
kube-system          coredns-66bc5c9577-25kt8                                    4m           15Mi
kube-system          coredns-66bc5c9577-5t6ts                                    4m           15Mi
kube-system          etcd-prgs-control-plane                                     59m          79Mi
kube-system          kindnet-hxn6z                                               2m           11Mi
kube-system          kube-apiserver-prgs-control-plane                           160m         542Mi
kube-system          kube-controller-manager-prgs-control-plane                  30m          77Mi
kube-system          kube-proxy-4l5fz                                            5m           15Mi
kube-system          kube-scheduler-prgs-control-plane                           18m          23Mi
kube-system          metrics-server-fcf6b4bd6-8wnrl                              7m           19Mi
local-path-storage   local-path-provisioner-7b8c8ddbd6-jq7td                     1m           7Mi
metallb-system       metallb-controller-765c495b75-2wsxx                         4m           32Mi
metallb-system       metallb-speaker-cjct8                                       10m          51Mi
nginx-gateway        ngf-nginx-gateway-fabric-c98866d6f-h4fpw                    20m          36Mi

cat <<EOF | k apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx
  name: nginx
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - image: nginx
        name: nginx
        resources:
          requests:
            cpu: 10m
          limits:
            cpu: 15m
---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: nginx
  name: nginx
spec:
  ports:
  - name: nginx-service
    port: 80
    protocol: TCP
    targetPort: 80
  selector:
    app: nginx
  type: ClusterIP
EOF


# ==========================================================================
# Note:
#
# Request is always used when a pod is placed inside a node.
# It is taken into account when choosing the node where the pod will be placed.
# Kube-schedules decides which worker my pod will run on, it evaluates the resources.
# ==========================================================================
# Note:
#
# The secret is to declare the resources in the deployment
# What HPA takes into account is ( request ).
# Limits is used to define the maximum amount of CPU /RAM used by a POd (hard limit)
# The HPA does not consult the limits to make scaling decisions.
# The scheduler's decision to start a new Pod takes place through the request metric.

k explain horizontalpodautoscalers.spec
k explain horizontalpodautoscalers.spec.metrics.resource.target
k explain horizontalpodautoscalers.spec | grep required
maxReplicas	<integer> -required-
scaleTargetRef	<CrossVersionObjectReference> -required-

# A namespace resource
k api-resources | grep hpa
horizontalpodautoscalers            hpa                               autoscaling/v2                    true         HorizontalPodAutoscaler

k neat <<< $(k autoscale deployment nginx --cpu=50 --min=1 --max=5 --dry-run=client -o yaml)

# HPA (Based on CPU millicore)
# When workloads vary greatly
# Requires absolute CPU control

cat <<EOF | k apply -f -
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: nginx
spec:
  maxReplicas: 5
  minReplicas: 1
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: nginx
  metrics:
  - resource:
      name: cpu
      target:
        averageValue: 10m
        type: AverageValue
    type: Resource
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 30
      policies:
      - type: Percent
        value: 100
        periodSeconds: 15
EOF

# HPA output when using Milicore-based rules
k get hpa
NAME    REFERENCE          TARGETS      MINPODS   MAXPODS   REPLICAS   AGE
nginx   Deployment/nginx   cpu: 0/10m   1         5         1          51m


# HPA (Based on % CPU Usage)
#
# When well defined requests.cpu
# In the vast majority of workloads (APIs, web, microservices)

cat <<EOF | k apply -f -
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: nginx
spec:
  maxReplicas: 5
  minReplicas: 1
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: nginx
  metrics:
  - resource:
      name: cpu
      target:
        averageUtilization: 50
        type: Utilization
    type: Resource
EOF

k get hpa
NAME    REFERENCE          TARGETS       MINPODS   MAXPODS   REPLICAS   AGE
nginx   Deployment/nginx   cpu: 0%/50%   1         5         1          16s

k describe hpa nginx

# Validating process
# Monitor HPA
k get hpa -w
nginx   Deployment/nginx   cpu: 0%/50%     1         5         1          114s

nginx   Deployment/nginx   cpu: 20%/50%    1         5         1          5m1s
nginx   Deployment/nginx   cpu: 200%/50%   1         5         1          5m31s
nginx   Deployment/nginx   cpu: 200%/50%   1         5         4          5m46s
nginx   Deployment/nginx   cpu: 110%/50%   1         5         4          6m1s

# Generating Stress load in Nginx
k run --image alpine --rm -it teste-curl sh
apk add curl
while true; do curl -I nginx; done

# Vendo os Pods sendo criados.
k get pods
nginx-7577f95fd6-2zqjb   0/1     ContainerCreating   0          5s
nginx-7577f95fd6-hdmbf   0/1     ContainerCreating   0          5s
nginx-7577f95fd6-sl8fh   1/1     Running             0          30m
nginx-7577f95fd6-vhn74   0/1     ContainerCreating   0          5s

# After ending the Stress load, the Pods must assume the default deployment value.
# Even with low CPU, it “holds” the pods for a few minutes before killing

k get pods
NAME                     READY   STATUS        RESTARTS   AGE
nginx-7577f95fd6-2zqjb   1/1     Terminating   0          6m32s
nginx-7577f95fd6-8kx5t   1/1     Terminating   0          5m47s
nginx-7577f95fd6-hdmbf   1/1     Terminating   0          6m32s
nginx-7577f95fd6-sl8fh   1/1     Running       0          36m
nginx-7577f95fd6-vhn74   1/1     Terminating   0          6m32s
teste-curl               1/1     Running       0          7m50s

# How to make scale down faster.
# Adding the Block below to the manifest...

  behavior:
    scaleDown:
      stabilizationWindowSeconds: 30
      policies:
      - type: Percent
        value: 100
        periodSeconds: 15

# Ex:
cat <<EOF | k apply -f -
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: nginx
spec:
  maxReplicas: 5
  minReplicas: 1
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: nginx
  metrics:
  - resource:
      name: cpu
      target:
        averageUtilization: 50
        type: Utilization
    type: Resource
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 30
      policies:
      - type: Percent
        value: 100
        periodSeconds: 15
EOF

#*************************** Extending or calculating HPA *****************************
#

https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/#algorithm-details

# ceil => Rounding function (Golang)

# Formula to determine the number of replicas to handle requests.
# It will calculate the number of desired replicas
#
# currentReplicas => Replicas defined in deployment
# desiredMetricValue => HPA averageUtilization
# currentMetricValue => Usage/Desired This is calculated based on request limits ( requests => cpu: 10m )
k get hpa
NAME        REFERENCE          TARGETS       MINPODS   MAXPODS   REPLICAS   AGE
nginx    Deployment/nginx    cpu: 0%/50%       1         5         1        105m

# Ex:
# If my app needs 10m (milli core or millicpu), but at the moment it has no use and the pod is consuming 3m of cpu.
# Therefore, 10m was defined for this POD. This is the maximum and as if it were the hard limit.
# This 10m is the request because it is in this field that the HPA operates.
#
k top pods
NAME                     CPU(cores)   MEMORY(bytes)
nginx-7577f95fd6-sl8fh   0m           10Mi

# Let's imagine that you defined this in your HPA
# Out of nowhere your Pod starts using 12m cpu, this means that 12m is greater than 10m which is greater than 100%
# OS 10m represents the total CPU tolerated by the HPA (it represents 100%)

- resource:
    name: cpu
    target:
      averageValue: 10m
      type: AverageValue
  type: Resource

# Pods working without overhead
k get hpa
NAME    REFERENCE          TARGETS      MINPODS   MAXPODS   REPLICAS   AGE
nginx   Deployment/nginx   cpu: 0/10m   1         5         1          73m

# Pods working with overload
k get hpa
nginx   Deployment/nginx   cpu: 10m/10m   1         5         4          69m

# Regra de 3
10m -- 100%
32m -- x
10x = 3200
x = 320%

# So I can say that the request defined in the manifest (10m is equivalent to 100%)
# This value will be the attribute used to calculate the HPA.
# But with Pods consuming 32m has it consumed 320% of the defined cpu?

desiredReplicas = ceil[currentReplicas * ( currentMetricValue / desiredMetricValue )]

desiredReplicas = ceil[1 * ( X / 50 )]

desiredReplicas = ceil[1 * ( 320 / 60 )]

desiredReplicas = ceil[1  * ( 5.3 )]

desiredReplicas = 6

# Doing it in practice
watch kubectl top pod nginx-599d9c6bc5-twzk8
NAME                     CPU(cores)   MEMORY(bytes)
nginx-599d9c6bc5-twzk8   58m           3Mi

# Suppose that
# 58m => Rule of 3 (That means almost 580%)

desiredReplicas = ceil[1 * ( 580 / 60 )]

desiredReplicas = ceil[1 * ( 9.666 )]

desiredReplicas = 10

# Therefore, the desired value to meet this demand would be 10 Replicas.
# If any pod is working with more than 10m cpu HPA will provision more nodes.

k get hpa -w
NAME        REFERENCE          TARGETS       MINPODS   MAXPODS   REPLICAS   AGE
nginx-hpa   Deployment/nginx   cpu: 0%/60%     1         50        1          92s
nginx-hpa   Deployment/nginx   cpu: 580%/60%   1         50        1          5m16s
nginx-hpa   Deployment/nginx   cpu: 23%/60%    1         50        10          11m
nginx-hpa   Deployment/nginx   cpu: 1%/60%     1         50        10          11m
nginx-hpa   Deployment/nginx   cpu: 0%/60%     1         50        10          12m

https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/#default-behavior

# Stabillization window, defines how kubernetes descales pods (This is punk for him)
# used to scale down.
#
# Standard (300s /5 minutes)

k explain hpa.spec
k explain hpa.spec.behavior
k explain hpa.spec.behavior.scaleDown
k explain hpa.spec.behavior.scaleDown.stabilizationWindowSeconds


#================================= Vertical (VPA) ===================================
#
# Deployment => ReplicaSet => Pod
# NOTE: VPA will only work on deployments that have at least 2 replicas
# What behavior?
#
# It kills one of the pods, the new Pod when created will be intercepted by the VPA which will adjust the request limits with
# a value defined in the VPA (required resources) and then the Pod goes up.
#
# Monolith Applications is a good use case for VPA
# Just like HPA, VPA takes request limits into account.
#
#
# VPA is not automatically deployed

https://github.com/kubernetes/autoscaler

# NOTE: Checkout the last stable tag
#
# VPA acts on events
#
# cluster-autoscaler is used by cloud providers to scale nodes
#
# Deploy Manual
git clone https://github.com/kubernetes/autoscaler.git
git checkout vertical-pod-autoscaler-1.32.7
cd vertical-pod-autoscaler/
./hack/vpa-up.sh

# Deploy Helm
helm repo add fairwinds-stable https://charts.fairwinds.com/stable
helm repo update
helm install vertical-pod-autoscaler fairwinds-stable/vpa \
  --namespace vertical-pod-autoscaler \
  --create-namespace \
  --wait

# Check
k describe pods -n vertical-pod-autoscaler vertical-pod-autoscaler-vpa-admission-controller-7f4667b6fszspr

# How does VPA work?
# It intercepts the creation of the POD and dynamically adjusts the request limits, note that it acts at the Pod level.
# It uses this Webhook feature to manage this.

k get mutatingwebhookconfigurations
NAME                                         WEBHOOKS   AGE
vertical-pod-autoscaler-vpa-webhook-config   1          3m18s

# Yaml
k get mutatingwebhookconfigurations vertical-pod-autoscaler-vpa-webhook-config -o yaml

# Actions that this mutatingweebhook will trigger.
# -Any create call on the POds resource. Whenever a pod is created, it will fall into this Hook
# -Whenever you update or create a VPA
#
# What does he do?
#
# It takes the request and sends it to your service (HPA Webhook)

  service:
      name: vertical-pod-autoscaler-vpa-webhook
      namespace: vertical-pod-autoscaler
      port: 443

k get svc -n vertical-pod-autoscaler

# What is behind this service?
k get endpointslices.discovery.k8s.io -n vertical-pod-autoscaler
NAME                                        ADDRESSTYPE   PORTS   ENDPOINTS     AGE
vertical-pod-autoscaler-vpa-webhook-r59kl   IPv4          8000    10.244.0.23   8m42s

# Who is this POd ( 10.244.0.23 )?
k get pods -A -o wide | grep 10.244.0.23
vertical-pod-autoscaler   vertical-pod-autoscaler-vpa-admission-controller-7f4667b6fszspr   1/1     Running   0          9m56s   10.244.0.23

# Note:
#
✔️ Vertical Pod Autoscaler calculates new requests
✔️ It can recreate the pod to apply these values
✔️ It uses the Target value, not the YAML manifest

# Who defines the final value?
#
👉 He is the VPA recommender
👉 Ele calcula:

Target:
  cpu: 350m
  memory: ~335Mi

# EvictedPod ... to apply resource recommendation
👉 This means:

✔️ VPA calculated
✔️ VPA decided
✔️ VPA killed the pod
✔️ VPA applied new requests

💥 VPA DOES NOT react directly to OOM

❌ it doesn’t say “it went OOM → goes up to 1GB”
✅ says “average usage indicates you need ~335Mi”

#********************************* VPA Na prática ***********************************
#
cat <<EOF | k apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: stress
  name: stress
spec:
  replicas: 3
  selector:
    matchLabels:
      app: stress
  template:
    metadata:
      labels:
        app: stress
    spec:
      containers:
      - name: stress
        image: alpine
        command: [ "/bin/sh", "-c", "--" ]
        args: [ "while true; do echo Running...; sleep 30; done;" ]
        resources:
          requests:
            cpu: 200m
            memory: 200M
          limits:
            cpu: 200m
            memory: 200M
EOF

# Check recurso
pod=$(k get pods -o=jsonpath='{range .items..metadata}{.name}{"\n"}{end}' | grep '^stress-')

while read i;
do
  k get pods ${i} -o yaml | egrep 'cpu|memory'
  echo "---"
done <<< ${pod}

...
---
...
---
        cpu: 200m
        memory: 200M
        cpu: 200m
        memory: 200M
      cpu: 200m
      memory: 200M
        cpu: 200m
        memory: 200M
        cpu: 200m
        memory: 200M

# Monitor Pod Events live
# This feature will not notify the creation of Pods for this laboratory.
# Observe that after creating the Pods above, there will be no create action.
k get events --sort-by=.lastTimestamp -w
...
...
...

# Check consumo do Pod
watch kubectl top pod -l app=stress
NAME                     CPU(cores)   MEMORY(bytes)
stress-59788cbb7-6f9xs   1m           0Mi
stress-59788cbb7-8lht5   0m           0Mi
stress-59788cbb7-jxc7v   0m           0Mi

# Appply VPA
cat <<EOF | k apply -f -
apiVersion: "autoscaling.k8s.io/v1"
kind: VerticalPodAutoscaler
metadata:
  name: stress-vpa
spec:
  targetRef:
    apiVersion: "apps/v1"
    kind: Deployment
    name: stress
  updatePolicy:
    updateMode: "Recreate"
  resourcePolicy:
    containerPolicies:
      - containerName: "*"
        minAllowed:
          cpu: 200m
          memory: 200Mi
        maxAllowed:
          cpu: 600m
          memory: 600Mi
        controlledResources: ["cpu", "memory"]
EOF

k get vpa
NAME         MODE       CPU    MEM     PROVIDED   AGE
stress-vpa   Recreate   200m   200Mi   True       14s

# After applying VPA, PODs were intercepted and recreated.
# As I have 3 Pods, I did this one for each Pod.
k get events --sort-by=.lastTimestamp -w

0s          Normal   Killing                   pod/stress-59788cbb7-8lht5            Stopping container stress
0s          Normal   EvictedByVPA              pod/stress-59788cbb7-8lht5            Pod was evicted by VPA Updater to apply resource recommendation.
0s          Normal   EvictedPod                verticalpodautoscaler/stress-vpa      VPA Updater evicted Pod stress-59788cbb7-8lht5 to apply resource recommendation.
0s          Normal   SuccessfulCreate          replicaset/stress-59788cbb7           Created pod: stress-59788cbb7-dl2xv
0s          Normal   Scheduled                 pod/stress-59788cbb7-dl2xv            Successfully assigned default/stress-59788cbb7-dl2xv to prgs-control-plane
0s          Normal   Pulling                   pod/stress-59788cbb7-dl2xv            Pulling image "alpine"
0s          Normal   Pulled                    pod/stress-59788cbb7-dl2xv            Successfully pulled image "alpine" in 1.241s (1.241s including waiting). Image size: 3875040 bytes.
0s          Normal   Created                   pod/stress-59788cbb7-dl2xv            Created container: stress
0s          Normal   Started                   pod/stress-59788cbb7-dl2xv            Started container stress
0s          Normal   Killing                   pod/stress-59788cbb7-jxc7v            Stopping container stress
0s          Normal   EvictedByVPA              pod/stress-59788cbb7-jxc7v            Pod was evicted by VPA Updater to apply resource recommendation.
0s          Normal   SuccessfulCreate          replicaset/stress-59788cbb7           Created pod: stress-59788cbb7-zdrzw
0s          Normal   Scheduled                 pod/stress-59788cbb7-zdrzw            Successfully assigned default/stress-59788cbb7-zdrzw to prgs-control-plane
0s          Normal   EvictedPod                verticalpodautoscaler/stress-vpa      VPA Updater evicted Pod stress-59788cbb7-jxc7v to apply resource recommendation.
0s          Normal   Pulling                   pod/stress-59788cbb7-zdrzw            Pulling image "alpine"
0s          Normal   Pulled                    pod/stress-59788cbb7-zdrzw            Successfully pulled image "alpine" in 1.185s (1.185s including waiting). Image size: 3875040 bytes.
0s          Normal   Created                   pod/stress-59788cbb7-zdrzw            Created container: stress
0s          Normal   Started                   pod/stress-59788cbb7-zdrzw            Started container stress
0s          Normal   EvictedByVPA              pod/stress-59788cbb7-6f9xs            Pod was evicted by VPA Updater to apply resource recommendation.
0s          Normal   Killing                   pod/stress-59788cbb7-6f9xs            Stopping container stress
0s          Normal   EvictedPod                verticalpodautoscaler/stress-vpa      VPA Updater evicted Pod stress-59788cbb7-6f9xs to apply resource recommendation.
0s          Normal   SuccessfulCreate          replicaset/stress-59788cbb7           Created pod: stress-59788cbb7-wptm6
0s          Normal   Scheduled                 pod/stress-59788cbb7-wptm6            Successfully assigned default/stress-59788cbb7-wptm6 to prgs-control-plane
0s          Normal   Pulling                   pod/stress-59788cbb7-wptm6            Pulling image "alpine"
0s          Normal   Pulled                    pod/stress-59788cbb7-wptm6            Successfully pulled image "alpine" in 1.232s (1.232s including waiting). Image size: 3875040 bytes.
0s          Normal   Created                   pod/stress-59788cbb7-wptm6            Created container: stress
0s          Normal   Started                   pod/stress-59788cbb7-wptm6            Started container stress


# Because He Killed the Pros and Created Them
# The Recommendation field dictates the rules of the VPA game
k describe vpa stress-vpa

Status:
  Conditions:
    Last Transition Time:  2026-05-11T09:06:33Z
    Status:                True
    Type:                  RecommendationProvided
  Recommendation:
    Container Recommendations:
      Container Name:  stress
      Lower Bound:
        Cpu:     200m
        Memory:  200Mi
      Target:
        Cpu:     200m
        Memory:  200Mi
      Uncapped Target:
        Cpu:     15m
        Memory:  100Mi
      Upper Bound:
        Cpu:     600m
        Memory:  600Mi
Events:
  Type    Reason      Age   From         Message
  ----    ------      ----  ----         -------
  Normal  EvictedPod  13m   vpa-updater  VPA Updater evicted Pod stress-59788cbb7-8lht5 to apply resource recommendation.
  Normal  EvictedPod  12m   vpa-updater  VPA Updater evicted Pod stress-59788cbb7-jxc7v to apply resource recommendation.
  Normal  EvictedPod  11m   vpa-updater  VPA Updater evicted Pod stress-59788cbb7-6f9xs to apply resource recommendation.


# Generating Stress Load
pod=$(k get pods -o=jsonpath='{range .items..metadata}{.name}{"\n"}{end}' | grep '^stress-')
while read i;
do
  echo "Connect Pod: $i"
  echo "--------"
  k exec ${i} -- sh -c "apk add stress-ng"
done <<< ${pod}

count=0
while read i;
do
  echo "Connect Pod: $i"
  echo "--------"
  [[ $count == 0 ]] && k exec ${i} -- sh -c 'for _ in $(seq 1 10); do stress-ng --vm 1 --vm-bytes 200M --timeout 300; sleep 10; done'
  ((count++))
done <<< ${pod}


stress-59788cbb7-9c9sv   200m         66Mi
stress-59788cbb7-wptm6   1m           1Mi
stress-59788cbb7-zdrzw   1m           1Mi

# Note that the VPA has already changed the resource limits to the value it proposed.
k get pods stress-59788cbb7-9c9sv -o yaml | grep memo
    vpaUpdates: 'Pod resources updated by stress-vpa: container 0: cpu request, memory
      request, cpu limit, memory limit'
        memory: "380258472"
        memory: "380258472"
      memory: "380258472"
        memory: "380258472"
        memory: "380258472"

#********************************* VPA Nginx K6 ************************************
#
https://grafana.com/docs/k6/latest/

#
# Generating data load.
#
# Watching
watch -n 2 "kubectl get pod -l app=nginx -o wide"

k get events --sort-by=.lastTimestamp -w

# Running Stress
cat > script.js <<EOF
import http from 'k6/http';
import { sleep, check } from 'k6';

export const options = {
  vus: 50,
  duration: '10m',
};

export default function () {
  const res = http.get('http://172.17.0.241', {
    headers: {
      Host: 'nginx.prgs-corp.xyz',
    },
  });

  check(res, {
    'status 200': (r) => r.status === 200,
  });

  sleep(1);
}
EOF

k6 run --insecure-skip-tls-verify script.js

# Running Stress - Another form
k run --image alpine --rm -it teste-curl sh
apk add curl
while true; do curl -I nginx-service; done
```

[Menu](#-menu)

# 🚀 Create Object - CNI

```bash
# CNI is different between clusters (AWS /Azure)
# CNI is a specification of how the network should behave in a K8S cluster.
# This generates a great diversity of implementations, with each cloud provider having its own needs to be met.

# So this cannot be implemented by the k8s code core, but by the vendor that will deliver k8s as a service to you.

# A pod communicates with another pod regardless of which node it is running on, without using nat.
# A daemonset must have the ability to communicate directly with the pod.
# CNI is usually a daemonset that runs on each node in the cluster

k get pods -n kube-system -o wide | grep kindnet

kindnet-7npgk   1/1     Running   0          4h50m   172.17.0.2   prgs-control-plane  <none>           <none>

# Creating a Deployment and a Service
k create deployment --image=nginx nginx
k create service clusterip nginx --tcp=80:80

k get pods -o wide
NAME                     READY   STATUS    RESTARTS   AGE   IP            NODE                 NOMINATED NODE   READINESS GATES
nginx-66686b6766-xgt78   1/1     Running   0          71s   10.244.0.32   prgs-control-plane   <none>           <none>

# Listing the Interfaces on the Host
docker exec prgs-control-plane bash -c "ip a | grep veth"

3: veth82067b25@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    inet 10.244.0.1/32 scope global veth82067b25
4: veth05d59c24@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    inet 10.244.0.1/32 scope global veth05d59c24
5: veth8dec968f@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    inet 10.244.0.1/32 scope global veth8dec968f
6: veth448f4893@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    inet 10.244.0.1/32 scope global veth448f4893
7: vethc1917bac@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    inet 10.244.0.1/32 scope global vethc1917bac
9: veth6e5b38c2@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    inet 10.244.0.1/32 scope global veth6e5b38c2
13: vethcaab9ce8@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    inet 10.244.0.1/32 scope global vethcaab9ce8
14: vethadd1228f@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    inet 10.244.0.1/32 scope global vethadd1228f
15: vetheecc2fbe@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    inet 10.244.0.1/32 scope global vetheecc2fbe
16: veth4b1eb62f@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    inet 10.244.0.1/32 scope global veth4b1eb62f
17: veth7b54fa9c@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    inet 10.244.0.1/32 scope global veth7b54fa9c
18: vethc5cf1a50@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    inet 10.244.0.1/32 scope global vethc5cf1a50
19: veth7e71391f@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    inet 10.244.0.1/32 scope global veth7e71391f
20: veth312bf78b@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    inet 10.244.0.1/32 scope global veth312bf78b
22: veth18ec8eaf@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    inet 10.244.0.1/32 scope global veth18ec8eaf
23: vethc4ab357f@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    inet 10.244.0.1/32 scope global vethc4ab357f
24: veth297ec1ad@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    inet 10.244.0.1/32 scope global veth297ec1ad
33: veth8b8a115d@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    inet 10.244.0.1/32 scope global veth8b8a115d

# Why are so many network interfaces created on the Host? No Conflict?
👉 Because each pod needs its own "virtual network card".
👉 In Kubernetes, a pod does not share the node interface directly.
👉 Resource that is mapped to a Network namespace at the host kernel level (isolates the network).
👉 Then the kernel creates a veth pair:

[pod netns] eth0 <------> vethXXXX [node]

👉 It is literally a “virtual Ethernet cable”.
👉 one end is in the pod namespace, the other end is in the node.
👉 traffic enters one side and leaves the other
👉 edge of the interface on the node/container

# Do these same IPs NOT conflict?
👉 IP representa SOMENTE este endpoint.
👉 No /32 subnet

# Why does Linux allow the SAME IP on different interfaces?
👉 Are routes point-to-point
👉 used policy routing
👉 used namespaces
👉 or are used as internal CNI next-hop

# Ex:
inet 10.244.0.1/32 scope global vethXXXX

# In a practical way
pod A <-> veth A usa 10.244.0.1
pod B <-> veth B usa 10.244.0.1

pod1 ===== network private ===== node
pod2 ===== network private ===== node
pod3 ===== network private ===== node

👉 each pod needs its own TCP/IP stack
👉 network isolation
👉 independent firewall
👉 independent routing
👉 independent policy
👉 independent Observability

1 pod = 1 netns = 1 eth0 = 1 veth pair


#************************************ Debug CNI ************************************
#
# Tenho essa procissão de Network, qual delas atende meu Pod ( nginx-66686b6766-xgt78 )
k get pods -o wide
NAME                     READY   STATUS    RESTARTS   AGE   IP            NODE                 NOMINATED NODE   READINESS GATES
nginx-66686b6766-xgt78   1/1     Running   0          24h   10.244.0.32   prgs-control-plane   <none>           <none>



# Note:
# The 10.244.0.1/32 you saw is NOT the pod's IP.
# This is normally the IP of the bridge/route used by the CNI.
#
# Discover the other end of veth
docker exec prgs-control-plane bash -c "ip link"

1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: eth0@if93: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default
    link/ether 42:3f:a7:fb:a6:14 brd ff:ff:ff:ff:ff:ff link-netnsid 0
3: veth82067b25@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default qlen 1000
    link/ether d6:0f:81:f3:11:5c brd ff:ff:ff:ff:ff:ff link-netns cni-aa5c9c4e-2a72-db95-c2b8-ef261bf21dc2
4: veth05d59c24@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default qlen 1000
    link/ether 6e:9f:6a:ca:f4:92 brd ff:ff:ff:ff:ff:ff link-netns cni-d482bde7-f7dc-48db-a241-206b452dfe87
5: veth8dec968f@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default qlen 1000
    link/ether 9e:2e:df:9f:50:4a brd ff:ff:ff:ff:ff:ff link-netns cni-783c6c5f-fc7e-2fb7-8ff8-f6a86b644591
6: veth448f4893@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default qlen 1000
    link/ether 6e:4d:9d:c3:99:4f brd ff:ff:ff:ff:ff:ff link-netns cni-d0549ef8-4d61-2411-5185-f2c2beb295e8
7: vethc1917bac@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default qlen 1000
    link/ether 3e:69:81:60:4b:26 brd ff:ff:ff:ff:ff:ff link-netns cni-7b9aade6-626a-482a-e7c6-44efc1110c76
9: veth6e5b38c2@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default qlen 1000
    link/ether 9a:fe:97:44:b5:af brd ff:ff:ff:ff:ff:ff link-netns cni-d5f63792-1051-7cc6-40dc-d6ffa802ddb7
13: vethcaab9ce8@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default qlen 1000
    link/ether ae:ad:0c:28:45:41 brd ff:ff:ff:ff:ff:ff link-netns cni-3cfdf0b9-ab55-c3b1-5c37-e133367d520b
14: vethadd1228f@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default qlen 1000
    link/ether 8a:7f:2f:ef:55:4d brd ff:ff:ff:ff:ff:ff link-netns cni-6c883486-8117-2db6-6910-c72699ed300c
15: vetheecc2fbe@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default qlen 1000
    link/ether 9a:cc:3c:88:fe:1c brd ff:ff:ff:ff:ff:ff link-netns cni-56e61d8e-039b-6183-3498-ceb21891f258
16: veth4b1eb62f@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default qlen 1000
    link/ether 32:b6:46:2b:53:2b brd ff:ff:ff:ff:ff:ff link-netns cni-361eb0f7-88ad-d14f-b2d4-ce658215be6f
17: veth7b54fa9c@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default qlen 1000
    link/ether 22:73:10:37:38:e7 brd ff:ff:ff:ff:ff:ff link-netns cni-8c5a894e-b78d-313d-049a-9674c2d4fa46
18: vethc5cf1a50@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default qlen 1000
    link/ether 7a:e8:1f:e3:63:f1 brd ff:ff:ff:ff:ff:ff link-netns cni-5fb0d73c-d699-9927-f2f5-dd61b0895b12
19: veth7e71391f@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default qlen 1000
    link/ether aa:f7:79:65:12:ab brd ff:ff:ff:ff:ff:ff link-netns cni-4a174ced-70f0-df8f-e466-501e202e98d5
20: veth312bf78b@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default qlen 1000
    link/ether 3a:83:09:76:5f:6c brd ff:ff:ff:ff:ff:ff link-netns cni-8d7adb2a-3de1-cbe5-f166-9742d9abe86a
22: veth18ec8eaf@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default qlen 1000
    link/ether 7e:6c:60:b3:08:10 brd ff:ff:ff:ff:ff:ff link-netns cni-fe485a1a-cc55-357e-2c82-21f9a65d7eb6
23: vethc4ab357f@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default qlen 1000
    link/ether 6a:1a:73:13:fd:a7 brd ff:ff:ff:ff:ff:ff link-netns cni-a6898e03-71e5-be69-58d8-e30f3d83e6f9
24: veth297ec1ad@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default qlen 1000
    link/ether ae:ac:40:f1:be:93 brd ff:ff:ff:ff:ff:ff link-netns cni-3314b657-ac96-e965-b2e6-e60ed232c762
33: veth8b8a115d@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default qlen 1000
    link/ether 6a:7b:2e:1f:68:11 brd ff:ff:ff:ff:ff:ff link-netns cni-bab69db5-ed3d-ef0e-4aae-2c8fc10d3c25

# Ao ver essa informação ( veth82067b25@if2 ), esse @if2 significa que:
👉  the other end of the veth pair has Menu 2 within the pod namespace.
👉  It is necessary to go through CNI by CNI to know which interface is being served by the Pod.

# Inspect CNI ( cni-aa5c9c4e-2a72-db95-c2b8-ef261bf21dc2 )
# Ex:
docker exec prgs-control-plane bash -c "nsenter --net=/var/run/netns/cni-aa5c9c4e-2a72-db95-c2b8-ef261bf21dc2 ip link"

1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: eth0@if3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default qlen 1000
    link/ether 3a:ba:dd:52:a3:38 brd ff:ff:ff:ff:ff:ff link-netnsid 0

# What does this mean?
👉 host see if2
👉 pod  see if3

# NOtes:
#*********  How to identify which CNI is linked to my Pod and Service? *************
# NOtes:

# Export Variable
export cnis=$(docker exec prgs-control-plane bash -c "ip link | egrep -o 'cni-[a-z0-9-]+'")

# Print
docker exec prgs-control-plane bash -c "printf '%s\n' \"${cnis}\""

# nsenter default output
2: eth0@if33: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000 link-netnsid 0
    inet 10.244.0.32/24 brd 10.244.0.255 scope global eth0
       valid_lft forever preferred_lft forever

# Regex
# (?<=inet\s)\d+(\.\d+){3}
# (?<=...) → lookbehind Positive ( I look back )
# inet     → tliteral text matches inet keyword
# \s       → a blank space
# I got IPV4 after this match
# Ex:
# 10.244.0.32 => Ip do Pod ( Nginx )

while read -r cni;
do
  match=$(docker exec prgs-control-plane bash -c "nsenter --net=/var/run/netns/${cni} ip -4 addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}'")
  [[ ${match} == "10.244.0.32" ]] && echo "${cni} - ${match}"
done <<< ${cnis}

# So the CNI that is serving the Nginx Pod is...
cni-bab69db5-ed3d-ef0e-4aae-2c8fc10d3c25 - 10.244.0.32
```

[Menu](#-menu)

# 🚀 Create Object - DNS

```bash
# Kube-DNS resolv Name
k get svc -n kube-system
NAME             TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                  AGE
kube-dns         ClusterIP   10.96.0.10      <none>        53/UDP,53/TCP,9153/TCP   78m
metrics-server   ClusterIP   10.108.129.79   <none>        443/TCP                  73m

# Creating a Deployment and a Servicee
k create deployment --image=nginx nginx
k create service clusterip nginx --tcp=80:80

pod=$(k get pods -o=jsonpath='{range .items..metadata}{.name}{"\n"}{end}')
k exec -it $pod -- bash -c "cat /etc/resolv.conf"

search default.svc.cluster.local svc.cluster.local cluster.local
nameserver 10.96.0.10
options ndots:5

# Who generates this resolv.conf?
# The kubelet itself

👉 Search => Defines the automatic search domains.
nginx.default.svc.cluster.local
nginx.svc.cluster.local
nginx.cluster.local

👉 Nameserver => Ip do servidor.
👉 options    => ndots:5

# It controls when a name is considered “absolute” (FQDN) or “relative”.
# If the hostname has LESS than 5 dots (.), the resolver will try to apply the search domains.
# Ex:
# curl google.com
# Will try to resolve...
# google.com.default.svc.cluster.local
# google.com.svc.cluster.local
# google.com.cluster.local
# Try this before trying this...
# google.com

# These are the Pods that will respond to these requests
k get endpoints -n kube-system kube-dns
NAME       ENDPOINTS                                               AGE
kube-dns   10.244.0.2:53,10.244.0.4:53,10.244.0.2:53 + 3 more...   14m

k get pods -n kube-system -o wide | grep coredns
coredns-66bc5c9577-9wjg7                     1/1     Running   0          15m   10.244.0.2   prgs-control-plane   <none>           <none>
coredns-66bc5c9577-t4k6n                     1/1     Running   0          15m   10.244.0.4   prgs-control-plane   <none>           <none>

# Monitoring the Logs
dns=$(k get pods -n kube-system -o=jsonpath='{range .items..metadata}{.name}{"\n"}{end}' | grep '^coredns-')

while true;
do
  while read i;
  do
    k logs -n kube-system ${i}
    echo "---"
  done <<< ${dns}
  sleep 3
done

pod=$(k get pods -o=jsonpath='{range .items..metadata}{.name}{"\n"}{end}')
k exec -it $pod -- bash -c "curl nginx"

# Note that the kube-system Logs do not include Name resolution
# How to Activate /Enable (Logs and Debug)?

k get cm -n kube-system coredns
k get cm -n kube-system coredns -o yaml
k edit cm -n kube-system coredns -o yaml

apiVersion: v1
data:
  Corefile: |
    .:53 {
        log
        debug
        errors
        health {
           lameduck 5s
        }

# After modifying the ConfigMap, restart the Pods
k rollout restart -n kube-system deployment coredns
deployment.apps/coredns restarted

# Run monitoring again
[INFO] 127.0.0.1:58994 - 34124 "HINFO IN 6037978408014335337.605814283789943898. udp 56 false 512" NXDOMAIN qr,rd,ra 131 0.030715552s
[INFO] 10.244.0.18:44094 - 2374 "TXT IN _grpc_config.localhost.cluster.local. udp 65 false 1232" NXDOMAIN qr,aa,rd 147 0.000133673s
[INFO] 10.244.0.18:53621 - 42692 "TXT IN _grpc_config.localhost. udp 51 false 1232" NOERROR qr,aa,rd,ra 40 0.000665255s
[INFO] 10.244.0.18:50217 - 27442 "TXT IN _grpc_config.localhost.argocd.svc.cluster.local. udp 76 false 1232" NXDOMAIN qr,aa,rd 158 0.000451439s
[INFO] 10.244.0.18:47653 - 27301 "TXT IN _grpc_config.localhost.cluster.local. udp 65 false 1232" NXDOMAIN qr,aa,rd 147 0.000265055s
[INFO] 10.244.0.18:42682 - 225 "TXT IN _grpc_config.localhost.svc.cluster.local. udp 69 false 1232" NXDOMAIN qr,aa,rd 151 0.000098051s
[INFO] 10.244.0.18:59465 - 42232 "TXT IN _grpc_config.localhost.argocd.svc.cluster.local. udp 76 false 1232" NXDOMAIN qr,aa,rd 158 0.000412204s
[INFO] 10.244.0.18:43551 - 3161 "TXT IN _grpc_config.localhost.cluster.local. udp 65 false 1232" NXDOMAIN qr,aa,rd 147 0.000274895s
[INFO] 10.244.0.18:46699 - 41298 "TXT IN _grpc_config.localhost. udp 51 false 1232" NOERROR qr,aa,rd,ra 40 0.001113165s
[INFO] 10.244.0.18:51218 - 41659 "TXT IN _grpc_config.localhost.cluster.local. udp 65 false 1232" NXDOMAIN qr,aa,rd 147 0.00010227s
[INFO] 10.244.0.18:49290 - 65400 "TXT IN _grpc_config.localhost. udp 51 false 1232" NOERROR qr,aa,rd,ra 40 0.000420723s
[INFO] 10.244.0.18:40972 - 13505 "TXT IN _grpc_config.localhost.argocd.svc.cluster.local. udp 76 false 1232" NXDOMAIN qr,aa,rd 158 0.000533889s
[INFO] 10.244.0.18:43550 - 21969 "TXT IN _grpc_config.localhost.svc.cluster.local. udp 69 false 1232" NXDOMAIN qr,aa,rd 151 0.000305457s
[INFO] 10.244.0.18:45800 - 35989 "TXT IN _grpc_config.localhost.cluster.local. udp 65 false 1232" NXDOMAIN qr,aa,rd 147 0.000350586s
[INFO] 10.244.0.18:34607 - 33844 "TXT IN _grpc_config.localhost.argocd.svc.cluster.local. udp 76 false 1232" NXDOMAIN qr,aa,rd 158 0.00048275s
[INFO] 10.244.0.18:51297 - 16213 "TXT IN _grpc_config.localhost.svc.cluster.local. udp 69 false 1232" NXDOMAIN qr,aa,rd 151 0.000346629s
[INFO] 10.244.0.18:38990 - 39505 "TXT IN _grpc_config.localhost. udp 51 false 1232" NOERROR qr,aa,rd,ra 40 0.001392945s
[INFO] 10.244.0.11:50750 - 53043 "A IN nginx.default.svc.cluster.local. udp 49 false 512" NOERROR qr,aa,rd 96 0.000213921s
[INFO] 10.244.0.11:50750 - 44854 "AAAA IN nginx.default.svc.cluster.local. udp 49 false 512" NOERROR qr,aa,rd 142 0.000279647s


# If you have an internal DNS, resolving another domain, how do you make this domain accessible in the cluster?
# An External DNS must be configured.

k get cm -n kube-system coredns
k get cm -n kube-system coredns -o yaml
k edit cm -n kube-system coredns -o yaml

# Add a new block, in my case the block is called "interno.prgs.corp"

apiVersion: v1
data:
  Corefile: |
    .:53 {
        errors
        health {
           lameduck 5s
        }
        ready
        kubernetes cluster.local in-addr.arpa ip6.arpa {
           pods insecure
           fallthrough in-addr.arpa ip6.arpa
           ttl 30
        }
        prometheus :9153
        forward . /etc/resolv.conf {
           max_concurrent 1000
        }
        cache 30 {
           disable success cluster.local
           disable denial cluster.local
        }
        loop
        reload
        loadbalance
    }
    interno.prgs.corp {
        log
        errors
        forward . 192.168.56.56
        loadbalance
        cache 30
        reload
    }

# Restart Pods
k rollout restart -n kube-system deployment coredns

# In this scenario, the external DNS ( vault.interno.prgs.corp points to 192.168.56.56 )
#
k run --image alpine --rm -it curl sh
/ # ping 192.168.56.56
/ # apk add bind-tools
/ # host vault.interno.prgs.corp 192.168.56.56
Using domain server:
Name: 192.168.56.56
Address: 192.168.56.56#53
Aliases:

Host vault.interno.prgs.corp.default.svc.cluster.local not found: 5(REFUSED)

/ # cat /etc/resolv.conf
search default.svc.cluster.local svc.cluster.local cluster.local
nameserver 10.96.0.10
options ndots:5

/ # host vault.interno.prgs.corp
vault.interno.prgs.corp is an alias for ns1.interno.prgs.corp.
ns1.interno.prgs.corp has address 192.168.56.56

/ # ping vault.interno.prgs.corp
PING vault.interno.prgs.corp (192.168.56.56): 56 data bytes
64 bytes from 192.168.56.56: seq=0 ttl=62 time=0.750 ms
64 bytes from 192.168.56.56: seq=1 ttl=62 time=0.519 ms
64 bytes from 192.168.56.56: seq=2 ttl=62 time=0.719 ms

```

[Menu](#-menu)

# 🚀 Create Object - Network Policies

```bash

# To reproduce this laboratory it is necessary to have a CNI that supports Policies. In the scenarios below, Kind was implemented with Cilium support.
#
# Start kind with cilium support

k apply -f apps
deployment.apps/backend created
deployment.apps/database created
deployment.apps/frontend created

k get pods -o wide
NAME                        READY   STATUS    RESTARTS   AGE   IP             NODE           NOMINATED NODE   READINESS GATES
backend-76f4f86497-p76q2    1/1     Running   0          17m   10.244.2.148   prgs-worker    <none>           <none>
database-57f5bfb9c5-tfb6b   1/1     Running   0          17m   10.244.2.181   prgs-worker    <none>           <none>
frontend-64f4b788f9-hw8hb   1/1     Running   0          17m   10.244.1.49    prgs-worker2   <none>           <none>

# Frontend:
# -Receives traffic from outside, but can only talk to Backend.
# -Cannot talk to database.

# Backend:
# -Receives requests from the Front End
# -Can make requests to the Database.

# Database:
#   -Only receives requests from the Frontend.


#******************* Frontend cannot reach Database **********************
#
# 1) Connect to the Database and leave a Listen port (5432)

k exec -it database-57f5bfb9c5-tfb6b  -- sh
nc -lvp 5432
listening on [::]:5432 ...
connect to [::ffff:10.244.2.181]:5432 from [::ffff:10.244.1.49]:42587 ([::ffff:10.244.1.49]:42587)

# 2) Connect to Frontend and try to connect to port (5432)
k exec -it frontend-64f4b788f9-hw8hb  -- sh
nc -v 10.244.2.181 5432
10.244.2.181 (10.244.2.181:5432) open

# This applied policy allows external connection, but does not allow intra-cluster connection.
# It blocks everything, as the DNS is in the Pods range (10.244.0.0/16) I cannot resolve names.
#
cat <<EOF | k apply -f -
kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  name: allow-internet-only
spec:
  podSelector: {}
  policyTypes:
  - Egress
  egress:
  - to:
    - ipBlock:
        cidr: 0.0.0.0/0
        except:
        - 10.244.0.0/16
EOF

k exec -it frontend-64f4b788f9-hw8hb  -- sh
/ # apk add curl
/ # ping 4.2.2.2 -c 5
PING 4.2.2.2 (4.2.2.2): 56 data bytes
64 bytes from 4.2.2.2: seq=0 ttl=61 time=1.347 ms
64 bytes from 4.2.2.2: seq=1 ttl=61 time=0.707 ms
64 bytes from 4.2.2.2: seq=2 ttl=61 time=0.915 ms
64 bytes from 4.2.2.2: seq=3 ttl=61 time=0.682 ms
64 bytes from 4.2.2.2: seq=4 ttl=61 time=0.923 ms


cat <<EOF | k apply -f -
kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  name: allow-internet-only
spec:
  podSelector: {}
  policyTypes:
  - Egress
  egress:
  - to:
    - ipBlock:
        cidr: 0.0.0.0/0
        except:
        - 10.244.0.0/16
---
kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  name: allow-dns
spec:
  podSelector: {}
  policyTypes:
  - Egress
  egress:
    - to:
      - namespaceSelector:
          matchLabels:
            kubernetes.io/metadata.name: kube-system
        podSelector:
          matchLabels:
            k8s-app: kube-dns
EOF

k exec -it frontend-64f4b788f9-hw8hb  -- sh
/ # apk add curl
fetch https://dl-cdn.alpinelinux.org/alpine/v3.21/main/x86_64/APKINDEX.tar.gz
fetch https://dl-cdn.alpinelinux.org/alpine/v3.21/community/x86_64/APKINDEX.tar.gz
(1/9) Installing brotli-libs (1.1.0-r2)
(2/9) Installing c-ares (1.34.3-r0)
(3/9) Installing libunistring (1.2-r0)
(4/9) Installing libidn2 (2.3.7-r0)
(5/9) Installing nghttp2-libs (1.64.0-r0)
(6/9) Installing libpsl (0.21.5-r3)
(7/9) Installing zstd-libs (1.5.6-r2)
(8/9) Installing libcurl (8.11.1-r0)
(9/9) Installing curl (8.11.1-r0)
Executing busybox-1.37.0-r9.trigger
OK: 12 MiB in 24 packages

kubectl get networkpolicy
kubectl describe networkpolicy allow-dns

```

[Menu](#-menu)

# 🚀 Create Object - RBAC / CRB / RB

```bash

# RBAC ( Role Based Access Control )
#
# Role => A function that gives you access to something.

           AUTH            |        Authorization
-------------------------------------------------------------
                            ------ ( CRB ) Cluster Rolling Binding => View
( Usuário kubeconfig )-----|
                            ------ (  RB ) Rolling Binding         => Monitoring ( ro )

# Auth (Process that verifies who you are)
#
# Example: A user will interact with the cluster via kubectl, but the same commands and calls
# can be performed by a running pod, and if that pod has privileges using (service accounts),
# it can make changes to the cluster.

# All calls made by a user (kubectl), inside or outside the cluster, will go through the api-server.
#
# When going through the api-server, it must be an API call, so since this access is authenticated, we can
# map the permissions that can be granted.

# (CRB) Cluster Rolling Binding
# Gives access to resources at the cluster-wide level, not by namespace.
# Example:
# If I give a user permission to read the services, the user will be able to read all services from all namespaces.

# (RB) Rolling Binding
# Provides access to resources at the namespace level
# The term (Binding) is what creates the binding.
# The role is what grants access.

# Ex: The cluster already has a native (CRB) that provides read access to the cluster.
# If I need to monitor the cluster, I can create a (RB) called (monitoring-ro) that will give access to all resources within the monitoring namespace.

```

[Menu](#-menu)
# 🚀 Create Object - RBAC / Create User

```bash

https://kubernetes.io/docs/reference/access-authn-authz/authentication/

https://kubernetes.io/docs/reference/access-authn-authz/certificate-signing-requests/#kubernetes-signers

# Kubernetes only trusts certificates that it has signed itself, in the most common x509 format.
# We can create a (CSR - Certificate Signing Request) and the Kubernetes CA signs and trusts it.
# You don't create a user in Kubernetes (Kind User), that doesn't exist.
# Kubernetes reads the certificate (CN).


#********************** Criando Certificado para Usuário ***************************
#

openssl req -nodes \
  -days 365 \
  -newkey rsa:2048 \
  -keyout estagiario.key \
  -out estagiario.csr \
  -subj '/CN=estagiario/O=prgs/O=corp' \
  -addext 'subjectAltName = DNS:estagiario.prgs.corp'

# Create CSR ( BEGIN CERTIFICATE REQUEST )

cat estagiario.csr
-----BEGIN CERTIFICATE REQUEST-----
MIICqjCCAZICAQAwMzETMBEGA1UEAwwKZXN0YWdpYXJpbzENMAsGA1UECgwEcHJn
czENMAsGA1UECgwEY29ycDCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEB
AJgTlNNSpjtoBRE/RcMWOXoDAW2S3eAgGgRjZeNkocAfSkclfVJ6FwmZ1o4/CNkz
5jwULCmgXhv//d9gOVPyqyfdDNuBIrTzLrVUxZbU6ZgMyTBvnMOpExuRVYV78Pfo
wFDSro63ZOHV2t4B6fBn50fpxQ3L3Sa2q01uPB2/1rJg8kCXqX1yiPkkEGhHB18a
jkdi6J2uvEJ0Obt/cFE7mxsluAuYkNELAv77a2URpdQP1feS9NreUFWYkiQyqfHn
/ZMSurUkdETO5HthlS4ikL/UaWvkl+vNXaqPPqQMbTejz/m5lMOfeDOA3yXwzaQN
lDeokPjiDxPqSl2g1eRsGPkCAwEAAaAyMDAGCSqGSIb3DQEJDjEjMCEwHwYDVR0R
BBgwFoIUZXN0YWdpYXJpby5wcmdzLmNvcnAwDQYJKoZIhvcNAQELBQADggEBAFFg
GizQtXF2sBjGSgp9hIELjjrwdMUsa7b0y69/E+gu+Iwpe6Y1dhUS5OEMZUmWly1R
aKx/kAfdfD/9MRZH5nfLGYb8ZdrcOud4c/7juPFCFvM29aEdEKj5bQMMvUlkBhAN
oEIO74sK7OPqB6DO/NFjcU/71HZ20t0Qe6HIJlYzcbTKt1Qo6xvxFQhvFSb+ZYkR
jsrW8C/SylGO04XZOzezid1WPTg5hiUYuokGNgqh0efq6n5ExnH1yBbRABoub90f
d8caVqQbBoQymuKQmfZU5W4kVvnMjiFPUxjwWfoQSHDYNDD61pmCNh5N9EBSze2T
7wYd79Xz6MlH+gZUe9g=
-----END CERTIFICATE REQUEST-----


# To authenticate, I will need the key and the certificate signed by Kubernetes. The CSR file is the request to sign the certificate.
#
# Creating a certificate to authenticate with kubeconfig
#
# How to sign?

cat <<EOF | k apply -f -
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: estagiario-csr
spec:
  request: $(cat estagiario.csr | base64 -w 0)
  signerName: kubernetes.io/kube-apiserver-client
  usages:
  - client auth
EOF

# How to check all open CSRs?
# It will remain pending until an admin can approve it

k get csr
NAME             AGE   SIGNERNAME                                    REQUESTOR                        REQUESTEDDURATION   CONDITION
csr-p76zx        94m   kubernetes.io/kube-apiserver-client-kubelet   system:node:prgs-control-plane   <none>              Approved,Issued
estagiario-csr   8s    kubernetes.io/kube-apiserver-client           kubernetes-admin                 <none>              Pending

# This is where he signs the certificate.
# Signing Certificate
k certificate approve estagiario-csr
certificatesigningrequest.certificates.k8s.io/estagiario-csr approved

k get csr
NAME             AGE   SIGNERNAME                                    REQUESTOR                        REQUESTEDDURATION   CONDITION
csr-p76zx        94m   kubernetes.io/kube-apiserver-client-kubelet   system:node:prgs-control-plane   <none>              Approved,Issued
estagiario-csr   49s   kubernetes.io/kube-apiserver-client           kubernetes-admin                 <none>              Approved,Issued


# Extract certificate
k get csr estagiario-csr -o yaml

# How to check if the certificate was signed by k8s?
# Issuer CN=Kubernertes
# Subjetct CN = estagiario
k get csr estagiario-csr -o json | jq -r '.status.certificate' | base64 -d | openssl x509 -text

Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            50:1d:6b:9c:b1:99:75:42:c9:bb:34:c5:f9:d7:ed:50
        Signature Algorithm: sha256WithRSAEncryption
        Issuer: CN=kubernetes
        Validity
            Not Before: Jan 22 13:47:18 2026 GMT
            Not After : Jan 22 13:47:18 2027 GMT
        Subject: O=corp + O=prgs, CN=estagiario

# It is necessary to extract the certificates signed by Kubernetes.
k get csr estagiario-csr -o json | jq -r '.status.certificate' | base64 -d > estagiario.crt

-----BEGIN CERTIFICATE-----
MIIDNzCCAh+gAwIBAgIQd1D0Xk4vcPWqO3CXPjq2FTANBgkqhkiG9w0BAQsFADAV
MRMwEQYDVQQDEwprdWJlcm5ldGVzMB4XDTI2MDUxNDEzMjcyNloXDTI3MDUxNDEz
MjcyNlowMTEaMAsGA1UEChMEY29ycDALBgNVBAoTBHByZ3MxEzARBgNVBAMTCmVz
dGFnaWFyaW8wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCTVUNpLq8I
uYUx1pTige4vDsLHcC61L26Z2c0A1fXPPmIN9C98fBO7uQSpFBLW/3EQbvR9Aol/
QyINq5m9pGWlQI+MkGosoe8ONH2t4LLZN8f9FyDDYBfYfaY9pSia8WBlhoAICgM0
qkQdKwuaxQttGuikazWUj1zCfWnvZxI1tYFew0IiepMVyRJg+XXJsBDDDOcXprxG
VMrcvcqhISZ35dw72SZEJ4oQUdYn8MW5fQQstXqimW9221KiAZ04Z1PoBXMOkPIp
ut8QXh1LsKpeqF1HSUAlFsP7dhuHZLADIPrtAw+2hc/LRydEj9BkTANXECJgiP3U
yr1QEzaPebrPAgMBAAGjZzBlMBMGA1UdJQQMMAoGCCsGAQUFBwMCMAwGA1UdEwEB
/wQCMAAwHwYDVR0jBBgwFoAUEw5qGh+nrYPiEz2gCIb3yIWqKFAwHwYDVR0RBBgw
FoIUZXN0YWdpYXJpby5wcmdzLmNvcnAwDQYJKoZIhvcNAQELBQADggEBAH6GHtip
KU/DsOG1N8ru+pUZY8uwNQd1KTCkhTb0X5XmRnE9op6vxr4J98e0i1uIfAqRdl58
HUyP9A7pm/JO+1UcDAM1ZsbXOSBhAp4dHsTA/2gKmXsPUsj2lbpm1AkapjDIWPnV
s/MFq3l+aBmZ7uYZUxbOTT8qKUlmppCNXQmhGq9F8nopFidH+g0d7cyXSS4VbT47
teu8gT7s9EKIgmqxbbsPtKsNMKco3Av/NIxQO+n8CfQIxJbXKWIrwFky9XKH8aXv
fbR8AOYbxaKbGmBC01eczfMdPAC/dWXYw/VoZeS3lgF6kpl9w6JvNO3EI0IoKAha
R6zl6qw7CWOuxNI=
-----END CERTIFICATE-----
```

[Menu](#-menu)

# 🚀 Create Object - RBAC / Create Context

```bash

#**************** Configuring New Credential Estagiário **************************
#
# Check the current Context
k config current-context
kind-prgs

# Backup Config
cp ~/.kube/config{,.bkp}

# The ~/.kube/config file stores:
#
👉 clusters
👉 users (credentials/certificados)
👉 contexts

# A context is the combination of:
#
👉 cluster
👉 usuário
👉 namespace padrão

# This is where you create a new user in Kubeconfig
# This user ( estagiário ) will use your certificates to authenticate.
# Setting the ( estagiário ) credentials in kubeconfig
k config set-credentials estagiario --client-certificate=$(pwd)/estagiario.crt --client-key=$(pwd)/estagiario.key
User "estagiario" set.

# What happens internally?
# The kubeconfig file injects an entry for the intern user into the config.

users:
- name: estagiario
  user:
    client-certificate: /caminho/estagiario.crt
    client-key: /caminho/estagiario.key

# Creating a Context called ( estagiario )
k config set-context estagiario --cluster kind-prgs --namespace default --user estagiario

# What does this generate?
contexts:
- context:
    cluster: kind-prgs
    namespace: default
    user: estagiario
  name: estagiario

# Switching to context
k config use-context estagiario
Switched to context "estagiario".

# Can I read existing nodes?
k get nodes
Error from server (Forbidden): nodes is forbidden: User "estagiario" cannot list resource "nodes" in API group "" at the cluster scope

# This means:
✅ authentication worked
❌ authorization failed

# Check the contexto
kubectl config current-context
estagiario

# How to check all existing contexts and which one is in use?
kubectl config get-contexts
CURRENT   NAME                          CLUSTER      AUTHINFO           NAMESPACE
*         estagiario                    kind-prgs    estagiario         default
          kind-prgs                     kind-prgs    kind-prgs
          kubernetes-admin@kubernetes   kubernetes   kubernetes-admin

# Who am I after Kubernetes authenticates me
k auth whoami

# OBs.:
# The .kube/config files are being referenced by a path ( /path/certificate )
# If you want to define the certificate and key in base64 format in .kube/config, perform the procedures below:
#
cp ~/.kube/config{,.kind}

export base64_cert=$(base64 -w 0 <<< $(cat estagiario.crt))
export base64_key=$(base64 -w 0 <<< $(cat estagiario.key))

kubectl config set-credentials estagiario --client-certificate=/tmp/estagiario.crt --client-key=/tmp/estagiario.key

sed -i "s/client-certificate: \/tmp\/estagiario.crt/client-certificate-data: ${base64_cert}/" ~/.kube/config
sed -i "s/client-key: \/tmp\/estagiario.key/client-key-data: ${base64_key}/" ~/.kube/config
```

[Menu](#-menu)

# 🚀 Create Object - RBAC / Configurando Autorização

```bash

#**************** Configuring Authorization for Estagiário *************************
#
https://kubernetes.io/docs/reference/access-authn-authz/rbac/
https://kubernetes.io/docs/reference/access-authn-authz/rbac/#user-facing-roles
https://kubernetes.io/docs/reference/access-authn-authz/rbac/#clusterrole-example

# What resources?
k api-resources
NAME                                SHORTNAMES                        APIVERSION                        NAMESPACED   KIND
bindings                                                              v1                                true         Binding
componentstatuses                   cs                                v1                                false        ComponentStatus
configmaps                          cm                                v1                                true         ConfigMap
endpoints                           ep                                v1                                true         Endpoints
events                              ev                                v1                                true         Event
limitranges                         limits                            v1                                true         LimitRange
namespaces                          ns                                v1                                false        Namespace
...
...
...

# Listing every namespaced resource can be linked to a Role.
k api-resources | grep true

# List all namespaced resource
k api-resources --namespaced

# Return to context that has privileges
k config use-context kind-prgs
Switched to context "kind-prgs".

# What cluster roles exist?
k get clusterrole
NAME                                                                   CREATED AT
admin                                                                  2026-05-14T13:28:04Z
argo-cd-argocd-application-controller                                  2026-05-14T13:34:17Z
argo-cd-argocd-notifications-controller                                2026-05-14T13:34:17Z
argo-cd-argocd-server                                                  2026-05-14T13:34:17Z
cluster-admin                                                          2026-05-14T13:28:04Z
edit                                                                   2026-05-14T13:28:04Z
kindnet                                                                2026-05-14T13:28:07Z
kubeadm:get-nodes                                                      2026-05-14T13:28:05Z
...
...
...

# If I give permission at the cluster level, I give permission in all namespaces.

cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: estagiario-ro
rules:
- apiGroups: [""]
  resources: ["nodes"]
  verbs: ["list"]
EOF

k get clusterrole estagiario-ro
NAME            CREATED AT
estagiario-ro   2026-05-14T14:09:20Z

# Return to estagiário context
k config use-context estagiario
Switched to context "estagiario".

# Test ....
# Still having errors?
k get pods -A
Error from server (Forbidden): pods is forbidden: User "estagiario" cannot list resource "pods" in API group "" at the cluster scope


# Why does it keep giving errors?
👉 We just created the ClusterRole, now we have to do the binding to grant the action ( list ) Nodes.


# Return to context that has privileges
k config use-context kind-prgs
Switched to context "kind-prgs".

cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: estagiario-ro
subjects:
- kind: User
  name: estagiario
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: estagiario-ro
  apiGroup: rbac.authorization.k8s.io
EOF

k get clusterrolebindings estagiario-ro
NAME            ROLE                        AGE
estagiario-ro   ClusterRole/estagiario-ro   39s

# Return to intern context
k config use-context estagiario
Switched to context "estagiario".

k config get-contexts
CURRENT   NAME                          CLUSTER      AUTHINFO           NAMESPACE
*         estagiario                    kind-prgs    estagiario         default
          kind-prgs                     kind-prgs    kind-prgs
          kubernetes-admin@kubernetes   kubernetes   kubernetes-admin

# List the nodes
k get nodes
NAME                 STATUS   ROLES           AGE   VERSION
prgs-control-plane   Ready    control-plane   46m   v1.34.0

# Can I list the Pods?
# List Nodes yes, but I don't have permission to Pods?
k get pods -A
Error from server (Forbidden): pods is forbidden: User "estagiario" cannot list resource "pods" in API group "" at the cluster scope

# Return to privileged context
k config use-context kind-prgs
Switched to context "kind-prgs".

k config get-contexts
CURRENT   NAME                          CLUSTER      AUTHINFO           NAMESPACE
          estagiario                    kind-prgs    estagiario         default
*         kind-prgs                     kind-prgs    kind-prgs
          kubernetes-admin@kubernetes   kubernetes   kubernetes-admin

# There is a "ClusterRoleBinding" called "view" , which will give read permission to all objects in the cluster
# Does not give access to secrets (Check the documentation)

cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: estagiario-ro
subjects:
- kind: User
  name: estagiario
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: view
  apiGroup: rbac.authorization.k8s.io
EOF

# It is not possible to change an existing ClusterRoleBinding.
The ClusterRoleBinding "estagiario-ro" is invalid: roleRef: Invalid value: {"APIGroup":"rbac.authorization.k8s.io","Kind":"ClusterRole","Name":"view"}: cannot change roleRef

# Delete ClusterRoleBinding
k get clusterrolebindings estagiario-ro
k delete clusterrolebindings estagiario-ro

✅ Reapply the manifest

# Return to privileged context ( estagiário )
k config use-context estagiario
Switched to context "estagiario".

kubectl config get-contexts
CURRENT   NAME                          CLUSTER      AUTHINFO           NAMESPACE
*         estagiario                    kind-prgs    estagiario         default
          kind-prgs                     kind-prgs    kind-prgs
          kubernetes-admin@kubernetes   kubernetes   kubernetes-admin

# Run the build again
✅ This ClusterRole ( view ) cannot see the nodes.
✅ This RBAC does not allow us to see the nodes

k get nodes
Error from server (Forbidden): nodes is forbidden: User "estagiario" cannot list resource "nodes" in API group "" at the cluster scope

# I can list all Pods
k get pods -A
NAMESPACE            NAME                                                        READY   STATUS    RESTARTS   AGE
argocd               argo-cd-argocd-application-controller-0                     1/1     Running   0          47m
argocd               argo-cd-argocd-applicationset-controller-65f795bdf4-c7tc5   1/1     Running   0          47m
argocd               argo-cd-argocd-dex-server-76c9c5f56b-22rfq                  1/1     Running   0          47m
argocd               argo-cd-argocd-notifications-controller-7d746d6f96-dj8q5    1/1     Running   0          47m
argocd               argo-cd-argocd-redis-9c859c655-f6sqt                        1/1     Running   0          47m
argocd               argo-cd-argocd-repo-server-6d9f79976f-rfb52                 1/1     Running   0          47m
argocd               argo-cd-argocd-server-66b994c4fd-696cv                      1/1     Running   0          47m
argocd               gateway-nginx-7b76ff4574-b66r5                              1/1     Running   0          47m
kube-system          coredns-66bc5c9577-8wvsv                                    1/1     Running   0          54m
kube-system          coredns-66bc5c9577-pt4fh                                    1/1     Running   0          54m
kube-system          etcd-prgs-control-plane                                     1/1     Running   0          54m
kube-system          kindnet-mmlt7                                               1/1     Running   0          54m
kube-system          kube-apiserver-prgs-control-plane                           1/1     Running   0          54m
kube-system          kube-controller-manager-prgs-control-plane                  1/1     Running   0          54m
kube-system          kube-proxy-j4t4v                                            1/1     Running   0          54m
kube-system          kube-scheduler-prgs-control-plane                           1/1     Running   0          54m
kube-system          metrics-server-fcf6b4bd6-hpwvw                              1/1     Running   0          52m
local-path-storage   local-path-provisioner-7b8c8ddbd6-2llx5                     1/1     Running   0          54m
metallb-system       metallb-controller-765c495b75-6t24q                         1/1     Running   0          53m
metallb-system       metallb-speaker-7zzvt                                       4/4     Running   0          53m
nginx-gateway        ngf-nginx-gateway-fabric-76fc67668f-b8g7w                   1/1     Running   0          51m


# If you try to delete....
# Without permission.
k delete pod -n nginx-gateway ngf-nginx-gateway-fabric-76fc67668f-b8g7w
Error from server (Forbidden): pods "ngf-nginx-gateway-fabric-76fc67668f-b8g7w" is forbidden: User "estagiario" cannot delete resource "pods" in API group "" in the namespace "nginx-gateway
```

[Menu](#-menu)

# 🚀 Create Object - RBAC / Role ServiceAccount + RolingBindgings

```bash

# Implement Roles and Service Account
# A scenario where a user is not used to authenticate, RBAC is done within the pods of a cluster.
#
# Create a service account
#

# And a resource linked to the namespace
k api-resources | grep sa
serviceaccounts                     sa                                v1                                true         ServiceAccount

k create sa kubectl-sa --dry-run=client -o yaml
k create sa kubectl-sa

# Check
k get sa
NAME      SECRETS   AGE
default      0         8m18s
kubectl-sa   0         14s

# Creating a Pod and Adding the ServiceAccount
k neat <<< $(k run --image bitnami/kubectl kubectl --dry-run=client -o yaml)

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: kubectl
  name: kubectl
spec:
  serviceAccountName: kubectl-sa
  containers:
  - image: bitnami/kubectl
    name: kubectl
    command: [ "/bin/sh", "-c", "--" ]
    args: [ "echo 'Running....'; sleep 40;" ]
EOF

# Connecting to the Pod and executing Kubectl commands
k exec -it kubectl -- bash

I have no name! [ / ]$ kubectl get pods
Error from server (Forbidden): pods is forbidden: User "system:serviceaccount:default:kubectl-sa" cannot list resource "pods" in API group "" in the namespace "default"

I have no name! [ / ]$ kubectl get nodes
Error from server (Forbidden): nodes is forbidden: User "system:serviceaccount:default:kubectl-sa" cannot list resource "nodes" in API group "" at the cluster scope

I have no name! [ / ]$ ls /var/run/secrets/kubernetes.io/serviceaccount/token
I have no name! [ / ]$ cat /var/run/secrets/kubernetes.io/serviceaccount/token
ZMOIdLaU3Gm0VcXZdInXJHvP9xGx4JhKWSbWerbFBwt1Um_G8OsEsNBtBeMa28lrWxx7nDo8c98IzHAgug6xeQwI.....

#********************************** Create The Role *********************************
# How does Pod authenticate?
#
# I now need to create a Role (I will only give access to namespace)
# Note: If I want to restrict it to just one namespace, my "Role" must be created within that namespace.

k get ns
NAME                 STATUS   AGE
argocd               Active   17m
default              Active   24m
kube-node-lease      Active   24m
kube-public          Active   24m
kube-system          Active   24m
local-path-storage   Active   24m
metallb-system       Active   23m
nginx-gateway        Active   20m

# Imagine that you want to give permission to pods in the "argocd" namespace, then I create a role and
# a rolebinding within this namespace.

# Check existing Roles.
k get role -A
NAMESPACE            NAME                                             CREATED AT
argocd               argo-cd-argocd-application-controller            2026-05-15T09:09:47Z
argocd               argo-cd-argocd-applicationset-controller         2026-05-15T09:09:47Z
argocd               argo-cd-argocd-dex-server                        2026-05-15T09:09:47Z
argocd               argo-cd-argocd-notifications-controller          2026-05-15T09:09:47Z
argocd               argo-cd-argocd-redis-secret-init                 2026-05-15T09:05:53Z
argocd               argo-cd-argocd-repo-server                       2026-05-15T09:09:47Z
argocd               argo-cd-argocd-server                            2026-05-15T09:09:47Z
kube-public          kubeadm:bootstrap-signer-clusterinfo             2026-05-15T08:58:47Z
kube-public          system:controller:bootstrap-signer               2026-05-15T08:58:47Z
kube-system          extension-apiserver-authentication-reader        2026-05-15T08:58:47Z
kube-system          kube-proxy                                       2026-05-15T08:58:48Z
kube-system          kubeadm:kubelet-config                           2026-05-15T08:58:47Z
kube-system          kubeadm:nodes-kubeadm-config                     2026-05-15T08:58:47Z
kube-system          system::leader-locking-kube-controller-manager   2026-05-15T08:58:47Z
kube-system          system::leader-locking-kube-scheduler            2026-05-15T08:58:47Z
kube-system          system:controller:bootstrap-signer               2026-05-15T08:58:47Z
kube-system          system:controller:cloud-provider                 2026-05-15T08:58:47Z
kube-system          system:controller:token-cleaner                  2026-05-15T08:58:47Z
local-path-storage   local-path-provisioner-role                      2026-05-15T08:58:50Z
metallb-system       metallb-controller                               2026-05-15T08:59:08Z
metallb-system       metallb-pod-lister                               2026-05-15T08:59:08Z
nginx-gateway        ngf-nginx-gateway-fabric-cert-generator          2026-05-15T09:02:35Z


# Creating the Role within the namespace ( kube-system )
cat <<EOF | k apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: prgs:kubectl-role
  namespace: kube-system
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["list"]
EOF

k get role -n kube-system prgs:kubectl-role
NAME                CREATED AT
prgs:kubectl-role   2026-05-15T09:26:29Z

#**************************** Create the RoleBinding *********************************
#
# OBS.:
# Resources created in their respective namespaces must be informed.
subjects:
- kind: ServiceAccount
  name: kubectl-sa      # Name the service account
  namespace: default    # NameSpace where this SA is located


cat <<EOF | k apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: prgs:kubectl-rolebinding
  namespace: kube-system
subjects:
- kind: ServiceAccount
  name: kubectl-sa
  namespace: default
roleRef:
  kind: Role
  name: prgs:kubectl-role
  apiGroup: rbac.authorization.k8s.io
EOF

k get rolebinding -n kube-system prgs:kubectl-rolebinding
NAME                       ROLE                     AGE
prgs:kubectl-rolebinding   Role/prgs:kubectl-role   35s

#********************************* Test Autenticação *********************************
#
cat <<EOF | k apply -f -
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: kubectl
  name: kubectl
spec:
  serviceAccountName: kubectl-sa
  containers:
  - image: bitnami/kubectl
    name: kubectl
    command: [ "/bin/sh", "-c", "--" ]
    args: [ "echo 'Running....'; sleep 40;" ]
EOF

k exec -it kubectl -- bash
I have no name! [ / ]$ kubectl get pods -n kube-system
NAME                                         READY   STATUS    RESTARTS   AGE
coredns-66bc5c9577-44xks                     1/1     Running   0          21m
coredns-66bc5c9577-tks9c                     1/1     Running   0          21m
etcd-prgs-control-plane                      1/1     Running   0          21m
kindnet-r572p                                1/1     Running   0          21m
kube-apiserver-prgs-control-plane            1/1     Running   0          21m
kube-controller-manager-prgs-control-plane   1/1     Running   0          21m
kube-proxy-xlh8z                             1/1     Running   0          21m
kube-scheduler-prgs-control-plane            1/1     Running   0          21m
metrics-server-fcf6b4bd6-wtnzq               1/1     Running   0          20m


I have no name! [ / ]$ kubectl get pods -A
Error from server (Forbidden): pods is forbidden: User "system:serviceaccount:default:kubectl-sa" cannot list resource "pods" in API group "" at the cluster scope

#********************************* And the Jobs ****************************************
#

I have no name! [ / ]$ kubectl get jobs -n kube-system
Error from server (Forbidden): jobs.batch is forbidden: User "system:serviceaccount:default:kubectl-sa" cannot list resource "jobs" in API group "batch" in the namespace "kube-system"

cat <<EOF | k apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: prgs:kubectl-role
  namespace: kube-system
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["list"]
- apiGroups: ["batch"]
  resources: ["jobs"]
  verbs: ["list"]
EOF

I have no name! [ / ]$ kubectl get jobs -n kube-system
No resources found in kube-system namespace.

```

[Menu](#-menu)

# 🚀 Create Object - Affinity / Node-Selector Labels

```bash
#
# The Node Selector works as a rule to define Pod scheduling in Kubernetes workers.
#
# When a workload (such as Pod, Deployment, DaemonSet or StatefulSet) is created, the request is sent to the kube-apiserver, which stores the object in etcd.
#
# Next, the kube-scheduler identifies that there is a Pod without a defined node (Pending) and evaluates which node it can be run on.
#
# During this analysis, the scheduler considers several criteria defined in YAML and in the cluster, such as:

👉 nodeSelector
👉 nodeAffinity
👉 taints e tolerations
👉 resources available on the node (CPU, Memory)
👉 scheduling policies

# After choosing the most suitable node, the scheduler updates the Pod informing which node it should run on.
#
# Then the ReplicaSet (or another controller, such as StatefulSet/DaemonSet) ensures that the necessary Pods are created,
# and the kubelet of the selected node receives the instruction to start the containers.
#

k get pods -n kube-system kube-scheduler-master01
NAME                      READY   STATUS    RESTARTS      AGE
kube-scheduler-master01   1/1     Running   0            3h23m

# List all labels defined on nodes.
kubectl get nodes --show-labels | tr ',' '\n'
NAME       STATUS   ROLES           AGE   VERSION   LABELS
master01   Ready    control-plane   89d   v1.35.5   beta.kubernetes.io/arch=amd64
beta.kubernetes.io/os=linux
kubernetes.io/arch=amd64
kubernetes.io/hostname=master01
kubernetes.io/os=linux
node-role.kubernetes.io/control-plane=
node.kubernetes.io/exclude-from-external-load-balancers=
worker01   Ready    worker          89d   v1.35.5   beta.kubernetes.io/arch=amd64
beta.kubernetes.io/os=linux
kubernetes.io/arch=amd64
kubernetes.io/hostname=worker01
kubernetes.io/os=linux
node-role.kubernetes.io/worker=

cat <<EOF | k apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: postgres
  name: postgres
spec:
  replicas: 1
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      nodeSelector:
        prgs/postgres: "true"
      containers:
      - image: nginx
        name: postgres
EOF

#
k get pods postgres-64f4bd66b8-tgnwj
NAME                        READY   STATUS    RESTARTS   AGE
postgres-64f4bd66b8-tgnwj   0/1     Pending   0          19s

# The status will be pending , as this label is not defined.
#
# Defining Label
#
kubectl label node worker01 prgs/postgres=true

# Listing all Pods after creating the label.
k get pods
NAME                          READY   STATUS              RESTARTS      AGE
nginx-0                       1/1     Running             1 (25m ago)   3h11m
nginx-1                       1/1     Running             1 (25m ago)   3h5m
nginx-paulo-78455bbb4-82vkz   1/1     Running             1 (25m ago)   3h14m
postgres-64f4bd66b8-tgnwj     0/1     ContainerCreating   0             8m54s
```

[Menu](#-menu)

# 🚀 Create Object - Affinity / Node-Affinity

```bash

https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/

# Node Afinity => is more flexible!!!
#
# Used when I want to give preference to running on a certain worker,
# but if it is deployed to another worker there is no problem.
#
# As it is a "required" rule, it will be pending if it does not meet the rule.
#
# Selector node behavior

#************ Affinity - NodeSelector Similar Behavior ***********************
#

cat <<EOF | k apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: postgres
  name: postgres
spec:
  replicas: 1
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: prgs/postgres
                operator: In
                values:
                - uma-label-inexistente
      containers:
      - image: nginx
        name: postgres
EOF

k get pods -A
NAME                          READY   STATUS    RESTARTS      AGE
nginx-0                       1/1     Running   1 (34m ago)   3h19m
nginx-1                       1/1     Running   1 (34m ago)   3h14m
nginx-paulo-78455bbb4-82vkz   1/1     Running   1 (34m ago)   3h23m
postgres-5b48bf944f-f5xl9     0/1     Pending   0             1s

# NOTE: Same behavior as Node Selector
k describe pod postgres-5b48bf944f-f5xl9

Conditions:
  Type           Status
  PodScheduled   False
Volumes:
  kube-api-access-vkhw9:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    Optional:                false
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type     Reason            Age   From               Message
  ----     ------            ----  ----               -------
  Warning  FailedScheduling  28s   default-scheduler  0/2 nodes are available: 1 node(s) didn't match Pod's node affinity/selector, 1 node(s) had untolerated taint(s). no new claims to deallocate, preemption: 0/2 nodes are available: 2 Preemption is not helpful for scheduling.

#****************** Affinity - Try Scheduling on the Correct Node ***********************
#
# It will try to schedule the Pod on the Node that has the label "prgs/postgres", if it doesn't find it, it will play on any other

cat <<EOF | k apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: postgres
  name: postgres
spec:
  replicas: 1
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      affinity:
        nodeAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 1
            preference:
              matchExpressions:
              - key: prgs/postgres
                operator: In
                values:
                - uma-label-inexistente
      containers:
      - image: nginx
        name: postgres
EOF

# - weight: 1
#  preference:
#
# This wight is the "weight" as it is an array I can measure which one will have more preference for deployment.
#
# The concept of weight in nodeAffinity is used to define a scheduler preference
# preferred → preference, not obligation

cat <<EOF | kaf -
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx
  name: nginx
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      affinity:
        nodeAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 5
            preference:
              matchExpressions:
              - key: prgs/apps
                operator: In
                values:
                - "true"
          - weight: 6
            preference:
              matchExpressions:
              - key: prgs/postgres
                operator: In
                values:
                - "true"
      containers:
      - image: nginx
        name: nginx
EOF

```

[Menu](#-menu)

# 🚀 Create Object - Affinity / Pod-Affinity

```bash

https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#an-example-of-a-pod-that-uses-pod-affinity

#
# PodAntiAffinity is a rule used to prevent certain Pods from running close to each other.
#
# It is widely used to:
# -high availability
# -load distribution
# -avoid single point of failure
# Get the doc because the syntax is puck and guarantee the labels because it is the key to it working.
#
# Let's deploy postgres to the postgres worker and I don't want the frontend pod on the same worker

# Defining Label
#
kubectl label node worker01 prgs/postgres=true
kubectl label node worker01 app=database

# Creating Deployment
# The label will be used to match the affinity of the backend deployment

cat <<EOF | k apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: database
  name: postgres
spec:
  replicas: 1
  selector:
    matchLabels:
      app: database
  template:
    metadata:
      labels:
        app: database
    spec:
      nodeSelector:
        prgs/postgres: "true"
      containers:
      - image: nginx
        name: postgres
EOF

# List the labels of this pod
pod=$(k get pods -o=jsonpath='{range .items..metadata}{.name}{"\n"}{end}' | grep '^postgres-')

k get pod $pod --show-labels
NAME                        READY   STATUS    RESTARTS   AGE   LABELS
postgres-684cb45d6-hbwth   1/1     Running   0          6s    app=database,pod-template-hash=684cb45d6

# I want the application to run close to the bank, on the same worker.
#
# Check
kubectl get nodes --show-labels | grep -o app=database
app=database

# Criando Deployment
#
# topologyKey: prgs/postgres
# What does this mean...
# the Pod must be on the same node where there is a Pod with Label prgs/postgres
# The topologyKey is NOT any arbitrary value.
# It needs to reference an existing label on the nodes, and all nodes involved need to have this label.
#
# topologyKey uses only the node label KEY.
# podAffinity does not look for nodes with label app = database.
#
# It looks for:
# Pods with app=database
#
# and then use the topologyKey to find out which “domain/topology” this Pod is in.
#
cat <<EOF | kaf -
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: backend
  name: backend
spec:
  replicas: 1
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      affinity:
        podAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: app
                operator: In
                values:
                - database
            topologyKey: prgs/postgres
      containers:
      - image: nginx
        name: backend
EOF

k get pods
NAME                       READY   STATUS    RESTARTS   AGE
backend-58fd97f655-bqfgd   1/1     Running   0          13s
postgres-684cb45d6-hbwth   1/1     Running   0          53s
```

[Menu](#-menu)

# 🚀 Create Object - Affinity / PodAntiAffinity

```bash
#****************** Affinity - Frontend Running on Another Node  ***********************
#
# As I don't have another node, I will remove the rule that prevents using the node (Control Plane) to schedule Pods.
#
kubectl taint nodes master01 node-role.kubernetes.io/control-plane:NoSchedule-

cat <<EOF | kaf -
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: frontend
  name: frontend
spec:
  replicas: 1
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: app
                operator: In
                values:
                - database
            topologyKey: prgs/postgres
      containers:
      - image: nginx
        name: frontend
EOF


k get pod -o wide
NAME                        READY   STATUS    RESTARTS   AGE   IP             NODE       NOMINATED NODE   READINESS GATES
backend-58fd97f655-bqfgd    1/1     Running   0          13m   10.244.1.163   worker01   <none>           <none>
frontend-67c8c6b765-rvg4s   1/1     Running   0          80s   10.244.0.50    master01   <none>           <none>
postgres-684cb45d6-hbwth    1/1     Running   0          13m   10.244.1.162   worker01   <none>           <none>
```

[Menu](#-menu)

# 🚀 Create Object - Affinity / Tolerations

```bash
| Type             | Behavior                    |
| ---------------- | --------------------------- |
| NoSchedule       | Does not schedule new Pods  |
| PreferNoSchedule | Avoid, but you can schedule |
| NoExecute        | Remove Pods already running |

# Ensure that workloads are scheduled on control-plane nodes.
# Guaranteeing that no pod will be scheduled in the control-plane.
# Unless it has corresponding tolerance.

k taint nodes master01 node-role.kubernetes.io/control-plane=:NoSchedule
k describe node master01 | grep Taint

# What is tolerance?
# This declared in the manifest ensures that the Pod can be scheduled in the control-plane e.g.
# even if it has a taint

tolerations:
- key: "node-role.kubernetes.io/control-plane"
  operator: "Exists"
  effect: "NoSchedule"


# What if my taint is "NoExecute" ?
# The NoExecute effect does two things:
# Prevent new Pods from being scheduled
# Remove Pods that are already running and do not tolerate taint

👉 O Pod:

# Can be scheduled
# Will not be removed
# Runs indefinitely

| Taint      | With toleration      | Without toleration | With tolerationSeconds  |
| ---------- | -------------------- | ------------------ | ----------------------- |
| NoSchedule | No schedule          | Schedule           | Schedule                |
| NoExecute  | No schedule + remove | schedule + remains | Schedule + remove after |

# Define the workloads that can be used in the manifest.
# As workers have a worker label, pods will only be scheduled on workers.
#
nodeSelector:
  node-role.kubernetes.io/worker: ""


kubectl patch daemonset xxx -p '
spec:
  template:
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: node-role.kubernetes.io/worker
                operator: Exists
'


# Return to default, to disallow that can be scheduled in the control plane
kubectl taint nodes master01 node-role.kubernetes.io/control-plane:NoSchedule

# In practice, to ensure that the frontend does not run in the application pods, I can force the friendship.

cat <<EOF | kaf -
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: frontend
  name: frontend
spec:
  replicas: 1
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      tolerations:
      - key: "node-role.kubernetes.io/control-plane"
        operator: "Exists"
        effect: "NoSchedule"
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: app
                operator: In
                values:
                - database
            topologyKey: prgs/postgres
      containers:
      - image: nginx
        name: frontend
EOF

# Listing all Pods
k get pod -o wide
NAME                       READY   STATUS    RESTARTS   AGE   IP             NODE       NOMINATED NODE   READINESS GATES
backend-58fd97f655-bqfgd   1/1     Running   0          19m   10.244.1.163   worker01   <none>           <none>
frontend-d646846c6-9jczm   1/1     Running   0          8s    10.244.0.51    master01   <none>           <none>
postgres-684cb45d6-hbwth   1/1     Running   0          20m   10.244.1.162   worker01   <none>           <none>
```

[Menu](#-menu)

# 🚀 Create Object - Affinity / Pod Topology Spread Constraints

```bash

# Defines rules where the scheduler itself will distribute workloads across different nodes.

https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/

https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/#example-multiple-topologyspreadconstraints

# Suppose we have a deployment with 3 replicas, I want it to be distributed across 3 nodes
#
# I can use this same analogy for availability zones, where I can guarantee that I will have replicas running in multi-az.
#
us-east-1a
us-east-1b
us-east-1c

spec:
  topologySpreadConstraints:
  - maxSkew: 1
    topologyKey: zone
    whenUnsatisfiable: DoNotSchedule

# maxSkew =>
# Suppose we have 2 nodes and my deployment will schedule 5 REPLICAS.
# In practice, this means that I will have 1 pod running per node, so 3 pods will NOT be deployed.
#
# Another scenario =>
# My "maxSkew" set to 2, I will have 2 pods per node and 1 pod will be pending.
#
# The higher this number, the smoother your deployment will be in terms of how the schedule will be done
#
# topologyKey: kubernetes.io/hostname ( Guarantees that this label will be unique per node )
# In the cloud, it is interesting to place them by availability zone

# Imagine a scenario with a deployment with 10 replicas, the k8s default is to create another replicaset
# and usually it downloads 2 pods and creates 2 pods.
#
# The problem is that both the old and new Deployment have the same label (app=nginx).
# During a rolling update, the scheduler can consider pods of different revisions
# as belonging to the same group when calculating the skew of topologySpreadConstraints,
# since they both share the same labels.
#
# Without this configuration, old and new pods can influence each other
# distribution, causing unexpected balancing during rollout.

matchLabelKeys:
  - pod-template-hash

# When using matchLabelKeys with pod-template-hash, the scheduler starts to consider
# only pods that have the same pod-template-hash value (i.e. from the same Deployment revision)
# when calculating skew.
# Thus, the pods of the new version do not interfere with balancing
# of the old version's pods, and vice versa.


cat <<EOF | kaf -
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: frontend
  name: frontend
spec:
  replicas: 5
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      topologySpreadConstraints:
          - maxSkew: 1
            topologyKey: kubernetes.io/hostname
            whenUnsatisfiable: DoNotSchedule
            labelSelector:
              matchLabels:
                app: frontend
            matchLabelKeys:
              - pod-template-hash
      containers:
      - image: alpine
        name: frontend
        command:
          - sleep
          - "9999999999999"
EOF

# I only have 2 nodes (workers)
kgn
NAME                 STATUS   ROLES             AGE    VERSION
prgs-control-plane   Ready    control-plane     139m   v1.32.0
prgs-worker          Ready    worker-apps       139m   v1.32.0
prgs-worker2         Ready    worker-postgres   139m   v1.32.0


# Only made 2 deploys
k get pod
NAME                        READY   STATUS    RESTARTS   AGE
frontend-77876bddc7-hcz94   0/1     Pending   0          4m41s
frontend-77876bddc7-jsmr9   0/1     Pending   0          4m41s
frontend-77876bddc7-qct74   0/1     Pending   0          4m41s
frontend-77876bddc7-s7x78   1/1     Running   0          4m41s
frontend-77876bddc7-x6f4c   1/1     Running   0          4m41s

# Another example
# 3 pods per node, so 6 pods will be deployed and 4 pods are pending due to lack of worker

cat <<EOF | kaf -
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: frontend
  name: frontend
spec:
  replicas: 10
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      topologySpreadConstraints:
          - maxSkew: 3
            topologyKey: kubernetes.io/hostname
            whenUnsatisfiable: DoNotSchedule
            labelSelector:
              matchLabels:
                app: frontend
            matchLabelKeys:
              - pod-template-hash
      containers:
      - image: alpine
        name: frontend
        command:
          - sleep
          - "9999999999999"
EOF

# When doing describe you can notice that it tried to use the control-plane, but due to an affinity rule (tolerance)
# no pods can be scheduled in the control-planes.
#
k describe pod frontend-c86867df9-fnjdr
  Warning  FailedScheduling  3m31s  default-scheduler  0/3 nodes are available: 1 node(s) had untolerated taint {node-role.kubernetes.io/control-plane: }, 2 node(s) didn't match pod topology spread constraints. preemption: 0/3 nodes are available: 1 Preemption is not helpful for scheduling, 2 No preemption victims found for incoming pod.


kubectl rollout restart deploy

k rollout restart deployment/frontend
k rollout restart -n default deployment frontend
```

[Menu](#-menu)

# 🚀 Cluster Upgrade - Ferramentas e Boas Práticas

```bash
# For this lab we will use Vms provisioned via KVM
# Current cluster running on version 1.34
# Control Plane => master01
# Control Data => worker01

# NOTE:
# Always one minor at a time
#
# Beware of deprecated APIs

https://kubernetes.io/docs/reference/using-api/deprecation-guide/


k get nodes
NAME       STATUS   ROLES           AGE   VERSION
master01   Ready    control-plane   87d   v1.34.4
worker01   Ready    worker          87d   v1.34.4

# kubenet
# Helps to map deprecated APIs
https://github.com/doitintl/kube-no-trouble

sh -c "$(curl -sSL https://git.io/install-kubent)"
kubent --help

# Go show me a list of things that could cause problems.
# Make a dump and show you the changes
# Change API versions before upgrading

# I want to update to 1.35
kubent -t 1.35
10:44AM INF >>> Kube No Trouble `kubent` <<<
10:44AM INF version 0.7.3 (git sha 57480c07b3f91238f12a35d0ec88d9368aae99aa)
10:44AM INF Initializing collectors and retrieving data
10:44AM INF Target K8s version is 1.35.0
10:45AM INF Retrieved 5 resources from collector name=Cluster
10:45AM INF Retrieved 43 resources from collector name="Helm v3"
10:45AM INF Loaded ruleset name=custom.rego.tmpl
10:45AM INF Loaded ruleset name=deprecated-1-16.rego
10:45AM INF Loaded ruleset name=deprecated-1-22.rego
10:45AM INF Loaded ruleset name=deprecated-1-25.rego
10:45AM INF Loaded ruleset name=deprecated-1-26.rego
10:45AM INF Loaded ruleset name=deprecated-1-27.rego
10:45AM INF Loaded ruleset name=deprecated-1-29.rego
10:45AM INF Loaded ruleset name=deprecated-1-32.rego
10:45AM INF Loaded ruleset name=deprecated-future.rego

# Note that it went smoothly, so the cluster will not break during the Upgrade process.

#************************ How to Simulate Kubent With Changes **************************
#
# Get the supported flow version
kubectl api-resources | grep flow
flowschemas                                      flowcontrol.apiserver.k8s.io/v1   false        FlowSchema
prioritylevelconfigurations                      flowcontrol.apiserver.k8s.io/v1   false        PriorityLevelConfiguration

# O flowcontrol.apiserver.k8s.io is the mechanism of API Priority and Fairness (APF) do Kubernetes.
#
# It controls:
👉 who can consume the API
👉 how much each customer can consume
👉 how the request queue is organized
👉 kube-apiserver overload protection

# In summary:
👉 APF prevents a client from “throttling” the Kubernetes API.

# Supposing you are running the cluster on 1.31 and want to upgrade to 1.32
kubent -t 1.32
4:54PM INF >>> Kube No Trouble `kubent` <<<
4:54PM INF version 0.7.3 (git sha 57480c07b3f91238f12a35d0ec88d9368aae99aa)
4:54PM INF Initializing collectors and retrieving data
4:54PM INF Target K8s version is 1.32.0
4:54PM INF Retrieved 15 resources from collector name=Cluster
4:54PM INF Retrieved 33 resources from collector name="Helm v3"
4:54PM INF Loaded ruleset name=custom.rego.tmpl
4:54PM INF Loaded ruleset name=deprecated-1-16.rego
4:54PM INF Loaded ruleset name=deprecated-1-22.rego
4:54PM INF Loaded ruleset name=deprecated-1-25.rego
4:54PM INF Loaded ruleset name=deprecated-1-26.rego
4:54PM INF Loaded ruleset name=deprecated-1-27.rego
4:54PM INF Loaded ruleset name=deprecated-1-29.rego
4:54PM INF Loaded ruleset name=deprecated-1-32.rego
4:54PM INF Loaded ruleset name=deprecated-future.rego
__________________________________________________________________________________________
>>> Deprecated APIs removed in 1.32 <<<
------------------------------------------------------------------------------------------
KIND         NAMESPACE     NAME          API_VERSION                            REPLACE_WITH (SINCE)
FlowSchema   <undefined>   cilium-pods   flowcontrol.apiserver.k8s.io/v1beta3   flowcontrol.apiserver.k8s.io/v1 (1.32.0)


#******************************* Dump Manifestos ************************************
#
https://github.com/msfidelis/kubedump

```
[Menu](#-menu)

# 🚀 Cluster Upgrade - Control Plane / Masters

```bash

# Deployed Products At the Time of Upgrade
k get nodes -o wide
NAME       STATUS   ROLES           AGE   VERSION   INTERNAL-IP     EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION       CONTAINER-RUNTIME
master01   Ready    control-plane   89d   v1.34.4   10.100.100.11   <none>        Ubuntu 22.04.5 LTS   5.15.0-177-generic   containerd://1.7.28
worker01   Ready    worker          89d   v1.34.4   10.100.100.20   <none>        Ubuntu 22.04.5 LTS   5.15.0-171-generic   containerd://1.7.28

k get pods -A
NAMESPACE            NAME                                                        READY   STATUS      RESTARTS        AGE
default              my-job-ggqs6                                                0/1     Completed   0               76d
default              my-job2-jjp4r                                               0/1     Completed   0               76d
default              my-job3-x2ht7                                               0/1     Completed   0               76d
default              nginx-0                                                     1/1     Running     4 (107s ago)    78d
default              nginx-1                                                     1/1     Running     4 (107s ago)    78d
default              nginx-paulo-78455bbb4-kx5w5                                 1/1     Running     2 (107s ago)    75d
kube-flannel         kube-flannel-ds-qxqqp                                       1/1     Running     7 (108s ago)    89d
kube-flannel         kube-flannel-ds-zzgvm                                       1/1     Running     7 (107s ago)    89d
kube-system          coredns-66bc5c9577-7vrjp                                    1/1     Running     7 (108s ago)    89d
kube-system          coredns-66bc5c9577-lnjr9                                    1/1     Running     7 (108s ago)    89d
kube-system          etcd-master01                                               1/1     Running     7 (108s ago)    89d
kube-system          kube-apiserver-master01                                     1/1     Running     7 (108s ago)    89d
kube-system          kube-controller-manager-master01                            1/1     Running     7 (108s ago)    89d
kube-system          kube-proxy-fg27m                                            1/1     Running     7 (107s ago)    89d
kube-system          kube-proxy-zf2fv                                            1/1     Running     7 (108s ago)    89d
kube-system          kube-scheduler-master01                                     1/1     Running     7 (108s ago)    89d
kube-system          metrics-server-755bdffd6c-trrcm                             1/1     Running     7 (108s ago)    89d
local-path-storage   local-path-storage-local-path-provisioner-f555d4fc6-qrlqp   1/1     Running     3 (107s ago)    76d
metallb-system       metallb-controller-765c495b75-c757j                         1/1     Running     7 (108s ago)    89d
metallb-system       metallb-speaker-lsp9j                                       4/4     Running     28 (108s ago)   89d
metallb-system       metallb-speaker-rhs68                                       4/4     Running     28 (107s ago)   89d

https://docs.aws.amazon.com/eks/latest/userguide/update-cluster.html

https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/

# For this laboratory, the Cluster was created via kubeadm, as this scenario will be covered in the exam.
#
# All commands listed below must be executed on the master (control plane)
#
# Shows available versions
#
apt list -a kubeadm
Listing... Done
kubeadm/unknown 1.34.8-1.1 amd64 [upgradable from: 1.34.4-1.1]
kubeadm/unknown 1.34.7-1.1 amd64
kubeadm/unknown 1.34.6-1.1 amd64
kubeadm/unknown 1.34.5-1.1 amd64
kubeadm/unknown,now 1.34.4-1.1 amd64 [installed,upgradable to: 1.34.8-1.1]
kubeadm/unknown 1.34.3-1.1 amd64
kubeadm/unknown 1.34.2-1.1 amd64
kubeadm/unknown 1.34.1-1.1 amd64
kubeadm/unknown 1.34.0-1.1 amd64

# My repository points to 1.34, so Minio Version upgrades are confined to that version.

# Update my repository list.
# I am issuing the commands logged in as root

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.35/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.35/deb/ /" | tee /etc/apt/sources.list.d/kubernetes.list
apt-get update -y

# Re-list available versions
apt list -a kubeadm
Listing... Done
kubeadm/unknown 1.35.5-1.1 amd64 [upgradable from: 1.34.4-1.1]
kubeadm/unknown 1.35.4-1.1 amd64
kubeadm/unknown 1.35.3-1.1 amd64
kubeadm/unknown 1.35.2-1.1 amd64
kubeadm/unknown 1.35.1-1.1 amd64
kubeadm/unknown 1.35.0-1.1 amd64
kubeadm/now 1.34.4-1.1 amd64 [installed,upgradable to: 1.35.5-1.1]

# When logging into the machine, Ubuntu itself shows that it needs to be updated.

Expanded Security Maintenance for Applications is not enabled.

44 updates can be applied immediately.
To see these additional updates run: apt list --upgradable

apt list --upgradable

Listing... Done
apparmor/jammy-updates 3.0.4-2ubuntu2.5 amd64 [upgradable from: 3.0.4-2ubuntu2.4]
cloud-init/jammy-updates 25.3-0ubuntu1~22.04.1 all [upgradable from: 25.2-0ubuntu1~22.04.1]
containerd/jammy-updates 2.2.1-0ubuntu1~22.04.1 amd64 [upgradable from: 1.7.28-0ubuntu1~22.04.1]
coreutils/jammy-updates 8.32-4.1ubuntu1.3 amd64 [upgradable from: 8.32-4.1ubuntu1.2]
cri-tools/unknown 1.35.0-1.1 amd64 [upgradable from: 1.34.0-1.1]
distro-info-data/jammy-updates 0.52ubuntu0.12 all [upgradable from: 0.52ubuntu0.11]
iproute2/jammy-updates 5.15.0-1ubuntu2.1 amd64 [upgradable from: 5.15.0-1ubuntu2]
kubeadm/unknown 1.35.5-1.1 amd64 [upgradable from: 1.34.4-1.1]
kubectl/unknown 1.35.5-1.1 amd64 [upgradable from: 1.34.4-1.1]
kubelet/unknown 1.35.5-1.1 amd64 [upgradable from: 1.34.4-1.1]
kubernetes-cni/unknown 1.8.0-1.1 amd64 [upgradable from: 1.7.1-1.1]

# If you simply run the upgrade, the packages will be ignored ( kubeadm kubectl kubelet )
# Because they are marked as (Hold), so as not to update.
# At this stage I guarantee the upgrade of other packages
#
apt upgrade

Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
Calculating upgrade... Done
Get another security update through Ubuntu Pro with 'esm-apps' enabled:
  containerd
Learn more about Ubuntu Pro at https://ubuntu.com/pro
The following NEW packages will be installed:
  linux-headers-5.15.0-179 linux-headers-5.15.0-179-generic linux-image-5.15.0-179-generic linux-modules-5.15.0-179-generic netplan-generator python3-netplan
The following packages have been kept back:
  kubeadm kubectl kubelet
The following packages will be upgraded:
  apparmor cloud-init containerd coreutils cri-tools distro-info-data iproute2 kubernetes-cni landscape-common libapparmor1 libldap-2.5-0 libldap-common libnetplan0 libnftables1
  libnss-systemd libpam-systemd libsystemd0 libudev1 linux-headers-generic linux-headers-virtual linux-image-virtual linux-virtual lshw netplan.io nftables python3-attr runc snapd
  sosreport systemd systemd-sysv systemd-timesyncd tzdata ubuntu-advantage-tools ubuntu-minimal ubuntu-pro-client ubuntu-pro-client-l10n ubuntu-server ubuntu-standard udev
40 upgraded, 6 newly installed, 0 to remove and 3 not upgraded.
4 standard LTS security updates
Need to get 188 MB of archives.
After this operation, 195 MB of additional disk space will be used.
Do you want to continue? [Y/n] Y

# Packages have not been updated
kubectl version
Client Version: v1.34.4
Kustomize Version: v5.7.1
Server Version: v1.34.4

# NOTE: If a suggestion window for restarting services appears at the time of the upgrade, deselect the options related to:
👉 - kubelet.service
👉 - containerd.service

# List packages to be updated
apt list --upgradable
Listing... Done
kubeadm/unknown 1.35.5-1.1 amd64 [upgradable from: 1.34.4-1.1]
kubectl/unknown 1.35.5-1.1 amd64 [upgradable from: 1.34.4-1.1]
kubelet/unknown 1.35.5-1.1 amd64 [upgradable from: 1.34.4-1.1]

# How to check packages marked as Hold
# When issuing the command below, packages starting with ( hi ) are marked not to be updated.
#
dpkg -l | grep kube
hi  kubeadm                          1.34.4-1.1                              amd64        Command-line utility for administering a Kubernetes cluster
hi  kubectl                          1.34.4-1.1                              amd64        Command-line utility for interacting with a Kubernetes cluster
hi  kubelet                          1.34.4-1.1                              amd64        Node agent for Kubernetes clusters
ii  kubernetes-cni                   1.7.1-1.1                               amd64        Binaries required to provision kubernetes container networking

# Should I mark everyone as unhold?
# NO !!!
# Note: At first only kubeadm

apt-mark unhold kubeadm
Canceled hold on kubeadm.

# When marked with unhold your status changes to (ii)
#
dpkg -l | grep kube
ii  kubeadm                          1.34.4-1.1                              amd64        Command-line utility for administering a Kubernetes cluster
hi  kubectl                          1.34.4-1.1                              amd64        Command-line utility for interacting with a Kubernetes cluster
hi  kubelet                          1.34.4-1.1                              amd64        Node agent for Kubernetes clusters
ii  kubernetes-cni                   1.7.1-1.1                               amd64        Binaries required to provision kubernetes container networking

# Updating kubeadm
apt install kubeadm

# NOTE: If a suggestion window for restarting services appears at the time of the upgrade, deselect the options related to:
👉 kubelet.service
👉 containerd.service

kubeadm version
kubeadm version: &version.Info{Major:"1", Minor:"35", EmulationMajor:"", EmulationMinor:"", MinCompatibilityMajor:"", MinCompatibilityMinor:"", GitVersion:"v1.35.5", GitCommit:"6636cbce3bbef91ff61d36658757179426f9e1b2", GitTreeState:"clean", BuildDate:"2026-05-12T09:53:04Z", GoVersion:"go1.25.9", Compiler:"gc", Platform:"linux/amd64"}

# kubeadm upgrade --help
kubeadm upgrade plan
COMPONENT   NODE       CURRENT   TARGET
kubelet     master01   v1.34.4   v1.35.5
kubelet     worker01   v1.34.4   v1.35.5

Upgrade to the latest stable version:

COMPONENT                 NODE       CURRENT   TARGET
kube-apiserver            master01   v1.34.4   v1.35.5
kube-controller-manager   master01   v1.34.4   v1.35.5
kube-scheduler            master01   v1.34.4   v1.35.5
kube-proxy                           1.34.4    v1.35.5
CoreDNS                              v1.12.1   v1.13.1
etcd                      master01   3.6.5-0   3.6.6-0

You can now apply the upgrade by executing the following command:

	kubeadm upgrade apply v1.35.5

# Upgrade Now
kubeadm upgrade apply v1.35.5
[upgrade] Reading configuration from the "kubeadm-config" ConfigMap in namespace "kube-system"...
[upgrade] Use 'kubeadm init phase upload-config kubeadm --config your-config-file' to re-upload it.
[upgrade/preflight] Running preflight checks
[upgrade] Running cluster health checks
[upgrade/preflight] You have chosen to upgrade the cluster version to "v1.35.5"
[upgrade/versions] Cluster version: v1.34.4
[upgrade/versions] kubeadm version: v1.35.5
[upgrade] Are you sure you want to proceed? [y/N]: y
[upgrade/preflight] Pulling images required for setting up a Kubernetes cluster
[upgrade/preflight] This might take a minute or two, depending on the speed of your internet connection
[upgrade/preflight] You can also perform this action beforehand using 'kubeadm config images pull'
[upgrade/control-plane] Upgrading your static Pod-hosted control plane to version "v1.35.5" (timeout: 5m0s)...
[upgrade/staticpods] Writing new Static Pod manifests to "/etc/kubernetes/tmp/kubeadm-upgraded-manifests4021411400"
[upgrade/staticpods] Preparing for "etcd" upgrade
[upgrade/staticpods] Renewing etcd-server certificate
[upgrade/staticpods] Renewing etcd-peer certificate
[upgrade/staticpods] Renewing etcd-healthcheck-client certificate
...
...
[addons] Applied essential addon: CoreDNS
[addons] Applied essential addon: kube-proxy
[upgrade] SUCCESS! A control plane node of your cluster was upgraded to "v1.35.5".

[upgrade] Now please proceed with upgrading the rest of the nodes by following the right order.


# Even after Upgrade it still shows the old version
kubectl get nodes
NAME       STATUS   ROLES           AGE   VERSION
master01   Ready    control-plane   89d   v1.34.4
worker01   Ready    worker          89d   v1.34.4

# Updating the Cluster
# This parameter is necessary because you are using emptyDir (ephemeral local storage).
kubectl drain master01 --ignore-daemonsets --delete-emptydir-data

Warning: ignoring DaemonSet-managed Pods: kube-flannel/kube-flannel-ds-qxqqp, kube-system/kube-proxy-qm6qq, metallb-system/metallb-speaker-lsp9j
evicting pod metallb-system/metallb-controller-765c495b75-c757j
evicting pod kube-system/metrics-server-755bdffd6c-trrcm
pod/metallb-controller-765c495b75-c757j evicted
pod/metrics-server-755bdffd6c-trrcm evicted
node/master01 drained

# Update other packages
apt-mark unhold kubectl kubelet
Canceled hold on kubectl.
Canceled hold on kubelet.

# NOTE: If a suggestion window for restarting services appears at the time of the upgrade, deselect the options related to:
👉 kubelet.service
👉 containerd.service

apt install kubectl kubelet
apt-mark hold kubectl kubelet kubeadm


kubectl version
Client Version: v1.35.5
Kustomize Version: v5.7.1
Server Version: v1.35.5

# Now Restart the Service
systemctl restart kubelet

kubectl get nodes
NAME       STATUS                     ROLES           AGE   VERSION
master01   Ready,SchedulingDisabled   control-plane   89d   v1.35.5
worker01   Ready                      worker          89d   v1.34.4

# In the Upgrade process, Kubernetes marks the node to not receive a schedule.
kubectl uncordon master01
node/master01 uncordoned

# Check
kubectl get nodes
NAME       STATUS   ROLES           AGE   VERSION
master01   Ready    control-plane   89d   v1.35.5
worker01   Ready    worker          89d   v1.34.4

```

[Menu](#-menu)

# 🚀 Cluster Upgrade - Control Data / Workers

```bash

# In a similar way to the Control Plane upgrade, it will be followed here:
# -check unhold packages
# -update OS
# -initially mark only kubeadm with unhold
# -update images ( kubeadm upgrade )
# -drain
# -update other components (kubect and kubelet)
# -uncordon
# -restart

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.35/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.35/deb/ /" | tee /etc/apt/sources.list.d/kubernetes.list
apt-get update -y


# List available versions
apt list -a kubeadm
Listing... Done
kubeadm/unknown 1.35.5-1.1 amd64 [upgradable from: 1.34.4-1.1]
kubeadm/unknown 1.35.4-1.1 amd64
kubeadm/unknown 1.35.3-1.1 amd64
kubeadm/unknown 1.35.2-1.1 amd64
kubeadm/unknown 1.35.1-1.1 amd64
kubeadm/unknown 1.35.0-1.1 amd64
kubeadm/now 1.34.4-1.1 amd64 [installed,upgradable to: 1.35.5-1.1]

# How to check packages marked as Hold
# When issuing the command below, packages starting with ( hi ) are marked not to be updated.
dpkg -l | grep kube
hi  kubeadm                          1.34.4-1.1                              amd64        Command-line utility for administering a Kubernetes cluster
hi  kubectl                          1.34.4-1.1                              amd64        Command-line utility for interacting with a Kubernetes cluster
hi  kubelet                          1.34.4-1.1                              amd64        Node agent for Kubernetes clusters
ii  kubernetes-cni                   1.7.1-1.1                               amd64        Binaries required to provision kubernetes container networking

# Upgrade S.O
apt upgrade

# List packages to be updated
# Here it should only show packages (hold)
#
apt list --upgradable
Listing... Done
kubeadm/unknown 1.35.5-1.1 amd64 [upgradable from: 1.34.4-1.1]
kubectl/unknown 1.35.5-1.1 amd64 [upgradable from: 1.34.4-1.1]
kubelet/unknown 1.35.5-1.1 amd64 [upgradable from: 1.34.4-1.1]

# OBS.: Se no momento do upgrade aparecer janela de sugestao para reinicio dos servicos, desmaque as opçoes relacionadas a:
# - kubelet.service
# - containerd.service

# Devo marcar todos como unhold?
# NÃO !!!
# Obs.: Nesse primeiro momento apenas o kubeadm
apt-mark unhold kubeadm
Canceled hold on kubeadm.

# Atualizando kubeadm
apt install kubeadm

# NOTE: If a suggestion window for restarting services appears at the time of the upgrade, deselect the options related to:
👉 kubelet.service
👉 containerd.service

kubeadm version
kubeadm version: &version.Info{Major:"1", Minor:"35", EmulationMajor:"", EmulationMinor:"", MinCompatibilityMajor:"", MinCompatibilityMinor:"", GitVersion:"v1.35.5", GitCommit:"6636cbce3bbef91ff61d36658757179426f9e1b2", GitTreeState:"clean", BuildDate:"2026-05-12T09:53:04Z", GoVersion:"go1.25.9", Compiler:"gc", Platform:"linux/amd64"}

# Unlike the control plane that has the plan , here you must directly issue the upgrade node.
# kubeadm upgrade
kubeadm upgrade node
[upgrade] Reading configuration from the "kubeadm-config" ConfigMap in namespace "kube-system"...
[upgrade] Use 'kubeadm init phase upload-config kubeadm --config your-config-file' to re-upload it.
W0521 06:14:53.191140   37001 utils.go:69] The recommended value for "bindAddress" in "KubeProxyConfiguration" is: ::; the provided value is: 0.0.0.0
[upgrade/preflight] Running pre-flight checks
[upgrade/preflight] Skipping prepull. Not a control plane node.
[upgrade/control-plane] Skipping phase. Not a control plane node.
[upgrade/kubeconfig] Skipping phase. Not a control plane node.
...
...

# Update the other components.
apt-mark unhold kubectl kubelet

# Note:
# Connect to controlPlane and drain worker01
#
kubectl drain worker01 --ignore-daemonsets --delete-emptydir-data
evicting pod metallb-system/metallb-controller-765c495b75-4rfdm
evicting pod default/my-job-ggqs6
evicting pod default/my-job2-jjp4r
evicting pod default/my-job3-x2ht7
evicting pod default/nginx-0
evicting pod default/nginx-1
evicting pod default/nginx-paulo-78455bbb4-kx5w5
evicting pod kube-system/coredns-7d764666f9-9n9gk
evicting pod kube-system/coredns-7d764666f9-d7v9j
evicting pod kube-system/metrics-server-755bdffd6c-sn8g4
evicting pod local-path-storage/local-path-storage-local-path-provisioner-f555d4fc6-qrlqp
...
...
error when evicting pods/"nginx-1" -n "default" (will retry after 5s): Cannot evict pod as it would violate the pod's disruption budget.
error when evicting pods/"nginx-0" -n "default" (will retry after 5s): Cannot evict pod as it would violate the pod's disruption budget.

# I have Pods with PDB enabled.
kubectl get pdb -A
NAMESPACE   NAME        MIN AVAILABLE   MAX UNAVAILABLE   ALLOWED DISRUPTIONS   AGE
default     nginx-pdb   N/A             0                 0                     76d

# Delete PDB
kubectl delete pdb nginx-pdb -n default

kubectl drain worker01 --ignore-daemonsets --delete-emptydir-data
node/worker01 already cordoned
Warning: ignoring DaemonSet-managed Pods: kube-flannel/kube-flannel-ds-zzgvm, kube-system/kube-proxy-gp4kn, metallb-system/metallb-speaker-rhs68
evicting pod default/nginx-1
evicting pod default/nginx-0
pod/nginx-0 evicted
pod/nginx-1 evicted
node/worker01 drained

# Upgrade packages in Worker01
apt install kubectl kubelet

# NOTE: If a suggestion window for restarting services appears at the time of the upgrade, deselect the options related to:
👉 kubelet.service
👉 containerd.service

dpkg -l | grep kube
ii  kubeadm                          1.35.5-1.1                                       amd64        Command-line utility for administering a Kubernetes cluster
ii  kubectl                          1.35.5-1.1                                       amd64        Command-line utility for interacting with a Kubernetes cluster
ii  kubelet                          1.35.5-1.1                                       amd64        Node agent for Kubernetes clusters
ii  kubernetes-cni                   1.8.0-1.1                                        amd64        Binaries required to provision kubernetes container networking

# Mark packets again with hold
apt-mark hold kubectl kubelet kubeadm
kubectl set on hold.
kubelet set on hold.
kubeadm set on hold.

# Now Restart the Service
systemctl restart kubelet

# Note:
# The commands below must be executed in the control plane
kubectl get nodes
NAME       STATUS                     ROLES           AGE   VERSION
master01   Ready,SchedulingDisabled   control-plane   89d   v1.35.5
worker01   Ready                      worker          89d   v1.34.4

# In the Upgrade process, Kubernetes marks the node to not receive a schedule.
kubectl uncordon worker01
node/worker01 uncordoned

# Check
kubectl get nodes
NAME       STATUS   ROLES           AGE   VERSION
master01   Ready    control-plane   89d   v1.35.5
worker01   Ready    worker          89d   v1.35.5
```

[Menu](#-menu)

# 🚀 Dicas - CrashLoopBackOff

```bash
https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/

https://kubernetes.io/docs/concepts/containers/images/#imagepullbackoff

# Usually caused by an application problem (container problem),
# The process started by the command is returning something other than 0
# And a type of error that can be shown in the Pod logs.

cat <<EOF | k apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: chashloop
  name: chashloop
spec:
  replicas: 3
  selector:
    matchLabels:
      app: chashloop
  template:
    metadata:
      labels:
        app: chashloop
    spec:
      containers:
      - image: alpine
        name: chashloop
        command:
          - ls
          - -l
          - abacate
EOF

k get pod
chashloop-5c5b77669f-6xxdj   0/1     CrashLoopBackOff   1 (4s ago)   20s
chashloop-5c5b77669f-hbrfz   0/1     CrashLoopBackOff   1 (3s ago)   20s
chashloop-5c5b77669f-qqsp5   0/1     CrashLoopBackOff   1 (1s ago)   20s


# Describe Pod
k describe pod chashloop-5c5b77669f-qqsp5

# The describe will show the status of the container, and the command it is executing

Controlled By:  ReplicaSet/chashloop-5c5b77669f
Containers:
  chashloop:
    Container ID:  containerd://7c2b4f285e1c1f0f92b410c53135f8b7866bb5f7efe97436220259243b2fe587
    Image:         alpine
    Image ID:      docker.io/library/alpine@sha256:56fa17d2a7e7f168a043a2712e63aed1f8543aeafdcee47c58dcffe38ed51099
    Port:          <none>
    Host Port:     <none>
    Command:
      ls
      -l
      abacate
    State:          Waiting
      Reason:       CrashLoopBackOff
    Last State:     Terminated
      Reason:       Error
      Exit Code:    1
      Started:      Fri, 24 Jan 2025 11:07:48 -0300
      Finished:     Fri, 24 Jan 2025 11:07:48 -0300
    Ready:          False


# Logs can also be consulted

k logs chashloop-5c5b77669f-qqsp5
ls: abacate: No such file or directory
```

[Menu](#-menu)

# 🚀 Dicas - ImagePullBackOff

```bash
# Unable to pull the image

cat <<EOF | k apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: imagepullerror
  name: imagepullerror
spec:
  replicas: 3
  selector:
    matchLabels:
      app: imagepullerror
  template:
    metadata:
      labels:
        app: imagepullerror
    spec:
      containers:
      - image: alpine:paulera
        name: imagepullerror
        command:
          - sleep
          - infinity
EOF


k get pod -o wide
NAME                              READY   STATUS         RESTARTS   AGE   IP            NODE          NOMINATED NODE   READINESS GATES
imagepullerror-7bfdbb568d-52kgd   0/1     ErrImagePull   0          11s   10.244.1.10   prgs-worker   <none>           <none>
imagepullerror-7bfdbb568d-82w45   0/1     ErrImagePull   0          11s   10.244.1.9    prgs-worker   <none>           <none>
imagepullerror-7bfdbb568d-dbk5b   0/1     ErrImagePull   0          11s   10.244.1.8    prgs-worker   <none>           <none>

# NOTE: As it did not transition 1/1, the pod does not generate a log, so I must use describe to identify what happened.

k describe pod imagepullerror-7bfdbb568d-dbk5b

iled to resolve reference "docker.io/library/alpine:paulera": docker.io/library/alpine:paulera: not found
  Warning  Failed     22s (x4 over 2m3s)  kubelet            Error: ErrImagePull
  Normal   BackOff    10s (x6 over 2m3s)  kubelet            Back-off pulling image "alpine:paulera"
  Warning  Failed     10s (x6 over 2m3s)  kubelet            Error: ImagePullBackOff

# Common errors
👉  Certificado https do registry privado
👉  Se o registry usa um certificado auto assinado, esse certificado deve ser importado para dentro do node.
👉  Autenticação

cat <<EOF | k apply -f -
apiVersion: v1
data:
  .dockerconfigjson: xxxxxxxxxxxxxx=
kind: Secret
metadata:
  creationTimestamp: null
  name: regcred
  namespace: web
type: kubernetes.io/dockerconfigjson
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: web
  name: web-deploy
  namespace: web
spec:
  replicas: 5
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      imagePullSecrets:
        - name: regcred
      containers:
      - name: web
        image: registry.meudominio.com/app-web:1.0.0
        imagePullPolicy: Always
EOF
```

[Menu](#-menu)

# 🚀 Dicas - Node NotReady

```bash
```

[Menu](#-menu)

# 🚀 Explorando Documentação - Kubectl

```bash
k explain deployment

k explain deployment.metadata

k explain deployment.spec

k explain deployment.spec.template

k explain deployment.spec.template.spec.containers
```

[Menu](#-menu)


# 🚀 Plugins

```bash
# Krew
# This is package that assists in the installation of plugins.
https://krew.sigs.k8s.io/


k krew search | grep neat
k krew install neat
k krew list

# Neat
# This plugin removes unnecessary information and metadata, such as date and time stamps.

k neat <<< $(k get pods -n kube-system metrics-server-755bdffd6c-trrcm -o yaml)
k neat <<< $(k get pods -n kube-system metrics-server-755bdffd6c-trrcm -o yaml) > /tmp/metric-server.yaml

```
