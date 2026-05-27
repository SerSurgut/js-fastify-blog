# Ansible-деплой Redmine на Timeweb Cloud

Автоматический деплой [Redmine](https://www.redmine.org/) (вместе с PostgreSQL) на удалённый сервер Ubuntu с помощью Ansible и Docker Compose.

## Что делает плейбук

1. Устанавливает зависимости системы (curl, ca-certificates, python3 и т.д.)
2. Добавляет официальный репозиторий Docker и ставит **Docker Engine + Compose plugin**
3. Создаёт директорию `/opt/redmine`
4. Рендерит `docker-compose.yml` из Jinja2-шаблона с подставленными переменными
5. Поднимает контейнеры **Redmine + PostgreSQL 16**
6. Дожидается, пока Redmine начнёт отвечать по HTTP

## Структура

```
ansible/
├── README.md
├── inventory.ini                    # один сервер группы redmine
├── group_vars/all.yml               # переменные (образ, БД, порты, секреты)
├── playbooks/deploy.yml             # основной плейбук
└── templates/docker-compose.yml.j2  # docker-compose шаблон
```

## Требования на локальной машине

* Ansible 2.14+
* SSH-доступ к серверу (пароль или ключ)
* Опционально: `community.docker` collection (плейбук имеет fallback на shell, если её нет)

```bash
sudo apt update
sudo apt install -y ansible openssh-client sshpass
# опционально:
ansible-galaxy collection install community.docker
```

## Использование

### 1. Положить IP сервера в inventory

В `inventory.ini` замени `ansible_host=...` на IP своего сервера.

### 2. Запустить плейбук

С паролем root:

```bash
cd ansible
ansible-playbook -i inventory.ini playbooks/deploy.yml --ask-pass --ask-become-pass
```

С SSH-ключом:

```bash
ansible-playbook -i inventory.ini playbooks/deploy.yml
```

### 3. Открыть Redmine

После завершения плейбука открыть в браузере:

```
http://<IP сервера>/
```

Дефолтные учётные данные администратора Redmine — `admin / admin` (нужно сменить при первом входе).

## Переменные

В `group_vars/all.yml`:

| Переменная           | Назначение                                          |
| -------------------- | --------------------------------------------------- |
| `redmine_dir`        | Куда положить compose-файл на сервере               |
| `redmine_image`      | Образ Redmine                                       |
| `redmine_port`       | Внешний HTTP-порт, маппится на 3000 внутри          |
| `postgres_image`     | Образ PostgreSQL                                    |
| `postgres_db`        | Имя БД                                              |
| `postgres_user`      | Пользователь БД                                     |
| `postgres_password`  | Пароль БД (рекомендуется поменять!)                 |
| `timezone`           | TZ контейнеров                                      |
| `redmine_secret_key` | SECRET_KEY_BASE приложения (`openssl rand -hex 32`) |

## Управление после деплоя

```bash
ssh root@<IP>
cd /opt/redmine
docker compose ps          # статус
docker compose logs -f     # логи
docker compose restart     # перезапуск
docker compose down -v     # остановить и удалить (с volume!)
```
