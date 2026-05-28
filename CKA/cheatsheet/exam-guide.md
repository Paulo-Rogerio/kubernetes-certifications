# 🚀 Setup, Shortcuts & First 5 Minutes


- [Home Page](https://github.com/Paulo-Rogerio/kubernetes-certifications/blob/main)

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

No other websites, notes, or books are allowed.

## ⚡⚡⚡ First 5 Minutes of the Exam ⚡⚡⚡

## 🚀 1) Confirm alias and autocompletion work (pre-configured on exam nodes)

```bash
source <(kubectl completion bash)
complete -F __start_kubectl k
alias k=kubectl
k version --short
```

```bash
export do="--dry-run=client -o yaml"
# Uso: k run pod1 --image=nginx $do

export now="--force --grace-period 0"
# Uso: k delete pod x $now
```

## 🚀 2) Learn Vim

Define input in **.vimrc**

```bash
cat > ~/.vimrc <<EOF
set tabstop=2
set expandtab
set shiftwidth=2
EOF
```

## 🚀 3) Manager Context

```bash
k config current-contexts
k config get-contexts
k config use-context <cluster-name>
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

[Top](#-setup-shortcuts--first-5-minutes)
