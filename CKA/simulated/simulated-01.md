```text
01)
Solve this question on instance: ssh ckad9999
Namespace: storage-task
Concepts: storage, persistent-volumes, pods
Create a Dynamic PVC named data-pvc with the following specifications:

- Storage Class: standard
- Access Mode: ReadWriteOnce
- Storage Request: 2Gi

Then create a Pod named data-pod using the nginx image that mounts this PVC as volume with name data at /usr/share/nginx/html.

Ensure both the PVC and Pod are in the storage-task namespace.
```

```yml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: data-pvc
  namespace: storage-task
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: standard
  resources:
    requests:
      storage: 2Gi
---
apiVersion: v1
kind: Pod
metadata:
  name: data-pod
  namespace: storage-task
spec:
  containers:
    - name: data-pod
      image: nginx
      volumeMounts:
      - mountPath: "/usr/share/nginx/html"
        name: data
  volumes:
    - name: data
      persistentVolumeClaim:
        claimName: data-pvc
```

https://kubernetes.io/docs/concepts/storage/persistent-volumes/#persistentvolumeclaims


```text
02)
Solve this question on instance: ssh ckad9999
Namespace: storage-class
Concepts: storage, storage-classes
Create a new StorageClass named fast-local with the following specifications:

- Provisioner: rancher.io/local-path
- VolumeBindingMode: WaitForFirstConsumer
- Set it as the default StorageClass

Note: Ensure any existing default StorageClass is no longer marked as default.
```

```bash
kubectl get sc standard -o yaml > 02-storage.yml

kubectl patch storageclass default-test -p '{"metadata": {"annotations": {"storageclass.kubernetes.io/is-default-class": "false"}}}'
kubectl patch storageclass local-path -p '{"metadata": {"annotations": {"storageclass.kubernetes.io/is-default-class": "false"}}}'
```

```yml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: standard
  annotations:
    ingressclass.kubernetes.io/is-default-class: "true"
provisioner: rancher.io/local-path
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
```

https://kubernetes.io/docs/concepts/storage/storage-classes/#storageclass-objects
https://kubernetes.io/docs/tasks/administer-cluster/change-default-storage-class/


```text
03)
Doc em Volumes

Solve this question on instance: ssh ckad9999
Namespace: manual-storage
Concepts: storage, persistent-volumes, node-affinity
Create a PersistentVolume named manual-pv with the following specifications:

- Storage: 1Gi
- Access Mode: ReadWriteOnce
- Host Path: /mnt/data
- Node Affinity: Must run on node k3d-cluster-agent-0

Then create a PersistentVolumeClaim named manual-pvc that binds to this PV.

Finally, create a Pod named manual-pod using the busybox image that mounts this PVC at /data and runs the command sleep 3600.
```

apiVersion: v1
kind: PersistentVolume
metadata:
  name: manual-pv
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: /mnt/data
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - k3d-cluster-agent-0
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: manual-pvc
  namespace: manual-storage
spec:
  storageClassName: ""
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
---
apiVersion: v1
kind: Pod
metadata:
  name: manual-pod
  namespace: manual-storage
spec:
  containers:
  - name: busybox
    image: busybox
    command: ["sleep", "3600"]
    volumeMounts:
    - name: data
      mountPath: /data
  volumes:
  - name: data
    persistentVolumeClaim:
      claimName: manual-pvc

https://kubernetes.io/docs/concepts/storage/volumes/#local
https://kubernetes.io/docs/concepts/storage/persistent-volumes/#reserving-a-persistentvolume
https://kubernetes.io/docs/concepts/storage/persistent-volumes/#claims-as-volumes

========================================================================================

Solve this question on instance: ssh ckad9999
Namespace: scaling
Concepts: autoscaling, deployments, resource-management
Create a Deployment named scaling-app with the following specifications:

- Image: nginx
- Initial replicas: 2
- Resource requests: CPU: 200m, Memory: 256Mi
- Resource limits: CPU: 500m, Memory: 512Mi

Then create a HorizontalPodAutoscaler for this deployment:
- Use apiVersion: autoscaling/v1
- Min replicas: 2
- Max replicas: 5
- Target CPU utilization: 70%

