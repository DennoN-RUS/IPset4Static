# IPset4Static
Здесь выложены файлы для работы ipset + iptables. Позволяет направлять в впн по доменному имени любой сайт

Есть возможность настройки с одним впн, так и с двумя (один основной, второй резервный + пользовательское перенаправление в определенный)

Совместим с Bird4Static (с версии Bird4Static 3.9 и выше) и является его аддоном, но IPset4Static может работать и отдельно.

Предназначено для роутеров Keenetic с установленным на них entware, а так же для любой системы с opkg пакетами, и у которых система расположена в каталоге */opt/

**Требует установленного и настроенного AdguardHome или dnsmasq, перед началом установки**

Так что перед установкой нужно один из них настроить, какой выбрать и как настроить описано [здесь](https://github.com/DennoN-RUS/IPset4Static/wiki/Перед-установкой)

## Установка сервиса IPset4Static
1) Зайти по ssh в среду entware: `ssh root@192.168.1.1`

2) Выполнить:
    ```bash
   opkg install git git-http
   git clone https://github.com/DennoN-RUS/IPset4Static.git
   chmod +x ./IPset4Static/*.sh
   ./IPset4Static/install.sh 
    ```
   Далее выбирать нужные параметры.

Более подробная инструкция установки и описание [тут](https://github.com/DennoN-RUS/IPset4Static/wiki/Установка)

---
Веб-интерфейс: [web4static](https://github.com/spatiumstas/web4static)

Канал в телеграме: [тут](https://t.me/bird4static)

Чат в телеграме: [тут](https://t.me/bird4static_chat)

Поддержать проект можно через [yoomoney](https://yoomoney.ru/to/41001872039390) и [cloudtips](https://pay.cloudtips.ru/p/76ea7dde)
