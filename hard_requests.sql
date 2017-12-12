--Запрос 1
--Вывести какую прибыль или какие затраты принесет данная поездка
SELECT DISTINCT ON (Jo.id)
  SUM(St.worker_salary * (Jo.date_arrive - Jo.date_depature))
  OVER (PARTITION BY Bo.id ) / tmp.num_tikets +
  Bo.spending_for_a_day * (Jo.date_arrive - Jo.date_depature) AS jorney_cost,
  SUM(Ti.cost)
  OVER (
    PARTITION BY Jo.id ) / Bo.number_of_landing_sites         AS jorney_profit
FROM staff St
  JOIN staff_boats SB ON St.id = SB.worker_id
  JOIN boats Bo ON SB.boat_id = Bo.id
  JOIN jorneys Jo ON Bo.id = Jo.boat_id
  JOIN tickets Ti ON Jo.id = Ti.jorney_id
  ,
  (SELECT COUNT(*) AS num_tikets
   FROM tickets
   WHERE jorney_id = _NUMBER_)
    AS tmp
WHERE Jo.id = _NUMBER_;
--допустимые значения [_NUMBER_]:
  6
  2
  8

--Необходимость:
--получение знаний о прибыльности той или иной поездки
--для оценки её рентабильности для компании.

--Оптимизация:
index_tickets_cost
index_tickets_jorney_id
index_staff_id
index_jorneys_dates
index_jorneys_id
index_boats_id
staff_salaries_index
index_sb_boat_id
index_sb_worker_id
CREATE INDEX index_jorneys_boat_id ON jorneys(boat_id);
CREATE INDEX index_boats_spending ON boats(spending_for_a_day);


--до оптимизации:
 Unique  (cost=80.32..81.12 rows=1 width=24) (actual time=0.561..0.577 rows=1 loops=1)
   ->  WindowAgg  (cost=80.32..81.12 rows=16 width=24) (actual time=0.557..0.570 rows=4 loops=1)
         ->  WindowAgg  (cost=80.32..80.68 rows=16 width=48) (actual time=0.501..0.513 rows=4 loops=1)
               ->  Sort  (cost=80.32..80.36 rows=16 width=40) (actual time=0.438..0.442 rows=4 loops=1)
                     Sort Key: bo.id
                     Sort Method: quicksort  Memory: 25kB
                     ->  Nested Loop  (cost=31.88..80.00 rows=16 width=40) (actual time=0.248..0.300 rows=4 loops=1)
                           ->  Seq Scan on tickets ti  (cost=0.00..31.25 rows=8 width=8) (actual time=0.049..0.057 rows=2 loops=1)
                                 Filter: (jorney_id = 6)
                                 Rows Removed by Filter: 23
                           ->  Materialize  (cost=31.88..48.55 rows=2 width=36) (actual time=0.098..0.116 rows=2 loops=2)
                                 ->  Nested Loop  (cost=31.88..48.54 rows=2 width=36) (actual time=0.180..0.210 rows=2 loops=1)
                                       ->  Nested Loop  (cost=31.73..48.15 rows=2 width=36) (actual time=0.164..0.177 rows=2 loops=1)
                                             ->  Nested Loop  (cost=31.57..47.65 rows=1 width=36) (actual time=0.102..0.108 rows=1 loops=1)
                                                   ->  Nested Loop  (cost=31.42..39.47 rows=1 width=24) (actual time=0.064..0.067 rows=1 loops=1)
                                                         ->  Aggregate  (cost=31.27..31.28 rows=1 width=8) (actual time=0.046..0.047 rows=1 loops=1)
                                                               ->  Seq Scan on tickets  (cost=0.00..31.25 rows=8 width=0) (actual time=0.027..0.035 rows=2 loops=1)
                                                                     Filter: (jorney_id = 6)
                                                                     Rows Removed by Filter: 23
                                                         ->  Index Scan using jorneys_pkey on jorneys jo  (cost=0.15..8.17 rows=1 width=16) (actual time=0.013..0.015 rows=1 loops=1)
                                                               Index Cond: (id = 6)
                                                   ->  Index Scan using boats_pkey on boats bo  (cost=0.15..8.17 rows=1 width=12) (actual time=0.030..0.031 rows=1 loops=1)
                                                         Index Cond: (id = jo.boat_id)
                                             ->  Index Only Scan using staff_boats_pkey on staff_boats sb  (cost=0.15..0.39 rows=11 width=8) (actual time=0.046..0.051 rows=2 loops=1)
                                                   Index Cond: (boat_id = bo.id)
                                                   Heap Fetches: 2
                                       ->  Index Scan using staff_pkey on staff st  (cost=0.15..0.19 rows=1 width=8) (actual time=0.009..0.010 rows=1 loops=2)
                                             Index Cond: (id = sb.worker_id)
 Planning time: 5.863 ms
 Execution time: 1.394 ms


