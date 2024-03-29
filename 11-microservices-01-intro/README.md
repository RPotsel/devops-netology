# 11.01 Введение в микросервисы

## Задача 1: Интернет Магазин

Руководство крупного интернет магазина у которого постоянно растёт пользовательская база и количество заказов рассматривает возможность переделки своей внутренней ИТ системы на основе микросервисов.

Вас пригласили в качестве консультанта для оценки целесообразности перехода на микросервисную архитектуру.

Опишите какие выгоды может получить компания от перехода на микросервисную архитектуру и какие проблемы необходимо будет решить в первую очередь.

---

__Ответ:__

Дробление монолита может быть долгим и в его процессе могут меняться подходы к решению задач и инструменты разработки. На первоначальном этапе важно определиться с технологией контейнеризации приложений и инструментами взаимодействия между сервисами, которые будут использоваться в проекте, менять на ходу которые будет затратно. Переход от монолитной к микросервисной архитектуре в основном производится поэтапно, после повышения квалификации специалистов, привлечения новых и организации структуры команд, строится архитектура системы и выделяется вычислительная инфраструктура, на которой создаются новые сервисы и отделяются существующие.

Обозначим основные выгоды от перехода на микросервисную архитектуру для нашего проекта:

- Повышение показателей доступности и отказоустойчивости, к примеру у интернет магазина может отказать платежный сервис, но покупатели смогут пользоваться витриной и добавлять товары в корзину;
- Легкость масштабирования, в случае изменения нагрузки на один из сервисов можно выполнить горизонтальное масштабирование ресурсов для этого сервиса или вертикальное масштабирование изменив технологию только для этого сервиса;
- Возможность внедрения новых технологий в процессе жизненного цикла, к примеру для построения модели поведения покупателя на основе имеющихся данных с помощью машинного обучения можно создать новый сервис, используя свой стек технологий и существующую архитектуру;
- Простота внесения изменений в существующие сервисы, т.к. при правильном проектировании системы сервисы между собой мало связаны, можно вносить изменения гранулярно и часто;
- Отражение структуры команд в архитектуре сервисов, поможет менеджерам при распределении нагрузки среди исполнителей и повысит качество контроля за выполняемыми задачами.

Обозначим какие проблемы необходимо будет решить в первую очередь:

- Повысить уровень компетенций команды и оценить уровень нагрузки при переходе на микросервисную архитектуру, привлечь новых специалистов и обучить имеющихся;
- Определить бизнес-функции, которые могут вычленены из монолита в микросервис с минимальными затратами;
- Определить стек технологий, оптимального для перехода к будущей архитектуре;
- Выполнить расчет нагрузки на вычислительную инфраструктуру требуемую для перехода;
- Реструктуризировать команды в соответствии с архитектурой сервисов.