k create deployment --image=ngnix -name xx --dry-run=client -o yaml

apiVersion: apps/v1
kind: Deployment
metadata:
  name: scaling-app
  namespace: scaling
spec:
  replicas: 2
  selector:
    matchLabels:
      app: scaling-app
  template:
    metadata:
      labels:
        app: scaling-app
    spec:
      containers:
      - name: nginx
        image: nginx
        resources:
          requests:
            cpu: 200m
            memory: 256Mi
          limits:
            cpu: 500m
            memory: 512Mi


https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#creating-a-deployment
https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#scaling-a-deployment
https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/

kubectl autoscale deployment -n scaling scaling-app --cpu=70% --min=2 --max=5

========================================================================================

Solve this question on instance: ssh ckad9999
Namespace: scheduling
Concepts: scheduling, node-affinity, deployments
Create a deployment named app-scheduling with 3 replicas using the nginx image that must only run on node k3d-cluster-agent-1 using node affinity (not node selector).

Requirements:
- Use requiredDuringSchedulingIgnoredDuringExecution
- Match the node by its hostname
- Label the target node with disk=ssd before creating the deployment

kubectl label node k3d-cluster-agent-1 disk=ssd

kubectl get nodes --show-labels | grep k3d-cluster-agent-1

apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-scheduling
  namespace: scheduling
spec:
  replicas: 3
  selector:
    matchLabels:
      app: app-scheduling
  template:
    metadata:
      labels:
        app: app-scheduling
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: disk
                operator: In
                values:
                - ssd
      containers:
      - name: nginx
        image: nginx

https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/
https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#built-in-node-labels
https://kubernetes.io/docs/tasks/configure-pod-container/assign-pods-nodes/#add-a-label-to-a-node


========================================================================================

Solve this question on instance: ssh ckad9999
Namespace: security
Concepts: security, pod-security-policy
Configure Pod Security for the security namespace and create a secure nginx pod with nginx image :

1. Create the security namespace with Pod Security Admission (PSA) controls
- Set the namespace to enforce the 'restricted' security profile
- Use the latest version of the security profile

2. Create a secure pod named secure-pod in the security namespace with the following specifications:
- Use the nginx image
- Set the pod-level security context to:
Run as a non-root user with UID 1000
Enable runAsNonRoot

- Configure container-level security context to:
Prevent privilege escalation
Run as non-root user (UID 1000)
Drop ALL Linux capabilities

- Add a volume mount:
Create an emptyDir volume named 'html'
* Mount the volume at '/usr/share/nginx/html'
use default seccomp profile


kubectl label namespace security pod-security.kubernetes.io/enforce=restricted  pod-security.kubernetes.io/enforce-version=latest

apiVersion: v1
kind: Pod
metadata:
  name: secure-pod
  namespace: security
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
    seccompProfile:
      type: RuntimeDefault
  containers:
  - name: nginx
    image: nginx
    securityContext:
      allowPrivilegeEscalation: false
      runAsNonRoot: true
      runAsUser: 1000
      capabilities:
        drop:
          - ALL
  volumes:
  - name: html
    emptyDir: {}


https://kubernetes.io/docs/concepts/security/pod-security-admission/
Link ( Pod Security levels => Security Context )
https://kubernetes.io/docs/concepts/security/pod-security-standards/
https://kubernetes.io/docs/concepts/workloads/pods/#pod-security
https://kubernetes.io/docs/tasks/configure-pod-container/enforce-standards-namespace-labels/
https://kubernetes.io/docs/tasks/configure-pod-container/security-context/
https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-pod


========================================================================================

Solve this question on instance: ssh ckad9999
Namespace: scheduling
Concepts: scheduling, taints, tolerations
Configure node k3d-cluster-agent-1 with a taint key=special-workload, value=true and effect=NoSchedule.

Then create a deployment named toleration-deploy with 2 replicas using the nginx image that can tolerate this taint.

Finally, create another deployment named normal-deploy with 2 replicas that should not run on the tainted node.

Solution
kubectl taint node k3d-cluster-agent-1 special-workload=true:NoSchedule
apiVersion: apps/v1
kind: Deployment
metadata:
  name: toleration-deploy
  namespace: scheduling
