--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.5
-- Dumped by pg_dump version 9.6.5

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- Name: pasport_number; Type: DOMAIN; Schema: public; Owner: korwin
--

CREATE DOMAIN pasport_number AS text
	CONSTRAINT pasport_number_check CHECK (((VALUE ~ '^[0-9[:space:]]+$'::text) AND (octet_length(btrim(VALUE)) > 7) AND (octet_length(VALUE) < 20)));


ALTER DOMAIN pasport_number OWNER TO korwin;

--
-- Name: phone_number; Type: DOMAIN; Schema: public; Owner: korwin
--

CREATE DOMAIN phone_number AS text
	CONSTRAINT phone_number_check CHECK (((VALUE IS NULL) OR ((VALUE ~ '^[0-9+-.\(\)[:space:]]+$'::text) AND (octet_length(btrim(VALUE)) > 5) AND (octet_length(VALUE) < 30))));


ALTER DOMAIN phone_number OWNER TO korwin;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: addresses; Type: TABLE; Schema: public; Owner: korwin
--

CREATE TABLE addresses (
    id integer NOT NULL,
    contry text NOT NULL,
    town text NOT NULL,
    street text NOT NULL,
    CONSTRAINT check_is_valid_string_contry CHECK (((octet_length(btrim(contry)) > 1) AND (contry ~ '^[A-Za-z[:space:]-]+$'::text) AND (length(contry) < 100))),
    CONSTRAINT check_is_valid_string_street CHECK (((octet_length(btrim(street)) > 1) AND (contry ~ '^[A-Za-z[:space:]-]+$'::text) AND (length(street) < 100))),
    CONSTRAINT check_is_valid_string_town CHECK (((octet_length(btrim(town)) > 1) AND (town ~ '^[A-Za-z[:space:]-]+$'::text) AND (length(town) < 100)))
);


ALTER TABLE addresses OWNER TO korwin;

--
-- Name: addresses_id_seq; Type: SEQUENCE; Schema: public; Owner: korwin
--

CREATE SEQUENCE addresses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE addresses_id_seq OWNER TO korwin;

--
-- Name: addresses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: korwin
--

ALTER SEQUENCE addresses_id_seq OWNED BY addresses.id;


--
-- Name: boats; Type: TABLE; Schema: public; Owner: korwin
--

CREATE TABLE boats (
    id integer NOT NULL,
    boat_name text NOT NULL,
    number_of_landing_sites integer NOT NULL,
    spending_for_a_day integer NOT NULL,
    CONSTRAINT check_is_valid_string_boat_name CHECK (((octet_length(ltrim(boat_name)) > 1) AND (boat_name ~ '^[A-Za-z0-9+[:space:]-]+$'::text))),
    CONSTRAINT check_positive_number_of_landing_sites CHECK ((number_of_landing_sites > 0)),
    CONSTRAINT check_positive_spending_for_a_day CHECK ((spending_for_a_day > 0))
);


ALTER TABLE boats OWNER TO korwin;

--
-- Name: boats_id_seq; Type: SEQUENCE; Schema: public; Owner: korwin
--

CREATE SEQUENCE boats_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE boats_id_seq OWNER TO korwin;

--
-- Name: boats_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: korwin
--

ALTER SEQUENCE boats_id_seq OWNED BY boats.id;


--
-- Name: clients; Type: TABLE; Schema: public; Owner: korwin
--

CREATE TABLE clients (
    id integer NOT NULL,
    full_name text NOT NULL,
    client_age integer,
    phone_number phone_number,
    pasport_number pasport_number NOT NULL,
    address integer,
    CONSTRAINT check_is_positive_client_age CHECK (((client_age > 0) OR (client_age IS NULL))),
    CONSTRAINT check_is_valid_string_full_name CHECK (((octet_length(btrim(full_name)) > 1) AND (full_name ~ '^[A-Za-z[:space:]-]+$'::text)))
);


ALTER TABLE clients OWNER TO korwin;

--
-- Name: clients_id_seq; Type: SEQUENCE; Schema: public; Owner: korwin
--

CREATE SEQUENCE clients_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE clients_id_seq OWNER TO korwin;

--
-- Name: clients_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: korwin
--

ALTER SEQUENCE clients_id_seq OWNED BY clients.id;


--
-- Name: clients_tickets; Type: TABLE; Schema: public; Owner: korwin
--

CREATE TABLE clients_tickets (
    client_id integer NOT NULL,
    ticket_id integer NOT NULL
);


