#Использовать v8runner
#Использовать cmdline

Перем СЕРВЕР;
Перем СЕРВЕР_СУБД;
Перем БАЗА;
Перем SQL_ПОЛЬЗОВАТЕЛЬ;
Перем SQL_ПАРОЛЬ;
Перем ПЛАТФОРМА_ВЕРСИЯ;
Перем ПУТЬ_К_ФАЙЛУ_БАЗЫ;
Перем ЭТО_СЕРВЕРНАЯ_БАЗА;
Перем ЭТО_RAS;

Перем Лог;
Перем Конфигуратор;

Функция Инициализация()

    Лог = Логирование.ПолучитьЛог("createTemplateBase");
    Лог.УстановитьУровень(УровниЛога.Информация);

    Парсер = Новый ПарсерАргументовКоманднойСтроки();
    Парсер.ДобавитьИменованныйПараметр("-platform");
    Парсер.ДобавитьИменованныйПараметр("-server1c");
    Парсер.ДобавитьИменованныйПараметр("-serversql");
    Парсер.ДобавитьИменованныйПараметр("-base");
    Парсер.ДобавитьИменованныйПараметр("-sqlpassw");
    Парсер.ДобавитьИменованныйПараметр("-sqluser");
    Парсер.ДобавитьИменованныйПараметр("-cfdt");

    Параметры = Парсер.Разобрать(АргументыКоманднойСтроки);

    ПЛАТФОРМА_ВЕРСИЯ = Параметры["-platform"];
    СЕРВЕР           = Параметры["-server1c"];
    СЕРВЕР_СУБД      = Параметры["-serversql"];
    БАЗА             = НРег(Параметры["-base"]);
    SQL_ПОЛЬЗОВАТЕЛЬ = Параметры["-sqluser"];
    Если Не ЗначениеЗаполнено(SQL_ПОЛЬЗОВАТЕЛЬ) Тогда
        SQL_ПОЛЬЗОВАТЕЛЬ = ""
    КонецЕсли;
    Если Не ЗначениеЗаполнено(SQL_ПАРОЛЬ) Тогда
        SQL_ПАРОЛЬ = "";
    КонецЕсли;

    ПУТЬ_К_ФАЙЛУ_БАЗЫ = Параметры["-cfdt"];

    Если Не ЗначениеЗаполнено(ПУТЬ_К_ФАЙЛУ_БАЗЫ) Тогда
        ПУТЬ_К_ФАЙЛУ_БАЗЫ = "";
    КонецЕсли;

    ЭТО_СЕРВЕРНАЯ_БАЗА = ЗначениеЗаполнено(СЕРВЕР);

    Конфигуратор = Новый УправлениеКонфигуратором();
    Если ЗначениеЗаполнено(ПЛАТФОРМА_ВЕРСИЯ) Тогда
       Конфигуратор.ИспользоватьВерсиюПлатформы(ПЛАТФОРМА_ВЕРСИЯ);
    КонецЕсли;

КонецФункции

Функция СоздатьСервернуюБазу1С()

    ПараметрыБазы1С = Новый Структура;
    ПараметрыБазы1С.Вставить("Сервер1С", СЕРВЕР);
    ПараметрыБазы1С.Вставить("ИмяИБ", БАЗА);

    ПараметрыСУБД = Новый Структура();
    ПараметрыСУБД.Вставить("ТипСУБД", "MSSQLServer");
    ПараметрыСУБД.Вставить("СерверСУБД", СЕРВЕР_СУБД);
    ПараметрыСУБД.Вставить("ПользовательСУБД", SQL_ПОЛЬЗОВАТЕЛЬ);
    ПараметрыСУБД.Вставить("ПарольСУБД", SQL_ПАРОЛЬ);
    ПараметрыСУБД.Вставить("ИмяБД", БАЗА);
    ПараметрыСУБД.Вставить("СоздаватьБД", Истина);

    АвторизацияВКластере = Новый Структура;
    АвторизацияВКластере.Вставить("Имя", "");
    АвторизацияВКластере.Вставить("Пароль", "");
    
    Конфигуратор.СоздатьСервернуюБазу(ПараметрыБазы1С, ПараметрыСУБД, АвторизацияВКластере, Ложь, ПУТЬ_К_ФАЙЛУ_БАЗЫ);

КонецФункции

Процедура СоздатьСервернуюБазуRAS()
    
    Кластеры = Конфигуратор.Кластеры();
    // Обходим список кластеров
    Для Каждого Кластер Из Кластеры.Список() Цикл
        ЛОГ.Информация("Cluster name = " + Кластер.Получить("Имя"));
        ИБКластера = Кластер.ИнформационныеБазы();

        ПараметрыИБ = Новый Структура;
        ПараметрыИБ.Вставить("ТипСУБД", "MSSQLServer");
        ПараметрыИБ.Вставить("АдресСервераСУБД", СЕРВЕР);
        ПараметрыИБ.Вставить("ИмяБазыСУБД", БАЗА);
        ПараметрыИБ.Вставить("ИмяПользователяБазыСУБД", SQL_ПОЛЬЗОВАТЕЛЬ);
        ПараметрыИБ.Вставить("ПарольПользователяБазыСУБД", SQL_ПАРОЛЬ);
        ПараметрыИБ.Вставить("БлокировкаРегламентныхЗаданийВключена", "on");
        ПараметрыИБ.Вставить("ВыдачаЛицензийСервером", "allow");

        ИБКластера.Добавить(БАЗА, , , ПараметрыИБ)
    КонецЦикла;

КонецПроцедуры

Процедура СоздатьФайловуюБазу1С()
    Конфигуратор.СоздатьФайловуюБазу(БАЗА, ПУТЬ_К_ФАЙЛУ_БАЗЫ);
КонецПроцедуры

Процедура СоздатьФайловуюБазуRAS()
    ВызватьИсключение "Not implemented"
КонецПроцедуры

Сообщить("1");
Инициализация();
Если ЭТО_СЕРВЕРНАЯ_БАЗА Тогда
        Лог.Информация("Creating server base with 1C...");
        СоздатьСервернуюБазу1С();
Иначе
        Лог.Информация("Creating file base with 1C...");
        СоздатьФайловуюБазу1С();
КонецЕсли;
Лог.Информация("script completed");