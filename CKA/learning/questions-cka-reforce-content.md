```bash
1) You need to give a developer read-only access to Pods in the dev namespace only. Which two RBAC resources would you create?
R: Role e RoleBinding

2) Which statement best describes the difference between labels and annotations?
R: Labels can be used for selecting objects, while annotations provide descriptive information but cannot be used for selection

3) Which tool is used to inspect detailed resource usage for a node, such as CPU and memory?
R: kubectl describe node <node-name>

4) A team is testing a feature marked v1beta1. Which of the following statements is correct?
R: it is enabled by default and supports backward compatibility, but may still have bugs

5) You have one base Kubernetes configuration for your application. For your development environment, you want to use a different image tag and increase the number of replicas, but you don’t want to duplicate YAML files. Which tool is most appropriate?
R: Kustomize

6) You configure a Pod with .spec.schedulerName=custom-scheduler, but the custom scheduler is not running in the cluster. What will happen?
R: The Pod will remain in the Pending state indefinitely

7) You apply the following NetworkPolicy in the default namespace. Which Pods will it affect?

spec:
  podSelector:
    matchLabels:
      role: db

R: Only Pods with the label 'role: db' in the default namespace

8) You want to ensure that certain Pods only run on nodes with SSD storage. Which configuration should you use?
R: Add a label such as 'disktype=ssd' to nodes, then use 'nodeSelector' in the Pod spec

9) Which namespace is readable by everyone, including unauthenticated users?
R: kube-public


10) A cluster administrator wants all dynamically provisioned volumes to use SSD storage on Google Cloud by default. Which Kubernetes object must they configure?
R: StorageClass

11) A Pod in your cluster is stuck in Pending state. You have verified logs and networking, but the Pod still won’t schedule. What is the next layer to investigate?
R: Node resource availability and scheduler events


12) Which of the following is a best practice for ensuring reliable traffic distribution across multiple control plane nodes?
R: Configure a TCP pass-through load balancer

13) Your cluster is experiencing high latency in service responses. You suspect the issue spans multiple microservices. Which observability tool would best help you trace requests across these services?
R: Jaeger fiquei em duvida com Metric Server

14) What is the purpose of a headless Service in Kubernetes?
R: A headless Service in Kubernetes is used to discover the individual IPs of each Pod directly, without going through a load balancer or a single IP address (ClusterIP). To omit a ClusterIP and load balancing, allowing direct access to Pod IPs.


15) What does Kubernetes expect from applications for better scalability and resilience?
R: Applications should be designed as transient and decoupled microservices

16) What is a valid reason to deploy Kubernetes on-premises instead of in the cloud?
Select all answers that apply.
R:
b.Improved security
c.Data sovereignty
d.Less network latency

17) Your web application has unpredictable spikes in traffic. Which Kubernetes feature would you configure to automatically add or remove Pods?
R: Horizontal Pod Autoscaler

18) A developer wants to route traffic to two versions of an application (v1 and v2) for testing. They need to send 80% of traffic to v1 and 20% to v2. Which resource should they use?
R: Gateway API with an HTTPRoute defining weighted traffic splitting ( chutei )

19) Your team needs to extend Kubernetes with a new API that supports custom authentication logic and advanced non-RESTful operations. Which approach should you choose?
R: Aggregated APIs

20) Which Kubernetes component runs on each node and manages local firewall rules to route traffic for Services?
R: kube-proxy

21) You are troubleshooting Pod-to-Pod connectivity across nodes. You confirm that each Pod has an IP but cannot reach each other. Which is the most likely issue?
R: The CNI plugin or overlay network is not properly configured

22) Your organization requires that no containers run as the root user. Which of the following settings would enforce this requirement?
R: runAsNonRoot: true

23) An application running in Kubernetes expects its configuration to be provided in a file called app.conf. Which method is most appropriate?
R: Store the configuration in a ConfigMap and mount it as a volume file named 'app.conf'

24) A cluster operator enables the flag --enable-aggregator-routing=true on the kube-apiserver. What functionality does this enable?
R: Support for Aggregated APIs

25) What is the primary purpose of Kubernetes networking?
R: To connect microservices securely across different nodes
