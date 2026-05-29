# 🚀 Setup, Shortcuts & First 5 Minutes


- [Home Page](https://github.com/Paulo-Rogerio/kubernetes-certifications)

---

## ⏰ Quick Stats (CKA v1.35)

| Item | Detail |
|------|--------|
| **Duration** | 2 hours |
| **Tasks** | 15–20 performance based |
| **Passing Score** | 66% |
| **Kubernetes Version** | v1.35 |
| **Results** | Emailed within 24 hours |
| **Validity** | 2 years |
| **Retake** | 1 free retake included |

---

## ✅ Pre-Exam Environment Checklist

Run through this the day before your exam:

- [ ] Run [PSI system check](https://syscheck.bridge.psiexams.com/) on your exam machine
- [ ] Single monitor only  dual monitors are **NOT** supported
- [ ] Screen size ≥ 15", resolution 1080p recommended
- [ ] **Wired internet connection** preferred over Wi-Fi
- [ ] Close bandwidth-heavy apps (Dropbox, BitTorrent, video calls)
- [ ] Disable firewall or corporate proxy (can block PSI Secure Browser)
- [ ] Stop antivirus scanning during exam time
- [ ] Laptop **plugged into power** (battery must not die mid-exam)
- [ ] Do **NOT** use a corporate machine if possible (security policies can disrupt PSI)
- [ ] Do **NOT** use a virtual machine to take the exam
- [ ] Test microphone — must work before exam starts
- [ ] Webcam must be moveable (for room pan during check-in)
- [ ] Valid government-issued photo ID ready (unexpired, original, physical)
- [ ] Name on ID must **exactly** match your verified name on the LF portal

### Room Requirements
- [ ] Clutter-free desk 👉  no paper, electronics, or other objects
- [ ] Clear walls 👉  no paper/printouts (paintings are OK)
- [ ] Well-lit room 👉  proctor must see your face, hands, and workspace
- [ ] Private, quiet space (no coffee shops, open offices, etc.)
- [ ] You must stay within the camera frame throughout

---

## 🖥️ Exam Interface Quick Reference

### Keyboard Shortcuts (Remote Desktop)

| Action | Shortcut |
|--------|----------|
| **Close tab (Chrome)** | Use `Ctrl+Alt+W` (**NOT** `Ctrl+W`) |
| **Copy** (Terminal) | `Ctrl+Shift+C` |
| **Paste** (Terminal) | `Ctrl+Shift+V` |
| **Copy** (other apps on remote desktop) | `Ctrl+C` |
| **Paste** (other apps on remote desktop) | `Ctrl+V` |
| **Find in Firefox** | `Ctrl+F` |
| **Locate cursor** | `Ctrl+Alt+K` |
| **Vim INSERT mode** | `i` (INSERT key is disabled) |
| **Exit INSERT mode (Vim)** | `Esc` |


## 🚀 What browser shortcuts do I need to know for the CKA exam?

Use `Ctrl+Alt+W` to close tabs (NOT `Ctrl+W` — that kills your terminal).

Copy with `Ctrl+Shift+C`, paste with `Ctrl+Shift+V` in the terminal.

## 🚀 Linux elevated privileges

```bash
sudo -i
```

### 🚀 Pre-installed Tools (on all SSH hosts)

> [!IMPORTANT]
> Each exam task tells you which node to work on. Complete the task on that node, then `exit` back to base. **Nested SSH is not supported.**


| Tool | Description |
|------|-------------|
| `kubectl` | Kubernetes CLI |
| `k` | Alias for `kubectl` (with bash autocompletion) |
| `do` | Alias for `--dry-run=client -o yaml` usage `k run pod1 --image=nginx $do` |
| `now` | Alias for `--force --grace-period 0` usage `k delete pod x $now` |
| `yq` | YAML processor |
| `curl` | HTTP requests |
| `wget` | HTTP downloads |
| `man` | Manual pages |


### Allowed Resources During Exam

You may open **one additional browser tab** pointing to:
- `https://kubernetes.io/docs`
- `https://kubernetes.io/blog`
- `https://helm.sh/docs`

## 📚 Kubernetes Docs Bookmarks

One browser tab allowed. Know these paths:

| Topic | URL Path |
|-------|----------|
| kubectl cheatsheet | `/docs/reference/kubectl/quick-reference/` |
| RBAC | `/docs/reference/access-authn-authz/rbac/` |
| Network Policies | `/concepts/services-networking/network-policies/` |
| PersistentVolumes | `/concepts/storage/persistent-volumes/` |
| Scheduling | `/concepts/scheduling-eviction/` |
| kubeadm install | `/setup/production-environment/tools/kubeadm/install-kubeadm/` |
| Ingress | `/concepts/services-networking/ingress/` |

Use `Ctrl+F` in Firefox to search within any docs page.

No other websites, notes, or books are allowed.

## ⚡⚡⚡ First 5 Minutes of the Exam ⚡⚡⚡

## 🚀 1) Confirm alias and autocompletion work (pre-configured on exam nodes)

```bash
source <(kubectl completion bash)
complete -F __start_kubectl k
alias k=kubectl
k version
```

```bash
export do="--dry-run=client -o yaml"
# Uso: k run pod1 --image=nginx $do

export now="--force --grace-period 0"
# Uso: k delete pod x $now
```

## 🚀 2) Learning Vim

Define input in **.vimrc**

```bash
cat > ~/.vimrc <<EOF
set tabstop=2
set expandtab
set shiftwidth=2
syntax on
EOF
```

Exemples:

| Action | Comando |
| ------ | ------- |
| **Save + Exit** | `:wq` |
| **Exit without saving** | `:q!` |
| **Copy line** | `yy` |
| **Delete line** | `dd` |
| **Paste** | `p` |
| **Undo** | `u` |
| **Find** | `/` |
| **Replace** | `:%s/x/y/g` |
| **Identify** | `>` or `<`  |
| **Top Line** | `gg` |
| **Last line** | `G` |
| **Select** | `v` |
| **Select line** | `V` |
| **Select block** | `Ctrl+v` |
| **Comment** | `:s/^/# /` |
| **Describe** | `:s/# //` |


> 📖 [Learn Kubernetes](../learning/kubernetes.md)

## 🚀 3) Manager Context

```bash
k config current-context
k config get-contexts
k config use-context <cluster-name>
```

> 📖 [Learn Kubernetes](../learning/kubernetes.md)

## ⚙️ Imperative Commands Quick Reference

```bash
# Pods
k run nginx --image=nginx
k run busybox --image=busybox --restart=Never -- sleep 3600
k exec -it busybox -- sh

# Deployments
k create deploy app --image=nginx --replicas=3

# Services
# --targe-port => Porta que o container expoe, definido no Dockerfile da imagem.
# --port       => Porta que o service vai escutar
# --tcp        => <Porta que o service vai escutar>:<Porta que container expoe>
k expose deploy app --port=8080 --target-port=80
k create svc clusterip app --tcp=8080:80

# Debug
k port-forward svc/app 8181:8080

# ConfigMaps & Secrets
k create configmap cm --from-literal=key=value
k create secret generic sec --from-literal=key=value --from-file=./file

# RBAC
k create role r --verb=get,list --resource=pods
k create rolebinding rb --role=r --user=username
k create clusterrole cr --verb=get --resource=pods
k create clusterrolebinding crb --clusterrole=cr --user=username

# Scale / Image update
k scale deploy app --replicas=5
k set image deploy/app nginx=nginx:1.26

# Generate YAML without applying
k run nginx --image=nginx $do > pod.yaml
k create deploy app --image=nginx $do > deploy.yaml
```

> 📖 [Learn Kubernetes](../learning/kubernetes.md)

## 🔑 Essential kubectl One-Liners for Speed

```bash
# Delete fast (no grace period)
k delete pod my-pod $now

# Switch namespace quickly
k config set-context --current --namespace=my-namespace

# Switch cluster context (required per task!)
k config use-context <context-name>

# Get all resources in a namespace
k get all -n my-namespace

# Check events (great for debugging)
k get events --sort-by='.lastTimestamp' -n my-namespace

# Explain resource fields without docs
k explain pod.spec.containers.livenessProbe
k explain deployment.spec.strategy
k explain networkpolicy.spec

# Check RBAC
k auth can-i create pods --as=<user> -n <ns>

# Check available API versions for a resource
k api-resources | grep ingress
k api-versions | grep networking
```

## 🕐 Time Management Strategy

The exam is **2 hours** for 15–20 tasks.

| Strategy | Detail |
|----------|--------|
| **Budget per task** | ~6–8 minutes on average |
| **Skip and return** | Flag hard questions, return after easier ones |
| **Partial credit** | Exists — incomplete answers still score points |
| **High-weight tasks** | Do these first if confident |
| **Cluster upgrade** | Time-consuming — plan carefully |
| **Verify your work** | Always run `kubectl get`/`describe` to confirm |

### Time allocation by domain weight

| Domain | Weight | Suggested Time |
|--------|--------|---------------|
| Troubleshooting | 30% | ~36 min |
| Cluster Architecture | 25% | ~30 min |
| Services & Networking | 20% | ~24 min |
| Workloads & Scheduling | 15% | ~18 min |
| Storage | 10% | ~12 min |

**3-pass approach:**
1. **First pass (60 min):** Solve everything under 5 min — skip the rest
2. **Second pass (45 min):** Return to flagged questions, use docs
3. **Buffer (15 min):** Final verification pass

---

## 🧠 Common Exam Mistakes to Avoid

| Mistake | Prevention |
|---------|-----------|
| Wrong namespace | Always check task context; use `-n <namespace>` |
| Wrong cluster context | Run `k config use-context <ctx>` before each task |
| Forgetting `sudo -i` | Always escalate on worker nodes |
| Not verifying work | After every task, run `k get`/`describe` to confirm |
| Editing wrong file | Double-check paths: `/etc/kubernetes/manifests/` |
| Accidentally closing tab | Use `Ctrl+Alt+W` — see keyboard shortcuts table above |
| Running out of time | Skip, flag, come back — partial credit beats nothing |
| Tabs in YAML | Always use 2 spaces, never tabs |
| Forgetting `--restart=Never` | Required for one-off pods: `k run test --image=busybox --restart=Never` |

---

## 📞 Support

If you have issues during check-in or the exam:
- Login to [trainingsupport.linuxfoundation.org](https://trainingsupport.linuxfoundation.org) with your LF account
- The proctor can assist with technical issues during check-in

[Top](#-setup-shortcuts--first-5-minutes)
