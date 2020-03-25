-- 1. INSERT
--  1. Без указания списка полей
	INSERT INTO hairdresser VALUES ('Mary', 'Smith', 32, 25000 );
	INSERT INTO service VALUES ('haircut', 'long hair haircut', '00:50:00', 400, 2);
	INSERT INTO completed (date, time_spent, complexity, rating) VALUES ('12/04/2020 12:00:00', '00:40:00', 7, 9);
--  2. С указанием списка полей
	INSERT INTO salon (name, address, phone, email) VALUES ('MyHair', 'Lenin pr., 15', '+79654875961', 'myhair@gmail.com');
--  3. С чтением значения из другой таблицы
	INSERT INTO hairdresser (first_name, last_name, age) SELECT first_name, last_name, age FROM client;

-- 2. DELETE
--  1. Всех записей
	DELETE salon;
--  2. По условию
	DELETE FROM completed WHERE id_completed = 3;
--	3. Очистить таблицу
	TRUNCATE TABLE client;
        
-- 3. UPDATE
--	1. Всех записей
	UPDATE completed SET rating = 10;
--	2. По условию обновляя один атрибут
	UPDATE client SET phone = '+79854856175' WHERE first_name = 'Chris' AND last_name = 'Jones' ;
--	3. По условию обновляя несколько атрибутов
	UPDATE service SET cost = 500, description = 'long hair haircut with styling' WHERE name = 'haircut';
	
-- 4. SELECT
--	1. С определенным набором извлекаемых атрибутов (SELECT atr1, atr2 FROM...)
	 SELECT name, address, phone, email FROM salon;
--	2. Со всеми атрибутами (SELECT * FROM...)
	SELECT * FROM client;
--	3. С условием по атрибуту (SELECT * FROM ... WHERE atr1 = "")
	select * FROM service WHERE cost = 500;

-- 5. SELECT ORDER BY + TOP (LIMIT)
--  1. С сортировкой по возрастанию ASC + ограничение вывода количества записей
	SELECT TOP 5 * FROM hairdresser ORDER BY last_name ASC;
--  2. С сортировкой по убыванию DESC
	SELECT TOP 5 * FROM hairdresser ORDER BY last_name DESC;
--  3. С сортировкой по двум атрибутам + ограничение вывода количества записей
	SELECT TOP 5 * FROM hairdresser ORDER BY first_name, salary DESC;
--  4. С сортировкой по первому атрибуту, из списка извлекаемых
	SELECT TOP 5 * FROM hairdresser ORDER BY age;

-- 6. Работа с датами. Необходимо, чтобы одна из таблиц содержала атрибут с типом DATETIME.
--  1. WHERE по дате
	SELECT * FROM completed WHERE date = '12/04/2020 12:00:00';
--  2. Извлечь из таблицы не всю дату, а только год. Например, год рождения автора.
	SELECT id_completed, YEAR(date) AS date FROM completed;

-- 7. SELECT GROUP BY с функциями агрегации
--  1. MIN
	SELECT name, MIN(cost) AS min_cost FROM service GROUP BY name;
--  2. MAX
	SELECT name, MAX(cost) AS max_cost FROM service GROUP BY name;
--  3. AVG
	SELECT name, AVG(cost) AS avg_cost FROM service GROUP BY name;
--  4. SUM
	SELECT name, SUM(cost) AS sum_cost FROM service GROUP BY name;
--  5. COUNT
	SELECT name, COUNT(cost) AS count FROM service GROUP BY name;

-- 8. SELECT GROUP BY + HAVING
--  1. Написать 3 разных запроса с использованием GROUP BY + HAVING
	SELECT name FROM service GROUP BY name HAVING MAX(cost) >= 300;
	SELECT name, AVG(cost) AS avg_cost FROM service GROUP BY name HAVING AVG(cost) <= 300;
	SELECT MIN(age) AS min_age, MAX(age) AS max_age, AVG(age) AS avg_age FROM client  HAVING AVG(age) >= 20;

-- 9. SELECT JOIN
--  1. LEFT JOIN двух таблиц и WHERE по одному из атрибутов
	SELECT * FROM service LEFT JOIN hairdresser ON service.id_hairdresser = hairdresser.id_hairdresser WHERE first_name = 'Mary';
--  2. RIGHT JOIN. Получить такую же выборку, как и в 5.1
	SELECT TOP 5 * FROM hairdresser RIGHT JOIN service ON service.id_service = hairdresser.id_hairdresser ORDER BY last_name ASC;
--  3. LEFT JOIN трех таблиц + WHERE по атрибуту из каждой таблицы
	SELECT 
		hairdresser.id_hairdresser, hairdresser.last_name, 
		completed.id_completed, completed.rating, 
		client.id_client, client.last_name
	FROM
		hairdresser LEFT JOIN completed ON hairdresser.id_hairdresser = completed.id_hairdresser
        LEFT JOIN client ON client.id_client = completed.id_client
        WHERE salary = 22000 AND rating > 7 AND client.id_client > 10;
--  4. FULL OUTER JOIN двух таблиц
	SELECT * FROM completed FULL OUTER JOIN hairdresser ON completed.id_completed = hairdresser.id_hairdresser;

-- 10. Подзапросы
--  1. Написать запрос с WHERE IN (подзапрос)
	SELECT * FROM service WHERE time IN ('00:40:00', '00:30:00');
--  2. Написать запрос SELECT atr1, atr2, (подзапрос) FROM ...    
	SELECT  
		id_service, 
		name, 
		(SELECT id_hairdresser FROM hairdresser 
		WHERE hairdresser.id_hairdresser = service.id_hairdresser) AS id_hairdresser
	FROM service;