--после оптимизации:
 Unique  (cost=6.67..6.77 rows=1 width=24) (actual time=0.124..0.127 rows=1 loops=1)
   ->  WindowAgg  (cost=6.67..6.77 rows=2 width=24) (actual time=0.123..0.126 rows=4 loops=1)
         ->  WindowAgg  (cost=6.67..6.72 rows=2 width=48) (actual time=0.110..0.111 rows=4 loops=1)
               ->  Sort  (cost=6.67..6.68 rows=2 width=40) (actual time=0.097..0.098 rows=4 loops=1)
                     Sort Key: bo.id
                     Sort Method: quicksort  Memory: 25kB
                     ->  Nested Loop  (cost=2.72..6.66 rows=2 width=40) (actual time=0.054..0.081 rows=4 loops=1)
                           ->  Nested Loop  (cost=2.59..5.87 rows=1 width=36) (actual time=0.051..0.073 rows=4 loops=1)
                                 ->  Nested Loop  (cost=2.45..5.08 rows=1 width=36) (actual time=0.043..0.059 rows=4 loops=1)
                                       ->  Hash Join  (cost=1.14..2.41 rows=1 width=24) (actual time=0.029..0.033 rows=2 loops=1)
                                             Hash Cond: (sb.boat_id = jo.boat_id)
                                             ->  Seq Scan on staff_boats sb  (cost=0.00..1.19 rows=19 width=8) (actual time=0.008..0.008 rows=19 loops=1)
                                             ->  Hash  (cost=1.12..1.12 rows=1 width=16) (actual time=0.010..0.010 rows=1 loops=1)
                                                   Buckets: 1024  Batches: 1  Memory Usage: 9kB
                                                   ->  Seq Scan on jorneys jo  (cost=0.00..1.12 rows=1 width=16) (actual time=0.005..0.006 rows=1 loops=1)
                                                         Filter: (id = 6)
                                                         Rows Removed by Filter: 9
                                       ->  Nested Loop  (cost=1.31..2.66 rows=1 width=16) (actual time=0.010..0.011 rows=2 loops=2)
                                             ->  Aggregate  (cost=1.31..1.32 rows=1 width=8) (actual time=0.007..0.007 rows=1 loops=2)
                                                   ->  Seq Scan on tickets  (cost=0.00..1.31 rows=1 width=0) (actual time=0.004..0.005 rows=2 loops=2)
                                                         Filter: (jorney_id = 6)
                                                         Rows Removed by Filter: 23
                                             ->  Seq Scan on tickets ti  (cost=0.00..1.31 rows=1 width=8) (actual time=0.003..0.005 rows=2 loops=2)
                                                   Filter: (jorney_id = 6)
                                                   Rows Removed by Filter: 23
                                 ->  Index Scan using index_staff_id on staff st  (cost=0.14..0.78 rows=1 width=8) (actual time=0.003..0.003 rows=1 loops=4)
                                       Index Cond: (id = sb.worker_id)
                           ->  Index Scan using index_boats_id on boats bo  (cost=0.14..0.78 rows=1 width=12) (actual time=0.001..0.002 rows=1 loops=4)
                                 Index Cond: (id = sb.boat_id)
 Planning time: 4.321 ms
 Execution time: 0.256 ms


-- заметно, что оптимизация была проведена оптимально, поскольку условная 
-- стоимость итераций в запросах была уменьшена в несколько раз, а также 
-- несколько поменялся сам план запроса и время его выполнения

-- примечание:
-- почему не был использован такой запроос:
SELECT
    jorney_profit,
  jorney_cost
