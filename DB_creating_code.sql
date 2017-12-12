DROP TABLE IF EXISTS addresses CASCADE;
DROP TABLE IF EXISTS boats CASCADE;
DROP TABLE IF EXISTS staff CASCADE;
DROP TABLE IF EXISTS "staff_boats" CASCADE;
DROP TABLE IF EXISTS clients CASCADE;
DROP TABLE IF EXISTS jorneys CASCADE;
DROP TABLE IF EXISTS tickets CASCADE;
DROP TABLE IF EXISTS clients_tickets CASCADE;
DROP INDEX IF EXISTS clients_phone_unique_index;
DROP DOMAIN IF EXISTS pasport_number;
DROP DOMAIN IF EXISTS phone_number;


CREATE DOMAIN pasport_number AS TEXT
  CHECK (value :: TEXT ~ '^[0-9[:space:]]+$' AND
         octet_length(trim(value)) > 7 AND
         octet_length(VALUE) < 20);

CREATE DOMAIN phone_number AS TEXT
  CHECK (value ISNULL OR (value :: TEXT ~ '^[0-9+-.\(\)[:space:]]+$' AND
                          octet_length(trim(value)) > 5 AND
                          octet_length(value) < 30));

CREATE TABLE "addresses" (
  "id"     SERIAL NOT NULL,
  "contry" TEXT   NOT NULL,
  "town"   TEXT   NOT NULL,
  "street" TEXT   NOT NULL,
  CONSTRAINT check_is_valid_string_contry CHECK (octet_length(trim(contry)) > 1
                                                 AND contry :: TEXT ~ '^[A-Za-z[:space:]-]+$'
                                                 AND length(contry) < 100),
  CONSTRAINT check_is_valid_string_town CHECK (octet_length(trim(town)) > 1
                                               AND town :: TEXT ~ '^[A-Za-z[:space:]-]+$'
                                               AND length((town)) < 100),
  CONSTRAINT check_is_valid_string_street CHECK (octet_length(trim(street)) > 1
                                                 AND contry :: TEXT ~ '^[A-Za-z[:space:]-]+$'
                                                 AND length((street)) < 100),
  PRIMARY KEY (id)
);

CREATE TABLE "boats" (
  "id"                      SERIAL NOT NULL,
  "boat_name"               TEXT   NOT NULL,
  "number_of_landing_sites" INT    NOT NULL,
  "spending_for_a_day"      INT    NOT NULL,
  CONSTRAINT check_positive_number_of_landing_sites CHECK (number_of_landing_sites > 0),
  CONSTRAINT check_positive_spending_for_a_day CHECK (spending_for_a_day > 0),
  CONSTRAINT check_is_valid_string_boat_name CHECK (octet_length(ltrim(boat_name)) > 1
                                                    AND boat_name :: TEXT ~ '^[A-Za-z0-9+[:space:]-]+$'),
  PRIMARY KEY (id)
);

