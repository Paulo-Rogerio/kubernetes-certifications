# 🚀 Dicas

#### O que tem no metadata?

Nome do objeto, label, namespace, anotation, geralmente o que é usado para identificar meu objeto.

# 🚀 Plugin - Krew

Donwload do [Krew](https://krew.sigs.k8s.io/), um gerenciador que auxilia na instalação de plugins.

```bash
k krew search | grep neat
k krew install neat
k krew list
```

# 🚀 Plugin - Neat

Com esse plugin consigo extrair o manifesto yaml de um pod em execução, sendo que ele ja remove informações desnecessárias, metadados como timestamp entre outros.

```bash
k neat <<< $(k get pods -n kube-system metrics-server-755bdffd6c-trrcm -o yaml)
k neat <<< $(k get pods -n kube-system metrics-server-755bdffd6c-trrcm -o yaml) > /tmp/metric-server.yaml
```

# 🚀 Plugin - Sniff

Sobe um sidecar e funciona como um **tcpdump**

# 🚀 Dicas Prova - Alias

```bash
alias k=kubectl
export do="--dry-run=client -o yaml"
# Uso: k run pod1 --image=nginx $do

export now="--force --grace-period 0"
# Uso: k delete pod x $now
```


# 🚀 Dicas Prova - Vim

```bash

# Evite erros de indentação no YAML.

cat > ~/.vimrc <<EOF
set tabstop=2
set expandtab
set shiftwidth=2
EOF
```
