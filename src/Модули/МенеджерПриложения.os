///////////////////////////////////////////////////////////////////////////////
//
// Служебный модуль с набором методов работы с командами приложения
//
// В большинстве проектов изменять данный модуль не требуется
//
///////////////////////////////////////////////////////////////////////////////

#Использовать logos
#Использовать cmdline
#Использовать tempfiles

///////////////////////////////////////////////////////////////////

Перем Лог Экспорт;

Перем ПарсерКоманд;
Перем ИсполнителиКоманд;
Перем ОбъектНастроек;
Перем ДополнительныеПараметры;
	
///////////////////////////////////////////////////////////////////
	
//	Инициализирует и настраивает лог приложения
// 
// Параметры:
//	УровеньЛогаСтрока - Строка - уровень логов, выводимых в консоль при выполнении скрипта
//
// Возвращаемое значение:
//   Лог   - Инициализированный лог, готовый к использованию
//
Функция Инициализировать(Знач Настройки) Экспорт
	
	// Служебные переменные
	ПарсерКоманд = Новый ПарсерАргументовКоманднойСтроки();
	ИсполнителиКоманд = Новый Соответствие;	
	ОбъектНастроек = Настройки;
	ДополнительныеПараметры = Новый Структура;

	// Логирование
	Лог = Логирование.ПолучитьЛог(ОбъектНастроек.ИмяЛогаСистемы());
	Лог.УстановитьУровень(УровниЛога.Информация);
	Лог.УстановитьРаскладку(ОбъектНастроек);

	// Инициализация команд
	РегистраторКоманд(ОбъектНастроек);

	Возврат ЭтотОбъект;

КонецФункции

//	Возвращает лог приложения
// 
// Возвращаемое значение:
//   Лог   - Текущий лог приложения
//
Функция ПолучитьЛог() Экспорт

	Возврат Лог;

КонецФункции

Процедура ЗавершитьРаботуПриложенияСОшибкой(Знач Сообщение, Знач КодВозврата = Неопределено) Экспорт

	Если КодВозврата = Неопределено Тогда
		КодВозврата = РезультатыКоманд().ОшибкаВремениВыполнения;
	КонецЕсли;

	Лог.КритичнаяОшибка(Сообщение);
	
	ЗавершитьРаботу(КодВозврата);

КонецПроцедуры

Процедура ЗавершитьРаботуПриложения(Знач КодВозврата) Экспорт
	
	ЗавершитьРаботу(КодВозврата);

КонецПроцедуры
	
///////////////////////////////////////////////////////////////////////////////

Функция ЗапуститьВыполнение() Экспорт
	
	МенеджерПриложения.ЗарегистрироватьКоманды(ПарсерКоманд);
	ПараметрыЗапуска = ПарсерКоманд.Разобрать(АргументыКоманднойСтроки);

	Если ПараметрыЗапуска = Неопределено ИЛИ ПараметрыЗапуска.Количество() = 0 Тогда
		
		ВывестиВерсию();
		Лог.Ошибка("Некорректные аргументы командной строки");
		МенеджерПриложения.ПоказатьСправкуПоКомандам();
		Возврат МенеджерПриложения.РезультатыКоманд().НеверныеПараметры;
		
	КонецЕсли;
	
	Команда = "";
	ЗначенияПараметров = Неопределено;
	
	Если ТипЗнч(ПараметрыЗапуска) = Тип("Структура") Тогда
		
		// это команда
		Команда				= ПараметрыЗапуска.Команда;
		ЗначенияПараметров	= ПараметрыЗапуска.ЗначенияПараметров;
		Лог.Отладка("Выполняю команду продукта %1", Команда);
		
	ИначеЕсли ЗначениеЗаполнено(ПараметрыПриложения.ИмяКомандыПоУмолчанию()) Тогда
		
		// это команда по-умолчанию
		Команда				= ПараметрыПриложения.ИмяКомандыПоУмолчанию();
		ЗначенияПараметров	= ПараметрыЗапуска;
		Лог.Отладка("Выполняю команду продукта по умолчанию %1", Команда);
		
	Иначе
		
		ВызватьИсключение "Некорректно настроено имя команды по-умолчанию.";
		
	КонецЕсли;
	
	Если Команда <> ПараметрыПриложения.ИмяКомандыВерсия() Тогда

		ВывестиВерсию();

	КонецЕсли;
	
	Возврат МенеджерПриложения.ВыполнитьКоманду(Команда, ЗначенияПараметров);
	