FROM (
       SELECT DISTINCT
         Jo.id                                                       AS jorney_id,
         SUM(St.worker_salary * (Jo.date_arrive - Jo.date_depature))
         OVER (
           PARTITION BY Bo.id ) +
         Bo.spending_for_a_day * (Jo.date_arrive - Jo.date_depature) AS jorney_cost
       FROM staff St
         JOIN staff_boats SB ON St.id = SB.worker_id
         JOIN boats Bo ON SB.boat_id = Bo.id
         JOIN jorneys Jo ON Bo.id = Jo.boat_id
       WHERE Jo.id = _NUMBER_)
  AS spending_table
  JOIN
  (SELECT DISTINCT ON (jorney_id)
     Jo.id                  AS jorney_id,
     SUM(Ti.cost)
     OVER (
       PARTITION BY Jo.id ) AS jorney_profit
   FROM jorneys Jo
     JOIN tickets Ti
       ON Jo.id = Ti.jorney_id)
    AS profit_table
    ON spending_table.jorney_id = profit_table.jorney_id;
-- изначальная версия зпроса. Неоптимальна и медленна по сравнению с новой,
-- а также переусложнена из-за большего количества подзапросов.





--Запрос 2
-- вывести колличество людей проживающих по одному адресу и находящихся в одной поездке,
-- сам адрес и дату их прибытия.

SELECT DISTINCT
  ad.id,
  ad.contry,
  ad.town,
  ad.street,
  tmp.date_arrive,
  count(*)
  OVER (
    PARTITION BY ad.id )
FROM addresses ad
  JOIN (
         SELECT
           address,
           st.id AS staff_id,
           NULL  AS client_id,
           jo.date_arrive
         FROM staff st
           JOIN staff_boats sb ON st.id = sb.worker_id
           JOIN boats bo ON sb.boat_id = bo.id
           JOIN jorneys jo ON bo.id = jo.boat_id
         WHERE jo.id = _NUMBER_

         UNION

         SELECT
           address,
           NULL  AS staff_id,
           cl.id AS client_id,
           jo.date_arrive
         FROM jorneys jo
           JOIN tickets ti ON jo.id = ti.jorney_id
           JOIN clients_tickets ct ON ti.id = ct.ticket_id
           JOIN clients cl ON cl.id = ct.client_id
         WHERE jo.id = _NUMBER_
       ) AS tmp
    ON ad.id = tmp.address;
--допустимые значения [_NUMBER_]:
  6
  2
  8


--необходимость:
-- Нужно подготовить определенное количество транспортных средств 
-- с опрделенным количеством пасссажирских мест и водителей,
-- с помощью которых пассажиры и экипаж смогут добраться до домашнего адреса
-- из пункта прибытия корабля из круиза.

--оптимизация
index_tickets_jorney_id
index_staff_id
index_jorneys_dates
index_jorneys_id
index_boats_id
index_sb_boat_id
index_sb_worker_id
index_jorneys_boat_id
index_ct_client_id 
index_ct_ticket_id
index_tickets_id
index_clients_id
CREATE INDEX index_addresses_all ON addresses(id,contry,town,street);
CREATE INDEX index_staff_address ON staff(address);
CREATE INDEX index_clients_address ON clients(address); 


