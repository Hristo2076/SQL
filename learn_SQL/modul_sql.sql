
--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выведите уникальные названия городов из таблицы городов.
--##Answer
select distinct city, city_id 
from city c 
order by city_id;




--ЗАДАНИЕ №2
--Доработайте запрос из предыдущего задания, чтобы запрос выводил только те города,
--названия которых начинаются на “L” и заканчиваются на “a”, и названия не содержат пробелов.
--##Answer
select distinct city, city_id 
from city c 
WHERE city  LIKE 'L%a' and city not LIKE  '% %'
order by city_id;




--ЗАДАНИЕ №3
--Получите из таблицы платежей за прокат фильмов информацию по платежам, которые выполнялись 
--в промежуток с 17 июня 2005 года по 19 июня 2005 года включительно, 
--и стоимость которых превышает 1.00.
--Платежи нужно отсортировать по дате платежа.
--##Answer
SELECT *
FROM payment
WHERE payment_date BETWEEN  CAST('2005-06-17' AS DATE) 
                        AND  CAST('2005-06-19' AS DATE)
                        AND amount > 1
ORDER BY payment_date ;




--ЗАДАНИЕ №4
-- Выведите информацию о 10-ти последних платежах за прокат фильмов.
--##Answer
SELECT *
FROM payment
ORDER BY payment_date DESC
LIMIT 10;





--ЗАДАНИЕ №5
--Выведите следующую информацию по покупателям:
--  1. Фамилия и имя (в одной колонке через пробел)
--  2. Электронная почта
--  3. Длину значения поля email
--  4. Дату последнего обновления записи о покупателе (без времени)
--Каждой колонке задайте наименование на русском языке.
--##Answer
SELECT CONCAT(last_name, ' ', first_name) AS "Фамилия и имя", 
email AS "Электронная почта", 
LENGTH(email) AS "Длина Электронной почты", 
last_update::DATE AS "Дата"
FROM customer;






--ЗАДАНИЕ №6
--Выведите одним запросом только активных покупателей, имена которых KELLY или WILLIE.
--Все буквы в фамилии и имени из верхнего регистра должны быть переведены в нижний регистр.
--##Answer
SELECT LOWER(last_name) AS last_name,
       LOWER(first_name) AS first_name
FROM customer
WHERE first_name = 'KELLY' 
	OR first_name = 'WILLIE' 
	AND active = 1;





--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выведите одним запросом информацию о фильмах, у которых рейтинг "R" 
--и стоимость аренды указана от 0.00 до 3.00 включительно, 
--а также фильмы c рейтингом "PG-13" и стоимостью аренды больше или равной 4.00.
--##Answer
SELECT title, description, rating, rental_rate
FROM film
WHERE rating::TEXT LIKE 'R' AND rental_rate BETWEEN 0 AND 3.00
	OR rating::TEXT LIKE 'PG-13' AND rental_rate >= 4.00;




--ЗАДАНИЕ №2
--Получите информацию о трёх фильмах с самым длинным описанием фильма.
--##Answer
SELECT description , CHARACTER_LENGTH(description) 
FROM film
ORDER BY 2 desc
LIMIT 3;



--ЗАДАНИЕ №3
-- Выведите Email каждого покупателя, разделив значение Email на 2 отдельных колонки:
--в первой колонке должно быть значение, указанное до @, 
--во второй колонке должно быть значение, указанное после @.
select *,
	SUBSTRING_INDEX(email, '@', 1) email_1,
	SUBSTRING_INDEX(email, '@', -1) email_2
from customer;




--ЗАДАНИЕ №4
--Доработайте запрос из предыдущего задания, скорректируйте значения в новых колонках: 
--первая буква должна быть заглавной, остальные строчными.
--##Answer
SELECT email  ,
	   SUBSTRING_INDEX(email  , '@', 1), 
	   CONCAT ( LEFT(UPPER(SUBSTRING_INDEX(email  , '@', 1)), 1), 
	   LOWER(SUBSTR((SUBSTRING_INDEX(email , '@',1)),2))) email_1 ,  
	   SUBSTRING_INDEX(email  , '@', -1) ,
	   CONCAT(LEFT(UPPER(SUBSTRING_INDEX(email  , '@', -1)), 1), 
       LOWER(SUBSTR((SUBSTRING_INDEX(email , '@',-1)),2))) mail_2
FROM customer; 
