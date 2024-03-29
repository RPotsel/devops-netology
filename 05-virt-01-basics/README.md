# 5.1. Введение в виртуализацию

## Задача 1

Опишите кратко, как вы поняли: в чем основное отличие полной (аппаратной) виртуализации, паравиртуализации и виртуализации на основе ОС.

__Ответ:__

При аппаратной виртуализации гостевая ОС полностью изолированна от ресурсов хоста и взаимодействует с ними через гипервизор, сругой стороны, при паравиртуализации гипервизор не изолирует ОС виртуальной машины полностью, а модифицирует ее, чтобы сделать ее совместимой с определенными API и заменить невиртуализируемые инструкции гипервызовами, т.е паравиртуализация требует, чтобы гостевая ОС была изменена для гипервизора. При виртуализации уровня операционной системы или контейнерной виртуализации не существует отдельного слоя гипервизора, вместо этого сама хостовая операционная система отвечает за разделение аппаратных ресурсов между несколькими гостевыми системами (контейнерами) и обеспечивает их независимость, что не позволяет запускать операционные системы с ядрами, отличными от типа ядра базовой операционной системы.

## Задача 2

Выберите один из вариантов использования организации физических серверов, в зависимости от условий использования.

Организация серверов:

- физические сервера,
- паравиртуализация,
- виртуализация уровня ОС.

Условия использования:

- Высоконагруженная база данных, чувствительная к отказу.
- Различные web-приложения.
- Windows системы для использования бухгалтерским отделом.
- Системы, выполняющие высокопроизводительные расчеты на GPU.

Опишите, почему вы выбрали к каждому целевому использованию такую организацию.

__Ответ:__

1. Высоконагруженная база данных, чувствительная к отказу - в данном сценарии, желательно использовать кластерную БД и отдельные физические сервера и для каждой ноды, т.к. это позволит убрать прослойку в виде гипервизора и сократить время отклика при обращении к аппаратныи ресурсам сервера.

2. Различные web-приложения - виртуализация уровня операционной системы или контейнерная виртуализация, т.к. позволяет уменьшить ресурсозатраты по сравнению с эмуляцией всей операционной системы и увеличить скорость развертывания приложений.

3. Windows системы для использования бухгалтерским отделом - в основном не требовательны к аппаратным ресурсами и технической поддержки, поэтому можно использовать бесплатные решения для паравиртуализации.

4. Системы, выполняющие высокопроизводительные расчеты на GPU - решения, поддерживающие виртуализацию GPU очень дорогие и если не требуется распределение ресурсов сложной графики, то лучше использовать отдельные физические сервера с выделенными графическими картами или виртуализацию средствами ОС.

## Задача 3

Выберите подходящую систему управления виртуализацией для предложенного сценария. Детально опишите ваш выбор.

Сценарии:

1. 100 виртуальных машин на базе Linux и Windows, общие задачи, нет особых требований. Преимущественно Windows based инфраструктура, требуется реализация программных балансировщиков нагрузки, репликации данных и автоматизированного механизма создания резервных копий.
2. Требуется наиболее производительное бесплатное open source решение для виртуализации небольшой (20-30 серверов) инфраструктуры на базе Linux и Windows виртуальных машин.
3. Необходимо бесплатное, максимально совместимое и производительное решение для виртуализации Windows инфраструктуры.
4. Необходимо рабочее окружение для тестирования программного продукта на нескольких дистрибутивах Linux.

__Ответ:__

1. Оптимальным видится использование решений для паравиртуализации, ко всем требованиям задания доходит Proxmox Virtual Environment.

2. Можно использовать XenServer, т.к. это более зрелый продукт по сравнению с KVM, c хорошей производительностью и исключительной стабильностью.

3. Microsoft Hyper-V Server является бесплатным продуктом и обеспечивает виртуализацию корпоративного класса для Windows инфраструктуры. Продукт имеет низкий порог вхождения для инженеров, упрощенное управление драйверами и широкий диапазон поддерживаемых устройств.

4. Можно использовать Oracle VM VirtualBox или VMware Workstation, т.к. позволяет оперативно выполнить развёртывание виртуальной инфраструктуры на любой рабочей ОС.

## Задача 4

Опишите возможные проблемы и недостатки гетерогенной среды виртуализации (использования нескольких систем управления виртуализацией одновременно) и что необходимо сделать для минимизации этих рисков и проблем. Если бы у вас был выбор, то создавали бы вы гетерогенную среду или нет? Мотивируйте ваш ответ примерами.

__Ответ:__

В отличии от гетерогенной среды виртуализации, использование единой среды проще с точки зрения инсталляции, настройки, мониторинга, сопровождения и управления, но привязывает вас к определенному вендору и техническому решению, что затрудняет отказ от него. Независимые виртуальные среды в компаниях внедряются с целью уменьшения расходов, реализации решения не поддерживаемого существующей средой, следования требованиям безопасности или процесса качественных преобразований. Например, использование open source продуктов может снизить расходы на расширение виртуальной среды, применение контейнерной виртуализации как современный стандарт при разработке web-приложений может внедряться на уже имеющихся виртуальных серверах, необходимость следования требованиям ФСТЭК или программам импортозамещения для организаций РФ вынуждают развертывания соответствующих средств виртуализации.
