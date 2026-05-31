# Lab 4 — IaC: Terraform + Ansible

## Архітектура

\`\`\`
client → VM1 (lab4-worker): nginx → app → VM2 (lab4-db): PostgreSQL
\`\`\`

## Вимоги

- Windows з VirtualBox 7.x
- Vagrant 2.4+
- Terraform 1.x
- Ansible 2.16+ (на окремій Linux VM або WSL)

## Швидкий старт

### 1. Створення VM (Terraform + Vagrant)

\`\`\`powershell
cd terraform
terraform init
terraform apply
\`\`\`

Це створить дві VM:
- \`lab4-worker\` — 192.168.56.10 (nginx + застосунок)
- \`lab4-db\` — 192.168.56.11 (PostgreSQL)

### 2. Налаштування (Ansible)

На Linux VM з доступом до host-only мережі:

\`\`\`bash
cd ansible
ansible-playbook -i inventory/hosts.yml playbook.yml
\`\`\`

### 3. Перевірка

\`\`\`bash
curl http://192.168.56.10/health/alive
curl http://192.168.56.10/tasks
\`\`\`

## Структура репозиторію

\`\`\`
terraform/
├── main.tf
├── variables.tf
├── vms.tf
├── outputs.tf
├── create-vm.ps1
├── destroy-vm.ps1
└── cloud-init/
    ├── worker.yml
    └── db.yml
ansible/
├── playbook.yml
├── inventory/
│   └── hosts.yml
└── roles/
    ├── common/
    ├── db/
    ├── app/
    └── nginx/
\`\`\`

## Користувачі

| Користувач | VM     | Права                          |
|------------|--------|--------------------------------|
| ansible    | всі    | sudo без пароля                |
| teacher    | всі    | sudo з паролем (12345678)      |
| app        | worker | системний, мінімальні права    |
| operator   | worker | sudo тільки для mywebapp/nginx |

## Мережеві обмеження

- nginx слухає 0.0.0.0:80
- app слухає 127.0.0.1:8080
- PostgreSQL доступний тільки з worker (192.168.56.10)
