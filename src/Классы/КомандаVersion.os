///////////////////////////////////////////////////////////////////////////////
//
// Служебный модуль с реализацией работы команды version
//
///////////////////////////////////////////////////////////////////////////////

Процедура ЗарегистрироватьКоманду(Знач Команда, Знач Парсер) Экспорт
	
КонецПроцедуры // ЗарегистрироватьКоманду

// Выполняет логику команды
// 
// Параметры:
//   ПараметрыКоманды - Соответствие - Соответствие ключей командной строки и их значений
//   Приложение - Модуль - Модуль менеджера приложения
//
Функция ВыполнитьКоманду(Знач ПараметрыКоманды, Знач Приложение) Экспорт

	Лог = Приложение.ПолучитьЛог();
	
	Сообщить(Приложение.ВерсияПродукта());

	Лог.Отладка("Вывод версии приложения");
	
	Возврат Приложение.РезультатыКоманд().Успех;
	
КонецФункции // ВыполнитьКоманду
