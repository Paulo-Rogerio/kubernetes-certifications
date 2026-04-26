- [Command Line - Contexts](#-command-line---contexts)
- [Command Line - Nodes](#-command-line---nodes)
- [Command Line - Pods](#-command-line---pods)
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

# 🚀 Command Line - Pods

```bash
# Nivel de verbosidade + alto
k get pods -A -v9

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

# 🚀 Create Object - Scale Deployment

```bash
k scale --help
k scale deployment nginx-paulo --replicas 10
```

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

# 🚀 Create Object - PDB -PodDisruptionBudget

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
```

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

# 🚀 Create Object - Storage PV / PVC / StorageClass

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


```

# 🚀 Create Object - Affinity

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

# 👉 O Pod:

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
```

# 🚀 Estratégias Deploy

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

# 🚀 Explorando Documentação - Kubectl

```bash
k explain deployment

k explain deployment.metadata

k explain deployment.spec

k explain deployment.spec.template

k explain deployment.spec.template.spec.containers
```
