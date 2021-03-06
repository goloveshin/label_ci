Пример сборки сторонних зависимостей (CMake, ExternalProject_Add).
Здесь приоритет скачиваемым исходникам, кроме тех, где по какой-то причине это невозможно.
iOS и Android не показаны, но там всё по той же схеме.

- Сторонние зависимости собираются из исходников и так делается на всех платформах.
- Если политика использования сторонних исходников позволяет хранить их под контролем версий, то хранить там и, желательно, в виде архива, в котором их предлагают скачивать с сайта, т.е. "как есть". Если хранить сторонние исходники нельзя, то они скачиваются в момент сборки по точному url. Например, как уже указали выше, в ExternalProject_Add можно указать и тот и другой способ.
- Собирать как можно больше сторонних зависимостей - это минимизирует зависимость пакета от системы.
- Можно _не_ собирать те зависимости, которые есть у всех и/или тот функционал/интерфейс, который вам оттуда нужен, не меняется долгое время - например, какой-нить libzip.
- Все - и программисты и тестировщики и клиенты должны использовать только один набор внешних зависимостей - тот, что мы собрали. Запретить напрочь использования зависимостей с системы, иначе тестировать будем одно, а на клиенте будет работать другое.

плюсы:
- Общий для всех рантайм - "всё своё ношу с собой".
- Устранение 'зоопарка' версий: например, вы собираете свою OpenSSL и далее все зависимости собираются только с этой OpenSSL, при использовании же пакетов каждый их них волен указать свою версию OpenSSL или вообще включить ее статически.
- Работа по сборке новой внешней зависимости делается один раз и в дальнейшем она собирается централизованно, позволяя не замусоривать машины разработчиков зависимостями, нужными исключительно для сборки наших зависимостей.
- Возможность собирать версии с нужными параметрами, а не теми, которые предлагают пакетные менеджеры.
- Возможность сборки нужными компиляторами.
- Возможность накатывать свои патчи.
- Возможность работать на системах, поддержка которых закончилась (пакета с нужной версией там может уже не быть).

минусы:
- Нужно всё это собирать.
- Геморрой.
- Местами очень сильный геморрой.
