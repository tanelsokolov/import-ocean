--
-- PostgreSQL database dump
--

-- Dumped from database version 17.2 (Ubuntu 17.2-1.pgdg22.04+1)
-- Dumped by pg_dump version 17.2 (Ubuntu 17.2-1.pgdg22.04+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: create_user_status_trigger(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.create_user_status_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO user_status (user_id, status, last_active)
    VALUES (NEW.id, 'offline', CURRENT_TIMESTAMP)
    ON CONFLICT DO NOTHING;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.create_user_status_trigger() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: chat_messages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.chat_messages (
    id character varying(255) NOT NULL,
    match_id integer,
    sender_id integer,
    content text NOT NULL,
    "timestamp" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    read boolean DEFAULT false
);


ALTER TABLE public.chat_messages OWNER TO postgres;

--
-- Name: match_preferences; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.match_preferences (
    user_id integer NOT NULL,
    priority text DEFAULT 'none'::text,
    CONSTRAINT match_preferences_priority_check CHECK ((priority = ANY (ARRAY['looking_for'::text, 'interests'::text, 'age'::text, 'none'::text])))
);


ALTER TABLE public.match_preferences OWNER TO postgres;

--
-- Name: matches; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.matches (
    id integer NOT NULL,
    user_id_1 integer,
    user_id_2 integer,
    status character varying(50) DEFAULT 'pending'::character varying,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.matches OWNER TO postgres;

--
-- Name: matches_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.matches_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.matches_id_seq OWNER TO postgres;

--
-- Name: matches_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.matches_id_seq OWNED BY public.matches.id;


--
-- Name: messages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.messages (
    id integer NOT NULL,
    match_id integer,
    sender_id integer,
    content text NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    read_at timestamp with time zone
);


ALTER TABLE public.messages OWNER TO postgres;

--
-- Name: messages_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.messages_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.messages_id_seq OWNER TO postgres;

--
-- Name: messages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.messages_id_seq OWNED BY public.messages.id;


--
-- Name: profiles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.profiles (
    user_id integer NOT NULL,
    name character varying(255) NOT NULL,
    bio text,
    interests text[] DEFAULT '{}'::text[],
    location character varying(255),
    looking_for text,
    age integer,
    occupation character varying(255),
    profile_picture_url text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.profiles OWNER TO postgres;

--
-- Name: tokens; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tokens (
    id integer NOT NULL,
    user_id integer,
    token character varying(500) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    expires_at timestamp with time zone NOT NULL
);


ALTER TABLE public.tokens OWNER TO postgres;

--
-- Name: tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tokens_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tokens_id_seq OWNER TO postgres;

--
-- Name: tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tokens_id_seq OWNED BY public.tokens.id;


--
-- Name: user_status; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_status (
    user_id integer NOT NULL,
    status character varying(20) DEFAULT 'offline'::character varying NOT NULL,
    last_active timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    last_notification_check timestamp without time zone,
    CONSTRAINT valid_status CHECK (((status)::text = ANY ((ARRAY['online'::character varying, 'offline'::character varying])::text[])))
);


ALTER TABLE public.user_status OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id integer NOT NULL,
    email character varying(255) NOT NULL,
    password_hash character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: matches id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.matches ALTER COLUMN id SET DEFAULT nextval('public.matches_id_seq'::regclass);


--
-- Name: messages id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messages ALTER COLUMN id SET DEFAULT nextval('public.messages_id_seq'::regclass);


--
-- Name: tokens id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tokens ALTER COLUMN id SET DEFAULT nextval('public.tokens_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: chat_messages; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.chat_messages (id, match_id, sender_id, content, "timestamp", read) FROM stdin;
1738399497165-0ao7610n8	1	1	tereee	2025-02-01 10:44:57.166226+02	t
1738399504229-gc01dcmun	1	1	kuidas läheb	2025-02-01 10:45:04.229774+02	t
1738399510953-yfqang8v5	1	1	hästi w	2025-02-01 10:45:10.953931+02	t
1738399516878-sylmaupst	1	2	kle suht	2025-02-01 10:45:16.879176+02	t
1738399525799-c30v4dz6d	1	2	siis ju timmis	2025-02-01 10:45:25.799793+02	t
1738399527544-imfof086m	1	2	ei w	2025-02-01 10:45:27.545513+02	t
1738399534738-yrop972yw	1	2	tundub küll	2025-02-01 10:45:34.739222+02	t
1738399655762-pqta162jd	1	2	kukkuuu	2025-02-01 10:47:35.762463+02	t
1738399660817-jkfqak9ir	1	1	no you	2025-02-01 10:47:40.817931+02	t
1738399667107-f0o5w9ddx	1	2	toiimib w	2025-02-01 10:47:47.107647+02	t
1738399685836-of9346elx	1	2	uuu	2025-02-01 10:48:05.837132+02	t
1738399688018-mz36nn929	1	2	ubububu	2025-02-01 10:48:08.019411+02	t
1738399709344-dx74f88en	1	1	lõbus w	2025-02-01 10:48:29.344703+02	t
1738399711761-ecewf4bjf	1	1	vist 	2025-02-01 10:48:31.762459+02	t
1738400339339-opw002zfq	2	4	tereee	2025-02-01 10:58:59.339954+02	t
1738400361292-dunw9xtdn	2	4	uuuu	2025-02-01 10:59:21.293536+02	t
1738400508364-w45ft7hfv	2	4	kuidas läheb	2025-02-01 11:01:48.365074+02	t
1738400513549-15vujydz1	2	4	hallo	2025-02-01 11:01:53.549655+02	t
1738400526783-kz10t21u9	2	3	mida	2025-02-01 11:02:06.784321+02	t
1738400529021-dhviiklo6	2	3	mis on	2025-02-01 11:02:09.021659+02	t
1738400540872-lywskc1zc	2	3	uu	2025-02-01 11:02:20.873+02	t
1738400544819-x1ca4j5pw	2	3	kakkaak	2025-02-01 11:02:24.819644+02	t
1738400654057-zx56mlgau	2	4	tere	2025-02-01 11:04:14.058462+02	t
1738400710218-f3t2ypf2f	3	4	teree	2025-02-01 11:05:10.219631+02	t
1738400713379-3xtnu533x	3	4	uuuuuu	2025-02-01 11:05:13.380558+02	t
1738400725075-21cdpbov0	3	4	tere	2025-02-01 11:05:25.076037+02	t
1738402075211-rg1l90l3z	3	4	abc	2025-02-01 11:27:55.212174+02	t
1738402077364-wdddg5sh2	3	4	abbaba	2025-02-01 11:27:57.364859+02	t
1738402083290-lma2zbz2w	3	4	abba	2025-02-01 11:28:03.2907+02	t
1738402084790-49kkr89oi	3	4	abab	2025-02-01 11:28:04.791237+02	t
1738402086071-g6fl5eld2	3	4	ababa	2025-02-01 11:28:06.072465+02	t
1738402087149-hdozeujck	3	4	ababa	2025-02-01 11:28:07.150594+02	t
1738402088454-cp55300ud	3	4	ababa	2025-02-01 11:28:08.454983+02	t
1738403020926-n4037c4pc	3	4	uuu	2025-02-01 11:43:40.926775+02	f
1738403024319-0sobdjm5y	3	4	teree	2025-02-01 11:43:44.3203+02	f
1738403075714-igceh0rsw	5	4	tereee	2025-02-01 11:44:35.714861+02	t
1738403965181-rps3ib9ee	5	4	a	2025-02-01 11:59:25.182522+02	t
1738403977508-abdiv1pu5	5	4	ababa	2025-02-01 11:59:37.509061+02	t
1738404391730-5fgp8y7m6	5	4	ababa	2025-02-01 12:06:31.731377+02	t
1738404394408-wjgr9rctl	5	4	abababa	2025-02-01 12:06:34.408817+02	t
1738404399070-4u8no4duf	5	4	ababbababa	2025-02-01 12:06:39.071127+02	t
1738404867848-2drr52qjh	5	4	ababa	2025-02-01 12:14:27.849499+02	t
1738404929894-d36xuwkvw	5	4	uuu	2025-02-01 12:15:29.894828+02	t
1738404932266-r0da1lpxz	5	4	asdas	2025-02-01 12:15:32.267188+02	t
1738405392377-hebjsy8r8	5	4	ababa	2025-02-01 12:23:12.377894+02	t
1738405398562-icwdm0928	5	4	abbababa	2025-02-01 12:23:18.563076+02	t
1738405443878-bevlyaoma	5	4	tereee	2025-02-01 12:24:03.879049+02	t
1738405464183-mnfb0a55p	5	4	dasdsa	2025-02-01 12:24:24.183971+02	t
1738405473048-gcusnem5t	5	4	dsadas	2025-02-01 12:24:33.048795+02	t
1738405478117-vuah7j8z6	5	4	sdadsadsa	2025-02-01 12:24:38.118149+02	t
1738405483020-ic4iqnabz	5	4	sdadsa	2025-02-01 12:24:43.021539+02	t
1738405497263-20phrkfjv	5	4	dsadsada	2025-02-01 12:24:57.264083+02	t
1738405505408-toijybx17	5	4	dsadsa	2025-02-01 12:25:05.409638+02	t
1738405518376-le9mdizof	5	4	dsadsa	2025-02-01 12:25:18.376587+02	t
1738405528366-efkbhx0ew	5	4	sdadsa	2025-02-01 12:25:28.367582+02	t
1738405534693-4dc65to4p	5	4	dsadas	2025-02-01 12:25:34.694176+02	t
1738405577678-mmsdroqqc	5	4	sdadas	2025-02-01 12:26:17.678922+02	t
1738405579660-de9sxcxpq	5	4	dsadsa	2025-02-01 12:26:19.661207+02	t
1738405720838-0h2cxxv0x	5	4	tereee	2025-02-01 12:28:40.838702+02	t
1738405730833-zodhqehra	5	4	uuuuu	2025-02-01 12:28:50.834016+02	t
1738405737794-qh327bs52	5	4	uuu	2025-02-01 12:28:57.79477+02	t
1738405746432-cpsc99c24	5	6	tea	2025-02-01 12:29:06.43358+02	t
1738405748375-imbu3fngx	5	6	tea	2025-02-01 12:29:08.375597+02	t
1738405756215-qankqy0kz	5	4	asdas	2025-02-01 12:29:16.216646+02	t
1738405760122-73u4lruux	5	4	dsadsa	2025-02-01 12:29:20.123272+02	t
1738405967578-30n4q873c	5	4	asdas	2025-02-01 12:32:47.578887+02	t
1738405968918-2xptdb1dl	5	4	asda	2025-02-01 12:32:48.919162+02	t
1738405978684-rjsn35oup	5	4	sdadas	2025-02-01 12:32:58.685549+02	f
1738493818857-whheu7rp8	1	2	tereee	2025-02-02 12:56:58.857784+02	t
1738493823564-3d2k8rqdi	1	2	uuu	2025-02-02 12:57:03.565051+02	t
1738493855882-kuaqw8ysk	1	2	kuku	2025-02-02 12:57:35.883614+02	t
1738493871125-v5klax7do	1	2	addd	2025-02-02 12:57:51.125866+02	t
1738493877738-lkztiob34	1	2	mis seis on	2025-02-02 12:57:57.738853+02	t
1738493960507-i7qdfljuw	4	1	tereee	2025-02-02 12:59:20.507919+02	f
1738494024366-igjohu61n	6	1	tereee	2025-02-02 13:00:24.366808+02	f
1738494030540-qi8mjik6u	6	1	kukuku	2025-02-02 13:00:30.541157+02	f
1738494079134-cpfletkoe	7	1	tereee	2025-02-02 13:01:19.135178+02	f
1738494086443-q7uzov075	7	1	hästi kõik v	2025-02-02 13:01:26.44371+02	f
1738494166698-6chaxm113	8	10	tereeee	2025-02-02 13:02:46.698919+02	t
1738494172487-wvfo9c9ai	8	10	korras w	2025-02-02 13:02:52.488243+02	t
1738494204838-qxq8i2gn2	8	11	on w	2025-02-02 13:03:24.839041+02	t
1738494213731-vyz7ncdk5	8	10	ma ei saa aru	2025-02-02 13:03:33.732394+02	f
\.


--
-- Data for Name: match_preferences; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.match_preferences (user_id, priority) FROM stdin;
\.


--
-- Data for Name: matches; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.matches (id, user_id_1, user_id_2, status, created_at, updated_at) FROM stdin;
1	1	2	connected	2025-02-01 10:44:22.068778+02	2025-02-01 10:44:31.532847+02
2	4	3	connected	2025-02-01 10:58:22.878528+02	2025-02-01 10:58:31.381096+02
3	5	4	connected	2025-02-01 11:04:49.486483+02	2025-02-01 11:04:53.142578+02
5	4	6	connected	2025-02-01 11:44:12.580801+02	2025-02-01 11:44:16.949004+02
4	6	1	connected	2025-02-01 11:44:09.2203+02	2025-02-02 12:58:37.931981+02
6	8	1	connected	2025-02-02 12:58:31.107496+02	2025-02-02 13:00:09.546698+02
7	9	1	connected	2025-02-02 13:01:05.750463+02	2025-02-02 13:01:10.238567+02
8	11	10	connected	2025-02-02 13:02:31.267443+02	2025-02-02 13:02:34.909809+02
\.


--
-- Data for Name: messages; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.messages (id, match_id, sender_id, content, created_at, read_at) FROM stdin;
\.


--
-- Data for Name: profiles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.profiles (user_id, name, bio, interests, location, looking_for, age, occupation, profile_picture_url, created_at, updated_at) FROM stdin;
1	a	tore säga	{Reading}	Tallinn	Friendship	22	Software Developer	http://localhost:3000/uploads/1_Pilt1.jpg	2025-02-01 10:43:02.827445+02	2025-02-01 10:43:14.723811+02
2	a1	abc	{Reading,Travel}	Tallinn	Relationship	22	Software Developer	http://localhost:3000/uploads/2_Pilt1.jpg	2025-02-01 10:43:45.572197+02	2025-02-01 10:43:45.572197+02
3	a2	a2	{Reading}	Tallinn	Friendship	22	Software Developer		2025-02-01 10:57:51.145142+02	2025-02-01 10:57:51.145142+02
4	a3	a3	{Reading}	Tallinn	Friendship	22	Software Developer		2025-02-01 10:58:12.713073+02	2025-02-01 10:58:12.713073+02
5	a4	adsa	{Reading}	Tallinn	Friendship	22	Software Developer		2025-02-01 11:04:42.467648+02	2025-02-01 11:04:42.467648+02
6	a5	a5	{Reading}	Tallinn	Friendship	22	Software Developer		2025-02-01 11:44:04.545739+02	2025-02-01 11:44:04.545739+02
8	a6	a6	{Reading}	Tallinn	Friendship	22	Software Developer		2025-02-02 12:58:26.510774+02	2025-02-02 12:58:26.510774+02
9	a7	a	{Reading}	Tallinn	Friendship	22	Software Developer		2025-02-02 13:00:59.429871+02	2025-02-02 13:00:59.429871+02
10	test1	a	{Reading}	Tartu	Friendship	22	Software Developer		2025-02-02 13:02:09.528105+02	2025-02-02 13:02:09.528105+02
11	test2	a	{Reading,Sports}	Tartu	Friendship	22	Software Developer		2025-02-02 13:02:28.077603+02	2025-02-02 13:02:28.077603+02
\.


--
-- Data for Name: tokens; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tokens (id, user_id, token, created_at, expires_at) FROM stdin;
1	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3Mzg0ODU3NjMsInVzZXJfaWQiOjF9.YsK-FBwxPEl7huPSjG1nsj0nXZo-krnDk9M-ipudFFo	2025-02-01 10:42:43.220324+02	2025-02-02 10:42:43.22488+02
2	2	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3Mzg0ODU4MDcsInVzZXJfaWQiOjJ9.6CmKhEzThEFwJDLKULoRAsOIIgP9bmNhtjmQae_nU-s	2025-02-01 10:43:27.570096+02	2025-02-02 10:43:27.571063+02
3	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3Mzg0ODYwODMsInVzZXJfaWQiOjF9.nKoZNnPxaf7vNttsy2VUmOJibKXvP5u5o1k-fH7hwU4	2025-02-01 10:48:03.173107+02	2025-02-02 10:48:03.173283+02
4	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3Mzg0ODYwOTksInVzZXJfaWQiOjF9._ZMZlniLyqAGYRZ4-uPIKdHmKieaDBgWMe07xE1LP4Y	2025-02-01 10:48:19.824916+02	2025-02-02 10:48:19.825123+02
5	2	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3Mzg0ODYxMDMsInVzZXJfaWQiOjJ9.QumufFDxpYPUGeO5t_fuVemArBRb0n6Izm0CgoaaHks	2025-02-01 10:48:23.373123+02	2025-02-02 10:48:23.373268+02
6	3	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3Mzg0ODY2NjAsInVzZXJfaWQiOjN9.w8IiTg4dmQo9uKMC8QUlHuP6SCAa7TX-TOqRKmoyRrs	2025-02-01 10:57:40.52766+02	2025-02-02 10:57:40.529404+02
7	4	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3Mzg0ODY2ODAsInVzZXJfaWQiOjR9.eImO1QwTG6pr1IpgtjTgQUyvJgN4cl7Xo4emDQXrGGI	2025-02-01 10:58:00.566949+02	2025-02-02 10:58:00.567862+02
8	5	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3Mzg0ODcwNjksInVzZXJfaWQiOjV9.u7yS4qnB4IWxzccuPs3N_cQdZhFXNyAskuR3WfAwnmE	2025-02-01 11:04:29.058009+02	2025-02-02 11:04:29.059621+02
9	6	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3Mzg0ODk0MzEsInVzZXJfaWQiOjZ9.37UxpkXK6WSmEIonvcKh1XdOc1epM4i_ISzFaGu_AKQ	2025-02-01 11:43:51.655038+02	2025-02-02 11:43:51.656695+02
10	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3Mzg1Nzk5NDksInVzZXJfaWQiOjF9.O8T5_kA1R3Egyk5ogcW7O7WhfgENUoKZhPboIYi7POE	2025-02-02 12:52:29.99043+02	2025-02-03 12:52:29.990585+02
11	2	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3Mzg1ODAyMTMsInVzZXJfaWQiOjJ9.jPj53PLExm2BIAkDMcTk0Y6HR72HRqCq77yoBDCbexQ	2025-02-02 12:56:53.138+02	2025-02-03 12:56:53.138161+02
12	1	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3Mzg1ODAyNDUsInVzZXJfaWQiOjF9.zL1BqUjt82B9FSZNGL21SxxWufeLrhgH0G5DgEb6br4	2025-02-02 12:57:25.909357+02	2025-02-03 12:57:25.909519+02
13	2	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3Mzg1ODAyNTEsInVzZXJfaWQiOjJ9.TDMI-RZQPCbQCGIiYK2PdKcoDOkaLvtP-AZXDlYq1DA	2025-02-02 12:57:31.498065+02	2025-02-03 12:57:31.498213+02
14	8	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3Mzg1ODAyOTYsInVzZXJfaWQiOjh9.VhslTLmR3bvbuWaV6hvQuGMNM6Ect2W3oqmh7L0Tfqw	2025-02-02 12:58:16.029413+02	2025-02-03 12:58:16.031278+02
15	9	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3Mzg1ODA0NDksInVzZXJfaWQiOjl9.67-2YbWH1Ig8iz40lkV41XTjvDg3z7ToloiGdLP1SLw	2025-02-02 13:00:49.289125+02	2025-02-03 13:00:49.291144+02
16	10	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3Mzg1ODA1MTQsInVzZXJfaWQiOjEwfQ.LFvQK46KbmQh50g1wu4Se4cNQlcJvbAbJipJ8avKKgU	2025-02-02 13:01:54.721382+02	2025-02-03 13:01:54.723095+02
17	11	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3Mzg1ODA1MzYsInVzZXJfaWQiOjExfQ.pNOdrVTOhlZV1ck_--3bD-l2BURsFJT2ttUQ2t2lNQo	2025-02-02 13:02:16.180243+02	2025-02-03 13:02:16.181114+02
\.


--
-- Data for Name: user_status; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_status (user_id, status, last_active, last_notification_check) FROM stdin;
10	offline	2025-02-02 13:03:40.981524+02	2025-02-02 13:02:41.316465
11	offline	2025-02-02 13:03:35.132286+02	2025-02-02 13:03:21.726335
4	offline	2025-02-01 12:33:33.148079+02	2025-02-01 11:44:31.579326
6	offline	2025-02-01 12:33:33.167415+02	2025-02-01 12:32:50.997859
8	offline	2025-02-02 13:00:36.451122+02	2025-02-02 12:59:53.373786
2	offline	2025-02-02 12:58:02.42113+02	2025-02-02 12:57:33.169496
9	offline	2025-02-02 13:01:27.822428+02	\N
1	offline	2025-02-02 13:01:39.101229+02	2025-02-02 13:01:13.468485
3	offline	2025-02-01 11:04:24.003741+02	2025-02-01 11:04:18.179979
5	offline	2025-02-01 11:43:44.352598+02	2025-02-01 11:28:12.430743
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, email, password_hash, created_at) FROM stdin;
1	a@a.a	$2a$10$gYNkdyIFOyfwzQBXWXSV..CQNPhwDXyCG3Wkep9QFiVKo55MGN1d6	2025-02-01 10:42:43.220324+02
2	a1@a.a	$2a$10$lf3ywXA4gVl0C.yzX1uK.utL5OM3GpYktMh7H23PQHyx7bSzphkay	2025-02-01 10:43:27.570096+02
3	a2@a.a	$2a$10$bUVXITU9Yk5yOZv4sSLw2eHsy3z44M.P51B.raXsQ7wfmtZ5TojI6	2025-02-01 10:57:40.52766+02
4	a3@a.a	$2a$10$tKTBN1/M9QzQMaikZUGe2eGtukKKFGVOzPVhpVJzXyw2Of/UiyOO6	2025-02-01 10:58:00.566949+02
5	a4@a.a	$2a$10$dF9RuXoE.pjA.mvUWNNxwOZSqFf6fegIOf48nTCNPUIthCcnAU3aa	2025-02-01 11:04:29.058009+02
6	a5@a.a	$2a$10$n5lVsdDug348qlgEAkaeL.NQ3tH/4RZNlNE0vv9am2lEcSe1pAuo6	2025-02-01 11:43:51.655038+02
8	a6@a.a	$2a$10$Nuqzn32CDzedVaSEipSMaO6Ieftu6qwbfRy/QayWgrc4wPzfZ9Df.	2025-02-02 12:58:16.029413+02
9	a7@a.a	$2a$10$JMP1VSawCFRLL99tqsn8K.SaVpuyTShjYrcTPK2Nt.6uC73rZeHia	2025-02-02 13:00:49.289125+02
10	test1@a.a	$2a$10$vue8frPI8YdjeJtG.tNWMuT4q3vyKUbjpi9iQbT9P7soUZ0KvVlZC	2025-02-02 13:01:54.721382+02
11	test2@a.a	$2a$10$BSY9WEun2iGA/TBQO/yS8ujn13SwxOLDbWt5pQnsryqSIQdEcDZ8u	2025-02-02 13:02:16.180243+02
\.


--
-- Name: matches_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.matches_id_seq', 8, true);


--
-- Name: messages_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.messages_id_seq', 1, false);


--
-- Name: tokens_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tokens_id_seq', 17, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 11, true);


--
-- Name: chat_messages chat_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_messages
    ADD CONSTRAINT chat_messages_pkey PRIMARY KEY (id);


--
-- Name: match_preferences match_preferences_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.match_preferences
    ADD CONSTRAINT match_preferences_pkey PRIMARY KEY (user_id);


--
-- Name: matches matches_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.matches
    ADD CONSTRAINT matches_pkey PRIMARY KEY (id);


--
-- Name: matches matches_user_id_1_user_id_2_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.matches
    ADD CONSTRAINT matches_user_id_1_user_id_2_key UNIQUE (user_id_1, user_id_2);


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id);


--
-- Name: profiles profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_pkey PRIMARY KEY (user_id);


--
-- Name: tokens tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tokens
    ADD CONSTRAINT tokens_pkey PRIMARY KEY (id);


--
-- Name: user_status user_status_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_status
    ADD CONSTRAINT user_status_pkey PRIMARY KEY (user_id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: idx_chat_messages_match; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_chat_messages_match ON public.chat_messages USING btree (match_id);


--
-- Name: idx_chat_messages_sender; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_chat_messages_sender ON public.chat_messages USING btree (sender_id);


--
-- Name: idx_matches_users; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_matches_users ON public.matches USING btree (user_id_1, user_id_2);


--
-- Name: idx_messages_match; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_messages_match ON public.messages USING btree (match_id);


--
-- Name: idx_messages_sender; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_messages_sender ON public.messages USING btree (sender_id);


--
-- Name: idx_profiles_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_profiles_user_id ON public.profiles USING btree (user_id);


--
-- Name: idx_tokens_token; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tokens_token ON public.tokens USING btree (token);


--
-- Name: idx_tokens_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tokens_user ON public.tokens USING btree (user_id);


--
-- Name: idx_user_status_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_status_user ON public.user_status USING btree (user_id);


--
-- Name: users user_status_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER user_status_trigger AFTER INSERT ON public.users FOR EACH ROW EXECUTE FUNCTION public.create_user_status_trigger();


--
-- Name: chat_messages chat_messages_match_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_messages
    ADD CONSTRAINT chat_messages_match_id_fkey FOREIGN KEY (match_id) REFERENCES public.matches(id);


--
-- Name: chat_messages chat_messages_sender_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_messages
    ADD CONSTRAINT chat_messages_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES public.users(id);


--
-- Name: match_preferences match_preferences_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.match_preferences
    ADD CONSTRAINT match_preferences_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: matches matches_user_id_1_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.matches
    ADD CONSTRAINT matches_user_id_1_fkey FOREIGN KEY (user_id_1) REFERENCES public.users(id);


--
-- Name: matches matches_user_id_2_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.matches
    ADD CONSTRAINT matches_user_id_2_fkey FOREIGN KEY (user_id_2) REFERENCES public.users(id);


--
-- Name: messages messages_match_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_match_id_fkey FOREIGN KEY (match_id) REFERENCES public.matches(id);


--
-- Name: messages messages_sender_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES public.users(id);


--
-- Name: profiles profiles_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: tokens tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tokens
    ADD CONSTRAINT tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: user_status user_status_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_status
    ADD CONSTRAINT user_status_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- PostgreSQL database dump complete
--

