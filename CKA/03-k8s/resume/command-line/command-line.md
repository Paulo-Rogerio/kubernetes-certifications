# 🚀 Menu

- [Command Line - Contexts](#-command-line---contexts)
- [Command Line - Nodes](#-command-line---nodes)
- [Command Line - Explorando API](#-command-line---explorando-api)
- [Create Object - Pod](#-create-object---pod)
- [Create Object - StaticPod](#-create-object---staticpod)
- [Create Object - Init Containers](#-create-object---init-containers)
- [Create Object - Replace Entrypoint](#-create-object---replace-entrypoint)
- [Create Object - Multi Containers](#-create-object---multi-containers)
- [Create Object - Acessando Pod Sem Kubectl Via Nsenter](#-create-object---acessando-pod-sem-kubectl-via-nsenter)
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
- [Create Object - Types Secrets](#-create-object---types-secrets)
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
- [Create Object - Role ServiceAccount + RolingBindgings](#-create-object---role-serviceaccount--rolingbindgings)
- [Create Object - Affinity / Node-Selector Labels](#-create-object---affinity--node-selector-labels)
- [Create Object - Affinity / Node-Affinity](#-create-object---affinity--node-affinity)
- [Create Object - Affinity / Pod-Affinity](#-create-object---affinity--pod-affinity)
- [Create Object - Affinity / PodAntiAffinity](#-create-object---affinity--podantiaffinity)
- [Create Object - Affinity / Tolerations](#-create-object---affinity--tolerations)
- [Cluster Upgrade - Ferramentas e Boas Práticas](#-cluster-upgrade---ferramentas-e-boas-práticas)
- [Cluster Upgrade - Control Plane / Masters](#-cluster-upgrade---control-plane--masters)
- [Cluster Upgrade - Control Data / Workers](#-cluster-upgrade---control-data--workers)
- [Explorando Documentação - Kubectl](#-explorando-documentação---kubectl)

# 🚀 Command Line - Contexts

```bash
k config get-contexts
k config set-context <name-context> --namespace='<namespace>'
k config set-context kubernetes-admin@kubernetes --namespace='metallb-system'
k config set-context kubernetes-admin@kubernetes --namespace=''

# Aplica-se ao contexto current
k config set-context --current --namespace=default

# Merge 2 kubeconfig
kubectl config view --flatten

KUBECONFIG=~/.kube/config:~/.kube/kube_outro_cluster_config kubectl config view --flatten > ~/.kube/kube-merge

# AWS ( EKS )
aws eks update-kubeconfig --dry-run --name paulo --region us-east-2
```
[Índice](#-menu)

# 🚀 Command Line - Nodes

```bash
k get nodes

# Ip Node
k get nodes -o wide

# Manifestos do Node
k get nodes -o yaml

# Precisa-se no Metric Server.
# O fato de ter o MetalLB deployado permite export ExternalIP
k top nodes

helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm repo update
helm upgrade \
  --install \
  --namespace kube-system \
  --create-namespace metrics-server metrics-server/metrics-server \
  --set-string args[0]=--kubelet-insecure-tls \
  --set-string args[1]="--kubelet-preferred-address-types=InternalIP\,Hostname\,ExternalIP"

# Definir Label ( Rótulo )
nodes=$(kubectl get nodes --no-headers | awk '$3 == "<none>" {print $1}')
for i in ${nodes[@]}
do
  kubectl label node ${i} node-role.kubernetes.io/worker=""
done

# Não schedular nenhum pod no worker
kubectl cordon worker01
kubectl uncordon worker01
```
[Índice](#-menu)

# 🚀 Command Line - Explorando API

```bash
# Nivel de verbosidade + alto
k get pods -A -v9

# Visualizando o Certificados
kubectl config view --raw -o jsonpath='{.users[?(@.name=="kind-prgs")].user.client-certificate-data}' \
| base64 -d \
| openssl x509 -text -noout

# Extraindo Certificados
base64 -d <<< $(kubectl config view --raw -o jsonpath='{.users[?(@.name=="kind-prgs")].user.client-key-data}') > prgs.key

base64 -d <<< $(kubectl config view --raw -o jsonpath='{.users[?(@.name=="kind-prgs")].user.client-certificate-data}') > prgs.crt

base64 -d <<< $(kubectl config view --raw -o jsonpath='{.clusters[?(@.name=="kind-prgs")].cluster.certificate-authority-data}') > ca.crt

port=$(docker inspect prgs-control-plane \
  --format='{{(index (index .NetworkSettings.Ports "6443/tcp") 0).HostPort}}')

curl --cacert ca.crt --cert prgs.crt --key prgs.key  "https://127.0.0.1:${port}/api/v1/pods?limit=500"


# Consulmindo a API
kubectl config view --raw -o jsonpath='{.users[0].user.client-certificate-data}' | base64 -d > /tmp/cert.crt
kubectl config view --raw -o jsonpath='{.users[0].user.client-key-data}' | base64 -d > /tmp/cert.key
curl \
  -k \
  --cert /tmp/cert.crt \
  --key /tmp/cert.key \
  --cacert /etc/kubernetes/pki/ca.crt \
  https://127.0.0.1:6443/api/v1/pods?limit=500

openssl x509 -in /tmp/cert.crt -text

# Consultando Usando Rotas anonimas
curl -k https://127.0.0.1:6443/version
curl -k https://127.0.0.1:6443/healthz
curl -k https://127.0.0.1:6443/livez
curl -k https://127.0.0.1:6443/readyz

# Check se Cluster aceita rotas anonimas
cat /etc/kubernetes/manifests/kube-apiserver.yaml | grep anonymous

# List Pods
k get pod

# Lista todos pod em todos Namespaces
k get pod -A

# Extrair manifestos
kubectl get pods -n kube-system etcd-master01 -o json
kubectl get pods -n kube-system etcd-master01 -o yaml

# Labels
k get pod -A --show-labels
k get pod -n kube-system etcd-master01
k get pod -A -l <label>=<value>
k get pod -A -l component=etcd

# Ip Pods.
k get pod -A -o wide

# "Assistindo" mudanças em tempo real.
k get pod -A -w

k edit pod -n kube-system etcd-master01
k describe pod -n kube-system etcd-master01
k delete pod -n kube-system etcd-master01

# Logs
k logs -n <namespace> <pod>
k logs -n kube-system etcd-master01

# Conectar no container
k exec -it -n <namespace> <pod> -- bash
k exec -it -n kube-flannel kube-flannel-ds-77m55 -- bash
k exec -it -n kube-flannel kube-flannel-ds-77m55 -- bash -c "pwd; ls"
```

[Índice](#-menu)

# 🚀 Create Object - Pod

Para muitos exemplos abaixo, foram usado alguns plugins, mais explicitamente o **neat**, veja o materia de [Dicas](https://github.com/Paulo-Rogerio/kubernetes-certifications/blob/main/CKA/03-k8s/exercises/dicas/dicas.md).

```bash
# Criar Resources
k apply -f <file-name.yml>

# Pega tudo do diretorio current
k apply -f .
k apply -f ./<dir>

# Criar de um URL
k apply -f https://<url>

# Retorna uma lista de objetos e se eles são Globais ou vinculados a um namespace
kubectl api-resources

# Run
# Cria o Pod ,e ao ser encerrado, já o deleta
k run <pod-name> --image=<image-name> --rm
k run demo --image alpine --rm -it -- sh

# Cria um YAML de um deploy de um Pod com um service do tipo ClusterIP
# Por default ao explicitar o --expose, e criado apeanas Cluster IP
k run demo --image nginx --port=80 --expose --dry-run=client -o yaml

# Se quiser criar service to tipo NodePort?
# Apos criado, aplicar patch para determinar uma porta alta.
# Padrão:30000-32767
#
k run demo --image nginx --port=80
k expose pod demo --port=80 --target-port=80 --type=NodePort
k patch svc demo -p '{"spec":{"ports":[{"port":80,"targetPort":80,"nodePort":30007}]}}'

# Se precisar mudar o range?
# kubectl get pods -n kube-system kube-apiserver-master01 -o yaml
# Adicione a entrada
# - --service-node-port-range=20000-40000
```
[Índice](#-menu)

# 🚀 Create Object - StaticPod

```bash

# Todos os pod que contem manifesto yaml nesse path é um staticPod
ls /etc/kubernetes/manifests/

# Static Pods , não é gerido pelo scheduler ( api server ), pois isso aqui é um processo exclusivo do kubelet
# O kubelete ( componete que roda no node ) é o piloto que comanda eles.

systemctl list-units --type=service --state=active
systemctl status kubelet

# O kubelete foi programado para ler qualquer manifesto existente em /etc/kubernetes/manifests
# Observer que nos workers ( trabalhadores ), esse diretório é vazio.

# Se colocarmos qualquer manifesto dentro desse diretorio do worker , ele iniciará imediatamente
# Se tentar matar ele é recriado

# Usando especificamente pelo controlplane. Por ser estático dentro do worker , NÃO É ESCALAVEL.
```
[Índice](#-menu)

# 🚀 Create Object - Init Containers

```bash

# O que são os init Containers?
# Container init, não fazem parte do processo principal do pod, geralmente são ações que fazem determinadas tarefas pre-requistos ( ex: clonar um repo ).

# Como simular?
# Essa image busybox é uma imagem que contem os binários essencias do linux , mas não é uma distro onde consegue rodar comandos do apt/yum/apk

k run --image busybox --rm -it demo sh

# Executa enquanto for falso
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

# Crie o service em outro TTY
# Apos essa ação o script acima comeca a responder.

k create service clusterip mymysql --tcp=80:80
k delete svc mymysql


# Aplicando ...

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

# Posso ter varios init containers, e somente quando ele finalizar ( passar ), é que o container real da aplicação será executado.

k get pods
nginx   0/1     Init:0/1   0          25s

k logs nginx
Defaulted container "nginx" out of: nginx, waitfordns (init)
Error from server (BadRequest): container "nginx" in pod "nginx" is waiting to start: PodInitializing

# Nesse contexto é criado 2 containers no mesmo pod ( nginx => aplicação e waitfordns que é meu pre-deploy )
# Para mim ler os logs desse "pre-deploy" chamado waitfordns

k logs nginx -c waitfordns -f
Clone repo....
```
[Índice](#-menu)

# 🚀 Create Object - Replace Entrypoint

```bash
# Pod irá subir e logo apos morrer, pois entrypoint espera um comando
# Ex: terraform plan , terraform apply
#
k neat <<< $(k run --image hashicorp/terraform terraform --dry-run=client -o yaml) | k apply -f -

# Definir sleep grande
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

# Definir While true infinito
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
[Índice](#-menu)

# 🚀 Create Object - Multi Containers

```bash

# Criar multiplos containers no mesmo Pod.

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

# Acessando container debug
k exec -it multicontainers -c debug -- sh
ps fax
```
[Índice](#-menu)

# 🚀 Create Object - Acessando Pod Sem Kubectl Via Nsenter

```bash
# Onde está rodando o deploy?
k get pods -o wide


# Instalar o pacote jq
apt update && apt install jq
crictl ps | grep multicontainers

# Acessando um Pod sem kubectl , para isso conecte-se via ssh ao worker onde o Pod está rodando
# e use o crictl, esse cara sai da abstração dos pods.
crictl ps | grep multicontainers

dfa92a11e4461       a40c03cbb81c5       22 hours ago        Running             debug               0                   73cd0774bbfec       multicontainers         default
84cdb66aba237       5cdef4ac3335f       22 hours ago        Running             nginx               0                   73cd0774bbfec       multicontainers         default

# Acessando diretamente o container
crictl exec -it dfa92a11e4461 sh

# Outra forma de acessar esse pod é usando ( nsenter )
# nsenter ( Namespace Enter => Se digitado sozinho entre no prompt do primeiro container da lista )
# Network namespace => Rodar o comando dentro da network namespace desse processo
nsenter --help

# Acessando o Pod que roda o processo do sleep dentro da perpectiva do Pod, na mesma network namespace
#
# Busque pela coluna ContainerID
crictl inspect dfa92a11e4461 | jq -r '.info.pid'
148192

# **** OBS.: **** Se NAO PASSAR O "-n" ( perpectiva do container , usando a network namespace ), o comando usara
# a perpectiva  do host ( network do host ) e não conseguirá chegar no serviço
nsenter -t 148192 -n ls /
nsenter -t 148192 -n curl localhost
```
[Índice](#-menu)

# 🚀 Create Object - Pod Lifecycle

```bash

# https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/

# Um Pod recebe um prazo para terminar graciosamente, que é de 30 segundos por padrão. Ou seja a aplicação deve subir nesse intervalo de tempo e sair com status code 0 .

# Apos esse 30 segundos o kubelet envia um sinal de sigkill para aplicaçao , e mata o processo na hora.

# Podemos manipular esse ciclo de vida, configurar um yaml para sempre que receber um sigterm, seja realizado uma ação com um pouco mais do padrao 30 segundos

# Ex:
kubectl get pods nginx -o wide
nginx   1/1     Running   0          42h   10.244.1.12   worker01   <none>           <none>

# Subir outro deploy com lifecycle
# Ao ser encerrado, antes de encerrar esse pod ira enviar um curl para Nginx
# Podia ser uma notificação no slack informando que Pod foi reciclado.

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

# Monitore os Logs
k logs nginx -f

# Ao matar o Pod ( pod-lifecycle ) devo receber um curl nos logs acima.
kubectl delete pod pod-lifecycle -n default

# Deve-se receber uma notificação no logs do pod Nginx
10.244.1.16 - - [23/Feb/2026:14:27:47 +0000] "GET / HTTP/1.1" 200 615 "-" "curl/8.14.1" "-"


# Se o commando (curl / script ) demorar mais que 30 secundos para executar , posso ajustar isso definindo
# terminationGracePeriodSeconds: 60 com um valor que satisfaça minha necessidade.

```
[Índice](#-menu)

# 🚀 Create Object - Namespace

```bash
cat <<EOF | k apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: prgs
EOF

# É um objeto Global
k api-resources | grep namespace

# Criando via linha de comando
k create ns familia

# Caso não lembre como declarar o manifesto
k neat <<< $(k create ns familia --dry-run=client -o yaml)
k neat <<< $(k create ns familia --dry-run=client -o yaml)
```
[Índice](#-menu)

# 🚀 Create Object - Deployment

```bash
# Deployment   => Aplicação stateless ( Aplicação escaláveis )
# Staless, nao depende de um estado.
# Statless é a capacidade da aplicação ser escalavel.

k create deployment --image=nginx nginx-paulo

k neat <<< $(k get deployment nginx-paulo -o yaml)

# O deployment garante que o pod seja recriado, mesmo que Pod seja deletado.
k delete pod nginx-paulo-5b98995fcc-25zj6

k delete deployment nginx-paulo

# Isso aqui é mais limpo
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
[Índice](#-menu)

# 🚀 Create Object - Scale Deployment

```bash
k scale --help
k scale deployment nginx-paulo --replicas 10
```
[Índice](#-menu)

# 🚀 Create Object - Request Limits

```bash
# Memoria => Limits   ( Hard ) => 1G
#         => Requests ( Soft ) => 200M

# CPU     => Limits   ( Hard )
#         => Requests ( Soft )

# Soft limit => É o limite que o sistema realmente aplica no momento.
# Um processo pode abrir 1024 descriptors
ulimit -n
1024

ulimit -n 4096
4096

# Hard Limit => É o teto máximo que o Soft pode alcancar.

# Um processo pode 1.048.576 arquivos/sockets simultaneos
# Esse É o teto máximo que o Soft pode alcancar
ulimit -Hn
1048576

# ==========================================================================
# É o recurso disponível no Worker ( Onde irá receber a carga de trabalho )
# Obs.:
# Request é usado sempre quando um pod é colocado dentro de um node.
# Ele é levado em conta na escolha do node onde será colocado o pod.
# Kube-schedules é quem decide em qual worker meu pod vai rodar, ele avalia os recursos.
# ==========================================================================
#
# Quando defino quantidade de Request, e esse numero que o scheduler levaria em conta para determinar em qual worker o pod
# vai trabalhar. Definido em 200M por ex, caso o worker tenha 500MB ele colocaria , pois ta dentro do valor que woker pode suportar.

# Manifest Request: 1 cpu / 4 GB Ram
k apply -f manifesto.yaml

# O scheduler só vai agendar esse Pod em um node que tenha pelo menos 1 CPU e 4 GB de Ram disponível

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

# Como ler a capacidade do Node?
k get nodes
k describe node <node-name>
k top nodes

# CPU:
# É informada em numero quantidade vcpu ou em porcentagem
# 100m ( 10 % da cpu ) milicpu ou milicore
# 0.1  ( 10% da cpu  )
# Memoria:
# É informada em M/G ex: 500M
```
[Índice](#-menu)

# 🚀 Create Object - Resources Limits

```bash

k explain
k explain deployment.spec
k explain deployment.spec.template
k explain deployment.spec.template.spec
k explain deployment.spec.template.spec.containers
k explain deployment.spec.template.spec.containers.resources
k explain deployment.spec.template.spec.containers.resources.requests

# Cgroup => Limites de recursos dos containers
#
# Cgroups (Control Groups) são um recurso do kernel Linux que permitem:
# - Limitar CPU
# - Limitar memória
# - Limitar I/O
# - Controlar número de processos
# - Medir consumo
# - Containers (Docker, containerd, CRI-O) usam cgroups para aplicar esses limites.

# Nomeclatura manifestos Yaml
# 100m ( 10 % da cpu ) mili-cpu / mili-core
# 0.1  ( 10% da cpu )
# Memoria é informada em M/G ex: 500M

# Se o container ultrapassar 64MB definido
# 👉 O kernel executa OOM Killer
# 👉 O container morre

# Mas não definir limit?
# 👉 O container pode consumir toda memória do node
# 👉 Pode causar OOM global
# 👉 Pode matar outros pods

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
[Índice](#-menu)

# 🚀 Create Object - ReplicaSet

```bash
# É um objeto no Cluster, responsável por garantir um número específico de Pods esteja rodando sempre em execução.

# Recuperar o manifesto
k neat <<< $(k get deployment nginx-paulo -o yaml)

k get rs
NAME                    DESIRED   CURRENT   READY   AGE
nginx-paulo-78455bbb4   1         1         1       12m

# Substituir Imagem, forca a troca do replicaset.
k neat <<< $(k get deployment nginx-paulo -o yaml) | sed 's/image: nginx/image: httpd/' | k apply -f -

k get rs
NAME                     DESIRED   CURRENT   READY   AGE
nginx-paulo-78455bbb4    0         0         0       14m
nginx-paulo-7bd98bdb44   1         1         1       26s

# Os replicaset zerados é mantido para fins de restore.
# Quem cria os replicaset são os Deployments
#
# Como o ReplicaSet sabe onde deve deployar?
# R: As label tem o proposito de nortear o replicaset para que ele identifique qual Pod ele irá gerenciar.
# Ela tambem é usada para direcionar que um pod possa deployar em determinado worker.
# O deployment gerencia os Pods vinculados a uma determinada label, isso por conta do matchLabels.
#
# Label escopo deployment

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

# Mostrar as labels apenas para escopo do deployment
k get deployment --show-labels
NAME          READY   UP-TO-DATE   AVAILABLE   AGE   LABELS
nginx-paulo   1/1     1            1           27m   app=nginx-paulo,environment=development

k get pods --show-labels
NAME                           READY   STATUS    RESTARTS   AGE   LABELS
nginx-paulo-7bd98bdb44-p9qk8   1/1     Running   0          15m   app=nginx-paulo,pod-template-hash=7bd98bdb44

Se eu quiser add label para pod tenho que fazer isso abaixo do objeto spec

# Definir Labels no escopo do Pod

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

# Filtrando por label
k get pod -l app=nginx-paulo
k get pod -n kube-system -l k8s-app=kube-dns
```
[Índice](#-menu)

# 🚀 Create Object - ReplicaSet Rollout

```bash

# Quais sao meus replicaset?
k get rs
NAME                     DESIRED   CURRENT   READY   AGE
nginx-paulo-78455bbb4    0         0         0       38m
nginx-paulo-7bd98bdb44   1         1         1       24m

# Histórico Rollout
k rollout history deployment/nginx-paulo
deployment.apps/nginx-paulo
REVISION  CHANGE-CAUSE
1         <none>
2         <none>

# Caso queira acompanhar em tempo real um rollout
watch kubectl rollout status deployment/nginx-paulo

# Fazendo undo para voltar para versao anterior
k rollout undo deployment/nginx-paulo --to-revision=1
deployment.apps/nginx-paulo rolled back

# Check novamente Histórico Rollout
k rollout history deployment/nginx-paulo
deployment.apps/nginx-paulo
REVISION  CHANGE-CAUSE
2         <none>
3         <none>

# Quais sao meus replicaset?
k get rs
NAME                     DESIRED   CURRENT   READY   AGE
nginx-paulo-78455bbb4    1         1         1       42m
nginx-paulo-7bd98bdb44   0         0         0       28m

# Checando que voltou para imagem nginx.
k get pods nginx-paulo-78455bbb4-pssgv -o yaml | grep image:

# Como ver o conteúdo de uma revision?
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

# Como saber qual revision está em execução

k get rs
NAME                     DESIRED   CURRENT   READY   AGE
nginx-paulo-78455bbb4    0         0         0       38m
nginx-paulo-7bd98bdb44   1         1         1       24m

k get rs nginx-paulo-78455bbb4 -o yaml | grep deployment.kubernetes.io/revision
  deployment.kubernetes.io/revision: "3"
  deployment.kubernetes.io/revision-history: "1"

# Reiniciar todos os Pods do Deployment nginx-paulo
k rollout restart deployment/nginx-paulo
```
[Índice](#-menu)

# 🚀 Create Object - Rollout maxSurge / maxUnavailable

```bash
# Por padrao o rollout sobe 25% dos pods ( nova release ) e a medida que esse pods ficam health,
# ele vai matando proporcionalmente a mesma quantidade ( 25% ) do replicaset antigo.

# Resumo:
# Comeca 25% dos pods novos
# Termina 25% dos pods velhos

# Imagine que temos 100 Pod rodando, ele iria nesse cenário subir 25% a mais ou seja, eu teria 125 Pod rodando.
# E quando esses novos pods estirem health ai sim ele mataria os 25 Pods antigos.

# Suponhamos que queira personalizar esse rollout quando uma nova release entrar no ar, e ter a seguinte característica:

# O que preciso ter em mente é:

# maxSurge => Numero maximo de pods que podem ser agendados para rollout acima do desejado, ou seja, se desejado e 100
# essa opçao subiriria 100 novos pods.
# Sendo:
# 100 Pods ( replicaset velho ) + 100 Pods ( replicaset novo) = 200 Pods

# maxUnavailable => Numero de pods que podem ficar indisponiveis durant um rollout.
# Se definido para 0 , ele não derruba nenhum pod até que os novos fiquem heath.

# Objeto que trata a estrategia de deploy ( Documentação )
k explain deployment.spec.strategy
k explain deployment.spec.strategy.rollingUpdate


# Boa estratégia
# Não derruba nenhum pod enquanto algum do novo replicaset fique heath
# Faz 1 a 1 ( replace )

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
[Índice](#-menu)

# 🚀 Create Object - Liveness / Readness Probes

```bash
#=================================================
# ReadinessProbe => Pronto para receber o trafego.
#=================================================
#
# O Ready garante que uma consulta get em alguma rota "/health" responda com status code 200 para comecar a receber trafego, então o Pod é transacionado para 1/1. Isso acontece no startup do pod.

#=================================================
# LivenessProbe => Garante que a aplicação ainda está viva.
#=================================================
#
# O Live garantir que a applicação continue viva live, monitora essa rota "/health" durante o tempo de vida do pod.
# Se a app travar por algum motivo e esse cara que transaciona o pod para 0/1.
# Nesse momento o pod é reiniciado para voltar ficar 1/1


k explain deployment.spec.template.spec.containers

k explain deployment.spec.template.spec.containers.readinessProbe

k explain deployment.spec.template.spec.containers.readinessProbe.httpGet

k explain deployment.spec.template.spec.containers.livenessProbe

# Simulando Cenario - Readness

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

# Apesar de estar Running o pod nao ficará disponivel até que esteja 1/1
# Porque ele ficará assim 0/1?
# Essa rota /health não é uma rota válida, entao esse pod Jamais ficará 1/1
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


# A correção é ajustar o path para "/"

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

# PARA simular o livesproble vamos remover o arquivo html do nginx para gerar error.
k exec -it nginx-paulo-699b6ff548-sprc2 -- bash -c "rm -f /usr/share/nginx/html/index.html"

# O pod receberá erro no log, e liveness vai tentar 3x e apos isso ele ira reiniciar o Pod.
k get pods -w
nginx-paulo-699b6ff548-sprc2   0/1     Running   1 (2s ago)   2m3s

# Boas práticas

k explain deployment.spec.template.spec.containers
k explain deployment.spec.template.spec.containers.env

https://12factor.net/
```
[Índice](#-menu)

# 🚀 Create Object - Daemonset

```bash
#=====================================================================
# Características:
# Daemonset => 1 Pod em cada Node ( Geralmente coletores de logs )
# Daemonset não se define o numero de replicas no manifestos.
# Daemonset será igual ao numero de nodes de um cluster.
# Daemonset não passa pelo kube-scheduler
#
# Caso de usos:
# Coletor de Logs => precisa rodar a nivel de host.
# CNI             => Roda a nivel do host
# Patch           => Aplicar um determinado patch
#=====================================================================

# Para logs geralmente é montado a pasta /var/log do host dentro do DaemonSet ( pod )

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

# O label mostra dessa forma ( kubernetes.io/hostname=worker01 ),
# mas na declaração do yaml definimos assim ( kubernetes.io/hostname: "worker01" )

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


# Rodar em Um node especifico.
k patch daemonset nginx-paulo -p '
spec:
  template:
    spec:
      nodeSelector:
        node-role.kubernetes.io/worker: ""
'
daemonset.apps/nginx-paulo patched


# Mesmo aplicando o patch o k8s manteve as 2 roles declaradas "Node Selector",
# isso acontece porque o K8s não substitui, ele faz merge ( apenda ). NodeSelector é um AND e não um OR.
#
k get daemonset
NAME          DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR                                                     AGE
nginx-paulo   1         1         1       1            1           kubernetes.io/hostname=worker01,node-role.kubernetes.io/worker=   2m22s


# Deixar apenas 1 Node Selector
k edit daemonsets nginx-paulo

# OBS.:
# Daemonset o troubleshouting é igual ao um Pod.
# Daemonset não possui subcomandos de Create. Não possui gerenciador Direto
# Pode-se cria-lo como um deployment, mas deve-se remover replicas e altera o Kind para DaemonSet
#
# Isso irá deployar em todos os Nodes
k neat <<< $(k create deployment --image=nginx nginx-paulo --dry-run=client -o yaml) | sed 's/Deployment/DaemonSet/;/replicas:/d' | k apply -f -

# Como não foi explicitado em qual node rodar, foi exchedulado o pod nos 2 nodes.
k get ds
NAME          DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
nginx-paulo   2         2         2       2            2           <none>          3s


# Rodar em Um node especifico ( Patch ).
k patch daemonset nginx-paulo -p '
spec:
  template:
    spec:
      nodeSelector:
        node-role.kubernetes.io/worker: ""
'
daemonset.apps/nginx-paulo patched

# Apos aplicado o patch
k get ds
NAME          DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR                     AGE
nginx-paulo   1         1         1       1            1           node-role.kubernetes.io/worker=   88s

k explain daemonset --recursive | less
k explain daemonset.spec
```
[Índice](#-menu)

# 🚀 Create Object - Statefullset

```bash
# StateFull => Depende totalmente do estado
# Ex: Uma aplicação que autentica usuarios, e determinado usuário logado tem uma seção conectado em um pod,
# ao ser redirecionado a outro pod, essa sessão autenticada, pode não funcionar.
#
# Redis para armazenar a sessão do usuario resolveria essa treta.
#
# A aplicação depende totalmente de estado.
# Quanto mais a app usa/depende do sistema de arquivos, mais statefull ela é.
#
# A tendencia e adequar a aplicação para que ela não dependa desses estados e que possa ser maleável.
#
# OBS.:
# Statefullset => A escalada tem que ser mais caltelosa ,cada pod tem seu volume, escala na ordem certa Ex: Banco de Dados )
# Statefullset => É gerido pelo kube-scheduler
# Statefullset => É um deployment controlado. Ele sempre segue a ordem de subir um e matar um. Sempre um por um.
# Ex: jenkins, vault
#
# Como identificar um statefullset fazendo um ( k get pods )?
# Geralmente o nome do pod tem um prefixo ex: jenkins-0
# Os nomes são sempre previsíveis, se meu deployment chama nginx, os Pods terão nomes: ( nginx-0, nginx-1 )
#
# Statefullset => Cada Pod com seu respectivo PVC
# Mesmo que o Pod ( nginx-2 ) morra, quando ele subir novamente, somente ele irá acessar esse dados.
# nginx-1 => pvc do nginx-1
# nginx-2 => pvc do nginx-2
# nginx-3 => pvc do nginx-3
#
#============================================================
# Um detalhe importante é quando exponho um statefullset, diferentemente de um deploymente que cria-se um service,
# esse cara trabalha diferente, ele cria um Headless Service ( Diferente de um Service comum não tem IP ),
# esse cara é um resolvedor de nomes que conhece todas as replicas ( nginx-1, nginx-2, nginx-3 ), ele não tem IP.
# Esse DNS retorna todos os IPs dos statefull ( nginx-1, nginx-2, nginx-3 ) e o cliente que requisitou escolhe em qual ele quer se conectar.
#============================================================

# Instalar Local-Path
# https://github.com/rancher/local-path-provisioner/tree/master/deploy/chart/local-path-provisioner

git clone https://github.com/rancher/local-path-provisioner.git
cd local-path-provisioner
helm install local-path-storage --create-namespace --namespace local-path-storage ./deploy/chart/local-path-provisioner/
helm list -A

# Listar StorageClass
k get sc -A

# Check Se StorageClass e default
k describe sc -n local-path-storage local-path

k edit sc -n local-path-storage local-path
storageclass.kubernetes.io/is-default-class: true

# Doc
# https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/

# Explicando Construção YAML de um PVC
k explain statefulsets.spec
k explain statefulsets.spec.volumeClaimTemplates
k explain statefulsets.spec.volumeClaimTemplates.spec
k explain statefulsets.spec.volumeClaimTemplates.metadata

# Modo de acesso ( Link )
k explain statefulsets.spec.volumeClaimTemplates.spec.accessModes

# Recursos Computacionais ( Link )
k explain statefulsets.spec.volumeClaimTemplates.spec.resources

#===================================================
# OBS.: O próprio StatefulSet cria automaticamente os PVCs a partir de volumeClaimTemplates
#===================================================

# Ex:
volumeClaimTemplates:
- metadata:
    name: nginx-html
  spec:
    accessModes: [ "ReadWriteOnce" ]
    resources:
      requests:
        storage: 1G


# Agora dentro do spec eu preciso definir como será montado dentro do container

k explain statefulsets.spec.template.spec.containers
k explain statefulsets.spec.template.spec.containers.volumeMounts

spec:
  containers:
  - image: nginx
    name: nginx
    volumeMounts:
    - name: nginx-html
      mountPath: "/usr/share/nginx/html"

# OBS.:
# StatefulSet o troubleshouting é igual ao um Pod.
# StatefulSet não possui subcomandos de Create. Não possui gerenciador Direto
# Pode-se cria-lo como um deployment, mas deve-se remover replicas e altera o Kind para StatefulSet
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

# No kind o path fica armazendo no seguinte lugar (ls /var/local-path-provisioner/)
#
ssh root@worker01 ls /opt/local-path-provisioner
pvc-5e022a02-521f-4f6b-906b-870992018639_default_nginx-html-nginx-0
pvc-e7a97210-ef2c-488b-979a-9ae4bf75ecdd_default_nginx-html-nginx-1

# Observe que não tem Ip atrelado ao service.
# Ele apenas cria registros DNS individuais para cada Pod
# nginx-0.nginx.default.svc.cluster.local
# nginx-1.nginx.default.svc.cluster.local

k get svc nginx
NAME    TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
nginx   ClusterIP   None         <none>        80/TCP    4d4h

# Alimente o ponto de montagem Nginx-0
kubectl exec -it nginx-0 -- bash -c "echo 'abacate' > /usr/share/nginx/html/index.html"

# k port-forward pod/<pod-name> <Minha-Porta>:<Porta-App>
k port-forward pod/nginx-0 8181:80

# Em outro terminal ao fazer um curl sempre obterá a resposta "abacate", pois o forward foi a nivel do Pod.

# Alimente o ponto de montagem Nginx-1
kubectl exec -it nginx-1 -- bash -c "echo 'morango' > /usr/share/nginx/html/index.html"

k port-forward svc/nginx 8181:80

kubectl exec -it nginx-1 -- bash -c "echo 'abacate' > /usr/share/nginx/html/index.html"

# Nome dos containers
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

# Observer que o serviço faz round-robin entre os 2 statefulset
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
# Caso não crie os PVC antes de criar a regra do Taint, o que aconteceria?
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

# Possiveis Problemas...
# PVC accessModes: [ "ReadWriteOnce" ], não possui node afinity explicito no manifesto,
# entao o PVC poderia facilmente montar 2 volumes distintos no mesmo worker.

k get pvc
k describe pvc nginx-html-nginx-1
k get pv
k describe pv pvc-003a61ee-f231-474a-9902-9300cf230553

# PVC zuado....
# Problema foi que tem uma regra de afinidade para o PV, mas temos um taint que bloqueia schedule no control-plane
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
[Índice](#-menu)

# 🚀 Create Object - PDB / PodDisruptionBudget

```bash
# É um objeto do cluster que garanti que um POD nunca fique indisponível
# Mais usado com statefulset

k api-resources | grep disrup
poddisruptionbudgets                pdb          policy/v1                         true         PodDisruptionBudget

# Com esse recurso consigo dizer ao k8s que dos 100% dos meus pods quero 90% sempre disponível.
# Ou quantas replicas indisponível eu posso tolerar, Ex: se tenho 3 replicas , tolero a perca de 2 no máximo.
#
# Isso é uma proteção contra o node ser drenado
#
# Doc:
https://kubernetes.io/docs/tasks/run-application/configure-pdb/

k explain poddisruptionbudget
k explain poddisruptionbudget.spec

# maxUnavailable => Maximo que aceito como não disponível
# minAvailable   => Minimo que tem que está disponível

# Listar se tenho PBD habilitado
k get pdb

# Checar as labels do meus pod
k get pod --show-labels
NAME      READY   STATUS    RESTARTS      AGE   LABELS
nginx-0   1/1     Running   1 (27m ago)   47h   app=nginx,apps.kubernetes.io/pod-index=0,controller-revision-hash=nginx-6cb5bc47cd,statefulset.kubernetes.io/pod-name=nginx-0
nginx-1   1/1     Running   1 (27m ago)   47h   app=nginx,apps.kubernetes.io/pod-index=1,controller-revision-hash=nginx-6cb5bc47cd,statefulset.kubernetes.io/pod-name=nginx-1

#=======================================================================
# DESSA FORMA EU NAO ESTOU INFERINDO QUE NENHUM POD FIQUE INDISPONIVEL.
#=======================================================================
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

# Esse cara aplica o cordon ( Marca o node para nao aceitar novos pods )
# Depois comeca dar o evict ( Pegar todos os pods rodando nesse worker e jogar para outro node )
# O pod (statefulset) nao conseguiu ser migrado devido a regra de pdb
k drain worker01 --ignore-daemonsets --delete-emptydir-data
node/worker01 cordoned
Warning: ignoring DaemonSet-managed Pods: kube-flannel/kube-flannel-ds-zzgvm, kube-system/kube-proxy-fg27m, metallb-system/metallb-speaker-rhs68
evicting pod local-path-storage/local-path-storage-local-path-provisioner-f555d4fc6-l4n2q
evicting pod default/nginx-1
evicting pod default/nginx-0

# O Node foi marcado para nao receber nenhum schedule
k get nodes
NAME       STATUS                     ROLES           AGE   VERSION
master01   Ready                      control-plane   12d   v1.34.4
worker01   Ready,SchedulingDisabled   worker          12d   v1.34.4

# Pods ainda rodando
k get pods
NAME      READY   STATUS    RESTARTS      AGE
nginx-0   1/1     Running   1 (38m ago)   2d
nginx-1   1/1     Running   1 (38m ago)   2d

# Para resolver eu devo deleta o PDB
k delete pdb nginx-pdb

# Agora sim consigo fazer o drain
k drain worker01 --ignore-daemonsets --delete-emptydir-data
node/worker01 already cordoned
Warning: ignoring DaemonSet-managed Pods: kube-system/kindnet-6vxfh, kube-system/kube-proxy-jrxg8, metallb-system/metallb-speaker-9vkng
evicting pod default/nginx-1
pod/nginx-1 evicted
node/worker01 drained

# Apos concluir o processo, garanta que o node possa receber agendamentos de Pod
k uncordon worker01
node/worker01 uncordoned

k get nodes
NAME       STATUS   ROLES           AGE   VERSION
master01   Ready    control-plane   12d   v1.34.4
worker01   Ready    worker          12d   v1.34.4
```
[Índice](#-menu)

# 🚀 Create Object - Jobs

```bash
# Batch Jobs ( Executa 1x só )
# Job => Executa um Pod => Durante a execução seu status e Running => Após finalizado transita para Completed => Tchau
#
k get job -A

# Sempre é mantido os 3 ultimas execuçoes de cronjobs ( k get pods )

# Doc
https://kubernetes.io/docs/concepts/workloads/controllers/job/

k api-resources | grep jobs
k explain
k explain jobs.spec
k explain jobs.spec.ttlSecondsAfterFinished
k explain jobs.spec.template
k explain jobs.spec.template.spec.restartPolicy

# Manifesto
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
# Job é imultável, uma vez criado nao consigo aplicar o manifesto para sobrepor seu conteudo.
# E necessário deletar o conteudo antigo.
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

# Outra forma de ver o Log
# Pegue o Id do Pod gerado pelo Job
k logs $(k get pods -l job-name=my-job2 -o name)
```
[Índice](#-menu)

# 🚀 Create Object - CronJobs

```bash
# Se eu precisar executar isso todo os dias?
# CronJob => Cria o Job => Cria o Pod ( Running ) => Após finalizado transita para Completed
#
# Exemplo
# https://github.com/mateusmuller/elasticsearch-delete-indices-7-days

k get cronjob -A

k explain cronjobs.spec

k neat <<< $(k create cronjob my-cronjob --image=prgs/alpine-jobs:latest --schedule="*/1 * * * *" --dry-run=client -o yaml) | k apply -f -

k get cronjob
k get job
k get pods -

# Outra forma de ver o Log
# Pegue o Id do Pod gerado pelo Job
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

# Pegando dinamicament
kubectl logs $(kubectl get jobs --sort-by=.metadata.creationTimestamp -o name | tail -1)
```
[Índice](#-menu)

# 🚀 Create Object - Services Tipos

```bash
# A comunicação interna dentro do k8s e os acessos não acontece diretamente no Pod.
# Eu me comunico por meio de um services.
# Comunicaçao interna ( 2 pods no mesmo namespace se comunicam por meio de service Cluster IP ).
# Service é a forma como me comunico com cluster seja interno ou externamente.
#
# DNS Name ( Service Discovery )

# ============================= Cluster IP ========================================
# Cluster IP é apenas para comunicação interna dentro do cluster.
# Ao criar o service , vc indica o selector e ele ja sabe para quem enviar a requisição.

k get svc kubernetes -o yaml

# name       => Nome do meu serviço ( rails-services ) esse Nome que o cluster faz busca de DNS para descobrir o serviço.
# port       => A porta que o service do k8s irá escutar
# targetPort => A porta que a aplicação ouve. Aqui ele redireciona tudo que chega na 80 manda para 3000
# selector   => Isso que fara match no Deployment, ele que defini onde será enviado a requisição.
# Isso se da por meio das labels
# Ex:
# --port ( É a porta do service )
# --target-port ( É a porta do nginx rodando no container )

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
# Como a resolução de nomes acontece quando estou em outra namespace?
#************************************************************************
#
# Apenas por FQDN
# Executando Pod no namespace kube-system
k run --namespace kube-system --image alpine --rm -it teste-curl sh

# Isso ( OK )
ping -c 2 mymysql.default.svc.cluster.local

# Isso ( Não Responde )
ping -c 2 mymysql

#************************************************************************
# Como criar um service via linha de comando?
#************************************************************************
#
# Criar um deployment
k create deployment --image=nginx nginx-paulo
k expose deployment nginx-paulo --port=80 --type='ClusterIP' --target-port=80

#************************************************************************
# Como que um service sabe chegar em um Pod?
#************************************************************************
#
# Por meios dos endpoints
# Esse comando ( endpoints ) vai ser deprecado em futuras versoes ( 1.33+ )
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
# Pouco usado
# Range => 30000-32767
# Se eu escolher a porta 30000, essa porta é aberta em cada um dos nodes.
# Para acessar eu preciso informar o Ip do Node:Porta Alta
# Finalidade ( testes e demos )

# ============================== LoadBalancer =====================================
#
# Constuma-se ter um L.B por aplicação
# Se utilizar esse service para expor sua app para mundo, lembre-se que cada endpoint terá seu L.B
# Ideal para TCP / UDP ( Layer 4 )

# Obs.:
# Se estou trabalhando na camada de aplicação http ( Layer 7 )
# o Gateway Api ( Falecido Ingress ) é a melhor alternativa, pois usa-se apenas
# um único LoabBalancer e cria rotas e endpoints de acesso.

# ============================== External Name ====================================
#
# Services => ( CNAME ) => DNS
# É um service usado para resolver nomes.
# Suponhamos que use RDS da AWS te entregue uma URL ( Endpoint ), mas vc não quer usar esse DNS que AWS te mandou,
# pois se ela mudar terá que sair redeployando toda suas apps.
#
# Então vc pode criar esse service ( External Name ) para criar um DNS válido dentro do Cluster
#
# Service , seria seu serviço ex: "db" que nada mais é que um cname para ( DNS URL da AWS ),
# assim quando sua URL de banco mudar voce so muda nesse service e sua app continua igual como antes.
#
# Toda a parte do services é feito no node

# ============================== Headless Service =================================
#
# Já falamos sobre esse serviço em ( Create Object - Statefullset ), porém aqui vamos trata-lo de forma isolada.

Headless Service, é um clusterIp sem IP, isso é usando expecificamente em statefullset e a busca é realizada por DNS

O serviçe continua sendo um clusterIp , porém defino ( ClusterIP como None )

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
EOF

k get pods
NAME      READY   STATUS    RESTARTS   AGE
nginx-0   1/1     Running   0          16s
nginx-1   1/1     Running   0          14s

k get svc
NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   78m
nginx        ClusterIP   None         <none>        80/TCP    28s

# Isso aqui não é um balanceamento de carga, pois eu resolvo direto pro pod.
#
# A chave para isso funcionar é definir o serviceName
spec:
  serviceName: "nginx"

# Para consumir ( Nome do Pod . Nome do Service ) Ex: nginx-0.nginx

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
[Índice](#-menu)

# 🚀 Create Object - Ipvs Vs Iptables

```bash
# Kubernetes Componetes
https://kubernetes.io/docs/concepts/overview/components/

# Kube-Proxy Comandos Referência
https://kubernetes.io/docs/reference/command-line-tools-reference/kube-proxy/

# =================================== IPVS ========================================
#
# Como checar se está usando Iptables ou Ipvs?
# - Caso esteja usando a interface tem o prefixo ipvs
# - Aqui as insterfaces tem a nomeclatura ( ipvs )
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
# Cloud Provides ( AWS ) usa iptables para rotear trafego entre os pods

# ================================= Como Alterar ==================================
#
# Como alterar o modo de roteamente?
# O provedor de cloud suporta isso?
#
# O kube-proxy é configurado por meio de um configmap

k get cm -n kube-system
NAME                                                   DATA   AGE
coredns                                                1      4h13m
extension-apiserver-authentication                     6      4h13m
kube-apiserver-legacy-service-account-token-tracking   1      4h13m
kube-proxy                                             2      4h13m
kube-root-ca.crt                                       1      4h13m
kubeadm-config                                         1      4h13m
kubelet-config                                         1      4h13m

# Por padrao o kind opera com Iptables
#
k neat <<< $(k get cm -n kube-system kube-proxy -o yaml) | grep mode
mode: iptables

# Garantir que os modulos do kernel estejam habilitados
modprobe ip_vs
modprobe ip_vs_rr
modprobe ip_vs_wrr
modprobe ip_vs_sh
modprobe nf_conntrack

# Quando alterar é necessário reciclar os nodes.
k edit cm -n kube-system kube-proxy -o yaml

kubectl rollout restart daemonset kube-proxy -n kube-system

# ================================= Debug Iptables ==================================

# Por default essa imagem expoe a porta 80
k create deployment --image nginx --replicas 3 nginx

# Criando um service do tipo ClusterIP 8080 e redireciona para porta 80
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
# A forma de Debug é a mesma , independente do serviço. Deixei separado por service type, apenas para fins de organização.
#
docker exec -it prgs-control-plane bash

root@prgs-control-plane:/# iptables-save > /tmp/iptables
root@prgs-control-plane:/# egrep '10.96.175.117' /tmp/iptables

-A KUBE-SERVICES -d 10.96.175.117/32 -p tcp -m comment --comment "default/nginx cluster IP" -m tcp --dport 8080 -j KUBE-SVC-2CMXP7HKUVJN7L6M
-A KUBE-SVC-2CMXP7HKUVJN7L6M ! -s 10.244.0.0/16 -d 10.96.175.117/32 -p tcp -m comment --comment "default/nginx cluster IP" -m tcp --dport 8080 -j KUBE-MARK-MASQ

# Acrescenta regras no final do conjunto de regras
# iptables -A

# Essa regra aqui que faz o redirecionamento
# Regras de Iptables no Host ( Worker )
# Pacote destinado ao host 10.96.175.117/32 ( Service ) na port 8080 action ( KUBE-SVC-2CMXP7HKUVJN7L6M )
-A KUBE-SERVICES -d 10.96.175.117/32 -p tcp -m comment --comment "default/nginx cluster IP" -m tcp --dport 8080 -j KUBE-SVC-2CMXP7HKUVJN7L6M

root@prgs-control-plane:/# egrep 'KUBE-SVC-2CMXP7HKUVJN7L6M' /tmp/iptables

-A KUBE-SERVICES -d 10.96.175.117/32 -p tcp -m comment --comment "default/nginx cluster IP" -m tcp --dport 8080 -j KUBE-SVC-2CMXP7HKUVJN7L6M
-A KUBE-SVC-2CMXP7HKUVJN7L6M ! -s 10.244.0.0/16 -d 10.96.175.117/32 -p tcp -m comment --comment "default/nginx cluster IP" -m tcp --dport 8080 -j KUBE-MARK-MASQ
-A KUBE-SVC-2CMXP7HKUVJN7L6M -m comment --comment "default/nginx -> 10.244.0.20:80" -m statistic --mode random --probability 0.33333333349 -j KUBE-SEP-BRZDTZFF2SFWJV4H
-A KUBE-SVC-2CMXP7HKUVJN7L6M -m comment --comment "default/nginx -> 10.244.0.21:80" -m statistic --mode random --probability 0.50000000000 -j KUBE-SEP-OI2S57TQ5WH5FOMC
-A KUBE-SVC-2CMXP7HKUVJN7L6M -m comment --comment "default/nginx -> 10.244.0.22:80" -j KUBE-SEP-473MVOWGJMIYYUKK

# Esse 10.244.0.0/16 é o CDIR que K8S usará para os Pods
# Aqui Tudo que vem dessa Chain ( KUBE-SVC-2CMXP7HKUVJN7L6M ) exceto a rede dos Pods vai rolar um Maskared para sair.
-A KUBE-SERVICES -d 10.96.175.117/32 -p tcp -m comment --comment "default/nginx cluster IP" -m tcp --dport 8080 -j KUBE-SVC-2CMXP7HKUVJN7L6M
-A KUBE-SVC-2CMXP7HKUVJN7L6M ! -s 10.244.0.0/16 -d 10.96.175.117/32 -p tcp -m comment --comment "default/nginx cluster IP" -m tcp --dport 8080 -j KUBE-MARK-MASQ

# Aqui que Balanceamente Acontece

# 30% de das requisições que chegar nesse host vai ser encaminhada para ( 10.244.0.20 ) -m statistic ( módulo de load balancer )
-A KUBE-SVC-2CMXP7HKUVJN7L6M -m comment --comment "default/nginx -> 10.244.0.20:80" -m statistic --mode random --probability 0.33333333349 -j KUBE-SEP-BRZDTZFF2SFWJV4H

# 50% das requisicoes que chegarem nesse host vai ser ecaminhada para ( 10.244.0.21 )
-A KUBE-SVC-2CMXP7HKUVJN7L6M -m comment --comment "default/nginx -> 10.244.0.21:80" -m statistic --mode random --probability 0.50000000000 -j KUBE-SEP-OI2S57TQ5WH5FOMC

# o restante das % das requisicoes que chegarem nesse host vai ser ecaminhada para ( 10.244.0.22 )
-A KUBE-SVC-2CMXP7HKUVJN7L6M -m comment --comment "default/nginx -> 10.244.0.22:80" -j KUBE-SEP-473MVOWGJMIYYUKK

# =========================== Como Debugar ( NodePort ) ===========================
#
# --port ( É a porta do service )
# --target-port ( É a porta do nginx rodando no container )

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

# Se tiver usando Kind , pode redirecionar a porta do NodePort para sua máquina local
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

# ========================= Como Debugar ( LoadBalancer ) =========================
# O LoadBalancer é trigado pelo cloud-controller ( Esse cara fala com o cloud Provider ( via api ))

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

# Aqui ele balanceia para o ClusterIp ( KUBE-SVC-2CMXP7HKUVJN7L6M )

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
[Índice](#-menu)

# 🚀 Create Object - Manutenção em Membros do Cluster

```bash
# Daemonset nao pode ser migrado ( 1 pod em cada node )
# Levar todos os Pods alocados no worker ( prgs-worker2 ) para outro node.
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

# Fazendo manutenção no worker2
# Nenhum Pode Poderá ser agendado no worker2
k get node
NAME                 STATUS                     ROLES             AGE    VERSION
prgs-control-plane   Ready                      control-plane     172m   v1.31.2
prgs-worker          Ready                      worker-apps       172m   v1.31.2
prgs-worker2         Ready,SchedulingDisabled   worker-postgres   172m   v1.31.2

# Vai ficar pending pois o stateful set não pode ser migrado para outro node.
# então devo deleta-lo.
k get pod -o wide
NAME      READY   STATUS    RESTARTS   AGE     IP            NODE          NOMINATED NODE   READINESS GATES
nginx-0   1/1     Running   0          8m3s    10.244.1.26   prgs-worker   <none>           <none>
nginx-1   0/1     Pending   0          3m32s   <none>        <none>        <none>           <none>

# Apos manutenção eu ressuscito o Host
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
[Índice](#-menu)

# 🚀 Create Object - External Name

```bash
# ============================== External Name ====================================
#
# Esse é um tipo de serviço onde cria-se um CNAME no DNS Server do Kubernetes.
#
# Services => ( CNAME ) => DNS
#
# É um service usado para resolver nomes.
# Suponhamos que use RDS da AWS te entregue uma URL ( Endpoint ), mas vc não quer usar esse DNS que AWS te mandou,
# pois se ela mudar terá que sair redeployando toda suas apps.
#
# Então vc pode criar esse service ( External Name ) para criar um DNS válido dentro do Cluster
#
# Service , seria seu serviço ex: "db" que nada mais é que um cname para ( DNS URL da AWS ),
# assim quando sua URL de banco mudar voce so muda nesse service e sua app continua igual como antes.
#
# Toda a parte do services é feito no node

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
[Índice](#-menu)

# 🚀 Create Object - Trafic Policy

```bash
# Essa feature é interessante quando temos aplicações críticas que requerem performance.
#
# As Traffic Policies, em um cenário com LoadBalancer, funcionam da seguinte forma:
#
# As requisições chegam pelo IP externo do LoadBalancer e são recebidas por um Node do cluster.
# Ao entrar no Node, o tráfego é direcionado para o Service (ClusterIP), e a partir daí o kube-proxy entra em # ação para decidir qual Pod irá atender a requisição.
#
# Para visualizar os Pods disponíveis, podemos listar os EndpointSlices:
#
k get endpointslices.discovery.k8s.io
NAME         ADDRESSTYPE   PORTS   ENDPOINTS    AGE
kubernetes   IPv4          6443    172.17.0.2   27m

# Esses endpoints apenas informam quais Pods estão disponíveis para o Service.
#
# Funcionamento do roteamento
#
# O ponto importante é que, por padrão, o kube-proxy pode encaminhar a requisição para qualquer Pod do cluster, independentemente do Node onde ele esteja rodando.
#
# Ou seja:
#
# A requisição pode chegar no Node-A e ser encaminhada para um Pod no Node-B
#
# Isso garante maior resiliência e distribuição de carga entre os Pods.
#
# Como isso acontece internamente
#
# O kube-proxy, rodando no Node (não dentro dos Pods), programa regras de iptables no kernel do sistema operacional.
#
# Essas regras fazem o balanceamento de carga utilizando probabilidade, por exemplo:
#
# Ex: 33% das requisicoes atendidas por esse Pod.

-A KUBE-SVC-2CMXP7HKUVJN7L6M -m comment --comment "default/nginx -> 10.244.1.5:80" -m statistic --mode random --probability 0.33333333349 -j KUBE-SEP-IZW656N5ZXYN5BEC

# Isso significa que aproximadamente 33% das requisições serão encaminhadas para esse Pod específico.
#
# Impacto de rede
#
#Como essa comunicação ocorre dentro da rede do cluster, normalmente (mesma VPC ou datacenter) isso não é um problema relevante.
#
# Porém, pode se tornar um problema quando:
#
# O cluster está distribuído entre múltiplas zonas ou regiões
# Existe latência significativa entre os Nodes
#
# Nesse caso, uma requisição que chega no Node A pode acabar sendo atendida por um Pod no Node B, gerando:
#
# Aumento de latência
# Maior consumo de rede
# Possível impacto em aplicações sensíveis a tempo de resposta
#
# Nesse modo:
#
# O tráfego é encaminhado apenas para Pods locais ao Node
# Evita tráfego entre Nodes
# Preserva o IP de origem do cliente
#
# Por outro lado:
#
# Se não houver Pod local, a requisição pode falhar
# O balanceamento global entre Pods fica menos eficiente
#
# De forma pratica

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

# Se eu acessar o Ip do ClusterIP ele irá rotear o tráfego entre todos os 4 Pods
curl -I http://10.96.247.192

k get pods
NAME                     READY   STATUS    RESTARTS   AGE
apline                   1/1     Running   0          2m30s
nginx-676b6c5bbc-8kggb   1/1     Running   0          4m37s
nginx-676b6c5bbc-n4slr   1/1     Running   0          4m37s
nginx-676b6c5bbc-pbmjh   1/1     Running   0          4m37s
nginx-676b6c5bbc-xkmqp   1/1     Running   0          4m37s

# Abrir 4 terminais
k logs nginx-676b6c5bbc-8kggb -f
k logs nginx-676b6c5bbc-n4slr -f
k logs nginx-676b6c5bbc-pbmjh -f
k logs nginx-676b6c5bbc-xkmqp -f

# Requisiçoes irão chegar em todos os POds , mesmo que esses Pods estejam em outros Workers
kubectl run -i --tty --image alpine apline --restart=Never --rm
apk add curl
while true; do curl -I http://10.96.247.192; done

# ======================= Configurando Trafic Policy ==============================

# Como saber a politica padrao do TrafficPolicies?
#
# O Padrao é "Cluster", altere para "Local"

k get svc nginx -o yaml

spec:
  allocateLoadBalancerNodePorts: true
  clusterIP: 10.96.247.192
  clusterIPs:
  - 10.96.247.192
  externalTrafficPolicy: Cluster
  internalTrafficPolicy: Cluster
  ipFamilies:

# Altere para Local
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

# Agora o roteamento é apenas para os Pod pertencentes ao mesmo Worker.

egrep 'KUBE-SVL-2CMXP7HKUVJN7L6M' /tmp/iptables
-A KUBE-SVL-2CMXP7HKUVJN7L6M -m comment --comment "default/nginx -> 10.244.1.6:80" -m statistic --mode random --probability 0.50000000000 -j KUBE-SEP-C4VXQDW52UV45WW3
-A KUBE-SVL-2CMXP7HKUVJN7L6M -m comment --comment "default/nginx -> 10.244.1.7:80" -j KUBE-SEP-DST4PJJC54MIXJRG

# Requisiçoes irão chegar apenas nos Pods do mesmo Node
#
kubectl run -i --tty --image alpine apline --restart=Never --rm
apk add curl
while true; do curl -I http://10.96.247.192; done
```
[Índice](#-menu)

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

# Como Deployment interagi com os replicaset?
O deployments orquestra os replicaset, e são os replicaset que cria os pods. Os Replicaset defini a quantidade de replicas que estaram rodando.

# O que é um Rolling Update?
E um termo usado quando vou atualizar meus produtos ( pods ). Ex: Meu manifesto ( Deployment )

O Deployment cria 1 replicaset com 3 pods, agora preciso trocar a imagem do manifesto.

Ao aplicar o deployment irá criará outro replicaset ( replicaset2 ) com 3 novos Pods isso acontece de forma gradativa.

Existe outras formas de deploy Ex: canary, mas nesse formato ( rolling Update ) o Replicaset1 remove (-) um pod a medida que o Replicaset2 adiciona (+) um pod.

Isso permite eu fazer um UNDO para outro replicaset
```
[Índice](#-menu)


# 🚀 Create Object - Deploy Canary

```bash
Canary Deploy ( Raiz )

( Joao ) => LoadBalance
               |
               |
               |
        -----------------
        |                |
        |                |
        |                |
       80%( v1/old )   20%( v2/new )

# Gerando Modelo
k neat <<< $(k create deployment --image nginx --replicas 0 nginx-blue --dry-run=client -o yaml)

# Criar 2 Deployments sendo blue com 1 replica e green com 9 replicas

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

# Todos Pods entra no mesmo Pool
selector:
  app: nginx


k get deployments.apps
NAME          READY   UP-TO-DATE   AVAILABLE   AGE
nginx-blue    1/1     1            1           38s
nginx-green   9/9     9            9           38s

kubectl run -i --tty --image alpine apline --restart=Never --rm
apk add curl

i=0; while [[ $i -le 10 ]]; do echo $i; curl nginx -I; let i=i+1; done

# Forcar cada requisição criar uma nova conexão TCP, cada requisição 1 Pod
# keep-alive     → reutiliza conexão → mesmo pod
# --no-keepalive → nova conexão      → novo pod

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
[Índice](#-menu)

# 🚀 Create Object - Deploy Blue Green

```bash
# Blue-Green Deploy ( Raiz )
#
# Subo toda a infra da aplicação em outros Pods e faço o switch da aplicação no seletor do Service.

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

# Blue representa o apache

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

# Green representa o nginx

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
[Índice](#-menu)

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

# O Ingress é uma aplicação que precisa ser deployadas no cluster.
# O Serviçe LoadBalancer, entrega as requisiçoes para (Pod do Ingress). Todos os DNS ( app.demo.com ) serão resolvidas pelo LoadBalancer.
# Quando meu manifesto yaml cria um ingress, ele adiciona uma regra de acesso ao ingress Resource.
# Ele na real cria um virtual host no Pod do Ingress Resource ( dinamicamente )
# O Ingress por sua vez , redireciona para o service da aplicação ( ClusterIP )
# O Ingress é um proxy-reverso

# Ingress Mantido pelo propria Corporação F5 Nginx
https://docs.nginx.com/nginx-ingress-controller/

# Ingress mantido pela comunidade ( OpenSource )
https://kubernetes.github.io/ingress-nginx/

# Esse ingress mantido pela comunidade resolve e podemos usa-lo para deployar.
# Como estou usando MetalLB para simular o L.B, posso baixar o manifesto yaml e substituir o service
# ( NodePort por LoadBalancer ).

curl -sSL https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.15.1/deploy/static/provider/baremetal/deploy.yaml | sed 's/NodePort/LoadBalancer/' | | k apply -f -

# Instalando via Helm
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx --set controller.service.type=LoadBalancer

# Check Instalação
k get pod -n ingress-nginx
NAME                                        READY   STATUS      RESTARTS   AGE
ingress-nginx-admission-create-p6hvd        0/1     Completed   0          53m
ingress-nginx-admission-patch-ffrmd         0/1     Completed   0          53m
ingress-nginx-controller-68697cf9d9-gntwb   1/1     Running     0          53m

k get svc -n ingress-nginx
NAME                                 TYPE           CLUSTER-IP       EXTERNAL-IP    PORT(S)                      AGE
ingress-nginx-controller             LoadBalancer   10.101.12.218    172.17.0.240   80:31168/TCP,443:30256/TCP   53m
ingress-nginx-controller-admission   ClusterIP      10.108.227.154   <none>         443/TCP                      53m

# Porque o curl retornou 404, sendo que tenho deployado o Ingress Controller?
# R: Ainda não foi deployado nenhum recurso ( ingress resources )
curl -I http://172.17.0.240
HTTP/1.1 404 Not Found
Date: Fri, 17 Apr 2026 13:32:51 GMT
Content-Type: text/html
Content-Length: 146
Connection: keep-alive

# =============================== Ingress Class ====================================
#
# No momento da criação do meu ingress resource, eu defino qual ingress class irá me atender.
# Isso porque eu posso ter multimplos ingress instalado no cluster.

k get ingressclasses
NAME    CONTROLLER             PARAMETERS   AGE
nginx   k8s.io/ingress-nginx   <none>       57m

**OBS.:**
# Se eu não informa o ingressclass, a criação do ingress ficará pending.
# Para evitar isso, posso definir o niginx comm ingressclass default.

https://kubernetes.io/docs/concepts/services-networking/ingress/#ingress-class

# Definir isso como anotation
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

# =============================== Criando Recurso ==================================

k explain ingress.spec
k explain ingress.spec.rules.http

k create deployment --image nginx --replicas 3 nginx
k expose deployment nginx --type=ClusterIP --port=80

k get endpointslices.discovery.k8s.io
NAME          ADDRESSTYPE   PORTS   ENDPOINTS                            AGE
kubernetes    IPv4          6443    172.17.0.3                           69m
nginx-9slrs   IPv4          80      10.244.1.9,10.244.1.11,10.244.1.10   32s

# 1) Resolve o DNS ( nginx.demo.com => IP do LoadBalancer )
# 2) Ao bater nesse IP, ele cai no Pod do Ingress Controller
# 3) O Ingress vai checar nas entradas de sua conf, se ha um virtual host definido, para o path e se sim,
# vai encaminhar para o backend rodando ( nginx )

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

# Simulando uma chamada via Vhost
curl 172.17.0.240 -H "Host: nginx.demo.com"

<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }

# Vc poderia criar uma entrada no ( /etc/host )
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

# Testando
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
[Índice](#-menu)

# 🚀 Create Object - Ingress Nginx Rewrite

```bash

Para exemplificar essa funcinalidade do ingress, vamos criar um ambiente mais simples e ir ajustando os paths e o rewrite.

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

# Porque nao foi especififcado hosts?

  rules:
  - host: "nginx.demo.com"
    http:
      paths:
      - path: /
    ...
    ...
    ...

# Quando é especificado o campo "Host" no manifesto, o Ingress cria uma regra específica.
# Só roteie se o header HTTP Host for "nginx.demo.com".
# curl 172.17.0.241 -H "Host: nginx.demo.com" => Assim eu forco o Header
#
# Ex:
server {
    server_name nginx.demo.com;
}

# Quando NÂO especifico o campo "Host" , o ingress cria uma regra Genérica ( catch-all )
# Aceita qualquer Host
#
# Esse _ é o default server / catch-all
# Ex:
server {
    server_name _;
}


# Desta forma estou acessando o nginx do Ingress Controller.
curl 172.17.0.240 -I
HTTP/1.1 200 OK
Date: Mon, 20 Apr 2026 13:11:25 GMT
Content-Type: text/html
Content-Length: 896
Connection: keep-alive
Last-Modified: Tue, 07 Apr 2026 11:37:12 GMT
ETag: "69d4ec68-380"
Accept-Ranges: bytes


# Se precisar definir uma rota? Ex: /nginx
# O Pod teria que que está apto a trbalhar nessa rota tbm?
# Sempre que informar um /nginx quero que seja redirecionado para o container do Nginx
# Quero que o redirecionamento seja na base do path e nao em base no host.

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

# DEU RUIM....

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

# 1) A requisicao está chegando no Pod ?

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


# Ele tentou abrir uma pasta chamada nginx em ( /usr/share/nginx/html/nginx ), isso porque ele tentou uma rota /nginx


#=========================== O que de fato queriamos? ==============================
#
# Ao acessar o /nginx o controller do nginx, deveria remover o "/nginx" da requisição e encaminhar para o pode correto no "/"
# Esse erro aconteceu porque a imagem não tem o path /nginx definido para responder requisição.
#
# Precisamos Reescrever o Path da Rotas

https://kubernetes.github.io/ingress-nginx/
https://kubernetes.github.io/ingress-nginx/examples/rewrite/

# Anotations injeta configurações ( Comportamento do Nginx )

# Tudo que começar com /nginx deve ir para o service nginx, mas reescrevendo a URL antes de enviar.
# nginx.ingress.kubernetes.io/use-regex: "true", Ativa interpretação de regex no path.
# Sem isso, /nginx(/|$)(.*) seria tratado como string literal.
#
# nginx.ingress.kubernetes.io/rewrite-target: /$2
# $2 = segundo grupo da regex → (.*)

# Internamente o Nginx gera isso...

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


# Annotations influenciam o comportamento do Ingress Controller, mas não são o que definem o Ingress por completo.
spec:
  rules:
  - host:
    http:
      paths:

# Isso define:
# - quem recebe a requisição
# - para onde ela vai (service)
# - paths e hosts

# Annotations (dependem do controller) - rotas extras
# Annotations customizam o comportamento do Ingress
```
[Índice](#-menu)

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

# Outra possibilidade é expor via Virtual Host.

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
[Índice](#-menu)

# 🚀 Create Object - Ingress Error 503

```bash

# Assumo aqui que o service e o deployment do httpd estejam rodando.

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

# Alterar o nome do selector app para httpd e voltar
k patch svc httpd -p '{"spec":{"selector":{"app":"httpd"}}}'

```
[Índice](#-menu)

# 🚀 Create Object - Ingress TLS

```bash
https://kubernetes.io/docs/concepts/services-networking/ingress/

# Gerando Certificados - Auto Assinado
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

# Testando Http
curl 172.17.0.240 -H "Host: nginx.prgs.corp"

# Criando Secrets
k create secret tls prgs-domain-secret --key /tmp/tls.key --cert /tmp/tls.crt

k get secrets
NAME                 TYPE                DATA   AGE
prgs-domain-secret   kubernetes.io/tls   2      6s

k describe secrets prgs-domain-secret
...
...
tls.crt:  1192 bytes
tls.key:  1708 bytes

# Recuperar Certificado
k get secrets prgs-domain-secret -o yaml

# Decriptar Certificado
base64 -d <<< $(k get secrets prgs-domain-secret -o=jsonpath='{.data.tls\.crt}')

# Isso aqui injeta TLS
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


# Query feita via http sendo redirecionada para https
curl 172.17.0.240 -I -H "Host: nginx.prgs.corp";
HTTP/1.1 308 Permanent Redirect
Date: Mon, 20 Apr 2026 20:15:07 GMT
Content-Type: text/html
Content-Length: 164
Connection: keep-alive
Location: https://nginx.prgs.corp

# Query feita via https ( -L / -k )
# Para que este teste funcione e necessário adicionar entrada no ( /etc/hosts )
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

# Ou se preferir pode definir isso na query, forcando o curl a resolver o Nome.
# Aqui não tem redirect, o curl já conversa via https.
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
[Índice](#-menu)

# 🚀 Create Object - ConfigMap Vs Secrets

```bash

# Configmap e Secrets => Objetos do Kubernetes
#
# Configmap => Composto por key=value
# Secrets   => Key armazenada no formato base64
#
# Ambos injetam dados para dentro de um Pod.
#
# Como injetar isso dentro do Pod?
# - Variavies de Ambiente
# - Montar-lo como arquivo dentro do filesystem
# - Um secret geralmente vira um arquivo de texto ( Ex: Vault )
#
# Obs.: Secret não está encripitado, está apenas encodado ( base64 )

```
[Índice](#-menu)

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

# Corefile => Representa a minha chave
# Tudo que está depois do  "|" é o conteudo ( Multi line )

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

# Deletar um configmap
k delete cm my-config

https://kubernetes.io/docs/concepts/configuration/configmap/

# Gerando um modelo
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

# Se alguma coisa estiver errada?
NAME                    READY   STATUS                       RESTARTS   AGE
nginx-96b46d48d-h6ft2   0/1     CreateContainerConfigError   0          8s

# Pegando Os enventos
k describe pod nginx-96b46d48d-h6ft2

# O erro ocorreu porque não foi definido o configmap

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


# Recuperar Nome do Pod
k get pods -o=jsonpath='{range .items..metadata}{.name}{"\n"}{end}'

# Executando e extraindo as variaveis
k exec -it $(k get pods -o=jsonpath='{range .items..metadata}{.name}{"\n"}{end}') -- env | egrep 'VHOSTS_PAULO|API_URL'
VHOSTS_PAULO=prgs.corp
API_URL=https://api.prgs.corp

# Deletando Tudo
k delete deployments.apps nginx && k delete cm virtualhost

#============================= ConfigMap Sem SubPaths ================================

# Gerando um modelo
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

# Crie um service para expor o Pod
k expose deployment nginx --type=ClusterIP --port=80 --target-port=80

# Desta forma todos os html contido nesse diretório ( /usr/share/nginx/html ) é substituido

kubectl run -i --tty --image alpine test --restart=Never --rm
apk add curl
curl nginx
<html>
  <h1>
    Index.html Prgs Corp
  </h1>
</html>

# Aqui é montando o volume inteiro no diretório. Sendo assim , o conteúdo total da pasta original é substituido.
k exec -it $(k get pods -o=jsonpath='{range .items..metadata}{.name}{"\n"}{end}') -- ls /usr/share/nginx/html
index.html


#====================== ConfigMap Com SubPaths - Evitar Replace =====================

# Para evitar o replace do diretório e substituirmos apenas o index.html precisamos ajustar o deployment.
# Nessa implementação a pasta não e sobrescrita.

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


# Recuperar Nome do Pod
k get pods -o=jsonpath='{range .items..metadata}{.name}{"\n"}{end}'

# Executando e extraindo as variaveis
k exec -it $(k get pods -o=jsonpath='{range .items..metadata}{.name}{"\n"}{end}') -- env | egrep 'VHOSTS_PAULO|API_URL'
VHOSTS_PAULO=prgs.corp
API_URL=https://api.prgs.corp

# Como foi usado subPath, o arquivo 50x.html ( Original ), se manteve
k exec -it $(k get pods -o=jsonpath='{range .items..metadata}{.name}{"\n"}{end}') -- ls /usr/share/nginx/html
50x.html  index.html

# Index.html conteúdo gerido pelo configmap é substituido.
k exec -it $(k get pods -o=jsonpath='{range .items..metadata}{.name}{"\n"}{end}') -- cat /usr/share/nginx/html/index.html
<html>
  <h1>
    Index.html Prgs Corp
  </h1>
</html>
```
[Índice](#-menu)

# 🚀 Create Object - ConfigMap Vhost Ingress

k expose deployment nginx --type=ClusterIP --port=80 --target-port=80 --dry-run=client -o yaml

```bash
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

# Batendo direto no Pod - Sem virtual Host
/ # curl 10.244.1.9
<html>
  <h1>
    Chegou Index.html prgs.corp
  </h1>
</html>

# Batendo direto no Pod - Com virtual Host
/ # curl 10.244.1.9 -H "Host: app.prgs.corp"
<html>
  <h1>
    Sou o Index App1
  </h1>
</html


# Batendo direto no Ingress - Sem virtual Host
curl 172.17.0.240
<html>
  <h1>
    Chegou Index.html prgs.corp
  </h1>
</html>

# Batendo direto no Ingress - Com virtual Host
curl 172.17.0.240 -H "Host: app.prgs.corp"
<html>
  <h1>
    Sou o Index App1
  </h1>
</html>

#================================ Projected-Volumes =================================
#
# Permite montar 2 ou mais pontos de montagem apontando para o mesmo arquivo.
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

# Temos 2 arquivos diferentes que referenciam o mesmo source ( configmap )
k exec nginx-66d8fc6cdb-s9x7q -- bash -c "ls /usr/share/nginx/html"
index.html
index2.html
```
[Índice](#-menu)

# 🚀 Create Object - Types Secrets

```bash
k create secret --help

# Available Commands:
#   docker-registry   Cria um secret para ser utilizado com o Docker registry
#   generic           Cria uma secret "from a local file", directory, or literal value
#   tls               Cria uma secret do tipo TLS

k create secret generic credentials --from-literal=username=admin
k get secrets

base64 -d <<< $(k get secrets credentials -o=jsonpath='{.data.username}') && echo

https://kubernetes.io/docs/concepts/configuration/secret/#secret-types

# Ao criar uma secret é importante checar o tipo na documentação acima, e criar conforme o k8s espera.

apiVersion: v1
kind: Secret
metadata:
  name: secret-basic-auth
type: kubernetes.io/basic-auth
stringData:
  username: admin # required field for kubernetes.io/basic-auth
  password: t0p-Secret # required field for kubernetes.io/basic-auth


#================================ Secrets Encode ====================================
#
# Ao criar um secret base64 lembra de rodar assim , para não ter quebra de linha
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

# Montou-se um diretorio ( /segredo ), e la dentro os arquivos
k exec -it $(k get pods -o=jsonpath='{range .items..metadata}{.name}{"\n"}{end}') -- cat /segredo/username && echo
admin
```
[Índice](#-menu)

# 🚀 Create Object - Storage PV / PVC / StorageClass / AccessMode

```bash
# Vamos separar o bloco storage em 3 temas:
# - Provisionamento Dinamico
# - Provisionamento Estático
# - Access Modes
#
#========================== Provisionamento Estático  ===============================
#
# Neste modelo consideramos:
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
# Persistent Volume ( PV ) => Precisamos de ( Objeto Persistent Volume ) , podemos ter vários tipos de persistent Volumes
# e uma vez criado eu posso ofertar isso ao pod.
# No persistent volume vc como admin defini o tipo, caracteristica e tamanho.
# Isso permitirá que agora meu cluster tenha um Objeto para persistir dados.
#
# Um cenario comum é ter um disco externo conectado em um dos Nodes ( Worker ), e entao os nodes schedulados para rodarem.
# Nesse node específico que tem esse disco, poderá escrever os dados nesse disco.
# Esse tipo de provisionamento é chamado "local". Ex: Criar um PV de 100GB
#
# PV => Storage que estou disponibilizando
#
# App:
#
# Persistent Volume Clain ( PVC ) => Minha aplicação que quer usar esse Volume definido pelo time da infra.
# A app entao pede ( clain ), requisita esse volume , entao ele usa esse objeto ( PVC ), um pedaço ( Ex: 5GB ).
# Obs.:
# O pod não fala direto com PV
#
# PVC é uma requisição de uma parte desse storage. Cada App terá seu PVC
#

https://kubernetes.io/docs/concepts/storage/volumes/

https://kubernetes.io/docs/concepts/storage/volumes/#local

# Para exemplificar iniciaremos com PV ( PersistentVolume )
#
# PV é global, isso quer dizer que não é atachado em NENHUM namespace.
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


# Em meu ambiente, tenho apenas 1 Node ( Control Plane ) e 1 Node ( Control Data )
#
docker exec prgs-worker bash -c "mkdir -p /data"
docker exec prgs-worker bash -c "ls -la /"

###################
# Criado PV
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

# RECLAIM POLICY => Retain ( Não vai deletar os dados )
# STATUS         => Available ( Disponível e não atachado e nenhum PVC )

k get pv
NAME             CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS   VOLUMEATTRIBUTESCLASS   REASON   AGE
prgs-worker-pv   1Gi        RWO            Retain           Available                          <unset>

###################
# Criado PVC
###################

https://kubernetes.io/docs/concepts/storage/persistent-volumes/

https://kubernetes.io/docs/concepts/storage/persistent-volumes/#persistentvolumeclaims

# No meu ambiente kind, já é provisionado o StorageClass, mas ELE NÃO SERÁ informado ao definir o PVC
# Se eu não definir o storageClassName, ele pegará isso de forma dinamica, pegará o default do cluster.
#
# Entao PRECISO deixar o storageClassName vazio, e preciso informar no campo volumeName o PV criado na fase anterior.
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

# O Kubernetes faz o bind do PVC com o PV assim que encontrou um match válido.

k describe pvc prgs-worker-pvc

# Doc para entender o Yaml
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

# Não criamos um PV de 1GB e um PVC 10 MB, como ele permitiu aramazenar 20MB?
✅  PVC não limita espaço por si só.
✅  Local PV não tem quota ( Deve-se usar LVM com PV limitando a capacidade do bloco, ou mesmo StorageClass como Ceph (RBD) / Longhorn).
✅  Aqui usa-se Bloco todo onde o está definido o PV. Limite real depende do storage backend.
✅  É comportamento esperado.

# E esse trecho abaixo, não deveria fazer isso?

resources:
  requests:
    storage: 10Mi

✅ Não !! Isso é um limite rígido, é apenas um requisito mínimo para binding.

k exec -it $pod -- bash -c "df -h"
Filesystem                         Size  Used Avail Use% Mounted on
overlay                            466G  255G  188G  58% /
tmpfs                               64M     0   64M   0% /dev
overlay                            466G  255G  188G  58% /data


#============================= Provisionamento Dinamico =============================

                             POD
                              |
                              |
                        StorageClass
                              |
                              |
    (POD Controller) =>   Storage Class => ( NFS / Local Path)

# App
# Não muda em nada se comparando com ( Provisionamento Estático ) ou seja , preciso de um PVC para requisitar uma parte do storage.
#
# Cada App terá seu PVC.
#
# A mudanca é que ao criar um PVC terá um campo para que eu informe a StorageClass, a depender da storageClass, será definido e seu tipo.
#
# Storage Classe é uma pratilheira com vários tipos de storage que posso usar.Ex: ( EFS que é o NFS da AWS , EBS, NFS, Longhorn )
#
# Quem faz essa mágia é o pod de controller para gerenciar esse dinamismo. Ele que cuida em criar o PV.
#
# Todo provisionamento dinamico terá um controller envolvido fazendo a magica...
#
# StoragClasses => NãO é especifico de uma namespace
#
# Vantagens do Volume dinamico, eu apenas escolho na prateleira qual PVC me atenderá e o resto o k8s
# se encarrega de fazer, que é montar o PV.


k get storageclasses
NAME                 PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
standard (default)   rancher.io/local-path   Delete          WaitForFirstConsumer   false                  47m

https://artifacthub.io/packages/helm/kvaps/nfs-server-provisioner

https://medium.com/@dikkumburage/how-to-deploy-nfs-client-provionser-31407a3746c8

# Não tenho que informar volumeName ( PV ) quando trabalho com volume dinamico
#
# Preciso informar qual storageClass
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


# Fisicamente os dados estao sendo persistidos dentro do worker
docker exec prgs-control-plane bash -c "ls -la /var/local-path-provisioner"
drwxr-xr-x  3 root root 4096 Apr 23 13:06 .
drwxr-xr-x 12 root root 4096 Apr 23 13:06 ..
drwxrwxrwx  2 root root 4096 Apr 23 13:06 pvc-1f64a261-b8b2-4e36-a8a7-33969078cc41_default_prgs-control-plane-pvc


# Cada pod escreveu 10 arquivos.txt no mesmo volume.
pods=$(k get pods -o=jsonpath='{range .items..metadata}{.name}{"\n"}{end}')

while IFS= read -r pod;
do
  k exec $pod -- bash -c 'for i in {1..10}; do touch "/data/${HOSTNAME}-$i.txt"; done'
done <<< "$pods"


# Lendo
while IFS= read -r pod;
do
  k exec $pod -- bash -c "ls /data"
  echo "-------------------"
done <<< "$pods"

# Todos os Pods escrevem no volume.
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


# Por ter esse mode de acesso ( ReadWriteOnce ) todos os Pods schedulados neste Node Podem escrever
#
# Por isso nao montou esse diretorio no outro container docker ( prgs-worker )
#
✅ Significa: o volume pode ser montado em modo leitura/escrita por UM NODE por vez
✅ Compartilhamento de filesystem dentro do mesmo node, não cluster-wide.

#================================== Access Modes ====================================

# AccessModes => O PV definido ( ReadWriteOnce ) terá o disco atachado somente a um Node.
# Eu até posso ter mais Pod lendo o mesmo disco, desde que esses Pod rodem no mesmo worker.
#
# PersistentVolumeReclaimPolicy => Ao ser deletado o PV, qual comportamento?
# Sera deletado todos os dados uma vez que ja foi removido o PV ( Ao definir como Delete isso irá acontecer )
#
# Cada tipo de storage suportará access Modes diferentes.

https://kubernetes.io/docs/concepts/storage/persistent-volumes/#access-modes

# ReadWriteOnce ( RWO ) => Eu até posso ter mais Pod lendo o mesmo disco/volume,
# desde que esses POd rodem no mesmo worker, ou storage seja compartilhado NFS.
#
# ReadWriteMany ( RWX ) => Casa da mãe Joana ( Todo mundo pode tudo )

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

# Ao tentar aplicar o manifesto , será schedulado o kube-scheduler irá tentar distribuir a carga entre os membro do cluster.
# O que acontecerá nesse cenário acima?

k describe pvc prgs-worker-claim

Events:
  Type     Reason                Age                From                                                                                                Message
  ----     ------                ----               ----                                                                                                -------
  Normal   WaitForFirstConsumer  30s                persistentvolume-controller                                                                         waiting for first consumer to be created before binding
  Normal   Provisioning          15s (x2 over 30s)  rancher.io/local-path_local-path-provisioner-57c5987fd4-m2f5m_840e8c44-e7d9-427b-93e5-a2b88ac268c5  External provisioner is provisioning volume for claim "default/prgs-worker-claim"
  Warning  ProvisioningFailed    15s (x2 over 30s)  rancher.io/local-path_local-path-provisioner-57c5987fd4-m2f5m_840e8c44-e7d9-427b-93e5-a2b88ac268c5  failed to provision volume with StorageClass "standard": Only support ReadWriteOnce access mode
  Normal   ExternalProvisioning  10s (x3 over 30s)  persistentvolume-controller                                                                         Waiting for a volume to be created either by the external provisioner 'rancher.io/local-path' or manually by the system administrator. If volume creation is delayed, please verify that the provisioner is running and correctly registered.

# O error é de compatibilidade entre o tipo de volume e o access mode que foi pedido.

accessModes:
  - ReadWriteMany

# Mas o provisionador que está sendo usado é o local-path-provisioner, e ele só suporta: ReadWriteOnce (RWO)
# A mensagem "Only support ReadWriteOnce access mode" deixa isso claro.
#
# Como corrigir?

accessModes:
  - ReadWriteOnce

# Todos os pods vão usar volumes separados
# ou o scheduler pode concentrar no mesmo node.
#
# Usar storage que suporta RWX (recomendado para esse caso)
# Ex:
# NFS
# CephFS
# Longhorn (com RWX habilitado)
# GlusterFS
```
[Índice](#-menu)

# 🚀 Create Object - Reclaim Policy PVC / StorageClass

```bash
https://kubernetes.io/docs/concepts/storage/persistent-volumes/#reclaim-policy

# Delete => Default ( Assim que deleta os recursos pvc é deletado os dados )
# Retain => Deleta o PVC, mas os dados continuam lá
#
# É na definição da PVC que aplico o tipo de Policy

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

# Isso quer dizer que os Deployments que usarem esse PVC ( volume-persistente ) não teram seus dados apagados

# Se eu deletar o Deployment + PVC , meus dados ainda sim continuaram intactos,
# pois quem ta garantindo isso é o StorageClass do tipo Retain.

# O PV ainda estará lá mas com status ( Release )
# Estando nesse estado ( Release ) , ele pode ser atachado novamente.

k get pv

# Para re-usar esse PV é necessário ajustar o deploy do PVC para "especificar o PV" e deixo em "branco o storageClass".
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
# Nada impede ter multiplos storageClass no seu cluster. No exemplo abaixo, será criado um novo pvc
# manualmente, e será rotulado que esse PVC terá um nome qualquer como StorageClass

# Crie o diretório
docker exec prgs-control-plane bash -c "mkdir -p /data"
docker exec prgs-control-plane bash -c "ls /data"

# Para esse laboratório, primeiro cria-se o PV
# Como esse PV tem uma regra específica de afinidade, ele so montará os pods com esse volume neste node ( prgs-control-plane )

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

# Criando PVC

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

# Apesar do PVC ter sido rotulado com StorageClass, chamado "prgs-control-plane-sc", esse storageClass não existe no K8S.

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


# Lendo pelo Pod
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

# Lendo No worker
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

# E se eu deletar tudo ?
#
k delete deployments.apps nginx
deployment.apps "nginx" deleted from default namespace

# Delete PVC
k delete pvc prgs-control-plane-pvc
persistentvolumeclaim "prgs-control-plane-pvc" deleted from default namespace

# Delete Pv
k delete pv prgs-control-plane-pv
persistentvolume "prgs-control-plane-pv" deleted

# Lendo No worker
# Os dados estao lá
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

# Se eu Subir novamente ( PV / PVC / Deployment ) o que acontece?
k get pods
NAME                     READY   STATUS    RESTARTS   AGE
nginx-6767449f59-h58tb   1/1     Running   0          63s
nginx-6767449f59-pg2sl   1/1     Running   0          63s
nginx-6767449f59-vdxbp   1/1     Running   0          63s

# Lendo pelo Pod
pods=$(k get pods -o=jsonpath='{range .items..metadata}{.name}{"\n"}{end}')

while IFS= read -r pod;
do
  k exec $pod -- bash -c "ls /data"
  echo "-------------------"
done <<< "$pods"

# Consegue montar e ler os dados normalmente. Isso porque ao criar o PVC foi Definido ( persistentVolumeReclaimPolicy: Retain )

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
# A ideia aqui e aplicar a mesma regras de Retaim feita no PVC, porém a nivel de StorageClass
#
# O pv é criado herdando o que foi definido na StorgaClass
#
# É na definição da StorageClass que aplico o tipo de Policy
#
# Vamos criar um StorageClass Personalizado.

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

# Criando o PVC
#
# Obs.: Aqui foi definido que o mode de acesso ...

accessModes:
  - ReadWriteOnce

✅ Por ter esse mode de acesso ( ReadWriteOnce ) todos os Pods schedulados neste Node Podem escrever / ler.
✅ O volume pode ser montado em modo leitura/escrita por UM NODE por vez
✅ Compartilhamento de filesystem dentro do mesmo node, não cluster-wide.
✅ O PV definido ( ReadWriteOnce ) terá o disco atachado somente a um Node.
✅ Vários Pods podem usar o mesmo volume se estiverem no mesmo node.

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
# OBS.: Aqui ele ficará como Pending até que um POD faca requisição para usar esse PVC

k get pvc
NAME                     STATUS    VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS         VOLUMEATTRIBUTESCLASS   AGE
prgs-control-plane-pvc   Pending                                      volume-persistente   <unset>                 2s

# Criando Deployment
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

# Como ficou o ponto montagem dentro do Worker?
#
docker exec prgs-control-plane bash -c "ls /var/local-path-provisioner"
pvc-25c56de4-a766-4d72-9ecf-566c0074cbfd_default_prgs-control-plane-pvc

k get pvc
NAME                     STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS         VOLUMEATTRIBUTESCLASS   AGE
prgs-control-plane-pvc   Bound    pvc-25c56de4-a766-4d72-9ecf-566c0074cbfd   10Mi       RWO            volume-persistente   <unset>                 9m8s


# Injetando Dados
pods=$(k get pods -o=jsonpath='{range .items..metadata}{.name}{"\n"}{end}')

while IFS= read -r pod;
do
  k exec $pod -- bash -c 'for i in {1..10}; do touch "/data/${HOSTNAME}-$i.txt"; done'
done <<< "$pods"

# Listando direto do Worker
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

# E se eu deletar tudo?
#
k delete deployments.apps nginx
deployment.apps "nginx" deleted from default namespace
#
k delete pvc prgs-control-plane-pvc
persistentvolumeclaim "prgs-control-plane-pvc" deleted from default namespace

# Listando direto do Worker
# Os dados continuam lá , isso por conta da regra ( Policy Retain )
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

# Se não tenho mais PVC, mas os dados estao montados fisicamente nesse Worker, com esse NOME ( pvc-25c56de4-a766-4d72-9ecf-566c0074cbfd_default_prgs-control-plane-pvc )
# Como eu montaria esse PVC novamente?
#
# OBS.:
# OBS.: ISSO SÓ É POSSIVEL, PORQUE AO DELETAR O PVC , O PV É CONSERVADO
# OBS.:

k get pv
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS     CLAIM                            STORAGECLASS         VOLUMEATTRIBUTESCLASS   REASON   AGE
pvc-25c56de4-a766-4d72-9ecf-566c0074cbfd   10Mi       RWO            Retain           Released   default/prgs-control-plane-pvc   volume-persistente   <unset>                          9m45s

# Recriando o PVC fazendo match com PV existente
#
# Obs: Foi definido o ID do PV no PVC

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

# Listando PVC
k get pvc
NAME                     STATUS    VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS         VOLUMEATTRIBUTESCLASS   AGE
prgs-control-plane-pvc   Pending   pvc-25c56de4-a766-4d72-9ecf-566c0074cbfd   0                         volume-persistente   <unset>                 9s

# Caso o PV esteja montado em node específico, e melhor definir uma regra de afinidade ao montar o deployment.

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

# Listando os Pod...
# Não subiu nada !!!
#
NAME                     READY   STATUS    RESTARTS   AGE
nginx-6767449f59-2jhlp   0/1     Pending   0          2s
nginx-6767449f59-8blp8   0/1     Pending   0          2s
nginx-6767449f59-hrxn8   0/1     Pending   0          2s

# Isso acontece porque o PV ainda está atrelado ao PVC antigo que morreu
# O fato do Status está como ( Released ), aponta para essa caracterítica.
#
k get pv
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS     CLAIM                            STORAGECLASS         VOLUMEATTRIBUTESCLASS   REASON   AGE
pvc-25c56de4-a766-4d72-9ecf-566c0074cbfd   10Mi       RWO            Retain           Released   default/prgs-control-plane-pvc   volume-persistente   <unset>                          25m

# ----------------- Hard Core -----------------------------
# Uma outra solução seria fazer um provisionamento estatico.
# Defino storageClass como ""
# Aponto qual pv quero usar usando o objeto volumeName
# Uma outra alternativa seria editar o PV e remover o ID atrelado ao PV
# Ex: Remover a entrada ( claimRef => uid: 0e436051-7441-42d5-83d9-3a8362ee0d34 )
# ---------------------------------------------------------

# Aplicar PAtch de correção...
# Obs.:
kubectl patch pv pvc-25c56de4-a766-4d72-9ecf-566c0074cbfd -p '{"spec":{"claimRef": null}}'
# Obs.:
#

k delete deployments.apps nginx
k delete pvc prgs-control-plane-pvc

# Reaplique o PVC
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


# Consegue montar e ler os dados normalmente. Isso porque ao criar o PVC foi Definido ( persistentVolumeReclaimPolicy: Retain )

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
# Criei StorageClass com Policy Retaim, mas matei o PV
# Como fica?
#
k delete deployments.apps nginx
deployment.apps "nginx" deleted from default namespace

k delete pvc prgs-control-plane-pvc
persistentvolumeclaim "prgs-control-plane-pvc" deleted from default namespace

k delete pv pvc-25c56de4-a766-4d72-9ecf-566c0074cbfd
persistentvolume "pvc-25c56de4-a766-4d72-9ecf-566c0074cbfd" deleted

# Meu volume está orfão
#
# Porém o dado ainda existe no meu cluster
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

# O processo de recuperação de um PV orfão é manual.
#
# Criando PV
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

# Criando PVC
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

# Listando PVC
k get pvc
NAME             STATUS    VOLUME          CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
pvc-recuperado   Pending   pv-recuperado   0                                        <unset>                 3s

# Criando App
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

# Listando conteúdo
#
pods=$(k get pods -o=jsonpath='{range .items..metadata}{.name}{"\n"}{end}')

while IFS= read -r pod;
do
  k exec $pod -- bash -c "ls /data"
  echo "-------------------"
done <<< "$pods"

# Consegue montar e ler os dados normalmente. Isso porque ao criar o PVC foi Definido ( persistentVolumeReclaimPolicy: Retain )

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

[Índice](#-menu)

# 🚀 Create Object - HPA / VPA

```bash
# Escala Vertical X Escala Horizontal ( Componentes que monitoram recursos )
#
#================================ Horizontal (HPA) ==================================
#
# Deployment => ReplicaSet => Pod
#
# No Deployment injetamos um novo objeto chamado HPA, ele irá escutar alguma métrica ( CPU / RAM ),
# mas pode-se usar metricas externas e uma vez que esse threshoud bater no limite definido, o HPA escalará os PODS.
#

https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/

https://kubernetes.io/docs/reference/command-line-tools-reference/kube-controller-manager/

# No start no kube-controller existem parametros listado no link acima que definem comportamentos do HPA
# Ex: --horizontal-pod-autoscale-xxxx
#
# Em amnientes gerenciados, vc dificilmente ajustará esses comportamentos pois não tem gerencia sobre o control-plane.
#
# Formas como HPA coleta as metricas?

https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/#support-for-resource-metrics

- Custom Metrics ( Escalar baseada em CPU )
- APi Metrics ( Coleta metricas de um Prometheus )
- Escalar baseada em request, fila SQS .. etc

# OBS.:
# Preciso do metrics-server deployado no cluster
#
# Metric Server baseada em CPU
metrics.k8s.io API

# Metrics Customizadas / Como é coletada as metrics
custom.metrics.k8s.io API.
external.metrics.k8s.io API.

# Recursos consumidos pelo Node
k top nodes
NAME                 CPU(cores)   CPU(%)   MEMORY(bytes)   MEMORY(%)
prgs-control-plane   532m         4%       1570Mi          10%

# Recursos consumidos pelos Pods
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
# Obs.:
# Request é usado sempre quando um pod é colocado dentro de um node.
# Ele é levado em conta na escolha do node onde será colocado o pod.
# Kube-schedules é quem decide em qual worker meu pod vai rodar, ele avalia os recursos.
# ==========================================================================
#
# O segredo está em declarar os resource no deployment
# O que o HPA leva em consideração é o (request).
# O limits é usado para definir a quantidade maxima de CPU / RAM usada por um POd ( hard limit )
# O HPA nao consulta o limits para tomada de decisao em escalar.
# A tomada de decisão do scheduler de iniciar um novo Pod acontece por meio da metrica de request.

k explain horizontalpodautoscalers.spec
k explain horizontalpodautoscalers.spec.metrics.resource.target
k explain horizontalpodautoscalers.spec | grep required
maxReplicas	<integer> -required-
scaleTargetRef	<CrossVersionObjectReference> -required-

# Um recurso namespace
k api-resources | grep hpa
horizontalpodautoscalers            hpa                               autoscaling/v2                    true         HorizontalPodAutoscaler

k neat <<< $(k autoscale deployment nginx --cpu=50 --min=1 --max=5 --dry-run=client -o yaml)

# HPA ( Baseado em milicore do CPU )
# Quando o workloads variam muito
# Requer um controle absoluto de CPU

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

# Saida do HPA quando usa-se regras baseadas em Milicore
k get hpa
NAME    REFERENCE          TARGETS      MINPODS   MAXPODS   REPLICAS   AGE
nginx   Deployment/nginx   cpu: 0/10m   1         5         1          51m



# HPA ( Baseado em % de Uso do CPU )
#
# Quando definido bem o requests.cpu
# Na grande maioria dos workloads (APIs, web, microserviços)

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

# Validando processo
# Monitore o HPA
k get hpa -w
nginx   Deployment/nginx   cpu: 0%/50%     1         5         1          114s

nginx   Deployment/nginx   cpu: 20%/50%    1         5         1          5m1s
nginx   Deployment/nginx   cpu: 200%/50%   1         5         1          5m31s
nginx   Deployment/nginx   cpu: 200%/50%   1         5         4          5m46s
nginx   Deployment/nginx   cpu: 110%/50%   1         5         4          6m1s

# Gerando carga de Stress no Nginx
k run --image alpine --rm -it teste-curl sh
apk add curl
while true; do curl -I nginx; done

# Vendo os Pods sendo criados.
k get pods
nginx-7577f95fd6-2zqjb   0/1     ContainerCreating   0          5s
nginx-7577f95fd6-hdmbf   0/1     ContainerCreating   0          5s
nginx-7577f95fd6-sl8fh   1/1     Running             0          30m
nginx-7577f95fd6-vhn74   0/1     ContainerCreating   0          5s

# Após encerrar a carga de Stress, os Pods devem assumir o valor default do deployment.
# Mesmo com CPU baixa, ele “segura” os pods por alguns minutos antes de matar

k get pods
NAME                     READY   STATUS        RESTARTS   AGE
nginx-7577f95fd6-2zqjb   1/1     Terminating   0          6m32s
nginx-7577f95fd6-8kx5t   1/1     Terminating   0          5m47s
nginx-7577f95fd6-hdmbf   1/1     Terminating   0          6m32s
nginx-7577f95fd6-sl8fh   1/1     Running       0          36m
nginx-7577f95fd6-vhn74   1/1     Terminating   0          6m32s
teste-curl               1/1     Running       0          7m50s

# Como deixar o scale down mais rápido.
# Adicionando o Bloco abaixo no manifesto...

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

#*************************** Etendendo o calculo do HPA *****************************
#

https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/#algorithm-details

# ceil => Função de arrendodamento ( Golang )

# Fórmula para determinar a quantidade de replicas para aguentar as requisiçoes.
# Ele vai calcular a quantidade de replicas desejadas
#
# currentReplicas    => Replicas definidas no deployment
# desiredMetricValue => HPA averageUtilization
# currentMetricValue => Utilização/Desejado Isso é calculado baseado no request limits ( requests => cpu: 10m )

k get hpa
NAME        REFERENCE          TARGETS       MINPODS   MAXPODS   REPLICAS   AGE
nginx    Deployment/nginx    cpu: 0%/50%       1         5         1        105m

# Ex:
# Se minha app precisa de 10m ( mili core ou milicpu ), mas no momento não tem utilização e o pod está consumindo 3m de cpu.
# Sendo que para esse POD foi definido 10m. Esse  é o maximo e como se fosse o hard limit.
# Esse 10m e o request pois e nesse campo que o HPA atua.
#
k top pods
NAME                     CPU(cores)   MEMORY(bytes)
nginx-7577f95fd6-sl8fh   0m           10Mi

# Vamos imaginar que vc definiu isso no seu HPA
# Do nada seu Pod começa a usar 12m cpu , isso quer dizer que 12m é maior que 10m que é maior que 100%
# OS 10m representa a totallidade de CPU tolerada pelo HPA ( ele representa o 100% )

- resource:
    name: cpu
    target:
      averageValue: 10m
      type: AverageValue
  type: Resource

# Pods trabalhando em sem sobrecarga
k get hpa
NAME    REFERENCE          TARGETS      MINPODS   MAXPODS   REPLICAS   AGE
nginx   Deployment/nginx   cpu: 0/10m   1         5         1          73m

# Pods trabalhando com sobrecarga
k get hpa
nginx   Deployment/nginx   cpu: 10m/10m   1         5         4          69m

# Regra de 3
10m -- 100%
12m -- x
10x = 1200
x = 120%

# Entao posso afirmar que a request definido no manifesto ( 10m isso equivale a 100% )
# Esse valor será o atributo usado para calculo do HPA
# mas com Pods consumindo 32m tem consumido 320% da cpu definida.

desiredReplicas = ceil[currentReplicas * ( currentMetricValue / desiredMetricValue )]

desiredReplicas = ceil[1 * ( X / 50 )]

desiredReplicas = ceil[1 * ( 320 / 60 )]

desiredReplicas = ceil[1  * ( 5.3 )]

desiredReplicas = 6

# Fazendo na prática
watch kubectl top pod nginx-599d9c6bc5-twzk8
NAME                     CPU(cores)   MEMORY(bytes)
nginx-599d9c6bc5-twzk8   58m           3Mi

# Suponhamos que
# 58m => Regrinha de 3 ( Isso quer dizer quase 580%)

desiredReplicas = ceil[1 * ( 580 / 60 )]

desiredReplicas = ceil[1 * ( 9.666 )]

desiredReplicas = 10

# Sendo assim o valor desejado para atender essa demanda seria 10 Replicas.
# Se algum pod estiver trabalhando com mais de 10m cpu HPA irá provisionar mais nodes.

k get hpa -w
NAME        REFERENCE          TARGETS       MINPODS   MAXPODS   REPLICAS   AGE
nginx-hpa   Deployment/nginx   cpu: 0%/60%     1         50        1          92s
nginx-hpa   Deployment/nginx   cpu: 580%/60%   1         50        1          5m16s
nginx-hpa   Deployment/nginx   cpu: 23%/60%    1         50        10          11m
nginx-hpa   Deployment/nginx   cpu: 1%/60%     1         50        10          11m
nginx-hpa   Deployment/nginx   cpu: 0%/60%     1         50        10          12m

https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/#default-behavior

# Stabillization window , define como o kubernetes desescala o pods ( Isso aqui que é punk para ele )
# usado para scale down.
#
# Padrao ( 300s / 5 minutos )

k explain hpa.spec
k explain hpa.spec.behavior
k explain hpa.spec.behavior.scaleDown
k explain hpa.spec.behavior.scaleDown.stabilizationWindowSeconds


#================================= Vertical (VPA) ===================================
#
# Deployment => ReplicaSet => Pod
# OBS.: O VPA só ira atuar em deployments que tenha no mínimo 2 réplicas
# Qual comportamento?
#
# Ele mata um dos pods, o novo Pod ao ser criado será interceptado pelo VPA que ajustará os request limits com
# um valor definido no VPA ( recursos necessários ) e ai sim o Pod sobe.
#
# Aplicaçoes Monolitas é um bom caso de uso de VPA
# Assim como no HPA no VPA leva-se em consideração o request limits.
#
#
# VPA não é deployado automaticamente

https://github.com/kubernetes/autoscaler

# OBS.: Faça checkou na ultima tag estavel
#
# VPA atua em cima dos enventos
#
# cluster-autoscaler é usado pelos cloud providers para escalar os nodes
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

# Como o VPA trabalha?
# Ele intercepta a criação do POD e ajusta dinamicamente os request limits, observe que ele atua a nivel de Pod.
# Ele usa esse recuso de Webhook para gerir isso.

k get mutatingwebhookconfigurations
NAME                                         WEBHOOKS   AGE
vertical-pod-autoscaler-vpa-webhook-config   1          3m18s

# Yaml
k get mutatingwebhookconfigurations vertical-pod-autoscaler-vpa-webhook-config -o yaml

# Açoes as quais esse mutatingweebhook irá trigar.
# - Qualquer chamada de create no recurso de POds. Sempre que um pod for criado , ele vai cair nesse Hook
# - Sempre que atualizar ou criar um VPA
#
# O que ele faz?
#
# Ele pega a requisição e manda para o seu service ( HPA Webhook )

  service:
      name: vertical-pod-autoscaler-vpa-webhook
      namespace: vertical-pod-autoscaler
      port: 443

k get svc -n vertical-pod-autoscaler

# O que está por de traz desse serviço?
k get endpointslices.discovery.k8s.io -n vertical-pod-autoscaler
NAME                                        ADDRESSTYPE   PORTS   ENDPOINTS     AGE
vertical-pod-autoscaler-vpa-webhook-r59kl   IPv4          8000    10.244.0.23   8m42s

# Quem é esse POd ( 10.244.0.23 )?
k get pods -A -o wide | grep 10.244.0.23
vertical-pod-autoscaler   vertical-pod-autoscaler-vpa-admission-controller-7f4667b6fszspr   1/1     Running   0          9m56s   10.244.0.23

# Obs:
#
✔️ O Vertical Pod Autoscaler calcula novos requests
✔️ Ele pode recriar o pod para aplicar esses valores
✔️ Ele usa o valor de Target, não o manifesto YAML

# Quem define o valor final?
#
👉 É o recommender do VPA

Ele calcula:
Target:
  cpu: 350m
  memory: ~335Mi

# EvictedPod ... to apply resource recommendation
👉 Isso significa:

✔️ VPA calculou
✔️ VPA decidiu
✔️ VPA matou o pod
✔️ VPA aplicou novos requests

💥 O VPA NÃO reage diretamente ao OOM

❌ não diz “deu OOM → sobe pra 1GB”
✅ diz “uso médio indica que precisa ~335Mi”

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

# Monitore os Eventos dos Pods ao vivo
# Esse recurso não ficará notificando criacão de Pods, para esse laboratório.
# Observer que após criados os Pod acima, não terá ação de create.
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



# Aplciando VPA
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

# Após a aplicação do VPA , os PODs foram interceptados e recriados.
# Como tenho 3 Pods, fez isso um para cada Pod.
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


# Porque Matou os Pod e os Recriou
# O campo Recomendation dita a regra do jogo do VPA
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


# Gerando Carga de Stress
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

# Observe que o VPA ja alterou o resource limits para o valor que ele mesmo prospectou.
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
# Gerando Carga de dados.
#
# Watching
watch -n 2 "kubectl get pod -l app=nginx -o wide"

# Em outra aba
k get events --sort-by=.lastTimestamp -w


# Running - Gerar carga de stress
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

# Running - Gerar carga de stress
k run --image alpine --rm -it teste-curl sh
apk add curl
while true; do curl -I nginx-service; done
```

[Índice](#-menu)

# 🚀 Create Object - CNI

```bash
# CNI é diferente entre os cluster ( AWS / Azure )
# CNI é uma especifiçao de como a rede deve se comportar num cluster K8S.
# Isso gera uma grande diversidade de implementaçoes, sendo que cada cloud provider tem suas necessidades para ser atendida.

# Entao isso não pode ser implementado pelo core do código k8s e sim pelo vendor que vai entregar o k8s como serviço para vc.

# Um pod precisa comunicar-se com outro pod independente em qual node estiver rodando , sem usar nat.
# Um daemonset tem que ter a capacidade de comunicar-se diretamente com o pod
# CNI geralmente é um daemonset que roda em cada no do cluster

k get pods -n kube-system -o wide | grep kindnet

kindnet-7npgk   1/1     Running   0          4h50m   172.17.0.2   prgs-control-plane  <none>           <none>

# Criando um Deployment e um Service
k create deployment --image=nginx nginx
k create service clusterip nginx --tcp=80:80

k get pods -o wide
NAME                     READY   STATUS    RESTARTS   AGE   IP            NODE                 NOMINATED NODE   READINESS GATES
nginx-66686b6766-xgt78   1/1     Running   0          71s   10.244.0.32   prgs-control-plane   <none>           <none>

# Listando as Interface no Host
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

# Porque se cria tanta interface de rede no Host? Não Conflita?
👉 Porque cada pod precisa de uma "placa de rede virtual" própria.
👉 No Kubernetes, um pod não compartilha a interface do node diretamente.
👉 Recurso que está mapeado a um Network namespace no nível do kernel do Host ( isola a rede ).
👉 Então o kernel cria um veth pair:

[pod netns] eth0 <------> vethXXXX [node]

👉 É literalmente um “cabo virtual Ethernet”.
👉 uma ponta fica no namespace do pod a outra ponta fica no node.
👉 o tráfego entra por um lado e sai pelo outro
👉 ponta da interface no node/container

# Esses IPs iguais NÃO conflitam?
👉 IP representa SOMENTE este endpoint.
👉 Sem subnet /32

# Porque Linux permite o MESMO IP em interfaces diferentes?
👉 São rotas point-to-point
👉 usam policy routing
👉 usam namespaces
👉 ou são usados como next-hop internos do CNI

# Ex:
inet 10.244.0.1/32 scope global vethXXXX

# De forma prática
pod A <-> veth A usa 10.244.0.1
pod B <-> veth B usa 10.244.0.1

pod1 ===== fio privado ===== node
pod2 ===== fio privado ===== node
pod3 ===== fio privado ===== node

👉 cada pod precisa de stack TCP/IP própria
👉 isolamento de rede
👉 firewall independente
👉 roteamento independente
👉 policy independente
👉 observabilidade independente

1 pod = 1 netns = 1 eth0 = 1 veth pair


#************************************ Debug CNI ************************************
#
# Tenho essa procissão de Network, qual delas atende meu Pod ( nginx-66686b6766-xgt78 )
k get pods -o wide
NAME                     READY   STATUS    RESTARTS   AGE   IP            NODE                 NOMINATED NODE   READINESS GATES
nginx-66686b6766-xgt78   1/1     Running   0          24h   10.244.0.32   prgs-control-plane   <none>           <none>



# Obs.:
# O 10.244.0.1/32 que você viu NÃO é o IP do pod.
# Esse normalmente é IP da bridge/rota usada pelo CNI.
#
# Descobrir a outra ponta do veth
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
- a outra ponta do par veth possui índice 2 dentro do namespace do pod.

# Inspecionando CNI ( cni-aa5c9c4e-2a72-db95-c2b8-ef261bf21dc2 )
# Ex:
docker exec prgs-control-plane bash -c "nsenter --net=/var/run/netns/cni-aa5c9c4e-2a72-db95-c2b8-ef261bf21dc2 ip link"

1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: eth0@if3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default qlen 1000
    link/ether 3a:ba:dd:52:a3:38 brd ff:ff:ff:ff:ff:ff link-netnsid 0

# O que isso quer dizer?
👉 Perceba:

# host vê if2
# pod  vê if3

# Como identificar qual CNI está vinculada ao meu Pod e Service?

# Exportar Variavel
export cnis=$(docker exec prgs-control-plane bash -c "ip link | egrep -o 'cni-[a-z0-9-]+'")

# Print
docker exec prgs-control-plane bash -c "printf '%s\n' \"${cnis}\""

# Saida padrao do nsenter
2: eth0@if33: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000 link-netnsid 0
    inet 10.244.0.32/24 brd 10.244.0.255 scope global eth0
       valid_lft forever preferred_lft forever

# Regex
# (?<=inet\s)\d+(\.\d+){3}
# (?<=...) → lookbehind positivo ( Olho para traz )
# inet     → texto literal bate com palavra chave inet
# \s       → um espaço em branco
# Pego IPV4 apos esse match

# 10.244.0.32 => Ip do Pod ( Nginx )

while read -r cni;
do
  match=$(docker exec prgs-control-plane bash -c "nsenter --net=/var/run/netns/${cni} ip -4 addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}'")
  [[ ${match} == "10.244.0.32" ]] && echo "${cni} - ${match}"
done <<< ${cnis}

# Entao a CNI que está atendendo o Pod Nginx é:
cni-bab69db5-ed3d-ef0e-4aae-2c8fc10d3c25 - 10.244.0.32
```

[Índice](#-menu)

# 🚀 Create Object - DNS

```bash
# Kube-DNS resolv Name
k get svc -n kube-system
NAME             TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                  AGE
kube-dns         ClusterIP   10.96.0.10      <none>        53/UDP,53/TCP,9153/TCP   78m
metrics-server   ClusterIP   10.108.129.79   <none>        443/TCP                  73m

# Criando um Deployment e um Service
k create deployment --image=nginx nginx
k create service clusterip nginx --tcp=80:80

pod=$(k get pods -o=jsonpath='{range .items..metadata}{.name}{"\n"}{end}')
k exec -it $pod -- bash -c "cat /etc/resolv.conf"

search default.svc.cluster.local svc.cluster.local cluster.local
nameserver 10.96.0.10
options ndots:5

# Quem gera esse resolv.conf?
# O próprio kubelet

👉 Search => Definie os domínios de busca automática.
nginx.default.svc.cluster.local
nginx.svc.cluster.local
nginx.cluster.local

👉 Nameserver => Ip do servidor.
👉 options    => ndots:5

# Ela controla quando um nome é considerado “absoluto” (FQDN) ou “relativo”.
# Se o hostname tiver MENOS de 5 pontos (.), o resolver tentará aplicar os domínios do search.
# Ex:
# curl google.com
# Tentará resolver...
# google.com.default.svc.cluster.local
# google.com.svc.cluster.local
# google.com.cluster.local
# Tenta isso antes, de tentar isso...
# google.com

# Esses sao os Pod que irão atender essas requisiçoes
k get endpoints -n kube-system kube-dns
NAME       ENDPOINTS                                               AGE
kube-dns   10.244.0.2:53,10.244.0.4:53,10.244.0.2:53 + 3 more...   14m

k get pods -n kube-system -o wide | grep coredns
coredns-66bc5c9577-9wjg7                     1/1     Running   0          15m   10.244.0.2   prgs-control-plane   <none>           <none>
coredns-66bc5c9577-t4k6n                     1/1     Running   0          15m   10.244.0.4   prgs-control-plane   <none>           <none>

# Monitorando os Logs
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

# Observe que os Logs do kube-system não trazem a resolução dos Nomes
# Como Ativar / Habilitar ( Logs e Debug )?

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

# Após modificar o ConfigMap, reinicie os Pods
k rollout restart -n kube-system deployment coredns
deployment.apps/coredns restarted

# Execute novamente o monitoramento
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


# Se tiver um DNS interno, resolvendo outro dominio, como fazer para esse Dominio ficar acessível no cluster?
# Deve-se configurar um DNS Externo.

k get cm -n kube-system coredns
k get cm -n kube-system coredns -o yaml
k edit cm -n kube-system coredns -o yaml

# Adicione um novo bloco, no meu caso o bloco chama-se "interno.prgs.corp"

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

# Reinicie os Pods
k rollout restart -n kube-system deployment coredns

# Nesse cenário, O DNS externo ( vault.interno.prgs.corp aponta para 192.168.56.56 )
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

[Índice](#-menu)

# 🚀 Create Object - Network Policies

```bash

# Para reproduzir esse laboratório é necessário ter uma CNI que suporta Policies. No cenários abaixo foi implementado o Kind com suporte a Cilium.
#
# Subir o kind com suporte a cilium

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
#   - Recebe tráfego de fora, mas só pode conversar com Backend.
#   - Não pode falar com database.

# Backend:
#   - Recebe requisiçoes do Frontend
#   - Pode fazer requisições para o Database.

# Database:
#   - Só recebe requisiçoes do Frontend.


#******************* Frontend não consegue Chegar no Database **********************
#
# 1) Conectar no Database e deixar uma porta Listen ( 5432 )

k exec -it database-57f5bfb9c5-tfb6b  -- sh
nc -lvp 5432
listening on [::]:5432 ...
connect to [::ffff:10.244.2.181]:5432 from [::ffff:10.244.1.49]:42587 ([::ffff:10.244.1.49]:42587)

# 2) Conectar no Frontend e tentar conectar na porta ( 5432 )
k exec -it frontend-64f4b788f9-hw8hb  -- sh
nc -v 10.244.2.181 5432
10.244.2.181 (10.244.2.181:5432) open

# Esse Policie aplicada permite conexão externa , mas não permite conexão intra cluster.
# Ela bloqueia tudo, como o DNS está no range dos Pods ( 10.244.0.0/16 ) não consigo resolver nomes.
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

[Índice](#-menu)

# 🚀 Create Object - RBAC / CRB / RB

```bash

# RBAC ( Role Based Access Control )
#
# Role => Função que te dá acesso a alguma coisa.

           AUTH            |        Authorization
-------------------------------------------------------------
                            ------ ( CRB ) Cluster Rolling Binding => View
( Usuário kubeconfig )-----|
                            ------ (  RB ) Rolling Binding         => Monitoring ( ro )

# Auth ( Processo que verifica se vc é diz quem ser )
#
# Ex: Usuário irá interagir com o cluster por meio do kubectl, mas os mesmo comandos as mesmas chamadas
# podem ser realizadas por algum pod que esteja em execução e se esse POD tiver previlégio usando ( services accounts ),
# ele poderá efetivar alteraçoes no cluster.

# Todas as chamadas sejam feitas por um usuário ( kubectl ), dentro ou fora do cluster irão passar pelo api-server.
#
# Ao passar pelo api-server é necessário ser uma chamada de API, entao como esse acesso é autenticado , conseguimos
# mapear as permissões que podem ser realizado.

# ( CRB ) Cluster Rolling Binding => Dá acesso a recursos a nivel do cluster inteiro, não por namespace.
# Ex: Se eu der permissão para usuário ler os services, o usuário poderá ler todos todos os services de todos namespaces.

# ( RB ) Rolling Binding => Dá acesso a recursos a nivel de namespace

# O termo ( Binding ) é o que faz o atrelamento
# A role é o que dá o acesso.

# Ex: O cluster ja possui uma (CRB) nativa que dá acesso a leitura ao cluster.
# Se eu precisar monitorar o cluster , posso criar uma (RB) chamada ( monitoring-ro ) que dará acesso a todos os recursos dentro da namespace monitoring
```

[Índice](#-menu)

# 🚀 Create Object - RBAC / Create User

```bash

https://kubernetes.io/docs/reference/access-authn-authz/authentication/

https://kubernetes.io/docs/reference/access-authn-authz/certificate-signing-requests/#kubernetes-signers


# O kubernets só confia em certificados que ele mesmo assinou, no formato mais comum x509
# podemos criar um (CSR Certificate signing requests) e a CA do k8s assina e confia

# Não se cria um usuario no kubernetes ( Kind User ) isso nao existe. O kubernetes le o certicicado ( CN )

#********************** Criando Certificado para Usuário ***************************
#

openssl req -nodes \
  -days 365 \
  -newkey rsa:2048 \
  -keyout estagiario.key \
  -out estagiario.csr \
  -subj '/CN=estagiario/O=prgs/O=corp' \
  -addext 'subjectAltName = DNS:estagiario.prgs.corp'

# Observe que ele criou um ( BEGIN CERTIFICATE REQUEST )

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


# Para me autentica , vou precisar da key e do certificado assinado pelo kubernetes. O arquivo csr é a requisição para assinar o certificado.
#
# Criando um certificado para autenticar no kubeconfig
#
# Como assinar?

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

# Como checar Todas CSR abertas?
# Ele ficará como pendind até que um admin possa aprovar
k get csr
NAME             AGE   SIGNERNAME                                    REQUESTOR                        REQUESTEDDURATION   CONDITION
csr-p76zx        94m   kubernetes.io/kube-apiserver-client-kubelet   system:node:prgs-control-plane   <none>              Approved,Issued
estagiario-csr   8s    kubernetes.io/kube-apiserver-client           kubernetes-admin                 <none>              Pending

# Aqui é onde ele assina o certificado.
# Assinando Certificado
k certificate approve estagiario-csr
certificatesigningrequest.certificates.k8s.io/estagiario-csr approved

k get csr
NAME             AGE   SIGNERNAME                                    REQUESTOR                        REQUESTEDDURATION   CONDITION
csr-p76zx        94m   kubernetes.io/kube-apiserver-client-kubelet   system:node:prgs-control-plane   <none>              Approved,Issued
estagiario-csr   49s   kubernetes.io/kube-apiserver-client           kubernetes-admin                 <none>              Approved,Issued


# Extrair certificado
k get csr estagiario-csr -o yaml

# Como checar se o certificao foi assinado pelo k8s?
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

[Índice](#-menu)

# 🚀 Create Object - RBAC / Create Context

```bash

#**************** Configurando Nova Credencial Estagiário **************************
#
# Check o current Context
kubectl config current-context
kind-prgs

# Backup Config
cp ~/.kube/config{,.bkp}

# O arquivo ~/.kube/config guarda:
#
👉 clusters
👉 usuários (credentials/certificados)
👉 contexts

# Um context é a combinação de:
#
👉 cluster
👉 usuário
👉 namespace padrão

# Aqui é onde se cria um novo usuário no Kubeconfig
# Esse usuário ( estagiário ) usará seus certificados para autenticar.
# Definindo no kube/config as credencias do estagiário
kubectl config set-credentials estagiario --client-certificate=$(pwd)/estagiario.crt --client-key=$(pwd)/estagiario.key
User "estagiario" set.

# O que acontece internamente
# O kubeconfig ganha algo parecido com:

users:
- name: estagiario
  user:
    client-certificate: /caminho/estagiario.crt
    client-key: /caminho/estagiario.key

# Criando um Context chamado ( estagiário )
kubectl config set-context estagiario --cluster kind-prgs --namespace default --user estagiario

# O que isso gera?
contexts:
- context:
    cluster: kind-prgs
    namespace: default
    user: estagiario
  name: estagiario

# Trocando para o contexto
kubectl config use-context estagiario
Switched to context "estagiario".

Error from server (Forbidden): nodes is forbidden: User "estagiario" cannot list resource "nodes" in API group "" at the cluster scope

# Isso significa:
✅ autenticação funcionou
❌ autorização falhou

# Check o contexto
kubectl config current-context
estagiario

# Como checar todos os contexts existentes e qual está em uso.
kubectl config get-contexts
CURRENT   NAME                          CLUSTER      AUTHINFO           NAMESPACE
*         estagiario                    kind-prgs    estagiario         default
          kind-prgs                     kind-prgs    kind-prgs
          kubernetes-admin@kubernetes   kubernetes   kubernetes-admin

# OBs.:
# Os arquivos .kube/config estão sendo referenciado por um path ( /caminho/certificado )
# Caso queira definir no próprio .kube/config
# O resultado é o mesmo
#
cp ~/.kube/config{,.kind}

export base64_cert=$(base64 -w 0 <<< $(cat estagiario.crt))
export base64_key=$(base64 -w 0 <<< $(cat estagiario.key))

kubectl config set-credentials estagiario --client-certificate=/tmp/estagiario.crt --client-key=/tmp/estagiario.key
sed -i "s/client-certificate: \/tmp\/estagiario.crt/client-certificate-data: ${base64_cert}/" ~/.kube/config
sed -i "s/client-key: \/tmp\/estagiario.key/client-key-data: ${base64_key}/" ~/.kube/config
```

[Índice](#-menu)

# 🚀 Create Object - RBAC / Configurando Autorização

```bash

#**************** Configurando Autorização para Estagiário *************************
#
https://kubernetes.io/docs/reference/access-authn-authz/rbac/
https://kubernetes.io/docs/reference/access-authn-authz/rbac/#user-facing-roles
https://kubernetes.io/docs/reference/access-authn-authz/rbac/#clusterrole-example

# Quais resources?
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

# Todo o recurso namespaced pode ser vinculado a uma Role, restringindo apenas por namespace.
k api-resources | grep true

# Listar todos recurso namespaced
k api-resources --namespaced

# Volte para contexto que tem previlégios
kubectl config use-context kind-prgs
Switched to context "kind-prgs".

# Quais cluster roles existentes?
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

# Se eu der permissão a nivel de cluster eu dou permissão em todas as namespaces.

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

# Volte para contexto estagiário
kubectl config use-context estagiario
Switched to context "estagiario".

# Teste .... Ainda com erros?
k get pods -A
Error from server (Forbidden): pods is forbidden: User "estagiario" cannot list resource "pods" in API group "" at the cluster scope


# Porque continua dando erro?
👉 Apenas criamos a ClusterRole, agora temos que fazer o binding para conceder a ação ( list ).


# Volte para contexto que tem previlégios
kubectl config use-context kind-prgs
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

# Volte para contexto estagiário
kubectl config use-context estagiario
Switched to context "estagiario".

kubectl config get-contexts
CURRENT   NAME                          CLUSTER      AUTHINFO           NAMESPACE
*         estagiario                    kind-prgs    estagiario         default
          kind-prgs                     kind-prgs    kind-prgs
          kubernetes-admin@kubernetes   kubernetes   kubernetes-admin

# Lista os nodes
k get nodes
NAME                 STATUS   ROLES           AGE   VERSION
prgs-control-plane   Ready    control-plane   46m   v1.34.0

# Consigo listar os Pods?
# List Nodes , mas os Pods não tenho permisão?
k get pods -A
Error from server (Forbidden): pods is forbidden: User "estagiario" cannot list resource "pods" in API group "" at the cluster scope

# Volte para context com previlégios
kubectl config use-context kind-prgs
Switched to context "kind-prgs".

kubectl config get-contexts
CURRENT   NAME                          CLUSTER      AUTHINFO           NAMESPACE
          estagiario                    kind-prgs    estagiario         default
*         kind-prgs                     kind-prgs    kind-prgs
          kubernetes-admin@kubernetes   kubernetes   kubernetes-admin

# Existe um "ClusterRoleBinding" chamado "view" , que dará permissão de leitura para todos objetos do cluster
# Não da acesso a secrets ( Checar na documentação )

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

# Não é possível alterar
The ClusterRoleBinding "estagiario-ro" is invalid: roleRef: Invalid value: {"APIGroup":"rbac.authorization.k8s.io","Kind":"ClusterRole","Name":"view"}: cannot change roleRef

k get clusterrolebindings estagiario-ro
k delete clusterrolebindings estagiario-ro

✅ Reaplique o manifesto

# Volte para context com previlégios
kubectl config use-context estagiario
Switched to context "estagiario".

kubectl config get-contexts
CURRENT   NAME                          CLUSTER      AUTHINFO           NAMESPACE
*         estagiario                    kind-prgs    estagiario         default
          kind-prgs                     kind-prgs    kind-prgs
          kubernetes-admin@kubernetes   kubernetes   kubernetes-admin

# Execute a criação novamente
# Esse ClusterRole ( view ) , não consegue ver os nodes.

# Essa RBAC não permite ver os nodes
k get nodes
Error from server (Forbidden): nodes is forbidden: User "estagiario" cannot list resource "nodes" in API group "" at the cluster scope

# Consigo listar todos os Pods
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


# Se tentar deletar....
# Sem permissão.
k delete pod -n nginx-gateway ngf-nginx-gateway-fabric-76fc67668f-b8g7w
Error from server (Forbidden): pods "ngf-nginx-gateway-fabric-76fc67668f-b8g7w" is forbidden: User "estagiario" cannot delete resource "pods" in API group "" in the namespace "nginx-gateway
```

[Índice](#-menu)

# 🚀 Create Object - Role ServiceAccount + RolingBindgings

```bash

# Implementar Roles e Service Account
# Um cenário onde não se usa usuário para autenticar, o RBAC é feito por dentro dos pods de um cluster.
#
# Criar uma service account
#

# E um recurso vinculado ao namespace
k api-resources | grep sa
serviceaccounts                     sa                                v1                                true         ServiceAccount

k create sa kubectl-sa --dry-run=client -o yaml
k create sa kubectl-sa

# Check
k get sa
NAME      SECRETS   AGE
default      0         8m18s
kubectl-sa   0         14s

# Criando um Pod e Adicionando a ServiceAccount
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

# Conectando no Pod e executando comandos do Kubectl
k exec -it kubectl -- bash

I have no name! [ / ]$ kubectl get pods
Error from server (Forbidden): pods is forbidden: User "system:serviceaccount:default:kubectl-sa" cannot list resource "pods" in API group "" in the namespace "default"

I have no name! [ / ]$ kubectl get nodes
Error from server (Forbidden): nodes is forbidden: User "system:serviceaccount:default:kubectl-sa" cannot list resource "nodes" in API group "" at the cluster scope

I have no name! [ / ]$ ls /var/run/secrets/kubernetes.io/serviceaccount/token
I have no name! [ / ]$ cat /var/run/secrets/kubernetes.io/serviceaccount/token
ZMOIdLaU3Gm0VcXZdInXJHvP9xGx4JhKWSbWerbFBwt1Um_G8OsEsNBtBeMa28lrWxx7nDo8c98IzHAgug6xeQwI.....

#********************************** Criando a Role *********************************
# Como o Pod se autentica?
#
# Preciso agora criar uma Role ( Vou dar acesso apenas a namespace )
# Obs.: Se quero restringir apenas a uma namespace, minha "Role" deve ser criada dentro dessa namespace.

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

# Imagine que queira dar permissao aos pods da namespace "argocd" , entao crio uma role e
# uma rolebinding dentro dessa namespace.

# Checo as Roles existentes.
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


# Criando a Role dentro do namespace ( kube-system )
cat <<EOF | kubectl apply -f -
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

#**************************** Criando a RoleBinding *********************************
#
# OBS.:
# Recursos criados em seus respectivos namespaces, deve ser informados.
subjects:
- kind: ServiceAccount
  name: kubectl-sa      # Nome da service account
  namespace: default    # Name Space onde esse SA está localizada


cat <<EOF | kubectl apply -f -
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

#**************************** Testando Autenticação *********************************
#

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

#********************************* E os Jobs ****************************************
#

I have no name! [ / ]$ kubectl get jobs -n kube-system
Error from server (Forbidden): jobs.batch is forbidden: User "system:serviceaccount:default:kubectl-sa" cannot list resource "jobs" in API group "batch" in the namespace "kube-system"

cat <<EOF | kubectl apply -f -
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

[Índice](#-menu)

# 🚀 Create Object - Affinity / Node-Selector Labels

```bash
# O Node Selector funciona como uma regra de agendamento no Kubernetes.
#
# Quando um workload (como Pod, Deployment, DaemonSet ou StatefulSet) é criado, a requisição é enviada para o kube-apiserver, que armazena o objeto no etcd.
#
# Em seguida, o kube-scheduler identifica que existe um Pod sem node definido (Pending) e avalia em qual node ele pode ser executado.
#
# Durante essa análise, o scheduler considera diversos critérios definidos no YAML e no cluster, como:

👉 nodeSelector
👉 nodeAffinity
👉 taints e tolerations
👉 recursos disponíveis no node (CPU, Memória)
👉 políticas de scheduling

# Após escolher o node mais adequado, o scheduler atualiza o Pod informando em qual node ele deve rodar.
#
# Então o ReplicaSet (ou outro controller, como StatefulSet/DaemonSet) garante que os Pods necessários sejam criados, e o kubelet do node selecionado recebe a instrução para iniciar os containers.
#

k get pods -n kube-system kube-scheduler-master01
NAME                      READY   STATUS    RESTARTS      AGE
kube-scheduler-master01   1/1     Running   0            3h23m

# Listar todas as labels
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

# O status ficará assim como pending , pois não tem essa label definda.
#
# Definindo Label
#
kubectl label node worker01 prgs/postgres=true

# Listando todos Pods após criação da label.
k get pods
NAME                          READY   STATUS              RESTARTS      AGE
nginx-0                       1/1     Running             1 (25m ago)   3h11m
nginx-1                       1/1     Running             1 (25m ago)   3h5m
nginx-paulo-78455bbb4-82vkz   1/1     Running             1 (25m ago)   3h14m
postgres-64f4bd66b8-tgnwj     0/1     ContainerCreating   0             8m54s
```

[Índice](#-menu)

# 🚀 Create Object - Affinity / Node-Affinity

```bash

https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/

# Node Afinity => é mais flexivel !!!
# Utilizado quando quero dar preferencia para rodar em determinado worker,
# mas caso ele seja deployado em outro worker não tem problemas.
#
# Como é uma regra de "required" ele ficará em pendind se não bater na regra.
#
# Comportamento do node selector

#************ Affinity - Comportamento Semelhante NodeSelector ***********************
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

# OBS.: Mesmo comportamento do Node Selector
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

#****************** Affinity - Tenta Schedular no Node Correto ***********************
#
# Ele irá tentar schedular o Pod no Node que tem a label "prgs/postgres", se não achar, ele joga em qualquer um

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
# Esse wight é o peso como ele é um array eu consigo mensurar qual terá mais preferencia para deploy.
#
# O conceito de weight no nodeAffinity serve para definir uma preferência do scheduler
# preferred → preferência, não obrigação

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

[Índice](#-menu)

# 🚀 Create Object - Affinity / Pod-Affinity

```bash

https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#an-example-of-a-pod-that-uses-pod-affinity

#
# PodAntiAffinity é uma regra usada para evitar que determinados Pods sejam executados próximos uns dos outros.
#
# Ela é muito utilizada para:
# - alta disponibilidade
# - distribuição de carga
# - evitar ponto único de falha

# Pegar na doc pois a sintaxe é puck e garantir as labels pois ela é a chave.
#
# Vamos deployar postgres no worker do postgres e nao quero o pod do frontend no mesmo worker

# Definindo Label
#
kubectl label node worker01 prgs/postgres=true
kubectl label node worker01 app=database

# Criando Deployment
# A label será usada para fazer match no afinity do deployment do backend
#
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

# Listar as labels deste pod
pod=$(k get pods -o=jsonpath='{range .items..metadata}{.name}{"\n"}{end}' | grep '^postgres-')

k get pod $pod --show-labels
NAME                        READY   STATUS    RESTARTS   AGE   LABELS
postgres-684cb45d6-hbwth   1/1     Running   0          6s    app=database,pod-template-hash=684cb45d6

# Quero que a aplicação rode próximo do banco, no mesmo worker.
#
# Check
kubectl get nodes --show-labels | grep -o app=database
app=database

# Criando Deployment
#
# topologyKey: prgs/postgres
# O que isso significa...
# o Pod deve ficar no mesmo node onde existe um Pod com Label prgs/postgres
# O topologyKey NÃO é um valor arbitrário qualquer.
# Ele precisa referenciar uma label existente nos nodes, e todos os nodes envolvidos precisam possuir essa label.
#
# topologyKey usa somente a CHAVE da label do node.
# O podAffinity não procura nodes com label app=database.
#
# Ele procura:
# Pods com app=database
#
# e depois usa o topologyKey para descobrir em qual “domínio/topologia” esse Pod está.
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

[Índice](#-menu)

# 🚀 Create Object - Affinity / PodAntiAffinity

```bash
#****************** Affinity - Frontend Rodando em Outro Node  ***********************
#
# Como não tenho outro node , vou remover a regra que evitar usar o node ( Control Plane ) para schedular Pods.
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

[Índice](#-menu)

# 🚀 Create Object - Affinity / Tolerations

```bash
| Tipo             | Comportamento           |
| ---------------- | ----------------------- |
| NoSchedule       | Não agenda novos Pods   |
| PreferNoSchedule | Evita, mas pode agendar |
| NoExecute        | Remove Pods já rodando  |

# Ensure no workloads are scheduled on control-plane nodes.
# Garantindo que nenhum pod sera schedulado nos control-plane.
# A menos que ele tenha toleration correspondente.

k taint nodes master01 node-role.kubernetes.io/control-plane=:NoSchedule
k describe node master01 | grep Taint

# O que o toleration?
# Isso declarado no manifesto garante que o Pod possa ser schedulado no control-plane por ex,
# mesmo que tenha um taint

tolerations:
- key: "node-role.kubernetes.io/control-plane"
  operator: "Exists"
  effect: "NoSchedule"


# E se meu taint for "NoExecute" ?
# O efeito NoExecute faz duas coisas:
# Impede que novos Pods sejam agendados
# Remove Pods que já estão rodando e não toleram o taint

👉 O Pod:

# Pode ser agendado
# Não será removido
# Fica rodando indefinidamente

| Taint      | Sem toleration      | Com toleration     | Com tolerationSeconds      |
| ---------- | ------------------- | ------------------ | -------------------------- |
| NoSchedule | Não agenda          | Agenda             | Agenda                     |
| NoExecute  | Não agenda + remove | Agenda + permanece | Agenda + remove após tempo |


# Definir no manifesto os workloads que pode-se usar.
# Como os workers tem label de worker, entao os pods só serão agendados nos worker.
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


# Voltar o padrao, para nao permitir que pods seja agendados no control plane
kubectl taint nodes master01 node-role.kubernetes.io/control-plane:NoSchedule

# Na prática para garantir que o frontend não rode nos pod da aplicação posso forcar a amizade.

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

# Listando todos os Pods
k get pod -o wide
NAME                       READY   STATUS    RESTARTS   AGE   IP             NODE       NOMINATED NODE   READINESS GATES
backend-58fd97f655-bqfgd   1/1     Running   0          19m   10.244.1.163   worker01   <none>           <none>
frontend-d646846c6-9jczm   1/1     Running   0          8s    10.244.0.51    master01   <none>           <none>
postgres-684cb45d6-hbwth   1/1     Running   0          20m   10.244.1.162   worker01   <none>           <none>
```

[Índice](#-menu)

# 🚀 Cluster Upgrade - Ferramentas e Boas Práticas

```bash
# Para esse laboratório vamos usar Vms provisionadas via KVM
# Cluster atual rodando na versao 1.34
# Control Plane => master01
# Control Data  => worker01

# OBS.:
# Sempre uma minor por vez
#
# Cuidado com as APIs deprecada

https://kubernetes.io/docs/reference/using-api/deprecation-guide/


k get nodes
NAME       STATUS   ROLES           AGE   VERSION
master01   Ready    control-plane   87d   v1.34.4
worker01   Ready    worker          87d   v1.34.4

# kubenet
# Ajuda a mapear as APIs deprecadas
https://github.com/doitintl/kube-no-trouble

sh -c "$(curl -sSL https://git.io/install-kubent)"
kubent --help

# Vai me mostra uma lista de coisas que podem dar problema.
# Faz um dump e te mostra as mudancas
# Faça a mudanca das versoes das api antes do upgrade

# Quero atualizar para 1.35
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

# Observe que passou liso, entao o cluster não vai quebrar no processo de Upgrade.

#************************ Como Simular kubent Com Mudancas **************************
#
# Pegue a versao o flow suportada
kubectl api-resources | grep flow
flowschemas                                      flowcontrol.apiserver.k8s.io/v1   false        FlowSchema
prioritylevelconfigurations                      flowcontrol.apiserver.k8s.io/v1   false        PriorityLevelConfiguration

# O flowcontrol.apiserver.k8s.io é o mecanismo de API Priority and Fairness (APF) do Kubernetes.
#
# Ele controla:
👉 quem pode consumir a API
👉 quanto cada cliente pode consumir
👉 como a fila de requisições é organizada
👉 proteção contra overload do kube-apiserver

# Em resumo:
👉 O APF impede que um cliente “afogue” a API do Kubernetes.

# Supondo que esteja rodando o cluster na 1.31 e quisesse atualizar para 1.32
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
[Índice](#-menu)

# 🚀 Cluster Upgrade - Control Plane / Masters

```bash

# Produtos Deployados No momento do Upgrade
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

# Para esse laboratório o Cluster foi criado via kubeadm, pois no exame será abordado esse cenário.
#
# Todos os comandos listados abaixo devem ser executados no master ( control plane )
#
# Mostra as versoes disponiveis
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

# Meu repositório aponta para 1.34, então os upgrades de Minio Version fica confinado a essa versão.

# Atuallizar minha lista de repositorio.
# Estou emitindo os comandos logado como root

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.35/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.35/deb/ /" | tee /etc/apt/sources.list.d/kubernetes.list
apt-get update -y

# Liste novamente as versões disponíveis
apt list -a kubeadm
Listing... Done
kubeadm/unknown 1.35.5-1.1 amd64 [upgradable from: 1.34.4-1.1]
kubeadm/unknown 1.35.4-1.1 amd64
kubeadm/unknown 1.35.3-1.1 amd64
kubeadm/unknown 1.35.2-1.1 amd64
kubeadm/unknown 1.35.1-1.1 amd64
kubeadm/unknown 1.35.0-1.1 amd64
kubeadm/now 1.34.4-1.1 amd64 [installed,upgradable to: 1.35.5-1.1]

# Ao logar na máquina o próprio Ubuntu que mostra que ele precisam ser atualizado.

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

# Se simplismente rodar o upgrade será ignorado os pacotes ( kubeadm kubectl kubelet )
# POis os mesmos estão marcado como ( Hold ), para não atualizar.
# Nessa etapa garanto o upgrade de outros pacotes
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

# Os pacotes não foram atualizados
kubectl version
Client Version: v1.34.4
Kustomize Version: v5.7.1
Server Version: v1.34.4

# OBS.: Se no momento do upgrade aparecer janela de sugestao para reinicio dos servicos, desmaque as opçoes relacionadas a:
# - kubelet.service
# - containerd.service

# Listar os pacotes a serem atualzidos
apt list --upgradable
Listing... Done
kubeadm/unknown 1.35.5-1.1 amd64 [upgradable from: 1.34.4-1.1]
kubectl/unknown 1.35.5-1.1 amd64 [upgradable from: 1.34.4-1.1]
kubelet/unknown 1.35.5-1.1 amd64 [upgradable from: 1.34.4-1.1]

# Como checar os pacotes marcados como Hold
# Ao emitir o comando abaixo, os pacotes iniciados com ( hi ) estão marcados para não serem atualziados.
dpkg -l | grep kube
hi  kubeadm                          1.34.4-1.1                              amd64        Command-line utility for administering a Kubernetes cluster
hi  kubectl                          1.34.4-1.1                              amd64        Command-line utility for interacting with a Kubernetes cluster
hi  kubelet                          1.34.4-1.1                              amd64        Node agent for Kubernetes clusters
ii  kubernetes-cni                   1.7.1-1.1                               amd64        Binaries required to provision kubernetes container networking

# Devo marcar todos como unhold?
# NÃO !!!
# Obs.: Nesse primeiro momento apenas o kubeadm

apt-mark unhold kubeadm
Canceled hold on kubeadm.

# Ao ficar marcado com unhold seu status muda para ( ii )
dpkg -l | grep kube
ii  kubeadm                          1.34.4-1.1                              amd64        Command-line utility for administering a Kubernetes cluster
hi  kubectl                          1.34.4-1.1                              amd64        Command-line utility for interacting with a Kubernetes cluster
hi  kubelet                          1.34.4-1.1                              amd64        Node agent for Kubernetes clusters
ii  kubernetes-cni                   1.7.1-1.1                               amd64        Binaries required to provision kubernetes container networking

# Atualizando kubeadm
apt install kubeadm

# OBS.: Se no momento do upgrade aparecer janela de sugestao para reinicio dos servicos, desmaque as opçoes relacionadas a:
# - kubelet.service
# - containerd.service

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


# Mesmo após o Upgrade ainda mostra a versão antiga
kubectl get nodes
NAME       STATUS   ROLES           AGE   VERSION
master01   Ready    control-plane   89d   v1.34.4
worker01   Ready    worker          89d   v1.34.4

# Atualizando o Cluster
# Esse parametro é necessário porque está usando emptyDir (storage local efêmero).
kubectl drain master01 --ignore-daemonsets --delete-emptydir-data

Warning: ignoring DaemonSet-managed Pods: kube-flannel/kube-flannel-ds-qxqqp, kube-system/kube-proxy-qm6qq, metallb-system/metallb-speaker-lsp9j
evicting pod metallb-system/metallb-controller-765c495b75-c757j
evicting pod kube-system/metrics-server-755bdffd6c-trrcm
pod/metallb-controller-765c495b75-c757j evicted
pod/metrics-server-755bdffd6c-trrcm evicted
node/master01 drained

# Atualize os demias pacotes
apt-mark unhold kubectl kubelet
Canceled hold on kubectl.
Canceled hold on kubelet.

# OBS.: Se no momento do upgrade aparecer janela de sugestao para reinicio dos servicos, desmaque as opçoes relacionadas a:
# - kubelet.service
# - containerd.service
apt install kubectl kubelet
apt-mark hold kubectl kubelet kubeadm


kubectl version
Client Version: v1.35.5
Kustomize Version: v5.7.1
Server Version: v1.35.5

# Agora sim Reinici o Servico
systemctl restart kubelet

kubectl get nodes
NAME       STATUS                     ROLES           AGE   VERSION
master01   Ready,SchedulingDisabled   control-plane   89d   v1.35.5
worker01   Ready                      worker          89d   v1.34.4

# No processo de Upgrade o kubernets marca o node para não receber schedule.
kubectl uncordon master01
node/master01 uncordoned

# Check
kubectl get nodes
NAME       STATUS   ROLES           AGE   VERSION
master01   Ready    control-plane   89d   v1.35.5
worker01   Ready    worker          89d   v1.34.4

```

[Índice](#-menu)

# 🚀 Cluster Upgrade - Control Data / Workers

```bash

# De forma semelhante que foi feito o upgrade no Control Plane, será seguido aqui:
# - checar pacotes unhold
# - atualizar S.O
# - marcar inicialmente apenas kubeadm com unhold
# - atualizar images ( kubeadm upgrade )
# - drain
# - atualizar demais componentes ( kubect e kubelet )
# - uncordon
# - restart

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.35/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.35/deb/ /" | tee /etc/apt/sources.list.d/kubernetes.list
apt-get update -y


# Liste as versões disponíveis
apt list -a kubeadm
Listing... Done
kubeadm/unknown 1.35.5-1.1 amd64 [upgradable from: 1.34.4-1.1]
kubeadm/unknown 1.35.4-1.1 amd64
kubeadm/unknown 1.35.3-1.1 amd64
kubeadm/unknown 1.35.2-1.1 amd64
kubeadm/unknown 1.35.1-1.1 amd64
kubeadm/unknown 1.35.0-1.1 amd64
kubeadm/now 1.34.4-1.1 amd64 [installed,upgradable to: 1.35.5-1.1]

# Como checar os pacotes marcados como Hold
# Ao emitir o comando abaixo, os pacotes iniciados com ( hi ) estão marcados para não serem atualziados.
dpkg -l | grep kube
hi  kubeadm                          1.34.4-1.1                              amd64        Command-line utility for administering a Kubernetes cluster
hi  kubectl                          1.34.4-1.1                              amd64        Command-line utility for interacting with a Kubernetes cluster
hi  kubelet                          1.34.4-1.1                              amd64        Node agent for Kubernetes clusters
ii  kubernetes-cni                   1.7.1-1.1                               amd64        Binaries required to provision kubernetes container networking

# Atuallize o S.O
apt upgrade

# Listar os pacotes a serem atualzidos
# Aqui deve mostrar apenas os pacotes ( hold )
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

# OBS.: Se no momento do upgrade aparecer janela de sugestao para reinicio dos servicos, desmaque as opçoes relacionadas a:
# - kubelet.service
# - containerd.service

kubeadm version
kubeadm version: &version.Info{Major:"1", Minor:"35", EmulationMajor:"", EmulationMinor:"", MinCompatibilityMajor:"", MinCompatibilityMinor:"", GitVersion:"v1.35.5", GitCommit:"6636cbce3bbef91ff61d36658757179426f9e1b2", GitTreeState:"clean", BuildDate:"2026-05-12T09:53:04Z", GoVersion:"go1.25.9", Compiler:"gc", Platform:"linux/amd64"}

# Diferente do control plane que tem o plan , aqui deve-se emitir diretamente o upgrade node.
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

# Ataulize os demais componentes.
apt-mark unhold kubectl kubelet

# Obs.:
# Conectar no controlPlane e fazer o drain no worker01
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

# Tenho Pods com PDB habilitado.
kubectl get pdb -A
NAMESPACE   NAME        MIN AVAILABLE   MAX UNAVAILABLE   ALLOWED DISRUPTIONS   AGE
default     nginx-pdb   N/A             0                 0                     76d

# Deletar PDB
kubectl delete pdb nginx-pdb -n default

kubectl drain worker01 --ignore-daemonsets --delete-emptydir-data
node/worker01 already cordoned
Warning: ignoring DaemonSet-managed Pods: kube-flannel/kube-flannel-ds-zzgvm, kube-system/kube-proxy-gp4kn, metallb-system/metallb-speaker-rhs68
evicting pod default/nginx-1
evicting pod default/nginx-0
pod/nginx-0 evicted
pod/nginx-1 evicted
node/worker01 drained

# Atualize os pacotes do Worker01
apt install kubectl kubelet

# OBS.: Se no momento do upgrade aparecer janela de sugestao para reinicio dos servicos, desmaque as opçoes relacionadas a:
# - kubelet.service
# - containerd.service

dpkg -l | grep kube
ii  kubeadm                          1.35.5-1.1                                       amd64        Command-line utility for administering a Kubernetes cluster
ii  kubectl                          1.35.5-1.1                                       amd64        Command-line utility for interacting with a Kubernetes cluster
ii  kubelet                          1.35.5-1.1                                       amd64        Node agent for Kubernetes clusters
ii  kubernetes-cni                   1.8.0-1.1                                        amd64        Binaries required to provision kubernetes container networking

# Marque os pacotes novamente com hold
apt-mark hold kubectl kubelet kubeadm
kubectl set on hold.
kubelet set on hold.
kubeadm set on hold.

# Agora sim Reinici o Servico
systemctl restart kubelet

# Obs.:
# Os comandos abaixo deve ser executado no control plane
kubectl get nodes
NAME       STATUS                     ROLES           AGE   VERSION
master01   Ready,SchedulingDisabled   control-plane   89d   v1.35.5
worker01   Ready                      worker          89d   v1.34.4

# No processo de Upgrade o kubernets marca o node para não receber schedule.
kubectl uncordon worker01
node/worker01 uncordoned

# Check
kubectl get nodes
NAME       STATUS   ROLES           AGE   VERSION
master01   Ready    control-plane   89d   v1.35.5
worker01   Ready    worker          89d   v1.35.5
```

[Índice](#-menu)

# 🚀 Explorando Documentação - Kubectl

```bash
k explain deployment

k explain deployment.metadata

k explain deployment.spec

k explain deployment.spec.template

k explain deployment.spec.template.spec.containers
```
[Índice](#-menu)
