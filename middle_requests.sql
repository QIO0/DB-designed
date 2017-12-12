--Запроос 1
--Выбрать название судна, дату отправления и прибытия
--с условием, что это судно в заданную дату (_DATE_)
--находится в круизе в порядке ввозрастания 
--дат отправления и прибытия.
SELECT
  boat_name     AS boat_name,
  date_depature AS date_depature,
  date_arrive   AS date_arrive
FROM
  boats B
  INNER JOIN
  jorneys J
    ON
      B.id = J.boat_id
WHERE
  J.date_depature <= _DATE_
  AND
  J.date_arrive >= _DATE_
ORDER BY
  date_depature, date_arrive ASC;

--допустимые значения [_DATE_]:

	now()::DATE
	'2018-07-05'
	'2017-12-31'

--Необходимость:
--Предпологается, что необходимо знать,
--какие суда в данный момент в море,
--их дату отправления и прибытия,
--что бы планировать следующие поездки
--на данных короблях. А также вести
--учет использующихся кораблей.
--И передовать спасательным службам
--профилактическую информацию о 
--кораблях которые в море.

--оптимизация:
--Добавлены следующие индексы:
CREATE INDEX index_boats_id ON boats(id);
CREATE INDEX index_jorneys_id ON jorneys(id);
CREATE INDEX index_jorneys_dates ON jorneys(date_depature,date_arrive ASC);


--До оптимизации:
-- Sort  (cost=9.34..9.35 rows=1 width=40)
--   Sort Key: j.date_depature, j.date_arrive
--   ->  Nested Loop  (cost=0.15..9.33 rows=1 width=40)
--         ->  Seq Scan on jorneys j  (cost=0.00..1.15 rows=1 width=12)
--               Filter: ((date_depature <= '2017-12-31'::date) AND (date_arrive >= '2017-12-31'::date))
--         ->  Index Scan using boats_pkey on boats b  (cost=0.15..8.17 rows=1 width=36)
--               Index Cond: (id = j.boat_id)

--После оптимизации:
-- Sort  (cost=2.31..2.31 rows=1 width=40)
--   Sort Key: j.date_depature, j.date_arrive
--   ->  Hash Join  (cost=1.16..2.30 rows=1 width=40)
--         Hash Cond: (b.id = j.boat_id)
--         ->  Seq Scan on boats b  (cost=0.00..1.09 rows=9 width=36)
--         ->  Hash  (cost=1.15..1.15 rows=1 width=12)
--               ->  Seq Scan on jorneys j  (cost=0.00..1.15 rows=1 width=12)
--                     Filter: ((date_depature <= '2017-12-31'::date) AND (date_arrive >= '2017-12-31'::date))

--Отсюда видно, что индекс полей по которым шел JOIN и устанавливался порядок вывода был необходим
--по скольку позволял достаточно сильно снизить условную "цену" запроса.



--Запрос 2
--Выбрать полное имя, дату отправления и прибытия
--члена команды, по которому выполняется поиск.
SELECT
  full_name     AS full_name,
  date_depature AS date_depature,
  date_arrive   AS date_arrive
FROM
  staff S
  INNER JOIN
  staff_boats SB
    ON
      S.id = SB.worker_id
  INNER JOIN
  boats B
    ON
      SB.boat_id = B.id
  INNER JOIN
  jorneys J
    ON
      B.id = J.boat_id
WHERE
  full_name LIKE (_NAME_)
ORDER BY full_name, date_depature, date_arrive ASC;
--допустимые значения [_NAME_]:
	'%Lo%'
	'Ludvig Bethoven Drousil'
	'%Ivanov%'

--Необходимость:
--Сотруднику необходимо знать даты своих поездок, 
--что бы спланировать времяпрепровождение между ними,
--а также вовремя явится к отправке судна.

--оптимизация:
--Добавлены следующие индексы:
CREATE INDEX index_staff_full_name ON staff(full_name ASC);
CREATE INDEX index_staff_id ON staff(id);
CREATE INDEX index_sb_worker_id ON staff_boats(worker_id);
CREATE INDEX index_sb_boat_id ON staff_boats(boat_id);
--Использованы индексы:
index_boats_id 
index_jorneys_id
index_jorneys_dates

--До оптимизации:
-- Sort  (cost=34.23..34.24 rows=1 width=40)
--   Sort Key: s.full_name, j.date_depature, j.date_arrive
--   ->  Nested Loop  (cost=1.38..34.23 rows=1 width=40)
--         Join Filter: (sb.worker_id = s.id)
--         ->  Seq Scan on staff s  (cost=0.00..1.19 rows=1 width=36)
--               Filter: (full_name ~~ 'Ludvig Bethoven Drousil'::text)
--         ->  Nested Loop  (cost=1.38..32.80 rows=19 width=12)
--               ->  Hash Join  (cost=1.23..27.83 rows=10 width=16)
--                     Hash Cond: (b.id = j.boat_id)
-- +                    ->  Seq Scan on boats b  (cost=0.00..22.00 rows=1200 width=4)
--                     ->  Hash  (cost=1.10..1.10 rows=10 width=12)
--                           ->  Seq Scan on jorneys j  (cost=0.00..1.10 rows=10 width=12)
--               ->  Index Only Scan using staff_boats_pkey on staff_boats sb  (cost=0.15..0.39 rows=11 width=8)
--                     Index Cond: (boat_id = b.id)