-- до оптимизации
Unique  (cost=120.43..120.65 rows=13 width=112) (actual time=1.483..1.498 rows=4 loops=1)
   ->  Sort  (cost=120.43..120.46 rows=13 width=112) (actual time=1.481..1.483 rows=4 loops=1)
         Sort Key: ad.id, ad.contry, ad.town, ad.street, tmp.date_arrive, (count(*) OVER (?))
         Sort Method: quicksort  Memory: 25kB
         ->  WindowAgg  (cost=119.96..120.19 rows=13 width=112) (actual time=1.208..1.232 rows=4 loops=1)
               ->  Sort  (cost=119.96..119.99 rows=13 width=104) (actual time=1.181..1.184 rows=4 loops=1)
                     Sort Key: ad.id
                     Sort Method: quicksort  Memory: 25kB
                     ->  Hash Join  (cost=100.93..119.72 rows=13 width=104) (actual time=1.122..1.137 rows=4 loops=1)
                           Hash Cond: (ad.id = tmp.address)
                           ->  Seq Scan on addresses ad  (cost=0.00..16.30 rows=630 width=100) (actual time=0.019..0.028 rows=10 loops=1)
                           ->  Hash  (cost=100.76..100.76 rows=13 width=8) (actual time=1.057..1.057 rows=4 loops=1)
                                 Buckets: 1024  Batches: 1  Memory Usage: 9kB
                                 ->  Subquery Scan on tmp  (cost=100.50..100.76 rows=13 width=8) (actual time=1.030..1.040 rows=4 loops=1)
                                       ->  HashAggregate  (cost=100.50..100.63 rows=13 width=16) (actual time=1.028..1.034 rows=4 loops=1)
                                             Group Key: st.address, st.id, (NULL::integer), jo.date_arrive
                                             ->  Append  (cost=0.61..100.37 rows=13 width=16) (actual time=0.689..1.000 rows=4 loops=1)
                                                   ->  Nested Loop  (cost=0.61..17.24 rows=2 width=16) (actual time=0.687..0.721 rows=2 loops=1)
                                                         ->  Nested Loop  (cost=0.46..16.85 rows=2 width=8) (actual time=0.637..0.651 rows=2 loops=1)
                                                               ->  Nested Loop  (cost=0.30..16.35 rows=1 width=12) (actual time=0.087..0.092 rows=1 loops=1)
                                                                     ->  Index Scan using jorneys_pkey on jorneys jo  (cost=0.15..8.17 rows=1 width=8) (actual time=0.016..0.018 rows=1 loops=1)
                                                                           Index Cond: (id = 3)
                                                                     ->  Index Only Scan using boats_pkey on boats bo  (cost=0.15..8.17 rows=1 width=4) (actual time=0.053..0.055 rows=1 loops=1)
                                                                           Index Cond: (id = jo.boat_id)
                                                                           Heap Fetches: 1
                                                               ->  Index Only Scan using staff_boats_pkey on staff_boats sb  (cost=0.15..0.39 rows=11 width=8) (actual time=0.113..0.120 rows=2 loops=1)
                                                                     Index Cond: (boat_id = bo.id)
                                                                     Heap Fetches: 2
                                                         ->  Index Scan using staff_pkey on staff st  (cost=0.15..0.19 rows=1 width=8) (actual time=0.025..0.027 rows=1 loops=2)
                                                               Index Cond: (id = sb.worker_id)
                                                   ->  Nested Loop  (cost=31.65..83.00 rows=11 width=16) (actual time=0.226..0.273 rows=2 loops=1)
                                                         ->  Nested Loop  (cost=31.50..80.81 rows=11 width=8) (actual time=0.193..0.224 rows=2 loops=1)
                                                               ->  Index Scan using jorneys_pkey on jorneys jo_1  (cost=0.15..8.17 rows=1 width=8) (actual time=0.010..0.011 rows=1 loops=1)
                                                                     Index Cond: (id = 3)
                                                               ->  Hash Join  (cost=31.35..72.53 rows=11 width=8) (actual time=0.179..0.206 rows=2 loops=1)
                                                                     Hash Cond: (ct.ticket_id = ti.id)
                                                                     ->  Seq Scan on clients_tickets ct  (cost=0.00..32.60 rows=2260 width=8) (actual time=0.036..0.055 rows=27 loops=1)
                                                                     ->  Hash  (cost=31.25..31.25 rows=8 width=8) (actual time=0.064..0.064 rows=2 loops=1)
                                                                           Buckets: 1024  Batches: 1  Memory Usage: 9kB
                                                                           ->  Seq Scan on tickets ti  (cost=0.00..31.25 rows=8 width=8) (actual time=0.032..0.048 rows=2 loops=1)
                                                                                 Filter: (jorney_id = 3)
                                                                                 Rows Removed by Filter: 23
                                                         ->  Index Scan using clients_pkey on clients cl  (cost=0.15..0.19 rows=1 width=8) (actual time=0.017..0.018 rows=1 loops=2)
                                                               Index Cond: (id = ct.client_id)
 Planning time: 6.184 ms
 Execution time: 2.734 ms