КонецФункции // ВыполнениеКоманды()

///////////////////////////////////////////////////////////////////////////////

Процедура ВывестиВерсию()
	
	Сообщить(СтрШаблон("%1 v%2", ПараметрыПриложения.ИмяПродукта(), ПараметрыПриложения.ВерсияПродукта()));
	
КонецПроцедуры // ВывестиВерсию

///////////////////////////////////////////////////////////////////////////////

Процедура ЗарегистрироватьКоманды(Знач Парсер) Экспорт
	
	КомандыИРеализация = Новый Соответствие;
	ОбъектНастроек.ПриРегистрацииКомандПриложения(КомандыИРеализация);

	Для Каждого КлючИЗначение Из КомандыИРеализация Цикл

		ДобавитьКоманду(КлючИЗначение.Ключ, КлючИЗначение.Значение, Парсер);

	КонецЦикла;
	
КонецПроцедуры // ЗарегистрироватьКоманды

Процедура РегистраторКоманд(Знач ОбъектРегистратор) Экспорт

	ДополнительныеПараметры.Вставить("Лог", Логирование.ПолучитьЛог(ПараметрыПриложения.ИмяЛогаСистемы()));

КонецПроцедуры // РегистраторКоманд

Функция ПолучитьКоманду(Знач ИмяКоманды) Экспорт
	
	КлассРеализации = ИсполнителиКоманд[ИмяКоманды];
	Если КлассРеализации = Неопределено Тогда

		ВызватьИсключение СтрШаблон("Неверная операция. Команда '%1' не предусмотрена.", ИмяКоманды);

	КонецЕсли;
	
	Возврат КлассРеализации;
	
КонецФункции // ПолучитьКоманду

Функция ВыполнитьКоманду(Знач ИмяКоманды, Знач ПараметрыКоманды) Экспорт
	
	Команда = ПолучитьКоманду(ИмяКоманды);
	КодВозврата = Команда.ВыполнитьКоманду(ПараметрыКоманды, ДополнительныеПараметры);
	
	Возврат КодВозврата;

КонецФункции // ВыполнитьКоманду

Процедура ПоказатьСправкуПоКомандам(ИмяКоманды = Неопределено) Экспорт

	ПараметрыКоманды = Новый Соответствие;
	Если ИмяКоманды <> Неопределено Тогда

		ПараметрыКоманды.Вставить("Команда", ИмяКоманды);

	КонецЕсли;

	ВыполнитьКоманду("help", ПараметрыКоманды);

КонецПроцедуры // ПоказатьСправкуПоКомандам

Процедура ДобавитьКоманду(Знач ИмяКоманды, Знач КлассРеализации, Знач Парсер)
	
	Попытка
		
		РеализацияКоманды = Новый(КлассРеализации);
		РеализацияКоманды.ЗарегистрироватьКоманду(ИмяКоманды, Парсер);
		ИсполнителиКоманд.Вставить(ИмяКоманды, РеализацияКоманды);

	Исключение
		
		ДополнительныеПараметры.Лог.Ошибка("Не удалось выполнить команду '%1' для класса '%2'", ИмяКоманды, КлассРеализации);
		ВызватьИсключение;

	КонецПопытки;

КонецПроцедуры

///////////////////////////////////////////////////////////////////

Функция РезультатыКоманд() Экспорт

	РезультатыКоманд = Новый Структура;
	РезультатыКоманд.Вставить("Успех", 0);
	РезультатыКоманд.Вставить("НеверныеПараметры", 5);
	РезультатыКоманд.Вставить("ОшибкаВремениВыполнения", 1);
	
	Возврат РезультатыКоманд;

КонецФункции // РезультатыКоманд

Функция КодВозвратаКоманды(Знач Команда) Экспорт

	Возврат Число(Команда);

КонецФункции // КодВозвратаКоманды