spec:
  replicas: 2
  selector:
    matchLabels:
      app: toleration-deploy
  template:
    metadata:
      labels:
        app: toleration-deploy
    spec:
      tolerations:
      - key: "special-workload"
        operator: "Equal"
        value: "true"
        effect: "NoSchedule"
      containers:
      - name: nginx
        image: nginx
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: normal-deploy
  namespace: scheduling
spec:
  replicas: 2
  selector:
    matchLabels:
      app: normal-deploy
  template:
    metadata:
      labels:
        app: normal-deploy
    spec:
      containers:
      - name: nginx
        image: nginx










========================================================================================

Solve this question on instance: ssh ckad9999
Namespace: stateful
Concepts: statefulsets, headless-services, storage
Create a StatefulSet named web with 3 replicas using the nginx image. Requirements:

- Create a headless service named web-svc to expose the StatefulSet
- Each pod should have a volume mounted at /usr/share/nginx/html
- Use the StorageClass cold for dynamic provisioning
- Volume claim template should request 1Gi storage

Ensure pods are created in sequence and can be accessed using their stable network identity.

bash kubectl create namespace stateful

apiVersion: v1
kind: Service
metadata:
  name: web-svc
  namespace: stateful
spec:
  clusterIP: None
  selector:
    app: web
  ports:
  - port: 80
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: web
  namespace: stateful
spec:
  serviceName: web-svc
  replicas: 3
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: nginx
        image: nginx
        volumeMounts:
        - name: www
          mountPath: /usr/share/nginx/html
  volumeClaimTemplates:
  - metadata:
      name: www
    spec:
      accessModes: ["ReadWriteOnce"]
      storageClassName: cold
      resources:
        requests:
          storage: 1Gi

========================================================================================

Solve this question on instance: ssh ckad9999
Namespace: dns-debug
Concepts: dns, service-discovery, networking
Set up DNS service discovery testing environment:

1. Create a deployment named web-app with 3 replicas using nginx image

2. Create a ClusterIP service named web-svc to expose the deployment

3. Create a Pod named dns-test using the busybox image that will:
- Run the command wget -qO- http://web-svc && wget -qO- http://web-svc.dns-debug.svc.cluster.local && sleep 36000
- Verify it can resolve both the service DNS (web-svc.dns-debug.svc.cluster.local)
- Verify it can resolve pod DNS entries
4. Create a ConfigMap named dns-config with custom search domains for the test pod

Solution
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
  namespace: dns-debug
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
    spec:
      containers:
      - name: nginx
        image: nginx
---
apiVersion: v1
kind: Service
metadata:
  name: web-svc
  namespace: dns-debug
spec:
  selector:
    app: web-app
  ports:
  - port: 80
---
apiVersion: v1
kind: Pod
metadata:
  name: dns-test
  namespace: dns-debug
spec:
  containers:
  - name: busybox
    image: busybox
    command:
    - sh
    - -c
    - "wget -qO- http://web-svc && wget -qO- http://web-svc.dns-debug.svc.cluster.local && sleep 36000"
  dnsConfig:
    searches:
    - dns-debug.svc.cluster.local
    - svc.cluster.local
    - cluster.local
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: dns-config
  namespace: dns-debug
data:
  search-domains: |
    search dns-debug.svc.cluster.local svc.cluster.local cluster.local

========================================================================================

Solve this question on instance: ssh ckad9999
Namespace: dns-config
Concepts: dns, service-discovery, networking
Set up basic DNS service discovery:

1. Create a deployment named dns-app with 2 replicas using the nginx image
2. Create a service named dns-svc to expose the deployment
3. Create a Pod named dns-tester using the infoblox/dnstools image that:
- Runs the command to test DNS resolution of the service
- Verifies both service DNS (dns-svc.dns-config.svc.cluster.local)
- Stores the test results in /tmp/dns-test.txt inside the pod

Note: The test results should include both the service DNS resolution and FQDN resolution.

Solution
# Create the deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: dns-app
  namespace: dns-config
spec:
  replicas: 2
  selector:
    matchLabels:
      app: dns-app
  template:
    metadata:
      labels:
        app: dns-app
    spec:
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
---
# Create the service
apiVersion: v1
kind: Service
metadata:
  name: dns-svc
  namespace: dns-config
