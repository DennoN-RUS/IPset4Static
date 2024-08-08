# IPset4Static
Здесь выложены файлы для работы ipset + iptables. Позволяет направлять в впн по доменному имени любой сайт

Есть возможность настройки с одним впн, так и с двумя (один основной, второй резервный + пользовательское перенаправление в определенный)

Совместим с Bird4Static (с версии Bird4Static 3.9 и выше) и является его аддоном, но IPset4Static может работать и отдельно.

Предназначено для роутеров Keenetic с установленным на них entware, а так же для любой системы с opkg пакетами, и у которых система расположена в каталоге */opt/

## Требование
* AdguardHome или dnsmasq

## Установка AdguardHome
1. Подключиться к entware по ssh: `ssh root@192.168.1.1 -p 222`
2. `opkg update` - обновить пакеты opkg
3. `opkg adguardhome-go` - установить AdguardHome

## Настройка кастомного DNS-сервера
1. Отключить дефолтный DNS-сервер:
* Через telnet:
   1. telnet 192.168.1.1 (ip адрес вашего роутера)
   2. `opkg dns-override` - отключить дефолтный DNS-сервер
   3. `system configuration save` - сохранить конфиг
   4. `system reboot` - перезагрузить роутер
* Через Web CLI:
   1. Зайти на интерфейс роутера: http://192.168.1.1/a
   2. `opkg dns-override` - отключить дефолтный DNS-сервер
   3. `system configuration save` - сохранить конфиг
   4. `system reboot` - перезагрузить роутер

## Настройка AdguardHome
1. `/opt/etc/init.d/S99adguardhome start` - запустить сервис
2. Открыть в браузере мастер первоначальной настройки AdGuard Home по адресу http://192.168.1.1:3000.
3. Произвести первоначальную настройку.
   * Веб-интерфейс повесьте на Все интерфейсы, порт 1234
   * DNS-сервер повесьте на Все интерфейсы, порт 53.
   * Придумайте логин и пароль для доступа к AdguardHome
4. Зайдите на http://192.168.1.1:1234 и настройте остальное (подписки, фильтры, upstream DNS) по вкусу.
5. Настройка завершена. Проверить работу adguardhome можно командой:
   `/opt/etc/init.d/S99adguardhome status`. Перезапуск - `/opt/etc/init.d/S99adguardhome restart`.

[Источник](https://dartraiden.github.io/AdGuard-Home-Keenetic/)

## Установка сервиса IPset4Static
1) Зайти по ssh в среду entware: `ssh root@192.168.1.1`

2) Выполнить:
    ```
      opkg install git git-http
      git clone https://github.com/DennoN-RUS/IPset4Static.git
      chmod +x ./IPset4Static/*.sh
      ./IPset4Static/install.sh 
    ```
   Далее выбирать нужные параметры.

Более подробная инструкция установки и описание [тут](https://github.com/DennoN-RUS/IPset4Static/wiki/Установка)

## Описание работы

Пользовательские файлы для заполнения будут:
* `Bird4Static/IPset4Static/lists/user-ipset-*.list`
* `Bird4Static/lists/user-ipset-*.list`

Заполнять можно только доменами через пробел или построчно. В файлах не должно быть ничего лишнего! Поддерживаются коментарии если строка  начинается со знака #, то вся строка будет проигнорирована.

После изменения пользовательских файлов нужно запустить скрипт
* `./Bird4Static/IPset4Static/scripts/update-ipset.sh`
* или так `./Bird4Static/scripts/update-ipset.sh` (это ссылка на изначальный файл)
  по факту соберет все в 1 конфигурационный файл и перезапустит днс

## Починить youtube

Нужно в файл `Bird4Static/IPset4Static/lists/user-ipset-vpn.list` добавить домен `googlevideo.com`, потом запустить `./Bird4Static/IPset4Static/scripts/update-ipset.sh`

## Диагностика ipset

1) Проверяем что таблицы 1010/1011 (и 1012 в случае двух впн)  есть

`ip rule | grep "101[012]"`

2) Проверяем что маршрут по умолчанию в таблицу записался

`ip route list table 1011`

должно выдать что-то типа: default dev nwg2 scope link вместо 1011 можно еще и 1010 и 1012 указать, и проверить

3) проверяем, что правила фаерволла есть

`iptables-save | grep ipset`

должно выдать 4 (в случае с одним впн) и 6 (в случае с двумя впн) строк

4) проверяем, что таблицы ipset наполняются адресами

`ipset list ipset_vpn1`

вместо ipset_vpn1 можно указывать еще ipset_vpn2 и ipset_isp1

---
Канал в телеграме: [тут](https://t.me/bird4static)

Чат в телеграме: [тут](https://t.me/bird4static_chat)

Поддержать проект можно [тут](https://yoomoney.ru/to/41001872039390)
