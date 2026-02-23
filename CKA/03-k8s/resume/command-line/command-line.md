
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

#Um Pod recebe um prazo para terminar graciosamente, que é de 30 segundos por padrão. Ou seja a aplicação deve subir nesse intervalo de tempo e sair com status code 0 .

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
k create deployment --image=nginx nginx-paulo

k neat <<< $(k get deployment nginx-paulo -o yaml)

# O deployment garante que o pod seja recriado, mesmo que Pod seja deletado.
k delete pod nginx-paulo-5b98995fcc-25zj6

k delete deployment nginx-paulo

# Isso aqui é mais limpo
k neat <<< $(k create deployment --image=nginx nginx-paulo --replicas=2 --dry-run=client -o yaml)
k neat <<< $(k create deployment --image=nginx nginx-paulo --dry-run=client -o yaml) | k apply -f
```

# 🚀 Create Object - Statefullset

```bash
Statefullset => Aplicação statefull ( A escalada tem que ser mais caltelosa ,
cada pod tem seu volume, escala na ordem certa Ex: Banco de Dados )

Daemonset    => 1 Pod em cada Node ( Geralmente coletrores de logs )
```

# 🚀 Estratégias Deployment

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