CREATE TABLE "staff" (
  "id"                     SERIAL         NOT NULL,
  "full_name"              TEXT           NOT NULL,
  "phone_number"           PHONE_NUMBER   NOT NULL UNIQUE,
  "pasport_number"         PASPORT_NUMBER NOT NULL UNIQUE,
  "number_of_worked_years" INT            NOT NULL,
  "worker_age"             INT            NOT NULL,
  "worker_salary"          INT,
  "address"                INT            NOT NULL,
  PRIMARY KEY (id),
  FOREIGN KEY (address) REFERENCES addresses (id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT check_positive_worker_age CHECK (worker_age > 0),
  CONSTRAINT check_legal_age_to_work CHECK (worker_age > 15),
  CONSTRAINT check_positive_worker_salary CHECK (worker_salary > 0),
  CONSTRAINT check_positive_number_of_worked_years CHECK (number_of_worked_years > -1),
  CONSTRAINT check_legal_work CHECK (number_of_worked_years < worker_age - 16),
  CONSTRAINT check_is_valid_string_full_name CHECK (octet_length(trim(full_name)) > 1 AND
                                                    full_name :: TEXT ~ '^[A-Za-z[:space:]]+$')
);


CREATE TABLE "staff_boats" (
  "boat_id"   INT NOT NULL,
  "worker_id" INT NOT NULL,
  PRIMARY KEY (boat_id, worker_id),
  FOREIGN KEY (boat_id) REFERENCES boats (id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (worker_id) REFERENCES staff (id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE "jorneys" (
  "id"            SERIAL NOT NULL,
  "boat_id"       INT    NOT NULL,
  "date_depature" DATE   NOT NULL,
  "date_arrive"   DATE   NOT NULL,
  "city_depature" TEXT   NOT NULL,
  "city_arrive"   TEXT   NOT NULL,
  CONSTRAINT check_is_valid_string_city_depature CHECK (
    octet_length(trim(city_depature)) > 1
    AND city_depature :: TEXT ~ '^[A-Za-z[:space:]-]+$'
    AND length(city_depature) < 100),
  CONSTRAINT check_is_valid_string_city_arrrive CHECK (
    octet_length(trim(city_arrive)) > 1
    AND city_arrive :: TEXT ~ '^[A-Za-z[:space:]-]+$'
    AND length(city_arrive) < 100),
  CONSTRAINT check_is_valid_date_order CHECK (date_depature <= date_depature),
  PRIMARY KEY (id),
  FOREIGN KEY (boat_id) REFERENCES boats (id) ON DELETE CASCADE ON UPDATE CASCADE
);


CREATE TABLE "tickets" (
  "id"           SERIAL NOT NULL,
  "jorney_id"    INT    NOT NULL,
  "cost"         INT    NOT NULL,
  "cabin_number" INT    NOT NULL,
  "ticket_class" INT    NOT NULL,
  CONSTRAINT check_is_positive_cabin_number CHECK (cabin_number > 0),
  CONSTRAINT check_is_positive_cost CHECK (cost > 0),
  CONSTRAINT check_is_valid_ticket_class CHECK (ticket_class > 0 AND ticket_class < 4),
  PRIMARY KEY (id),
  FOREIGN KEY (jorney_id) REFERENCES jorneys (id) ON DELETE CASCADE ON UPDATE CASCADE
);


CREATE TABLE "clients" (
  "id"             SERIAL         NOT NULL,
  "full_name"      TEXT           NOT NULL,
  "client_age"     INT,
  "phone_number"   PHONE_NUMBER,
  "pasport_number" PASPORT_NUMBER NOT NULL UNIQUE,
  "address"        INT,
  PRIMARY KEY (id),
  CONSTRAINT check_is_positive_client_age CHECK (client_age > 0 OR client_age ISNULL),
  CONSTRAINT check_is_valid_string_full_name CHECK (octet_length(trim(full_name)) > 1 AND
                                                    full_name :: TEXT ~ '^[A-Za-z[:space:]-]+$'),
  FOREIGN KEY (address) REFERENCES addresses (id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE UNIQUE INDEX clients_phone_unique_index
  ON clients (phone_number)
  WHERE phone_number NOTNULL;

CREATE TABLE "clients_tickets" (
  "client_id" INT NOT NULL,
  "ticket_id" INT NOT NULL,
  PRIMARY KEY (client_id, ticket_id),
  FOREIGN KEY (client_id) REFERENCES clients (id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (ticket_id) REFERENCES tickets (id) ON DELETE CASCADE ON UPDATE CASCADE
);

INSERT INTO addresses (contry, town, street) VALUES
  ('Russia', 'Petergoth', 'Chicherinskay'),
  ('Russia', 'Piter', 'Nevsky Prospect'),
  ('Russia', 'Moskva', 'Red Square'),
  ('Russia', 'Murmansk', 'Stalina'),
  ('Russia', 'Piter', 'Lenina'),
  ('USA', 'Boston', 'Vinstons'),
  ('Astrulia', 'Sydney', 'Lenina'),
  ('UK', 'London', 'Green'),
  ('Moon', 'Rain', 'Kotyt'),
  ('Russia', 'Petergoth', 'Botanichescay');

INSERT INTO staff (full_name, phone_number, pasport_number, number_of_worked_years, worker_age, worker_salary, address)
VALUES
  ('Gans Hristian Anderson', '+799999999', '56789034', 4, 27, 100, 1),
  ('Frederic Lorigin Rouse', '+799945754', '56387454', 7, 38, 150, 2),
  ('Brian Kokel Shane', '+799834654', '83745634', 1, 23, 60, 5),
  ('Fred Bright Start', '+799234673', '18236334', 17, 56, 23, 1),
  ('Grock Harrison Loddy', '+799934845', '92175743', 3, 33, 90, 7),
  ('Ivan Ivanov Ivanovich', '+799923654', '38745665', 100, 200, 500, 2),
  ('Ludvig Bethoven Drousil', '+791299967', '56773394', 9, 37, 173, 9),
  ('Drenden Droun Drang', '+796633999', '57788224', 12, 32, 207, 6),
  ('Fiona Filly Fon', '+799399009', '83745689', 4, 43, 100, 4),
  ('Dolchy Gabana', '+7943765679', '38475678', 23, 60, 325, 5),
  ('Pushkin Alex', '753845', '76458923', 4, 34, 100, 2),
  ('London Jeck', '8911674583', '32548273', 17, 45, 269, 8),
  ('Rembo Rembo', '+7734638883', '87650345', 2, 26, 80, 6),
  ('Timur Slima', '8947567246', '28635564', 1, 56, 61, 1),
  ('Kek Cheburek', '0202020301', '34876893', 0, 23, 12, 2);

INSERT INTO boats (boat_name, number_of_landing_sites, spending_for_a_day) VALUES
  ('Petrovich', 5, 400),
  ('Titanic', 4, 320),
  ('Rudi', 2, 160),
  ('Dolores', 2, 160),
  ('Cheloveck-Parahod', 1, 110),
  ('IronMan', 2, 200),
  ('IRA', 1, 80),
  ('LeNiN', 2, 210),
  ('C++', 1, 130);

INSERT INTO staff_boats (boat_id, worker_id) VALUES
  (1, 1),
  (1, 2),
  (1, 3),
  (1, 4),
  (2, 5),
  (2, 6),
  (2, 7),
  (2, 8),
  (3, 2),
  (3, 9),
  (4, 6),
  (4, 10),
  (5, 11),
  (6, 12),
  (6, 11),
  (7, 13),
  (8, 15),
  (8, 14),
  (9, 15);

INSERT INTO jorneys (boat_id, date_depature, date_arrive, city_depature, city_arrive) VALUES
  (1, '2017-10-02', '2018-01-12', 'London', 'Paris'),
  (2, '2017-12-31', '2018-01-01', 'Laplandia', 'all world'),
  (3, '2017-09-01', '2017-09-15', 'Piter', 'Moskva'),
  (4, '2018-02-01', '2018-03-01', 'Tagil', 'Gelengick'),
  (1, '2018-04-18', '2018-06-17', 'London', 'New-York'),
  (3, '2018-08-01', '2018-08-10', 'Barselona', 'Barselona'),
  (4, '2018-06-01', '2018-08-31', 'Yamaika', 'Gelengick'),
  (6, '2017-12-31', '2018-12-31', 'St-Petersburg', 'Moskva'),
  (7, '2018-03-30', '2018-04-02', 'Minsk', 'Paris'),
  (8, '2018-05-05', '2019-06-06', 'Tokio', 'New-York');


INSERT INTO tickets (jorney_id, cost, cabin_number, ticket_class) VALUES
  (1, 1700, 1, 2),
  (1, 1700, 2, 2),
  (1, 1700, 3, 2),
  (1, 3400, 4, 3),
  (1, 3450, 5, 1),
  (2, 20000, 1, 2),
  (2, 20000, 2, 2),
  (2, 100000, 3, 1),
  (2, 100000, 4, 1),
  (3, 1300, 1, 2),
  (3, 1300, 2, 2),
  (4, 2000, 1, 2),
  (4, 2000, 2, 2),
  (5, 1900, 1, 2),
  (5, 1900, 2, 2),
  (5, 1900, 3, 2),
  (5, 3800, 4, 3),
  (5, 4000, 5, 1),
  (6, 400, 1, 2),
  (6, 400, 2, 2),
  (7, 70000, 1, 2),
  (7, 70000, 2, 2),
  (8, 200000, 1, 1),
  (9, 200, 1, 3),
  (10, 10000, 1, 2);

INSERT INTO clients (full_name, client_age, phone_number, pasport_number, address) VALUES
  ('Wiliam Sheksper', 47, '+799999999', '56789034', 10),
  ('Leonard Snowden', 67, '+798475879', '83578957', 9),
  ('Jordan Bush', 79, '+743568788', '32547230', 8),
  ('Iogan Kepler', 34, '+704959374', '74558738', 7),
  ('Galileo Galiley', 23, '+798357949', '09450934', 6),
  ('Vladimir Putin ', 62, '+000000000', '00000000', 3),
  ('Rodion Raskolnikov', 56, '+789357483', '62487548', 7),
  ('Homa Homa', 12, '+787564768', '32654984', 4),
  ('Lolipo Android', 45, '+773578334', '78563875', 10),
  ('Leonard Snow', 89, '+743578945', '52872117', 4),
  ('Fixik Pixik', 23, '+712738343', '47593793', 2),
  ('Help Me', 34, '+798573573', '45739540', 1),
  ('Martin Lenon', 23, NULL, '59673546', NULL),
  ('Merry Lenon', NULL, NULL, '69481637', NULL),
  ('Ostin Jeck', 45, '893747236', '69786235', 4),
  ('Din Kihot', 67, NULL, '38956785', 5),
  ('Lina Kihot', 66, NULL, '45789213', NULL);

INSERT INTO clients_tickets (client_id, ticket_id) VALUES
  (1, 1),
  (2, 2),
  (3, 3),
  (4, 4),
  (5, 5),
  (6, 6),
  (7, 7),
  (8, 8),
  (9, 9),
  (1, 10),
  (7, 11),
  (5, 12),
  (6, 13),
  (10, 14),
  (11, 15),
  (12, 16),
  (1, 17),
  (2, 18),
  (1, 19),
  (8, 20),
  (9, 21),
  (4, 22),
  (13, 23),
  (14, 23),
  (15, 24),
  (16, 25),
  (17, 25);


CREATE INDEX staff_salaries_index
  ON staff (worker_salary ASC);
CREATE INDEX jorneys_depature_date_index
  ON jorneys (date_depature ASC);
CREATE INDEX clients_full_name_hash_index
  ON clients USING HASH (full_name);
CREATE INDEX clients_age_index
  ON clients (client_age ASC);
CREATE INDEX clients_full_name_index
  ON clients (full_name ASC);
CREATE INDEX staff_age_index
  ON staff (worker_age ASC);
CREATE INDEX index_boats_id
  ON boats (id);
CREATE INDEX index_jorneys_id
  ON jorneys (id);
CREATE INDEX index_jorneys_dates
  ON jorneys (date_depature, date_arrive ASC);
CREATE INDEX index_staff_full_name
  ON staff (full_name ASC);
CREATE INDEX index_staff_id
  ON staff (id);
CREATE INDEX index_sb_worker_id
  ON staff_boats (worker_id);
CREATE INDEX index_sb_boat_id
  ON staff_boats (boat_id);
CREATE INDEX index_clients_id
  ON clients (id);
CREATE INDEX index_ct_client_id
  ON clients_tickets (client_id);
CREATE INDEX index_ct_ticket_id
  ON clients_tickets (ticket_id);
CREATE INDEX index_tickets_id
  ON tickets (id);
CREATE INDEX index_tickets_jorney_id
  ON tickets (jorney_id);
CREATE INDEX index_tickets_cost
  ON tickets (cost);
CREATE INDEX index_boats_name
  ON boats USING HASH (boat_name);
CREATE INDEX index_jorneys_boat_id
  ON jorneys (boat_id);
CREATE INDEX index_boats_spending
  ON boats (spending_for_a_day);
CREATE INDEX index_addresses_all
  ON addresses (id, contry, town, street);
CREATE INDEX index_staff_address
  ON staff (address);
CREATE INDEX index_clients_address
  ON clients (address);
CREATE INDEX index_staff_experience
  ON staff (number_of_worked_years);