--после оптимизации
 Unique  (cost=9.87..9.93 rows=3 width=112) (actual time=0.553..0.565 rows=4 loops=1)
   ->  Sort  (cost=9.87..9.88 rows=3 width=112) (actual time=0.552..0.554 rows=4 loops=1)
         Sort Key: ad.id, ad.contry, ad.town, ad.street, tmp.date_arrive, (count(*) OVER (?))
         Sort Method: quicksort  Memory: 25kB
         ->  WindowAgg  (cost=9.80..9.85 rows=3 width=112) (actual time=0.476..0.494 rows=4 loops=1)
               ->  Sort  (cost=9.80..9.80 rows=3 width=104) (actual time=0.452..0.454 rows=4 loops=1)
                     Sort Key: ad.id
                     Sort Method: quicksort  Memory: 25kB
                     ->  Hash Join  (cost=8.61..9.77 rows=3 width=104) (actual time=0.408..0.421 rows=4 loops=1)
                           Hash Cond: (ad.id = tmp.address)
                           ->  Seq Scan on addresses ad  (cost=0.00..1.10 rows=10 width=100) (actual time=0.020..0.027 rows=10 loops=1)
                           ->  Hash  (cost=8.57..8.57 rows=3 width=8) (actual time=0.348..0.348 rows=4 loops=1)
                                 Buckets: 1024  Batches: 1  Memory Usage: 9kB
                                 ->  Subquery Scan on tmp  (cost=8.51..8.57 rows=3 width=8) (actual time=0.332..0.339 rows=4 loops=1)
                                       ->  HashAggregate  (cost=8.51..8.54 rows=3 width=16) (actual time=0.330..0.333 rows=4 loops=1)
                                             Group Key: st.address, st.id, (NULL::integer), jo.date_arrive
                                             ->  Append  (cost=1.41..8.48 rows=3 width=16) (actual time=0.130..0.306 rows=4 loops=1)
                                                   ->  Nested Loop  (cost=1.41..4.00 rows=2 width=16) (actual time=0.128..0.163 rows=2 loops=1)
                                                         ->  Nested Loop  (cost=1.27..3.20 rows=1 width=20) (actual time=0.108..0.132 rows=2 loops=1)
                                                               ->  Hash Join  (cost=1.14..2.41 rows=1 width=16) (actual time=0.082..0.095 rows=2 loops=1)
                                                                     Hash Cond: (sb.boat_id = jo.boat_id)
                                                                     ->  Seq Scan on staff_boats sb  (cost=0.00..1.19 rows=19 width=8) (actual time=0.009..0.016 rows=19 loops=1)
                                                                     ->  Hash  (cost=1.12..1.12 rows=1 width=8) (actual time=0.038..0.038 rows=1 loops=1)
                                                                           Buckets: 1024  Batches: 1  Memory Usage: 9kB
                                                                           ->  Seq Scan on jorneys jo  (cost=0.00..1.12 rows=1 width=8) (actual time=0.021..0.027 rows=1 loops=1)
                                                                                 Filter: (id = 3)
                                                                                 Rows Removed by Filter: 9
                                                               ->  Index Scan using index_staff_id on staff st  (cost=0.14..0.78 rows=1 width=8) (actual time=0.011..0.013 rows=1 loops=2)
                                                                     Index Cond: (id = sb.worker_id)
                                                         ->  Index Only Scan using index_boats_id on boats bo  (cost=0.14..0.78 rows=1 width=4) (actual time=0.007..0.008 rows=1 loops=2)
                                                               Index Cond: (id = sb.boat_id)
                                                               Heap Fetches: 2
                                                   ->  Nested Loop  (cost=1.46..4.45 rows=1 width=16) (actual time=0.100..0.139 rows=2 loops=1)
                                                         ->  Nested Loop  (cost=1.32..3.84 rows=1 width=8) (actual time=0.087..0.117 rows=2 loops=1)
                                                               ->  Hash Join  (cost=1.32..2.71 rows=1 width=8) (actual time=0.079..0.095 rows=2 loops=1)
                                                                     Hash Cond: (ct.ticket_id = ti.id)
                                                                     ->  Seq Scan on clients_tickets ct  (cost=0.00..1.27 rows=27 width=8) (actual time=0.007..0.014 rows=27 loops=1)
                                                                     ->  Hash  (cost=1.31..1.31 rows=1 width=8) (actual time=0.029..0.029 rows=2 loops=1)
                                                                           Buckets: 1024  Batches: 1  Memory Usage: 9kB
                                                                           ->  Seq Scan on tickets ti  (cost=0.00..1.31 rows=1 width=8) (actual time=0.013..0.020 rows=2 loops=1)
                                                                                 Filter: (jorney_id = 3)
                                                                                 Rows Removed by Filter: 23
                                                               ->  Seq Scan on jorneys jo_1  (cost=0.00..1.12 rows=1 width=8) (actual time=0.005..0.009 rows=1 loops=2)
                                                                     Filter: (id = 3)
                                                                     Rows Removed by Filter: 9
                                                         ->  Index Scan using index_clients_id on clients cl  (cost=0.14..0.60 rows=1 width=8) (actual time=0.006..0.007 rows=1 loops=2)
                                                               Index Cond: (id = ct.client_id)

 Planning time: 7.006 ms
 Execution time: 1.104 ms

