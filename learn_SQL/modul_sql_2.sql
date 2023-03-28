--=============== МОДУЛЬ 3. ОСНОВЫ SQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выведите для каждого покупателя его адрес проживания, 
--город и страну проживания.
--Ответ:
SELECT CONCAT(c.last_name,' ', c.first_name) AS "full_name", 
		a."address", 
		ci."city", 
		co."country"
FROM customer c
JOIN address a 
ON a.address_id = c.address_id
JOIN city ci 
ON ci.city_id = a.city_id
JOIN country co 
ON co.country_id =  ci.country_id ;




--ЗАДАНИЕ №2
--С помощью SQL-запроса посчитайте для каждого магазина количество его покупателей.
--Ответ:
SELECT s.store_id, 
       COUNT(c.customer_id) AS "count_custom"
FROM store s
JOIN costomer c
ON c.store_id = s.store_id
GROUP BY s.store_id;



--Доработайте запрос и выведите только те магазины, 
--у которых количество покупателей больше 300-от.
--Для решения используйте фильтрацию по сгруппированным строкам 
--с использованием функции агрегации.
--Ответ:
SELECT s.store_id, 
       COUNT(c.customer_id) AS "count_custom"
FROM store s
JOIN costomer c
ON c.store_id = s.store_id
GROUP BY s.store_id
HAVING COUNT(c.customer_id) > 300;



-- Доработайте запрос, добавив в него информацию о городе магазина, 
--а также фамилию и имя продавца, который работает в этом магазине.
--Ответ:
SELECT CONCAT(ms.first_name,' ',ms.last_name) AS "full_name",
		s.store_id,
		COUNT(c.customer_id) AS count_custom,
		ci.city
FROM store s
JOIN staff ms 
ON ms.staff_id = s.manager_staff_id
JOIN customer c
ON c.store_id = s.store_id 
ON address a
ON a.address_id = s.address_id 
JOIN city ci 
ON ci.city_id = a.city_id 
GROUP BY s.store_id , full_name,ci.city
HAVING COUNT(c.customer_id) > 300;





--ЗАДАНИЕ №3
--Выведите ТОП-5 покупателей, 
--которые взяли в аренду за всё время наибольшее количество фильмов
--Ответ:
SELECT CONCAT(c.last_name, ' ', c.first_name) AS "full_name",
	COUNT(r.rental_id) AS "count_films"
FROM customer c
JOIN rental r
ON r.customer_id = c.customer_id
GROUP BY c.customer_id
ORDER BY COUNT(r.rental_id) DESC
LIMIT 5;


--ЗАДАНИЕ №4
--Посчитайте для каждого покупателя 4 аналитических показателя:
--  1. количество фильмов, которые он взял в аренду
--  2. общую стоимость платежей за аренду всех фильмов (значение округлите до целого числа)
--  3. минимальное значение платежа за аренду фильма
--  4. максимальное значение платежа за аренду фильма
--Ответ:
SELECT CONCAT(c.last_name, ' ', c.first_name) AS "full_name",
	COUNT(r.rental_id) AS "count_films",
	ROUND(SUM(p.amount)) "sum_amount",
	MIN(p.amount),
	MAX(p.amount)
FROM customer c
JOIN rental r
ON r.customer_id = c.customer_id
JOIN payment p 
ON p.customer_id = c.customer_id 
GROUP BY c.customer_id
ORDER BY COUNT(r.rental_id) DESC
LIMIT 5;




--ЗАДАНИЕ №5
--Используя данные из таблицы городов составьте одним запросом всевозможные пары городов таким образом,
 --чтобы в результате не было пар с одинаковыми названиями городов. 
 --Для решения необходимо использовать декартово произведение.
 --Ответ:
 SELECT c.city,cl.city
 FROM city c
 CROSS JOIN city cl
 WHERE c.city != cl.city;




--ЗАДАНИЕ №6
--Используя данные из таблицы rental о дате выдачи фильма в аренду (поле rental_date)
--и дате возврата фильма (поле return_date), 
--вычислите для каждого покупателя среднее количество дней, за которые покупатель возвращает фильмы.
 --Ответ:
SELECT r.customer,
ROUND(AVG(DATE_PART('day'return_date - rental_date :: DATE)) :: NUMERIC) AS "avg_day_return"
FROM rental r
GROUP BY r.customer_id
ORDER BY r.customer_id;



--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Посчитайте для каждого фильма сколько раз его брали в аренду и значение общей стоимости аренды фильма за всё время.
--Ответ:
SELECT  f.title, 
	f.rating ,
	f.release_year,
	l."name",
	COUNT(p.amount) as "count_amount",
	SUM(p.amount) AS "sum_amount"
FROM payment p
JOIN rental r 
ON r.rental_id = p.rental_id
JOIN inventory i 
ON i.inventory_id = r.inventory_id
JOIN film f 
ON f.film_id = i.film_id
join "language" l 
on l.language_id = f.language_id  
group by f.title,
	 f.release_year ,
	 l."name" ,
	 f.rating 
order by f.title ;



--ЗАДАНИЕ №2
--Доработайте запрос из предыдущего задания и выведите с помощью запроса фильмы, которые ни разу не брали в аренду.
--Ответ:
SELECT  f.title, 
	f.release_year, 
	p.amount
FROM payment p
JOIN rental r 
ON r.rental_id = p.rental_id
JOIN inventory i 
ON i.inventory_id = r.inventory_id
JOIN film f 
ON f.film_id = i.film_id
WHERE p.amount = 0
ORDER BY f.title;




--ЗАДАНИЕ №3
--Посчитайте количество продаж, выполненных каждым продавцом. Добавьте вычисляемую колонку "Премия".
--Если количество продаж превышает 7300, то значение в колонке будет "Да", иначе должно быть значение "Нет".
--Ответ:
SELECT CONCAT(s.first_name, ' ', s.last_name) AS ""full_name,
       COUNT(p.amount) AS "count_amount",
CASE
	WHEN COUNT(p.amount) > 8000 THEN 'YES'
	WHEN COUNT(p.amount) < 8000 THEN 'NO'
END AS bonus,
SUM(p.amount) AS "sum_amount"
FROM payment p
JOIN staff s 
ON s.staff_id = p.staff_id
WHERE p.amount > 0
GROUP BY salesman
ORDER BY sales DESC;