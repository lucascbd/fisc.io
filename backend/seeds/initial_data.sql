--
-- PostgreSQL database dump
--

\restrict j83iiJ2rWcZEGSuCRxCc42pWWAYEQ8ze395iozvIkxxk2DxUjHek1J3JPJi3kD4

-- Dumped from database version 17.9 (Debian 17.9-0+deb13u1)
-- Dumped by pg_dump version 17.9 (Debian 17.9-0+deb13u1)

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: categories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.categories (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    icon character varying(50),
    color character varying(7) DEFAULT '#999999'::character varying,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    display_order integer DEFAULT 0,
    ipca_category_code integer,
    ipca_category_name text
);


ALTER TABLE public.categories OWNER TO postgres;

--
-- Name: categories_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.categories_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.categories_id_seq OWNER TO postgres;

--
-- Name: categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.categories_id_seq OWNED BY public.categories.id;


--
-- Name: ipca; Type: TABLE; Schema: public; Owner: budget_user
--

CREATE TABLE public.ipca (
    "NC" integer,
    "NN" text,
    "MC" integer,
    "MN" text,
    "V" numeric(12,2),
    "D1C" integer,
    "D1N" text,
    "D2C" integer,
    "D2N" text,
    "D3C" integer,
    "D3N" text,
    "D4C" integer,
    "D4N" text,
    sidra_row_hash text NOT NULL,
    ingested_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.ipca OWNER TO budget_user;

--
-- Name: categories id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories ALTER COLUMN id SET DEFAULT nextval('public.categories_id_seq'::regclass);


--
-- Data for Name: categories; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.categories (id, name, description, icon, color, is_active, created_at, display_order, ipca_category_code, ipca_category_name) FROM stdin;
5	Mercado	Compras de mercado	🛒	#32cd32	t	2026-02-11 18:06:59.013845	15	7171	11.Alimentação no domicílio
6	Uber	Aplicativos de transporte	🚗	#fffd75	t	2026-02-11 18:06:59.013845	18	47649	5101051.Transporte por aplicativo
8	Lazer	Entretenimento	🎮	#00ced1	t	2026-02-11 18:06:59.013845	12	47662	7201266.Cinema, teatro e concertos
10	Outros	Despesas diversas	📦	#808080	t	2026-02-11 18:06:59.013845	19	7169	Índice geral
23	Gás	Conta de gás	🔥	#cc0000	t	2026-02-13 12:57:33.86533	2	7483	2201005.Gás encanado
2	Energia	Conta de luz	⚡	#ffa500	t	2026-02-11 18:06:59.013845	1	7484	2202.Energia elétrica residencial
15	Gatinhos	Despesas com pets	😸	#ad8800	t	2026-02-13 11:44:11.97185	4	107666	7201020.Alimento para animais
25	Farmárcia	Remédios e outros itens	💊	#ff8af7	t	2026-02-13 20:35:39.157051	14	7661	61.Produtos farmacêuticos e óticos
26	Faxina	Serviços de limpeza	🧹	#61ffba	t	2026-02-25 14:42:48.727164	8	7714	7101.Serviços pessoais
32	Bares	Botecos e outras diversões	🍺	#ff00ff	t	2026-03-07 02:54:10.76802	17	7440	1201048.Cerveja
33	Roupas	Vestuário em geral	👕	#8991d9	t	2026-03-10 20:09:08.96723	10	7558	4.Vestuário
34	Eletro	Artigos de residência	📺	#9cff78	t	2026-03-11 16:29:43.858125	11	7522	3201.Eletrodomésticos e equipamentos
38	Media	Serviços de streaming	▶️	#eeffb0	t	2026-03-15 19:29:23.585736	9	47671	9101115.Serviços de streaming
40	Metrô	Transportes públicos	🚇	#4c487d	t	2026-03-17 03:47:30.638039	13	7635	5101011.Metrô
4	Internet	Serviço de internet	🛜	#9370db	t	2026-02-11 18:06:59.013845	3	47672	9101116.Combo de telefonia, internet e tv por assinatura
42	Contábil	Estornos e outros ajustes	📓	#96ab4d	t	2026-03-20 04:35:39.930336	5	\N	\N
41	Passagens	Despesas com aéreo	✈️	#1b74f2	t	2026-03-20 01:40:44.988195	7	7634	5101010.Passagem aérea
39	Aulas	Academia e aulas diversas	🏋	#6529c4	t	2026-03-16 14:43:38.147829	6	12428	8104006.Atividades físicas
24	Alimentação	Bares e restaurantes	🍴	#ffff00	t	2026-02-13 16:58:06.895623	16	7434	1201001.Refeição
1	Aluguel	Aluguel mensal	🏠	#ff6b6b	t	2026-02-11 18:06:59.013845	0	7448	2101001.Aluguel residencial
\.


--
-- Data for Name: ipca; Type: TABLE DATA; Schema: public; Owner: budget_user
--

COPY public.ipca ("NC", "NN", "MC", "MN", "V", "D1C", "D1N", "D2C", "D2N", "D3C", "D3N", "D4C", "D4N", sidra_row_hash, ingested_at) FROM stdin;
1	Brasil	2	%	0.33	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7169	Índice geral	2ab9ca73e9a53d3de354681db752066b472d4caa3e4dfb850e4271d014225d73	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.23	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7170	1.Alimentação e bebidas	1698c79d52f96cb8bfa8f7fdbfc33ec4b3b3b78a274f4205d76e53450bba7528	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.10	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7171	11.Alimentação no domicílio	b17c9b7cbe45303d21243b0265fbac4c4fb8fe2b42f22515ad7c23b5b200d874	2026-03-13 18:44:13.621322
1	Brasil	2	%	-1.27	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7172	1101.Cereais, leguminosas e oleaginosas	c4efff5b85055a53c1935abc1cc0e739a2c7453dbb8b17208989b0911745f6ef	2026-03-13 18:44:13.621322
1	Brasil	2	%	-1.55	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7173	1101002.Arroz	3ab396f26db148b39ab9484fc82b9ea74742484a441715fcfec1899e84dfcc19	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.38	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7175	1101051.Feijão - mulatinho	5e3f0bea4b2253589f64f8b3d48b689d921da1539da3268c38a5db70fcbaf674	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.68	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7176	1101052.Feijão - preto	0a39a7b34887cf508132892a57c335bec83da65f2b20aaecf0183bc8c5028d88	2026-03-13 18:44:13.621322
1	Brasil	2	%	-1.50	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	47617	1101053.Feijão - macáçar (fradinho)	e29b37267af4d0551a16543492a3e96b2627bae2660b758b5990c6e820d4c516	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.64	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	12222	1101073.Feijão - carioca (rajado)	aa3a11af217191a1d8e3aa0467d4c335469290ec91e745e40d140bb1fe773102	2026-03-13 18:44:13.621322
1	Brasil	2	%	2.27	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	47618	1101079.Milho (em grão)	ddde094ffea5975c804305422507a01fbe19528b73138646d1a4f9e7865df0d2	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.11	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7184	1102.Farinhas, féculas e massas	5a75313f6d6c246ed17b6ef1497b2634d7011b825b72c030bfcd5c6e14c7d870	2026-03-13 18:44:13.621322
1	Brasil	2	%	1.30	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7185	1102001.Farinha de arroz	7868a1e2bc3ccb2d4a94b8a2ba93cef88dc1da220c87b64d5b6257bdd2fb2b5f	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.34	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7187	1102006.Macarrão	1108dea1d3c60871fcee5b8259b1d30834b87c579c52e2d674b19f1ea6d21e7a	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.23	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7188	1102008.Fubá de milho	e961956773404888b6a17d6e441c9f7bfc7ff9e3a747c5cf655b0d1cbee63a56	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.13	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7190	1102010.Flocos de milho	8c6be35be8079ca5f7e2093971e72ae008304ca1f8b74488e5be60802db4a5ec	2026-03-13 18:44:13.621322
1	Brasil	2	%	-1.63	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7191	1102012.Farinha de trigo	8f5da6b1042faea664d53cc10c20c63f51aa589495e27e0f6a3c79100f10ad0f	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.56	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7195	1102023.Farinha de mandioca	ee93a7fd850cf1a80f8bac3f6e96c836298a6e2b6144b18d6a6b6abf52ff5545	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.75	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	107608	1102029.Massa semipreparada	2e83adaafc55b09729937d5609efb97dbd31b730f36c900c6949afa3b45de167	2026-03-13 18:44:13.621322
1	Brasil	2	%	1.21	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	47619	1102061.Macarrão instantâneo	58ac13ddbdd269f5d34a23abf3b205b6ed065dbd1db06664769c3c496f54e87d	2026-03-13 18:44:13.621322
1	Brasil	2	%	7.63	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7200	1103.Tubérculos, raízes e legumes	c1e462105366ac1d5e19d3a56cfd8f3bd9aec82c13456d3f4e63705dee4691be	2026-03-13 18:44:13.621322
1	Brasil	2	%	2.62	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7201	1103002.Batata-doce	44d6bb6d4d1718b816457bbcda22cd9cf5fc7cfa6694a5a00038e720f79d45e2	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.66	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7202	1103003.Batata-inglesa	fc10a969801d3594d67155b15bb5e9ea3908de252e9b06a47c7cecadca3f9b3f	2026-03-13 18:44:13.621322
1	Brasil	2	%	10.06	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7203	1103004.Inhame	b662c3846d9647324be11cac6988663297dd4c93fc800b36861c32d3dceacf13	2026-03-13 18:44:13.621322
1	Brasil	2	%	1.11	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7204	1103005.Mandioca (aipim)	6ab76ac83aa75e0b41d0cd19db4e80b772278aabb4b47ec4f8944c5bd05103c0	2026-03-13 18:44:13.621322
1	Brasil	2	%	13.77	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7206	1103020.Abobrinha	0f08839c7e015ce0d65762470968068ba30cd0935e8ab1c8942dce7588ce7f39	2026-03-13 18:44:13.621322
1	Brasil	2	%	28.82	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7209	1103025.Pepino	6310aae845ca8dc257cb4a94fbb508345338a940d2b55a9a1239af0974345b37	2026-03-13 18:44:13.621322
1	Brasil	2	%	-9.16	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7210	1103026.Pimentão	c42b793cd4fc161a8968a2dc901b5eee6944148cbfb96df1dcef24f46d9eeca6	2026-03-13 18:44:13.621322
1	Brasil	2	%	20.52	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7212	1103028.Tomate	24156afdd5a65458795acb30f91d180dce8cb56d301d2d3603b898b339aa31ad	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.21	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7215	1103043.Cebola	a74e8d971983711f53aafefb6754b003f04d188d246674c30273990f1387a4f9	2026-03-13 18:44:13.621322
1	Brasil	2	%	9.94	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7216	1103044.Cenoura	37f0e78672c073f775b2fe2b3a0918da8d73b56c233f5cf26a2b7a347f493171	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.23	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7219	1104.Açúcares e derivados	3a6cb13e9f24ebb65470b4ad1a60adf5c92a7a96f893a4c8ca5ac18098d3ec78	2026-03-13 18:44:13.621322
1	Brasil	2	%	-1.54	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7220	1104003.Açúcar refinado	5ce9a58e20b89efb7fa4d96f64b30a74738071bc8ee07f357c79723b210f2d04	2026-03-13 18:44:13.621322
1	Brasil	2	%	-1.92	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7221	1104004.Açúcar cristal	e490eac7cfbd59b520c8a0cde5e8027d881eabf8989e34398ba32b6262744b53	2026-03-13 18:44:13.621322
1	Brasil	2	%	-2.24	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	12224	1104018.Balas	6476dc8643542ae4bb696b06c1c7316eccb54f3c070273d59e82c9914a5a865b	2026-03-13 18:44:13.621322
1	Brasil	2	%	1.28	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	107609	1104023.Chocolate em barra e bombom	5162c8ed1d9a625128a4bd559fcf578efe85345e6655b0c7c8c927f68d3871b1	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.72	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7230	1104032.Sorvete	4b066280a11a4c8d9fafb9e39db04f7842777a6654a5859f9105571fd70f93fa	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.32	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	107611	1104052.Chocolate e achocolatado em pó	0f049a623220b10e5608a6588b8c1a065c56f17ed9fd675767ddcd2c3567e6a5	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.11	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7233	1104060.Doce de frutas em pasta	3f68f48050d712082ece7a105f8dfd100a482f624c813575fd350e75cd449172	2026-03-13 18:44:13.621322
1	Brasil	2	%	-1.86	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	47620	1104067.Açúcar demerara	60e223480cf2a811378ee2e2d8eedc901d2177fd3a3bae60ea32874ee9609125	2026-03-13 18:44:13.621322
1	Brasil	2	%	5.23	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7241	1105.Hortaliças e verduras	7616445def9e9beafb5d2c2d03246e81aca1bbddb4c46d2bdd9c9540694e499c	2026-03-13 18:44:13.621322
1	Brasil	2	%	6.46	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7242	1105001.Alface	7eb135edd674e9843f95ea9bc831b26aaf8c8a05e7b8b08f95bbb2be21e25e0e	2026-03-13 18:44:13.621322
1	Brasil	2	%	-4.34	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7244	1105004.Coentro	e206676bb332bd1f5035cb55f0b6cc156a442c8ec3120d4596b3fd1af140bff0	2026-03-13 18:44:13.621322
1	Brasil	2	%	5.18	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7245	1105005.Couve	45916207168f06796634ad331f978e0e7cea6497866b7429e4cd721c21e4b70d	2026-03-13 18:44:13.621322
1	Brasil	2	%	11.39	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7246	1105006.Couve-flor	7e76e6bc8f72040530b278ed39fd21d31c2dadb6be86aa42d058e29180770f7e	2026-03-13 18:44:13.621322
1	Brasil	2	%	1.73	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7248	1105010.Repolho	00e5f45cecaac494c9bb5361559ba9c30edbe511c937a186472b7db66a4985e5	2026-03-13 18:44:13.621322
1	Brasil	2	%	3.19	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7249	1105012.Cheiro-verde	198fa716a527daebbb0d247d6c99e4f494ab6800ba95d78a53045a209b6667e3	2026-03-13 18:44:13.621322
1	Brasil	2	%	8.23	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7253	1105019.Brócolis	e75a8ae216b1eae221e7a09edeef9d367028b70ccbf9c1b21735329715563331	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.95	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7254	1106.Frutas	50e6c03f0ff7351bcc4ac6c28ff16338598f3d216f581e396951a88bcf355a1a	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.30	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7255	1106001.Banana-da-terra	b3a4a017941514e002d91bfa248ed1a158b3183c54dbfd68c6d83d78d3349acc	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.66	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7256	1106003.Abacaxi	dd2e1591e074138c945504024a9a070263fb3affcb5f674ea4458ca2a4175ac1	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.35	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7257	1106004.Abacate	891a29f2311450ad0bda32a8c0127f065d44fcb59316a5baf1dce61cf404b248	2026-03-13 18:44:13.621322
1	Brasil	2	%	-1.38	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7258	1106005.Banana - d'água	a484bd3f625220a869b2ea004eeb164ff109652376ab19de956243618ace5981	2026-03-13 18:44:13.621322
1	Brasil	2	%	-6.05	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7259	1106006.Banana - maçã	f10ae61763661356d051d78324eb70c0ac12aa1a8a8dce2247a025ae94dca487	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.60	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7260	1106008.Banana - prata	12021d6f41ad91008945106e713b90f651495e105584d9eb4c68da40cdd73dc6	2026-03-13 18:44:13.621322
1	Brasil	2	%	-1.00	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7262	1106011.Laranja - baía	47a7ca5f63025424627f68e43880f52f7ed8ce5ff34ab49bf9ee64576afee711	2026-03-13 18:44:13.621322
1	Brasil	2	%	4.61	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7263	1106012.Laranja - lima	8ef570f30eae9893561465327a22c8ee5352f3ff2e59c52f90a3a0e12cbd6b92	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.44	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7265	1106015.Limão	d669c0841e03194adfb844e0c1405f3f4ae8e9109d62dca89053cc4491f58334	2026-03-13 18:44:13.621322
1	Brasil	2	%	3.94	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7266	1106017.Maçã	9cb838f341da25ab398c16cb5308b6b29b4d2d141a772e7fa2793d7b59c8b296	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.30	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7267	1106018.Mamão	ef182e9142344e7482223381cc90da2a17ee4374c41bf7442ea28efab2e4367a	2026-03-13 18:44:13.621322
1	Brasil	2	%	3.04	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7268	1106019.Manga	9335e5a4ae1310b34d26e48f9283dd41d0b44b7f9f89754d5fa44ad136d7dde0	2026-03-13 18:44:13.621322
1	Brasil	2	%	2.51	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7269	1106020.Maracujá	7e5f1221e8448a796f8c661c73ad0c6ae502a2c75333a93914bd87d79b09c11f	2026-03-13 18:44:13.621322
1	Brasil	2	%	-2.35	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7270	1106021.Melancia	2f8464fb0f5c01cccb7811dd31442b5435e1d555269d95465f845473f0d333e4	2026-03-13 18:44:13.621322
1	Brasil	2	%	-1.91	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7271	1106022.Melão	415f267cde5318c5462f9e579384f4fccc2a56b32ff747c41bcaff1672de5c90	2026-03-13 18:44:13.621322
1	Brasil	2	%	2.49	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7272	1106023.Pera	670f141ddd0e394f5e1013b89873f31db8a088e5bc815588173e2272d595a3a7	2026-03-13 18:44:13.621322
1	Brasil	2	%	1.00	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7275	1106027.Tangerina	6adfb27c77e3df64fb1faeb95d513873724c42b023f02df60447f2da66c342fe	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.89	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7276	1106028.Uva	f68bf9b9f6684646490b017e8f35c66737263276dc60102d791f2dbe686e0a11	2026-03-13 18:44:13.621322
1	Brasil	2	%	1.69	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7279	1106039.Laranja - pera	5b2c63451ebf1587bb251bd4eac563aeb30d365e0f8637afa454452d7fc816d7	2026-03-13 18:44:13.621322
1	Brasil	2	%	5.07	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7280	1106051.Morango	fb923653da4b02d1f7e010f70e3a9d25015c17f84fdb6d13d0c24ad43ca88392	2026-03-13 18:44:13.621322
1	Brasil	2	%	3.75	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7281	1106084.Goiaba	da794821f995c84eed842c635871b3ca2101a4c361c42b93a7beb7ee0398c31f	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.84	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7283	1107.Carnes	42edea769f96cdbd4e1827b63c82ea7045841786563a01eea09eabd75627df6d	2026-03-13 18:44:13.621322
1	Brasil	2	%	4.21	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7285	1107009.Fígado	eff3de6b178e5d49269446726c3e7c208920d67dda505513b4e32b56a16825a2	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.05	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7287	1107018.Carne de porco	c0fdeb212267a13241900c8d054540e5a70cb6aeb54783120b64424812f46a5a	2026-03-13 18:44:13.621322
1	Brasil	2	%	3.05	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7288	1107031.Carne de carneiro	f9300e6b16f56bcd38940e11cb342e0519b3bf39febfca8710c66dcb3400fae6	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.06	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7290	1107081.Cupim	3994cccdb89dcd8df5993a79df69a5ca7a9cdb2ad94a89f81d4731ee623d7efe	2026-03-13 18:44:13.621322
1	Brasil	2	%	1.86	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7291	1107084.Contrafilé	4108c9739d1faa6c43419956638c1b9d392ec1128de12377de47fd049bb99943	2026-03-13 18:44:13.621322
1	Brasil	2	%	4.76	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7292	1107085.Filé-mignon	81e8aa33957306bca299bf3decf98f055ea0576c2a50c163d5031e02beb16ac7	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.67	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7293	1107087.Chã de dentro	d3fffdc3120be72c4d2044cdfc532962d3638a85aa189956abe3bb213b975e7f	2026-03-13 18:44:13.621322
1	Brasil	2	%	1.61	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7294	1107088.Alcatra	9cb423651215815473fb5df53b29cda49518e42ca42728aa129feae0397e9301	2026-03-13 18:44:13.621322
1	Brasil	2	%	1.18	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7295	1107089.Patinho	cceffb2a7db648902ee56dcf353db951fb9b61692a2539d60e4b44c15f1dbffe	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.38	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7296	1107090.Lagarto redondo	b9f0695a73daa40a12b25b0e752c8adfce3c43af55430b92cd38b394e16b6d94	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.24	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	12294	1107091.Lagarto comum	b4f07384ff4fe4b5d384436a9448897c06a00ee58cc2b8530e0d44c8717dd624	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.36	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7298	1107093.Músculo	5071cf4c9ccf0e7a2b903c8b61cd3532e5e5053994de3c28ac73e94ffeb13c3c	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.00	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7299	1107094.Pá	cd4f94ac20247a39ecefd90c5393724f76616de244a5f146d227b56a31c34f44	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.33	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7300	1107095.Acém	003fff543e43ca7202ef02466ba8de8cf3591e65cf43292dac9b142e98c253dd	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.07	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7301	1107096.Peito	3b0ce33f1a72782f9fd9d07a27288073e419ba4505901c59420a216ba645828e	2026-03-13 18:44:13.621322
1	Brasil	2	%	2.56	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	101448	1107097.Capa de filé	1fb2cd79c24093428c57a9989861518dfa7e3ac27e77d19350f2737cd158c6c0	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.25	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7302	1107099.Costela	6f8dc023cef2f1933f2c649ed1bbb103dcc2b794c0256c31fca9b18dd20c362b	2026-03-13 18:44:13.621322
1	Brasil	2	%	2.48	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	47621	1107208.Picanha	717bc379267f0b2621717568d6a42f5d60db58ead7a96acd9677dc9a9fdbdaf1	2026-03-13 18:44:13.621322
1	Brasil	2	%	2.77	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7303	1108.Pescados	7a7ef2f9b86b6703468cca3ad072441f3aa54c6f453eb7bb79ee6fcfc95fe9fe	2026-03-13 18:44:13.621322
1	Brasil	2	%	4.78	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7305	1108002.Peixe - anchova	1f169f90ab6328a030621c44e1e1e3291a4d6737284634146bb9ef67c6fe502a	2026-03-13 18:44:13.621322
1	Brasil	2	%	4.82	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7306	1108004.Peixe - corvina	579c96346b0b3cd9c6e68d77804beddf2a0848014de276ee9b557d71f41aa7c5	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.00	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7309	1108011.Peixe - tainha	52f69b1306b7772b1228894ce54d49f6549b374989de60290518c533bf045326	2026-03-13 18:44:13.621322
1	Brasil	2	%	5.43	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7310	1108012.Peixe - sardinha	0f2cac34e5e2bdd20b784178da353dfa13db0573e59bcb438d928046e42e3f7e	2026-03-13 18:44:13.621322
1	Brasil	2	%	1.89	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7311	1108013.Camarão	d48910895a44c3141002ace03945c06de4efc28dc850276ffc58d605e1ba472a	2026-03-13 18:44:13.621322
1	Brasil	2	%	1.05	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7313	1108019.Peixe - cavala	1ebce109e9471799ba1199627fbd9d3f12e88e6a44928a0b6b234fd98bf8ad6e	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.72	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	107615	1108029.Peixe - cação	fa4d40a4f616e851c9538c4a63665b8ba2a406e455c0c43bef01ffb25e98ec02	2026-03-13 18:44:13.621322
1	Brasil	2	%	-1.18	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	107616	1108031.Peixe - merluza	ad6b8bc9173a12cab34fe54ac71bdc540be606fb862580eb1fe83959ae242849	2026-03-13 18:44:13.621322
1	Brasil	2	%	-3.38	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7317	1108032.Peixe - serra	8c908f3c2b55a0d34738b2e1e9a6cb837d9272f4032de456dc4fcf886f39d20f	2026-03-13 18:44:13.621322
1	Brasil	2	%	3.03	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7320	1108038.Peixe - pescada	588a521d0dd6388e347946d86f215e7e37ac2c72687f4e9dda9ba76c25ac8575	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.44	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7323	1108045.Caranguejo	38a5d862e671c2b943f9933ae62da862a0f90cfd792f293cd3d01309eb13c309	2026-03-13 18:44:13.621322
1	Brasil	2	%	2.88	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	12300	1108049.Peixe - castanha	fafeb9a13849784814f80412e01869b0078337a49d9e9ef8bb6803c939d3a386	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.94	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	12301	1108052.Peixe - palombeta	0d71458695a73c549887d864cd719722b50418bf73fffae589e8d23f86b30ca7	2026-03-13 18:44:13.621322
1	Brasil	2	%	3.07	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	101466	1108072.Peixe - curimatã	05ccbd5cfdb8f4066b441c6a192f3b2cb89b2a01f7aacb58612f1737d63ff0e0	2026-03-13 18:44:13.621322
1	Brasil	2	%	7.94	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	12431	1108075.Peixe - salmão	e56962b06853e89100e24e687b52439750b079b3380a0d4c153073e61a69c61b	2026-03-13 18:44:13.621322
1	Brasil	2	%	2.33	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	12302	1108080.Peixe - tilápia	513c34fa61d8ba8618f677519b4a02076d5e5fc861fb67ac0b5b190b17132741	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.12	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	41129	1108087.Peixe - tambaqui	a9c530ed1c4c820b1dbf55de2c7accb1a1f1198ef1b05c9a86568a689bc1611d	2026-03-13 18:44:13.621322
1	Brasil	2	%	9.32	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7333	1108088.Peixe - dourada	ac8de021dd821762a1877731408950b051bd21da47ccc3d9d957ded5934d9d3d	2026-03-13 18:44:13.621322
1	Brasil	2	%	6.67	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	47623	1108092.Peixe - filhote	c938d140372af87913e5d185abda23afed9bb432463ff0654c63181dd53e844e	2026-03-13 18:44:13.621322
1	Brasil	2	%	5.18	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	8874	1108096.Peixe - peroá	b118a5779780e3a72446d4008bccea2c67d84ffa66b80eee99bdd34b89d6c4dd	2026-03-13 18:44:13.621322
1	Brasil	2	%	-2.51	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	31694	1108112.Peixe - pintado	c5867da6ea73bd4f91cd5ffda6acf92791af84169b44d316c3ae49e67e9f664b	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.12	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	47624	1108125.Peixe - aruanã	878992b201b09455e60483e0e2cbbed68a7c7af00a38d94226aec45f264f3a66	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.17	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7335	1109.Carnes e peixes industrializados	62c35d52ec97930fe1910ea0abd4fb5f1c604e5dc043fa3d3c8431a089c9525a	2026-03-13 18:44:13.621322
1	Brasil	2	%	1.59	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7336	1109002.Presunto	256f79e2104f5fa27ec3a179c0dcd889fd028489f35e45353584bd6f863f27fd	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.64	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	12304	1109007.Salsicha	4dd27d81fb6c8534ae5b738c51f6c184f2f1ed1c0831db2863e6712e527e8ab9	2026-03-13 18:44:13.621322
1	Brasil	2	%	-1.30	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7339	1109008.Linguiça	9306beea9c6e810b63a37cb01ef35ff2ce4469b26b23f95ffd800714953c19e2	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.28	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7341	1109010.Mortadela	dd9f6252fa8d787e6f0395648f0435adb5a92e0a0fef844aa44e2c9d658a7b42	2026-03-13 18:44:13.621322
1	Brasil	2	%	2.17	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	12305	1109012.Salame	450acf8a825ab8c8556ecd8b4d86c3e8514d6fef12dc49104e809987d91b7206	2026-03-13 18:44:13.621322
1	Brasil	2	%	1.66	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7343	1109023.Bacalhau	4a7281ab39b0878407798271d99c4088c7c66ed38405589ddcd032deb771cbba	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.70	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	12379	1109056.Carne-seca e de sol	dd6d239ce09f57aaa4c95947c4fb707b271015c748bdf63628d42bbf3cc29ae5	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.25	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7347	1109058.Carne de porco salgada e defumada	971aa965faece636f6765c408f3e9503e314dbf659efe4a11ff59a4e93aeeab6	2026-03-13 18:44:13.621322
1	Brasil	2	%	-1.70	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7349	1110.Aves e ovos	fab2dcf528d0bb334178ac0c61a2a5dd63d8c4f50ae85038a7a0a5ff30b45619	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.37	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	107617	1110009.Frango inteiro	8b6517be0dd225778529ca27850746d6fe0c0a356d45dcb02041620977422337	2026-03-13 18:44:13.621322
1	Brasil	2	%	-1.41	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	107618	1110010.Frango em pedaços	b91d06a41fef89e8ded3bde5d92f0fd1c6869999dd034bcef7707578539b13a2	2026-03-13 18:44:13.621322
1	Brasil	2	%	-4.48	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7355	1110044.Ovo de galinha	807166c5cedac3f0906d87482cb12ab8e45c906468fb8704d1243e2b721820f2	2026-03-13 18:44:13.621322
1	Brasil	2	%	-2.31	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7356	1111.Leites e derivados	e8d210a3a96839551c4a8f9fb62e93c58261ee92dcb8a7ff9c15f511e4a1b270	2026-03-13 18:44:13.621322
1	Brasil	2	%	-5.59	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	12393	1111004.Leite longa vida	d2afbc095632891f70b275c4c055c12df16291f87e1d752652c954100c2d64b4	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.44	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7358	1111008.Leite condensado	d7887ccea95eabb10769ef19ee82a34e2509abb658890259029f9c58997ce42f	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.54	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7359	1111009.Leite em pó	94cfce077d8fffd3a524ccde5146b7c9f5aad32258013fed615c2efc18b6ec81	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.63	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	107619	1111011.Queijo	d805f93a2f05bfa6f7c1e476371b1b8ea460847e9417e84b4ff8046f5249db18	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.78	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	12394	1111019.Iogurte e bebidas lácteas	45ffdf151f280ad4b4ca1788677a8430f9cc32e9c247200e4fb7809bede24dd3	2026-03-13 18:44:13.621322
1	Brasil	2	%	-1.73	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	47627	1111021.Requeijão	feae9ccbfca972e6f93f542725c112624ef3b64ba29545a7c65dc3d82b8115e2	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.53	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7367	1111031.Manteiga	c226bc18a30476bbb9cd33516e7774b4d555f214d8be91aa628e30514d393414	2026-03-13 18:44:13.621322
1	Brasil	2	%	2.04	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7368	1111038.Leite fermentado	b63a9793c877a40207fee8be9296e5ad3f7f3ef8ea9d8e3dc26df9eafc4e9462	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.36	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7372	1112.Panificados	40120697e475495364deeeeb151a21733eb6f0da518203a8b745ff659a1994cb	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.53	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7373	1112003.Biscoito	ae1345557ea22e7ae97919967de78b22732af0e6d77f122fee7dc4ca2a391f26	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.01	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7375	1112015.Pão francês	4c0546a2dbbedb6574b7bdd461b70690853f0a1cdf81fed7813c9f0092043da6	2026-03-13 18:44:13.621322
1	Brasil	2	%	-1.31	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7376	1112017.Pão doce	51e8b616ab6dcbccc5a9a91be1aa92987c1c446ccb58b83da0f625477c568fb3	2026-03-13 18:44:13.621322
1	Brasil	2	%	2.91	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7377	1112018.Pão de forma	25707473241e11527f1442226a90f357be360eb73d0352fae086f7c82f434456	2026-03-13 18:44:13.621322
1	Brasil	2	%	1.24	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7378	1112019.Bolo	d440eccb16ab17d9dc1d89a2d252b20125c0b5de8c2a39b98bc1365aa596dd59	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.52	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7380	1112025.Pão de queijo	63bbb3a1b4b4bb569cda6e3642bfd9cfeba2816e4c964792396f5c3e7c928231	2026-03-13 18:44:13.621322
1	Brasil	2	%	-2.06	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7384	1113.Óleos e gorduras	c54b4e7161d176b13aa651b1b06efde1027ca556af43df9e5824467dee6b83ad	2026-03-13 18:44:13.621322
1	Brasil	2	%	-3.32	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7385	1113013.Óleo de soja	38df94fa43c42119a9e6e04d02fd5a2d5a6678cab56babdbc1c4bbe62e226a8c	2026-03-13 18:44:13.621322
1	Brasil	2	%	-1.84	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7386	1113014.Azeite de oliva	b65ef77bbeeec87201339af49591a74fb8317499fe8e5466fa7e869b87ca0ced	2026-03-13 18:44:13.621322
1	Brasil	2	%	1.14	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	12395	1113040.Margarina	8f291d12fff14f5a6137c224557e0dfe8f946aed044f744292fe8fa12a028d6b	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.29	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7389	1114.Bebidas e infusões	033acfc536a8341200e13cfaf604134b25c12eef9c7c9ef7a88f80228a49bf88	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.56	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7390	1114001.Suco de frutas	665d52f05a1588f1a1dce911b3adec36414e881cc8b89621dfea45bda8b8615b	2026-03-13 18:44:13.621322
1	Brasil	2	%	1.43	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	47628	1114003.Polpa de fruta (congelada)	52446016d87675e1d61313c0a90d6a9686f630b0fef686d976e0eec44302475e	2026-03-13 18:44:13.621322
1	Brasil	2	%	4.29	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	12396	1114004.Açaí (emulsão)	49cd96893f9fb96e42dc16da7ce504819d5e8ab4c5369cddad6f243ea80fbf97	2026-03-13 18:44:13.621322
1	Brasil	2	%	-1.18	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7392	1114022.Café moído	09aa98dc5b781843227e28982d9fec0f33eee91bf654a1abd710e50b6ff38a13	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.01	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7393	1114023.Café solúvel	23bc559821541a4e9fce962aab682a2ca5aaedb2646d472cda8c4fb3954966f9	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.07	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	107621	1114083.Refrigerante e água mineral	93a2a0d4fc44fe177bcc012dbbc9be6f6f4a35bc6a598782aa0e31d067857e49	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.06	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7396	1114084.Cerveja	b8727ee2295713413de05cdc82b712296ce14828ffee291184edf96f3c766fe9	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.56	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7397	1114085.Outras bebidas alcoólicas	db6d4d507bfbc607ae0919ff313c14a799dd4185e8a3fa5bc0cd846588b1d50b	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.08	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7399	1114087.Vinho	d50b01945d1b7c2844317c4fd53913c144debe094e0e9e8e92b373faf15ce8f4	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.46	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	47630	1114090.Suco em pó	269283b57cdc35ea98d1170283c71276ca31ec0054327bd4fd46ab111bd7331c	2026-03-13 18:44:13.621322
1	Brasil	2	%	-1.09	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	47631	1114091.Chá mate (erva mate)	a00d2b2dc7764c21a22d25048a375a6110ea06e9c63667bddd1eee5d86ca9b50	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.69	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7401	1115.Enlatados e conservas	5b65616144ed918620e7a73cc92a339d0630c3924eccdcb3aaead2febaa31c1b	2026-03-13 18:44:13.621322
1	Brasil	2	%	1.71	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	107702	1115013.Alimento infantil	2517ae24f32b977abc62f40a4e97e829d8aa8863c9efd14c288ce0f429abddbc	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.38	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7406	1115016.Palmito em conserva	dc9f1e59c4c9fb9dd0b535778181de6fed6dc3e4ac88937cf768d01b7e7215bb	2026-03-13 18:44:13.621322
1	Brasil	2	%	1.28	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7407	1115017.Pepino em conserva	7a9af7ccf6d5836607e00f2a454675c5f0d750cc6b33815c9c3f94e38c660d68	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.31	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	107624	1115039.Sardinha em conserva	9a33dd2dfe053b173a7dc01254f45b1f024ba224b7abeabcccb3b54a21932ada	2026-03-13 18:44:13.621322
1	Brasil	2	%	-2.63	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	107625	1115050.Salsicha em conserva	19d4c63f6b7ebb84694c469174f1d9ae5e264f33e275431f9d18fad8d64c9108	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.77	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7411	1115056.Sopa desidratada	48860e4c6d49e53cd5c71274ee96b06ef79a521d930dd51e2ded52119c09132f	2026-03-13 18:44:13.621322
1	Brasil	2	%	2.16	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7412	1115057.Azeitona	6563fb8580d2c1009a11afa6000e05d6874ee2ead60a227acb61d6a856993ad4	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.56	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	107628	1115058.Milho-verde em conserva	7b76155481936e1df81edcde071f2aaa6fdd617fe2a9534f2d6c99d80e3a53a8	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.34	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	107630	1115075.Atum em conserva	32294f0294ceb004fc836d234736068cf24547a90d2fa7fb6572d72c32efcad3	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.35	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7415	1116.Sal e condimentos	2297b6b779d4909b7c0c9503fc6eb1c6f65c3617e49319220a34907b933b7883	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.45	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7416	1116001.Leite de coco	c4c36b55ab89a5f9d90640f522416a008eb06752a6360b27a305c263a8f92624	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.52	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	109463	1116005.Atomatado	a9471fcd9905ec16c213c1321fbc7f06e9feb89fd7b79d4d1038084266c97786	2026-03-13 18:44:13.621322
1	Brasil	2	%	-1.50	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7418	1116010.Alho	cba91e95176c3934e7abf65f874a4d08e3ee538b54a57faa3932471415423fab	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.53	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	12397	1116013.Sal	0d7dcce6c553b7275537a415e19dd72f7a6cd2a9fc7f16ba082037ef59588a4c	2026-03-13 18:44:13.621322
1	Brasil	2	%	-1.56	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7420	1116022.Colorau	0e32ae7e929e01fbce17c731b283436e4f44ee05e87b0013b0719a3ebc4cea2f	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.18	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7421	1116023.Caldo de tucupi	1ded3dbb58a510d61b7cd0293f24a6e7098371cf8211b69eb3ce447a95b90613	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.19	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7422	1116026.Fermento	1bcfb1a4c1453b03eac6b2a4af9a742e632e37d102e909b8366054530141f3de	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.64	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7423	1116033.Maionese	901d0723d067edb866e4c549b0bdf59ad504160939170fc47af3e751c34446ad	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.56	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7424	1116041.Vinagre	2fb80c38b2f920e4aeca002b7dfb3194a179048354e61823254d1fe64ea726a4	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.81	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7425	1116048.Caldo concentrado	d76d84406d553eb16e8341b1e57254a10e01cba5b42a4d535a5852228fc2fcbf	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.91	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7428	1116071.Tempero misto	8bdc199c2de8576f0b832f43ad01aad01f13aa201a28aa6e24b08039baf1afcb	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.55	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7432	12.Alimentação fora do domicílio	895fd06d1436771901960cd5ad5364526682ca6c80272a68b710d7dd68639e26	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.55	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7433	1201.Alimentação fora do domicílio	65220369be41c452ffc2bd307a1a1cc73721790cccd4b1f7fd4e04c7b5837e35	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.66	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7434	1201001.Refeição	8842383cb2f0d27b22be8754185474af2f9e31dfb5f66243f271c1e172dd5f61	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.27	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7435	1201003.Lanche	a0730e0592b90390b999c1ac096f0fe836b5224ea10e712848bc1954a4aa89f6	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.47	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	107633	1201007.Refrigerante e água mineral	786c3ea9bd783ed487da2c162faec9a19a1cff1a21d1eaabc539a4225a401971	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.58	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7438	1201009.Cafezinho	9bb9e08308db96f0b88a8b9a04d12bc6ec04572a610a6903ad4f65f8b7d68f04	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.97	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7440	1201048.Cerveja	f16cb24915a797a582fbbe494a30554709202a151853dd5383d371ff5c458257	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.53	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7443	1201051.Outras bebidas alcoólicas	f11dc628e7c967f187437a20bbc5528ca6ca1da7a6b205d8deae755a82650348	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.19	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	47632	1201052.Vinho	0da56a94724b204f5e52fd9c36e5ccb1485f6fde00b4881abd2add988a78ad51	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.47	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7444	1201061.Doces	45c44d661c6b26aeca7cf499af8db1c2dccbd4e905326b8911a90e3a486be677	2026-03-13 18:44:13.621322
1	Brasil	2	%	1.05	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	47633	1201088.Sorvete	aa4bd6264afcb46b088932130f1c151f8f930a5262d7647143402197fa55d447	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.11	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7445	2.Habitação	e505eb99c67de52bc496664d9251a70a0e96f97ecff83010d78b623fea0b3094	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.98	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7446	21.Encargos e manutenção	191e09b5c937a0fad1c47de8439aa45047cd59080333c34bb63d7170dea54198	2026-03-13 18:44:13.621322
1	Brasil	2	%	1.12	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7447	2101.Aluguel e taxas	efc56a16ca83eef714becf8f9cb0689a16cb54fea5f1cf6e46b841af39440024	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.76	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7448	2101001.Aluguel residencial	0b94c4f8e8428eab8056cdfbe206b716b4552af871deb3b540c955590a4c96b6	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.51	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7449	2101002.Condomínio	09089ef89d5310b1a60c6ae87a6e214750a3bf2d31d8fec0f30c4a259e191363	2026-03-13 18:44:13.621322
1	Brasil	2	%	2.56	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7451	2101004.Taxa de água e esgoto	2f17febf5cfafbb6b85ca21e706b7328c379a574176261c0bac9d83eea22458f	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.00	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7453	2101012.Mudança	214da0bdaf6cd8f2687246e59c01fb2736dc0f569767db6413f113d9bc85331c	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.39	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7454	2103.Reparos	f0935ec055635f969c8286ebee14e32e9be2a62eb884af74f2ab58bcebee0e32	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.64	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7455	2103005.Ferragens	5475f24296474e9f709ac608c4d43bdc391d4a3e57b25f8be491239309a5599e	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.98	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7456	2103008.Material de eletricidade	86c177f1b2af5157904256867b46e68eb6d55720c51aeba35568d2c7e939273e	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.00	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	12433	2103012.Vidro	d58b07f073d7caa0eb130b871b7c4080cfe1615e7d5552b273e97e1eca89369a	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.35	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7459	2103014.Tinta	dec7d270186d53b48a44c3c04f0a53fa302716fec1e62356f2e6cc0b74e15df4	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.39	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	12398	2103032.Revestimento de piso e parede	e9b91e9b80aabc2df8d259440fd549519d6fb06c5de6ebe9ce99488d4799e753	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.92	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	47634	2103038.Madeira e taco	e49877c195e7bcd858e7b70eebf29a8159b48af2ff65d3a0196732c234cbf569	2026-03-13 18:44:13.621322
1	Brasil	2	%	1.64	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	107638	2103039.Cimento	e6809ab605f4e2594bd05ace7b027f44d262fd72ad602fec1e79518a947d8b9a	2026-03-13 18:44:13.621322
1	Brasil	2	%	1.59	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	107639	2103040.Tijolo	b08ed3a0f43de1c4e908b9d319275fb8ccbfde856fa35ac8555d0954b83238d5	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.03	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	107640	2103041.Material hidráulico	f8e78172532cdf550b598c2f4a9fe8afc48eeff75f2c0be86832ce35c687c9a2	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.66	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	107641	2103042.Mão de obra	b5f4bcf0d3d1a64f59098a95620aaf0be64dd306f11e12cf23dcb488d9db1d0e	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.10	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	107642	2103048.Areia	c3ac73acf8e1e7b0191b18e215c2ed99565a93be16b744604e2790ca559ecdfd	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.41	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	107643	2103049.Pedras	008681549525f5d702e707840436c8e41f40c9230af18e326897a4d9b0a47310	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.01	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	12399	2103055.Telha	9ccb23d3589e7bdbbe98b863998f2770ad60ff83f9e004ed171be23bd00be5d0	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.56	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7461	2104.Artigos de limpeza	1852b2468f12066c259458ea3608b9bcfd28c135bd93d13cbb75a6855db33f64	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.42	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7463	2104003.Saco para lixo	0818454a39d6974caba0b7d19d65b4d5c0d0b091c371a5becf687de2fe7d6c2d	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.43	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7464	2104005.Água sanitária	852e69b3cdfe9ae63d5e325cd4e49745cde9d3f805dfedbba44b7f1d1c543cbe	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.36	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7465	2104008.Detergente	5648fcb605ec67de08ebb79c6b3c8248572ee0d9a3fbeae6bd8a14f6cd879ee2	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.51	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7466	2104009.Sabão em pó	6aa5af8c84c7669bf2cd29651613b97ca8f34a20ef192626dc6cec9d13dc3e5a	2026-03-13 18:44:13.621322
1	Brasil	2	%	1.15	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7467	2104012.Desinfetante	53cee7a8ae7f8d62b4c1cb6ffbdd6c12dccaf5040c75eb9628bda6a66e663828	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.10	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7470	2104015.Sabão em barra	c10f1b09866ab11c11076cbc3e8d23b1abb7423303129a047266e0fc8c77d590	2026-03-13 18:44:13.621322
1	Brasil	2	%	1.48	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7471	2104016.Esponja de limpeza	8c7384301ca4415196f41f135135d43bb7a34c82f87f993d909c5f72c4ed5148	2026-03-13 18:44:13.621322
1	Brasil	2	%	1.11	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	47635	2104019.Sabão líquido	39f2a8630fd66ba0a78430ddb7e1da494e5975723e3e37c1a9abb8197ea6d659	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.04	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	47636	2104020.Limpador multiuso	5302d6555f120fd9876dc1d3656e173dbf7c4d3c9869c4fab23e554aeb2e9b24	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.96	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7477	2104041.Papel toalha	4456b9c127228c291f59fdcf74141db2d4eaf5e6cf045572c5426f2802eb11d3	2026-03-13 18:44:13.621322
1	Brasil	2	%	1.45	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	47637	2104085.Amaciante e alvejante	795da0112f9bebe6c555cea25ec032f792a61eacfc02aa85343e9cf3bb266e64	2026-03-13 18:44:13.621322
1	Brasil	2	%	-2.03	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7479	22.Combustíveis e energia	43a31144e46fa2a855c55a07c6630322a467cd1560197b1525b7c3619713dd2e	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.05	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7480	2201.Combustíveis (domésticos)	256c0069a87a9d4849e267dc6ec64967098c5414b81ed8ee95936f126e19ad3d	2026-03-13 18:44:13.621322
1	Brasil	2	%	-1.19	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7481	2201003.Carvão vegetal	77e899eb8b9ab02cc757d439a7c4cff1e37f9ce12b4cf7944e6f77ed2bb5db19	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.06	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7482	2201004.Gás de botijão	faa98c957d291e5fb4a56915168277d945ed72a40a10608fc0df4fb56726f213	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.95	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7483	2201005.Gás encanado	0e0e11e9842a186c3cd0ef374172902b68caf9524aeaad4c77248c3f39b20ba6	2026-03-13 18:44:13.621322
1	Brasil	2	%	-2.73	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7484	2202.Energia elétrica residencial	5dbb6ed4186dd7bdd8a4e66f9a7bffe923a65e47a75226136b7405aba7da68f0	2026-03-13 18:44:13.621322
1	Brasil	2	%	-2.73	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7485	2202003.Energia elétrica residencial	f74f865bf977a81c40b2970b0129549a4699056011f629276003e16ad0c38e7d	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.20	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7486	3.Artigos de residência	3b80dcb0a1a290152e0729d72d98998b1948e77fb71eec13d7c11b8b6a2ad4b0	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.06	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7487	31.Móveis e utensílios	d0be77a104f5a7f2d09288de27635135b88ae72a047dcc4af1ef1d3c6ea9951e	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.08	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7488	3101.Mobiliário	2e6aebd18f8e51962c38ba9832bad0b39410e6f98e542f66eeff4cd2c4f6caea	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.11	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7489	3101002.Móvel para sala	30f94ad1dd3939172c7cd5bc9b89f4371d4a9c21b996a2a0ce96eb436ea40f82	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.09	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7490	3101003.Móvel para quarto	a97846fa19fc358fddc8ab963a1044da5517bb9dfa13a57471339b1e78cfb088	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.05	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7492	3101015.Móvel para copa e cozinha	0573dd7fc47683f7995fbbf54c083a86be82ebf047d72e8e080062362a08b01f	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.81	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	12401	3101016.Móvel infantil	8112b57ce964abb84083a5fbdf6ad94c0f3c29da029813f7a9c5a582bf10077d	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.51	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7493	3101017.Colchão	43d91cb4994a437dadd8dbeaf27ce1d534aac9b2c36ad53b304ed08cc5127cd8	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.32	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7495	3102.Utensílios e enfeites	f26772c12c2f7a6c215097f7716d69900d8ef1485d7744f09b098ec55692849b	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.47	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	47638	3102001.Artigos de iluminação	bceea6efdbc23c3eb920c920192bee858ae4957d0fc4bf30ce14608494036697	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.33	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7497	3102005.Tapete	77f93c83a23f3bc415bbffe4d6469568e0367790c8db7827990f06c8bea04830	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.23	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7498	3102006.Cortina	fb26d6697625d8929052af48caf525a2b15800e373a81f6d518c95246c86146f	2026-03-13 18:44:13.621322
1	Brasil	2	%	1.35	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	12402	3102007.Utensílios de metal	0c186a2f2544c169c1069aaf6b5a8941752e9e2f8e1cafe30595df15740f51cf	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.92	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	12403	3102009.Utensílios de vidro e louça	caf718693e53e9d4f22aecf1fc24463f285dc47dfdfc6dc4227d7561e5cb64dd	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.71	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	107645	3102010.Utensílios de plástico	7c240cb9b041bccfc30c5e68b2f850a3223b7eb1aa919ac3cc81409c999dc725	2026-03-13 18:44:13.621322
1	Brasil	2	%	-10.84	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7508	3102035.Flores naturais	db42078554fee2198d7f490e35d6649ac8636fa020ce9898f5d4e042da3906a1	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.55	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	47639	3102337.Utensílios para bebê	b66e02e27ba1d1efa06942c1e6911d0025ff3d0a8bed5d42866f1536405fd6d9	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.47	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7517	3103.Cama, mesa e banho	939c0631f111d33cccf2bce482288bcaaf634f4082276a40fd01da0046a0e2b7	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.43	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7518	3103001.Roupa de cama	1149f7430a057366f20ff928e1aa9040dfb9fc528e0d019e8c7b2e19bb8f0329	2026-03-13 18:44:13.621322
1	Brasil	2	%	1.68	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7520	3103003.Roupa de banho	7f8b1680a46df5e37bc4b3745bcdf796c83cf87416bd873ce6cc64454bf2e5e2	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.29	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7521	32.Aparelhos eletroeletrônicos	085ed5ccb014cdd08d6d9ec53f634fd5923241c2739d272078c27ffcd607b4ef	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.13	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7522	3201.Eletrodomésticos e equipamentos	27a082ad0347bef79401270aaa4f483ad4eb31154af678e2eee269c58ef3454d	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.55	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7523	3201001.Refrigerador	bf4735fc6922d9a52f2c0fe26d547a8c44bbf887be90eceaf4d219532e3d8319	2026-03-13 18:44:13.621322
1	Brasil	2	%	1.56	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	12434	3201002.Ar-condicionado	c6b43fff6d1f514b54034ab44f0cc3925b83a443f0eda966002e160af0d070cd	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.43	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7526	3201006.Máquina de lavar roupa	978a50086ff9d75533a7ffc11dcda2838063237465a0dd707621f690e741c2c9	2026-03-13 18:44:13.621322
1	Brasil	2	%	1.00	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7530	3201013.Ventilador	49d6135f49434501fdb455253b6ac31038e9b39b7b8da5a1a8b2145628decf7d	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.23	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7531	3201021.Fogão	2cc2238f096202237170e412d4a1e371324878c778fc587a81a94988e02f9de3	2026-03-13 18:44:13.621322
1	Brasil	2	%	2.46	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7539	3201050.Chuveiro elétrico	f17ffae14a629c6f6832c2bcaa394ee0ca4cbab433c899bbc3e580c2326c7478	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.89	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7541	3202.Tv, som e informática	bc11ef3d849a6e11f10be79cae212e75390d53d7f0711859c79e4cb4739383d6	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.33	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7542	3202001.Televisor	bd7f5316d110536446176381fc02ac21f9f9d9d3fe9f79b4e5e74f4e77a3b56b	2026-03-13 18:44:13.621322
1	Brasil	2	%	1.40	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7543	3202003.Aparelho de som	8f6b3abce8a44e51fdcee9bdbc0d21e154655447ee803f1b41a39b4c0aecfc57	2026-03-13 18:44:13.621322
1	Brasil	2	%	1.51	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	47640	3202008.Videogame (console)	e0bf0b38c97f2a8d53fbdb6354295ead5d478ce1f7699c54579d682cb0788723	2026-03-13 18:44:13.621322
1	Brasil	2	%	1.71	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	47641	3202028.Computador pessoal	e149a155854a21134b826d5e9ce13ce8fdef5150d6ba9f29d08eb0aa516d0ff6	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.52	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7548	33.Consertos e manutenção	dc46811b8a49495304c8588e943bc54b04d42b6e9b5b2f9f522e41a720196898	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.52	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7549	3301.Consertos e manutenção	1e9b1ae5d729ae426dd312794f373d2db5de8b6f1555daff52be69cae2e28074	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.07	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	12405	3301002.Conserto de refrigerador	82f42469b1c915bb655ec10fa940d821e7d9c2cfcc719b7107590415c129d29f	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.25	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	107648	3301006.Conserto de televisor	05a56aff0788b333d5fccf1f01c9f194d0a57e3bea1877c1994a3a2a16c7f4d2	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.94	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	12406	3301015.Conserto de máquina de lavar roupa	2ea688d165f49bb3d688f383dee3e8f4d594c3a04f619f76d2d9a9e1f841e6ba	2026-03-13 18:44:13.621322
1	Brasil	2	%	1.19	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7555	3301022.Reforma de estofado	d4bb241a78b889a6e515c36f20e4c58dccb7632637145f8974d66e4885cfc69e	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.10	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	47642	3301088.Conserto de aparelho celular	5a02eb2c4b7a9a05254522f2c5e2a7e17bf5eeb77219844e15cc1237be13b88e	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.51	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	47643	3301130.Conserto de bicicleta	6ebed8af2bd3652fceef92e8b3f31c43e5e481e9001e0578c8ddbe9ffff2851e	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.25	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7558	4.Vestuário	98f45a5722be32965e5e170bd700b5d6e3116f511c48b9ca0ca6a57334aea38c	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.68	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7559	41.Roupas	bb0818c64b4622902304bc947103503971e9d46d55b7bbdcfab6224d01f4d451	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.51	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7560	4101.Roupa masculina	2105e11d9e8111e7fa1fe386441c1849ea6fd18b1bde946aa56bbb5e5ddbf556	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.69	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7561	4101002.Calça comprida masculina	7560eaefed497ec6953d2ef9fa83a472475acf792bc7ee42918ed22fc034ea9d	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.01	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7563	4101005.Agasalho masculino	d7415fff10bcaeb5541f8427e13ca3b89c83c5e545fb2855258d516644cebf2e	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.94	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	47644	4101006.Bermuda/short masculino	97f066a6563e0e6a4393b8491353a3c9333f14d40b02451521e83e47a301cff3	2026-03-13 18:44:13.621322
1	Brasil	2	%	-2.06	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7565	4101008.Cueca	f3e7344812f561021da64dc6717ad15322da5300b0efa2753ddefa88ca7594d3	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.30	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	107649	4101009.Camisa/camiseta masculina	a259e56f59b9cc37e40d9e78c48809e9718400c2e3c03c7291dd91548507d222	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.96	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7572	4102.Roupa feminina	5b8bbeaad25313162577d654589bcc0688b7425fdb4e033cc57d374e17252a14	2026-03-13 18:44:13.621322
1	Brasil	2	%	-1.64	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7573	4102002.Calça comprida feminina	4706cdb606de00fa512ab528a350c96283b6d52a78a50b0b19125ce9f088c14e	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.82	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7574	4102003.Agasalho feminino	8c99780f5024f8ddaac9cf00b97651178b68857c0945fd82b2ccaa18d0b849bd	2026-03-13 18:44:13.621322
1	Brasil	2	%	-2.20	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7575	4102004.Saia	75e400efaa8816ade64a182a7695d38ff322ebb4e701d7ba2a99f4335d503376	2026-03-13 18:44:13.621322
1	Brasil	2	%	-1.68	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7576	4102005.Vestido	78a925218a83da3c0b4396325c91b2b5b18112ac7e15f0e90565ecde336b4ee7	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.52	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7577	4102008.Blusa	90c0c13220e01176fed22f9cd144e31f7c871567efbf8f0bd745c1483d2af9b0	2026-03-13 18:44:13.621322
1	Brasil	2	%	1.05	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7579	4102010.Lingerie	d383e3b5122aa654067183dadb36029b615489428049a5aacbfc3d9f7f6b1c25	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.95	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	47645	4102013.Bermuda/short feminino	e51f4dfbd79cc0efe50fbee092abf4f21fb7f56b14421087d0aea8c1283da471	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.37	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7587	4103.Roupa infantil	48a83b51ce78cca874e52f07240805257d7d5409cae131a2463657fd8f345d48	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.60	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	12408	4103001.Uniforme escolar	46c7df99db99f372bc5bfb8a52510766a6fae6e946f7a174b0dc372d4b72b5a7	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.06	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7589	4103002.Calça comprida infantil	0ba92bc0a7630699f26664c6d5a34e37156e97f2878a4f8c928c8e8df5df8c1b	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.20	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7590	4103005.Agasalho infantil	48354d464f50869a5d3ae05fd562350a6939d4635e244e245b87b72681d0a208	2026-03-13 18:44:13.621322
1	Brasil	2	%	-2.44	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7591	4103007.Vestido infantil	6cdfb6dcb9b3987a1479627016653105d3d24549e2d442f738a85c3c98c7247e	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.05	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	47646	4103008.Bermuda/short infantil	8b17676b501102be23672ac596b249b377debd4fbfaa9a9e887d4d8f8b77ddd6	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.80	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	107650	4103011.Camisa/camiseta infantil	790e00505f0973959f5df50c01492936473e1cfdce4abb53c374a0193a599c83	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.04	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	12409	4103031.Conjunto infantil	fe3c0f3cce6d0c40188b32dbf51b08350ea47aa5027442eb168a00d8da8b3827	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.28	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7604	42.Calçados e acessórios	24c879bd9e1a097941f183f157ccb1025385dd6e5f417130a9a58350137f189e	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.28	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7605	4201.Calçados e acessórios	8015f6942bc623aa1a2674094b63b923afb8829f4dc3fad3d1f7ccb9285325c7	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.11	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7606	4201002.Sapato masculino	dc3e0a1129bd3ca2217024cd7bac71779e3bd951c12cf1d924823d6b4821b8bf	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.15	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7607	4201003.Sapato feminino	0d0b9ea71277d852e0a477527e45b1affdd005eb547e48fe8a0a3a65a25b685a	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.62	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7608	4201004.Sapato infantil	e73690050ee73718502ae3208384c0a424a9cbaef22ea061775f5f86557b1b7b	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.21	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	107652	4201015.Bolsa	95080112f932c905be2f8233ddc828ea061acb617843cdad8216c8d1dc5f237f	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.45	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	47647	4201040.Mochila	cbe980c1ada69c09c762251e6fbca910bbffe3a6f810da7b2e371a5ca79c0d24	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.60	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7614	4201063.Tênis	553332ac21f7f466094182769b01d04f1aa049e70d3d8d4702f3da5547af6c13	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.18	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	47648	4201098.Sandália/chinelo	0cef645a97d2c14fa7aa43c110607e4f3218667a7a04edf08d220e99fb199668	2026-03-13 18:44:13.621322
1	Brasil	2	%	2.21	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7615	43.Joias e bijuterias	611ba604d2a021978f41776c73cc8baa99970cafb4f1b25a0457d76c53dbd0ce	2026-03-13 18:44:13.621322
1	Brasil	2	%	2.21	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7616	4301.Joias e bijuterias	b7278d6f01c4976d2517e8236f848213e07a080d1c5f8ccb38a44075e37da4f0	2026-03-13 18:44:13.621322
1	Brasil	2	%	1.14	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7617	4301001.Bijuteria	c77dca21e8d0e806228fbb81c884d104317416f9cec8cd85b6e453d52dfd3074	2026-03-13 18:44:13.621322
1	Brasil	2	%	2.53	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7618	4301002.Joia	ddbe38b9af825febfc533671ec579f067565568d97246d0ff765dd6fea2539a9	2026-03-13 18:44:13.621322
1	Brasil	2	%	1.32	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7619	4301004.Relógio de pulso	7d846a8640c42dc4196868e5629dbc4e36d0f398826d613ba5c2cb20e0c94002	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.29	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7620	44.Tecidos e armarinho	f3f4d49ef8001eda50c99ea0958cb23bad2bf687e4ddc072ec4fddcf0b948a1e	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.29	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7621	4401.Tecidos e armarinho	e73f212a002a712c818f2300ac30d8ae0ee80cbd578ba74a81f3d5be2cfc4c60	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.16	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7622	4401001.Tecido	ede36b2802cf7d67b31db1845494e78d566ac818c7461a3b467da6ea5bda384f	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.84	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7623	4401002.Artigos de armarinho	c465faa3fb2ac0e9a4ad8dcfb613c49b367120a80f8b03798aa209d97874a668	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.60	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7625	5.Transportes	2d2298efb5e92501ef3ef8f36851b8a5399cbc1168bbeebcd6c32286b4df0375	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.60	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7626	51.Transportes	a0f793044dfc96567003780941aac980035b93fd5156d624fcaf0fdffb890301	2026-03-13 18:44:13.621322
1	Brasil	2	%	-1.64	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7627	5101.Transporte público	d30f877ef9014db442822414472f0d83ea8bf326a7b7f1902629f4362f53c746	2026-03-13 18:44:13.621322
1	Brasil	2	%	5.14	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7628	5101001.Ônibus urbano	fbd776c3f2c6dfe948955f673c9422a9a132b8b6aae96d6887fe1f4bbef258b7	2026-03-13 18:44:13.621322
1	Brasil	2	%	1.47	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7629	5101002.Táxi	4caa235c1e2a79a51972d2c12ea9660494fae603ea81454e9e4eb4c374028a3a	2026-03-13 18:44:13.621322
1	Brasil	2	%	1.56	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7630	5101004.Trem	6b1c6c0f6810f937f9975b4f73d5d8aa45a66becb226b9fdf7769353a41e95e2	2026-03-13 18:44:13.621322
1	Brasil	2	%	2.52	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7631	5101006.Ônibus intermunicipal	2d401dd2bd0a8421ba0347d4afafa7174133e96606d287b42f38cc97ff0b42c2	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.98	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7632	5101007.Ônibus interestadual	1091f4d5c9c77be5b7f4561b298a2d63d60b7a4f6718180df45c159598a14189	2026-03-13 18:44:13.621322
1	Brasil	2	%	-8.90	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7634	5101010.Passagem aérea	b39acf288de30d18ec4b6600cc7620397096bc0f34b924c4f5417ae468ba2bb2	2026-03-13 18:44:13.621322
1	Brasil	2	%	1.87	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7635	5101011.Metrô	5dac8f678a0dafbf0a61fe8d4c179a724b647f83e47e5d274d031c7aa1c8e6e1	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.28	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7639	5101026.Transporte escolar	c28380b608fbac7cda0c9ed520bf5ef70a190cf0a70894e5b8b2fce88a5876b0	2026-03-13 18:44:13.621322
1	Brasil	2	%	-17.23	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	47649	5101051.Transporte por aplicativo	cf4c892889e6f97196a15b64661b76c42296861c899e6a0d27ea45de70836521	2026-03-13 18:44:13.621322
1	Brasil	2	%	6.88	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	47650	5101053.Integração transporte público	b867bf819578fc29e3cc4f6492fbdc14b4b95183474131b655f8e5f98dc0001d	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.40	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7640	5102.Veículo próprio	526389e6f561537e386618b3d9b186c892241132abd79a31035929b80b02649d	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.81	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7641	5102001.Automóvel novo	d509a46e913d4717cd8097e3582a68186b59dc023997101a2691c4001cdeb1b5	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.17	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7642	5102004.Emplacamento e licença	a5c955013067927988bf271c92a92d74ab1a22e87c27d4a6a32e252a491b6cd0	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.64	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7643	5102005.Seguro voluntário de veículo	4b83f354159476c7eb3df86c2c23a71720167ed3a83075c4ed419a76b1d1751e	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.00	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	107653	5102006.Multa	89b59dee7d056470d5f0280eb6abb1f2a1ff86b86072c5d2d2e551601d1cdf70	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.01	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7644	5102007.Óleo lubrificante	82b49b00715714258fe6eda0534ba0401b6d55585f2ef091e0efa8d46f4de243	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.05	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7645	5102009.Acessórios e peças	4c4af6977dff247632114a65eef084eabd998f88c5ddbb4669cc3fbf33db64b2	2026-03-13 18:44:13.621322
1	Brasil	2	%	1.04	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	12411	5102010.Pneu	1d3946e0b36230101e2997817e9fdcb0fe7378563ed4df9cf344e35668fc3fde	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.82	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7647	5102011.Conserto de automóvel	2a9945c2f29a6a431473c107db234dc951f50f16aee0f5beb8d60e5940f7aa01	2026-03-13 18:44:13.621322
1	Brasil	2	%	1.32	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7648	5102013.Estacionamento	a4704c0d132c98ff98bf11cdc00c09c902c122656d77bbb6a3e66da0c6cf9e55	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.42	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7649	5102015.Pedágio	c47efbf68ec615203c7d98a2c415f21f1c5273ff90c85fd08d7667702543d4ba	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.40	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	107654	5102020.Automóvel usado	669d7f9e1eca77a0d8a59e72a0c2d01430b8acb73a6840ca084d8f15236c35e5	2026-03-13 18:44:13.621322
1	Brasil	2	%	-1.60	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7653	5102037.Pintura de veículo	4695936ae35c2fec19425be6e10d7c395eeb3c19b08fa8eb1cc65d6c3918ad59	2026-03-13 18:44:13.621322
1	Brasil	2	%	9.65	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	107656	5102051.Aluguel de veículo	f8e5fd9c7af80c1c8c34663a8413d75c250f64dffe616b1a3ab03ecb5e7832e5	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.60	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7654	5102053.Motocicleta	6d9cba576a1fd183b92e816297885182a7eab50bd54c60781e53fdb37113e6c2	2026-03-13 18:44:13.621322
1	Brasil	2	%	2.14	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7656	5104.Combustíveis (veículos)	e27d2019367525d0aed57b5591dd00f03743e19bc783b8033ad70ebbe8c48188	2026-03-13 18:44:13.621322
1	Brasil	2	%	2.06	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7657	5104001.Gasolina	b2a0d47462f25847c7d727621b6e9dee45011a01adfa530f818667de66b823ef	2026-03-13 18:44:13.621322
1	Brasil	2	%	3.44	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7658	5104002.Etanol	5425e39064db5c214a2e0896da879259207ba004acb446f962c297769da0774c	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.52	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7659	5104003.Óleo diesel	780d95d00c1e0b6b4a74517f11feaa9029c53e40fd85d08fd469f60946803da6	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.20	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	107657	5104005.Gás veicular	c2252b94ddee441de86afb06f29b6597c25ee3e280f81b13d5fbac77aac8d910	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.70	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7660	6.Saúde e cuidados pessoais	d283f4e1d5feb1407fbf56c118e04e88c36af54de78006c74432733db9bec478	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.25	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7661	61.Produtos farmacêuticos e óticos	3f599d66f1eb8ed11d5e04d7d10836ae5ecf3bd4df3b9058081994678186a1e3	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.18	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7662	6101.Produtos farmacêuticos	435b30ec59b97430863fa9421900cba9f139ece2c38ac8c7199f859f5ca6cd64	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.40	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7663	6101001.Anti-infeccioso e antibiótico	fce1c215d89858813c0cb072944b18f10c0e2de3795211d6154f68cbf15fc2f9	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.23	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7664	6101002.Analgésico e antitérmico	39e2d2ff5f23928e2c11ee634c1d0f7815d89e3e896b20d916a07beabf72f11f	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.19	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7665	6101003.Anti-inflamatório e antirreumático	2eb7241afc6328748d1fd6f083b37e0ceda6a634eba9b009b003ed9399068b8e	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.29	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7666	6101004.Antigripal e antitussígeno	dd7f3fded17e44a7918bca703c994dc97e4e05c93a76ea82289b6924cc6e43a2	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.80	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	12412	6101006.Dermatológico	82c47330a8461bb392ddb3efe7d53c1187e65a74207aab12d5691290a17e1cf5	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.74	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7669	6101007.Antialérgico e broncodilatador	82bd495ee70d6ed3811594d8007d5b03a8bcf5d23c5b22c9d030c06db0caa910	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.25	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7670	6101009.Gastroprotetor	662f9de059e7764ad80967c3abfa31e627400de288e34a90cfd28ea6b2061dcb	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.26	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7671	6101010.Vitamina e fortificante	1203d9f4ad84fd52f718c4b266385718e02cd98a036fb07f7726841e8f12e758	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.24	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	47651	6101011.Hormonal	9637c49016fb20af2955b032bbd6f1dba140d2fbaadf6de0c931e2dfa67f2a92	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.30	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7673	6101013.Psicotrópico e anorexígeno	c70b6e8024aa95b5bd42912560dc5325352352ae58765f23c011f61583981e5b	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.10	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7674	6101014.Hipotensor e hipocolesterolêmico	ddf99d6d247bb28678b11b21aaef422ad006cfd14ad29e85a39e6ca4b3f72e8e	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.24	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	107659	6101051.Oftalmológico	53c46a3d3e74996e3413ef32ed63dcdfb3a46e6b42aa6929b4f8471b4e61aeb0	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.71	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7677	6101064.Antidiabético	964ffb223cff760ea258edca98afd5ee56de017e87ebf31a051ff4ae62f9be3d	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.24	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	47652	6101148.Neurológico	51b67eb3fbfcbf22a5650a0814e0ab27e08b4cb2890f8669ae6a2d12cac62f0a	2026-03-13 18:44:13.621322
1	Brasil	2	%	1.20	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	109464	6102.Produtos óticos	9ccd323382e206ca886d380cddee54c77b7daeb4c066534bd631ff647437d55e	2026-03-13 18:44:13.621322
1	Brasil	2	%	1.20	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	47653	6102012.Óculos de grau	4b5a75673c6864fcff257f19bbd9898f9d048d9564bc80004af257a293f37123	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.66	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7683	62.Serviços de saúde	cc6f8c1fc3f0308a71792c2276de16468fd044d51ddce6489d9e0520f8875299	2026-03-13 18:44:13.621322
1	Brasil	2	%	1.05	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7684	6201.Serviços médicos e dentários	72a702de701af7feb37d9917bdc8ac37372c9cc4c8fa1822b190289ce08bd8ae	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.94	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7685	6201002.Médico	e753be3405e1424cbb3550dd7d06d04a33b6650f629017a5f2e08c4a8f69e958	2026-03-13 18:44:13.621322
1	Brasil	2	%	1.12	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7686	6201003.Dentista	37a218cc5737c31aafaee40d0a6eab5e801ab197de77b31c5ce5d7b01673ca34	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.33	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	12414	6201005.Aparelho ortodôntico	3eabaf2e8f48559b4a764132880db6a59afa1be550c59520c7dd876e0b2fcb2d	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.04	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	12435	6201007.Fisioterapeuta	02540c5ab7e598e83961590fc11e36a1651b5ee391924026e44a3e1cd5326f80	2026-03-13 18:44:13.621322
1	Brasil	2	%	1.84	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	12436	6201010.Psicólogo	d58c5a74689ee58266087eb0646fb2c64827af02e7d3eaf178c4f327a08cbd01	2026-03-13 18:44:13.621322
1	Brasil	2	%	1.04	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7690	6202.Serviços laboratoriais e hospitalares	f2fee085e384a252a950fbaaba24308f97d2f6a786d7b49749c41486034a7a63	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.87	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7691	6202003.Exame de laboratório	81d4137721b094ee6007675934da286a620a0019cb0bb2f39c559bbf47d5aa61	2026-03-13 18:44:13.621322
1	Brasil	2	%	1.14	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7692	6202004.Hospitalização e cirurgia	162ac0cab00484e75e12a617d88b15b3fa498e441e9a64419a53a5e297ed95f8	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.88	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	12416	6202006.Exame de imagem	7cfb5d0dc575222a233928cf62e335a1b7e234eccadf7c3378f8c2f16e39a1c2	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.49	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7695	6203.Plano de saúde	7611ecea875c00758938758cd81ca8972bfa6166770e83c484ca1a7f5e2a8320	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.49	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7696	6203001.Plano de saúde	051b37a42db5ddd433f33f53c399c296d5e8969c4f3794a5b7f52039c1c709f7	2026-03-13 18:44:13.621322
1	Brasil	2	%	1.20	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7697	63.Cuidados pessoais	4630532c858e0b906eed435a285879ebb6dd8ac36977ebead45537e130702f41	2026-03-13 18:44:13.621322
1	Brasil	2	%	1.20	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7698	6301.Higiene pessoal	7c8ec048209b6faec7133f220918c7dd419b521fd19624a9068252f389ec938a	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.34	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7699	6301001.Produto para cabelo	a46e49986a70b7a8f5c3074d8e003d7689089a9d2add8c516addf5a4499654aa	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.59	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	12420	6301002.Fralda descartável	77c8a9b75c2bdc436eae45b34e9625dfa7bc56e01d47c0cc056fbd7910b94b0b	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.67	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	101642	6301004.Produto para barba	4e7d84cd2c944c4592fb9d8856e6b75bd246b7d389c923f8a797106cebd0c46d	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.12	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	101644	6301006.Produto para pele	824da03e2bb690da4f7146b98a5b16e59958ba1980f7d2bbf6582e6e89cc269f	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.93	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	107661	6301007.Produto para higiene bucal	3e29977534738a1887283a52dd4d5cb94a06396e9d0ab0721e7ba60f389c48bf	2026-03-13 18:44:13.621322
1	Brasil	2	%	2.68	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7703	6301010.Produto para unha	1368b924e0107e16411a8032c9915869aaabd6c5def85df6ece428e8a71bebd2	2026-03-13 18:44:13.621322
1	Brasil	2	%	2.94	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7704	6301011.Perfume	23acd64e1dae756d55024056bcc93de00c841c029117d24dd62d8ebee43ed471	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.93	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7707	6301014.Desodorante	bd33c93ade229e23cd2dc98fcc258f31eb930a886f1b68baf9e14fce6aae9649	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.53	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7708	6301015.Absorvente higiênico	77aae11a0179d01f1b28f18702a001db6944927016ee57347681cf69121f0b9e	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.63	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7709	6301016.Sabonete	0c6911d040c503d36355e58dc773130a5c972a0a40324d12391796b1daac944a	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.65	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7710	6301017.Papel higiênico	db3d52c437198578ad4aef4db191d147368ff42431ebb70485b0b5ec3d731b65	2026-03-13 18:44:13.621322
1	Brasil	2	%	2.23	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7711	6301020.Artigos de maquiagem	691f3fc22706a55f0b91bd651f1339cf7d1ca6de03ebbe47bdd349538959ae2e	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.41	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7712	7.Despesas pessoais	b088afe9cc373c5c98ee4e408f39e00a1f2560736638bd6b35d27d87ff31d7d0	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.39	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7713	71.Serviços pessoais	45de8b5dd8d789d9d94e8524ac308d689e77b0c7af7829b6676466891d70db32	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.39	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7714	7101.Serviços pessoais	c8f16f00be4929a88b748d4802fa819e17d05f2f68b80a4c5148adb1f4cf0b53	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.27	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7715	7101001.Costureira	77faa47a16a1e6a8fd71b6982832bc0432a494c6b21f55f002ca0f737cef34af	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.39	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	12421	7101005.Manicure	720cfaa13dff83ba39108e7560f51d7fc5997de1d6a9869cd1bc3d2211fd56e3	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.48	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7720	7101010.Empregado doméstico	4b3ef46131c1275449fe32f991edc827853b99d22337681681671066cdb181e2	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.71	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	47654	7101011.Cabeleireiro e barbeiro	cdcebd3f0cf3c8d61cd0b73bc92f3303868058cf3355ed0d6dabe11e03cbd17f	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.21	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7721	7101014.Depilação	ac386b8b5060d716bd0c598595f6ff355fb3ec724f4bfe41c599b2fa2cd57de1	2026-03-13 18:44:13.621322
1	Brasil	2	%	3.41	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7723	7101034.Cartório	56caae809d4bf1d8944c5f2e37129afcfb9dcc98d7f13eb60e8e7101c308db37	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.43	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7724	7101036.Despachante	07e2c3896b5ffc3fa6f95664936c3a6168264dafeb2ecc7eab2be56ece34feea	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.00	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7727	7101076.Serviço bancário	72ed102fafccd4e75d8fbd10ee585b9da70f0e76cebe9387555838d4ad74b6e8	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.43	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7728	7101090.Conselho de classe	8e230155773675f488e177ad19524f11a3d0adff8a56af181f7343dccc784ea0	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.20	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	47655	7101144.Sobrancelha	68d3dfb617300957551d52ea06ce14a85f6314282d324497ff8a30b2cfb426fa	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.44	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	47656	72.Recreação e fumo	ac9ad0e5ad1f89759098b4f92c03939f9d7c5a20cd7923a1355cbfc02d5ddb76	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.49	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7730	7201.Recreação	74202bd58acdcd179abe20b289b16456121ce93642ffbae8ac441cfc19211ebc	2026-03-13 18:44:13.621322
1	Brasil	2	%	1.25	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7733	7201006.Clube	d7b420abf10e694bf00e35c698093271cbe2e50bda3dd0138f34ed87cb99932c	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.57	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7735	7201010.Instrumento musical	604b232251f4d3dca8c4e892cbbe8e9a527d05ff6aca1ddbfe3f6f8b746ace75	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.53	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	47657	7201015.Tratamento de animais (clínica)	b78db20fdb6372834d24ec2f00cf31cef9194df5b31598b6627edce6f47cf7a1	2026-03-13 18:44:13.621322
1	Brasil	2	%	1.54	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7736	7201019.Bicicleta	087c893520ab9238f6c9283aee315ca9d618a992d1ca61ee448c74f082c13a56	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.38	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	107666	7201020.Alimento para animais	859eb508a9dcd9e33860a94fca7d73d1d13c51539931f6cdbca67e27897c028b	2026-03-13 18:44:13.621322
1	Brasil	2	%	1.20	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7738	7201023.Brinquedo	4c1d0f3410ed2ad8c7ac92ea247d1270fde8f54d4d3782f77256cf06ac295e27	2026-03-13 18:44:13.621322
1	Brasil	2	%	1.19	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	47658	7201054.Casa noturna	5ad1d9bda4530c886c43f384e8a6321b161036f49a9795566d9fe4596abea882	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.00	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	107668	7201063.Jogos de azar	34ca4a022e81116043cd7a04c6ff99a37ee964c52a05e68a5867f2426a47757d	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.79	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7746	7201067.Material de caça e pesca	1046d9a22c7b215b603ae270df5b6a61b79a44741104a323402e8b293052bfb8	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.54	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	47659	7201090.Hospedagem	48e9c65ee1abd187b75338ddae4bbda083366ddd536d20ebeb94afdf9db5d355	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.46	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	47660	7201095.Pacote turístico	77ff5fc5e33f1c58c7058704430b0c35c4b0a1931e3f86979649969ec6150366	2026-03-13 18:44:13.621322
1	Brasil	2	%	1.11	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	47661	7201256.Serviço de higiene para animais	0b498a429f96f17cffbe7d33f027ea01fa23c018a6ad87014ef3d46940ecb06f	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.23	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	47662	7201266.Cinema, teatro e concertos	2951e89e77825751d571b31d500c3530992a24850880c445decf39312322ff9d	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.12	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7758	7202.Fumo	1ea67c4267d6628d68e6584576f202b0eb36225b620e9d96d96c7db01eed5f35	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.12	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7759	7202041.Cigarro	75a0fc6dc22ca7c4efd60516121325b0ba040ff84184dc9e55d367e4a0b1ec70	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.02	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7766	8.Educação	4d6a341b78e66f206830f7a67a841fa4f09890dc08902a64bceda603650f47d7	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.02	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7767	81.Cursos, leitura e papelaria	446540287b5d52872d1e6268881d0b1274f8f995e152fa4447068eaa7401ab34	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.00	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	12427	8101.Cursos regulares	e3e15f51fe64f243057fefa81d70ec66627d1537a546e27d21fe3a260ef1c5e4	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.00	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7769	8101001.Creche	0a2a5d06e5296ba83425643898a7af7492bd4bb8d4da064e717a23e0f51dc28e	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.00	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	47663	8101002.Pré-escola	686e96e53f1f7ea49b7159071cf8ed2960292d510ec4ff5d0c8ce886aec844d2	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.00	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	107671	8101003.Ensino fundamental	06573d2c03c2af59ad95259109c5931175495ec3ee627ddb2c1e9caeeff4ffa1	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.00	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	107672	8101004.Ensino médio	a309e2c50921ee155d916f81bd846dcea719657ee9abd21dd68d7b316b6458e0	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.00	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	107673	8101005.Ensino superior	88c9eb75acdd53116c752bc24b0baf957e50308d990ccb94f86e1d71c60e278a	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.00	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	107674	8101006.Pós-graduação	9e4589c98d1b551931deb1b77aab3008c88220dfb3354433a151d4c2c37b5cf9	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.00	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	47664	8101008.Educação de jovens e adultos	5b50d99c0629a281b5264a54732104c60277464037beed68c4e0946999f7622c	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.00	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	47665	8101045.Curso técnico	6ad7ea2c4e56ef60278a74a3618c786632a24006bed39f541e09023744e22a3e	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.94	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7777	8102.Leitura	d6ba7c21cc9830c126c09b7a106f77074b4f92dde5248dc55788a5ffab982fce	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.35	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7778	8102001.Jornal diário	a42b54771191af495e04f740d97c12cc91800507f8def21792c087565cac697a	2026-03-13 18:44:13.621322
1	Brasil	2	%	-1.56	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	107676	8102004.Revista	e633912ea0d16738a58afd100a4156a9feb0ea3710eff6ffaa79af4911518020	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.99	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	47666	8102007.Livro didático	e3636e0dd7068d7193b03f1ca22095e186d3c9b2169f9fce8bcea8fe3b6eefad	2026-03-13 18:44:13.621322
1	Brasil	2	%	1.84	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	47667	8102008.Livro não didático	bc059906f2dbc851f579cf347560508ae456201cc93c1388e0a98d00f2a988bf	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.73	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7782	8103.Papelaria	1de0ac93d24f00eac64528067aac52a76c504e53f0a0e5343ca8ddb6cc05160e	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.82	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7783	8103001.Caderno	13f8374f8911ab2e91b8c63f219c8a7e24b794d9c3f040841cddf7792e08c882	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.67	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7785	8103014.Artigos de papelaria	ea9db4edd86aa7f2a735e8f4dfe18dd69929ce1f1c86a223f671d54387e17109	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.38	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	107678	8104.Cursos diversos	53c93d1a762a1b89f90d6de503d773c15dd65ffe2ee7da32627d49a12d92ade4	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.00	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	107679	8104001.Curso preparatório	72b2da599dfa9f422d10d40a6e35604d568f1f7234334f4ccc66f1b940e34f49	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.00	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	107681	8104003.Curso de idioma	4ecb4972f5412be83522afd0a444b940d2fe3e497a89a57fbcfda8ccee4f9503	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.16	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	107682	8104004.Curso de informática	b036868f4f9be8812958486509e240ad1c96e8d2d20f62a7b18b69ce86e67a9a	2026-03-13 18:44:13.621322
1	Brasil	2	%	-3.89	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	107683	8104005.Autoescola	050248287a57dc57c915137c2489a29755d66010443fcd16c655b23a0661f51a	2026-03-13 18:44:13.621322
1	Brasil	2	%	-0.21	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	12428	8104006.Atividades físicas	8ddc02a08e4de446670ee11f5fa4def5eef41e474b62709de4ffa651d422a7d0	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.82	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7786	9.Comunicação	be0d0377cdcd4455ca41f0c09d53efafaf7267880040b89b50b221a8003da647	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.82	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7787	91.Comunicação	5dcbca4a77d0949b2e4bb7d9c0fe2e23c0ffc8476063bddc2b7356735ce8ba93	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.82	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7788	9101.Comunicação	94443279e6d3355bfb8877c1cb3372e652e347fd6c0420b641ab20f138f774e5	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.00	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7789	9101001.Correio	344405349116005f93f320d5cf33a34c3700fbc88b22c5d92063051f4f54b0a0	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.00	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	47668	9101002.Plano de telefonia fixa	77af865dfba5329f7913bfc3a95a715ee3d8456c36563fb70d52ead2f6cc1a7b	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.24	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	47669	9101008.Plano de telefonia móvel	40b2bf34f45c638c7e846cadaf767e0db5f43ba7dac5c52e22aee9b68b497e77	2026-03-13 18:44:13.621322
1	Brasil	2	%	1.34	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	47670	9101010.Tv por assinatura	d6617c11250883217823d0ce0bcb8218820b77646336bf1e40efa7c31dda487a	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.00	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	107688	9101018.Acesso à internet	cb2524ddbdbed25078202a3e9a647358ed21793f354b583400c3bd36a7829d6b	2026-03-13 18:44:13.621322
1	Brasil	2	%	2.61	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	7794	9101019.Aparelho telefônico	0d90113888d3ec6af587149d48d7b7a24f27780d7025ff948c9df312acc82d82	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.00	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	47671	9101115.Serviços de streaming	04fc3d17c3505a360f67c070fcf49faf0d00d6245a655fd3266c6ca8cbbcd7a7	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.76	1	Brasil	63	IPCA - Variação mensal	202601	janeiro 2026	47672	9101116.Combo de telefonia, internet e tv por assinatura	91fd47de3e7f37249a4d852ac4c7848775ccf27094b43f5bfddaa976d2559e51	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.30	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7169	Índice geral	7ea21d1f941ce7ce736cf657215b5507c81f84fc8953747e508f903316aed172	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.09	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7170	1.Alimentação e bebidas	584761391eecef08a7c70e186b73d177de332d389117856ea217c84a70649e8e	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-0.04	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7171	11.Alimentação no domicílio	9cb6874269566e910497995753d09f1055a4ea4fcd88d1e1514043f80cf49751	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-2.79	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7172	1101.Cereais, leguminosas e oleaginosas	bd9f8394d202ab60eee3773d7236e308899c5b1ab98ca3b2ae22f10585d953a9	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-2.86	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7173	1101002.Arroz	23803fce34c086dcdcf148df69811578fe20f9862f89704adb2a734638d0f198	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7175	1101051.Feijão - mulatinho	19c69f3c7a934a729b0f0f6013ecd5a6b27ff6fc3e0d3d63ec37410b6036e637	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-2.61	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7176	1101052.Feijão - preto	a13df7ceaf5a7356079b0d1cf9bcb43ba56fcb788a695cf53e5e7874081fdc0d	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	47617	1101053.Feijão - macáçar (fradinho)	d80490f455843d2a11030d506ecabfeae6d7623a0ed099153c3ae7c6606237bf	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	12222	1101073.Feijão - carioca (rajado)	d923023663d907888304004e8279c9b8696f8b43def564201365a56d74749282	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	47618	1101079.Milho (em grão)	d9fa1ac008db984e6a3e8af806b42f788721216e8f0c0c3ac56ae6c39914f390	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-0.47	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7184	1102.Farinhas, féculas e massas	f796b625c728b0cee0cba0e3bb9e53f0e6df12a580fb2b2e4f5de5b25917c10c	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7185	1102001.Farinha de arroz	164a045afc97fc8b57206bb998029410e49b5b625d394c6c516af3cd25a2a425	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	1.25	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7187	1102006.Macarrão	3a191efe54ca5c94f71b89accd5d30d4bb10a7ba8e5d6337388ecb049a844aaa	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7188	1102008.Fubá de milho	f02c5970e5e7388a781aac1787a4f3351b9f5c7cefb3cca36639aa605baa743f	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7190	1102010.Flocos de milho	598cd62922d621916612bafa2f275c32c6998ca01444fa5007674f186726a514	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7191	1102012.Farinha de trigo	0f062eedeeeeecd4a2ccf56a45a28889e93b42f43b7d2b6893f160ae14b17948	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-3.91	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7195	1102023.Farinha de mandioca	6aa84389194b339a64d624cf271b31013089a4c21a6baeec667f209884bfba1a	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-0.42	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	107608	1102029.Massa semipreparada	5125fe225fbc20cf893b0d3745989450c2104bd6d8144a989ce2c8aaa4497066	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-1.32	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	47619	1102061.Macarrão instantâneo	004f65294a748d84ea189b6cdfb0820fa776df2883bd7be7a18a8da658c2faac	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	10.21	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7200	1103.Tubérculos, raízes e legumes	3c8a573a43602915db05856cd2d4181d82531e0b4aa293e3faaf1383887571f0	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-0.67	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7201	1103002.Batata-doce	4efa73cd22672422ccb38dddf082a9dedc03501ac1d6ec133450eef924b008fd	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	1.51	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7202	1103003.Batata-inglesa	6c65d1b82441f4d85d6d53dbb8be12980238701ead3a3fa04a37a71bdc283662	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7203	1103004.Inhame	34ec13f1aae926ab6f31296692e1ac6f18e3329221e8d78db749f34488362ba7	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7204	1103005.Mandioca (aipim)	cbd032bdd7037d8e107877f8f00eef501700e80c540bc55c8ad62b38541cb3a6	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7206	1103020.Abobrinha	a2c34386c003514f48e4930eead1dbf7ae0c6a91f82d4499befcba62ea6da03c	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7209	1103025.Pepino	fa3a6cbd6e6d643956323604d70eb5149c6be267f083f93ba135ef136e4e9471	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7210	1103026.Pimentão	00f6744968fb6c973ae70043858aff6f91dcff9b97fe417f3dc48ac25a810b6c	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	38.49	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7212	1103028.Tomate	7aa508367500def1881b6464d710a79c178bf99c1f72c4a7dded747b6b5a130a	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-7.29	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7215	1103043.Cebola	717a1412c719782744e2dff5ef4d22403edd94841978c1951a00e4fce4c10ee5	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	14.47	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7216	1103044.Cenoura	466734225701bee6ea36f11f9d7640716c09644570d26ef8a5d84df150f762b2	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-1.41	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7219	1104.Açúcares e derivados	9875da3d3a9ad6e9ac4c15e9017f5fbcb7550a1bb5549f05e299ec0f53568e00	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-3.58	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7220	1104003.Açúcar refinado	4334c2be4c5659d5e69d4ebda0f86daf843207bd16aac1539f039f151c0999d7	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7221	1104004.Açúcar cristal	9c5c04921a3c03f3dba5900b6b3241ca98c0237805161c9ee862153a88fdc4d5	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	12224	1104018.Balas	af8507a7f1515de1a9a339dfaba305e1ea948e627b27160c192fdcf142be6108	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-0.12	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	107609	1104023.Chocolate em barra e bombom	44fca45ae993342fa2d3006c2160afcca2049cae5b1ef43b2fa2e640daf23d32	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-0.32	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7230	1104032.Sorvete	181ae48dfacbaae39e0d2a6161635230740ee16f231fe74dc6fdb036154dbab4	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-0.62	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	107611	1104052.Chocolate e achocolatado em pó	c3367064b165c9da41984fdb85c6ccc308259aa041fda079ae78daf74a2bdb60	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7233	1104060.Doce de frutas em pasta	1ae3aee9863b665d8210a5fedeb1fb5bceb70392f97cccaccc430d797a6b1eb2	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	47620	1104067.Açúcar demerara	2f3df7cf850c134b81ee8119d7e3fe739d3ab8d5f0d4a3bf2c8d6611afdddff6	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	4.71	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7241	1105.Hortaliças e verduras	dcf1656c9ec8a2da8bc0db841288e3ef25b57635d06623ecb0da539501ba142c	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	3.42	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7242	1105001.Alface	1b299f0c08434fe3bdc20023a996272d3fb8ec5716e67d0f59f11e0cfe4af42e	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7244	1105004.Coentro	573a3aab64771f679b677dfe2fa178a1b401bc02d1be7a52790d41ef3073f8b4	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	2.99	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7245	1105005.Couve	f96d3af11618ce4a5512ae6ab6988630a6bba77edc312d680ef3e54b65d84268	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	12.33	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7246	1105006.Couve-flor	f04ed83706adedf0037c09780dae7781fd897046b7c727c026d0ad810bda8508	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7248	1105010.Repolho	77021af3b78f4447cd40b5e3adfc28b3ce7a693dc10120c0a0a152e943d0b0be	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	2.92	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7249	1105012.Cheiro-verde	4b0792f96e84044d3f6fbe465a06e073734c9b4cc2a9ebf0583648e5b58ab134	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	3.91	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7253	1105019.Brócolis	c2596633c9d3f3403d09f9b3dad15af79b87cfceeedb95570c295eef34e43907	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	2.52	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7254	1106.Frutas	2c04534b22dcc8cea1b251a7aa1f2f400303b5fabd1bcb62c51ef52326a207f0	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7255	1106001.Banana-da-terra	337409d7d73c24dc0311f7ba7f6cae57783528deca33cc1b99f9044b93ad5547	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	1.44	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7256	1106003.Abacaxi	256e8af08af1623200c6f5feb555af49789e96fa355c92a9c899e7eec580e8f3	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7257	1106004.Abacate	673fd4d77f2afeb9baa9c6ba45d01f780765a84d18747ca31508797aa5adcc66	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-2.54	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7258	1106005.Banana - d'água	878d4f2568af6c4ef2589efbeec3e60d1fb26c9aae43b213091cd41c3dc07d16	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7259	1106006.Banana - maçã	d2e8d7270253153abb9ca39a220dfdbc1ef12be828a9c547c3bab82e329144ab	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	3.42	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7260	1106008.Banana - prata	48a3a1b73305672673e81bf5ce1155bbd821173eac76511961cc96d05a9826be	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7262	1106011.Laranja - baía	37d4a3ef5bd09a48f8f0b60e25401218b8d111cb6d6ead85cd2f864a5e90aa71	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7263	1106012.Laranja - lima	e5094aa65bedf3876147d5905eb2220c3f534251b55330f4fea1161fd6b2e796	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	5.94	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7265	1106015.Limão	225cf66e5aa73cc75528285c3edc15c746c5aa375c17afb700d4b994a0b52e20	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	6.50	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7266	1106017.Maçã	69720fac619298e02c358ced8c77ef6e694fccca528bf46ce6dafb35beacab96	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-2.24	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7267	1106018.Mamão	120425ce234f2acd2723e63d6e4f15e21fcad33bd3c524d720f24f9f1f75c018	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.01	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7268	1106019.Manga	88c31a73441d3294273712864abf6de509c6ada43115dc98e1b182a5cd3a5f81	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7269	1106020.Maracujá	eb8af06d0e33379228aac6192f993d101877903db52fe441289c5f580d7ae754	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7270	1106021.Melancia	442c9e6e5fe5665dc7a4027ce565dbee6855c440875be40af806aef51555b9c5	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-1.54	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7271	1106022.Melão	1869a05fb2f35ed808c081e361bbd37a43d0eff4f2a7f29818cbc2b72dec8125	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7272	1106023.Pera	7d8630650653cbcc216aee0e1d8ec8aa3d2e2e9e795e3dcadfccfdc14adc9b45	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7275	1106027.Tangerina	bf47a74d7cdedb98b587a0006402ac54589ed496ad4600228ca25eada888a0cd	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	4.21	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7276	1106028.Uva	d0b7d78d719c2f4dcf619f8a3578442411e8f4b5b466a5c36cf12f16d6753f65	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	4.69	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7279	1106039.Laranja - pera	c136f4004c89dc6709469fb2aeefba8f9e16175637cf4e9b19e23a1228512a06	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7280	1106051.Morango	c555ecde593f4bbf0e7a2287beff81356e632fe252ae4b43d2536844c8011e7b	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7281	1106084.Goiaba	8fd457e337a0890bb855e9be22539b969e11512b376a0d9a6c02cee775f31404	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	1.18	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7283	1107.Carnes	ae03e1a88661adade0e0564787701f17c44eb7877996bfc18998faf15e899f4a	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7285	1107009.Fígado	b40400797e0b8bd8210d668091f487c18f245a0aa7bc60abb67a953d3eec58e2	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-0.32	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7287	1107018.Carne de porco	de830447b92b9ff7c3df7b8d1055a903c86a75b133eb88a53696249b6bdc2a55	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7288	1107031.Carne de carneiro	764af24302795a60c6ab77b6dda2950bc19f831a93082e13a34949144ecd7766	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7290	1107081.Cupim	2b940ee39aef3f3bae048da4ff3c628d4db33d09fb166420255ec996204b197f	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	4.94	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7291	1107084.Contrafilé	9747fb2f45b7368fb2d7a179b7651fee290fc9ea22c647cbb6853b333f5c6af9	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	6.87	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7292	1107085.Filé-mignon	7f989cea9403364358acc103465d2614faf18e7928713c1add68354d3a3669e9	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	1.86	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7293	1107087.Chã de dentro	4095979d15ddcce888dde0fd205dadff5752cd9e1ef51cb1df9c42d61222394a	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	1.91	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7294	1107088.Alcatra	b6e8175ae06033a235acdf7f793ec332cc177d4743f8488fe52d69f3d9d0f887	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.16	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7295	1107089.Patinho	a89cb1b34ee4c4564e1247c833a34346d8d5c3a954c4d4f5fc681fbac6a2b620	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7296	1107090.Lagarto redondo	7b712b2d18746208b49e8eb8396b3260bb1943f6ac933cfa5fad60a822d411f5	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	12294	1107091.Lagarto comum	53e4dd749e37c174a8ac7615c4f562d18cfe0b3da82977a8abfdb67aa9ba5637	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-2.35	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7298	1107093.Músculo	a1154f277107f7f2637efa02d871ecaa29dfc16b8bd9b2a687044eeca010cf24	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7299	1107094.Pá	9d9ddde4de1d90e1a8943f1919fa0746835501c16f564b0c4016699b6f91f3f3	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-2.89	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7300	1107095.Acém	8a8d41e023bddd521b0f09353cb4c35ead6769bde87eb135b35c4e1050fe452f	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7301	1107096.Peito	436f91e7e945534ab091f84fd4757cb76582927e74e487aa82f07baa9437b355	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	101448	1107097.Capa de filé	25224aa6ccced182171c517ef36a27a5ab25b39d24fd41b1972721c926db8312	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-1.40	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7302	1107099.Costela	313a9bfd61bc76f48b55c6ee08fef055299e721e1549e4a40c0f3a85e87a0b47	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	47621	1107208.Picanha	2b80babaf7f0b860aa2494d80f7710b3e6f2afe941312bd2b472eee61b8fc14f	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	8.59	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7303	1108.Pescados	60e83506f3f644db8ef7afd555fc9414f5b2416d26b79098bee80c0c892c592a	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7305	1108002.Peixe - anchova	4a66b005013b5ded5fb1b703c080d9c35cfefac750c98fce40efc2acfdd507cd	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	10.44	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7306	1108004.Peixe - corvina	f2c87c3dacbae1c3a5e4a8739ad76a3becc64f818b08f4e1db515af0e10bf6a5	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7309	1108011.Peixe - tainha	8426a8e08845b7a135e9444260df6ffe24ab9874cdc7bb7f1c77fbd229b36af8	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7310	1108012.Peixe - sardinha	f3d62b65a27f0f6820972eb18e4ecd3bfcfb09e7734f69198344bd1a93904b3d	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	2.28	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7311	1108013.Camarão	62512f3e5bc3b774ed8db943b9ba20c58bbbbf4c5bc7bdb0637df8e7c2dcd35d	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7313	1108019.Peixe - cavala	1ec1bd060090b32077e9a6805809ae2484c2342180910e6c45d157b2dd7e516d	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	107615	1108029.Peixe - cação	551ee74b2fd927e2dc83f0300d9f99398f7868177f7b8281478eee3148bbd4bb	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	107616	1108031.Peixe - merluza	fbb7cd0e903610fbe383c745a18238fd84989820fde1da273668123d73799f63	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7317	1108032.Peixe - serra	eed79ac30ddbcd8600ec61a111f22ac18e2a54388b4ba71dd9894bb70b85411d	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7320	1108038.Peixe - pescada	bc3eb532f06aa8641da372ef69541fbd3382b33ff12fb029de0ab20242fed4e3	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	8.59	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7323	1108045.Caranguejo	896b08b4edb863843abd319cf8f3bdde60eb1ba98aeefa9fc9460f78e63463b3	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	12300	1108049.Peixe - castanha	5c665b87e8f0a1fddaad3a8f786cb3e3f33152d140601b7508c1eb481794ab61	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	12301	1108052.Peixe - palombeta	1d750c91d8a8360396112ba2643c7a442d53c7f499ef41c4fb0bd55510cb85ce	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	101466	1108072.Peixe - curimatã	1733a3f4e2272ff091acac719e4891b1ba33d3601767befd428beb668685a7b9	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	10.74	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	12431	1108075.Peixe - salmão	1a438949c9f48a133bc744c0c2d3e5c244cb31cbf22463dd8ddd1ac999326290	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.70	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7169	Índice geral	e6c6790b7ae4753b837c5aa8ab72f16b1c3e3d53cd9ee979f3e14ff2a890a49d	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	12302	1108080.Peixe - tilápia	0b8e6d3b984382dfb2de75cf159469dd2b23df15a67305b4a9570e20a94320af	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	41129	1108087.Peixe - tambaqui	96db67dab38db95c1e5d98a63cfac06ae6c485497fe80bfb7b6009900e8f82f1	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7333	1108088.Peixe - dourada	8b8f9a5df4016088b537b4ee549620fef8c1368ba428320f9ccda6ae0eb2b802	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	47623	1108092.Peixe - filhote	d477e17e2804d17e704da0a0963a42ab8a29a96bbee3cd366e2201091c755dba	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	8874	1108096.Peixe - peroá	5b642d9828d110ebe895a7f25c2df22d61d91135e5802cc46e81632b7ff00a2a	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	31694	1108112.Peixe - pintado	e450c69a5af34a88d59fd71b9923c5ac1069ce2fa77ea2561f56725f48f8cbb2	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	47624	1108125.Peixe - aruanã	bb2ec3f52e7c77564583a4dfa896944f26ebbc57e7c23fcd9b1e6d2ac1efd03c	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-0.49	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7335	1109.Carnes e peixes industrializados	f49948cf95c197991477cf652b284e9c4ac519ceeefba51485fbfa370651e11e	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-1.66	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7336	1109002.Presunto	9ad3a6f271ccde00df9234e74e1cfb07ba29e0e9cb1736e645847cce0d87b4c3	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	12304	1109007.Salsicha	8b652b7acdb63717cf5796e1a8dfc240f2ea9ccf09e6bf5b806275027ef493b2	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-0.95	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7339	1109008.Linguiça	2ada8a33217ef3b1b29ce450dddfbc5c364814526bc8c99df459e5d9ee340d57	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.11	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7341	1109010.Mortadela	524b70ef405c73bb10d31d8f6fb9de8e25d530d13a02c2227c8e0c560cad83d4	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	12305	1109012.Salame	690244f0394fac3027087f63e1dafa9299c4f2a2e868e1399193ef8aec3c17e5	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	1.92	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7343	1109023.Bacalhau	1129ee8636ad045d6abdc6fef39cb2a7ce5d147435343c27aba5536a6af3433c	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-0.60	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	12379	1109056.Carne-seca e de sol	25b13394e093ab3ce0d49d21846ac7d8c64c108ffa592513490527fd71c46bc6	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7347	1109058.Carne de porco salgada e defumada	7efc8f121d575bdec2db8392219a1f4a140a2f92c20fadab4442ddfe4a4b597e	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-0.51	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7349	1110.Aves e ovos	cdc828387614d30b13fba87da8aee48fd4d7831a3c7da1da306b22b19bcaacf0	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-0.38	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	107617	1110009.Frango inteiro	8b1703d48cb40ff47590d7f11f477f3ec5f3e2c47d3387b62c333b2e50b50edb	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.45	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	107618	1110010.Frango em pedaços	a2d1dbfd4d4c39b1e528055a76a91e24f1a2aedcd2304d4c332a04503bd5e654	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-3.83	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7355	1110044.Ovo de galinha	fc40a7bc3000467e8a094a9c061317fdc89d8807f4e82454c032dca29315e2c6	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-3.39	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7356	1111.Leites e derivados	b67175571c0443208b9780d878f6e6499d39d7cc5a4584f553c7d12e371dc691	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-9.77	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	12393	1111004.Leite longa vida	acfe12c9dc2fdc15305de23ea962fa92c61ac2fb9c44f8aa942584d62f889381	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-1.78	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7358	1111008.Leite condensado	0a0423455c060f866862e46df9bf833607a68282cc262a7ac817c22a6f0f6403	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-0.79	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7359	1111009.Leite em pó	dc450ed59ada436709efd249b6211007c3fdc0315a11f2854c2836323ca74aab	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-0.87	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	107619	1111011.Queijo	4faa1ae3159a95d6cf5bb42e9ea9de09d16ba57eba25c1cafa9a414e3720453c	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	2.24	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	12394	1111019.Iogurte e bebidas lácteas	72f2a608fa3e4e6dadc4b0df6165ec8a8e0ad28426453bf97e22b4b40d2f7df3	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.44	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	47627	1111021.Requeijão	b50893246df6a6429411d2c7bfc84411eccd70a3f5c14fdca6e14eb6cd7605b3	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-0.92	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7367	1111031.Manteiga	ccf018c3af747c9564c45d56ec1f99cb0fd9a88116d968fdd4b96a9bea716259	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7368	1111038.Leite fermentado	ed2e751361cbafb88e9944a2448dafcbec6bcdb32c75042ce25ecfe15c233cad	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.96	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7372	1112.Panificados	726f4e3e6b5a85401a1f7973233dcfe3fdc358337f9a722636bdf498c7e1d844	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.57	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7373	1112003.Biscoito	53378d8781a3c57b6ca4113891f0ae47b995291d37d97065c5807197ae47418a	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	1.40	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7375	1112015.Pão francês	2471a6fc076789ff4055471e5794de3bcce4cda41ae2a7a6f7b7edf6dbde4d5d	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-0.41	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7376	1112017.Pão doce	41a0ffc82cd14e977049c06f6529e79024c2c48823223b56e73cbd6d2f78f3a1	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	1.44	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7377	1112018.Pão de forma	258aaae75a4d54e60ab6e3ea934ca92f623936f07ce640772af2a32d8938716a	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.22	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7378	1112019.Bolo	89c7e08654454caf6eb55394dd55de2265d07f7ef90d3f3d9ccc068a931f0b8c	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7380	1112025.Pão de queijo	1ba8636fe82afed78d1a975a5fd611bc72f588c03ec2b48bf18dcc549a766d9c	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-3.51	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7384	1113.Óleos e gorduras	b61df19daed3337196205bb0488b6d0c44c611a78e7a363f7a046b10e008bcb6	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-7.94	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7385	1113013.Óleo de soja	9cdcd5a5bd6d3b35c0548579b85f66816cb850a85bcfe545b5ffac75adc5ce3f	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-1.15	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7386	1113014.Azeite de oliva	8d9a4959201c054bc29dd42147900d48df0c43d34ea90d54a31c43c39a4ff504	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	1.27	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	12395	1113040.Margarina	d3a10230a668b1db3d865f3adddce57ce7b0212f21ff55cbb588c30a193d2e5e	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-0.13	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7389	1114.Bebidas e infusões	3b23cec022422c8c7114519be31fe0a20ae65ba501c121c3ca6284faa490cfd8	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-0.58	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7390	1114001.Suco de frutas	d188e85a17337d89a20b7ac837cd79430abafb15dcb2e54ed9b6a517635fa93d	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	47628	1114003.Polpa de fruta (congelada)	ce7c0aed6bb2732f16fa6404053cfe4aa8c896e2c5736e6c0ab0217a812a3065	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	12396	1114004.Açaí (emulsão)	6f90bc526b4531807f9a3099fedef3caeedd9da0656abf1b2108d7541aa2db0b	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-1.06	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7392	1114022.Café moído	15b6b2f390c88bbc9540b4473661968c83149163433cb1c73af3263c51258d3e	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7393	1114023.Café solúvel	a6a979c450d56c4cbc3cb0d9d7b291bcf6c443b16bf25300f0316878c8877ddc	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.43	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	107621	1114083.Refrigerante e água mineral	b354c4a0924d5d9bfb57cad29a434f99998576be1e10c32758c39f5a1ea7d3ba	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.63	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7396	1114084.Cerveja	e07277dcb10c1012e4fb92148b119bc856d4c9e8cb1d2711968ab374d590fd28	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7397	1114085.Outras bebidas alcoólicas	d76d2ecf2dfcf67b4f6455aa17b1233cc57e07c53e8bf5c3b41a8c9910a3f68f	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	1.02	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7399	1114087.Vinho	ece20d0308bda2893e7a88ff50ac1c07226b5fa81c3826a178d5280c549c899b	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	47630	1114090.Suco em pó	ae9cd0e2a285b6354cf2ac7ca24685e967ef497c27c1aece62885ad5d00edd93	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	47631	1114091.Chá mate (erva mate)	3e59563025f314bcd8ff15a44701c7dfcd0fb45d2657783f8ff82adbd6fb1869	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-0.30	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7401	1115.Enlatados e conservas	8107a2dde29aa9a531db89de4b44062e25a52ba174af00abd18431dca1a002c1	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	107702	1115013.Alimento infantil	a272bb8b31e4fd2d32c866787bf5859ceaeaced065f8e6aa821cd1d0d990eb24	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7406	1115016.Palmito em conserva	542cf42cc3fceffaadc708a22f73e785ae6261bd761b1cc5370e9b3387d5f1f6	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7407	1115017.Pepino em conserva	0a4e16e9817cb0485bb7b58f4c3ee72be8f63878b7946d01b8961cd1cc85a28c	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-0.81	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	107624	1115039.Sardinha em conserva	3a8b61848582ac08004f7b677072ee7d6f59a7912fb208a6670ba22dca26a4ae	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	107625	1115050.Salsicha em conserva	8010a686c60939a93d9e9155be4500bc3a49316374cf05d0ad57766f14376ebe	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7411	1115056.Sopa desidratada	585428a035b28c50e3d3c1b7069b8c958967e2f0e0f47c226e48dda0f180934b	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.68	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7412	1115057.Azeitona	88bebf1d8ee89766251909e45191e2aa80218332fab0f5f9a0d330e816db1fda	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-1.61	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	107628	1115058.Milho-verde em conserva	56fa45cb898f5480097c06acf0d1547544682698bc6f3baa3d31935005cfd662	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-0.18	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	107630	1115075.Atum em conserva	368e661d799631a24ba0d4915581e9e95efc58e79ccebb5f89af50db2eb7da36	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-4.51	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7415	1116.Sal e condimentos	528a4820af1830c1ed8db3ad150578ca17681381bac5c4bbb70dc234e136fa39	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7416	1116001.Leite de coco	4898804893cab9cf327e4b3d04f2a7e99422f5579cb05a7e46f01edffb05c187	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-0.75	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	109463	1116005.Atomatado	86e3c4e04fa7e42a539481b0fe64dc9b48575cb5b2f2c23b45ba39e5506cfd80	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-8.80	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7418	1116010.Alho	30113eb7314ce2ca91363e68be5addfafc0486fe81e23e8e978b84f183d1a15b	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-0.54	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	12397	1116013.Sal	8388526dc52d6802e21d18323c3835ea6f2e809a48355150ea296768d63c8371	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7420	1116022.Colorau	50691071acf8a266359a2ff1033fa7627496c5aa3dca8b8587157af7e9fd9166	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7421	1116023.Caldo de tucupi	63033b6a1cb2b885e43c6b0e009adf5a7a535c34e683d34269ebe98cc206babc	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7422	1116026.Fermento	ade8fc6f799e4bd59b7ba11e45ccdc5cc92974849b9238d6afb26c438baa791f	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-1.17	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7423	1116033.Maionese	6186f39555ff0f89e485d8ab1ede5af7c2a7c8bbd5076f3a06e7d82acde92dac	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7424	1116041.Vinagre	5a54a7afe88b04d4c096d6209ae23eafde640255c21b36d4ea902691d6df8481	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7425	1116048.Caldo concentrado	909bff77026fb7f9976f2c36e33efb643a34f83bd208e621f288024528427062	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7428	1116071.Tempero misto	df6ecfdf5f4bf73c6df16e43ca6d1aecbe126d1238b15a0c427023b1ebe33ea2	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.39	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7432	12.Alimentação fora do domicílio	3677031381c182318ed4e2419ecd6300221720e7ca275d4208e4d1818d7f60e6	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.39	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7433	1201.Alimentação fora do domicílio	a2f20cc05af52ac62c0e0857dbd1945c8c6d0221d3a5a08b6b5a2a38d4a363df	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.15	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7434	1201001.Refeição	5716231fbd99d1d14d878938ef8a32e3cc70079dc3d5ebdbd4d6a1da3a0f2d27	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.78	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7435	1201003.Lanche	348e2add541703e7fe3f0cab81fb25b0bbf992d188f535b9a5e9b6f3d21bd15f	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	1.03	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	107633	1201007.Refrigerante e água mineral	dd42f32a5d27f5fc4cd379be131abb624054ee2bb806eae41afc44993835c798	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7438	1201009.Cafezinho	e424075db86211abfa3a3ddbe5f8f6327b2d58f3a5659ae937013882f26a3640	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	1.33	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7440	1201048.Cerveja	f44e8508b141c9b4c8d29de175e131b71cf594211a33f86fa4a5189b4a5255bb	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7443	1201051.Outras bebidas alcoólicas	891ffc67e39a995b8948041906afed30761762c2c92550e1cf8dd86a72b17e62	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.19	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	47632	1201052.Vinho	564cab13a89266202496fd468bab4f91955541d16e76b7d10f17d03ab6922dfb	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7444	1201061.Doces	8c24f9d46cde7065a1fd0b50d92f513baf19dfef42623b5f856c816279d9d65f	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	47633	1201088.Sorvete	1b7e2ee83c7fa44d3b49f6b4ab2c182662caf224bb9388b22f17d9a1a1827717	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.03	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7445	2.Habitação	e843003c2e6ce998301a9d8d1648f22ec1658ae99593dadef6a8746a1dd9de87	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.97	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7446	21.Encargos e manutenção	289104b22929d2a110a3bedc03e3904ac04c742f5e874dcc210e1517990b0ce7	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	1.08	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7447	2101.Aluguel e taxas	a9279a3e949bf9f78ee6dbc97be60f02b7a684ab6736690353f8564ad355c8e5	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.47	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7448	2101001.Aluguel residencial	fadb982f00cba10dbd9ede4e232005fd191f4377a3d84d60e1ebcf4e2dac7546	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	2.02	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7449	2101002.Condomínio	942367bcc3453fe165e120a276020bae8335cae6371a1c83001f37d164fdb004	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.58	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7451	2101004.Taxa de água e esgoto	5e747a4af265fdc82c07307a39d468903efb7341ba2bce3a12c01354fd64397c	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7453	2101012.Mudança	1694458a4b43dd036667d3db8d7d86e6fe74ad90c4d768b68fae0ac320d2ee32	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.19	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7454	2103.Reparos	186fcc80a0f79464d2386b3b6ccf358702e33e05eafa8d3e39de6f7360248094	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7455	2103005.Ferragens	a7b47bc83afc8a9889e9ae7310e90be36214fce4c760395ef5c815235b8546d2	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7456	2103008.Material de eletricidade	27f437cd2a2a3b7c77d3fb7ec7f0cd195f4881b9ba7440f1e454861853cc41b3	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	12433	2103012.Vidro	db491d7743fb68f2059664aac8086bf5a52d4708758a9c80d3a38be00536be85	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-0.99	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7459	2103014.Tinta	a5dc681af58cdfdc70bd34d1e588484e4b3199045b804929a4d7dee03ff02c2a	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-1.07	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	12398	2103032.Revestimento de piso e parede	a5c4db66e98ee975f9e04a89766fba2c10dd4aa004399abc37b87f2d8109bf02	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	47634	2103038.Madeira e taco	5488d8fa5c0f943dcf2119a2774fafa0269d8e322fb5bad96536a9e8bfd7f5e6	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	107638	2103039.Cimento	ddcbb0fc17582b11c2901f9d3c70f9d0989b066d51cff48560f244d2891ec322	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	3.75	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	107639	2103040.Tijolo	86e8b737c1e1ced817e1652fcb2645cf32df9defc604e5b000d230c9b48cdf5f	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	107640	2103041.Material hidráulico	29754d9a53ca51cb9aac3ca99642de5cc3d14c0a15bab7de3e20b96a8481f392	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.66	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	107641	2103042.Mão de obra	a9ab01bac0a0e7062d6f015c8b23154ea290642529e479de556d7b5d7f7e7f0c	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	1.22	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	107642	2103048.Areia	bbcfc5fcc8b07ed71fce39057e7b6cb0eec6dec32e9e8950071f98500fd21116	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	107643	2103049.Pedras	923742bdcf69487feca0ce2a64a3f762575705d3431b0f63c4930ddc6e2133db	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	12399	2103055.Telha	0a938a80d82a27b3558dde718e489de550c4f279e624fba15dfeccbf085f69a2	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	1.13	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7461	2104.Artigos de limpeza	cf4fdc29945d138f008f4923da37e8ccd3ce68400a4ba39b56c647bfcc9faa66	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7463	2104003.Saco para lixo	7302364480110c3ab41afccba5a3f09397af5d1543041afcba820e9891def763	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	1.79	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7464	2104005.Água sanitária	9d22cae1f485c603ab53b67a49a01254176700038dc552bed47b3d6e6a47b31a	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.61	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7465	2104008.Detergente	847c49e8ce97d574da8f95f0836419c3ad9ef5c4e5510e1d97151d866725be32	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	1.66	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7466	2104009.Sabão em pó	8fe40c3cffa4026489f8208b559ac0bc6e0f06637ad2df1aba2070b89e326235	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.37	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7467	2104012.Desinfetante	5a2d4a01640de68d4e5fbe3a8aa98f9df8bfa6777b644fe83ae5b8ab9bca51f0	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-2.74	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7470	2104015.Sabão em barra	22ca5a7dc32d2c8cf9505ef6043d9f3496520896082f2e34c029eaaf821afff3	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7471	2104016.Esponja de limpeza	41c0ed8b3096845ddc0519c725432bb17958ce251941336be2d39f9c69de4735	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	47635	2104019.Sabão líquido	0c947ea5bdfa21bbb13b56976122df664ea56fe8bf4dc77d64763168f08cfe58	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	47636	2104020.Limpador multiuso	807745a3d224f8f9424fbc493e80d6ef8ae9cda544d09bb9d449ca9165660e41	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.96	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7477	2104041.Papel toalha	87057d2f216084e9401e7ce83bf1a72d3f9c8cf3dc44235d3d6fb9ef040857e0	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	1.98	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	47637	2104085.Amaciante e alvejante	b9663e28cc534bd3071233a906d3d32242824e6aa10e53f9675c2a888e0a10da	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-1.49	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7479	22.Combustíveis e energia	016ea010658dafeea32a760aa14b6749f8a14ba410660f432d39b40979c1373c	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.39	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7480	2201.Combustíveis (domésticos)	70a89639c459f6cd0756fa1ddab3a20cba58c03e883883a3f8b41584f4dfe520	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7481	2201003.Carvão vegetal	64cd4dcdd57ef24754d62e24fa87dd8f5995629a0ec31bca005f0b2d052c2528	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.61	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7482	2201004.Gás de botijão	1301dec49010fedf1d3e50cab27e0d1e87a10490b8d4aae6f65da95f5cd35e0d	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-0.08	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7483	2201005.Gás encanado	47006763f3bfe969d14aa3adf6cebab91983864bc9a418b71edba2dc3083b89b	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-2.02	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7484	2202.Energia elétrica residencial	b01d82683d4ff2c3fab92b920ef3a989af9f19bd1d3e5b9447f2007539efe4bf	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-2.02	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7485	2202003.Energia elétrica residencial	1569d1dcc4f8756ceb1c1ae662402b4030f09fb3bf6b120c5efcd47e8ed19ba9	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.90	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7486	3.Artigos de residência	967592324f26ded829d5dc42e6a901ab8358bb49b763706efb12ab239816c46c	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.12	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7487	31.Móveis e utensílios	f330cdb160b1fa483d6d82116fe2cf73ee640cf92ed7abe499789f44627b08ec	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.37	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7488	3101.Mobiliário	32f88686c1c25a47036a2806507e73bc09612ae028ea004af78cc5d40e11e4f5	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.67	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7489	3101002.Móvel para sala	8aec32306122f0ac22385887ede6cc69ef5342353622705e6995c5a823987aac	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.51	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7490	3101003.Móvel para quarto	cb3d670b5badd47df3cdda3a50b2e645ad4b323d7574621c64a988ca1b6b9165	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-0.85	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7492	3101015.Móvel para copa e cozinha	a6201d421eb606fbcf568dbe5f05b8fb6ebf8e758d838a1ff619a56fff824c0a	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	12401	3101016.Móvel infantil	8d5769a528d8addee07cc4e81c582f8541dad5d3a9d47118d0bfe3b47e27002f	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7493	3101017.Colchão	a2b9b5eff7beecd7c8cbb7904992552c02bece1b0b781d8dfae14ffb8b7c8928	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-0.31	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7495	3102.Utensílios e enfeites	3c39d83b1d80eb7a38ba1319aa1d7cef7baf03e53da19b2e388a67fd9b7930b5	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-0.58	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	47638	3102001.Artigos de iluminação	fa2a84ebae94de9cfb41aa36c1812fa5f3ed9d964c0df30e25befe5bda7dc150	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-0.34	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7497	3102005.Tapete	40a602597c0a583d11488a43aa4d6fa2bb196d4bb28d6e9ecf84ac3c7596a9ab	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-1.21	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7498	3102006.Cortina	17471ca4db15195c87e94451cb659e75259d01f056b5f5b712b0d49e1bcdf252	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.52	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	12402	3102007.Utensílios de metal	ab0187c0d94c9d0bb95cd7a1ffdb4e2f4e51b52f4c5527c86766c3f49d4679b7	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	12403	3102009.Utensílios de vidro e louça	029e145586c4df3b0097cdbe49a86c3d1c8e11ac09c8160c9158db882d1d57d5	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	107645	3102010.Utensílios de plástico	9503699ec80899fcce880fc2d5f5d1da2a3ecce04743609427412270262c1214	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7508	3102035.Flores naturais	514316b2d1e0065702187727eb87173ae53b83b0bb30d077da1e1ab4a8c9020e	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	47639	3102337.Utensílios para bebê	1b0724d5b791095e4c3cc8a223e3419fa32b0d4455d612af3baaad7b88b43560	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-0.62	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7517	3103.Cama, mesa e banho	cc0ac476af64e6113952c06befeba477b55729d14d4a71aaf85ae7438710bf29	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-0.62	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7518	3103001.Roupa de cama	ca836bea4d7b7dccf37cba6ab80c61abf8c0fa59d7dd1058f76f9b1589bb9430	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7520	3103003.Roupa de banho	ac3f4ef34947cdba8a348c19c5185937065676276193bb14865c2035cc4403a5	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	1.49	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7521	32.Aparelhos eletroeletrônicos	1d8668be6914557bcac3245024576d5af0b994b03b2d6976f4760899b80d10df	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	1.54	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7522	3201.Eletrodomésticos e equipamentos	bc96fa1fc5b33973240700052d55e2ed032f0379cef6d61d81d9d8b3340bd551	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.54	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7523	3201001.Refrigerador	3ff78f97ca34b0ca11aa5bbf5f21a4e85bc16448e165d3da5bbb81dce37b96a6	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	4.00	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	12434	3201002.Ar-condicionado	8eef212a0befab2c4e9fec938edfdfd7997e9284ec8686778878b39603315823	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	2.93	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7526	3201006.Máquina de lavar roupa	f790fd8d026aea3f12be891934f70c4438ddd7d7959dca1c9f988c3ccb235061	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7530	3201013.Ventilador	05cbb980f799254e8660fdfad8c799fff51077e11e9f6c21767878524dc558cd	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-0.03	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7531	3201021.Fogão	9dccfe0db09aea6472f674fa7d497b29479c6c9e76d4c98f212f54085e28e875	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7539	3201050.Chuveiro elétrico	9ceb8d5c41bc970d538e15ae1f9b0baf3cec8b5c340cc059af28d896c8d26283	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	1.43	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7541	3202.Tv, som e informática	b15834924a988cd8247b2f0c9e4c5f75c9588b275aa48efd0c918d8976331a9a	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	1.70	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7542	3202001.Televisor	8f62f52fdceefa5854220a4506ed8cf0c196a551727e9d0c6bbdfb320c8046db	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7543	3202003.Aparelho de som	3477da6f8ebee3a331f9c3a089059b09dd5e50fbf3c54d43f918ba7a7f1e6f0f	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	47640	3202008.Videogame (console)	80a8c70ad9ec9c306a2fe4dc30772933539a1bf00b2d5cf3d20c77b3fce78ff7	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.99	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	47641	3202028.Computador pessoal	c81b3ce75e4e3bd14009bca4d09a7f64dc092158c6fa0a76e316e4db597108b3	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	1.72	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7548	33.Consertos e manutenção	970aab19e3e941f91ab26685fb4649a36448fcce0c295b7dcaee027a79dc48cc	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	1.72	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7549	3301.Consertos e manutenção	dbae2dad3b50974a45a38c3c0c1221595d16f9e12c972b2e776c2c21a26d0703	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	12405	3301002.Conserto de refrigerador	ee8fb3a48aae1a7b09c082ade2cd6465cc7e5f58eeaf33431561a983a81e7b2c	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	107648	3301006.Conserto de televisor	964a95aac9b82c239e2b95853e7581ef5ccaf78c1c97eb8e36b38fe8f5c8d517	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	12406	3301015.Conserto de máquina de lavar roupa	e2ee368de3d74a956ed44b98ecda9897f76ef3f53d63111b622e5d99ab589a1f	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.45	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7555	3301022.Reforma de estofado	3d24fffd782f87718dcff1ed163f9bdf0cae3b377c6bd83edec1040a20b688b9	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	47642	3301088.Conserto de aparelho celular	8904a8b7223881b21f0ace61a7d6d856b96f5fade5853531f89d8ce069285e12	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	1.96	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	47643	3301130.Conserto de bicicleta	c07128e2a216ee8bc773e9d04e3cb8d00126374752a63c015af6338d0026b9c4	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-0.99	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7558	4.Vestuário	35492e30a90110db66047782944698e60e772c3f32974f50d7d69bd0fb118ff5	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-1.66	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7559	41.Roupas	593f34fe0e402ce6717a1e18fddd983f282ec3f38c3e617aeb8478c6e55e9574	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-0.99	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7560	4101.Roupa masculina	d6d8000815e3e8cd1253ff6afcad7fa19a3c57bbd74a841eaf5b51a889cb3643	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-2.88	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7561	4101002.Calça comprida masculina	c683348402fad4a535a74b89e1479833f21e9cc2e4b6e40bfe38e0c749064bc7	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7563	4101005.Agasalho masculino	89646b10a3b3454c81373ffd6a980fee67ce08b6e4bbd8f10c9b9e0e9f87a113	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-3.44	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	47644	4101006.Bermuda/short masculino	d410cffa951952ed824545e8e15dff2fc54f56b97381079911dbbb2b4f684313	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7565	4101008.Cueca	e89419749ec4fdab4e683ec3062e64456f941159b9930ede654ad177f3de364e	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.19	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	107649	4101009.Camisa/camiseta masculina	d9751c47d5031ed82549f7e857933a79e53b33512cf1010a920c2d7b0193c798	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-2.78	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7572	4102.Roupa feminina	0a6f01a07a884ae930e9317da4f3c7a85e33fba650c6d5a827c7d54c944e8949	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-3.13	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7573	4102002.Calça comprida feminina	1e369489987b2bb1974dff8ee5480892939462f37cbea2321c418db7c349c894	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7574	4102003.Agasalho feminino	e1784a1d8ff885cff0f533cdb6aa3255c53716f60f4b64d79c512306d5c95dc0	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7575	4102004.Saia	f676d484fbb55235d567125a7896187a785a407ee1a6297e879ff59253388d18	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-3.64	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7576	4102005.Vestido	f059154719b2df9529ea7e82dc5ee15e19e879544eb22cdd340e78a4ddf242f2	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-2.22	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7577	4102008.Blusa	9d8f51472e5a602966b985d08979931e3a9f79700a12a93fbacc1aefa9549823	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7579	4102010.Lingerie	e584997b42032633b0f3d26103ebcb0a614bbe125be1c0876d601d64344e1ab4	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-2.02	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	47645	4102013.Bermuda/short feminino	1ea9456bf25103cbd38da00cc638b7fe1060168964761b5a3f504da2b4b73b8d	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-0.22	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7587	4103.Roupa infantil	dccf65e7b12ef33a81ff9d5c4da8bb34aba0761d4bd361e4f6b15b5c9c361a4a	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	12408	4103001.Uniforme escolar	4f450396b72422204d846d6e4227b3c1255db0b37468035981853316a201efb1	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7589	4103002.Calça comprida infantil	40cb279cb5b9bf18ad0c0c029053bdccf5cc5a4d47908ad5129e8aafa6d8a744	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7590	4103005.Agasalho infantil	1f22db06a92f8f60b60f5cbc3419e7acb6803382e219f61d3b3c33df6692d033	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-2.77	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7591	4103007.Vestido infantil	89c2ab9fc319c20b65db7d13c983ba51f98f8ca07dd6737886491a27ed07cd81	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.52	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	47646	4103008.Bermuda/short infantil	3244887f4b99f7fba392cba744b886a1b6733a681e0d92516413b0c970c850ff	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	1.05	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	107650	4103011.Camisa/camiseta infantil	a76ed0c5b93067f7cdd4d3d446d4bf4210f70a28b1d9910ae6069703054e5042	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-1.71	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	12409	4103031.Conjunto infantil	aa53ca8c4229dcb8f4ca668b81a8ed2ca27e2e358cbb5f689b0290c2b55ef9ef	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.05	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7604	42.Calçados e acessórios	14643dbb7b4ed5d71e824a4669a359d8ce322631878eca697e4301fb7ce6c85b	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.05	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7605	4201.Calçados e acessórios	c8028a4a870d661ca8349fb623ccaba26453bcb3403bd3a0d29f53210c2aaf89	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.61	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7606	4201002.Sapato masculino	ca8192b0508b4861ef5e6f61731baf9b45a89abc63dc7092fe9bca3bc11ac958	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-0.41	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7607	4201003.Sapato feminino	390e15fd37f127d137e1f454b2b24df2e9debe65e10414f798622b94ad51977d	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7608	4201004.Sapato infantil	106e482eb7d18b9963734b7b50b21c0c370edfd8f31816eada1fb1a3f6ff3885	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.70	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	107652	4201015.Bolsa	d3240bcd23a29af092a4c6cbab94ddc76022a3c452b12310d4c558acd60c9add	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	47647	4201040.Mochila	f4b69a74c7b5bde90721f0b87fe71e7de1e12438c12993d7296ed0d235e20c42	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.37	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7614	4201063.Tênis	458f47bbe9b678b91160393e573d32e2ade59f0130850c5609d468e3078e75df	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-0.71	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	47648	4201098.Sandália/chinelo	72c4911f7034bb09d220f46842959aceca9c0680f0c75261db0d29ebf3659b07	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	1.85	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7615	43.Joias e bijuterias	3d26b94dfdd7e3fd0822c7d0dbd670c1736825a81f9271668ddfa1e1024f45ef	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	1.85	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7616	4301.Joias e bijuterias	467ab88733f582516e9a0e6024b15b068827d477fbd4cdfe91569c2c4bc17f25	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7617	4301001.Bijuteria	e787e448190ecbc1a648449bf270212e358dcae755d0202af5dd58b70e54c3df	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	1.81	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7618	4301002.Joia	c9d3b0a8c435ea5ffe939a25324980ec8c9514c1f3d2d9267abbcbfe40cec9bb	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	1.96	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7619	4301004.Relógio de pulso	4cb7f1ee7041b34ddaac9c5bbe4927c26f31f7ae7ff38ff362754aa3b5779b07	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-0.76	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7620	44.Tecidos e armarinho	4dc8969b3027138ec24ff0b01de0786ce55fc0d5ec24c44bab63e0f835bf8fa7	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-0.76	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7621	4401.Tecidos e armarinho	857dd56f95f0015a351e3b439ad2fe96a3b5369d83dbb1a20fbe3144eeadd1db	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-0.76	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7622	4401001.Tecido	b835d0600f63231ad537666d129ce2e15a7b62029e91e6259cf5ab5942f7461f	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7623	4401002.Artigos de armarinho	d65c76f94e2f8cff0b69eb31593b5f7830037cbcdb57e48793029f32216625a3	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.54	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7625	5.Transportes	cb8414c59878ee089a21540d7dff222a061a8b289980d6f838173e5073a00739	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.54	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7626	51.Transportes	30ae159fc9528527ccd7d625a484c49a5c3be2b9cc01018b21d047c421210e4f	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.17	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7627	5101.Transporte público	4415791d976116417a8030a6253a4db4a86965c47670afb3bdf3ecf07bdc47a7	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	5.32	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7628	5101001.Ônibus urbano	c34441ec72fe3cb26ba8fe4e34b340ad001aa1dee5830766ab8a111a4fc60c28	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	4.45	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7629	5101002.Táxi	0e0e994bb2f8bdc1fcea0618a817d7fa85591581e2aef185198cd0e1f5842287	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.00	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7630	5101004.Trem	b0edc550a0c5d4ceb169971f86186d3517a3a76895e3026d7e24c5872fe06205	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.00	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7631	5101006.Ônibus intermunicipal	1d09810c6127ec8b6aa90b10f23fd5a20460be1c9fe626e3e7a94616a7792aa8	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-0.48	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7632	5101007.Ônibus interestadual	250c45ff47e8b805f9396b2d3cfc98411abc8e84748a368a7f32742962f10c19	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-8.60	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7634	5101010.Passagem aérea	dd58e3de3408c7bd96fb40a3b0744c46053a57d98373d71caf2f0c275fb9fa92	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.00	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7635	5101011.Metrô	f58ea89a42658981e4872fe6495dc3a23cd627b55b700c32bcd76b72c8824ee9	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7639	5101026.Transporte escolar	de6e75ec2ffbbb1876e634ee9319fcf44fe22360b15c555ad39ebbefde349cc2	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-13.79	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	47649	5101051.Transporte por aplicativo	3363f3149a34454f7d43f90de1cef68d73df08b5a98400059e9512a639a93cac	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	47650	5101053.Integração transporte público	2ba326ac0abfa6d8e392b41b7e264e59cfc22bdda25e5d6383c49fc716325f2a	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.25	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7640	5102.Veículo próprio	07e792d47dfd55839daea273dd0b424325220678ace7d76b88d559a9b4254072	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.38	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7641	5102001.Automóvel novo	d3520c8e39830ebf18abcba1762978e94c34345a113c8bed4acc1fbae2b93d07	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.34	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7642	5102004.Emplacamento e licença	684bb72990244da9aa14e5d4ae17f72a381316f44bd2db27522df31214c3253f	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-2.26	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7643	5102005.Seguro voluntário de veículo	6f530e70d63965f0ce23bfe19909abd36eab8d62465f1ec99be70b2df1815ff9	2026-03-13 18:44:13.621322
1	Brasil	2	%	5.21	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7766	8.Educação	1120e7722b7c244779615b37a46c9a591a483580160e411335c9e788d995bd12	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	107653	5102006.Multa	75d5532dd237fa0ad193c97720836c842903db90876bc4a37ef875a00461ac64	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7644	5102007.Óleo lubrificante	a231b9f2cdf31fe64b24eb7b1745de136ed4c8651d7d49f389cea2b9c23e9eb8	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.31	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7645	5102009.Acessórios e peças	436e65b0144c3290949636ce31906794ed98b16f4ea0e672e951e920a3440962	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	12411	5102010.Pneu	24009be62d296a498702ea5a9d8c24d7e8a7f7bac5fe80883d229a4efcd7ade2	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	2.44	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7647	5102011.Conserto de automóvel	62a423e0739bf5f3d8eb1c68509e558d53b2eb2c95a5358912ced4b5538a16ff	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7648	5102013.Estacionamento	16a2513b2292ca95917433e2c5509d003d3a17d79401760d213ee077cb42f6f8	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7649	5102015.Pedágio	e178e52c98a4ede0765ba93130ae28d38f043235ba2f75dbf93d7de780caa963	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-0.92	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	107654	5102020.Automóvel usado	ed7de9f776d958bc8504e387b8ff51bc85396185bf648321929a1b7e8327ff95	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7653	5102037.Pintura de veículo	8358be8bed0ea94510b6c22f121a2ddd818af73c28397fba761b79cd395186ed	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	9.02	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	107656	5102051.Aluguel de veículo	c41818787a4c5766db58202f8ed92c181cd2e41f2f8dde701e1beafcaedd22be	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	1.03	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7654	5102053.Motocicleta	9c1bf87b4445673d9f0c885b4f530b547bd60980cb8cfaf033ca9e9cdc00c6d5	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	1.59	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7656	5104.Combustíveis (veículos)	256cd481bc94902e2fb866c95778defbf4c6a8c47b19e618e3cb8034b7332407	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	1.75	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7657	5104001.Gasolina	94e2ead12d759e91e874cf88cadfa9ce8688324757c96db7944a9f86ae6b1016	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	3.60	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7658	5104002.Etanol	93ccd12bffb157f0d6d554cf45ec61f9cf44cd3bb06642736a182a717a4d1e59	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.70	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7659	5104003.Óleo diesel	b63d3c87acafe8501aba000acda0d6d3eb5aa3bc2532339400e6f41007a961e1	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.21	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	107657	5104005.Gás veicular	76f6805f518a1c44f4e91655b7f3062178e16bada8b568d392f949c20d8d9668	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.36	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7660	6.Saúde e cuidados pessoais	06aa2a9f6be3ccc58e099bd01e43890703f8702e83055776d7b2dce111fe3545	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.17	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7661	61.Produtos farmacêuticos e óticos	86ec2e184dbc83dd3d7898653c34b10575e2e1b6b0620e311d9051ca1e088530	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.17	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7662	6101.Produtos farmacêuticos	8c8e7fa09ac031df46aaa2956624276657592641b501eb95d02f778ff12cb48a	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	2.61	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7663	6101001.Anti-infeccioso e antibiótico	3567bd28aabe42bd6dfc62d2fd8264da51b1d9f2de779814eeb2c576ee66d7c1	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-0.03	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7664	6101002.Analgésico e antitérmico	1a7ec2a0ed19beccd6b36cf607beccea2b953f74b624aacbb4ab668d1bf02091	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.49	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7665	6101003.Anti-inflamatório e antirreumático	f9daf1d70847a1f3103afeb95f7a51ca575beeb65d13596bbecc0b159f84ecd5	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.23	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7666	6101004.Antigripal e antitussígeno	77a55c4d508a7b2bc23db5d85ecb3a5bfbafb2a93f59867f30bac3de4e54982a	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.43	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	12412	6101006.Dermatológico	89f0b5f3b7bddd5f699f3eee95763e2be8bbb231975299ed7b3ad7d2b62e3afd	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	1.23	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7669	6101007.Antialérgico e broncodilatador	304b3218b7d8325771b2ce0663fba7eae2bb8b7455273a8adbf51c84a0af9e34	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	1.64	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7670	6101009.Gastroprotetor	1c12a13ced95a3b2de827d23d6c896de95b49894303e90087788999b91729e74	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.20	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7671	6101010.Vitamina e fortificante	80292c863511143510a66b0a3c210ffb8af691a580726eb04a6d4aa992206204	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-1.34	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	47651	6101011.Hormonal	6c751380b77b167b49049f11ec2017f62496bf9e21818353156da402f46a6465	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-0.38	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7673	6101013.Psicotrópico e anorexígeno	9297e350f43dd97041d61d595fc2886ac37110340b94e4357d0a430a0dc05c00	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.34	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7674	6101014.Hipotensor e hipocolesterolêmico	00d8d706eeb5837f3d719fd7c16c959f7d3a5ef4829db8fac5f9a01bc8d60e95	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-0.54	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	107659	6101051.Oftalmológico	f3188f674799731b32c0eeadb8c3631cf8d7f859f897fd3b252ebb92d8abe36c	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-1.42	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7677	6101064.Antidiabético	49f9724f5e8878948443c881d574f16ef116f4913302a4aa6d7572586cbb9071	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.52	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	47652	6101148.Neurológico	b32257d7b5b2a687c86928a95fb289e86c2e241510690b86d224c8cbb62513c2	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-0.03	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	109464	6102.Produtos óticos	87ead9cda7d2f6fea8ea47e046d6352c8543f2718105156040c498a2d2e7120c	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-0.03	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	47653	6102012.Óculos de grau	1e3deb11bd490f75ffca7d907adb778c5766f5b325d28e6626f5ec5272dbbd0c	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.49	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7683	62.Serviços de saúde	2ac14f3717b3a879a88172670fb70636047f70bb024f8e64cbb2d5d261967e29	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.26	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7684	6201.Serviços médicos e dentários	b43cef0b0c6fd3a75459ac07626d94919c01e19c076063e88074f796e78c4e96	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	1.61	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7685	6201002.Médico	ec83a5d3ff546f79ad8fa74c50dbcd0fad765d42d7c37059d2151ee11fbe5efe	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-0.98	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7686	6201003.Dentista	3da260836970662a944a384abceaac21d5310b9ed3657950dbb3e029118080ed	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	12414	6201005.Aparelho ortodôntico	083ae9d2cfc7450bb81791d3a09f52285abd0fa9743bb1a236bab1e77129efa4	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	12435	6201007.Fisioterapeuta	36df30aa25196ef168e3fdce0787398cea3be3c2238b69205a08c24cda13eee5	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.50	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	12436	6201010.Psicólogo	28d7c0ec76394c49e3d56cd4bcb10f9e335addb7b3d649a94b19157e96c46561	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.51	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7690	6202.Serviços laboratoriais e hospitalares	5ba2323bdb8b7af3dcf95b7f1383069a5d213814ed5335e0b3870f4ca5f77c63	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.39	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7691	6202003.Exame de laboratório	c4d5b564b62d6482e6855d60015cbaba90c8604b767564210fd6be946fa5edd0	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.48	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7692	6202004.Hospitalização e cirurgia	1367df89ef557fa2ac2c3b4df598cefb46e063dd0d6f38d52d3f8a2b01d0391f	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.82	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	12416	6202006.Exame de imagem	a5fe75ed454796cefa2b6264358599f89a0d02a0611ef6ce8b476481865c9a7b	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.53	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7695	6203.Plano de saúde	333061636fd11b3eae7ae7765d95d5e6d8f0177355c010596f72239d3d0de41e	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.53	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7696	6203001.Plano de saúde	172d0a9bf44c69acafcc7a85e1f4ad60fdf55ee8ef18397eeb0446dfc0da73f6	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.32	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7697	63.Cuidados pessoais	726e3a897dfaaea52495ae1d077a4e33985c72120459dd77c2e3732fa9c62ea6	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.32	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7698	6301.Higiene pessoal	461820d8f09cf4956c6eb88a4bf7190df3cb93c873bd673e93587b4e2e5d9fa4	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.06	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7699	6301001.Produto para cabelo	1d357d042b1e09a6fa9913407bc3bcbd1b6520464dbc9f1cbc38a33a3f563c74	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.45	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	12420	6301002.Fralda descartável	2e82fdee00b423d93c51bd1db6adb6684a9a2289f01203284cb7ee0390410e78	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.24	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	101642	6301004.Produto para barba	09a667f6dd5efac05a9cb86c71f0636f0d21844f7ed3e2e714b2b851ed593c25	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-2.70	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	101644	6301006.Produto para pele	afe86057bfcb7dd30c7afc31bed3fdec9b3648b42611640b67e2e9efb7ad66c4	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-0.92	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	107661	6301007.Produto para higiene bucal	fa119bd56546ed313f80b1f762052f61536867bd3232bea6faee23a5ddd745d7	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7703	6301010.Produto para unha	1c36f422d2469bdc4e46adb4d1ac7a654647fa6daa02cdb9ead2603e60c8422f	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	1.63	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7704	6301011.Perfume	e190378426aa2cd50067a46653a4db09f191d1945a82eb91b1aa0a9cfe07ac1a	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	2.38	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7707	6301014.Desodorante	21b97beb1d23965eee46eec28e6eea3ec125aa8dfd4685e837394db5830509eb	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.42	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7708	6301015.Absorvente higiênico	78ef885a47f6cf7f5db1b92959a77dfcb6633104e9d75ce9eebf697c21230e24	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-1.05	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7709	6301016.Sabonete	80c41dfde36c95d9d680bdd31e9df35b5435500134b6005ba41a607c78420062	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-1.98	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7710	6301017.Papel higiênico	e0ef236ee2aa9cabac17ad83f8feceb6c8b021855d356d2c3d91034d6d79fec1	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	2.02	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7711	6301020.Artigos de maquiagem	4d9798796367bc28ea344325c5d89b7ae054dbb8d11643e47dfa1d43ddb93bd3	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.95	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7712	7.Despesas pessoais	d2803f760fd59c529b39f65a8266fc1caf2f0e95daac820dd715d147c2382d5a	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.21	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7713	71.Serviços pessoais	411813ceea39ea571827ef04b269afcb6f9ba342f3cb8d14054b44427d853a38	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.21	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7714	7101.Serviços pessoais	d710e3241552e72287ab1a9725cac0c7103b9fafdfb1b86d459046f8764032cd	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7715	7101001.Costureira	5ba0536f90aef6cfdaa5a6095c1c5c1a8cbcd51b5e6f4e24a7dcfc81ce722645	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-0.66	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	12421	7101005.Manicure	33f071157db7b5e32102bb441777a0a570e425b8ce55abac1256b406d976bb74	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.48	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7720	7101010.Empregado doméstico	043ac711d971e3b969f40f6a1ee2578f37a0fa48d37f877da0bf5b6fc1254101	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.01	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	47654	7101011.Cabeleireiro e barbeiro	f5867d40db029e4a92f2dc8ef53bccccbc32bc29d9842a0cfda1d295e5663137	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7721	7101014.Depilação	529cda90559f7455c92096ce74d392836747001a16abf4f7bec87ad4a85e7689	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7723	7101034.Cartório	9f250f86f8e6947a5d37c609253cd6c89460d0ab6cfcae80f79d307bd194a7ec	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7724	7101036.Despachante	d143ef4c745b2fa323da27adb26ac01a6dc59916f826102c69b3bae33b8bedee	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.00	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7727	7101076.Serviço bancário	6eb7b28bd27940bf666c099078372022bb405355d6c4f5e0e6f73558b9490f4c	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7728	7101090.Conselho de classe	f3bf23431c49ef2a610bcb7036d9a4c2ca7157e82c89361d7574d69192d42e26	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	1.24	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	47655	7101144.Sobrancelha	43a8019a495924ee5780ab306de339c01cbbdf5522fbd889ab549e7a1f9b849a	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	2.18	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	47656	72.Recreação e fumo	cef324889e9b99b6dceb861a0dd75e47543f65a5b049055378458ea527f68d8e	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	2.67	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7730	7201.Recreação	736bd38e46ab3eea2a6d2d6d030bbd3246c518303e17f01646c6cebbd14de6ae	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7733	7201006.Clube	2e10072477bb01ced977f83647bf086837af51d09c051e3272d591e5c4c451b7	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7735	7201010.Instrumento musical	cc53024552bfaa43fafce71240539e662c7b4026bb0820ac935704745538dfd6	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.09	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	47657	7201015.Tratamento de animais (clínica)	e07d99a10c4621d7c5e592ede1d19b85da8a3573598d30be9453319bd44b0d1b	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7736	7201019.Bicicleta	7de55ab91f7d8b9b226dd36001c58625343c943ab75b9d50a33ceea5ea55974c	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	1.51	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	107666	7201020.Alimento para animais	cba78fc4b0f4fd4ca482815c9a44fb69bf103ede7adb1451b1d57e699c967401	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	2.63	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7738	7201023.Brinquedo	65c30b36922e1fc54f0ef88277214218da057781357f1a6f796f8a7489d454b1	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-0.02	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	47658	7201054.Casa noturna	ef45a15fad2b722710e1f2f7b89399e17cba2d41fb4ceec996eabd7897b90b46	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.00	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	107668	7201063.Jogos de azar	36cb2aae6b016ea8e2f42b11816c903604f162eab532866d5cb58c7d05629427	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7746	7201067.Material de caça e pesca	1bdf547d79e83763918fc6aaac040dff1b397e77ed845fa0576d4e224a1afe68	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	9.87	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	47659	7201090.Hospedagem	7cca1fcb57b34e14d0d956b0e8337e94ef1a6236dc94773d0401e3b198bfeb98	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	2.14	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	47660	7201095.Pacote turístico	1c2b5794ff304b5f2c83c290321bc225def7e841208d479b0c0e3edc36d6dd48	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-0.38	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	47661	7201256.Serviço de higiene para animais	14a91c491b40832746cf119a5124d1537062e71c380c93f2b823837af0d50632	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.32	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	47662	7201266.Cinema, teatro e concertos	876febe166161f46699c1eb267bdc8574078cf15d6bc0a307bba5ae57be527f9	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.00	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7758	7202.Fumo	36e1ea6df8137c5580c5fcab27f2c87d0a559aa71e2b7ed9bf7ad8ada7d9f59b	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.00	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7759	7202041.Cigarro	e44575f5cac6fc038789dd82e0631a7bd9945feb8a1e27fa6d8e0c8241dd3de6	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.17	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7766	8.Educação	8ecb6234dccdc22626f835bb26cfcbb31092eead35cd5bebec6bb3d47956c164	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.17	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7767	81.Cursos, leitura e papelaria	4764f2cadc911e7b57d6af838ce7336e3101bf72d63197fb4262011d4bfda4c3	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.00	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	12427	8101.Cursos regulares	bebd5ff9263c81a5d53c2cc75e6a1be526d8c8b030778531173ddf02ec286ed6	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.00	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7769	8101001.Creche	0cff45a48c437d95bdf516a4bc78da99c752f4260759ac2447efa1237c706a7d	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.00	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	47663	8101002.Pré-escola	4a2a8fa92d26a339e2d062ed6eba53202356271a9d6ed3b966ac3c02ef27eb07	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.00	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	107671	8101003.Ensino fundamental	0657998a204bdd4dd62298ebe2c532f225a4d925026bb14911db0070db205281	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.00	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	107672	8101004.Ensino médio	56bd45293c84594714f92d68193c922aa40eff95a4d9e55e99f168c9f8fb46ec	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.00	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	107673	8101005.Ensino superior	56062fb1092429286cc4dfbc65216ac06c84282beec058356e102bade7c6a956	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.00	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	107674	8101006.Pós-graduação	2750eaa7eba4df5273d926bef99e16b70ff9305f827698c56e0592a51ae1bbba	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.00	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	47664	8101008.Educação de jovens e adultos	1ace5e254939c93c9ff7fcb9cf326ec51f8eafeb3c71f19384b544817825ec61	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	47665	8101045.Curso técnico	bce92e13475bdf1063fc225514655310ef001d9282800caa49f0e2ac80d91407	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	2.28	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7777	8102.Leitura	c6ef961d41331fa3df711b665cee1ebb73bc900bf28ea417aaf95417dc0d5649	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	1.17	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7778	8102001.Jornal diário	404303caa6c772bdb37941d961b4ce862c519ff163659fe58f1f31ed4c62e145	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	107676	8102004.Revista	88dbe70b4e9575fb8f862b536bd109f9efe265dd7369c008c85d494d334e0dad	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	3.21	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	47666	8102007.Livro didático	c48e4c5ae89e9b9df0b17278e3e95484b77c34c01936f0ea9c7d2e5b49555803	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.43	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	47667	8102008.Livro não didático	224fd7805b253ef9e395e05343fb8330fe53cd4bdae9277002becf14b53bf6ce	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-0.35	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7782	8103.Papelaria	73c5f787f04523ff443ec6cafa5fe03971407a34894c407f1fa3bab3ceea5e90	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	1.12	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7783	8103001.Caderno	ed9ee787f7a5b2400e026233625b2085713f5f4d83934fe679a8617bfe6148e4	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-0.99	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7785	8103014.Artigos de papelaria	5b8d853549b2267f60649abf36b72697e0f8863f2eed2ef7a79f4682e146fc67	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-0.36	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	107678	8104.Cursos diversos	6eae24333bed17523f2cc1a88421faec378901743fe48182ae6a04af26b27795	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.00	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	107679	8104001.Curso preparatório	fa26739e6071d2127ab74f821c70915379b22e56efcfb8da9314d221f0bfd2b6	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.00	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	107681	8104003.Curso de idioma	86b267722711f8fc2300da1fa0b5479d70d399b85cfa15c387e48f2fad68733b	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	107682	8104004.Curso de informática	e5029e8bc65b25bb908f0c5dc75549c1322bf6890f99f2f4bb2306634b78464e	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	107683	8104005.Autoescola	1c7ea129efff239f40e18aa970c39ad1ca07109d4880e1475454dcd12859b63b	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	-0.77	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	12428	8104006.Atividades físicas	6015b0d7bfc3c178f144df1ee1db4ba0a7621934fddd8c9da5cefd0ddd6d2c3b	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.62	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7786	9.Comunicação	f8e803dfaf6c3aa51ad8cfe3d325d12ee48822fc6dce719c882bb47894d762da	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.62	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7787	91.Comunicação	b6a94365ae324dcff72145613adafa1bf0e8b2944f7711216c39fd3cfdf23031	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.62	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7788	9101.Comunicação	350c76cb659f7f6a484917ac6c14bda6264e1d5fa6021dff3e0812b6dbb3e69a	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7789	9101001.Correio	0b3499d28c6fbbbdb7fb6c1a77a0f0e783caaa0ac7cfcbc3ef6b4d0e6921c202	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.00	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	47668	9101002.Plano de telefonia fixa	6898ba26d1a1eadef141affe4f1b581ede7e25f62db66998104e92deb88a2e29	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.00	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	47669	9101008.Plano de telefonia móvel	5be5da61e38613953c426858cc7d209f14b651f45188bef94e2d2a20116325e3	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	1.34	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	47670	9101010.Tv por assinatura	1324b400a675e0a4fa017657eebfb87279551da9ef5d356072b2915e34ec1e91	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.00	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	107688	9101018.Acesso à internet	e247efb5db7706f14e239bb30d580d35c8f3cb8e62fcb2bb7f4b4bbbf992589b	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	1.23	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	7794	9101019.Aparelho telefônico	66bf98cd0aae82a0e6a49a7251f68576d40062219dd183a3e25485ea9c698692	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	47671	9101115.Serviços de streaming	bffc877505b5c7314092c66d03e47c9967378f509a8e5b266e4ca6b4a8190e20	2026-03-13 18:44:13.621322
71	Categoria Metropolitana	2	%	0.76	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202601	janeiro 2026	47672	9101116.Combo de telefonia, internet e tv por assinatura	e986ad22131c2efefc3b417c7fc3db6a00134e939ec1ca93d28ca3dbb6acacda	2026-03-13 18:44:13.621322
1	Brasil	2	%	0.26	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7170	1.Alimentação e bebidas	77af64b1d062e3c42b9e2093d2fc895d2282bb1ab0501d4a7bf5bbe33f137cd7	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.23	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7171	11.Alimentação no domicílio	d6c5e1db87475ebd0fbe8838dc7ae462d10da33cff337a6a5bd0a997dc15b7ee	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.13	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7172	1101.Cereais, leguminosas e oleaginosas	816ed5af088b8f55da7a9b68ef5e99fe0d6dedbc7560f17e39f0b32fff1fc7f7	2026-03-13 18:45:34.375355
1	Brasil	2	%	-2.36	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7173	1101002.Arroz	d2ae6c8ec111c45dfabd248192094b503ed3b0c9fe3c88ed861d0b970dd667ee	2026-03-13 18:45:34.375355
1	Brasil	2	%	3.99	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7175	1101051.Feijão - mulatinho	488837ff0412cba5574fdf133aa6e18e683d283d0ec7ca55ff4be517eeda5908	2026-03-13 18:45:34.375355
1	Brasil	2	%	2.84	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7176	1101052.Feijão - preto	668d1731def577678071c5ffe9c5fae73ef403bcf31467441b6c35638ebe3cc1	2026-03-13 18:45:34.375355
1	Brasil	2	%	2.43	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	47617	1101053.Feijão - macáçar (fradinho)	5d45417cff4af8a4778459a9b8efad23a3fff34120ecfc77302661c7324e897c	2026-03-13 18:45:34.375355
1	Brasil	2	%	11.73	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	12222	1101073.Feijão - carioca (rajado)	235ad407e40d58df8775557e407ecb744c05f4470f6583f34c78e741ffe10d31	2026-03-13 18:45:34.375355
1	Brasil	2	%	-2.91	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	47618	1101079.Milho (em grão)	527fbe3ede91f059fbaa21d341c24853a2e942ddbd75e28c75ba037769c7d836	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.19	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7184	1102.Farinhas, féculas e massas	2ff555f69f5db19f62fdbb65fd06a7f5264d0b0e5682f8951fe1c0567a6f2b5b	2026-03-13 18:45:34.375355
1	Brasil	2	%	2.82	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7185	1102001.Farinha de arroz	a0c782bb7647a0bf47b0bec768c1923540fa4dc3b83fed13689f277395d0df50	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.42	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7187	1102006.Macarrão	9e2e79dbd6ff89c87b1cb8398137c499086e3cb61ee072198995ff8888d345a4	2026-03-13 18:45:34.375355
1	Brasil	2	%	-2.64	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7188	1102008.Fubá de milho	f3124755682485dc2b3b971bd3f432cb744eae989ad08d09e2c5bfab2d2202a2	2026-03-13 18:45:34.375355
1	Brasil	2	%	2.02	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7190	1102010.Flocos de milho	124b486a1af6db518276dad5a2ba6711adcd3a66864f980884051184fcc664f4	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.86	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7191	1102012.Farinha de trigo	25e94830715c776716e509dcd3cd42f264d307aeca2fbb10dea2efbe7ab52390	2026-03-13 18:45:34.375355
1	Brasil	2	%	1.06	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7195	1102023.Farinha de mandioca	a7aea3ca4b8e38e4027b7e74c5f58173810e8b6409a2b13c13f2be2823063873	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.51	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	107608	1102029.Massa semipreparada	b76cc3f2152d733532f38862df91d6c89d55d5be812ce01d5100cd5e537c3fab	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.15	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	47619	1102061.Macarrão instantâneo	8fda9bbc48e7e5ae33bd2c5ce57804f07a37b9ad26eaed1e4ef844d66da78369	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.06	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7200	1103.Tubérculos, raízes e legumes	5126db681939b5dd48b27eab366c1931e370d6ef7524165a06a4f366d817e5a5	2026-03-13 18:45:34.375355
1	Brasil	2	%	3.31	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7201	1103002.Batata-doce	899d0f09c5985ebbe4425336cbae76f8a2c5eac940372572e03af03cd0ca959a	2026-03-13 18:45:34.375355
1	Brasil	2	%	1.00	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7202	1103003.Batata-inglesa	8b8fef7d5aad1104b9be93fb0ead69ad7aa69ab68ea3d7d229d08a82c25d2898	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.91	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7203	1103004.Inhame	911f88c206e036eb30c20c6036bebf650dd51ce416dda22b649795a461662c10	2026-03-13 18:45:34.375355
1	Brasil	2	%	1.70	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7204	1103005.Mandioca (aipim)	58fea5c177ca1f3b0fafe2b85fbdeb7e125fe6f06b2d4ffb3a09818abad100b9	2026-03-13 18:45:34.375355
1	Brasil	2	%	4.51	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7206	1103020.Abobrinha	256a10b49d6c0684aef23155475bc990f3ebc001db42f2286b5d61dc561e77f3	2026-03-13 18:45:34.375355
1	Brasil	2	%	2.48	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7209	1103025.Pepino	1c6256ccdc3ffd8e9c3d364321494988a32a59e0ec651fb316294cbdb7303968	2026-03-13 18:45:34.375355
1	Brasil	2	%	-6.69	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7210	1103026.Pimentão	82e3246f0910f5cd5e30b5352cdd59b07205ae92c312b4b9171041fe06702754	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.30	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7212	1103028.Tomate	d560153c42b2c65a9e81626700bd3ce2a69b2c608d91022b25f84f3ee1d3469a	2026-03-13 18:45:34.375355
1	Brasil	2	%	-2.52	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7215	1103043.Cebola	2ec9f7c374c3fdee6662a56d1026240f25ef106730cb10cef4261ab705ad5fd5	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.58	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7216	1103044.Cenoura	3ee0498976fbb6b0d6bf91ee56e8c863394fc9c6a6f908e20c02b166144951c8	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.75	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7219	1104.Açúcares e derivados	4c1674e6eeba67b0e14864ed8b52d5c254df9d52fec39334961ce2e8fec8d64c	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.90	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7220	1104003.Açúcar refinado	e08d721e9293368ab28b326ffaf2b0d73fa5a85981488037116ea0dae348f17f	2026-03-13 18:45:34.375355
1	Brasil	2	%	-1.10	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7221	1104004.Açúcar cristal	a436aeb5e25943f9d64996f99fdb6e6fa6640eac109ea09d249a58179286fc46	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.55	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	12224	1104018.Balas	5d184a97a6792aaae2e9b1670c1f639decac6135dc8a70cbce0b0ba75d44a4bb	2026-03-13 18:45:34.375355
1	Brasil	2	%	2.70	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	107609	1104023.Chocolate em barra e bombom	34ffa24b296e47a0e6eb49b166ad4e84def1a22390ccb360a40971f8cf9241a6	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.11	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7230	1104032.Sorvete	a83fecfcb767ea7208cbdf0324602d20d7cd26f4b8b1e5e4911d1565aa14ebcb	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.90	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	107611	1104052.Chocolate e achocolatado em pó	a5456f429140a0cf6f7997f9349d96f55a53c8975b302172171becc36e9f1b30	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.65	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7233	1104060.Doce de frutas em pasta	bf63f21ef06dc07ecced5e815e36e6f2351021de808c3a2823fba17c30a01cdb	2026-03-13 18:45:34.375355
1	Brasil	2	%	-3.79	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	47620	1104067.Açúcar demerara	500d86efab4752ad2d1fb123a8ecbb3ff86301861014869a492d11707960ceaf	2026-03-13 18:45:34.375355
1	Brasil	2	%	3.90	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7241	1105.Hortaliças e verduras	b907d0dbca562b76630b6ab2391ee2c43877b4e103d05468ee5395759bbced74	2026-03-13 18:45:34.375355
1	Brasil	2	%	3.90	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7242	1105001.Alface	419445810f2734a9fd61bc61d7409caac6ec387ac296ef7e37d14b808a6dd2c6	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.53	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7244	1105004.Coentro	2330754f77bdf81f8645909d10c14faedb2dda40b76e8b84df501268ec929dff	2026-03-13 18:45:34.375355
1	Brasil	2	%	3.88	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7245	1105005.Couve	284ace3a4ea24aa60846c0563816119978db74b34ad239fd40c9cc2b87e28e34	2026-03-13 18:45:34.375355
1	Brasil	2	%	6.69	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7246	1105006.Couve-flor	afe937d814d593ba21be3042679099e16faccb8845cf519ec3a01577230744cb	2026-03-13 18:45:34.375355
1	Brasil	2	%	7.77	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7248	1105010.Repolho	0f64ca2f38472164f237278f83bcfe085a4b84afddb18414407807a428340cd6	2026-03-13 18:45:34.375355
1	Brasil	2	%	1.68	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7249	1105012.Cheiro-verde	0e5e6ec5c9b515243a0cfdcef52857650e115e68d2a17ed2c7dc61426138c4ac	2026-03-13 18:45:34.375355
1	Brasil	2	%	6.21	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7253	1105019.Brócolis	19755301af38ba52ff279edc85aca5a7ea11d0f7465186bfcb2c983f2d2acdc3	2026-03-13 18:45:34.375355
1	Brasil	2	%	-2.78	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7254	1106.Frutas	90016cbacf4f9a804ede576227eac2e93b2eb14e13a1fa9c3c72ced11fe9b5d6	2026-03-13 18:45:34.375355
1	Brasil	2	%	-4.01	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7255	1106001.Banana-da-terra	5c9692377067fa46991f4149797508e7527daed18feaf11af03b854560e09bd2	2026-03-13 18:45:34.375355
1	Brasil	2	%	5.74	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7256	1106003.Abacaxi	f0e32fa390304fd1bc73d8ea07704ca2c0eeaf5eaa17915398e9d9d9127d9ec3	2026-03-13 18:45:34.375355
1	Brasil	2	%	-24.35	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7257	1106004.Abacate	41f2af4f12f38bbcea1ff49ada92206ab75699249546990e26e218d6c72dbad7	2026-03-13 18:45:34.375355
1	Brasil	2	%	-3.39	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7258	1106005.Banana - d'água	8f3cef25917016ae385ac3a2547bed705425ba079fdc7e61f34091040469742e	2026-03-13 18:45:34.375355
1	Brasil	2	%	-1.85	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7259	1106006.Banana - maçã	99eef99a043a786b2e64631f602c04f1956247526668bb5cd39fd53346cb24c2	2026-03-13 18:45:34.375355
1	Brasil	2	%	-2.76	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7260	1106008.Banana - prata	9a839f35e9b0bf42c2f13343636b3ac45ef73515e7ee3ba6a43a3d1a6922c549	2026-03-13 18:45:34.375355
1	Brasil	2	%	-12.34	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7262	1106011.Laranja - baía	7f8bba33211cc72368293c767fb1d633bcbbfb04ca7a11e995f2b1009f10e832	2026-03-13 18:45:34.375355
1	Brasil	2	%	1.32	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7263	1106012.Laranja - lima	3725d9a7c236cb7474d1210243bcfcced96e5eeb24ea145244bc08c0c6100267	2026-03-13 18:45:34.375355
1	Brasil	2	%	-8.84	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7265	1106015.Limão	92197abf85adaf2ebe3e7fa3fdb8c42929a0188bb8e920749bc9ff61c2fac847	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.72	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7266	1106017.Maçã	d21366a262f416a2f73bd2fe73a92029d0413d6db832a6ca234f00e2467f9bc0	2026-03-13 18:45:34.375355
1	Brasil	2	%	-6.93	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7267	1106018.Mamão	b128cf06b9394b501909df85cd42d510e58f307b2904bb95f5c6a476e23dcd39	2026-03-13 18:45:34.375355
1	Brasil	2	%	-2.35	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7268	1106019.Manga	ccf9276011f8f363fb150c0592f89c3853df6c83eb273e3ba816f36272c09438	2026-03-13 18:45:34.375355
1	Brasil	2	%	-4.28	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7269	1106020.Maracujá	98347744eda09779824c9e1a20cad5e5391b90b8450cfcf67072ae7dbeddae40	2026-03-13 18:45:34.375355
1	Brasil	2	%	-1.61	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7270	1106021.Melancia	743518f8cb2380f1bfe9c173dff0df1ad94db13ad7d4c814e6cf0f2e284a6206	2026-03-13 18:45:34.375355
1	Brasil	2	%	-2.52	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7271	1106022.Melão	1bd814a0d8ec6831d42640df3fb7210ac88da47892fd56664c35f78ac052812d	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.76	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7272	1106023.Pera	09ea1fd864e01054ed1ed10c5646dd897338656dd239a136be0c57e42f2b6c69	2026-03-13 18:45:34.375355
1	Brasil	2	%	-2.78	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7275	1106027.Tangerina	b5a5183e14fc712f2e494952ddb5d9263c88126047831c64a0028f8ef1cb33f8	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.64	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7276	1106028.Uva	5d190b94d1ff7c8888a954dea8c4cfb2cb5acd549a4f0067e32d9cddc9f5f1a0	2026-03-13 18:45:34.375355
1	Brasil	2	%	-4.59	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7279	1106039.Laranja - pera	bbf4c1ad1d892e0d990fe811a1d74e2bb759cfc905e4d5930875fb575081dd4b	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.84	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7280	1106051.Morango	ff542a02a18b872dfe85ae937aebe8a9b072fbde15baa747d4edc06a057715d4	2026-03-13 18:45:34.375355
1	Brasil	2	%	-1.33	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7281	1106084.Goiaba	f8a5c3113fb8f9045706f26950c6759b0ff768cfa37675db81e04bf375c27caf	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.58	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7283	1107.Carnes	0dab55c119351b272c57e38804976e6a49c3ef9a224727146565827df9c8ff1d	2026-03-13 18:45:34.375355
1	Brasil	2	%	2.52	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7285	1107009.Fígado	2262dcab53439201eacf8b0aa4aea3e818b35442210c95d6ee61a157610e7a98	2026-03-13 18:45:34.375355
1	Brasil	2	%	-1.21	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7287	1107018.Carne de porco	9c4fa87b0212639552e634a5d684cbe9595abedd3fc76c49893dbc5dbd7e83ee	2026-03-13 18:45:34.375355
1	Brasil	2	%	-1.98	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7288	1107031.Carne de carneiro	f28db9615311acaea3064cda41c4b39b75049e41160d9b61478558bf4ad0fea8	2026-03-13 18:45:34.375355
1	Brasil	2	%	1.12	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7290	1107081.Cupim	2f1b6a8badfb1a4840115c2c816d93c452ec3618cd38784dd46535721c4d0d31	2026-03-13 18:45:34.375355
1	Brasil	2	%	1.30	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7291	1107084.Contrafilé	19bf0161e17aa80081350432d89c593beb2a1550b98dcdc8a8cc457c2140b09c	2026-03-13 18:45:34.375355
1	Brasil	2	%	-1.25	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7292	1107085.Filé-mignon	0157029e238d4fece2c91d623acf428cd5aa227e99ce1a1b9059939205e80f60	2026-03-13 18:45:34.375355
1	Brasil	2	%	1.99	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7293	1107087.Chã de dentro	05eb77bb6097b432f94773e326ed5285467991555cd59477ee929ddbeb7d1ac3	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.98	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7294	1107088.Alcatra	4803f2e81f5130018c2314cbe0e98ad6c76a40da3b773dcb33fd0f95e21bffb2	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.21	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7295	1107089.Patinho	8350c56eb7a2fb9069c5661422e0eba9f36daefea758093b6c31d9a0acc9b0e5	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.10	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7296	1107090.Lagarto redondo	1432259509bd18171fb1b79456072ceb5e74f0dce7549545bbc1e0a93233040c	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.03	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	12294	1107091.Lagarto comum	2d522ecc3e6f4e979572316d185a0adc6d76963a7df42ed4cd52b550af7dde15	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.67	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7298	1107093.Músculo	7d7869ec7c711fc03533bcfe0bf7ec17dcc1864e25a99bca09a56c778f698a43	2026-03-13 18:45:34.375355
1	Brasil	2	%	1.71	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7299	1107094.Pá	fa8836507b4fd801d43af8abe9005e7a9d6935209ae74e91517e79213379649a	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.61	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7300	1107095.Acém	bd97d6e718fb5b6cd1360b9a1c3d9f1720edec7a6b480b36f60166605bae7fd7	2026-03-13 18:45:34.375355
1	Brasil	2	%	1.24	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7301	1107096.Peito	e52bb261ffe98172892dde9775b540abf5b19f4fdceecd1d00da36186cf60392	2026-03-13 18:45:34.375355
1	Brasil	2	%	2.28	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	101448	1107097.Capa de filé	adbb4ce124db9b7196c57d6e0eb5bc861f74981ac6dc4ba961e1e46387ad00ae	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.23	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7302	1107099.Costela	dbd0405e4a6599d82dfda046f28c087c5394bb558be881d81ede178289324a1a	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.10	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	47621	1107208.Picanha	9d437e585be4265defe675d9678dc20aec7725eed3d74a8697b93ae9c1067c9c	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.11	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7303	1108.Pescados	7c9992298b47969cd41b7d0585ffc7e097998e69a36637b9f2c476043e13e3eb	2026-03-13 18:45:34.375355
1	Brasil	2	%	-1.49	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7305	1108002.Peixe - anchova	601b2548f1acc1569914eaea762a0a00897b516bc2aa79db4d2e32d7aa61b17a	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.69	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7306	1108004.Peixe - corvina	3de2090ee94ca8c6397e186e25fa115b52df9669f0d2700f7b2e52ecffe17f16	2026-03-13 18:45:34.375355
1	Brasil	2	%	-2.18	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7309	1108011.Peixe - tainha	df39443e9bd15f0ee6853241dcd1be14387d676fb3f82a5b5324f188ed0c9ab1	2026-03-13 18:45:34.375355
1	Brasil	2	%	-3.15	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7310	1108012.Peixe - sardinha	cf744bc22af3b4a7d342efd33782e95528f23e8387f8440782bb43823a612bac	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.68	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7311	1108013.Camarão	6b79acb1b294997b8ccd5be21bd2ab7bba72839eabff2fa4f3efca358ce3802e	2026-03-13 18:45:34.375355
1	Brasil	2	%	2.56	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7313	1108019.Peixe - cavala	44772c37b6a983f7a687d987aacf9ebb2488b379fdc3675b7bec2e7df5227c7b	2026-03-13 18:45:34.375355
1	Brasil	2	%	1.49	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	107615	1108029.Peixe - cação	6e1536101894c7dd1095fbc78fafb494c00d929a429d4cdd460e3f434e54903c	2026-03-13 18:45:34.375355
1	Brasil	2	%	-1.24	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	107616	1108031.Peixe - merluza	360cf549c415baf87616f881a0e15f24cb583594534442838421dc44d2f43984	2026-03-13 18:45:34.375355
1	Brasil	2	%	2.23	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7317	1108032.Peixe - serra	676afce1fe0dbb8974a4ccc1f009beba91b16e3e6921ca5c5341490c89ea4d20	2026-03-13 18:45:34.375355
1	Brasil	2	%	2.38	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7320	1108038.Peixe - pescada	b6e5759d426bf0c83a02f15e7a7865ced23db833d69aa027aad313c60ab1488d	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.75	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7323	1108045.Caranguejo	9b6608788c07c66e415accc84c035341a9302d2b78607ae239d1a6c4ba47ca4f	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.84	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	12300	1108049.Peixe - castanha	31bb88e48a508f5edf47d7f281cfb3a2454c55a31459dd7201842eb415afebb6	2026-03-13 18:45:34.375355
1	Brasil	2	%	3.58	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	12301	1108052.Peixe - palombeta	fb17f97cfdf29d2460456e4234d3de975747a20d797c4cb3a207468325c298f1	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.33	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	101466	1108072.Peixe - curimatã	91267cc7de67d1980878547c339fef9b476c72d8da6bd98e119ae0d03ad4a69a	2026-03-13 18:45:34.375355
1	Brasil	2	%	-3.28	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	12431	1108075.Peixe - salmão	5e227ed7784d2cfe653b2ee29340f872ccac7429bc22b5068eb735ea2ff4b072	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.26	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	12302	1108080.Peixe - tilápia	d704de0432671988fa3b1791cd1c9c652db893f54fabc9da8a495861abca29c6	2026-03-13 18:45:34.375355
1	Brasil	2	%	1.47	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	41129	1108087.Peixe - tambaqui	8ff11377d960eb78ae4e73b4647056ad625e5397730f5fde67d0c642f1b5c2fb	2026-03-13 18:45:34.375355
1	Brasil	2	%	-8.13	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7333	1108088.Peixe - dourada	e58c96d81e1a491e253f9f2593602118c3eb0f1cf0ef00f581e00fb3d5241eae	2026-03-13 18:45:34.375355
1	Brasil	2	%	1.64	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	47623	1108092.Peixe - filhote	c9aea37731e5bd59b5f829c72862d20128a3cfe3243a7289278a59b354d44109	2026-03-13 18:45:34.375355
1	Brasil	2	%	3.94	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	8874	1108096.Peixe - peroá	f2214d952570ce1ffea2bd2a20893d30d8e28dc0d36ba7f6383d4ad9a4b21893	2026-03-13 18:45:34.375355
1	Brasil	2	%	-2.44	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	31694	1108112.Peixe - pintado	5dab8004965b163149e58f11dc9b14213e06a1ef35fb5444171b2bb1f33d6a8e	2026-03-13 18:45:34.375355
1	Brasil	2	%	3.79	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	47624	1108125.Peixe - aruanã	56a20c337c9ae4e66d6e1ca466b75ec756913c6b6090ff749214dfa87ff41ea6	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.75	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7335	1109.Carnes e peixes industrializados	bc6d0f8fc03b65a38a0d6604355d01be627ed851ce3b11af301300de84e6c058	2026-03-13 18:45:34.375355
1	Brasil	2	%	-1.29	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7336	1109002.Presunto	499bfdecbe482b66c0beae88807e189cdca52aa791818577a87d2620f4552d75	2026-03-13 18:45:34.375355
1	Brasil	2	%	1.59	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	12304	1109007.Salsicha	cfa75a03bfb2e5f9f80938b4f214469e134c4db64297026ead2392378ddc080a	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.93	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7339	1109008.Linguiça	7813e6e33ecd87be1f1c964e135f584e7d7622d812c446cb9511d5effaddcf75	2026-03-13 18:45:34.375355
1	Brasil	2	%	1.41	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7341	1109010.Mortadela	1bbfe475a0cbf81d70b938180f8ac05e3c881039b2b61890604ff8bc24f3594e	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.40	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	12305	1109012.Salame	c86f6015c09eb3045a0dc917fee28388cdad0e1c908bc3a0754b16c711f557eb	2026-03-13 18:45:34.375355
1	Brasil	2	%	1.32	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7343	1109023.Bacalhau	cd771665d7395c83ca6d9f75249c2ef1246de53d64e8e84d6fffa2d2533bdd0a	2026-03-13 18:45:34.375355
1	Brasil	2	%	1.45	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	12379	1109056.Carne-seca e de sol	31c7bfa5f977004456f91b659ecccbda03cfd5e960e5ff56078e367d1142333f	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.83	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7347	1109058.Carne de porco salgada e defumada	181a88d39bee8cc72bac5edac997e0c228074ef2f5988b3c42481ee90e8b00d6	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.67	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7349	1110.Aves e ovos	46b7f8d5ad33dd10b2407a209703065c9bc4278908c952fc50f65b2b03b67db6	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.29	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	107617	1110009.Frango inteiro	9ac504a546da49b35de38ea2c6e1ddbdfb788c605215888fef22b731744a7a43	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.19	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	107618	1110010.Frango em pedaços	047637be3aa4e2a69311fa0b797ef0cf757490175f6adbb2ae9fec89a9a5c07f	2026-03-13 18:45:34.375355
1	Brasil	2	%	4.55	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7355	1110044.Ovo de galinha	3765b1c2b9a10b9b06c2137038b9a0cc847126fd0d416e6131c8454698ce20f1	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.68	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7356	1111.Leites e derivados	373833fb1542e65e41881452ab4f93aa2d11c1c886962ab208bf5138879fc115	2026-03-13 18:45:34.375355
1	Brasil	2	%	1.24	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	12393	1111004.Leite longa vida	d5a4948b94cb6808d1fce6e9f8e8ee403d712124fc8958a35328d680684899d8	2026-03-13 18:45:34.375355
1	Brasil	2	%	-1.03	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7358	1111008.Leite condensado	f0e7514de7759a414fbeeaa7285276e928a898400cc744a6bd5422424f44f34d	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.97	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7359	1111009.Leite em pó	8fa6c13d70e9961c6427f4c5d1ab048aa2e9c004da8dc41bc728d34f13458811	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.68	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	107619	1111011.Queijo	1f77a95a4225f4bb89ea131aac68f261a043b05143e6848a0d665be1527b1037	2026-03-13 18:45:34.375355
1	Brasil	2	%	1.10	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	12394	1111019.Iogurte e bebidas lácteas	b341ad3543fbc184333420ab736b31d4a75c0a90f17142d48d76a978db7323c0	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.90	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	47627	1111021.Requeijão	f4b05e07671e60b646bc30fec6fafb06339d1624d88d8272671a87979fc9d871	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.33	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7367	1111031.Manteiga	c87109974aaf71b174c9583d3a3963520cdc4954956b3d0389ce300f11b4f653	2026-03-13 18:45:34.375355
1	Brasil	2	%	2.11	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7368	1111038.Leite fermentado	4033bf52023a327851df8980ce4a957f3c5a355f88e185bcee271f9b64ae3328	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.28	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7372	1112.Panificados	90caa83f5bd15aad236252314ba1305a5e6393e2e7066922eb14fa73165458ab	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.21	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7373	1112003.Biscoito	b7c82351ab717369458973efa792b07bbc5341eb3b5f02bca0678ca499f8e77e	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.72	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7375	1112015.Pão francês	dbe8789a258fef3399edd9bf691cb95d082a0d4aeed6a539712c7c230482c924	2026-03-13 18:45:34.375355
1	Brasil	2	%	1.49	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7376	1112017.Pão doce	943e2f4d461a3e548b8a8f6814b09c6038d4bf6a1644524c242796c55a1a1583	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.39	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7377	1112018.Pão de forma	f244d294bb0a4926af771855bc7bb58b8dff4f554b33a350765fd869f7b9dca2	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.97	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7378	1112019.Bolo	593af1ff99c10b72f5e55b8977dbaed1953fc3c5646a99b525b0789770d2d0ca	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.94	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7380	1112025.Pão de queijo	c3cb094ec833cb029f8ed18c8cc64269cf683e601e23a316d5432fbfd8558129	2026-03-13 18:45:34.375355
1	Brasil	2	%	-1.55	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7384	1113.Óleos e gorduras	eb8e61378e9f8580a1ea8b26ff9e6adff4adf107aa2a7057cccbceb142d751c1	2026-03-13 18:45:34.375355
1	Brasil	2	%	-2.62	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7385	1113013.Óleo de soja	9c00271a1f339513bf4518ca08ad63f94df28f5442f1594621804755aa47c166	2026-03-13 18:45:34.375355
1	Brasil	2	%	-2.15	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7386	1113014.Azeite de oliva	d279b024cf9a3ddc7da6006d1409fc5a7cdce57b5e710a69024c8b0ee32d2e99	2026-03-13 18:45:34.375355
1	Brasil	2	%	1.59	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	12395	1113040.Margarina	1fa246ab9b7d09d16e3952de95096a4e47388e2463064c5fa9d86c49c4ef9a8f	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.67	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7389	1114.Bebidas e infusões	c8c12eb09d57bb9817cc39cb73fc00caa72f94ecd4f97f6d7e1996d109fa363b	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.38	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7390	1114001.Suco de frutas	2b9ce9b6764e70c96d2e213c09093cb268e8184652d500aafdb205074a0febc9	2026-03-13 18:45:34.375355
1	Brasil	2	%	1.24	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	47628	1114003.Polpa de fruta (congelada)	55cb6f7647893a85af99520ebcc74efbd08fd38f3ec8953fbbfda8d2760557a1	2026-03-13 18:45:34.375355
1	Brasil	2	%	25.29	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	12396	1114004.Açaí (emulsão)	64eb7ebc017c90fd10152c1615fcdadee06644dc1447820b935662d1d96bb3b9	2026-03-13 18:45:34.375355
1	Brasil	2	%	-1.20	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7392	1114022.Café moído	0a824b72055ec94137e72a3a9fb1a14955e9f87538a042da615c619bc039657c	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.37	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7393	1114023.Café solúvel	caeb6bd702d67f82fa6b680839806c94f44a787d3012e0dc21183afa8c699252	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.68	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	107621	1114083.Refrigerante e água mineral	3442e4305f9cfe6d4e40ae6c59bdc6129a6310bc096eef361c3be231559f6acb	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.36	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7396	1114084.Cerveja	007c26188741d034e0a2c4646acfcfb8bb0da71384d4f56c20fb9988229d0998	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.51	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7397	1114085.Outras bebidas alcoólicas	11f3fc5e088cf18ceffffdf6ce1bbcc6542de00658e0622e0e033b02bf192808	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.04	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7399	1114087.Vinho	71aa065b6d381d879a793c481f427c33548302052c478669528e0eb0c218a6f1	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.52	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	47630	1114090.Suco em pó	364fe218e117b601d31b1696d1a48b5e86f50268fbc6d826b093d0c06e68d50a	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.59	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	47631	1114091.Chá mate (erva mate)	c6cb0be0c00b5ba3928ad6f3e4cd9fb9657ba576ab8a77eab94b97a16fd911ac	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.67	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7401	1115.Enlatados e conservas	7462156448448e2e2188d9aacef1d6d5422622f52b62b236f44fc532f0e7d506	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.30	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	107702	1115013.Alimento infantil	793a66d315dd09cae6c1db72a6d90fb4ed020b87633135ddf0c26aa8e85050dc	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.51	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7406	1115016.Palmito em conserva	d3b3719f46e4c82cf7bea4e66da0475b47a85fba83e86fcded0b2e29f7d1cc65	2026-03-13 18:45:34.375355
1	Brasil	2	%	-3.87	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7407	1115017.Pepino em conserva	66c8db0ca22d8f5b2bf8299452522e3b014e321d2e48877dd8741ab0f008cb1f	2026-03-13 18:45:34.375355
1	Brasil	2	%	1.82	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	107624	1115039.Sardinha em conserva	5ac258172f4059849f4111c101d7cf52c5d713b5562ce503c7a3c3e44a6685d4	2026-03-13 18:45:34.375355
1	Brasil	2	%	-1.96	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	107625	1115050.Salsicha em conserva	ea9916ede9c7966534ad66ff42354cb592b5d67109079022013818a58253dd0a	2026-03-13 18:45:34.375355
1	Brasil	2	%	3.15	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7411	1115056.Sopa desidratada	cb20ca46022435d9392faa6361841a4e6556e8d5a0b77c920f53a73c1ff1cd82	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.52	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7412	1115057.Azeitona	faa6c206086a37ffd2462e09687711f58ac4b6c6ac368433909c3981d0bc8b80	2026-03-13 18:45:34.375355
1	Brasil	2	%	1.03	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	107628	1115058.Milho-verde em conserva	b155e4c0336c7378e111725d92ebeb4f85312c04ff6a380d1209701efeb31cd4	2026-03-13 18:45:34.375355
1	Brasil	2	%	1.65	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	107630	1115075.Atum em conserva	db583ccadcbf2aa9b34cb17a81ac7fb6da0a4496c4b569df5b85b83c896b76d3	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.54	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7415	1116.Sal e condimentos	56eba85b742c8c681a1518b5d61be7c878bdec5e8277fdea702ec6916bf185c9	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.60	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7416	1116001.Leite de coco	0be81a34170f916f7694cc4b8109a41a1ffa8acb6ffa690a66f56c80825a1135	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.54	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	109463	1116005.Atomatado	d32643fa1cb7b35e590ab3b07bd43906b04a1f289d134fabfda9479fde1003ff	2026-03-13 18:45:34.375355
1	Brasil	2	%	-3.57	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7418	1116010.Alho	2293e7de37ae859386fbc8229b235f2d221d5928aef29d6eccdf4a07b1a2cf1e	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.30	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	12397	1116013.Sal	42ce4e73a09286ed970fe9aa59bcc0fff0c8215ea2876aaa84b873dcd0f20200	2026-03-13 18:45:34.375355
1	Brasil	2	%	1.97	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7420	1116022.Colorau	fac24081d0d75a850aa26fdf971973926cfc829145ed6651c9e049d79e3f768b	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.24	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7421	1116023.Caldo de tucupi	3b839f17750e2dfaab41ea0b0f0624ea582011b01adcb37e45b0396e522f7981	2026-03-13 18:45:34.375355
1	Brasil	2	%	-1.02	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7422	1116026.Fermento	b96a816a166d5e4394dd2e369cf821ea67a6044e0abe0d07a2c336702d15a7d9	2026-03-13 18:45:34.375355
1	Brasil	2	%	1.22	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7423	1116033.Maionese	e53ffce12288a3869f851e138d7ab5d60fbcce6531935909ac18c9d55df5ff31	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.63	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7424	1116041.Vinagre	6154fc5847268578d7720255b52d7a8f086ac9846846e3ab1a53cc4c684ae830	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.80	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7425	1116048.Caldo concentrado	b9d5a1694335ebd3461b17701898a6402081a8585eb4539ad615e86ba95a6504	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.44	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7428	1116071.Tempero misto	424d6dcd2a0a64f4ce6b4ac6dd8cd73f011a40af212ac38dfe8895e892c0ec3a	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.34	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7432	12.Alimentação fora do domicílio	5f1102832cf88b1bbf124f3e27ce86a5e4b5fbaa38527c3323ae83a03fa6d7ec	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.34	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7433	1201.Alimentação fora do domicílio	a0c8999e5507f462fbd57a17ba6688d1c1dfb0266ea576dba8ea9be7ee3c8e65	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.49	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7434	1201001.Refeição	d818a86bdca6bb108a6bc1bae92d2507ca6c8e34566d7bd3f725b2fc57a3040a	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.15	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7435	1201003.Lanche	81073f025d068e99d6bc75962c25f6e0d30a53831bce7f5e2df5405c71f6ed7e	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.11	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	107633	1201007.Refrigerante e água mineral	486f24dd9bb512a1bf72aa5d935b1fe4d6618d1883c7b7bb46382d5d46407164	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.41	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7438	1201009.Cafezinho	6b8102fb5fb1d14606b6b70aaf01bba250fb761eef74901b72f074e9ecabd6c2	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.00	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7440	1201048.Cerveja	88a6b6f4198c9d1c2c506c03276e1af7d4d775f7ce36cecc7c7617ed5b9b14d1	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.26	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7443	1201051.Outras bebidas alcoólicas	d35fc135684df0561249392884a1cb9c9fc95e1d89d521a68cdc8b42daa1a49e	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.37	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	47632	1201052.Vinho	2708fc121017726918c410b7fc979e75994a632afd85c0fa464ef6b6048a545f	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.53	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7444	1201061.Doces	d50ce375967e624a4a026f4ca7ced9fa32dbf72b4bf151d570bef3ccac7c1dcb	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.38	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	47633	1201088.Sorvete	136d7f0fc3ec67b757dbc1f72d2fcbd76ec35b74b69270e84ac3a1d5eb7c47fd	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.30	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7445	2.Habitação	04b1cb806df950ea3dae771ffa3ec47e7b86b3e8d844214fd327795666ed541f	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.34	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7446	21.Encargos e manutenção	9176875e0b4190644a7d950f6a6dd2e3eea1ada4363db34cb6e49a032f46db3a	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.43	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7447	2101.Aluguel e taxas	7a1491480089a55266e4bb68edd1b6540d8a7b1f0296156548ebc826c7f61cfc	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.30	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7448	2101001.Aluguel residencial	736b0a6d3f90f306dae571a4ca9e4275794b9d352d7491983487fef767eb3c77	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.29	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7449	2101002.Condomínio	3fd4cedb1ecaa1d2e26713d70acf4ede4be98e76dc52317898af70454de9b9ae	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.84	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7451	2101004.Taxa de água e esgoto	8c71f5022a3f30b8c9dd39b591b2b0518687360a1e19916087e489bb75162d86	2026-03-13 18:45:34.375355
1	Brasil	2	%	4.61	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7453	2101012.Mudança	7041443349e539d92d9f732ff7ca71fe7ee66382bfe7b024258c3873ad0682db	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.21	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7454	2103.Reparos	fac3d9e0b3b399aaf06d4e5c74d5baec3ccd22268dce5472b5d2d61eadf58870	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.55	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7455	2103005.Ferragens	25c3e257121716de1aa378dd21126dccda21d67b477c73f76f743482ba6c5daa	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.13	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7456	2103008.Material de eletricidade	dad0d4a86bca34e773abe137be7049303eec39197aefbc614caaade190bcb0a8	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.41	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	12433	2103012.Vidro	8d1c98963d3dcca9b8cb06101ae6479aec17fb3646d2453c575b2f7ef3d77660	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.73	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7459	2103014.Tinta	4f7541c6625a3fd149da3c7fcfff97d602b942c1fbd39f369346a3f8db213ff2	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.02	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	12398	2103032.Revestimento de piso e parede	9eecac616656bd203ffdc53e8443b6a930321726e56ee7f5675a8ec336bd0b00	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.79	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	47634	2103038.Madeira e taco	2eb4f76b10f702d3766ef81a5750892dd14d8e5982c8782dd9461f3ae1f61d22	2026-03-13 18:45:34.375355
1	Brasil	2	%	1.42	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	107638	2103039.Cimento	c1826a1f4737989fe45cc9d04480d7275074b1177c5e0838871a571241d57c73	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.43	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	107639	2103040.Tijolo	d080350d388177172f2314f701655457cbd41595acdafebc0a0dee7d57214d37	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.37	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	107640	2103041.Material hidráulico	c489c09ded51b86689286468484749a1f6597b8fc70cba46c9b528802c93972b	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.69	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	107641	2103042.Mão de obra	35e7d6037f29bd71da6eb40b3744db2e7af70a9c2146370cd662fd38fef6b121	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.01	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	107642	2103048.Areia	e152236e15ad736efe68dd850c072b4f8961fc260a27674a3cbe101e79367937	2026-03-13 18:45:34.375355
1	Brasil	2	%	1.15	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	107643	2103049.Pedras	40c0024d82d807fc223a31aea7ca60d8c80914ad4f688f7b338ac9c52080e636	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.57	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	12399	2103055.Telha	3d9e15e7c4cd001e869c12cafb6a457f203fdf218a4bd04f7fdff8397748024c	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.35	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7461	2104.Artigos de limpeza	3d2e41f0313f7100b52b06325b09cb4ceaca056f670bcd26504132ff19c57a3c	2026-03-13 18:45:34.375355
1	Brasil	2	%	-1.31	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7463	2104003.Saco para lixo	56e08750524ed8a14ea9d537018cf01e15efd1cb0f59ecc1f38f6ccc8bc308cc	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.43	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7464	2104005.Água sanitária	d0f901b92d120cb904bd69c8ed0309130422453e8bdd8a262f1fec0aeb9357e2	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.74	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7465	2104008.Detergente	eceafefa57b79b1d6abd6f30cf253a92c30e43b630e0926ccf6e76550dd52556	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.83	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7466	2104009.Sabão em pó	6b696be29c65142483edada1e463676ffb1557f001b4a5577f9184189e0db88c	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.24	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7467	2104012.Desinfetante	b55e8df7251ae245e28a08be5669ae5e088b52259897a92e624386feb571d954	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.22	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7470	2104015.Sabão em barra	e0fa987b8dc658bfb0d20a24981ade8c3a07174fa303ca182de5b08e6bd6dada	2026-03-13 18:45:34.375355
1	Brasil	2	%	1.80	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7471	2104016.Esponja de limpeza	eb93a9358e2581e043e008dd36b868a150034c1580312ba3c1fd81e7ed38a76b	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.67	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	47635	2104019.Sabão líquido	1081c0d226510461793ca9c7130748ea8280fbbe6cd886f5df49957efd337d79	2026-03-13 18:45:34.375355
1	Brasil	2	%	1.05	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	47636	2104020.Limpador multiuso	c6ccca1a351c1f9be6ac3719a9eca9a329c5ad9209dee9e366155ee4a8bd31eb	2026-03-13 18:45:34.375355
1	Brasil	2	%	-1.16	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7477	2104041.Papel toalha	b2b998b24b33dae31d2c64caf2e55e2dbf45735c89ed3a72f272c14852da590a	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.08	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	47637	2104085.Amaciante e alvejante	59ef26c9f2886222dd8d9b78f59c825b3aa5aabc01d753f148fb8bba13682de5	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.21	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7479	22.Combustíveis e energia	9bdb4447b878539ee84fce649da40dc25b6296d5d5de36948f2e64ff5b996dd4	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.13	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7480	2201.Combustíveis (domésticos)	18c3f7f2d52bc98a363103980f80aeb116c2122e16d1d9815b4ab0aef561297b	2026-03-13 18:45:34.375355
1	Brasil	2	%	1.63	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7481	2201003.Carvão vegetal	7712a1384e68970d85af966a106d812cb017e9f899d0197aeab4f730a5f1d681	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.04	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7482	2201004.Gás de botijão	a384dec44070f681925cd6ee840032d78b9b69cc1a2a6c79678f20b1fcf29c78	2026-03-13 18:45:34.375355
1	Brasil	2	%	-1.60	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7483	2201005.Gás encanado	56b5df24ff9f4561230b4250a75771e871c45bfaf4bb4b8925514ba30a337945	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.33	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7484	2202.Energia elétrica residencial	dd4181e7fe95dfc62328acb2c28ae20626ce96e483f3fc8dfbe1bc2909bad736	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.33	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7485	2202003.Energia elétrica residencial	e433ba6fe2d1f6b482c658f7f4636d059713e7c3ba620a60cbd624667ce53941	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.13	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7486	3.Artigos de residência	105d1b62d89dd41478732dad4399daa92c2b5d40b99d65d99204eb0cdf6ffb88	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.05	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7487	31.Móveis e utensílios	1faad2b71541b8ba774778b4cea04359721e23ec2432682e36c805b222c4a1c5	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.09	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7488	3101.Mobiliário	4fb15c327f2893ed625979773de0e08c59664b819bd9116764ca638a90056c2e	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.01	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7489	3101002.Móvel para sala	500b0b37b03018d31cbede62abfa8e358a85fd8d13ef2a4c51a6863d0206dbc5	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.07	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7490	3101003.Móvel para quarto	8337d24fd265bc4ab174a9ed99b66e5d45340fd4dc2bdcad60d487cdb16f34cb	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.55	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7492	3101015.Móvel para copa e cozinha	2ce3b6b5016729e1be0fefc9b9c23cad18538360b38f5ef67891d290f0de588b	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.12	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	12401	3101016.Móvel infantil	992f393533872faaf7933324f2c82c340c641537b01892efecfb40fa62d179de	2026-03-13 18:45:34.375355
1	Brasil	2	%	-1.43	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7493	3101017.Colchão	f429aa0c356461b35ce9c71fd5c8a71a8d33036a813ee1d40b48180fdffa6117	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.05	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7495	3102.Utensílios e enfeites	338ca6bbfc8854fecc72442c0ec135dfbc42e79f2dbcc8b9b35128ed335dfe6c	2026-03-13 18:45:34.375355
1	Brasil	2	%	-1.31	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	47638	3102001.Artigos de iluminação	553a0f9673acd4cb5ac3c3b54cc16dd1fb551ec612303210a4fefc8febf1f3e3	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.21	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7497	3102005.Tapete	133617b599e950b271032595c802ce5c543383ce7a115df6a4044fa3ea166bba	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.94	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7498	3102006.Cortina	74313e9a15f6229f4a9f8d62ca9967709e2c85c777aeae37fe3c58db9d1d8e0e	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.68	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	12402	3102007.Utensílios de metal	18cb00f5d5ac8ac026692a6b4cd5559a3e0200d8e0367ac869d740bdced74f9d	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.70	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	12403	3102009.Utensílios de vidro e louça	6649d58b9e5b7a39c49d084950e748f48bafd4a1dd6c77099056e05641575f66	2026-03-13 18:45:34.375355
1	Brasil	2	%	1.16	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	107645	3102010.Utensílios de plástico	2621b5b8c1440b2afba9ec168d6a843d351fe2cbc6c17b2b3ea7f9c3dc272c38	2026-03-13 18:45:34.375355
1	Brasil	2	%	-6.18	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7508	3102035.Flores naturais	19e2ee457ed9ad7b01700ebcfd445aebefafda599c0347b2627f39f60e481e9b	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.17	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	47639	3102337.Utensílios para bebê	146d2f4a987430cd752cd01cb6c6c64afcca2bb574c60e5624db69b0e3fa7982	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.29	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7517	3103.Cama, mesa e banho	f0e08f96a26a9a5a6aaa1204083948122f5d0564912f51efaa388e40fb6361e6	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.32	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7518	3103001.Roupa de cama	a4b2bbf23b8fa67fe4fdcb5c98a9261d26b5cd9c8677c4ec543dbe457e040f4c	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.75	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7520	3103003.Roupa de banho	46b5c4e0f795abf89ab56c309d74c6c5bd5590041656ba85b9420edc7f9b2972	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.24	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7521	32.Aparelhos eletroeletrônicos	da15ae58254e67a5e35803e329d96286f3ce70e4d5e3a864c1d7fd806bf5256d	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.32	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7522	3201.Eletrodomésticos e equipamentos	2a3d71a05ad3d388962acaea529fc7a27cc43a83f6a9646b7056decf2b0cf134	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.03	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7523	3201001.Refrigerador	d882cb4b3a3745ee29782989da815c4800697e2d83a37b849bcd500431da8200	2026-03-13 18:45:34.375355
1	Brasil	2	%	-2.47	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	12434	3201002.Ar-condicionado	b938a2847b83f45ba2c9880db915ba1c2a2a258e9982f3abd142a5ffb0996f0c	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.00	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7526	3201006.Máquina de lavar roupa	f087c3a866957cf39526f13f765fadf41aaa6dd20485a3874e4df1542df32c1b	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.22	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7530	3201013.Ventilador	4e4713c07982e1da0cf9a8e1fbdcd11cfdf7d3621ebc299274b2b961579689f0	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.18	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7531	3201021.Fogão	ced5086f50826d7113bccc4cf13a5315c8a97dd7234c273721dc0e5024aa544c	2026-03-13 18:45:34.375355
1	Brasil	2	%	2.07	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7539	3201050.Chuveiro elétrico	c00183de51afc10f223a6c881eb8516939c59d665745250eb1d63b30c591a285	2026-03-13 18:45:34.375355
1	Brasil	2	%	1.02	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7541	3202.Tv, som e informática	cd4dd4bc86490559ea57139af1f9f8269c82f94b8ee19e96747b2a1874825a2c	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.99	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7542	3202001.Televisor	6e0f4c19ead6b72e77f753aec791df3b23267b04e6cb40a2e6c19fb0e88d38e5	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.72	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7543	3202003.Aparelho de som	2e85be0cc166dbb05f072e5a33badc74ade4367bb4de91e1fc869e1c72a0f373	2026-03-13 18:45:34.375355
1	Brasil	2	%	1.15	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	47640	3202008.Videogame (console)	562c2c860ede19beeab579b9ea3b4d515cbc668290ea0555bab9d249ade383b6	2026-03-13 18:45:34.375355
1	Brasil	2	%	1.07	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	47641	3202028.Computador pessoal	4becde3e6c4f90ab89df8729f2b233f4d54d353635fc8f2ec02f7229021a8360	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.55	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7548	33.Consertos e manutenção	7814cfac3e93d209fe1be2304b34bfb8e5f3665bedbdbd3dd0ef897760743642	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.55	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7549	3301.Consertos e manutenção	9104c207498302be1b7e2aded890eb8b27ff3b6810d06a1802dca54b1fc49b0c	2026-03-13 18:45:34.375355
1	Brasil	2	%	1.58	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	12405	3301002.Conserto de refrigerador	9466ba6847fd5b77bf18630f6de582c21783e642a936ec24af431c8f57e27a72	2026-03-13 18:45:34.375355
1	Brasil	2	%	2.27	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	107648	3301006.Conserto de televisor	1ac1b179eb06830e930fed2172f719ac21a5d25e2e8353b7e274c78f9904cbde	2026-03-13 18:45:34.375355
1	Brasil	2	%	-2.92	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	12406	3301015.Conserto de máquina de lavar roupa	6b5a229f970cc65c3c3565a7d2bfc49f45ec82c2e61e223f31ad84d04c2ab9ba	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.84	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7555	3301022.Reforma de estofado	1bf81f5d495e0bcf72babd928c88de18e05ae63de3f1fd1b954190154d06ade7	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.37	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	47642	3301088.Conserto de aparelho celular	1862eab7c7e02a58f82fd4585ca5c0a01468001a627920d68f7370590b5f7e52	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.52	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	47643	3301130.Conserto de bicicleta	536e37858a91a853139c852075edf2819b86a53f54b637a98ab99c93c331d7c8	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.16	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7558	4.Vestuário	b45a2d40c7d4c33cfa9f047ad7bc6fec2fe01f11235ac55c3249be3846a0264f	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.17	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7559	41.Roupas	f637dd709026298b9000eadf41807f5dd06b02f997f0ac87372b379c830be1f6	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.26	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7560	4101.Roupa masculina	77e0fa0c86ebe5c0253bcc6007b4ed2eb36d7b3b6f91eddd97ddd8a31ee64695	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.38	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7561	4101002.Calça comprida masculina	1bf16e6247aa9898e428dee73fcd2761abe87162ab4919a2ec7d4349b0170f37	2026-03-13 18:45:34.375355
1	Brasil	2	%	1.70	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7563	4101005.Agasalho masculino	3bfc6d28df5886d8e734e05ad6ccc1ab795b5f97fcb1e0ffc0ccb34f598cb910	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.27	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	47644	4101006.Bermuda/short masculino	5d751728277aff86e46814450afc1a8a030b5841324269d3ee1f84a257b72eb6	2026-03-13 18:45:34.375355
1	Brasil	2	%	2.47	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7565	4101008.Cueca	0cd2e863216d9e420f1cda46dfb3e4cd18bd1aa094de7b7c68a544e0c1ae40c8	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.66	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	107649	4101009.Camisa/camiseta masculina	9de27b2f42379c267cd3ec776be781de482b4b5f7e682be99725d532cdbeb90f	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.29	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7572	4102.Roupa feminina	525322b581f093c9ac23f95bc7acebe9fd0fb8aea6cf8fd51ea130bdf4a82c90	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.59	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7573	4102002.Calça comprida feminina	98971c3d16bd45fccf0a528f0a064446b71251ba6d01711c1fa24994a3207f58	2026-03-13 18:45:34.375355
1	Brasil	2	%	1.02	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7574	4102003.Agasalho feminino	78f12c52c15cdb9a135ad249867c15db833a1e503d4d7f5324636d7a824a1ade	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.63	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7575	4102004.Saia	f340404f5795bf7c2fb7e580365b3c313c212e2c21993155ba3a2b16c41f35ca	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.51	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7576	4102005.Vestido	eb0d1c62e661e2614ea40d4f14f8e226c15f085f44bd7a381720dacf030476a9	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.49	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7577	4102008.Blusa	092fb1e54238a811408e213d63405f08efd01f57bb7e9f97ccc87978402e4c8e	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.76	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7579	4102010.Lingerie	e450b0331d8a9e77dbf9a9b028446a0c96b471e7ab38627151158958437948cc	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.12	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	47645	4102013.Bermuda/short feminino	fb50bb8beff47430b6c0ef322a440e375d1f5caaffc973919cc4feec2b5a72f9	2026-03-13 18:45:34.375355
1	Brasil	2	%	-1.02	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7587	4103.Roupa infantil	c7bd4b35988a8337088d263d90fd40d4a014b7ee1347fc06af0fc91f1a8a2f7f	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.17	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	12408	4103001.Uniforme escolar	87f34cfaf9a6afbe0c5232f00c7e8265446785082cf2c7946c0dd84c1d35b651	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.64	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7589	4103002.Calça comprida infantil	3950ed3a3a9609617de27b1de52959951419463e2a84fde48d0ecb4e1db86362	2026-03-13 18:45:34.375355
1	Brasil	2	%	-1.93	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7590	4103005.Agasalho infantil	d9d86d2f630771c02cf35e52cbec65358ec935b634b3068d207f727951db5f66	2026-03-13 18:45:34.375355
1	Brasil	2	%	-2.15	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7591	4103007.Vestido infantil	29dfef3c877d4a8b050410f9bbff5e6df183213c236c2b989efe17a5be459e72	2026-03-13 18:45:34.375355
1	Brasil	2	%	-1.55	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	47646	4103008.Bermuda/short infantil	42528740d51d25f3aea66b4bc4871f2fdc8fdcbaa4e29ee33919aca5e75f30ce	2026-03-13 18:45:34.375355
1	Brasil	2	%	-2.42	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	107650	4103011.Camisa/camiseta infantil	0f9e6a1e2b64a82bfbb57e2e478f17061b1ceb442eee152c767d9a63da52a167	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.10	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	12409	4103031.Conjunto infantil	719b6d3708ff61e4b7296303d454fb58ae5ffb2e136c1381ea2e6fb9164f0682	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.40	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7604	42.Calçados e acessórios	6a723bccabe2dddb5a6b62d952de7fae756f4163564a5f2d0ff877e2375e7a20	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.40	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7605	4201.Calçados e acessórios	aaa291d42a4a8882da607b2a8d279124566959388933f420f0e30f1019c6ec39	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.05	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7606	4201002.Sapato masculino	f8315cdd0edf76cce2d1e6d98aa9211d786c4c5b69a522cde108f4cda9fd9a37	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.14	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7607	4201003.Sapato feminino	2ef109fcbf13d16c85d93a6068b539993df788f7600a8087bdced16bad4055d2	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.12	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7608	4201004.Sapato infantil	0052610521a83593bf7187c5ac236007d4576bedf4465f116fd0a2248fef73ef	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.06	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	107652	4201015.Bolsa	b8d4c4eaedef05a2cc5cd231c6f89ac09242927b4d845ea227301d8242a3c76e	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.22	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	47647	4201040.Mochila	11aff42b871e85bfbe8af71ba8d193db805b45d213ee63393299c01bc5f9fae5	2026-03-13 18:45:34.375355
1	Brasil	2	%	1.02	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7614	4201063.Tênis	7df2ab8b3397467b15ef02be2e5adf72bea2dca2ccc1937d33bdafcdbbd89e1e	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.19	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	47648	4201098.Sandália/chinelo	3563fd1ea19d94aaf9520e9c30610b15b3f5a8ac6e1cba06ceabe10b11d9b4de	2026-03-13 18:45:34.375355
1	Brasil	2	%	2.82	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7615	43.Joias e bijuterias	d5cc0c8fa88d6aee509a005cbb69b6f0a405ca6bc51ea1ab23ba016792c3dce8	2026-03-13 18:45:34.375355
1	Brasil	2	%	2.82	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7616	4301.Joias e bijuterias	98d33bee59b47374b256c544cbb38a75c8086b90237979aa4b06d0936ff005e5	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.04	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7617	4301001.Bijuteria	dae5a9ececcbf6b6fc913cceab06b90f65ea1abfe617a7f67ebaacf1e011036d	2026-03-13 18:45:34.375355
1	Brasil	2	%	3.64	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7618	4301002.Joia	e8f2aecbc54128040cbb28dc39646f8f474832c5a9d8604f0fdd576b86f4b81f	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.45	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7619	4301004.Relógio de pulso	14ca5519cd2377c5cd4df439828ff4c0ac50087743f95acddcb37fc27de7503f	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.04	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7620	44.Tecidos e armarinho	b75c3517368f0999c4b821a407c9efb1875eea3593e2725e66df3816b6ac5ad4	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.04	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7621	4401.Tecidos e armarinho	d7627fa09a41783282dd402bba335064ed3817c34fd72e696695d28a8c873c2a	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.06	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7622	4401001.Tecido	f4637bd153c1987caa49014f5dbd7bb953a871815b65eb700d603bf39502eb98	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.49	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7623	4401002.Artigos de armarinho	6c4d146901881f1d4dacd586e9e18369fca68135fa5f12d0c967bf76f3d7d514	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.74	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7625	5.Transportes	471fe3bd7973bcbd96c589249eb781d8ba4cf69df51317e18ad2d676b1e863fb	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.74	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7626	51.Transportes	cea5c11c12ccb968f4462668446434f1c8c89689ef363c78af72a33506f6acec	2026-03-13 18:45:34.375355
1	Brasil	2	%	3.45	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7627	5101.Transporte público	3ba903f1bdce32fe504dd0fff7bf35677d5ca0fa430a606a3a49e54c5f3aa5ef	2026-03-13 18:45:34.375355
1	Brasil	2	%	1.14	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7628	5101001.Ônibus urbano	07aa92f52ae23e59f5a83d858d4a366901723feb14be703694d2809b1503d506	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.90	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7629	5101002.Táxi	76bd4bb12a5a2d7740d8f43daaeb8ecf83d07d9abe8299d8aae097b75ef79eb1	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.51	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7630	5101004.Trem	9f8926587e153e8a281002824042aaaabf8abdba43ca6b4be96b9d9c67115093	2026-03-13 18:45:34.375355
1	Brasil	2	%	1.80	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7631	5101006.Ônibus intermunicipal	37d0ec71b239e0294515dcfbf4f6ec6e50fbc6ab29ef9c16c0db982bcdffffcd	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.74	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7632	5101007.Ônibus interestadual	da5aaa6827669b1ab660052d380718079ce39679d6519c29045f41a289b6d8e3	2026-03-13 18:45:34.375355
1	Brasil	2	%	11.40	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7634	5101010.Passagem aérea	37b35fceaea45723859b4e48f5b64a5ed9d73e4a0edd0c35e8b288539fd62f3b	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.00	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7635	5101011.Metrô	5fce44a98ff972b5491177d89b05ee9e172a5e5c24f2b01497ced2c3cb4f9d3e	2026-03-13 18:45:34.375355
1	Brasil	2	%	2.35	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7639	5101026.Transporte escolar	af792004301d9831d3921f76456f75804447eaa9997dc2baccc7046b641dcd43	2026-03-13 18:45:34.375355
1	Brasil	2	%	1.80	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	47649	5101051.Transporte por aplicativo	d1dbedd13f25f2481054018fe3b56272b4a1f88a54a0553f58c4ee9d7381fc24	2026-03-13 18:45:34.375355
1	Brasil	2	%	1.76	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	47650	5101053.Integração transporte público	d9c4fa339ba62df30710b937dc9ba4fb6d13274807d49bf88a148124df4a6edf	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.65	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7640	5102.Veículo próprio	4f8a03562e7637fc4b5d3cfc29786ed6adeada5f8ff066d2d88d4b8ad019355d	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.40	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7641	5102001.Automóvel novo	ce2bd334b689364e5b86dd06f8ad49c858b952d67628dc2fc916835dcb490478	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.15	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7642	5102004.Emplacamento e licença	2444edb339174a774ee67b4977eae900e2afac1b087aa2fe4bb169a7d9b08a22	2026-03-13 18:45:34.375355
1	Brasil	2	%	5.62	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7643	5102005.Seguro voluntário de veículo	62f3821f788d2a99883e88b9640fedef0e7e9118976be3507b39c16f728a1229	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.00	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	107653	5102006.Multa	3223e67f2dda6734311d4c48adf24e9b8323657e1b737031213cb47027aeb3b7	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.75	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7644	5102007.Óleo lubrificante	f5eb73c4e221a156702e60b302eb56a214875daca60f64610276a1e1d8f3e4c0	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.42	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7645	5102009.Acessórios e peças	937600d8a3eb682a22b780551944719594adf8cea295fca895029c67c6edd799	2026-03-13 18:45:34.375355
1	Brasil	2	%	-1.66	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	12411	5102010.Pneu	f27648f2d2a6ba5378190fe007dc52b1172d0149e5ea67bd731819b11cfcb11f	2026-03-13 18:45:34.375355
1	Brasil	2	%	1.22	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7647	5102011.Conserto de automóvel	27b6ae0647834f838b1cb1cbfa4181f643c09b583b8e51edbd120d3f64419c93	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.07	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7648	5102013.Estacionamento	d5eeb7b2c590ca4ff2d4d1aa62f25930032a0ce02d62619faa8541d7cf90f99d	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.10	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7649	5102015.Pedágio	df6f7687fb1754a5fac5a3016f4a0d61ba6ffee542a3d39408afe01a8907b8d1	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.19	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	107654	5102020.Automóvel usado	10429ffdff16911825a18456a1ed1a8a1e80790c16230466cabb8274372c5dce	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.40	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7653	5102037.Pintura de veículo	b89ca2ac2a979b0fdcf734c3e8acbe3b68f25e0308ee001e69b536529a85db1e	2026-03-13 18:45:34.375355
1	Brasil	2	%	-7.26	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	107656	5102051.Aluguel de veículo	6b087d6bf043ece4dbf85551cbdcc76ae5bf2188abc92265d1e9708d1bc98eab	2026-03-13 18:45:34.375355
1	Brasil	2	%	1.25	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7654	5102053.Motocicleta	10ebae1f6db778a74484f8eccf37ac7ff50d494c9330b9d1376340e56338ca7e	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.47	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7656	5104.Combustíveis (veículos)	aa32bcc3ccb394433a74b444ab16d63461bf496f49f07b4bd4ed19276cbc7929	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.61	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7657	5104001.Gasolina	c8a2401e6b358e58c1a1b8b6088d4fa37a7a98c82dda0e8011f713ea51563fb1	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.55	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7658	5104002.Etanol	913cffef847af539be2ac25d90f22ae02f025487fa98fcae144845e734ce8b3a	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.23	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7659	5104003.Óleo diesel	8aa68af5a1a91d2c3357f5dfbf5fd6a1d0b09168b0d9f131286f70547240f9de	2026-03-13 18:45:34.375355
1	Brasil	2	%	-3.10	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	107657	5104005.Gás veicular	a292ce841aaad0ffecec4cd3e5c85a6b3d623442697a2214c8a95ba37466a283	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.59	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7660	6.Saúde e cuidados pessoais	5a3b5c805ce9662fc073bd3a12edb743c3cbe3a2e3700a76cc63a23e98e83283	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.30	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7661	61.Produtos farmacêuticos e óticos	c41d780e5db487d8ebcd383f688620f40429ae353a91e0214db6a7a830d06ade	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.35	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7662	6101.Produtos farmacêuticos	451e1cec7d77659e466ae3014506a6593acfe6987b32321ba1531cdbae71c38a	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.04	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7663	6101001.Anti-infeccioso e antibiótico	7b602b91fc5d68f97561d33c2b42c161c869ced96b4e89815ec9b39786404920	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.92	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7664	6101002.Analgésico e antitérmico	260dd78ade4fc113f50b58b637f4d7b6585e2ce47e7022dcceb782cff2cc65c3	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.22	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7665	6101003.Anti-inflamatório e antirreumático	db93f4412e6749293f16352cc3b01765e4994763bf06f4877b94eaec9df68c7d	2026-03-13 18:45:34.375355
1	Brasil	2	%	1.22	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7666	6101004.Antigripal e antitussígeno	1fea770aad9f268f832b06a61a6a37aa002bab7efc97c53a2d757ff3b27ebf5b	2026-03-13 18:45:34.375355
1	Brasil	2	%	1.08	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	12412	6101006.Dermatológico	5882a2e1ff21de2c0068c3855f2386f065305b7235bd007dbe276a48528dafcf	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.15	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7669	6101007.Antialérgico e broncodilatador	07ac59c98cad9f68a75b73c5ed69455bf06a05b0e3f023046f3f886275784c4d	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.26	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7670	6101009.Gastroprotetor	6fc3f49591f930a0808b8a02286887de2874b59c69f166bf91375392a027e540	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.24	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7671	6101010.Vitamina e fortificante	6c60b8356bee28ffcba36d3a643f2209fc64b79720ebbc4516f039a45e7fe9ea	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.25	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	47651	6101011.Hormonal	93874e9acd50df2c86a25a3a20e1585ae57bdab85d189554fbb8d63aea7833ba	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.34	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7673	6101013.Psicotrópico e anorexígeno	f0f267be7f15e6f78870cef3880cfdd254ed5d6b90bff4ff768a65958f93a6ee	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.28	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7674	6101014.Hipotensor e hipocolesterolêmico	2d371a957b96caab11fea1347c76f9e66f2aef346ae5312bb015823e636ad724	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.94	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	107659	6101051.Oftalmológico	5bb0f0d203c6394fa8f6077e53f1d1e77984bfce234989b421740db100384678	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.31	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7677	6101064.Antidiabético	ad71a8c69640614bdd96ece462fa0a19badc2e55c220859f36d385da00341ccc	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.88	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	47652	6101148.Neurológico	f0b98578036bde69fece7806b6f11155e39c1476cc62ba2e72c63fe517a833a9	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.42	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	109464	6102.Produtos óticos	44d612426314976fb03390861ded84a51f9085880f90c9e2ce63c8902adc26e3	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.42	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	47653	6102012.Óculos de grau	92ea02a0942d6c3196fd2988b93a58554d8259e6f75714a1ff0ad48f89361c3a	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.56	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7683	62.Serviços de saúde	4bb0615b0a64c4f1acc3a16a74dba368951d257909cc584ca4abfd3383c21b44	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.87	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7684	6201.Serviços médicos e dentários	69b658e5be191b13eddc611c48c702ad72c51fed007b1f6daf59dacb25967a5e	2026-03-13 18:45:34.375355
1	Brasil	2	%	1.27	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7685	6201002.Médico	27bca87d257ea50a9dc124c9d0b9925cef3536ee7a5909e60db8bed49ce5179b	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.47	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7686	6201003.Dentista	64f128d033ac00c1e74f63b847457e8d14626e7787b2a5b3f35cd524d9490027	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.33	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	12414	6201005.Aparelho ortodôntico	434814b71c0aecbea50b4a67f41ce6e885e61e3fb91e9e7afdc3adc6af3cff10	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.00	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	12435	6201007.Fisioterapeuta	5af4c8eda9fe832005a5efcd5a842cd83a19b17e762d752ee530d998dd3892f6	2026-03-13 18:45:34.375355
1	Brasil	2	%	1.15	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	12436	6201010.Psicólogo	69dca2723f47ee441dabe26a2a34153f9e0c740c512456f113cc8eee3b4749b6	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.42	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7690	6202.Serviços laboratoriais e hospitalares	bbf7ec9196bb332f88ef6b8a2c8bfba844121e381e26c29cc46f9bcf04c03a01	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.97	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7691	6202003.Exame de laboratório	aa080dfc2838fd48691ccc08b66bf81e7a9da1f8c27ea569a3fb0acb70e86bd4	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.20	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7692	6202004.Hospitalização e cirurgia	294c3ed1e8ebf3ef257cb279658b11078ad2fbce57f49f47b3009eb9ac670d56	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.59	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	12416	6202006.Exame de imagem	3790931cf4c330dbd151c42a7b9d801cc8fcd39022d52d2979a93ce5a6355c2c	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.49	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7695	6203.Plano de saúde	6eb60682bcf1a501da3988b8e3730ec451b4a4ce9d4141912deea88d50e444c7	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.49	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7696	6203001.Plano de saúde	317f9646311e777e434f65c49a80edcafdbbe1c34934bbac342b89324ccc53ab	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.92	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7697	63.Cuidados pessoais	bd55ab2ced443b3fdcae0a110b8b05a9b7acf667258d9c789c34ae3305f0c8f1	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.92	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7698	6301.Higiene pessoal	07a6e06715d263aeeb1111ee203384fb4014fb098c4227afe5e7af9aab4bfcfa	2026-03-13 18:45:34.375355
1	Brasil	2	%	1.36	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7699	6301001.Produto para cabelo	67cf9faf33966c1e92fb8aa5beb96191f01eef73dd23e48eb33f23427f15b7e1	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.13	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	12420	6301002.Fralda descartável	4a4e728ca819717a389ff75db295b19f8d12bd942870ef4a20f8f22c2bd3e080	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.24	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	101642	6301004.Produto para barba	fdc96234311265a1d7655d616897796d34a9b02a15b2d66850a8fcc5f5a5d8fc	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.06	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	101644	6301006.Produto para pele	0f43dbeaa084362f55bbf09c33e9ccf549471d8780763483bdb4481da110cf5c	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.59	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	107661	6301007.Produto para higiene bucal	ff2e97105f6e4208f16fbd4a8ac2097c3aeb456a219b4bfbe860dfd70b94e0f8	2026-03-13 18:45:34.375355
1	Brasil	2	%	1.64	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7703	6301010.Produto para unha	9dcc9c92f7be86eb585749d3ed896bf7306fa20481ad8f0eb4a8189512acd133	2026-03-13 18:45:34.375355
1	Brasil	2	%	2.05	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7704	6301011.Perfume	5035d8efd01aebab91e9274a2600ceae402cae97d5bead95c4a13149b501a75e	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.55	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7707	6301014.Desodorante	4572ce3a8fe79f1512134130b120da0b5e6140a52182cb817af9de72008a933f	2026-03-13 18:45:34.375355
1	Brasil	2	%	1.03	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7708	6301015.Absorvente higiênico	9203d0ec4d5ec045488b95556f67b22a306c7e85a365550bd2280bf8daa89486	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.14	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7709	6301016.Sabonete	6536a75c7edaa24dbd145f7a8a3b0e2dcbe4288b49e7b358bdc2c76888e6bf11	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.31	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7710	6301017.Papel higiênico	e4d8e6d97a5ef48f242a3a1fb4a4bf22071b7c0c817332bd86d2fbbd577bffa3	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.37	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7711	6301020.Artigos de maquiagem	aeb421fa5a3183be0ab772ea5899f091536e7838e0cb8732ac8e2c1d33e6a632	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.33	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7712	7.Despesas pessoais	013d67f6295258c10717675eacd5910a1cd4befe63df300e76d89e4386496ac2	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.75	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7713	71.Serviços pessoais	0c06752da327750ef7af23469cb3aed17bddc4141ffbf8dde9e934c31c9ecb6d	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.75	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7714	7101.Serviços pessoais	429a0e01baec31c10df9df5aa69483938cca52902818e6801cd4728347c8c791	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.26	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7715	7101001.Costureira	5df5346c59b2f80abd35aa0eea7b72b6e7826821b5fa045cd3539531e283f501	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.96	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	12421	7101005.Manicure	44673181300e8631a9f9fe2d073c05563c22ffdae81b2fa0715520444bdbf710	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.52	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7720	7101010.Empregado doméstico	0f7abb54133e53358f2f614cb40ab84237e4fec6f481d09a34736ed647a94a7c	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.71	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	47654	7101011.Cabeleireiro e barbeiro	3998913dbf5888c645ef64da6fab6af0d160228f073c73f88b3996a50949caee	2026-03-13 18:45:34.375355
1	Brasil	2	%	1.43	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7721	7101014.Depilação	d904b3b7ed8fc23a146a2602bb4cd2c127f39da6719d1ae33c029d4611ae8953	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.22	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7723	7101034.Cartório	64cdf32ea131cb3e54afdba6735c7972ad225fb8ef870f95a08c90d32fe8c910	2026-03-13 18:45:34.375355
1	Brasil	2	%	1.23	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7724	7101036.Despachante	30d6274d4e3c166af7f41691e1f99f729ab2f32b8398702bdfc2284280a539b4	2026-03-13 18:45:34.375355
1	Brasil	2	%	1.06	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7727	7101076.Serviço bancário	94843d31106546c4ab61e975871fd4f88d197bc005f30a81dfb6aca2d21fc1ed	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.43	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7728	7101090.Conselho de classe	c4d875ce17f7230c1edc70a8a021882e623604d58596900d1e668d672d281e50	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.67	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	47655	7101144.Sobrancelha	662535ab0334f97ffb2b02792fbbf7bab6984aecc6469b9f30e9d843c5ac98df	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.33	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	47656	72.Recreação e fumo	ef6b2891f36c9e7ea09fe713ad795a061102eb3399e39e57dc0f21619dd87cb5	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.54	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7730	7201.Recreação	30c3c41d6a7bffd0d54e3c53d22ae2e97410a0b03b1cfe37a33969633e808c84	2026-03-13 18:45:34.375355
1	Brasil	2	%	2.15	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7733	7201006.Clube	43659a9dc01a820a133a620905d76638ae38b08c51400756f885760399c9c745	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.27	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7735	7201010.Instrumento musical	03308516c3b9d02d3725bc585af9d4cf49524bbbeaa5ce1a5fada2bf0ccf3645	2026-03-13 18:45:34.375355
1	Brasil	2	%	1.75	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	47657	7201015.Tratamento de animais (clínica)	31e282828a172d433289343cf35dfd787e60c6e6a52b6b429bd203713170b154	2026-03-13 18:45:34.375355
1	Brasil	2	%	-1.02	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7736	7201019.Bicicleta	e46bfff4fb0c6045d44e8ed54dd38660c7e99501953b79c9969d5664fa7aa619	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.58	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	107666	7201020.Alimento para animais	a78efc004096177d6f2208f1d015955f039e509cd35636fc64c4618a5b5e9e3d	2026-03-13 18:45:34.375355
1	Brasil	2	%	1.32	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7738	7201023.Brinquedo	4a6fd725f4027ae02f2a2413e3730ce20b89ecf570a7fe11a939a6cbd9415232	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.56	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	47658	7201054.Casa noturna	72ead4ed9d678fc0e7cfe1ac0a0ddbd3ab5c020b77ed19fc93999be29e8eb618	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.00	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	107668	7201063.Jogos de azar	994c3fd5369270cf9ae9fb314effe5e119dd198e13832047978ae8a847576e34	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.52	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7746	7201067.Material de caça e pesca	b04bb0c1d6600b00fc01ae9e0d4842fedd9c7d40b2a6e08fd4957eff0eb06df8	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.12	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	47659	7201090.Hospedagem	91717b5f40b5091ede8bafd3eb7b3410586fd5b00b907824602ac009162e5be3	2026-03-13 18:45:34.375355
1	Brasil	2	%	-1.79	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	47660	7201095.Pacote turístico	61d50bcccc431b6064ce8fbd20a18a94c4df178f2d15323b706fde9318a87ed1	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.02	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	47661	7201256.Serviço de higiene para animais	a76e25904c3a3d8ad2795c15786d42d15171436303059ba8e36a04bb0f864076	2026-03-13 18:45:34.375355
1	Brasil	2	%	-3.90	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	47662	7201266.Cinema, teatro e concertos	a0ba07b688febed134636375c0b02b35811573812f0deec08df73d659c3f573f	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.90	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7758	7202.Fumo	672df1773e1dff9efdca96f57875d1437005d24da4128c465abf7fc1024f6ded	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.90	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7759	7202041.Cigarro	3d5ee6cd84934b4cc21a29f4c32793d902fe5b5bfb3b5f10dd514cd0018ce011	2026-03-13 18:45:34.375355
1	Brasil	2	%	5.21	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7767	81.Cursos, leitura e papelaria	fd0d13a0d1b762e64a39844977db2a4b488fa25392939fbc923ebb7a45477d30	2026-03-13 18:45:34.375355
1	Brasil	2	%	6.20	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	12427	8101.Cursos regulares	554c55bf3f8bbefe13916ec9d4f8d096a626ccc77d5710e112765992716f1eac	2026-03-13 18:45:34.375355
1	Brasil	2	%	6.28	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7769	8101001.Creche	66ec216986cbe1d3abf3eb47f166f4989b15dd7fa6ba62952daf000385045865	2026-03-13 18:45:34.375355
1	Brasil	2	%	7.48	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	47663	8101002.Pré-escola	eeb5468bc399a3986141c99a6d0185379b433116f5683e381a49b44ebd571785	2026-03-13 18:45:34.375355
1	Brasil	2	%	8.11	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	107671	8101003.Ensino fundamental	83be7509394aeffe53808b84aed9a0a9f126d345fe908a284abcff95dc8e5050	2026-03-13 18:45:34.375355
1	Brasil	2	%	8.19	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	107672	8101004.Ensino médio	e9c1fe52589072aebd04c49a8d3a7a8bcc34670e182585d6a098b6c8fac077f9	2026-03-13 18:45:34.375355
1	Brasil	2	%	4.28	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	107673	8101005.Ensino superior	20f87e79f435cf520fb9f2476ebe17b06219e5071b9ba0e17ae0bb41692cae84	2026-03-13 18:45:34.375355
1	Brasil	2	%	1.68	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	107674	8101006.Pós-graduação	04fb5f24272069c2e9197adea68d28a172965342cf9638a56574b10a074d8215	2026-03-13 18:45:34.375355
1	Brasil	2	%	2.74	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	47664	8101008.Educação de jovens e adultos	1feda160fae72813b6e1898be7d1bd1fb5d5827dc70eaf5a4cf169d8cdd7f7e1	2026-03-13 18:45:34.375355
1	Brasil	2	%	2.05	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	47665	8101045.Curso técnico	c3e74e3eb603f3b0a544c92061209d78accdfdc0d689ada944048f6fe30f239d	2026-03-13 18:45:34.375355
1	Brasil	2	%	1.43	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7777	8102.Leitura	18d6f15ac8a19e33b655b385208c615cf22de7b90dec281c490d411167ba48e9	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.63	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7778	8102001.Jornal diário	5a7ecb62b79f2d878458d5822a851cdabe08d3cf1151718b7e5580d7ef7a4eca	2026-03-13 18:45:34.375355
1	Brasil	2	%	4.72	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	107676	8102004.Revista	f716ac29480d9009673e50c599393bce74cb70d551e19c1e6b91d8b259825a63	2026-03-13 18:45:34.375355
1	Brasil	2	%	1.03	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	47666	8102007.Livro didático	16a66d2eac2fa38f29be1098b6739b7e7fb70449f886304414798dc6c469b0d0	2026-03-13 18:45:34.375355
1	Brasil	2	%	2.02	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	47667	8102008.Livro não didático	56f4d921eaf30f84270aa9623f96d53c69421328be2f7dec586155b8c450d1da	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.44	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7782	8103.Papelaria	03f45368166e5dc02af2f94519d914425c86abef8b28ef3a7cea86f4cf8cadbe	2026-03-13 18:45:34.375355
1	Brasil	2	%	-1.61	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7783	8103001.Caderno	66e33a638c02ec45bd641762912e957d329a8b5f03ee817390724db9a2c0959a	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.25	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7785	8103014.Artigos de papelaria	fabddb321123d4059cfe0a1b8435a7399151e3120e2567040a1c55fac3c416ef	2026-03-13 18:45:34.375355
1	Brasil	2	%	3.24	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	107678	8104.Cursos diversos	44eb2efd336671132ca689a69b26776b3aa75d14ebf62e4ecf1f535d6d9016cc	2026-03-13 18:45:34.375355
1	Brasil	2	%	3.57	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	107679	8104001.Curso preparatório	d748a870b300ff0daff60b24660113d9941b0a576f813b11b68efe368cdba2e0	2026-03-13 18:45:34.375355
1	Brasil	2	%	4.45	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	107681	8104003.Curso de idioma	80ffd37a017fe3e21908d2a059ead0f2683a44416fcccfc6d6e6d86a9ead5926	2026-03-13 18:45:34.375355
1	Brasil	2	%	-2.30	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	107682	8104004.Curso de informática	990608dacab1bd1de501bb31c6500f574128a239c1bd7f3ed3663318073a9b89	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.51	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	107683	8104005.Autoescola	72eddeb6107ce5d9879cdd011713205dd3028929d0fbf2078f1c74a5e18a5b68	2026-03-13 18:45:34.375355
1	Brasil	2	%	2.70	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	12428	8104006.Atividades físicas	732f45c0c899ad0159974b32cc25b3d928c6539c6812867b89e33a68732d3397	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.15	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7786	9.Comunicação	8bb0d7a22ef3f466ebb89acddecf785cce6048c52144778468924bd1e5044329	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.15	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7787	91.Comunicação	0eb06648cf2c442364aeabd5470bc5fb24c5063c916a835d1ce2b09f4a558197	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.15	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7788	9101.Comunicação	e7a50837d5e2ef6600258dcb66d12b7dbe760339bd0feefbd3b24e9d7bb3f613	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.00	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7789	9101001.Correio	0b93d261fad4e1e50c4f015be8e8f47c257179e83f201681d79c46e6156109e7	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.00	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	47668	9101002.Plano de telefonia fixa	40440fca40abb416d770c63749ee0e198f51f7edcc323a5773d1a8d9f8fff7cb	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.64	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	47669	9101008.Plano de telefonia móvel	0efb8168408e1aaea22d057af7dfddeb6255ac96ce75869d9583c9c2f56614ad	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.00	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	47670	9101010.Tv por assinatura	312ea77768c8e4514ace45f8ada2b9707548acc878c2b78751dc7f809651f173	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.00	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	107688	9101018.Acesso à internet	73c8ac2fb3d7ef4ac0ea5cc27891264a15a20d3256ebe35eab0a08bcce56295c	2026-03-13 18:45:34.375355
1	Brasil	2	%	-0.17	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	7794	9101019.Aparelho telefônico	c1c875f20cb7cc78616015b9954e9f2f0acb000badf3e4112279ce630e399a53	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.00	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	47671	9101115.Serviços de streaming	e7d520d8d0068089e6afdb6e6b67596c89d1918aa67509e32594ea274be92b7a	2026-03-13 18:45:34.375355
1	Brasil	2	%	0.00	1	Brasil	63	IPCA - Variação mensal	202602	fevereiro 2026	47672	9101116.Combo de telefonia, internet e tv por assinatura	fc7aafb0312dea3d6bd0e7373357ffb817daa8d5387932ba6843bb09a2487123	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.74	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7169	Índice geral	724f5efc878e0c6e97969219f680981c930c057da7172f2ae4f16dd887adfa4f	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-0.21	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7170	1.Alimentação e bebidas	50aa1938f2ac74e4a878b224b337b5d4853635e6e6bc56af0bcdb594d0ba9d9d	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-0.44	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7171	11.Alimentação no domicílio	94ef783db8fe934b7cb2f052693e50d9294c9221767ce4bce0dec9d886790152	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-1.55	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7172	1101.Cereais, leguminosas e oleaginosas	dbc3b36703dc8a29e7ca9a8e30e3ce4377afc0d1b167e8103731ddbbe25994fa	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-3.34	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7173	1101002.Arroz	aa23bf76076939845d332a4b4fdfc6dfaa9636fe7a7b499c1d73dc1272ae3639	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7175	1101051.Feijão - mulatinho	b711a88cfb9ae8e3267959b44f16ff593e7c21c27b1d43ff3bcde4f88aad63ab	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	3.39	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7176	1101052.Feijão - preto	19e64028b24278e84340a7c23720249fe9985ce95918870259f7ce59b2472577	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	47617	1101053.Feijão - macáçar (fradinho)	c9749b1dbc5fcbeeb9ce5f41b0f4b07b031ddd20d8c7aa2cee58df900fb9af0d	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	12222	1101073.Feijão - carioca (rajado)	21972485721d8a8343d4dd0914b9b14bbe36d2e1bd3cc2f183dc75b3ef85acd5	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	47618	1101079.Milho (em grão)	f6e4c5a54c62742cb5b06d43d5e7820e123123a50a716935ec0cbfd96d5d6315	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.19	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7184	1102.Farinhas, féculas e massas	cb14cbb428918dbcbbdc30d2dded08ace0d875df9fe646af486fb934cada1a39	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7185	1102001.Farinha de arroz	bf1959b5e5e5c3f5282fc6782067ba9bd1f76a1a45b0c147070688e61ede1914	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-2.80	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7187	1102006.Macarrão	79d2fdebc0b36627ecb34f8bef04e23889c28e916b05831e5d41034669b6b8d3	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7188	1102008.Fubá de milho	036ac98ce9cbaaebf0f9f95ef648a2108866469a54fc4a652245c3e338b31ba5	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7190	1102010.Flocos de milho	e9280c78c2077ed2b87d9665e7334e08433d20e161de6aed7e9410fd198cfee0	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7191	1102012.Farinha de trigo	30000c98698a9388e70e99729c2afc77c530be3f989723d1f257fe09a2b7c4bf	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	4.41	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7195	1102023.Farinha de mandioca	66f0dae18d821137accd3c4bc6718011f0ef1d45d4ae9226f2652d997a56b7e9	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	1.20	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	107608	1102029.Massa semipreparada	08c5f66f767b74c0032b899e37a976084b53b8d3896de43f678bcedb10af431b	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	1.07	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	47619	1102061.Macarrão instantâneo	6044d42745f46c1d5cb58209671bcda3863a98b964568daf4d455bd5be4dd916	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	1.53	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7200	1103.Tubérculos, raízes e legumes	54f125bfdc7faa805fc5a273ac0d6458455a947a344e7c492891530867f3e09c	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-0.65	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7201	1103002.Batata-doce	16d82463bce40a5364d62a1f7b29f9f2dd95723e852e9cc22bdc4723af798372	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-1.02	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7202	1103003.Batata-inglesa	53561407d46d1cbda342c2a949c4da6220d41e1e4162926180a768f82c290438	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7203	1103004.Inhame	8712e3d8a280f0bffd7957a978d004d62076fab1d22337c2ac8516544f0cd3fe	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7204	1103005.Mandioca (aipim)	9ee409909ded3a642160d0a6380926f0883d9c67107382dfb414556d70cdb8b2	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7206	1103020.Abobrinha	e3f828c818abfedf6f8594b2bf6867b80ef96d1dd116acf17197d3016fc32287	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7209	1103025.Pepino	e7bee24ba664c0457919e47b84cfd67ef1d5ff17208d481f4e396cb72b305537	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7210	1103026.Pimentão	a1922ca72c0bef6e23e8b1803a2de84a78197d00a426f6fff85286c151984044	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	11.47	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7212	1103028.Tomate	01bdc3ccd23aac4ce97e8d6a1b945d2fad61d53a955ab82d058374f49357c8c9	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-8.89	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7215	1103043.Cebola	adc1c4802aa7abae4e69d2e531d93ba38ab71022bf9b01e20494bacc03115ecd	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-2.26	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7216	1103044.Cenoura	f5c6ee2ab4492b717b1393846927815be63d746d9fffa920e24908cd839aaf9f	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	1.23	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7219	1104.Açúcares e derivados	afba5d596026624e31fa495be5a116a518e9aaed8ea86c029774f0e8f7feb709	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-0.63	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7220	1104003.Açúcar refinado	88140991c7007a9d7a4c98fe74a6240267e97cdfcd2142569ff3bfcf9b0aa329	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7221	1104004.Açúcar cristal	eb370dbfa91a07ba1d36e28b21b9312c404fae728fa98783d98e4fee75dd2c3b	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	12224	1104018.Balas	8bb95964f3fdf9a65d56543c38a1c61b527dc7a2653de88063736fa296cb3f71	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	5.19	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	107609	1104023.Chocolate em barra e bombom	3f39214e23623e613884b2d18c62bd339371829abf897c1e29bbcc0c1110844a	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.77	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7230	1104032.Sorvete	230ab59151c4a8dd5ebd20b0c28524c665878ddca4454fc5fb5316e801ed2932	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.52	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	107611	1104052.Chocolate e achocolatado em pó	5677742a425a6b4efc6981a114fbdac1d22d6be533718b2385779d4505b9c365	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7233	1104060.Doce de frutas em pasta	9aed3ed7f9eddfe3ef6ac5bfdb95f4edb76203a63950a897fc9ea4e37c26faf6	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	47620	1104067.Açúcar demerara	fc64d839600f8e65ab011f3303cfb70bea1a3318416c04cbba0792618420b250	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	9.21	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7241	1105.Hortaliças e verduras	0e521a67fefbbc0fbfafd992b27d23602e5dfa4f32ed9dbf88cc3ad2a392d58b	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	8.95	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7242	1105001.Alface	71072607d50fdc681bfcbf5330069dc2f4e7721373ecd3dd61bbe3f05258fc2a	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7244	1105004.Coentro	b4641a81e87b00d2f2717c61dd57a997765cc34769dda8f5f11831ee69ac8d27	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	13.62	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7245	1105005.Couve	0978809fc2b66927527b28e8f0a235c17846a89dec7a6a621978aee1e7d21ab2	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	7.29	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7246	1105006.Couve-flor	0767dfd010f2012eb6f53eedee6c277eb493b85340859db80a7e5f9c1cb380fe	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7248	1105010.Repolho	86996c1ff48d0f582ccd13fe882919b5104ed5ba721965890a68cde3dcbd61b3	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	6.59	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7249	1105012.Cheiro-verde	0904f7da3893f6e688b3e183e479c98ff36dac5664c2b0cb3658278cc1c66ab0	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	10.23	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7253	1105019.Brócolis	6ea7b1b77137fc664adad20c078098684cdc61c13035dd7fd91e4ce26652fcbf	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-1.98	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7254	1106.Frutas	a32be58d741820d543c28848a87e2770089d4c6e3e1805632f3a7292e455ab31	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7255	1106001.Banana-da-terra	f5a6912a5aed5816985ffe112380153cd81f0147eb50a56d4a8d8bf45907a743	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	15.32	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7256	1106003.Abacaxi	43c72a3b15e5670817f4b51200c9038594911d3231001c7e3943a8cb49fb9d9c	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7257	1106004.Abacate	2ab0b4bea467816acbb193ce082e7203b3c93bc48cfa0d5801f2701eec3377e5	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	1.64	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7258	1106005.Banana - d'água	4a51957ddb04975db7c1e9299deabf3876aad9b5a72d0ee96a3700be6c322e32	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7259	1106006.Banana - maçã	549b30dd801c5c05de71b6e1b44ca615129220f49d5c37a32b1b4355997a7431	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-2.64	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7260	1106008.Banana - prata	336ac38ff8e6579718ce508b243befe07d319f3fd9b36cd67cf090b1ad847b48	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7262	1106011.Laranja - baía	c8f4065bf758b96fb5efbbc88446b642ae93af9a97f113722750ad11e197c0d4	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7263	1106012.Laranja - lima	78cec739ebeb3aaee539b00cea2b1b2d0105c0b11f7c3312e5cdc3420a430921	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-8.58	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7265	1106015.Limão	834a10507f5156508c12842de47e5e029977e4df02526f55bacf104390637314	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.90	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7266	1106017.Maçã	1d02d827f247089bb8a86814bfc4c5a728d113f9e6b2e8cac68009eb71adfd57	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-9.09	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7267	1106018.Mamão	c89c7d67eb09e71f6650c87dfae2b5ad1907457e9bb0b822e1deeeb77fa0b952	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-0.39	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7268	1106019.Manga	caab379c607f0ce216e9418ba3ecabf2b0352f5fa0967ec902c00f7ff1ac63bf	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7269	1106020.Maracujá	aa6237887dc94330263c63202c46b34197567c302eef569f29ccfb13218dbc27	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7270	1106021.Melancia	9b4b7dd8602487ecd50e4fe512cb1f9adec388a7e3b66d1138a4e01b4d85343c	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-8.07	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7271	1106022.Melão	af010e24f1a612ccc3e3dd51914887a1f36d603a61cdf15c96c6fcc777ccf714	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7272	1106023.Pera	3651253f8e7dc10701b31e56f9130189009fba6f6cce23f6c477de93d11db9ac	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7275	1106027.Tangerina	cc6b5e76b770a5bd95ef098e44279c26f9d7e711643b32ff72d6387951676d9d	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	4.57	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7276	1106028.Uva	0f80f2b1153f0ae3777ae44aa673128caa11610a50b30636e3f9daa4c8a54c84	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-7.72	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7279	1106039.Laranja - pera	836f964e50688c5f07596a21047cb2a9c6457e61f90df18e526f2869e79101e3	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7280	1106051.Morango	c02a9d0875ef0f4bb3d3f9491366259eed6f18eee75ab3a2a62afe742445e209	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7281	1106084.Goiaba	feae84bbef6fb3eec50c51882271fad10a8e9655c75fa240eee71c4d1b63f243	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-1.12	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7283	1107.Carnes	7ce4b71d3d847738e1b1b9ad66c061ee4add774c6a44ffed0bef5a2b1a3fbdbc	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7285	1107009.Fígado	f2c64f16e08ff6dd584b06ec3f82dd36c2e71054e664c5c3fc1356e698be0ac5	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-3.33	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7287	1107018.Carne de porco	a6404fcf353e01a3836b41463e0e94980c4063cd28368f9bdca0caec4a10b195	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7288	1107031.Carne de carneiro	0f23c11483450adcb1ed563344b16659b7eae9e0206698a59ff42a215ee4747c	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7290	1107081.Cupim	e2d6c987050ed4962acb4da2c5814358d4856a57a9d0afca324c71bca2177f67	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.08	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7291	1107084.Contrafilé	fcbe2a3ebb281621b6539a1f269fa140bed0b354c9fe8c561d5974c1cbe26e94	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-5.91	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7292	1107085.Filé-mignon	542221f940365fd580d783453d0ebf5a40f19656644319480185a48b45805ed0	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	1.64	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7293	1107087.Chã de dentro	02657935d96f77b5d90a85191bab270f372d1206a34798d16e4407971bb3d3a0	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-0.06	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7294	1107088.Alcatra	bcda1911af52b1d284a3ee93a047e16d1de48c5609cec86bf07703f1c9a94a0e	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-0.75	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7295	1107089.Patinho	ddd147b2430f6c52702bc4019a1f61644c93c97a026ebc60d70b2c307c55590d	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7296	1107090.Lagarto redondo	14f640dac8513ea4c13bff9be2f2ff6540ebb4fca09a7acf45eb899b0457a6d8	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	12294	1107091.Lagarto comum	aa378a89d1fd24eec47ccf36aad463cb2b53ee40fdf8bf6d869f6f82ece4ee09	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	1.87	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7298	1107093.Músculo	c231dc907a67da292ec5f23cd6a1f4a2545cbc30b6e1092ea0e9276b5d492c02	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7299	1107094.Pá	52f9a2ac8fec02b33a2b15b9dfcd0474347d38bc9660479ea1c3c23b17917833	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.14	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7300	1107095.Acém	eeaecf6e9cde0703f5cdbb74f56c081bc5e5ab346401980ae3ecec0cc060a813	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7301	1107096.Peito	c0db08e16df4d45999dd203a0ab34702925c400189ac38f9a4a5b9b9f76c34e9	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	101448	1107097.Capa de filé	a8eb730bcbfd7f665df209e43a8511f1dcfaffb28675c592767f5222aa2d0445	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-5.40	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7302	1107099.Costela	673f6a8ab34dcfd597468b312105ee06c92d45e33b689558783578c2cc5c4902	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	47621	1107208.Picanha	1b418de626862701cf984be6d9d8980f0a3ed4bbff2fc759b93bf73b34fa014a	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-1.72	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7303	1108.Pescados	26e4f6c8828e7ca0ee160052bcab22d1e8df51783581768d550e96a5f4398fa1	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7305	1108002.Peixe - anchova	16d42e78645dc2465893a4dd0fb28a24c5062efa95b123612b5254171524f4f1	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.59	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7306	1108004.Peixe - corvina	b739869c25394bedd6ea5491dfefc7aaad4af86cedbfcd14e44aad2a89f1864b	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7309	1108011.Peixe - tainha	f85848570aff155b66d7d40b4cded8de7250d84f9d1fe21dd307bd5122adbb2a	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7310	1108012.Peixe - sardinha	03675ba31d6ef46a033f01b6bad00dbea12238178bca4e8bd6ae6d6c436de4bd	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-1.61	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7311	1108013.Camarão	f727a122dc1aaa4b457c75ce5edf7c3c8af902285fb7eca112408cdb723a69ce	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7313	1108019.Peixe - cavala	fe84925aa8b56fdaecd38aae46e0b6aa8797caafb66ebaf6f2acae5fb3457d60	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	107615	1108029.Peixe - cação	c738002845b13393ab0aed808fd965bdb6c596eb7973d10d05e30e3c8453ac8e	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	107616	1108031.Peixe - merluza	cc15743b932d33586403743f3b5795a6b03f3d0d0cf8de8f6a82700ed43f082f	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7317	1108032.Peixe - serra	63c018fb0a0abe2ea227ae062513de18b41efdc4f2450cc7923163664e68fa57	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7320	1108038.Peixe - pescada	8afbc4dc2651d0fd1e7a4c9e9424ad5e49df29b6d907b4147674dd2a4d0e2e86	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-1.72	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7323	1108045.Caranguejo	599d6ce92411aa425270e958fec158b4bf8567b67e81fbaa600d2776a6d73718	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	12300	1108049.Peixe - castanha	b6e2d5ae575f5bd9bad10e029cb838b150b2c085bfd4d38ad56052a5c9234925	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	12301	1108052.Peixe - palombeta	2860bed8b4b8c26d5ae038ef2e19c248f92119009dc93f5e4f7c80e4ca26385c	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	101466	1108072.Peixe - curimatã	864a436d5606090dfd5431e26f0722c45f3c852cfab33985ffc9dc31636c7c88	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-7.08	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	12431	1108075.Peixe - salmão	acb6207da326efac1a1eb4ce2625299e25e73ba8b77cef38e896f67c31e4373c	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	12302	1108080.Peixe - tilápia	de41590c387059c1a778288c61856df7bbb1b45c5c2ab850c8ff62711af344ad	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	41129	1108087.Peixe - tambaqui	4ff27f242474f43d8d690e1664ad90b2e9398f86301aabdbf1b8446562a8bb65	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7333	1108088.Peixe - dourada	29ca9ad4f23fd0d0e057ab7a5497d0e7d02e4cd4ca0eb4fd781e768c3d3bfde7	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	47623	1108092.Peixe - filhote	17433504edad46e207cd32c4c71e3e63a6cac7ef996fa1a7009331e195b0dd49	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	8874	1108096.Peixe - peroá	ff560a70b527315a126e42c988a862cc0116ba8563f0b34f1daa29444bbdc5fb	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	31694	1108112.Peixe - pintado	687391c0742754c689ac49c36a61c231dcbfeaca331a8bdd8dc90804b1ed88fc	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	47624	1108125.Peixe - aruanã	975cf81879ee27e64e80940768dd47da7601717aa902f867851512631c512e6c	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.33	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7335	1109.Carnes e peixes industrializados	e68c94f3116c7c1136f4d61f902806e3d1f26e76a073e9983f09028af408ffca	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-0.73	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7336	1109002.Presunto	00fce7a81d5e8272cf6e30c9b24480d5fd793df05e1a11a50b744ea3979df9a1	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	12304	1109007.Salsicha	df1183f8c139506b1549f7234585b7564dd5be440743939965734048851f4bf4	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	1.41	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7339	1109008.Linguiça	d2e0c761c9bcd6fc3b5f90c4780b06720299c06b3f4e1910c386dbfabb38b71f	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.48	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7341	1109010.Mortadela	91415229a922da281f4a6dc5a5e3098689d15d313c9f81ce11c13127a8bfd855	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	12305	1109012.Salame	219b579ec32dcb894025acf0e03f1b652d898f4b92a14340748d7b6949c81e1e	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	1.28	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7343	1109023.Bacalhau	d977b407ceabb6c67604e6eaa8fb057a32b3a5d0f4753cc2f0c1fdfacb700ec0	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-1.24	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	12379	1109056.Carne-seca e de sol	d4e65813c2d9d41f71c4609b2d20d3b67aef351df1a28e032820b67e43f12c3a	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7347	1109058.Carne de porco salgada e defumada	a2eb46a50225ac5636cb64d3a6c26d122102eac6042426e0c5b8ae5658bcb673	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-0.83	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7349	1110.Aves e ovos	d1075cb5392efcb18d57965aa6b55ee883487c49a8c59af05ced37ba35f555c7	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-3.80	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	107617	1110009.Frango inteiro	ef95aa60f99394f2e286af6dd9600ae6f659bef110f6115f15066b255f6ab0c6	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-1.95	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	107618	1110010.Frango em pedaços	f15e8f5fec5aae3f02308fd6c583ae886c49a7edd26ec2f728b602d43e0e72f0	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	4.57	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7355	1110044.Ovo de galinha	a76cf30a9bbaf34a3b6cb5bfee80eb99c24ee1dfa128e31225e02521afd82ae8	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-0.61	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7356	1111.Leites e derivados	59fcde7c7b709176fa35c8c7f81c75549e5cbb12bfd4a4758d722715ca3342cb	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-2.01	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	12393	1111004.Leite longa vida	61e4ab46f9176f463d9ea1236d63f90f185df4def3fd1e3a4fe26d10546b1742	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	1.97	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7358	1111008.Leite condensado	6afcfc8c4b588dc263d68f9cfac39831bd913c5fe345baef112f8cceb5a5a80a	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.28	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7359	1111009.Leite em pó	31fbcd3fcda19237f6024c72e83371723c498c46068b9cc6047acbd4580d99cb	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-0.04	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	107619	1111011.Queijo	05bff3c0a74119702e4457953fd9837454f50341f23ddb19eab5db3652fa278c	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-0.87	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	12394	1111019.Iogurte e bebidas lácteas	551584e68b91af3ceea3021968331cf03740ec421abe8689afbdb864d134a15c	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-1.24	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	47627	1111021.Requeijão	0c52ab82d21a299e5c19f3ec1c5798dc4570b53099e446083296b2702cf24ea5	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.98	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7367	1111031.Manteiga	ba680b39ec528c6e8f4c96794a9f63ab4a5fc43c2298c1829727c4438efbb79a	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7368	1111038.Leite fermentado	dc6ce03ae51a058cda4294b8d5efd30dd20b0c6553a67d36fc0041c5f2479679	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.91	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7372	1112.Panificados	2f520cd1a601a14d1dbdea47dddc0a1155d17a359a4c82505448925ccbb3453d	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-0.74	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7373	1112003.Biscoito	3e02a99a4897ef3910179c892791d77960e7be29d89530108088efa8f61f75cf	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	1.25	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7375	1112015.Pão francês	ed2d2da4b5f50b18c9cc81a8dca3546938e8ca46889f02fec688ab89ae4be07d	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-0.22	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7376	1112017.Pão doce	4899af9f9b2c2d24df231a24666a6872d75e47698872a4ae13a0cc341db9f45a	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	3.20	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7377	1112018.Pão de forma	098c7d0502f9004c87953531bf6f9bd030d930edc2c9d2985313cd9fba30f9e2	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	2.44	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7378	1112019.Bolo	ac2e010b2956937c308c55bc5ae975a8675db268df73662107cc6a29abc198ef	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7380	1112025.Pão de queijo	4ae47616c8b3717135f89ab633cae85ecd646bdad428247d8605816946869749	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-2.20	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7384	1113.Óleos e gorduras	143e51b45780d5486072ac08ab644132d078bb057e092626514fe1f557be558b	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-4.22	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7385	1113013.Óleo de soja	3981e559ec4fcde126e9f8733ac3a0c72b2188fab15e0f630d79ad9efa04d2c7	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-1.65	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7386	1113014.Azeite de oliva	cdb1742d70c406e50749005676fb3bbb20b5d1ca878bbd087c8b18834afff2a8	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.32	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	12395	1113040.Margarina	8c7dbb906164a99dca6b73f6050d030e83bc787dcc5db6f849b3561a1f1d51b8	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-1.03	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7389	1114.Bebidas e infusões	842f101f42b0bdb6dc9770ece6b49aaf547e3a3043a46792a7fe94e842284b66	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-1.29	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7390	1114001.Suco de frutas	6f12148e41a2cc6751c495baa18c78c32d25b1df08636aa363024b84f674e185	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	47628	1114003.Polpa de fruta (congelada)	55f06c097d4a930b9080e94dd08bca9c620ad8b94dc610613f21e28786c515b7	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	12396	1114004.Açaí (emulsão)	3022a1dc92ac47e97659722ec84b4ef2a2c89b605adda28c545b65d08a4724a2	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-2.30	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7392	1114022.Café moído	e38e532cd72403bcd985d490e9718998f8026172fefc122cb35c3d7c2920eb13	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7393	1114023.Café solúvel	2c544e1cf35ba3f785097cd7006e25d4ae0c84dbab2b4c5e512a51f4004e99e7	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-0.57	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	107621	1114083.Refrigerante e água mineral	ca429c1acf45400ad0222901717083f5e4db28c77a8079a4af6c87b70462e979	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	1.08	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7396	1114084.Cerveja	eee1af90e12ad40e476a92c0bb7fbc6c9b333fc55208fec7a4cfb11f5b39592d	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7397	1114085.Outras bebidas alcoólicas	8df931878d4fc18f87c019a36431342e4aa33de8d9ae0709dee2f798ea97143a	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-2.01	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7399	1114087.Vinho	2d4b81f43845156f7e4ac78d0311b65859c1b8cbdb10a9471875e5ac6c33077f	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	47630	1114090.Suco em pó	28b3b82dbf0b4fbf7273831a9aa6d7aed2ec0180116d0d322c30005a14e29446	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	47631	1114091.Chá mate (erva mate)	c9f18978de367494e801fcdb993bae91d8009a6e1c7fa4b376785281648ec4eb	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.83	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7401	1115.Enlatados e conservas	f40df1a6d005e6b48144402cc122b3578c8e6442d62c61812bc73c7a04cfe803	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	107702	1115013.Alimento infantil	37a99719917c9ffc8696bbbad32b879000abce59fc21e37fb501dafee0f1c50b	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7406	1115016.Palmito em conserva	36b8275c0c74ea012cc92df208cc66c6a237c545c8f4e6dafaddb515e27ca17d	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7407	1115017.Pepino em conserva	7d3370bb3f34a9aac7b02a781cc4c4f7e1165362ce31b25d5c94ca9dbf386ec0	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	1.45	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	107624	1115039.Sardinha em conserva	02f614b73467cb82d85d16cafa2dbac552fc40ac4417c4001eb2718f2cc16209	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	107625	1115050.Salsicha em conserva	3d11e4e520f621ed5d729b7df68e6fc1839d426649cd7b50970e89a9a89e6539	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7411	1115056.Sopa desidratada	9a2d138af03440049be0cfbd31d70471302488e301a46e92f80e2a3104dc0dc2	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	1.18	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7412	1115057.Azeitona	9088267f2605a8c4d84c214c5f22dd1a4d10b422a2f43ca2387645642fe0636f	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.33	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	107628	1115058.Milho-verde em conserva	78dbf0a350676bfc55e4ecf7c9e9321919015b8f6548cedd1a1166c711a9635c	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-0.39	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	107630	1115075.Atum em conserva	215f034e3035b79a4c098950626a35cb3a0132d1fa0e8ab4aa057d0a32c2f733	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-1.30	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7415	1116.Sal e condimentos	1ad089019bd8d08580fc60ad546a11d107ef98aa878489412968bcbc476d83e6	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7416	1116001.Leite de coco	606be20f1037f5b368da290379a6f5defd86885ffd50d7ec64423d4fd93d71c0	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-0.16	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	109463	1116005.Atomatado	cc0d4671375f42a4262814f28bc79422f41009128a02d0a5914bfff5531e1ac5	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-3.40	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7418	1116010.Alho	d9e2adc599e53ffed20318f644532f54f7db63f89c92ad905a179bef7e6474dc	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-0.21	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	12397	1116013.Sal	9139d08da31453e48fd4619b71dddfdda36eed787568cfa4dd64dadac9335df6	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7420	1116022.Colorau	0ceb9c457ab2ba7f8fe708beff54bcd0d7a64b210669f641bba627bce7a14e03	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7421	1116023.Caldo de tucupi	ad393353a4196e2fa2b0ff1933af2f0680f7f3dfcc2496e0ae3cfc3d2b33c14a	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7422	1116026.Fermento	1da6bfa24dc4565428174d65be6d1bb6b6a23cbd456bacc46191e9dcb19b4639	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	1.67	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7423	1116033.Maionese	0e0919d647f370d1e3e0f90ab195186e8bb3e6b4aff1596f3e44f87eb53c21ec	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7424	1116041.Vinagre	1cfcec2d786161008c6ea1544df9d2fe44db005f5f882b5b04d08409750ad008	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7425	1116048.Caldo concentrado	faf4d0a835bd2495a00fd63483cf9f7f8c6c1898824ed96694716497e1137726	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7428	1116071.Tempero misto	bebae1bfc856f4f7a7871a39d94b17ad3b0541670f2638f968c268fe7c52e36d	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.37	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7432	12.Alimentação fora do domicílio	20a9eaf4efefe928bf4bcc568b07e4b0880a4d4e0e0eac73214fc33f4707baa0	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.37	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7433	1201.Alimentação fora do domicílio	958b55113cf7a045f276718f6b925f9a76119987fc9c94ebc80bb439b815be6e	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.85	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7434	1201001.Refeição	d1a2f891ed9db322cadbe0096c20851cae328c27d936e73a82723b9e48cd552f	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-0.42	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7435	1201003.Lanche	d60316aa94e8d374dce6462f07a7abe4b0b944f5a825c095e8581290590f9c95	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.13	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	107633	1201007.Refrigerante e água mineral	06303c709c98034de53b143de46f9faeccc1b053159833c219cae7379c00a6e1	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7438	1201009.Cafezinho	d86f0f66d3d57b3434052a0ae1e7fa29e0c0d140424dc8f4e343bb76f5fce59d	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-0.99	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7440	1201048.Cerveja	e220e48911dc33967a0b5e4b219bb17373654682b77953b17637cb53d26d394c	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7443	1201051.Outras bebidas alcoólicas	af07ae7c7b713e9daffffc75d7570865cd547a3d4f62b4df1ad1f2faef05b6ec	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-0.37	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	47632	1201052.Vinho	0831a0369417f6a47c7ac100d85bf22d53f2d5019e390c2c75f9d1c45a3d82fe	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7444	1201061.Doces	1e0cb211600404d981f231896b30fd76b17b1f918eeb9984252b591dc74c5afb	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	47633	1201088.Sorvete	3f03a1b2131b8f942ec1dc2b062bfc56dda358c6b04843e9c64f950b81865c5e	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.87	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7445	2.Habitação	8784213883bb84917d6829e0200bd82a20ade1ecb2adfbcabfa8d281be4d32d6	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.55	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7446	21.Encargos e manutenção	ee2a859081895dbec67108af0056ece815ca54c747522f44caea5d43164955ee	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.67	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7447	2101.Aluguel e taxas	2e39920574fe29ed96fdbc5ba779f591129564ed6ba577c5cd1a6876e9bdc062	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.34	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7448	2101001.Aluguel residencial	4385f524a56e19f439b2babe866b5b8ccca499f6d6a8646c65d0c447f9a33174	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	1.38	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7449	2101002.Condomínio	4674b60cf3acc40a61452abf1cb2d4cc3fc0573589e5ff0eb836002f1a84d531	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.00	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7451	2101004.Taxa de água e esgoto	cb8e09f6b709dcba87c3bd3fb599f8bb469085def36c79301cce0eb4fe6f57bb	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7453	2101012.Mudança	e5c14d5c4aaac88dd62729e638271dfc866bf4e8f16c4b1d414c2b9e02846f21	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.34	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7454	2103.Reparos	69d78db99f6acd3ad89dd9de63641f381867b2d455db7d1549be2d386f7ec451	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7455	2103005.Ferragens	eada9cd8aa9cd7d62fda9d48f3245e6da77ceea1ae70db11baf06eddcac6d327	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7456	2103008.Material de eletricidade	bbc622d737e2940b1716a1811e698108f9a6a7556b8ed314a3d0719ef8d87163	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	12433	2103012.Vidro	aa1be7346573af69278617a8682335d4789d88a1d66c33a5f1165d1f41b2058a	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.22	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7459	2103014.Tinta	89ac36b8cfd6f8a83699bb3b24ed307a9188decd3c9514440945e67190305493	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	1.04	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	12398	2103032.Revestimento de piso e parede	a54a874bfb1c4e319e130ccc9fff432d1b1058319a50bb05b5681d56e7206acb	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	47634	2103038.Madeira e taco	896334c07a861f8d816cc746585493667d73b5033b0ed63c316763f669225553	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	107638	2103039.Cimento	48ceca46381fe7bf8171067e99b19f30233a09db2e9a0937cf41e7ff0254e41a	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-1.08	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	107639	2103040.Tijolo	2867b756d4c2766cdef7f9677ef6f113812699e7e6e7d47af0b4ebb6ca60f767	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	107640	2103041.Material hidráulico	0b3bb4fd0157846acd595cf9b4b030382ecb3cdb401e27d69f07232c057eccb6	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.69	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	107641	2103042.Mão de obra	3894d52556942f299e3d1fadff63c92b667731dbc7ddd7f79359351053a98005	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-1.62	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	107642	2103048.Areia	0ec9b0c4d487720a9069bfcbeb387b32a764a09d6c92bc241add2c2132074aa8	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	107643	2103049.Pedras	fa02a716ebb629f8ae3f11b06bc2f8aafdd3036cba7996f4b7b1739f021c0afa	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	12399	2103055.Telha	a501b1661fd7c9ab170a5328d42d9afa7d071196076b06cd6e9a25c4a1fdf14c	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-0.85	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7461	2104.Artigos de limpeza	a6e41d7f4418ec583a351a3617951f6598a6befb6f583c8a6126a75e8b9bee34	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7463	2104003.Saco para lixo	3d8d79b3906d5947c71e50bf082268347d0b7ce5394831e744a4eb051c0a6381	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-1.46	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7464	2104005.Água sanitária	b795d33a4c7b989384fab1d9b1bae686b3d26d71a5a25ac3837a586b55b820d0	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.34	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7465	2104008.Detergente	b824582d1b5a48ca5945c660a3683a613682c20932aec73948f0c98fe0f092c1	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-1.78	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7466	2104009.Sabão em pó	122bc1cf0534eb0e4527a73ca5dc695314807339a5bad433db44e90f1e017552	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-1.10	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7467	2104012.Desinfetante	f5cf2df57d5f8dff8113be15d018b0b09f36e03ab2007d300c55573eeedaef6d	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	1.53	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7470	2104015.Sabão em barra	95956e4d3969ccb2b4e32c389be833c5e9b67e63c7c870a307c897a1cb0d8260	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7471	2104016.Esponja de limpeza	86a838bdc6e19c4e6511579d7e8f08f9b89e1b12062977f9f4ed181f3ba14b9f	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	47635	2104019.Sabão líquido	aa7949dee4c50b1f6e4218ab2c683ce3440d83baaac5e2450171543bad066fd5	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	47636	2104020.Limpador multiuso	45fe39315773be27d9331901f83ecaa9f3c63eaf52dd289617f3b24caf2ed728	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-1.16	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7477	2104041.Papel toalha	37dc5c098be3ba586db2a8fe1d01a1e686a1dcf416045f5fcba016514e48b13a	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-0.66	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	47637	2104085.Amaciante e alvejante	ab93afc15a9cd975d5b13d905b66645a6278bd87dc710d361639778f6bd18829	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	1.41	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7479	22.Combustíveis e energia	22738bfea88a9a9e8193d8e40878fd562c6a4e2bedfa5294d48586c641dbf9b9	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-1.20	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7480	2201.Combustíveis (domésticos)	404c3db53411d89be2c4f693c8e0744fb9cf48d413ea21290f2105ee4885a8ba	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7481	2201003.Carvão vegetal	12ca42b8bfffc3b5c58b861d524b1f29f5f4bb05ee4932c64c2e6f5167e62668	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-0.03	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7482	2201004.Gás de botijão	46d01ce52fcf4dac987c09b3832264ee9ee4a62e5b4cd702c78be1d12c3be861	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-3.64	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7483	2201005.Gás encanado	c8e2e011e66709ebe2137228300f4bb286806196b8806333035111988020c30f	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	2.17	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7484	2202.Energia elétrica residencial	cb822ff2c812ef7e0e745686f9beaa0c509933179879f4afac32369d4ff65220	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	2.17	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7485	2202003.Energia elétrica residencial	b9d03193411443394eceb330ddfc29b6ea2c96202ffdd1228d985e20d2370139	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-0.06	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7486	3.Artigos de residência	3e9410642b80aa7605a64e28a3927974819bb34e3e6e2fa16a8fee12d618c504	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-0.74	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7487	31.Móveis e utensílios	d520c8fbae8679a1df1f554a296854b5764bca23e0ab041ad4fe7df5313c9fdc	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-1.22	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7488	3101.Mobiliário	7a59fba143f524868816cf6c13387875d5f781d01f25735deed5b2cf21beccfe	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-0.44	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7489	3101002.Móvel para sala	ce6ebef3892cb4daf6f210eb26d2b725f0275c4fbc661e65bd5a3cdbaac27ea9	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-2.05	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7490	3101003.Móvel para quarto	02966d4173bc559c9f3a31c9fdeadb9883c93ff5a8510f5c117b01720904767d	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-0.93	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7492	3101015.Móvel para copa e cozinha	729b51f6d18267d702cfc23e2e5ae36b10f180fc4db75e8bab505ae5f3c3423e	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	12401	3101016.Móvel infantil	c2fe7358cbf9d4804c7c57f6201ea4bc6ce87f69ec802ef49a080f671a9ddd17	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7493	3101017.Colchão	1d66da9f10a2204cff9928efbfc659ce8691239d389c774b703c287f870c95ee	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-0.32	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7495	3102.Utensílios e enfeites	d1b725125101968d1fe6766294a7363582ac4e0e9fd94a049dd189262f75f19f	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-1.03	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	47638	3102001.Artigos de iluminação	5dc1077ca70fdee38a9717d19101c39f070f98e17298443f37f9e02e077b0e78	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-2.55	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7497	3102005.Tapete	fe9fc18263fa926f68bcb96b0c7e202523e4d377397832dd58fc152e4ef9f5f7	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-0.60	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7498	3102006.Cortina	cf36f8b8d211cf78d2bee8ada00d0886fb5b21a50d401a619ea3ea74e9040430	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	1.35	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	12402	3102007.Utensílios de metal	1327be635da63f053baad66348127b0387399291c5ad2e56b171bedbce6ba6c7	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	12403	3102009.Utensílios de vidro e louça	d6a5ef3adcde3715e098f31dd36dd65e7c18090f217700590cfb1ee633d7b8e2	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	107645	3102010.Utensílios de plástico	add217a125778fa8e4b987e32696ab1858d053d3405b1d55a3898a991c7e8ec2	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7508	3102035.Flores naturais	6845205173d028fdba1837f9ed244c4b38bd2009c9ff840396f74118e5e992d2	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	47639	3102337.Utensílios para bebê	29c5760008a94d918169c18e9f1e366479eb9c9abd060269a313ef163f203068	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	2.41	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7517	3103.Cama, mesa e banho	35def7d27e3417a0983d116379ce47cf529f8f99bd85158f28bf24dade3e5f42	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	2.41	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7518	3103001.Roupa de cama	0a30de7242624ff4e5cbea8dc875cbbf5a5b61db5861d2e626c865ac6fc4028e	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7520	3103003.Roupa de banho	b61aef2b8fc674a5b222d78c1c2c06209219e45c01b0c6766af986a042e94e95	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.50	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7521	32.Aparelhos eletroeletrônicos	4948a35618232df758205507dad91a336b1c942ebff5bf65632cda110a012b89	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-0.94	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7522	3201.Eletrodomésticos e equipamentos	c4b4356a4fb192a817a8820954e5ab5dab6841cf9a3f7fac995e01c5237f31fd	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-0.69	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7523	3201001.Refrigerador	8900e1a177a0c1a17d093aa7d9864ff5eb6cced5efcc5701ce05bea8b1de8465	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-2.76	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	12434	3201002.Ar-condicionado	34591cc98fee0940572687988a441b4edae3c25d2e2f3ef742aeb5e2c3662e61	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-0.48	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7526	3201006.Máquina de lavar roupa	7714ee1a688271906aeb74d0adbc4b2541667ec5f01cc68d5b4c4e2489c1bf37	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7530	3201013.Ventilador	c43641d6ff67b6a4c5e31b0cd7fec35f681d4e7ff3aa841cbb8853828141c22b	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-0.22	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7531	3201021.Fogão	de2413f09429e3a7de70a357ef4bef8430ffa91c674109a307b78dc54a436ec8	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7539	3201050.Chuveiro elétrico	a3fd00359616792e2c721ea7492199497687dcf3364bd1cefeee9a309de8121c	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	2.17	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7541	3202.Tv, som e informática	4a89933acdf605d67c9d8aaaba6306769b748deb7e0709c0ff3e312e76e0ff3e	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	1.93	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7542	3202001.Televisor	8a4955fa458382313a9eb1f6009c650aef7d6995563bc29617e7200b0121f35d	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7543	3202003.Aparelho de som	258554edb691cfa4af8cfa59e6d738d0c541bb4a2026b76522f13c547e03261d	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	47640	3202008.Videogame (console)	0be85daa664dc3c0e209c518aff980d1eb112bb35f1943aa62dbebde715e62ad	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	2.58	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	47641	3202028.Computador pessoal	38c532bcdc38109f41efc2ddd0e2a8e37338806f9fc7f28b885a7f1ad7c27dbe	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.44	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7548	33.Consertos e manutenção	ae85d4fe1366012f0380fb87782a1584c40a17a257da88c0e3afbe9876ccc27d	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.44	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7549	3301.Consertos e manutenção	d433ad49ed311fe97ad130ce1da562e39c856290b09cb0a87633db0f2f18be68	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	12405	3301002.Conserto de refrigerador	f2716f9299aa9aa3a9e04fe5237bf6b9900e198278174f6fa72ffb418cfc9a3e	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	107648	3301006.Conserto de televisor	f02f7c0642d8b601be97bb408b02dbf40025efedde0f4145603600637d186ab7	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	12406	3301015.Conserto de máquina de lavar roupa	9bafb3bc94500ba296f8ba38ffb793dbeda4cf8a00fc7ec44a8c6e39f7440ab1	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	2.37	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7555	3301022.Reforma de estofado	352af54ba5f7bee18ee54b1134bd9ae7d1f2641d5f4ed4236f705a11fde89b53	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	47642	3301088.Conserto de aparelho celular	49b4c4127d36922db613d4c9ed0a6811f389b51659aac42102c1b32df2f50587	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.08	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	47643	3301130.Conserto de bicicleta	5866adaa0cadc7d189b896ca716b808bbb495d96ef80c23efb5166fbd11418fb	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.26	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7558	4.Vestuário	be6940288fe3657a58dcc0e6ec6ad99b750f5c71a4523b5a9336a690d0e1071e	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-0.28	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7559	41.Roupas	6dd4034e77aebee950195547650a350a90e9aea32db6e947021b29cc9c71eee5	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.08	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7560	4101.Roupa masculina	ba0f6f8d37d4c739839afaae3df7aa8104dcfe0d6aec8236292038d1bb017553	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	2.53	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7561	4101002.Calça comprida masculina	d9912cf4af587a151d62b4a57b3a291b2fea08a326b4ddb3bae344f5a21ef832	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7563	4101005.Agasalho masculino	baf588de3e440d65bba842e8eb892d4188cad1cb6a516a052c34d0141ae50bb8	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-1.22	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	47644	4101006.Bermuda/short masculino	39cfb082ad47d73e0046acd4fb43bff27910ea10a6ae4c211bba7a159cb212c7	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7565	4101008.Cueca	97972b4843e7d3204f7fc6712958b8eaeeae5bf0d6afb7f6f5377f9530c6996a	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-0.21	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	107649	4101009.Camisa/camiseta masculina	d1b966949bd013ec8353366324eef100141fe7b270587ab0b5b6bd0b19e9d820	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-0.47	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7572	4102.Roupa feminina	2acce76e3513b5d0af4b637d36f0394c53e5238cb0cb40c6db4e7e5cdb105515	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	1.55	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7573	4102002.Calça comprida feminina	6a10164e1c4dfd727bc446494b59275ef101e3796fa8a3ac1463efdef47fa2aa	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7574	4102003.Agasalho feminino	0b6751cac25845b455a0e42ea637059b5bae6c7513f0d543c9f8dfa5d2b15ff6	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7575	4102004.Saia	68fb2154098a0f4ca7705a33ba27954eda11087659abc0e4b6a8b81e249083c3	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-3.28	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7576	4102005.Vestido	78a94304b703ffd8feb0d3368169e8ab027c5b8ec75b6364ba69b4d1dc214cbe	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-0.20	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7577	4102008.Blusa	7625893bc4fd56681b1db7fb223a4bae68a41dd8d2734491592fc295903c709b	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7579	4102010.Lingerie	8c0e9a45c487b07ac6dc45ba275f0715f818512b3673121c68c8ab5cb4d71a1d	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	2.21	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	47645	4102013.Bermuda/short feminino	e0937758c6d7777ee0673f893203065602ecdd56364d6324202b87eca5fb174c	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-0.62	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7587	4103.Roupa infantil	90a3142c9153389a0ff3022e1e32a8c2d9ab01b6d2848a2ac2b8ef3499c20d64	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	12408	4103001.Uniforme escolar	567d8299f53fcf53783b5393612899b6846ba4bbcca2cd37f9f05ab301c38f9c	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7589	4103002.Calça comprida infantil	01e12e60670995573bff60aa2b23fd411c2522a4cdd3da9aa0f9d87a62b1fad9	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7590	4103005.Agasalho infantil	c03a7c7f888b1b96cb6e426fccbd7d802e9c08922ed00aa41dd5af73381dde6a	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-3.02	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7591	4103007.Vestido infantil	61fecbbdecbcdb4eedfa8f26e17a80f69b910dc8622471f681e5a307b16eceb8	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-1.44	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	47646	4103008.Bermuda/short infantil	46459a5f14d066dc700b75a5f0a7c528cdc2cc6d602800cb74f732a58b13a4b5	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-1.01	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	107650	4103011.Camisa/camiseta infantil	68145a24c08f2a529a138d87b7500fb886559fa736e4f4ee4dabe192cfff9fe7	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	1.93	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	12409	4103031.Conjunto infantil	f9d8d60156ff4a931b747c650a4be41211a0fd8f1dcb0811786b58213f0330b7	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.96	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7604	42.Calçados e acessórios	3fa8c20cd95366719d67e7b588b89d043ec962b09c4006720f0114627178e3c2	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.96	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7605	4201.Calçados e acessórios	8848e09d8c0611d66443c33566b0ec491717e27e3f1d842e8994d02bcf96fc18	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.20	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7606	4201002.Sapato masculino	35027fed228f74f7a9222c9443993ba2bc77a885a7a5508d4750b12d200aef48	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	1.47	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7607	4201003.Sapato feminino	9a077440c2a650dadb3a7c74bcf3bc1796e55bc883b7afbd2263390f000878d0	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7608	4201004.Sapato infantil	865c00c9ecaa519e25d562830d1d1c62a1f77676fa8becca0d80894bb299bbf6	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-0.13	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	107652	4201015.Bolsa	a34b39ec2126e97ab4ebdc7023890d2c50654dffc3379c2dc4ac8dc9f5e2bb37	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	47647	4201040.Mochila	cfc46117b37cd5018cfe9a94e089d1d254cbb19c39ce595f41164a203eb9fe26	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	1.63	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7614	4201063.Tênis	0be7caef8014ee8b3c126313c7e069a686e22d9c44cb64f70b483b42b477c318	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-0.32	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	47648	4201098.Sandália/chinelo	3580086348c37b6cf26846228831093deb722552224a88ca6cce62cda9e8a52e	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	3.06	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7615	43.Joias e bijuterias	8c706877f1d26b456cde860205f786be7f251c6a7614c3cc733debf2c6367e93	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	3.06	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7616	4301.Joias e bijuterias	93cc25a583606d2991d629f5d5a99c46be10b2ffbdf8110905a56c0f36a74eb8	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7617	4301001.Bijuteria	64828a76b3a5c8bc25e9a08d7774edc38f769ddb90faac1fc740b0e4aedbad1e	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	3.86	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7618	4301002.Joia	42df965bbf748e2643b5b0e6aa4f1c8411bef790eead44425415d07d65593451	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.91	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7619	4301004.Relógio de pulso	c4281a68a76ce843547e112798a48919aa7e667d19fb0c9c4635e107cffac261	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.13	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7620	44.Tecidos e armarinho	50d8428e9c0034dbb2b84e4a0199aa35dabd08d8bb61c7192d33cc58f139e5ff	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.13	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7621	4401.Tecidos e armarinho	b54bfbb1cbe3d6bdbc148307b15d8d28ff7081985a09dd73a6ba6171a283f2e2	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.13	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7622	4401001.Tecido	bd99235c16bfd18960cd4ddefe313ad0aac3ef22e32017c34a0ed10025fabe31	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7623	4401002.Artigos de armarinho	aa4a6e03ecc2161edaf4d2489bc8d0e18963494286382f730355a16fc115de0a	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.77	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7625	5.Transportes	aa46f34298ede8cb7c56f98c5bdba7d06596ab671339e233b4d4297a1fe8f959	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.77	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7626	51.Transportes	1ef42fa69849cc8109c84965db06a2dcec5fc32a110a48b7d9929d145e34eaa0	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	1.89	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7627	5101.Transporte público	2d12f00db81352f1bfddd9d286017ec73369548acbbd79629495bc43697a02e6	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	1.01	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7628	5101001.Ônibus urbano	b171919664eeb1939fe352d164b5a1c5a891c2a24c5b0e15ccb1d3168e15f468	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.45	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7629	5101002.Táxi	1dbc9cfc4ade70eb1eee110717dd36af397016c58ff17316d29dbdc4153b4969	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.00	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7630	5101004.Trem	5749b67c30fbda6587837efbf9283c92dee24e909864cde226d91106c17405d5	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	7.06	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7631	5101006.Ônibus intermunicipal	af53e81e99ebf655d09005d489eb59151b55b1f4fb27e5049f95d04c7eee1af8	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-0.68	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7632	5101007.Ônibus interestadual	6f2e1d1d8aeec6a4920a7c0232109617981c02dabfd9c12934be23800f0c6771	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	4.62	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7634	5101010.Passagem aérea	f021a2fd130f4a0a21ae2a51bda677aa7acc902dd766399cec476872ed10033d	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.00	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7635	5101011.Metrô	5cef5b12bcb72b4446511bdc33f87983352eba14e6699abcae7e6843e46da8ff	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7639	5101026.Transporte escolar	faf82bbc5dd31daa940be0cca483f0035dd627f781d4da0a6c6ab91516c8122c	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	2.17	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	47649	5101051.Transporte por aplicativo	ba5c17391314ae2a8d41e5b819ed128a9138396a19d213fc595deb7f6d742164	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	47650	5101053.Integração transporte público	5cc4793a043138abecf3f556348979a0c8dd2ddb5b55b2189b742c5e09985e7e	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.50	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7640	5102.Veículo próprio	7ec7afd9d28580d0645e0ca8306755f650dc5e238bf9b43eee11168ba548153a	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.46	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7641	5102001.Automóvel novo	3d926021ef6e4b9f502e5b5199e7f0acc35ef92637c1b5dfa49605a8ff9a20e1	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.34	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7642	5102004.Emplacamento e licença	33bec06c5a218768e35f6fb756dabf868b46b86774571a05588c9a9f81cc3e91	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	3.32	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7643	5102005.Seguro voluntário de veículo	7d1bf672f64c626c80951fa870f46c3c7fd06b5323a37b285add04d9b2c837a2	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	107653	5102006.Multa	0e213e77ee74364077328b7cfb460886d6c2528a0ff7fb7e20a7c9fed78a28ff	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7644	5102007.Óleo lubrificante	41c95d04559a86452d697dd019999f64dadee51361d305d458da9f657eaa43e9	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-0.95	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7645	5102009.Acessórios e peças	44fedfc79b2d315cf5613c32e7daa9fc2a1e4b793de5aac13e0b5244e812373c	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	12411	5102010.Pneu	cd8741195f9c39c00d2424fff975b6b88eb47cb7af227671791b440310bc7b4b	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-0.40	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7647	5102011.Conserto de automóvel	1e395dc43af17b31f2a6ee5dfc5343bea12da80dda18474224f56b6dca22a158	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7648	5102013.Estacionamento	96ffd6aa2d52482758b58fa43c316d552a82aaab250c0fe0f76bfa9365271a7e	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7649	5102015.Pedágio	ad207dd4c01638d78103fa1eb1449e7240ea9dc56402194434a74d5b92d2252d	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-0.49	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	107654	5102020.Automóvel usado	92b697c963fa3ded3cfe8f004dcea59f21e1a4ea4b462c119032bb5a052aac08	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7653	5102037.Pintura de veículo	deef076e54539e035b061b81d3cc35095e0dfd4f2ad76976c20df1a180a9a402	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	5.41	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	107656	5102051.Aluguel de veículo	5f7c7c70ee5a16a5fa1c327bedfe3c7fad24672a0b6d456a552e53de2f7094c5	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.84	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7654	5102053.Motocicleta	86bb5b8080c05965b39579bcda0d1592eca8d0536d6ca3f1ba990e38dbd6544a	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.06	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7656	5104.Combustíveis (veículos)	dc64972288495ed035807d825c291f9f434b3d83611718ff701357d2def8785b	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.48	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7657	5104001.Gasolina	47a359eddd4b187e2e57a0a674b68d1678211d1118b24b114e6e92332f47c1d7	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	2.87	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7658	5104002.Etanol	72b4d0d4a6b607b060a0104aa73543dbf0358468f3a40f05a0147db5eada677c	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.23	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7659	5104003.Óleo diesel	42da3efd2868e32e3cf9905c35438491203d6e34bb39282b729c26f7134a322f	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-3.26	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	107657	5104005.Gás veicular	1164939a230122b16fa7b7d54fc66b2ee5eec01d9089d28b24d24541c908cf15	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.72	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7660	6.Saúde e cuidados pessoais	df4adf8087444c83e2581736072087895e06500c9a1816fc269b617122fc22d9	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.22	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7661	61.Produtos farmacêuticos e óticos	21b259403d8e36ef891dd71ac658cd4633500d940a962020285e9a4db0e3026d	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.25	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7662	6101.Produtos farmacêuticos	06381084499869dd9eca1b0ebddd7a4778e7988f0f7c62ab91931d2ea6b4c4f8	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-0.29	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7663	6101001.Anti-infeccioso e antibiótico	f4a96cefa35b4bc22b6ec66adf94410ab1fd0ec6a35c55c1ab250f75b1d82230	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.77	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7664	6101002.Analgésico e antitérmico	d3ee0ebd3e3315b083ffe99054cf1ba7cb77c4cb0ee936c219229fb924eb9fec	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.76	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7665	6101003.Anti-inflamatório e antirreumático	e730c1356b4c3cc063d80a10c13f99384e50b8feb9ebf9d96a809e8781916260	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.56	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7666	6101004.Antigripal e antitussígeno	df7ef755876869ebad13466a49387633b639700bb368d07bcdff25cc2209e9d3	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	2.20	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	12412	6101006.Dermatológico	f8661185e9946fcc243d2f388ce0602f1dee63901d8a4608841f141f184832d3	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.19	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7669	6101007.Antialérgico e broncodilatador	c82d16de8e7966288cad8aace00835fd68d2de75b2d0418f1a81aa26c2eecd8a	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.56	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7670	6101009.Gastroprotetor	2fed41447f90d2ca7acf320fbffdc3295128870c252fc12bc6ed3f031ef1e332	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.49	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7671	6101010.Vitamina e fortificante	025f7e33feee65ef7392e03f68a495525bd20aa5cd57dae8ab9c0f014e243c49	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	2.04	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	47651	6101011.Hormonal	9a4609802ac56e82914757c3ac5d0045a05d971c2c875b9f954cbc5e94627430	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	2.05	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7673	6101013.Psicotrópico e anorexígeno	e2e8b923d9403ffb98084f35f582467ebeacbb75e15c0ef69d80ce9415757fca	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-0.73	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7674	6101014.Hipotensor e hipocolesterolêmico	59e23c92565c051ae4722f7b7b155cbbee36b08e406adab802c3a9e8b87f6f38	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	1.52	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	107659	6101051.Oftalmológico	643d81f56bb1902f72cfc29f9f309576bc049ad104607f8fa0b2783eb747d65f	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-2.59	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7677	6101064.Antidiabético	dedd0597aa9ad1701a148303203b8f1f6292789216934ea50918673025712210	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-0.12	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	47652	6101148.Neurológico	da0a8a4be6d50ab2731828905f5fb229f5a09b38be7540238ab69fee663df9f3	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-0.61	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	109464	6102.Produtos óticos	7f3486041f4f3c9a789ed4332f67ca8318ae91973d9b3ee2ea84125aa2ac9244	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-0.61	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	47653	6102012.Óculos de grau	3e23ed2c9509575b1746a0e7ece85592551bfa0dac58f087a0604a5852c97f28	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.41	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7683	62.Serviços de saúde	4856b7b5c937c8b5b40f6d4f603b517363e6a196eb52034f27cd36016fe8622a	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-0.13	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7684	6201.Serviços médicos e dentários	121f726f35c136bff2d263f257f86c9cd66f7e29a8bfb882ea3d9e76075e39c7	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.24	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7685	6201002.Médico	a2af7ba106700645c5c5dc343297053a41542dafccb9ee51c86617f390f5a639	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.00	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7686	6201003.Dentista	a599efe571b78eb1cd5bddef66689488a0bc3d1460562c12175b5d42fca9f526	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	12414	6201005.Aparelho ortodôntico	72d8f980a6cedb58bb85626434c1b69caab1ee17d6dda283324bee0e9d5e0e4e	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	12435	6201007.Fisioterapeuta	649bdf211a544a0084b47f6920534915fd78add6a6ff11ce3f31470005ae23d5	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-2.50	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	12436	6201010.Psicólogo	1da993ef931b7033e67e0a5fe1903dea29d68e0b7a89903878c8a87f12f82aed	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.26	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7690	6202.Serviços laboratoriais e hospitalares	df6ea071ae31a04df2192d02c220a34636107e74e701386b7775570672eb9f5e	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	1.26	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7691	6202003.Exame de laboratório	eda53b6af31a29da90af0175f26bb8a1c7db6c8e13895316a4555d097a39fc71	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.00	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7692	6202004.Hospitalização e cirurgia	6b9d6e5169bb5e71efe9460a3734aff97ac79aa57ec12fb2ac85f9673390c104	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.75	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	12416	6202006.Exame de imagem	bdcf7d1d94e40f9ee097fd243231c972c43b81322739e0e9e3e87408b8963564	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.53	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7695	6203.Plano de saúde	4013b96279da9d36a1180a57bfd07169e07c7a0f89fcc32f1358184426207a5b	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.53	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7696	6203001.Plano de saúde	4a8dd3a98ae942d3ba50014804b9f29403fd0f04ba0746c257debbbcd38e41c7	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	2.09	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7697	63.Cuidados pessoais	969659a3a8e23455dbb2a010bc7bbc3c7a4ab8356886df8be1db8c657fe05f3e	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	2.09	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7698	6301.Higiene pessoal	636b25554a59cbcdd02b1947b08d8ed55320d292911da28f9783efdabdc0f26f	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	2.29	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7699	6301001.Produto para cabelo	4a71a464bdf730e8a81cad7f52bc11443930063742f843165889440ed562d549	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.55	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	12420	6301002.Fralda descartável	e6a2cc0ba99f82d1f1ac19258bae49eb6660732deffe3991964708828590426c	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	2.40	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	101642	6301004.Produto para barba	21d81ba77e34dbba293b20e8b23a5a52d47902a8a3a805be8a2818dfc737737d	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	3.27	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	101644	6301006.Produto para pele	9fe511c43fa2ee77e7b0a0a3f834288d736bd5a1df5aed54b01c578fa053afd9	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.97	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	107661	6301007.Produto para higiene bucal	08d5545f75c9cc828d5905122bc54b6042b3e7dee4624cd353170ced293c7b8e	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7703	6301010.Produto para unha	813f5d077302a120fea433df6b783151d7c765c89ec0c98dff00a045dc2b590e	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	3.51	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7704	6301011.Perfume	fdc85e6998b0ab98c88143a85f3db79f5740af29dc064205989423982f3c5716	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	1.62	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7707	6301014.Desodorante	bdde14a81e29bfc53c1a9e035efb0d872cf84c17238578b04e7899defeef25a7	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	2.32	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7708	6301015.Absorvente higiênico	d1952360143485997bff1d6bf6468dcf34081b837b21c669ded7d7f2af4669b0	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	1.89	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7709	6301016.Sabonete	89a65adc050519dddf504757fcc8a9c2bd78c973a8a059132098c3269ffce442	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	1.51	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7710	6301017.Papel higiênico	cf58b6ff9417c21ade2080ee0a1861a5f0a089ea60036964c7907e9a981767b2	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-2.74	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7711	6301020.Artigos de maquiagem	083ca5342f31d200036b0944f3b3dcf97d86dcad2834311de2a202498bc93eb8	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.79	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7712	7.Despesas pessoais	1476316c96416496e2ad86c3c40320d85c196ff63037074a84db1455e400f2c9	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.61	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7713	71.Serviços pessoais	3fbdc975946adc3989ca8141a2dfd56e2aa85e4bbfa471fecdeed11e407b1a60	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.61	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7714	7101.Serviços pessoais	7a4fad446ca813a4cf334e7e228eef196e5eadd71a1bf349dc9461a5b944246c	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7715	7101001.Costureira	e256637924c98d18f12265268dbc861b48382529bbd3c4aa79f123abc35c41b4	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	1.28	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	12421	7101005.Manicure	66d9e7b6d5d586821d29447a0b72c79fef5ac456d07de14798aa47021cc1e7d7	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.52	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7720	7101010.Empregado doméstico	f1979af96eaa294834297c6da6a6bc73cb60fd9cc4e1f511baaedef668cb7ed0	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.17	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	47654	7101011.Cabeleireiro e barbeiro	fa30026b8570ad0e84bccf5159b79bce99429155f9f9f923e7aeb27be59e450a	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7721	7101014.Depilação	b36f35b7fcb810761f625fca7b27d583d51d09e5827bd87f1f635c8054d6bf4a	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7723	7101034.Cartório	0a715d3020da3e9090c1a8ac3ff1d0681d15e7ba178856539dae0de2471918e2	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7724	7101036.Despachante	782be80bca410c32612151ddcaf8c984bd8b51d93e7a19597ed63d7742601666	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	1.06	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7727	7101076.Serviço bancário	fe226292d766fee8c7906d38a24271b0de0b87686336b5b30fc1922068afa9ef	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7728	7101090.Conselho de classe	eb010d4fcb73457b5da0e06b3467c03f400c1a7e4998685379577b10cbdab8a6	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-1.06	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	47655	7101144.Sobrancelha	a42e1654b13693148617b5f40c24d21ecd40a4eb8e5efab40bec788fd249ca79	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	1.08	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	47656	72.Recreação e fumo	b78fd654ebfdd57107c19877bc79391872063d17450a80b3bf0d08ce84fd1fef	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.71	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7730	7201.Recreação	bba5d2222a19ca7b67bcfdd3113fb6c86eb185cab31c2cdd89f9c976505fa618	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7733	7201006.Clube	45d4d7bbd58210af019fcfd11b550318006d0e29cf818eecd42a537c78beb167	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7735	7201010.Instrumento musical	1df62accb3a222e5ebdea64eaf88bcd876d8303bf085482beb11bc065c25e33e	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.64	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	47657	7201015.Tratamento de animais (clínica)	4e8ba79f7a2f81aac000e07c28f43a942d9ce527aa4abfc6f80bd25fe2585085	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7736	7201019.Bicicleta	c71f1d14dcf7734e60faf69de6886102fb7e33284e07132c5560022eae6c5d58	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-0.74	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	107666	7201020.Alimento para animais	14425f002e2bf694b5ba6fe99ae771a1bb0c4bd653139b7b17d8bf4c6555c933	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	2.29	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7738	7201023.Brinquedo	30afa17ded6e47ef8238acecce07ebfd07514132c738d76d9a0db4e51685162c	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	1.23	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	47658	7201054.Casa noturna	6af5f4b48e40364f7dcdf702ab38e54effdbd2265e95b0b3b6a8954619f2d4f2	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.00	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	107668	7201063.Jogos de azar	20fe45faa7d57a5f085ebdda5b32118f927971c8ccf297a0ca35d520c49e7706	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7746	7201067.Material de caça e pesca	15c1a1fe3d0e2d0d833c63226efe258972c4aa70218ca2224ba116f4628617f1	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	5.54	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	47659	7201090.Hospedagem	1a9ccd280545b245a2e6d7897b68af89d5418e8fa7c7783930316784840b624c	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-2.87	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	47660	7201095.Pacote turístico	73356c213eb5a4241b6b25f6d9eba5de2fe69df20f87dab4e8a5586c27240707	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	2.24	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	47661	7201256.Serviço de higiene para animais	dc246b054ac7c58278687288852de1fb6304112b5fe13114a6acdf81f7aa1ef4	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-1.29	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	47662	7201266.Cinema, teatro e concertos	444cc5fbebc5f3cdf67921300f43f5768105e10b7c3df34a883b3f70f4ede818	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	2.73	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7758	7202.Fumo	afa805b86a52f644ef69f8c36acd718c21721257d73874f15cab4a1d99eda51c	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	2.73	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7759	7202041.Cigarro	24f708736ee4470d768569d2c99e0dec460d54e04b1a7930c080d3e77e88d117	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	4.89	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7766	8.Educação	9284c8543448e63678945a20bde9b3b0c11a393f4008b8d0acdd06ee6c6bb907	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	4.89	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7767	81.Cursos, leitura e papelaria	153632c7eb42acf29cf8dcb23893cac4b69e60c395c075b39ca3d0c41524c75c	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	6.03	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	12427	8101.Cursos regulares	6710b54ec02b0df74bbe5de37002581680092466c306fc90befa2cd8ac90d3f7	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	5.63	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7769	8101001.Creche	1ec93ae6efb5c8442efc5eaeb71feaeeb32679e05c7c4b10d2c461bb20ebe96c	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	5.81	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	47663	8101002.Pré-escola	141cbbf0f4cd67e9327d2b1f75acde7b3b402bd9f711ac73983f52e9ae1650d7	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	7.28	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	107671	8101003.Ensino fundamental	75122701300a6a93dd42d610dd06ea1e705c6cf49265fc05bdbbe30873aa9002	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	7.16	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	107672	8101004.Ensino médio	e47e378567c4c7ac13cb67d5268744e5c5a9a8c5e93e300bf2a81a1c95aa6f13	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	4.46	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	107673	8101005.Ensino superior	ee106f0f6f171eebd1d47309a14cc1ff0cd7c97bfe732e6248b867dafb6b3070	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	2.66	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	107674	8101006.Pós-graduação	a0d9a495c402d6a4e18b4d50a879963188b13b4cdc85a9a8d0f14047196f9a63	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	1.32	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	47664	8101008.Educação de jovens e adultos	87e61dea835cddb68f506253ee1c7cf5c05c97afae4741039215d41f52b1f048	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	47665	8101045.Curso técnico	bad2eb3c580efe911e48ce3f45aaac2768a67639a65088deb9d3879187014a97	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	1.37	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7777	8102.Leitura	0026a5025ddb1d1654bbc311bb30cb74c8d2f2f5522fa2f0371fcc470c3e28d9	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	2.07	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7778	8102001.Jornal diário	57ff356093f4c40dd45a360d7a8bf802778892ec67a20a1d49bb5d35aa95b08e	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	107676	8102004.Revista	a9c002030d4bd21779e0b63e5db3363fa7f52da0fd38bc1fe2c03e8212875910	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	1.04	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	47666	8102007.Livro didático	36d4b56e2d08441f3fe78315a47020a27c00d239be65afae6b3ffd84be10c2c9	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	1.63	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	47667	8102008.Livro não didático	179620109933f2a651b8a02bc895dce58dbd1c89b98d5045437643e994781b7a	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-1.64	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7782	8103.Papelaria	9dd268a98c502d4cd29e157599c6b624fa19508f771c15a84e5cc4e4c0dcd01e	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-1.35	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7783	8103001.Caderno	eca4b7ff458a0e34f9199b166d4d208c0a17b8a3317d8f02221e9ce677868192	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	-1.77	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7785	8103014.Artigos de papelaria	5d3031e7f22b2a7ff61698fc5a81cd3aabf3df09b9dd6c71e8be0618eaa2c9c5	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	2.37	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	107678	8104.Cursos diversos	7d1140220c33e5686e6c0fa9f2994f5c60af37ed34ccda7de580289728fbf7a1	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	2.11	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	107679	8104001.Curso preparatório	a9a8d6c2744211cb441d123913b53fbda334932009747582074b338ae1d71c63	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	3.08	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	107681	8104003.Curso de idioma	64d3c7c5fa4da767553f53bf96178f7668f8ca2755ae432c378dc65ffda4ca4e	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	107682	8104004.Curso de informática	fa0eb3e51e5a7dfdea9598335083f5d47eee8ede46a403b26c8303a15209471f	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	107683	8104005.Autoescola	f3e1f728dee0749a5f7d2265a6d82f20d23b6f3fa0c5b1688a46ee4f4d5ffd95	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	1.95	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	12428	8104006.Atividades físicas	1da987c19f87580fbc63de1ff1ee8e6a07a4f1f5c3fe223b3ffad1fbf5052e2d	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.20	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7786	9.Comunicação	4f8d887d61282a79d2133d52241e0a54f7befd2a8022bd93d89b277cf5daadcd	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.20	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7787	91.Comunicação	013d2b3f986131abb621b9af6725d18afe3a5e275d54870375c60eb64850bc15	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.20	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7788	9101.Comunicação	5a806df289377297741599b88c557638b8c36b627858f6936a9387bea947ae81	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7789	9101001.Correio	95d7e3e337151bd8d90c0ce62abe999aee05c5664d5b0eea386107c4bd5ad075	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.00	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	47668	9101002.Plano de telefonia fixa	36651dfc764ce12c30176380b7e44efd170ff3a56afbe7164b42012ad5f6a827	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.00	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	47669	9101008.Plano de telefonia móvel	8938f827b6fad8d02b905ebca71a27d1d1f4c84dddbf1ebed85cf93e8b2af094	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.00	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	47670	9101010.Tv por assinatura	caa4daff0b5d4971ec681da2b0d56131f7755b601041daa0102cb7ba1142d214	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.00	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	107688	9101018.Acesso à internet	cda56f337722ae4340cd793ae2c0567abbb5f02ec661e0ffdc0e23c46bfae8fc	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	1.21	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	7794	9101019.Aparelho telefônico	d70bd7bbc1e7408e9a1835b154003eac45b13d1caf43d36aebc0ded9bb00d5f1	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	\N	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	47671	9101115.Serviços de streaming	8cabf35e00a5d5ad6170e9d28b0a26ef0526efde0963483f1d67c2dd12ecfb90	2026-03-13 18:45:34.375355
71	Categoria Metropolitana	2	%	0.00	4801	RM do Rio de Janeiro (RJ)	63	IPCA - Variação mensal	202602	fevereiro 2026	47672	9101116.Combo de telefonia, internet e tv por assinatura	3ca58e5f01a62d4a2111878b454304cb613a54cdf9750ff38ccdc5f3cadce835	2026-03-13 18:45:34.375355
\.


--
-- Name: categories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.categories_id_seq', 42, true);


--
-- Name: categories categories_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_name_key UNIQUE (name);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: idx_categories_display_order; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_categories_display_order ON public.categories USING btree (display_order);


--
-- Name: idx_categories_is_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_categories_is_active ON public.categories USING btree (is_active);


--
-- Name: ipca_rowhash_uidx; Type: INDEX; Schema: public; Owner: budget_user
--

CREATE UNIQUE INDEX ipca_rowhash_uidx ON public.ipca USING btree (sidra_row_hash);


--
-- Name: TABLE categories; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.categories TO budget_user;


--
-- Name: SEQUENCE categories_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.categories_id_seq TO budget_user;


--
-- PostgreSQL database dump complete
--

\unrestrict j83iiJ2rWcZEGSuCRxCc42pWWAYEQ8ze395iozvIkxxk2DxUjHek1J3JPJi3kD4