ALTER TABLE clients_tickets OWNER TO korwin;

--
-- Name: jorneys; Type: TABLE; Schema: public; Owner: korwin
--

CREATE TABLE jorneys (
    id integer NOT NULL,
    boat_id integer NOT NULL,
    date_depature date NOT NULL,
    date_arrive date NOT NULL,
    city_depature text NOT NULL,
    city_arrive text NOT NULL,
    CONSTRAINT check_is_valid_date_order CHECK ((date_depature <= date_depature)),
    CONSTRAINT check_is_valid_string_city_arrrive CHECK (((octet_length(btrim(city_arrive)) > 1) AND (city_arrive ~ '^[A-Za-z[:space:]-]+$'::text) AND (length(city_arrive) < 100))),
    CONSTRAINT check_is_valid_string_city_depature CHECK (((octet_length(btrim(city_depature)) > 1) AND (city_depature ~ '^[A-Za-z[:space:]-]+$'::text) AND (length(city_depature) < 100)))
);


ALTER TABLE jorneys OWNER TO korwin;

--
-- Name: jorneys_id_seq; Type: SEQUENCE; Schema: public; Owner: korwin
--

CREATE SEQUENCE jorneys_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE jorneys_id_seq OWNER TO korwin;

--
-- Name: jorneys_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: korwin
--

ALTER SEQUENCE jorneys_id_seq OWNED BY jorneys.id;


--
-- Name: staff; Type: TABLE; Schema: public; Owner: korwin
--

CREATE TABLE staff (
    id integer NOT NULL,
    full_name text NOT NULL,
    phone_number phone_number NOT NULL,
    pasport_number pasport_number NOT NULL,
    number_of_worked_years integer NOT NULL,
    worker_age integer NOT NULL,
    worker_salary integer,
    address integer NOT NULL,
    CONSTRAINT check_is_valid_string_full_name CHECK (((octet_length(btrim(full_name)) > 1) AND (full_name ~ '^[A-Za-z[:space:]]+$'::text))),
    CONSTRAINT check_legal_age_to_work CHECK ((worker_age > 15)),
    CONSTRAINT check_legal_work CHECK ((number_of_worked_years < (worker_age - 16))),
    CONSTRAINT check_positive_number_of_worked_years CHECK ((number_of_worked_years > '-1'::integer)),
    CONSTRAINT check_positive_worker_age CHECK ((worker_age > 0)),
    CONSTRAINT check_positive_worker_salary CHECK ((worker_salary > 0))
);


ALTER TABLE staff OWNER TO korwin;

--
-- Name: staff_boats; Type: TABLE; Schema: public; Owner: korwin
--

CREATE TABLE staff_boats (
    boat_id integer NOT NULL,
    worker_id integer NOT NULL
);


ALTER TABLE staff_boats OWNER TO korwin;

--
-- Name: staff_id_seq; Type: SEQUENCE; Schema: public; Owner: korwin
--

CREATE SEQUENCE staff_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE staff_id_seq OWNER TO korwin;

--
-- Name: staff_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: korwin
--

ALTER SEQUENCE staff_id_seq OWNED BY staff.id;


--
-- Name: tickets; Type: TABLE; Schema: public; Owner: korwin
--

CREATE TABLE tickets (
    id integer NOT NULL,
    jorney_id integer NOT NULL,
    cost integer NOT NULL,
    cabin_number integer NOT NULL,
    ticket_class integer NOT NULL,
    CONSTRAINT check_is_positive_cabin_number CHECK ((cabin_number > 0)),
    CONSTRAINT check_is_positive_cost CHECK ((cost > 0)),
    CONSTRAINT check_is_valid_ticket_class CHECK (((ticket_class > 0) AND (ticket_class < 4)))
);


ALTER TABLE tickets OWNER TO korwin;

--
-- Name: tickets_id_seq; Type: SEQUENCE; Schema: public; Owner: korwin
--

CREATE SEQUENCE tickets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE tickets_id_seq OWNER TO korwin;

--
-- Name: tickets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: korwin
--

ALTER SEQUENCE tickets_id_seq OWNED BY tickets.id;


--
-- Name: addresses id; Type: DEFAULT; Schema: public; Owner: korwin
--

ALTER TABLE ONLY addresses ALTER COLUMN id SET DEFAULT nextval('addresses_id_seq'::regclass);


--
-- Name: boats id; Type: DEFAULT; Schema: public; Owner: korwin
--