spec:
  selector:
    app: dns-app
  ports:
  - port: 80
    targetPort: 80
---
# Create the DNS tester pod
apiVersion: v1
kind: Pod
metadata:
  name: dns-tester
  namespace: dns-config
spec:
  containers:
  - name: dns-tester
    image: infoblox/dnstools
    command:
    - sh
    - -c
    - |
      nslookup dns-svc > /tmp/dns-test.txt
      nslookup dns-svc.dns-config.svc.cluster.local >> /tmp/dns-test.txt
      sleep 3600

To verify the setup:

# Check if service is resolvable
kubectl exec -n dns-config dns-tester -- cat /tmp/dns-test.txt

# Verify deployment is running
kubectl get deployment -n dns-config dns-app

# Check service endpoints
kubectl get endpoints -n dns-config dns-svc

========================================================================================

Solve this question on instance: ssh ckad9999
Namespace: helm-test
Concepts: helm, package-management
Using Helm:

1. Add the bitnami repository https://charts.bitnami.com/bitnami
2. Install the nginx chart from bitnami with release name web-release in namespace helm-test
3. Configure the service type as NodePort and set the replica count to 2
4. Verify the deployment is successful and pods are running

Solution
# Add bitnami repo
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Install nginx chart
helm install web-release bitnami/nginx \
  --namespace helm-test \
  --set service.type=NodePort \
  --set replicaCount=2

========================================================================================

Solve this question on instance: ssh ckad9999
Namespace: kustomize
Concepts: kustomize, configuration-management
Using Kustomize: in the directory /tmp/exam/kustomize/

1. Create a base deployment for nginx with 2 replicas
2. Create an overlay that:
- Adds a label environment=production
- Increases replicas to 3
- Adds a ConfigMap named nginx-config with key index.html and value Welcome to Production, mount config map as volume named nginx-index
3. Apply the overlay to create resources in the kustomize namespace

Solution
First, create the directory structure:

mkdir -p /tmp/exam/kustomize/base
mkdir -p /tmp/exam/kustomize/overlays/production
Create base files:

# /tmp/exam/kustomize/base/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
spec:
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
      - name: nginx
        image: nginx
        volumeMounts:
        - name: nginx-index
          mountPath: /usr/share/nginx/html/
      volumes:
      - name: nginx-index
        configMap:
          name: nginx-config

# /tmp/exam/kustomize/base/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- deployment.yaml

# /tmp/exam/kustomize/overlays/production/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: kustomize
bases:
- ../../base
patches:
- patch: |
    - op: replace
      path: /spec/replicas
      value: 3
  target:
    kind: Deployment
    name: nginx
commonLabels:
  environment: production
configMapGenerator:
- name: nginx-config
  literals:
  - index.html=Welcome to Production
Apply the configuration:

kubectl create namespace kustomize
kubectl apply -k /tmp/exam/kustomize/overlays/production/
Verify the deployment:

kubectl get deployments -n kustomize
kubectl get configmaps -n kustomize
kubectl get pods -n kustomize

========================================================================================

Solve this question on instance: ssh ckad9999
Namespace: gateway
Concepts: gateway-api, networking
Configure Gateway API resources:

1. Create a Gateway named main-gateway listening on port 80
2. Create an HTTPRoute to route traffic to a backend service:
- Path: /app1 should route to service app1-svc port 8080
- Path: /app2 should route to service app2-svc port 8080
3. Create two deployments (app1 and app2) with corresponding services to test the routing

Solution
apiVersion: gateway.networking.k8s.io/v1beta1
kind: Gateway
metadata:
  name: main-gateway
  namespace: gateway
spec:
  gatewayClassName: standard
  listeners:
  - name: http
    port: 80
    protocol: HTTP
---
apiVersion: gateway.networking.k8s.io/v1beta1
kind: HTTPRoute
metadata:
  name: app-routes
  namespace: gateway
spec:
  parentRefs:
  - name: main-gateway
  rules:
  - matches:
    - path:
        value: /app1
    backendRefs:
    - name: app1-svc
      port: 8080
  - matches:
    - path:
        value: /app2
    backendRefs:
    - name: app2-svc
      port: 8080
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app1
  namespace: gateway
