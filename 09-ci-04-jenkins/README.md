# 09.04 Jenkins

Отправить две ссылки на репозитории в ответе: с ролью и Declarative Pipeline и c плейбукой и Scripted Pipeline

__Ответ:__

- [Jenkinsfile](https://github.com/RPotsel/vector-role/blob/main/Jenkinsfile)
- [ScriptedJenkinsfile](./pipeline/ScriptedJenkinsfile)

## Подготовка к выполнению

1. Создать 2 VM: для jenkins-master и jenkins-agent.
2. Установить jenkins при помощи playbook'a.
3. Запустить и проверить работоспособность.
4. Сделать первоначальную настройку.

## Основная часть

1. Сделать Freestyle Job, который будет запускать `molecule test` из любого вашего репозитория с ролью.

__Ответ:__

![Freestyle_Pipeline_Config](./img/Freestyle_Pipeline_Config.png)
![Freestyle_Pipeline_Status](./img/Declarative_Pipeline_Status.png)

2. Сделать Declarative Pipeline Job, который будет запускать `molecule test` из любого вашего репозитория с ролью.

__Ответ:__

![Declarative_Pipeline_Config](./img/Declarative_Pipeline_Config.png)
![Declarative_Pipeline_Status](./img/Declarative_Pipeline_Status.png)

3. Перенести Declarative Pipeline в репозиторий в файл `Jenkinsfile`.

__Ответ:__

[Jenkinsfile](https://github.com/RPotsel/vector-role/blob/main/Jenkinsfile)

4. Создать Multibranch Pipeline на запуск `Jenkinsfile` из репозитория.

__Ответ:__

![Multibranch_Pipeline_Config](./img/Multibranch_Pipeline_Config.png)
![Declarative_Pipeline_Status](./img/Declarative_Pipeline_Status.png)

5. Создать Scripted Pipeline, наполнить его скриптом из [pipeline](./pipeline).
6. Внести необходимые изменения, чтобы Pipeline запускал `ansible-playbook` без флагов `--check --diff`, если не установлен параметр при запуске джобы (prod_run = True), по умолчанию параметр имеет значение False и запускает прогон с флагами `--check --diff`.

__Ответ:__

Для выполнения playbook java пользователь `jenkins` был добавлен в `sudoers`

![Scripted_Pipeline_Config](./img/Scripted_Pipeline_Config.png)
![Scripted_Pipeline_Status](./img/Scripted_Pipeline_Status.png)

7. Проверить работоспособность, исправить ошибки, исправленный Pipeline вложить в репозиторий в файл `ScriptedJenkinsfile`.

8. Отправить две ссылки на репозитории в ответе: с ролью и Declarative Pipeline и c плейбукой и Scripted Pipeline.

__Ответ:__

- [Jenkinsfile](https://github.com/RPotsel/vector-role/blob/main/Jenkinsfile)
- [ScriptedJenkinsfile](./pipeline/ScriptedJenkinsfile)

## Необязательная часть

1. Создать скрипт на groovy, который будет собирать все Job, которые завершились хотя бы раз неуспешно. Добавить скрипт в репозиторий с решением с названием `AllJobFailure.groovy`.
2. Дополнить Scripted Pipeline таким образом, чтобы он мог сначала запустить через Ya.Cloud CLI необходимое количество инстансов, прописать их в инвентори плейбука и после этого запускать плейбук. Тем самым, мы должны по нажатию кнопки получить готовую к использованию систему.