ALTER TABLE ONLY boats ALTER COLUMN id SET DEFAULT nextval('boats_id_seq'::regclass);


--
-- Name: clients id; Type: DEFAULT; Schema: public; Owner: korwin
--

ALTER TABLE ONLY clients ALTER COLUMN id SET DEFAULT nextval('clients_id_seq'::regclass);


--
-- Name: jorneys id; Type: DEFAULT; Schema: public; Owner: korwin
--

ALTER TABLE ONLY jorneys ALTER COLUMN id SET DEFAULT nextval('jorneys_id_seq'::regclass);


--
-- Name: staff id; Type: DEFAULT; Schema: public; Owner: korwin
--

ALTER TABLE ONLY staff ALTER COLUMN id SET DEFAULT nextval('staff_id_seq'::regclass);


--
-- Name: tickets id; Type: DEFAULT; Schema: public; Owner: korwin
--

ALTER TABLE ONLY tickets ALTER COLUMN id SET DEFAULT nextval('tickets_id_seq'::regclass);


--
-- Data for Name: addresses; Type: TABLE DATA; Schema: public; Owner: korwin
--

COPY addresses (id, contry, town, street) FROM stdin;
1	Russia	Petergoth	Chicherinskay
2	Russia	Piter	Nevsky Prospect
3	Russia	Moskva	Red Square
4	Russia	Murmansk	Stalina
5	Russia	Piter	Lenina
6	USA	Boston	Vinstons
7	Astrulia	Sydney	Lenina
8	UK	London	Green
9	Moon	Rain	Kotyt
10	Russia	Petergoth	Botanichescay
\.


--
-- Name: addresses_id_seq; Type: SEQUENCE SET; Schema: public; Owner: korwin
--

SELECT pg_catalog.setval('addresses_id_seq', 10, true);


--
-- Data for Name: boats; Type: TABLE DATA; Schema: public; Owner: korwin
--

COPY boats (id, boat_name, number_of_landing_sites, spending_for_a_day) FROM stdin;
1	Petrovich	5	400
2	Titanic	4	320
3	Rudi	2	160
4	Dolores	2	160
5	Cheloveck-Parahod	1	110
6	IronMan	2	200
7	IRA	1	80
8	LeNiN	2	210
9	C++	1	130
\.


--
-- Name: boats_id_seq; Type: SEQUENCE SET; Schema: public; Owner: korwin
--

SELECT pg_catalog.setval('boats_id_seq', 9, true);


--
-- Data for Name: clients; Type: TABLE DATA; Schema: public; Owner: korwin
--

COPY clients (id, full_name, client_age, phone_number, pasport_number, address) FROM stdin;
1	Wiliam Sheksper	47	+799999999	56789034	10
2	Leonard Snowden	67	+798475879	83578957	9
3	Jordan Bush	79	+743568788	32547230	8
4	Iogan Kepler	34	+704959374	74558738	7
5	Galileo Galiley	23	+798357949	09450934	6
6	Vladimir Putin 	62	+000000000	00000000	3
7	Rodion Raskolnikov	56	+789357483	62487548	7
8	Homa Homa	12	+787564768	32654984	4
9	Lolipo Android	45	+773578334	78563875	10
10	Leonard Snow	89	+743578945	52872117	4
11	Fixik Pixik	23	+712738343	47593793	2
12	Help Me	34	+798573573	45739540	1
13	Martin Lenon	23	\N	59673546	\N
14	Merry Lenon	\N	\N	69481637	\N
15	Ostin Jeck	45	893747236	69786235	4
16	Din Kihot	67	\N	38956785	5
17	Lina Kihot	66	\N	45789213	\N
\.


--
-- Name: clients_id_seq; Type: SEQUENCE SET; Schema: public; Owner: korwin
--

SELECT pg_catalog.setval('clients_id_seq', 17, true);


--
-- Data for Name: clients_tickets; Type: TABLE DATA; Schema: public; Owner: korwin
--

COPY clients_tickets (client_id, ticket_id) FROM stdin;
1	1
2	2
3	3
4	4
5	5
6	6
7	7
8	8
9	9
1	10
7	11
5	12
6	13
10	14
11	15
12	16
1	17
2	18
1	19
8	20
9	21
4	22
13	23
14	23
15	24
16	25
17	25
\.


--
-- Data for Name: jorneys; Type: TABLE DATA; Schema: public; Owner: korwin
--

