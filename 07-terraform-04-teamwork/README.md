# 7.4. Средства командной работы над инфраструктурой - Роман Поцелуев

## Задача 1. Настроить terraform cloud (необязательно, но крайне желательно).

В это задании предлагается познакомиться со средством командой работы над инфраструктурой предоставляемым разработчиками терраформа.

1. Зарегистрируйтесь на [https://app.terraform.io/](https://app.terraform.io/).
(регистрация бесплатная и не требует использования платежных инструментов).
1. Создайте в своем github аккаунте (или другом хранилище репозиториев) отдельный репозиторий с конфигурационными файлами прошлых занятий (или воспользуйтесь любым простым конфигом).
1. Зарегистрируйте этот репозиторий в [https://app.terraform.io/](https://app.terraform.io/).
1. Выполните plan и apply. 

В качестве результата задания приложите снимок экрана с успешным применением конфигурации.

__Ответ:__

Посмотрел, интересно, но к сожалению поэкспериментировать не получилось в силу блокировки сервисов.

## Задача 2. Написать серверный конфиг для атлантиса.

Смысл задания – познакомиться с документацией 
о [серверной](https://www.runatlantis.io/docs/server-side-repo-config.html) конфигурации и конфигурации уровня 
 [репозитория](https://www.runatlantis.io/docs/repo-level-atlantis-yaml.html).

Создай `server.yaml` который скажет атлантису:
1. Укажите, что атлантис должен работать только для репозиториев в вашем github (или любом другом) аккаунте.
1. На стороне клиентского конфига разрешите изменять `workflow`, то есть для каждого репозитория можно будет указать свои дополнительные команды. 
1. В `workflow` используемом по-умолчанию сделайте так, что бы во время планирования не происходил `lock` состояния.

Создай `atlantis.yaml` который, если поместить в корень terraform проекта, скажет атлантису:
1. Надо запускать планирование и аплай для двух воркспейсов `stage` и `prod`.
1. Необходимо включить автопланирование при изменении любых файлов `*.tf`.

В качестве результата приложите ссылку на файлы `server.yaml` и `atlantis.yaml`.

__Ответ:__

Пример файла конфигурации для контейнеров Atlantis и Ngrok

```YAML
version: '3.9'

services:
  ngrok:
    image: wernight/ngrok:latest
    ports:
    - 4040:4040
    environment:
      NGROK_PROTOCOL: http
      NGROK_PORT: atlantis:4141
    depends_on:
    - atlantis

  atlantis:
    container_name: atlantis
    image: runatlantis/atlantis:latest
    ports:
      - 4141:4141
    volumes:
      - ~/.ssh:/.ssh:ro
      - ./:/atlantis:ro
    command: 
      - server
      # Список параметров можно вынести в отдельный файл 
      # - --config=./config.yaml
      # Файл конфигурации сервера https://www.runatlantis.io/docs/configuring-atlantis.html#flags 
      - --repo-config=./server.yaml
      # УЗ для подключения к GitHub, можно использовать сервисную УЗ https://docs.github.com/en/developers/apps/building-github-apps/creating-a-github-app
      - --gh-user=""
      # https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token#creating-a-token 
      - --gh-token=""
      # Корень репозитория
      - --repo-allowlist="github.com/RPotsel/devops-netology"
      # Строка случайных символов https://www.runatlantis.io/docs/webhook-secrets.html#generating-a-webhook-secret 
      - --gh-webhook-secret="ssfjkczzhsmkrojrwhwvmokplcqlnzai"
      # Публичный адрес сервера atlantis, который будет доступен с GitHub
      # Для локального сервера можно установить Ngrok https://www.runatlantis.io/guide/testing-locally.htm
      - --atlantis-url=""
      # Отключение блокировки workspaces согласно условия
      - --disable-repo-locking
```

Файл серверной конфигурации

```YAML
repos:
  # Укажите, что атлантис должен работать только для репозиториев в вашем 
  # github (или любом другом) аккаунте.
- id: github.com/RPotsel/devops-netology

  # Workflow по-умолчанию
  workflow: devops-netology
  # Merge только после approve
  apply_requirements: [approved, mergeable]

  # На стороне клиентского конфига разрешите изменять workflow, то есть для 
  # каждого репозитория можно будет указать свои дополнительные команды.
  allowed_overrides: [workflow]
  allow_custom_workflows: true

workflows:
  devops-netology:
    plan: 
      steps:
        - init:
            extra_args: ["-lock=false"]
        - plan:
            # В workflow используемом по-умолчанию сделайте так, что бы во 
            # время планирования не происходил lock состояния.
            # Влияет только на блокировку средствами терраформа
            extra_args: ["-lock=false"]
    apply:
      steps: [apply]
```

Файл конфигурации уровня репозитория

```YAML
version: 3
projects:
# https://www.runatlantis.io/docs/repo-level-atlantis-yaml.html#use-cases
- dir: terraform
  # Надо запускать планирование и аплай для двух воркспейсов stage и prod.
  workspace: stage
  autoplan:
    # Необходимо включить автопланирование при изменении любых файлов *.tf.
    when_modified: ["../modules/**/*.tf", "*.tf*"]
- dir: terraform
  # Надо запускать планирование и аплай для двух воркспейсов stage и prod.
  workspace: prod
  autoplan:
    # Необходимо включить автопланирование при изменении любых файлов *.tf.
    when_modified: ["../modules/**/*.tf", "*.tf*"]
```

## Задача 3. Знакомство с каталогом модулей.

1. В [каталоге модулей](https://registry.terraform.io/browse/modules) найдите официальный модуль от aws для создания `ec2` инстансов.
2. Изучите как устроен модуль. Задумайтесь, будете ли в своем проекте использовать этот модуль или непосредственно ресурс `aws_instance` без помощи модуля?
3. В рамках предпоследнего задания был создан ec2 при помощи ресурса `aws_instance`. Создайте аналогичный инстанс при помощи найденного модуля.

В качестве результата задания приложите ссылку на созданный блок конфигураций.

__Ответ:__

Модуль нашел https://registry.terraform.io/modules/terraform-aws-modules/ec2-instance/aws/latest. Посмотрел, интересно, но к сожалению поэкспериментировать не получилось в силу блокировки сервисов.