--После оптимизации:
--Sort  (cost=4.44..4.44 rows=1 width=40)
--  Sort Key: s.full_name, j.date_depature, j.date_arrive
--   ->  Nested Loop  (cost=2.62..4.43 rows=1 width=40)
--         ->  Hash Join  (cost=2.48..3.63 rows=1 width=48)
--               Hash Cond: (j.boat_id = sb.boat_id)
--               ->  Seq Scan on jorneys j  (cost=0.00..1.10 rows=10 width=12)
--               ->  Hash  (cost=2.47..2.47 rows=1 width=36)
--                     ->  Hash Join  (cost=1.20..2.47 rows=1 width=36)
--                           Hash Cond: (sb.worker_id = s.id)
--                           ->  Seq Scan on staff_boats sb  (cost=0.00..1.19 rows=19 width=8)
--                           ->  Hash  (cost=1.10..1.10 rows=1 width=36)
--                                 ->  Seq Scan on staff s  (cost=0.00..1.10 rows=1 width=36)
--                                       Filter: (full_name ~~ 'Ludvig Bethoven Drousil'::text)
--         ->  Index Only Scan using index_boats_id on boats b  (cost=0.14..0.78 rows=1 width=4)
--               Index Cond: (id = sb.boat_id)


--Заметно, что индексация помогла уменьшить стоимость JOIN в запросе,
--а также сортировки по выбранным параметрам и фильтрации.


--Запрос 3
--Выдать полное имя, возраст(если указан) пассажиров
--отправляющихся в одну поездку в порядке возрастания их возраста.

SELECT
  full_name  AS full_name,
  client_age AS client_age
FROM
  clients C
  INNER JOIN
  clients_tickets CT
    ON
      C.id = CT.client_id
  INNER JOIN
  tickets T
    ON
      CT.ticket_id = T.id
WHERE
  T.jorney_id = _NUMBER_
ORDER BY
  client_age ASC NULLS LAST, full_name ASC;

--допустимые значения [_NUMBER_]:
	1
	2
	8

--Необходимость:
--Подготовка программы развлечений интересной
--и релевантной для возрастной аудитории судна
--в конкретную поездку.

--оптимизация:
--Добавлены следующие индексы:
CREATE INDEX index_clients_id ON clients(id);
CREATE INDEX index_ct_client_id ON clients_tickets(client_id);
CREATE INDEX index_ct_ticket_id ON clients_tickets(ticket_id);
CREATE INDEX index_tickets_id ON tickets(id);
CREATE INDEX index_tickets_jorney_id ON tickets(jorney_id);

--Использованы индексы:
clients_age_index
clients_full_name_hash_index

-- До оптимизации:
-- Sort  (cost=74.91..74.94 rows=11 width=36)
--   Sort Key: c.client_age, c.full_name
--   ->  Nested Loop  (cost=31.50..74.72 rows=11 width=36)
--         ->  Hash Join  (cost=31.35..72.53 rows=11 width=4)
--               Hash Cond: (ct.ticket_id = t.id)
--               ->  Seq Scan on clients_tickets ct  (cost=0.00..32.60 rows=2260 width=8)
--               ->  Hash  (cost=31.25..31.25 rows=8 width=4)
--                     ->  Seq Scan on tickets t  (cost=0.00..31.25 rows=8 width=4)
--                           Filter: (jorney_id = 1)
--         ->  Index Scan using clients_pkey on clients c  (cost=0.15..0.19 rows=1 width=40)
--               Index Cond: (id = ct.client_id)

--После оптимизации:
-- Sort  (cost=3.33..3.33 rows=1 width=36)
--   Sort Key: c.client_age, c.full_name
--   ->  Nested Loop  (cost=1.46..3.32 rows=1 width=36)
--         ->  Hash Join  (cost=1.32..2.71 rows=1 width=4)
--               Hash Cond: (ct.ticket_id = t.id)
--               ->  Seq Scan on clients_tickets ct  (cost=0.00..1.27 rows=27 width=8)
--               ->  Hash  (cost=1.31..1.31 rows=1 width=4)
--                     ->  Seq Scan on tickets t  (cost=0.00..1.31 rows=1 width=4)
--                           Filter: (jorney_id = 1)
--         ->  Index Scan using index_clients_id on clients c  (cost=0.14..0.60 rows=1 width=40)
--               Index Cond: (id = ct.client_id)


--Заметно что оптимизация была произведена, так как стоимомть запроса уменьшилась.


--Запрос 4
--Вывод  информации  о поездках
--и цены самого дешевого билета на поездку
--в порядке увеличения цены билетов

SELECT DISTINCT
  cost,
  date_depature,
  date_arrive,
  city_depature,
  city_arrive
FROM
  tickets T
  INNER JOIN
  jorneys J
    ON
      T.jorney_id = J.id
WHERE
  cost
  IN (SELECT MIN(cost)
      FROM tickets
      GROUP BY jorney_id)
ORDER BY cost ASC;

--Необходимость: 
--Создание завлекательной рекламы, в которой
--будут описана поездка и минимальная цена билета на неё

--Оптимизация
--Добавлены индексы:
CREATE INDEX index_jorneys_id ON jorneys(id);
CREATE INDEX index_tickets_cost ON tickets(cost ASC);

--Используются индексы:
index_tickets_jorney_id




--Запрос5
--Вывод информации об средней зарплате команды коробля

SELECT
  avg(worker_salary) AS avg_salary,
  boat_name
FROM staff
  INNER JOIN staff_boats ON staff.id = staff_boats.worker_id
  INNER JOIN boats ON staff_boats.boat_id = boats.id
GROUP BY boat_name
ORDER BY avg_salary ASC;
--Необходимость:
--средняя зарплата членов команды влияет на цену билетов
--и её надо знать при выставлении цен.

--оптимизация:
index_sb_boat_id 
index_sb_worker_id
index_staff_id
index_boats_id
staff_salaries_index
CREATE INDEX index_boats_name ON boats USING HASH(boat_name);