set search_path to bookings;
--Задание1:
--Выведите название самолетов, которые имеют менее 50 посадочных мест?
--ОТВЕТ:
SELECT a.model,COUNT(s.seat_no)
FROM aircrafts a 
JOIN seats s
ON s.aircraft_code = a.aircraft_code
GROUP BY s.aircraft_code,a.model
HAVING COUNT(s.seat_no) < 50;

--Задание2:
--Выведите процентное изменение ежемесячной суммы бронирования билетов,
--округленной до сотых.
--ОТВЕТ:
WITH res AS(
SELECT  TO_CHAR(book_date  ,'YYYY-MM') AS actual_date, --оставляем только месяц и год
SUM(total_amount) AS amount_month --сумируем стоимость
FROM bookings b
GROUP BY actual_date --групируем по дате
)
SELECT actual_date,ROUND((amount_month/ prev_sale)::DEC *100,2)-100--считаем процентное изменение 
FROM(
SELECT actual_date,amount_month,
LAG(amount_month) OVER(ORDER BY actual_date) AS prev_sale --ориентируемся на предыдущий показатель
FROM res) b;	



--Задание3:
--Выведите названия самолетов не имеющих бизнес - класс.
--Решение должно быть через функцию array_agg.
--ОТВЕТ:
SELECT model,conditions
FROM(
SELECT a.model,ARRAY_AGG(DISTINCT ARRAY[fare_conditions]) AS conditions
FROM aircrafts a 
JOIN seats s
ON s.aircraft_code = a.aircraft_code
GROUP BY a.model
ORDER BY a.model) b
WHERE NOT conditions::TEXT[] && ARRAY['Business'];



--Задание4:
--Вывести накопительный итог количества мест в самолетах по каждому аэропорту
--на каждый день, учитывая только те самолеты, которые летали пустыми и только
--те дни, где из одного аэропорта таких самолетов вылетало более одного.
--В результате должны быть код аэропорта, дата, количество пустых мест
--и накопительный итог.
--ОТВЕТ:
WITH boarded AS ( 
	SELECT 
		f.flight_id,
		f.flight_no,
		f.aircraft_code,
		f.departure_airport,
		f.scheduled_departure,
		f.actual_departure,
		COUNT(bp.boarding_no) boarded_count --считаем количество зянятых мест
	FROM flights f 
	JOIN boarding_passes bp 
	ON bp.flight_id = f.flight_id 
	WHERE f.actual_departure IS NOT NULL
	GROUP BY f.flight_id 
),
max_seats AS (
	SELECT 	s.aircraft_code,
		count(s.seat_no) max_seat --максимальное количество мест
	FROM seats s 
	GROUP BY s.aircraft_code 
)
SELECT departure_airport ,sched_dep,--создаем накопительный эфект пустых мест
       actu_dep,free_seats,
       SUM(free_seats) OVER(PARTITION BY (departure_airport,actu_dep) 
       ORDER BY actu_dep) "accumulate_free_seats"
FROM (
SELECT 
	b.departure_airport,
	b.scheduled_departure::DATE AS sched_dep,
	b.actual_departure ::DATE AS actu_dep,
	COUNT(actual_departure) OVER(PARTITION BY actual_departure ORDER BY actual_departure) count_flight, --количество вылетов
	ROUND((m.max_seat- b.boarded_count) / m.max_seat :: dec, 2) * 100 free_seats_percent, --процент пустых мест
	(m.max_seat- b.boarded_count) free_seats --колличество пустых мест
FROM boarded b 
JOIN max_seats m ON m.aircraft_code = b.aircraft_code
) res
WHERE free_seats_percent > 70 AND count_flight > 1; --в таблице небыло абсолютно пустых "птичек", считаю больше 70% пустых мест - пустой самолет


--Задание5:
--Найдите процентное соотношение перелетов по маршрутам от общего
--количества перелетов. 
--Выведите в результат названия аэропортов и процентное отношение.
--Решение должно быть через оконную функцию.
--ОТВЕТ:
SELECT DISTINCT CONCAT( "departure_airport_name",'->> ',"arrival_airport_name") reiss, --именнуем рейсы 
		ROUND(COUNT(flight_id) over(PARTITION BY departure_airport_name,arrival_airport_name)/
		COUNT(*) over()::dec * 100,4)
FROM flights_v fv  



--Задание6:
--Выведите количество пассажиров по каждому коду сотового оператора,
--если учесть, что код оператора - это три символа после +7
--ОТВЕТ:
WITH numbers AS (
SELECT passenger_id ,passenger_name ,
       contact_data ->>'phone'::TEXT AS num --дастаем номера и переводим в удобный для "слаов" формат
FROM tickets t 
)
SELECT code,COUNT(code) --считаем количество схожих кодов групируя по коду
FROM(
	SELECT SUBSTRING(num,3,3) AS code -- оставляем только код
	FROM numbers) b
GROUP BY code 
ORDER BY code;


--Задание7:
--Классифицируйте финансовые обороты (сумма стоимости билетов) по маршрутам:
--До 50 млн - low
--От 50 млн включительно до 150 млн - middle
--От 150 млн включительно - high
--Выведите в результат количество маршрутов в каждом полученном классе.
--ОТВЕТ:
WITH res AS(  --заворачиваем в результирующий CTE
WITH "cost" AS (
SELECT flight_id,amount --оставляем нужные колонки
FROM ticket_flights tf 
),
reisses AS (
SELECT flight_id ,flight_no , 
CONCAT("departure_airport",'->>',"arrival_airport") reiss,status --конкатим маршруты
FROM flights
)
SELECT r.reiss,SUM(amount) AS sum_cost --выводим стоимость маршрутов
FROM "cost" c
JOIN reisses r
ON r.flight_id = c.flight_id
GROUP BY r.reiss
ORDER BY sum_cost DESC
)
SELECT COUNT(reiss),
CASE    --присваиваем класс маршруту в зависимости от его суммы полета
	WHEN sum_cost < 50000000 THEN 'low' 
	WHEN 50000000 <= sum_cost  AND sum_cost < 150000000 THEN 'middle'
	WHEN sum_cost >= 150000000 THEN 'high'
END AS profit_level
FROM res
GROUP BY profit_level

--Здание8*:
--Вычислите медиану стоимости билетов, медиану размера бронирования и отношение
-- медианы бронирования к медиане стоимости билетов, округленной до сотых.
--ОТВЕТ:

WITH "median_book" AS(
SELECT PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY total_amount) AS median_bookings
FROM bookings b 
),
"median_ticket" AS(
SELECT PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY amount) AS median_amount
FROM ticket_flights tf 
)
SELECT median_bookings,median_amount,ROUND(median_bookings/median_amount)
FROM median_book,median_ticket







