# Learn Kubernetes

```bash
kubeadm version -o short
kubeadm config print init-defaults
```

```bash
echo "$(kubeadm token create --print-join-command)" > ${JOIN_FILE}/join.sh

kubeadm join 10.100.100.10:6443 \
  --token yw814a.mk47hgqt1yayq26k \
  --discovery-token-ca-cert-hash sha256:7613f7a62eb387ebc300bdd56bcf35782cbf0fea5bc7e622d58bb2b364b08730
```