--заметно, что оптимизация оказалась действенной, так как условная стоимость опустислась, а также уменьшилось время на обработку запроса


--примечание:
--использована такая реализация запроса из-за удобства подсчета людей проживающих по одному адресу.





--Запрос 3,
-- выбрать людей, чья зарплата больше 90, возраст от 25 до 40, опыт больше 3 лет и сколько дней они проработали в этом сезоне на данный момент.
SELECT DISTINCT
  St.full_name               AS worker_full_name,
  SUM(CASE WHEN (JO.date_arrive < now() :: DATE)
    THEN (Jo.date_arrive - Jo.date_depature)
      ELSE (now() :: DATE - Jo.date_depature) END)
  OVER (
    PARTITION BY full_name ) AS worked_days_in_this_season,
  St.number_of_worked_years  AS experience,
  St.worker_salary           AS worker_salary,
  ST.worker_age              AS age
FROM staff St
  INNER JOIN staff_boats SB
    ON St.id = SB.worker_id
       AND St.worker_age BETWEEN 25 AND 40
       AND St.worker_salary > 90
       AND St.number_of_worked_years >= 3
  INNER JOIN boats Bo
    ON SB.boat_id = Bo.id
  INNER JOIN jorneys Jo
    ON Bo.id = Jo.boat_id
       AND JO.date_depature < now() :: DATE
ORDER BY worked_days_in_this_season DESC, experience DESC;

-- статистика - поэтому нет параметра

--Необходимость: кампания решила выплатить премии молодым преданным специалистам. 
-- на основе данной статистики можно решить кому она достанется.

--оптимзация:
index_staff_id
index_jorneys_dates
index_jorneys_id
index_boats_id
index_sb_boat_id
index_sb_worker_id
index_jorneys_boat_id
staff_age_index
staff_salaries_index
index_staff_full_name
CREATE INDEX index_staff_experience ON staff(number_of_worked_years);

--до оптимизации:
 Unique  (cost=82.32..82.33 rows=1 width=84) (actual time=0.585..0.591 rows=2 loops=1)
   ->  Sort  (cost=82.32..82.32 rows=1 width=84) (actual time=0.583..0.584 rows=3 loops=1)
         Sort Key: (sum(CASE WHEN (jo.date_arrive < (now())::date) THEN (jo.date_arrive - jo.date_depature) ELSE ((now())::date - jo.date_depature) END) 
          OVER (?)) DESC, st.number_of_worked_years DESC, st.full_name, st.worker_salary, st.worker_age
         Sort Method: quicksort  Memory: 25kB
         ->  WindowAgg  (cost=82.27..82.31 rows=1 width=84) (actual time=0.461..0.476 rows=3 loops=1)
               ->  Sort  (cost=82.27..82.27 rows=1 width=52) (actual time=0.406..0.408 rows=3 loops=1)
                     Sort Key: st.full_name
                     Sort Method: quicksort  Memory: 25kB
                     ->  Nested Loop  (cost=57.29..82.26 rows=1 width=52) (actual time=0.322..0.364 rows=3 loops=1)
                           ->  Hash Join  (cost=57.14..81.25 rows=5 width=60) (actual time=0.262..0.286 rows=3 loops=1)
                                 Hash Cond: (jo.boat_id = sb.boat_id)
                                 ->  Seq Scan on jorneys jo  (cost=0.00..23.12 rows=250 width=12) (actual time=0.028..0.045 rows=2 loops=1)
                                       Filter: (date_depature < (now())::date)
                                       Rows Removed by Filter: 8
                                 ->  Hash  (cost=57.09..57.09 rows=4 width=48) (actual time=0.195..0.195 rows=7 loops=1)
                                       Buckets: 1024  Batches: 1  Memory Usage: 9kB
                                       ->  Nested Loop  (cost=25.11..57.09 rows=4 width=48) (actual time=0.095..0.169 rows=7 loops=1)
                                             ->  Seq Scan on staff st  (cost=0.00..21.20 rows=1 width=48) (actual time=0.016..0.036 rows=5 loops=1)
                                                   Filter: ((worker_age >= 25) AND (worker_age <= 40) AND (worker_salary > 90) AND (number_of_worked_years >= 3))
                                                   Rows Removed by Filter: 10
                                             ->  Bitmap Heap Scan on staff_boats sb  (cost=25.11..35.78 rows=11 width=8) (actual time=0.021..0.022 rows=1 loops=5)
                                                   Recheck Cond: (worker_id = st.id)
                                                   Heap Blocks: exact=5
                                                   ->  Bitmap Index Scan on staff_boats_pkey  (cost=0.00..25.11 rows=11 width=0) (actual time=0.006..0.006 rows=1 loops=5)
                                                         Index Cond: (worker_id = st.id)
                           ->  Index Only Scan using boats_pkey on boats bo  (cost=0.15..0.19 rows=1 width=4) (actual time=0.019..0.021 rows=1 loops=3)
                                 Index Cond: (id = sb.boat_id)
                                 Heap Fetches: 3
 Planning time: 3.757 ms
 Execution time: 1.230 ms