COPY jorneys (id, boat_id, date_depature, date_arrive, city_depature, city_arrive) FROM stdin;
1	1	2017-10-02	2018-01-12	London	Paris
2	2	2017-12-31	2018-01-01	Laplandia	all world
3	3	2017-09-01	2017-09-15	Piter	Moskva
4	4	2018-02-01	2018-03-01	Tagil	Gelengick
5	1	2018-04-18	2018-06-17	London	New-York
6	3	2018-08-01	2018-08-10	Barselona	Barselona
7	4	2018-06-01	2018-08-31	Yamaika	Gelengick
8	6	2017-12-31	2018-12-31	St-Petersburg	Moskva
9	7	2018-03-30	2018-04-02	Minsk	Paris
10	8	2018-05-05	2019-06-06	Tokio	New-York
\.


--
-- Name: jorneys_id_seq; Type: SEQUENCE SET; Schema: public; Owner: korwin
--

SELECT pg_catalog.setval('jorneys_id_seq', 10, true);


--
-- Data for Name: staff; Type: TABLE DATA; Schema: public; Owner: korwin
--

COPY staff (id, full_name, phone_number, pasport_number, number_of_worked_years, worker_age, worker_salary, address) FROM stdin;
1	Gans Hristian Anderson	+799999999	56789034	4	27	100	1
2	Frederic Lorigin Rouse	+799945754	56387454	7	38	150	2
3	Brian Kokel Shane	+799834654	83745634	1	23	60	5
4	Fred Bright Start	+799234673	18236334	17	56	23	1
5	Grock Harrison Loddy	+799934845	92175743	3	33	90	7
6	Ivan Ivanov Ivanovich	+799923654	38745665	100	200	500	2
7	Ludvig Bethoven Drousil	+791299967	56773394	9	37	173	9
8	Drenden Droun Drang	+796633999	57788224	12	32	207	6
9	Fiona Filly Fon	+799399009	83745689	4	43	100	4
10	Dolchy Gabana	+7943765679	38475678	23	60	325	5
11	Pushkin Alex	753845	76458923	4	34	100	2
12	London Jeck	8911674583	32548273	17	45	269	8
13	Rembo Rembo	+7734638883	87650345	2	26	80	6
14	Timur Slima	8947567246	28635564	1	56	61	1
15	Kek Cheburek	0202020301	34876893	0	23	12	2
\.


--
-- Data for Name: staff_boats; Type: TABLE DATA; Schema: public; Owner: korwin
--

COPY staff_boats (boat_id, worker_id) FROM stdin;
1	1
1	2
1	3
1	4
2	5
2	6
2	7
2	8
3	2
3	9
4	6
4	10
5	11
6	12
6	11
7	13
8	15
8	14
9	15
\.


--
-- Name: staff_id_seq; Type: SEQUENCE SET; Schema: public; Owner: korwin
--

SELECT pg_catalog.setval('staff_id_seq', 15, true);


--
-- Data for Name: tickets; Type: TABLE DATA; Schema: public; Owner: korwin
--

COPY tickets (id, jorney_id, cost, cabin_number, ticket_class) FROM stdin;
1	1	1700	1	2
2	1	1700	2	2
3	1	1700	3	2
4	1	3400	4	3
5	1	3450	5	1
6	2	20000	1	2
7	2	20000	2	2
8	2	100000	3	1
9	2	100000	4	1
10	3	1300	1	2
11	3	1300	2	2
12	4	2000	1	2
13	4	2000	2	2
14	5	1900	1	2
15	5	1900	2	2
16	5	1900	3	2
17	5	3800	4	3
18	5	4000	5	1
19	6	400	1	2
20	6	400	2	2
21	7	70000	1	2
22	7	70000	2	2
23	8	200000	1	1
24	9	200	1	3
25	10	10000	1	2
\.


--
-- Name: tickets_id_seq; Type: SEQUENCE SET; Schema: public; Owner: korwin
--

SELECT pg_catalog.setval('tickets_id_seq', 25, true);


--
-- Name: addresses addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: korwin
--

ALTER TABLE ONLY addresses
    ADD CONSTRAINT addresses_pkey PRIMARY KEY (id);


--
-- Name: boats boats_pkey; Type: CONSTRAINT; Schema: public; Owner: korwin
--

ALTER TABLE ONLY boats
    ADD CONSTRAINT boats_pkey PRIMARY KEY (id);


--
-- Name: clients clients_pasport_number_key; Type: CONSTRAINT; Schema: public; Owner: korwin
--