spec:
  replicas: 1
  selector:
    matchLabels:
      app: app1
  template:
    metadata:
      labels:
        app: app1
    spec:
      containers:
      - name: nginx
        image: nginx
---
apiVersion: v1
kind: Service
metadata:
  name: app1-svc
  namespace: gateway
spec:
  selector:
    app: app1
  ports:
  - port: 8080
    targetPort: 80
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app2
  namespace: gateway
spec:
  replicas: 1
  selector:
    matchLabels:
      app: app2
  template:
    metadata:
      labels:
        app: app2
    spec:
      containers:
      - name: nginx
        image: nginx
---
apiVersion: v1
kind: Service
metadata:
  name: app2-svc
  namespace: gateway
spec:
  selector:
    app: app2
  ports:
  - port: 8080
    targetPort: 80

========================================================================================

Solve this question on instance: ssh ckad9999
Namespace: limits
Concepts: resource-management, limitrange, resourcequota
Configure resource management:

1. Create a LimitRange in namespace limits with:
- Default request: CPU: 100m, Memory: 128Mi
- Default limit: CPU: 200m, Memory: 256Mi
- Max limit: CPU: 500m, Memory: 512Mi

2. Create a ResourceQuota for the namespace:
- Max total CPU: 2
- Max total memory: 2Gi
- Max number of pods: 5

3. Create a deployment named test-limits with 2 replicas to verify the limits are applied

Solution
apiVersion: v1
kind: LimitRange
metadata:
  name: resource-limits
  namespace: limits
spec:
  limits:
  - type: Container
    default:
      cpu: 200m
      memory: 256Mi
    defaultRequest:
      cpu: 100m
      memory: 128Mi
    max:
      cpu: 500m
      memory: 512Mi
---
apiVersion: v1
kind: ResourceQuota
metadata:
  name: compute-quota
  namespace: limits
spec:
  hard:
    cpu: "2"
    memory: 2Gi
    pods: "5"
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test-limits
  namespace: limits
spec:
  replicas: 2
  selector:
    matchLabels:
      app: test-limits
  template:
    metadata:
      labels:
        app: test-limits
    spec:
      containers:
      - name: nginx
        image: nginx

========================================================================================

Solve this question on instance: ssh ckad9999
Namespace: monitoring
Concepts: monitoring, resource-management, autoscaling
Create a deployment named resource-consumer with 3 replicas that:

1. Uses the image gcr.io/kubernetes-e2e-test-images/resource-consumer:1.5
2. Sets resource requests:
- CPU: 100m
- Memory: 128Mi
3. Sets resource limits:
- CPU: 200m
- Memory: 256Mi
4. Create a HorizontalPodAutoscaler for this deployment:
- Min replicas: 3
- Max replicas: 6
- Target CPU utilization: 50%

Note: metrics-server is already installed in the cluster.

Solution
apiVersion: apps/v1
kind: Deployment
metadata:
  name: resource-consumer
  namespace: monitoring
spec:
  replicas: 3
  selector:
    matchLabels:
      app: resource-consumer
  template:
    metadata:
      labels:
        app: resource-consumer
    spec:
      containers:
      - name: resource-consumer
        image: gcr.io/kubernetes-e2e-test-images/resource-consumer:1.5
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 200m
            memory: 256Mi
---
apiVersion: autoscaling/v1
kind: HorizontalPodAutoscaler
metadata:
  name: resource-consumer
  namespace: monitoring
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: resource-consumer
  minReplicas: 3
  maxReplicas: 6
  targetCPUUtilizationPercentage: 50

========================================================================================

Solve this question on instance: ssh ckad9999
Namespace: cluster-admin
Concepts: rbac, service-accounts, security
Perform the following cluster administration tasks:

1. Create a ServiceAccount named app-admin in the cluster-admin namespace
2. Create a Role that allows:
- List, get, watch operations on pods and deployments
- Create and delete operations on configmaps
- Update operations on deployments
3. Bind the Role to the ServiceAccount
4. Create a test Pod named admin-pod that uses this ServiceAccount with:
- Image: bitnami/kubectl:latest
- Command: sleep 3600
- Mount the ServiceAccount token as a volume

