# Lab 4 — IaC: Terraform + Ansible

## Архітектура

\`\`\`
client → VM1 (lab4-worker): nginx → app → VM2 (lab4-db): PostgreSQL
\`\`\`

Система розгортається на двох віртуальних машинах в межах host-only мережі `192.168.56.0/24`:

- **lab4-worker** (`192.168.56.10`) — nginx reverse proxy + Java веб-застосунок
- **lab4-db** (`192.168.56.11`) — PostgreSQL база даних

## Вимоги

| Інструмент | Версія | Де |
|---|---|---|
| VirtualBox | 7.x | Windows (host) |
| Vagrant | 2.4+ | Windows (host) |
| Terraform | 1.x | Windows (host) |
| Ansible | 2.16+ | Linux VM або WSL |
| community.postgresql | 3.x | на Ansible машині |

Встановити Ansible колекцію:

\`\`\`bash
ansible-galaxy collection install community.postgresql
\`\`\`

## Швидкий старт

### 1. Клонування репозиторію

\`\`\`powershell
git clone https://github.com/mykhailosoloma/mywebapp-lab4.git
cd mywebapp-lab4
\`\`\`

### 2. Створення VM (Terraform)

\`\`\`powershell
cd terraform
terraform init
terraform apply
\`\`\`

Terraform використовує провайдер VirtualBox + Vagrant і створює дві VM з cloud-init налаштуванням (SSH ключ, користувач ansible).

Альтернативно через скрипт:

\`\`\`powershell
.\create-vm.ps1
\`\`\`

### 3. Встановлення залежності на db VM

Перед запуском Ansible необхідно встановити `acl` на VM з базою даних:

\`\`\`bash
ssh ansible@192.168.56.11 "sudo apt install -y acl"
\`\`\`

### 4. Налаштування (Ansible)

З Linux VM або WSL з доступом до host-only мережі:

\`\`\`bash
cd ansible
ansible-playbook -i inventory/hosts.yml playbook.yml
\`\`\`

Playbook виконує:
- Створення користувачів (`teacher`, `operator`, `app`)
- Встановлення та налаштування PostgreSQL
- Розгортання Java застосунку як systemd сервіс
- Налаштування nginx як reverse proxy
- Налаштування UFW firewall на db VM

### 5. Перевірка

\`\`\`bash
curl http://192.168.56.10/health/alive
curl http://192.168.56.10/health/ready
curl http://192.168.56.10/tasks
\`\`\`

### 6. Знищення VM

\`\`\`powershell
cd terraform
terraform destroy
\`\`\`

Або:

\`\`\`powershell
.\destroy-vm.ps1
\`\`\`

## Структура репозиторію

\`\`\`
.
├── Vagrantfile
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── vms.tf
│   ├── outputs.tf
│   ├── create-vm.ps1
│   ├── destroy-vm.ps1
│   └── cloud-init/
│       ├── worker.yml
│       └── db.yml
└── ansible/
    ├── ansible.cfg
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

| Користувач | VM | Призначення | Права |
|---|---|---|---|
| ansible | всі | автоматизація | sudo без пароля |
| teacher | всі | перевірка роботи | sudo з паролем `12345678` |
| app | worker | запуск застосунку | системний, мінімальні |
| operator | worker | керування сервісами | sudo тільки для mywebapp та nginx |

SSH доступ:

\`\`\`bash
ssh teacher@192.168.56.10   # пароль: 12345678
ssh teacher@192.168.56.11   # пароль: 12345678
ssh operator@192.168.56.10  # пароль: 12345678
\`\`\`

Operator може виконувати:

\`\`\`bash
sudo systemctl start mywebapp
sudo systemctl stop mywebapp
sudo systemctl restart mywebapp
sudo systemctl status mywebapp
sudo systemctl reload nginx
\`\`\`

## Мережева архітектура

| Компонент | Адреса | Порт | Доступ |
|---|---|---|---|
| nginx | 0.0.0.0 | 80 | публічний |
| застосунок | 127.0.0.1 | 8080 | тільки localhost |
| PostgreSQL | 192.168.56.11 | 5432 | тільки з worker |

Доступ до PostgreSQL обмежено через:
- `pg_hba.conf` — дозволено підключення тільки з `192.168.56.10`
- UFW firewall — порт 5432 відкритий тільки для `192.168.56.10`

## API ендпоінти

| Метод | Шлях | Опис |
|---|---|---|
| GET | `/health/alive` | перевірка що застосунок живий |
| GET | `/health/ready` | перевірка зв'язку з БД |
| GET | `/tasks` | список задач |
| POST | `/tasks` | створення задачі |

## Ідемпотентність

Повторний запуск `ansible-playbook` не призводить до змін якщо конфігурація вже відповідає опису:

\`\`\`
PLAY RECAP
lab4-db     : ok=22  changed=0  failed=0
lab4-worker : ok=22  changed=0  failed=0
\`\`\`
