# 🚀 Dicas

#### O que tem no metadata?

Nome do objeto, label, namespace, anotation, geralmente o que é usado para identificar meu objeto.

Donwload do [Krew](https://krew.sigs.k8s.io/), um gerenciador que auxilia na instalação de plugins.

# Como usar os plugins do krew?

```bash
k krew search | grep neat
k krew install neat
k krew list
```

# Neat

Com esse plugin consigo extrair o manifesto yaml de um pod em execução, sendo que ele ja remove informações desnecessárias, metadados como timestamp entre outros.

```bash
k neat <<< $(k get pods -n kube-system metrics-server-755bdffd6c-trrcm -o yaml)
k neat <<< $(k get pods -n kube-system metrics-server-755bdffd6c-trrcm -o yaml) > /tmp/metric-server.yaml
```

# Sniff

sniff ( Sobe um sidecar e funciona como um tcpdump )
