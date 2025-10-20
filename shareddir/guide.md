# Как поставить общую папку

1. Скачайте набор дополнений для гостевой ОС: на странице [https://www.virtualbox.org/wiki/Downloads](https://www.virtualbox.org/wiki/Downloads) выберите справа "VirtualBox Extensions Pack", "Accept and download"

2. Запустите скачанный файл `Oracle_VirtualBox_Extension_Pack-[версия].vbox-extpack`, VirtualBox добавит расширения

3. Запустите виртуальную машину, войдите от имени `root`, в окне с виртуальной машиной во вкладке "Устройства" -> "Оптические диски" отметьте галочкой `VBoxGuestAdditions.iso`

4. В виртуальной машине установите нужные пакеты:

    * Для Debian:

        ```sh
        apt update
        apt upgrade -y
        # опционально:
        apt install -y sudo build-essential dkms linux-headers-$(dpkg --print-architecture)
        ```

    * Для CentOS

        ```sh
        sudo yum update -y
        sudo yum groupinstall -y 'Development Tools'
        ```

5. Сделайте привязку к приводу диска:

    ```sh
    mount /dev/cdrom /media
    ```

6. Установите расширения:

    ```sh
    cd /media
    # для x86-систем
    sudo ./VBoxLinuxAdditions.run --nox11
    # для arm-систем
    sudo ./VBoxLinuxAdditions-arm64.run --nox11
    ```

7. Теперь перейдите в раздел "Общие папки" в настройках, иконка справа "Добавляет новую общую папку"

    Укажите путь к желаемой папке в ОС хоста (лучше создать пустую папку), имя папки и точку подключения, например, `/shared/`

    Отметьте галочки "Авто-подключение", "Создать постоянную папку", создаем папку нажатием "Ок", сохраняем настройки машины нажатием "Ок"

    Перезапустите виртуальную машину, если папка не появилась


