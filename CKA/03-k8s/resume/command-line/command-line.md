
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
# Request é usado sempre quando um pod é colocado dentro de um node.
# Ele é levado em conta na escolha de onde será colocado o pod.
# Kube-schedules é quem decide em qual worker meu pod vai rodar, ele avalia os recursos.
# ==========================================================================
#
# Quando defino quantidade de Request, e esse numero que o scheduler levaria em conta para determinar em qual worker o pod
# vai trabalhar. Definido em 200M por ex, caso o worker tenha 500MB ele colocaria , pois ta dentro do valor que woker pode suportar.

# Manifest Request: 1 cpu / 4 GB Ram
k apply -f manifesto.yaml

# O scheduler só vai agendar esse Pod em um node que tenha pelo menos 0.1 CPU e 64 MB de Ram disponível

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
            cpu: 0.1
            memory: 64

# Como ler a capacidade do Node?
k get nodes
k describe node <node-name>
k top nodes
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

# 🚀 Explorando Documentação - Kubectl

```bash
k explain deployment

k explain deployment.metadata

k explain deployment.spec

k explain deployment.spec.template

k explain deployment.spec.template.spec.containers
```

# 🚀 Create Object - Liveness / Readness Probes

```bash
#=================================================
# Ready => Pronto para receber o trafego.
#=================================================
#
# O Ready garante que uma consulta get em alguma rota "/health" responda com status code 200 para comecar a receber trafego, então o Pod é transacionado para 1/1. Isso acontece no startup do pod.

#=================================================
# Live => Garante que a aplicação ainda está viva.
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
# Daemonset => 1 Pod em cada Node ( Geralmente coletores de logs )
# Daemonset não se define o numero de replicas.
# Daemonset será igual ao numero de nodes de um cluster.
# Daemonset não passa pelo kube-scheduler

# Caso de usos:
# Coletor de Logs => precisa rodar a nivel de host.
# CNI             => Roda a nivel do host
# Patch           => Aplicar um determinado patch

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


# Manteve os 2 Node Selector, isso acontece o K8s não substitui, ele faz merge ( apenda ). NodeSelector é um AND e não um OR.
k get daemonset
NAME          DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR                                                     AGE
nginx-paulo   1         1         1       1            1           kubernetes.io/hostname=worker01,node-role.kubernetes.io/worker=   2m22s


# Deixar apenas 1 Node Selector
k edit daemonsets nginx-paulo

# OBS.: Apesar de ser um daemonset o troubleshouting é igual ao um Pod
```


# 🚀 Create Object - Statefullset

```bash
Statefullset => Aplicação statefull ( A escalada tem que ser mais caltelosa ,
cada pod tem seu volume, escala na ordem certa Ex: Banco de Dados )

Daemonset    => 1 Pod em cada Node ( Geralmente coletrores de logs )
```

# 🚀 Create Object - Affinity

```bash

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
