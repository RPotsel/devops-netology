# Задание: опишите своими словами какие файлы будут проигнорированы в будущем благодаря добавленному .gitignore

    # Игнорировать все объекты из всех каталогов .terraform, * в конце инструкции позволит добавлять исключения ! для объектов данного каталога
    **/.terraform/*

    # Игнорировать файлы с расширением начинающимися на .tfstate
    *.tfstate
    *.tfstate.*

    # Игнорировать файлы crash.log
    crash.log

    # Исключить все файлы с расширением *.tfvars
    *.tfvars

    # Игнорировать файлы override
    override.tf
    override.tf.json
    *_override.tf
    *_override.tf.json

    # Исключая следующий
    !example_override.tf

    # Игнорировать файлы
    .terraformrc
    terraform.rc