ALTER TABLE ONLY clients
    ADD CONSTRAINT clients_pasport_number_key UNIQUE (pasport_number);


--
-- Name: clients clients_pkey; Type: CONSTRAINT; Schema: public; Owner: korwin
--

ALTER TABLE ONLY clients
    ADD CONSTRAINT clients_pkey PRIMARY KEY (id);


--
-- Name: clients_tickets clients_tickets_pkey; Type: CONSTRAINT; Schema: public; Owner: korwin
--

ALTER TABLE ONLY clients_tickets
    ADD CONSTRAINT clients_tickets_pkey PRIMARY KEY (client_id, ticket_id);


--
-- Name: jorneys jorneys_pkey; Type: CONSTRAINT; Schema: public; Owner: korwin
--

ALTER TABLE ONLY jorneys
    ADD CONSTRAINT jorneys_pkey PRIMARY KEY (id);


--
-- Name: staff_boats staff_boats_pkey; Type: CONSTRAINT; Schema: public; Owner: korwin
--

ALTER TABLE ONLY staff_boats
    ADD CONSTRAINT staff_boats_pkey PRIMARY KEY (boat_id, worker_id);


--
-- Name: staff staff_pasport_number_key; Type: CONSTRAINT; Schema: public; Owner: korwin
--

ALTER TABLE ONLY staff
    ADD CONSTRAINT staff_pasport_number_key UNIQUE (pasport_number);


--
-- Name: staff staff_phone_number_key; Type: CONSTRAINT; Schema: public; Owner: korwin
--

ALTER TABLE ONLY staff
    ADD CONSTRAINT staff_phone_number_key UNIQUE (phone_number);


--
-- Name: staff staff_pkey; Type: CONSTRAINT; Schema: public; Owner: korwin
--

ALTER TABLE ONLY staff
    ADD CONSTRAINT staff_pkey PRIMARY KEY (id);


--
-- Name: tickets tickets_pkey; Type: CONSTRAINT; Schema: public; Owner: korwin
--

ALTER TABLE ONLY tickets
    ADD CONSTRAINT tickets_pkey PRIMARY KEY (id);


--
-- Name: clients_age_index; Type: INDEX; Schema: public; Owner: korwin
--

CREATE INDEX clients_age_index ON clients USING btree (client_age);


--
-- Name: clients_full_name_hash_index; Type: INDEX; Schema: public; Owner: korwin
--

CREATE INDEX clients_full_name_hash_index ON clients USING hash (full_name);


--
-- Name: clients_full_name_index; Type: INDEX; Schema: public; Owner: korwin
--

CREATE INDEX clients_full_name_index ON clients USING btree (full_name);


--
-- Name: clients_phone_unique_index; Type: INDEX; Schema: public; Owner: korwin
--

CREATE UNIQUE INDEX clients_phone_unique_index ON clients USING btree (phone_number) WHERE (phone_number IS NOT NULL);


--
-- Name: index_addresses_all; Type: INDEX; Schema: public; Owner: korwin
--

CREATE INDEX index_addresses_all ON addresses USING btree (id, contry, town, street);


--
-- Name: index_boats_id; Type: INDEX; Schema: public; Owner: korwin
--

CREATE INDEX index_boats_id ON boats USING btree (id);


--
-- Name: index_boats_name; Type: INDEX; Schema: public; Owner: korwin
--

CREATE INDEX index_boats_name ON boats USING hash (boat_name);


--
-- Name: index_boats_spending; Type: INDEX; Schema: public; Owner: korwin
--

CREATE INDEX index_boats_spending ON boats USING btree (spending_for_a_day);


--
-- Name: index_clients_address; Type: INDEX; Schema: public; Owner: korwin
--

CREATE INDEX index_clients_address ON clients USING btree (address);


--
-- Name: index_clients_id; Type: INDEX; Schema: public; Owner: korwin
--

CREATE INDEX index_clients_id ON clients USING btree (id);


--
-- Name: index_ct_client_id; Type: INDEX; Schema: public; Owner: korwin
--

CREATE INDEX index_ct_client_id ON clients_tickets USING btree (client_id);


--
-- Name: index_ct_ticket_id; Type: INDEX; Schema: public; Owner: korwin
--

CREATE INDEX index_ct_ticket_id ON clients_tickets USING btree (ticket_id);


--
-- Name: index_jorneys_boat_id; Type: INDEX; Schema: public; Owner: korwin
--

CREATE INDEX index_jorneys_boat_id ON jorneys USING btree (boat_id);


