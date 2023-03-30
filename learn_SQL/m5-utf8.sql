--=============== МОДУЛЬ 5. РАБОТА С POSTGRESQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Сделайте запрос к таблице payment и с помощью оконных функций добавьте вычисляемые колонки согласно условиям:
--Пронумеруйте все платежи от 1 до N по дате
--Пронумеруйте платежи для каждого покупателя, сортировка платежей должна быть по дате
--Посчитайте нарастающим итогом сумму всех платежей для каждого покупателя, сортировка должна 
--быть сперва по дате платежа, а затем по сумме платежа от наименьшей к большей
--Пронумеруйте платежи для каждого покупателя по стоимости платежа от наибольших к меньшим 
--так, чтобы платежи с одинаковым значением имели одинаковое значение номера.
--Можно составить на каждый пункт отдельный SQL-запрос, а можно объединить все колонки в одном запросе.
--ОТВЕТ:
SELECT *
FROM (
SELECT customer_id,payment_id,payment_date,
	ROW_NUMBER() OVER(ORDER BY payment_date) AS "num_pay_date",
	ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY payment_date) AS "num_paymen_date",
	SUM(p.amount) OVER(PARTITION BY p.customer_id ORDER BY p.payment_date),
	DENSE_RANK() OVER(PARTITION BY p.customer_id ORDER BY amount DESC)
FROM payment p) tz_1
ORDER BY customer_id, dense_rank;




--ЗАДАНИЕ №2
--С помощью оконной функции выведите для каждого покупателя стоимость платежа и стоимость 
--платежа из предыдущей строки со значением по умолчанию 0.0 с сортировкой по дате.
--ОТВЕТ:
SELECT *
FROM( 
SELECT customer_id,payment_id,amount,
	LAG(p.amount,1,0.) OVER(PARTITION BY customer_id ORDER BY p.payment_date)
FROM payment p) AS tz_2
ORDER BY customer_id;




--ЗАДАНИЕ №3
--С помощью оконной функции определите, на сколько каждый следующий платеж покупателя больше или меньше текущего.
--ОТВЕТ:
SELECT *
FROM(
SELECT customer_id,payment_id,payment_date,amount,
	amount - LEAD(p.amount,1,0.) OVER(PARTITION BY customer_id 
	ORDER BY p.payment_date,customer_id) AS "difference"
FROM payment p) AS tz_3;




--ЗАДАНИЕ №4
--С помощью оконной функции для каждого покупателя выведите данные о его последней оплате аренды.
--ОТВЕТ:
SELECT *
FROM(
SELECT customer_id,payment_id,payment_date,
	LAST_VALUE(amount) OVER(PARTITION BY customer_id ORDER BY payment_date DESC),
	ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY payment_date DESC)
FROM payment) tz_4
WHERE row_number = 1;



--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--С помощью оконной функции выведите для каждого сотрудника сумму продаж за август 2005 года 
--с нарастающим итогом по каждому сотруднику и по каждой дате продажи (без учёта времени) 
--с сортировкой по дате.
--ОТВЕТ:
SELECT staff_id,payment_date::DATE,SUM(amount),
	SUM(SUM(p.amount)) OVER(PARTITION BY p.staff_id ORDER BY p.payment_date) sum_amount
FROM payment p
WHERE payment_date:: DATE BETWEEN'2005-07-31' AND '2005-09-01'
GROUP BY staff_id,payment_date;



--ЗАДАНИЕ №2
--20 августа 2005 года в магазинах проходила акция: покупатель каждого сотого платежа получал
--дополнительную скидку на следующую аренду. С помощью оконной функции выведите всех покупателей,
--которые в день проведения акции получили скидку
--ОТВЕТ:
SELECT*
FROM (
SELECT customer_id,payment_date,
	ROW_NUMBER() OVER(ORDER BY payment_date) payment_num	
FROM payment 
WHERE payment_date :: DATE BETWEEN '2005-08-20' AND '2005-08-21') tz_6
WHERE payment_num % 100 = 0;


--ЗАДАНИЕ №3
--Для каждой страны определите и выведите одним SQL-запросом покупателей, которые попадают под условия:
-- 1. покупатель, арендовавший наибольшее количество фильмов
-- 2. покупатель, арендовавший фильмов на самую большую сумму
-- 3. покупатель, который последним арендовал фильм
--ОТВЕТ:
--NO




