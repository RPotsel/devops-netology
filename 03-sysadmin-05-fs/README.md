# 3.5. Файловые системы - Роман Поцелуев

1. Узнайте о [sparse](https://ru.wikipedia.org/wiki/%D0%A0%D0%B0%D0%B7%D1%80%D0%B5%D0%B6%D1%91%D0%BD%D0%BD%D1%8B%D0%B9_%D1%84%D0%B0%D0%B9%D0%BB) (разряженных) файлах.

- **Ответ**

  - Статью прочитал, на моей практике чаще всего такие файлы используются в тонких дисках виртуальных машин.

2. Могут ли файлы, являющиеся жесткой ссылкой на один объект, иметь разные права доступа и владельца? Почему?

- **Ответ**

  - Нет, не могут, потому что ссылаются на одну запись в таблице inode, в которой и устанавливаются права на запись.
![Рисунок1](img/01.png)

3. Сделайте `vagrant destroy` на имеющийся инстанс Ubuntu. Замените содержимое Vagrantfile следующим:

    ```bash
    Vagrant.configure("2") do |config|
      config.vm.box = "bento/ubuntu-20.04"
      config.vm.provider :virtualbox do |vb|
        lvm_experiments_disk0_path = "/tmp/lvm_experiments_disk0.vmdk"
        lvm_experiments_disk1_path = "/tmp/lvm_experiments_disk1.vmdk"
        vb.customize ['createmedium', '--filename', lvm_experiments_disk0_path, '--size', 2560]
        vb.customize ['createmedium', '--filename', lvm_experiments_disk1_path, '--size', 2560]
        vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', lvm_experiments_disk0_path]
        vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 2, '--device', 0, '--type', 'hdd', '--medium', lvm_experiments_disk1_path]
      end
    end
    ```

- **Ответ**

    Данная конфигурация создаст новую виртуальную машину с двумя дополнительными неразмеченными дисками по 2.5 Гб.

![Рисунок2](img/02.png)

4. Используя `fdisk`, разбейте первый диск на 2 раздела: 2 Гб, оставшееся пространство.

- **Ответ**

![Рисунок3](img/03.png)

5. Используя `sfdisk`, перенесите данную таблицу разделов на второй диск.

- **Ответ**

![Рисунок4](img/04.png)

6. Соберите `mdadm` RAID1 на паре разделов 2 Гб.

- **Ответ**

![Рисунок5](img/05.png)

7. Соберите `mdadm` RAID0 на второй паре маленьких разделов.

- **Ответ**

![Рисунок6](img/06.png)

8. Создайте 2 независимых PV на получившихся md-устройствах.

- **Ответ**

![Рисунок7](img/07.png)

9. Создайте общую volume-group на этих двух PV.

- **Ответ**

![Рисунок8](img/08.png)

10. Создайте LV размером 100 Мб, указав его расположение на PV с RAID0.

- **Ответ**

![Рисунок9](img/09.png)

11. Создайте `mkfs.ext4` ФС на получившемся LV.

- **Ответ**

![Рисунок10](img/10.png)

12. Смонтируйте этот раздел в любую директорию, например, `/tmp/new`.

- **Ответ**

![Рисунок11](img/11.png)

13. Поместите туда тестовый файл, например `wget https://mirror.yandex.ru/ubuntu/ls-lR.gz -O /tmp/new/test.gz`.

- **Ответ**

![Рисунок12](img/12.png)

14. Прикрепите вывод `lsblk`.

- **Ответ**

![Рисунок13](img/13.png)

15. Протестируйте целостность файла:

    ```bash
    root@vagrant:~# gzip -t /tmp/new/test.gz
    root@vagrant:~# echo $?
    0
    ```

- **Ответ**

![Рисунок14](img/14.png)

16. Используя pvmove, переместите содержимое PV с RAID0 на RAID1.

- **Ответ**

![Рисунок15](img/15.png)

17. Сделайте `--fail` на устройство в вашем RAID1 md.

- **Ответ**

![Рисунок16](img/16.png)

18. Подтвердите выводом `dmesg`, что RAID1 работает в деградированном состоянии.

- **Ответ**

![Рисунок17](img/17.png)

19. Протестируйте целостность файла, несмотря на "сбойный" диск он должен продолжать быть доступен:

    ```bash
    root@vagrant:~# gzip -t /tmp/new/test.gz
    root@vagrant:~# echo $?
    0
    ```

- **Ответ**

![Рисунок18](img/18.png)

20. Погасите тестовый хост, `vagrant destroy`.

- **Ответ**

  - Выполнено.