--
-- Name: index_jorneys_dates; Type: INDEX; Schema: public; Owner: korwin
--

CREATE INDEX index_jorneys_dates ON jorneys USING btree (date_depature, date_arrive);


--
-- Name: index_jorneys_id; Type: INDEX; Schema: public; Owner: korwin
--

CREATE INDEX index_jorneys_id ON jorneys USING btree (id);


--
-- Name: index_sb_boat_id; Type: INDEX; Schema: public; Owner: korwin
--

CREATE INDEX index_sb_boat_id ON staff_boats USING btree (boat_id);


--
-- Name: index_sb_worker_id; Type: INDEX; Schema: public; Owner: korwin
--

CREATE INDEX index_sb_worker_id ON staff_boats USING btree (worker_id);


--
-- Name: index_staff_address; Type: INDEX; Schema: public; Owner: korwin
--

CREATE INDEX index_staff_address ON staff USING btree (address);


--
-- Name: index_staff_experience; Type: INDEX; Schema: public; Owner: korwin
--

CREATE INDEX index_staff_experience ON staff USING btree (number_of_worked_years);


--
-- Name: index_staff_full_name; Type: INDEX; Schema: public; Owner: korwin
--

CREATE INDEX index_staff_full_name ON staff USING btree (full_name);


--
-- Name: index_staff_id; Type: INDEX; Schema: public; Owner: korwin
--

CREATE INDEX index_staff_id ON staff USING btree (id);


--
-- Name: index_tickets_cost; Type: INDEX; Schema: public; Owner: korwin
--

CREATE INDEX index_tickets_cost ON tickets USING btree (cost);


--
-- Name: index_tickets_id; Type: INDEX; Schema: public; Owner: korwin
--

CREATE INDEX index_tickets_id ON tickets USING btree (id);


--
-- Name: index_tickets_jorney_id; Type: INDEX; Schema: public; Owner: korwin
--

CREATE INDEX index_tickets_jorney_id ON tickets USING btree (jorney_id);


--
-- Name: jorneys_depature_date_index; Type: INDEX; Schema: public; Owner: korwin
--

CREATE INDEX jorneys_depature_date_index ON jorneys USING btree (date_depature);


--
-- Name: staff_age_index; Type: INDEX; Schema: public; Owner: korwin
--

CREATE INDEX staff_age_index ON staff USING btree (worker_age);


--
-- Name: staff_salaries_index; Type: INDEX; Schema: public; Owner: korwin
--

CREATE INDEX staff_salaries_index ON staff USING btree (worker_salary);


--
-- Name: clients clients_address_fkey; Type: FK CONSTRAINT; Schema: public; Owner: korwin
--

ALTER TABLE ONLY clients
    ADD CONSTRAINT clients_address_fkey FOREIGN KEY (address) REFERENCES addresses(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: clients_tickets clients_tickets_client_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: korwin
--

ALTER TABLE ONLY clients_tickets
    ADD CONSTRAINT clients_tickets_client_id_fkey FOREIGN KEY (client_id) REFERENCES clients(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: clients_tickets clients_tickets_ticket_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: korwin
--

ALTER TABLE ONLY clients_tickets
    ADD CONSTRAINT clients_tickets_ticket_id_fkey FOREIGN KEY (ticket_id) REFERENCES tickets(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: jorneys jorneys_boat_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: korwin
--

ALTER TABLE ONLY jorneys
    ADD CONSTRAINT jorneys_boat_id_fkey FOREIGN KEY (boat_id) REFERENCES boats(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: staff staff_address_fkey; Type: FK CONSTRAINT; Schema: public; Owner: korwin
--

ALTER TABLE ONLY staff
    ADD CONSTRAINT staff_address_fkey FOREIGN KEY (address) REFERENCES addresses(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: staff_boats staff_boats_boat_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: korwin
--

ALTER TABLE ONLY staff_boats
    ADD CONSTRAINT staff_boats_boat_id_fkey FOREIGN KEY (boat_id) REFERENCES boats(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: staff_boats staff_boats_worker_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: korwin
--

ALTER TABLE ONLY staff_boats
    ADD CONSTRAINT staff_boats_worker_id_fkey FOREIGN KEY (worker_id) REFERENCES staff(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: tickets tickets_jorney_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: korwin
--

ALTER TABLE ONLY tickets
    ADD CONSTRAINT tickets_jorney_id_fkey FOREIGN KEY (jorney_id) REFERENCES jorneys(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