Verify the pod can perform the allowed operations but cannot perform other operations (like creating pods).

Solution
apiVersion: v1
kind: ServiceAccount
metadata:
  name: app-admin
  namespace: cluster-admin
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: app-admin
  namespace: cluster-admin
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["list", "get", "watch"]
- apiGroups: ["apps"]
  resources: ["deployments"]
  verbs: ["list", "get", "watch", "update"]
- apiGroups: [""]
  resources: ["configmaps"]
  verbs: ["create", "delete"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: app-admin
  namespace: cluster-admin
subjects:
- kind: ServiceAccount
  name: app-admin
  namespace: cluster-admin
roleRef:
  kind: Role
  name: app-admin
  apiGroup: rbac.authorization.k8s.io
---
apiVersion: v1
kind: Pod
metadata:
  name: admin-pod
  namespace: cluster-admin
spec:
  serviceAccountName: app-admin
  containers:
  - name: kubectl
    image: bitnami/kubectl:latest
    command: ["sleep", "3600"]
    volumeMounts:
    - name: token
      mountPath: /var/run/secrets/kubernetes.io/serviceaccount
  volumes:
  - name: token
    projected:
      sources:
      - serviceAccountToken:
          expirationSeconds: 3600
          audience: kubernetes.default.svc

========================================================================================

Solve this question on instance: ssh ckad9999
Namespace: network
Concepts: networking, network-policies, security
Configure network policies:

1. Create a deployment named web using nginx image with label app=web
2. Create a deployment named api using nginx image with label app=api
3. Create a deployment named db using postgres image with label app=db and environment variable POSTGRES_HOST_AUTH_METHOD=trust
4. Create NetworkPolicies to:
- Allow web to communicate only with api
- Allow api to communicate only with db
- Deny all other traffic between pods

Solution
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
  namespace: network
spec:
  replicas: 1
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: nginx
        image: nginx
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api
  namespace: network
spec:
  replicas: 1
  selector:
    matchLabels:
      app: api
  template:
    metadata:
      labels:
        app: api
    spec:
      containers:
      - name: nginx
        image: nginx
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: db
  namespace: network
spec:
  replicas: 1
  selector:
    matchLabels:
      app: db
  template:
    metadata:
      labels:
        app: db
    spec:
      containers:
      - name: postgres
        image: postgres
        env:
        - name: POSTGRES_HOST_AUTH_METHOD
          value: trust
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: web-policy
  namespace: network
spec:
  podSelector:
    matchLabels:
      app: web
  policyTypes:
  - Egress
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: api
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: api-policy
  namespace: network
spec:
  podSelector:
    matchLabels:
      app: api
  policyTypes:
  - Egress
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: web
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: db
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: db-policy
  namespace: network
spec:
  podSelector:
    matchLabels:
      app: db
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: api


========================================================================================

Solve this question on instance: ssh ckad9999
Namespace: upgrade
Concepts: deployments, rolling-updates, rollback
Perform a rolling update:

1. Create a deployment named app-v1 with 4 replicas using nginx:1.19
2. Perform a rolling update to nginx:1.20 with:
- Max unavailable: 1
- Max surge: 1
3. Record the update
4. Save the output of kubectl rollout history deployment app-v1 -n upgrade to /tmp/exam/rollout-history.txt
5. Roll back to the previous version

Solution
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-v1
  namespace: upgrade
spec:
  replicas: 4
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 1
  selector:
    matchLabels:
      app: app-v1
  template:
    metadata:
      labels:
        app: app-v1
    spec:
      containers:
      - name: nginx
        image: nginx:1.19
# Perform update
kubectl set image deployment/app-v1 nginx=nginx:1.20 -n upgrade --record

# Save rollout history
kubectl rollout history deployment app-v1 -n upgrade > /tmp/exam/rollout-history.txt

# Rollback
kubectl rollout undo deployment/app-v1 -n upgrade

========================================================================================

Solve this question on instance: ssh ckad9999
Namespace: scheduling
Concepts: scheduling, priority, anti-affinity
Configure advanced scheduling:

1. Create a pod named high-priority with PriorityClass priority 1000
2. Create a pod named low-priority with PriorityClass priority 100
3. Configure pod anti-affinity to ensure these pods don't run on the same node
4. Create enough resource pressure to trigger pod eviction and observe priority behavior

Note for Testing Resource Pressure:
- Use a resource-intensive image like polinux/stress to generate load
- Example: Create a pod with command: stress -c 4 -m 2 --vm-bytes 1G to consume CPU and memory
- Deploy multiple instances of resource-heavy pods to simulate node resource exhaustion

Solution
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: high-priority
value: 1000
---
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: low-priority
value: 100
---
apiVersion: v1
kind: Pod
metadata:
  name: high-priority
  namespace: scheduling
  labels:
    priority: high  # ✅ Add this
spec:
  priorityClassName: high-priority
  containers:
  - name: nginx
    image: nginx
  affinity:
    podAntiAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchExpressions:
          - key: priority
            operator: In
            values:
            - high
            - low
        topologyKey: kubernetes.io/hostname
---
apiVersion: v1
kind: Pod
metadata:
  name: low-priority
  namespace: scheduling
  labels:
    priority: low  # ✅ Add this
spec:
  priorityClassName: low-priority
  containers:
  - name: nginx
    image: nginx
  affinity:
    podAntiAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchExpressions:
          - key: priority
            operator: In
            values:
            - high
            - low
        topologyKey: kubernetes.io/hostname

========================================================================================

Solve this question on instance: ssh ckad9999
Namespace: troubleshoot
Concepts: troubleshooting, debugging, deployment-configuration
A deployment named failing-app has been created in the namespace troubleshoot but pods are not running. The deployment uses image nginx:1.25 and should have 3 replicas.

Fix the following issues:

1. The deployment is using an incorrect container port (port 8080 instead of 80)
2. The pods are failing due to insufficient memory (current limit is 64Mi, should be 256Mi)
3. There's a misconfigured liveness probe checking port 8080 instead of 80

Ensure all pods are running successfully after applying the fixes.

Solution
apiVersion: apps/v1
kind: Deployment
metadata:
  name: failing-app
  namespace: troubleshoot
spec:
  replicas: 3
  selector:
    matchLabels:
      app: failing-app
  template:
    metadata:
      labels:
        app: failing-app
    spec:
      containers:
      - name: nginx
        image: nginx:1.25
        ports:
        - containerPort: 80  # Fixed from 8080
        resources:
          limits:
            memory: 256Mi    # Fixed from 64Mi
        livenessProbe:
          httpGet:
            path: /
            port: 80        # Fixed from 8080
          initialDelaySeconds: 15
          periodSeconds: 10
















2=================

Helm Docs Custom Resources

Solve this question on: ssh cka7968

Install cert-manager using Helm in Namespace cert-manager. Then configure and create a ClusterIssuer resource:

    Create Namespace cert-manager

    Install Helm chart jetstack/cert-manager (with crds.enabled=true) into the new Namespace. The Helm Release should be called cert-manager

    Update the ClusterIssuer resource in /course/2/cluster-issuer.yaml to include crlDistributionPoints: ["http://example.com/crl"] under spec.selfSigned

    Create the ClusterIssuer resource from /course/2/cluster-issuer.yaml

    ℹ️ It is not required for cert-manager to issue real certificates. Installing the Helm Chart and the ClusterIssuer resource as requested is enough
===============
4
Pod Quality of Service Classes Node-pressure Eviction

Solve this question on: ssh cka2556

Check all available Pods in the Namespace project-c13 and find the names of those that would probably be terminated first if the nodes run out of resources (cpu or memory).

Write the Pod names into /course/4/pods-terminated-first.txt.
===========================
5
Horizontal Pod Autoscaling Kustomize

Solve this question on: ssh cka5774

Previously the application api-gateway used some external autoscaler which should now be replaced with a HorizontalPodAutoscaler (HPA).
The application has been deployed to Namespaces api-gateway-staging and api-gateway-prod like this:

kubectl kustomize /course/5/api-gateway/staging | kubectl apply -f -
kubectl kustomize /course/5/api-gateway/prod | kubectl apply -f -

Using the Kustomize config at /course/5/api-gateway do the following:

    Remove the ConfigMap horizontal-scaling-config completely
    Add HPA named api-gateway for the Deployment api-gateway with min 2 and max 4 replicas. It should scale at 50% average CPU utilisation
    In prod the HPA should have max 6 replicas
    Apply your changes for staging and prod so they're reflected in the cluster

===========================
7
Tools for Monitoring Resources kubectl Quick Reference

Solve this question on: ssh cka5774

The metrics-server has been installed in the cluster. Write two bash scripts which use kubectl:

    Script /course/7/node.sh should show resource usage of nodes
    Script /course/7/pod.sh should show resource usage of Pods and their containers

=========================
9
Accessing the Kubernetes API from a Pod Configure Service Accounts for Pods

Solve this question on: ssh cka9412

There is ServiceAccount secret-reader in Namespace project-swan. Create a Pod of image nginx:1-alpine named api-contact which uses this ServiceAccount.

Exec into the Pod and use curl to manually query all Secrets from the Kubernetes API.

Write the result into file /course/9/result.json.
==========================
13
Gateway API Gateway API Documentation

Solve this question on: ssh cka7968

The team from Project r500 wants to replace their Ingress (networking.k8s.io) with a Gateway API (gateway.networking.k8s.io) solution. The old Ingress is available at /course/13/ingress.yaml.

Perform the following in Namespace project-r500 and for the already existing Gateway:

    Create a new HTTPRoute named traffic-director which replicates the routes from the old Ingress
    Extend the new HTTPRoute with path /auto which forwards to mobile backend if the User-Agent is exactly mobile and to desktop backend otherwise

The existing Gateway is reachable at http://r500.gateway:30080 which means your implementation should work for these commands:

curl r500.gateway:30080/desktop
curl r500.gateway:30080/mobile
curl r500.gateway:30080/auto -H "User-Agent: mobile"
curl r500.gateway:30080/auto


=======================================
14
Certificate Management with kubeadm

Solve this question on: ssh cka9412

Perform some tasks on cluster certificates:

    Check how long the kube-apiserver server certificate is valid using openssl or cfssl. Write the expiration date into /course/14/expiration. Run the kubeadm command to list the expiration dates and confirm both methods show the same one
    Write the kubeadm command that would renew the kube-apiserver certificate into /course/14/kubeadm-renew-certs.sh

========================================
15
Network Policies Declare Network Policy

Solve this question on: ssh cka7968

There was a security incident where an intruder was able to access the whole cluster from a single hacked backend Pod.

To prevent this create a NetworkPolicy called np-backend in Namespace project-snake. It should allow the backend-* Pods only to:

    Connect to db1-* Pods on port 1111
    Connect to db2-* Pods on port 2222

Use the app Pod labels in your policy.

    ℹ️ All Pods in the Namespace run plain Nginx images. This allows simple connectivity tests like: k -n project-snake exec POD_NAME -- curl POD_IP:PORT

    ℹ️ For example, connections from backend-* Pods to vault-* Pods on port 3333 should no longer work
=======================================
16
Customizing DNS Service DNS for Services and Pods

Solve this question on: ssh cka5774

The CoreDNS configuration in the cluster needs to be updated:

    Make a backup of the existing configuration YAML and store it at /course/16/coredns_backup.yaml. You should be able to fast recover from the backup
    Update the CoreDNS configuration in the cluster so that SERVICE.NAMESPACE.custom-domain resolves the same as SERVICE.NAMESPACE.cluster.local (in addition to it)

Test your configuration for example from a Pod with busybox:1 image. These commands should result in an IP address:

nslookup kubernetes.default.svc.cluster.local
nslookup kubernetes.default.svc.custom-domain
=================================================
17
Debug with crictl

Solve this question on: ssh cka2556

In Namespace project-tiger create a Pod named tigers-reunite of image httpd:2-alpine with labels pod=container and container=pod. Find out on which node the Pod is scheduled. Ssh into that node and find the containerd container belonging to that Pod.

Using command crictl:

    Write the ID of the container and the info.runtimeType into /course/17/pod-container.txt

    Write the logs of the container into /course/17/pod-container.log

    ℹ️ You can connect to a worker node using ssh cka2556-node1 or ssh cka2556-node2 from cka2556