-- после оптимизации:
 Unique  (cost=4.24..4.25 rows=1 width=84) (actual time=0.443..0.450 rows=2 loops=1)
   ->  Sort  (cost=4.24..4.24 rows=1 width=84) (actual time=0.441..0.441 rows=3 loops=1)
         Sort Key: (sum(CASE WHEN (jo.date_arrive < (now())::date) THEN (jo.date_arrive - jo.date_depature) ELSE ((now())::date - jo.date_depature) END) 
          OVER (?)) DESC, st.number_of_worked_years DESC, st.full_name, st.worker_salary, st.worker_age
         Sort Method: quicksort  Memory: 25kB
         ->  WindowAgg  (cost=4.19..4.23 rows=1 width=84) (actual time=0.376..0.390 rows=3 loops=1)
               ->  Sort  (cost=4.19..4.19 rows=1 width=52) (actual time=0.327..0.329 rows=3 loops=1)
                     Sort Key: st.full_name
                     Sort Method: quicksort  Memory: 25kB
                     ->  Nested Loop  (cost=1.58..4.18 rows=1 width=52) (actual time=0.174..0.291 rows=3 loops=1)
                           ->  Nested Loop  (cost=1.45..3.38 rows=1 width=52) (actual time=0.152..0.218 rows=7 loops=1)
                                 ->  Hash Join  (cost=1.31..2.58 rows=1 width=48) (actual time=0.115..0.141 rows=7 loops=1)
                                       Hash Cond: (sb.worker_id = st.id)
                                       ->  Seq Scan on staff_boats sb  (cost=0.00..1.19 rows=19 width=8) (actual time=0.021..0.027 rows=19 loops=1)
                                       ->  Hash  (cost=1.30..1.30 rows=1 width=48) (actual time=0.056..0.056 rows=5 loops=1)
                                             Buckets: 1024  Batches: 1  Memory Usage: 9kB
                                             ->  Seq Scan on staff st  (cost=0.00..1.30 rows=1 width=48) (actual time=0.020..0.039 rows=5 loops=1)
                                                   Filter: ((worker_age >= 25) AND (worker_age <= 40) AND (worker_salary > 90) AND (number_of_worked_years >= 3))
                                                   Rows Removed by Filter: 10
                                 ->  Index Only Scan using index_boats_id on boats bo  (cost=0.14..0.78 rows=1 width=4) (actual time=0.006..0.007 rows=1 loops=7)
                                       Index Cond: (id = sb.boat_id)
                                       Heap Fetches: 7
                           ->  Index Scan using index_jorneys_boat_id on jorneys jo  (cost=0.14..0.79 rows=1 width=12) (actual time=0.007..0.009 rows=0 loops=7)
                                 Index Cond: (boat_id = sb.boat_id)
                                 Filter: (date_depature < (now())::date)
                                 Rows Removed by Filter: 1
 Planning time: 2.358 ms
 Execution time: 0.834 ms
