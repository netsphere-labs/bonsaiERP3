SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: common; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA common;


--
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

-- *not* creating schema, since initdb creates it


--
-- Name: hstore; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS hstore WITH SCHEMA public;


--
-- Name: EXTENSION hstore; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION hstore IS 'data type for storing sets of (key, value) pairs';


--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: array_intersection(anyarray, anyarray); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.array_intersection(anyarray, anyarray) RETURNS anyarray
    LANGUAGE sql
    AS $_$
SELECT ARRAY(
    SELECT $1[i]
    FROM generate_series( array_lower($1, 1), array_upper($1, 1) ) i
    WHERE ARRAY[$1[i]] && $2
);
$_$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: links; Type: TABLE; Schema: common; Owner: -
--

CREATE TABLE common.links (
    id bigint NOT NULL,
    organisation_id integer,
    user_id integer,
    settings character varying,
    creator boolean DEFAULT false,
    master_account boolean DEFAULT false,
    role character varying(50),
    active boolean DEFAULT true,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    tenant character varying(100),
    api_token character varying
);


--
-- Name: links_id_seq; Type: SEQUENCE; Schema: common; Owner: -
--

CREATE SEQUENCE common.links_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: links_id_seq; Type: SEQUENCE OWNED BY; Schema: common; Owner: -
--

ALTER SEQUENCE common.links_id_seq OWNED BY common.links.id;


--
-- Name: organisations; Type: TABLE; Schema: common; Owner: -
--

CREATE TABLE common.organisations (
    id bigint NOT NULL,
    country_id integer,
    name character varying(100),
    address character varying,
    address_alt character varying,
    phone character varying(40),
    phone_alt character varying(40),
    mobile character varying(40),
    email character varying,
    website character varying,
    user_id integer,
    due_date date,
    preferences text,
    time_zone character varying(100),
    tenant character varying(50),
    currency character varying(10),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    country_code character varying(5),
    inventory_active boolean DEFAULT true,
    settings jsonb,
    due_on date,
    plan character varying DEFAULT '2users'::character varying
);


--
-- Name: organisations_id_seq; Type: SEQUENCE; Schema: common; Owner: -
--

CREATE SEQUENCE common.organisations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: organisations_id_seq; Type: SEQUENCE OWNED BY; Schema: common; Owner: -
--

ALTER SEQUENCE common.organisations_id_seq OWNED BY common.organisations.id;


--
-- Name: users; Type: TABLE; Schema: common; Owner: -
--

CREATE TABLE common.users (
    id bigint NOT NULL,
    email character varying NOT NULL,
    first_name character varying(80),
    last_name character varying(80),
    phone character varying(40),
    mobile character varying(40),
    website character varying(200),
    description character varying(255),
    encrypted_password character varying,
    password_salt character varying,
    confirmation_token character varying(60),
    confirmation_sent_at timestamp without time zone,
    confirmed_at timestamp without time zone,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    reseted_password_at timestamp without time zone,
    sign_in_count integer DEFAULT 0,
    last_sign_in_at timestamp without time zone,
    change_default_password boolean DEFAULT false,
    address character varying,
    active boolean DEFAULT true,
    auth_token character varying,
    rol character varying(50),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    old_emails text[] DEFAULT '{}'::text[],
    locale character varying DEFAULT 'en'::character varying
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: common; Owner: -
--

CREATE SEQUENCE common.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: common; Owner: -
--

ALTER SEQUENCE common.users_id_seq OWNED BY common.users.id;


--
-- Name: account_ledgers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.account_ledgers (
    id bigint NOT NULL,
    reference text,
    currency character varying,
    account_id integer,
    account_balance numeric(14,2) DEFAULT 0.0,
    account_to_id integer,
    account_to_balance numeric(14,2) DEFAULT 0.0,
    date date,
    operation character varying(20),
    amount numeric(14,2) DEFAULT 0.0,
    exchange_rate numeric(14,4) DEFAULT 1.0,
    creator_id integer,
    approver_id integer,
    approver_datetime timestamp without time zone,
    nuller_id integer,
    nuller_datetime timestamp without time zone,
    inverse boolean DEFAULT false,
    has_error boolean DEFAULT false,
    error_messages character varying,
    status character varying(50) DEFAULT 'approved'::character varying,
    project_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    updater_id integer,
    name character varying,
    contact_id integer
);


--
-- Name: account_ledgers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.account_ledgers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: account_ledgers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.account_ledgers_id_seq OWNED BY public.account_ledgers.id;


--
-- Name: accounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.accounts (
    id bigint NOT NULL,
    name character varying,
    currency character varying(10),
    exchange_rate numeric(14,4) DEFAULT 1.0,
    amount numeric(14,2) DEFAULT 0.0,
    type character varying(30),
    contact_id integer,
    project_id integer,
    active boolean DEFAULT true,
    description text,
    date date,
    state character varying(30),
    has_error boolean DEFAULT false,
    error_messages character varying(400),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    tag_ids integer[] DEFAULT '{}'::integer[],
    updater_id integer,
    tax_percentage numeric(5,2) DEFAULT 0.0,
    tax_id integer,
    total numeric(14,2) DEFAULT 0.0,
    tax_in_out boolean DEFAULT false,
    extras jsonb,
    creator_id integer,
    approver_id integer,
    nuller_id integer,
    due_date date
);


--
-- Name: accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.accounts_id_seq OWNED BY public.accounts.id;


--
-- Name: active_storage_attachments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_attachments (
    id bigint NOT NULL,
    name character varying NOT NULL,
    record_type character varying NOT NULL,
    record_id bigint NOT NULL,
    blob_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_attachments_id_seq OWNED BY public.active_storage_attachments.id;


--
-- Name: active_storage_blobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_blobs (
    id bigint NOT NULL,
    key character varying NOT NULL,
    filename character varying NOT NULL,
    content_type character varying,
    metadata text,
    byte_size bigint NOT NULL,
    checksum character varying NOT NULL,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_blobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_blobs_id_seq OWNED BY public.active_storage_blobs.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: attachments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.attachments (
    id bigint NOT NULL,
    attachment_uid character varying,
    name character varying,
    attachable_id integer,
    attachable_type character varying,
    user_id integer,
    "position" integer DEFAULT 0,
    image boolean DEFAULT false,
    size integer,
    image_attributes json,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    publish boolean DEFAULT false
);


--
-- Name: attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.attachments_id_seq OWNED BY public.attachments.id;


--
-- Name: contacts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.contacts (
    id bigint NOT NULL,
    matchcode character varying,
    first_name character varying(100),
    last_name character varying(100),
    organisation_name character varying(100),
    address character varying(250),
    phone character varying(40),
    mobile character varying(40),
    email character varying(200),
    tax_number character varying(30),
    aditional_info character varying(250),
    code character varying,
    type character varying,
    "position" character varying,
    active boolean DEFAULT true,
    staff boolean DEFAULT false,
    client boolean DEFAULT false,
    supplier boolean DEFAULT false,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    incomes_status character varying(300) DEFAULT '{}'::character varying,
    expenses_status character varying(300) DEFAULT '{}'::character varying,
    tag_ids integer[] DEFAULT '{}'::integer[]
);


--
-- Name: contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.contacts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.contacts_id_seq OWNED BY public.contacts.id;


--
-- Name: histories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.histories (
    id bigint NOT NULL,
    user_id integer,
    historiable_id integer,
    new_item boolean DEFAULT false,
    historiable_type character varying,
    history_data json DEFAULT '{}'::json,
    created_at timestamp without time zone,
    klass_type character varying,
    extras public.hstore,
    all_data json DEFAULT '{}'::json
);


--
-- Name: histories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.histories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: histories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.histories_id_seq OWNED BY public.histories.id;


--
-- Name: inventories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.inventories (
    id bigint NOT NULL,
    contact_id integer,
    store_id integer,
    account_id integer,
    date date,
    ref_number character varying,
    operation character varying(10),
    description character varying,
    total numeric(14,2) DEFAULT 0.0,
    creator_id integer,
    transference_id integer,
    store_to_id integer,
    project_id integer,
    has_error boolean DEFAULT false,
    error_messages character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    updater_id integer
);


--
-- Name: inventories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.inventories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: inventories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.inventories_id_seq OWNED BY public.inventories.id;


--
-- Name: inventory_details; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.inventory_details (
    id bigint NOT NULL,
    inventory_id integer,
    item_id integer,
    store_id integer,
    quantity numeric(14,2) DEFAULT 0.0,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: inventory_details_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.inventory_details_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: inventory_details_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.inventory_details_id_seq OWNED BY public.inventory_details.id;


--
-- Name: items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.items (
    id bigint NOT NULL,
    unit_id integer,
    price numeric(14,2) DEFAULT 0.0,
    name character varying(255),
    description character varying,
    code character varying(100),
    for_sale boolean DEFAULT true,
    stockable boolean DEFAULT true,
    active boolean DEFAULT true,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    buy_price numeric(14,2) DEFAULT 0.0,
    unit_symbol character varying(20),
    unit_name character varying(255),
    tag_ids integer[] DEFAULT '{}'::integer[],
    updater_id integer,
    creator_id integer
);


--
-- Name: items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.items_id_seq OWNED BY public.items.id;


--
-- Name: links; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.links (
    id bigint NOT NULL,
    organisation_id integer,
    user_id integer,
    settings character varying,
    creator boolean DEFAULT false,
    master_account boolean DEFAULT false,
    role character varying(50),
    active boolean DEFAULT true,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    tenant character varying(100),
    api_token character varying
);


--
-- Name: links_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.links_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: links_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.links_id_seq OWNED BY public.links.id;


--
-- Name: movement_details; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.movement_details (
    id bigint NOT NULL,
    account_id integer,
    item_id integer,
    quantity numeric(14,2) DEFAULT 0.0,
    price numeric(14,2) DEFAULT 0.0,
    description character varying,
    discount numeric(14,2) DEFAULT 0.0,
    balance numeric(14,2) DEFAULT 0.0,
    original_price numeric(14,2) DEFAULT 0.0,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: movement_details_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.movement_details_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: movement_details_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.movement_details_id_seq OWNED BY public.movement_details.id;


--
-- Name: organisations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organisations (
    id bigint NOT NULL,
    country_id integer,
    name character varying(100),
    address character varying,
    address_alt character varying,
    phone character varying(40),
    phone_alt character varying(40),
    mobile character varying(40),
    email character varying,
    website character varying,
    user_id integer,
    due_date date,
    preferences text,
    time_zone character varying(100),
    tenant character varying(50),
    currency character varying(10),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    country_code character varying(5),
    settings public.hstore DEFAULT '"inventory"=>"true"'::public.hstore
);


--
-- Name: organisations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.organisations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: organisations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.organisations_id_seq OWNED BY public.organisations.id;


--
-- Name: projects; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.projects (
    id bigint NOT NULL,
    name character varying,
    active boolean DEFAULT true,
    date_start date,
    date_end date,
    description text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: projects_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.projects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: projects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.projects_id_seq OWNED BY public.projects.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: stocks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stocks (
    id bigint NOT NULL,
    store_id integer,
    item_id integer,
    unitary_cost numeric(14,2) DEFAULT 0.0,
    quantity numeric(14,2) DEFAULT 0.0,
    minimum numeric(14,2) DEFAULT 0.0,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    active boolean DEFAULT true
);


--
-- Name: stocks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.stocks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stocks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.stocks_id_seq OWNED BY public.stocks.id;


--
-- Name: stores; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stores (
    id bigint NOT NULL,
    name character varying,
    address character varying,
    phone character varying(40),
    active boolean DEFAULT true,
    description character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: stores_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.stores_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stores_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.stores_id_seq OWNED BY public.stores.id;


--
-- Name: tag_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tag_groups (
    id bigint NOT NULL,
    name character varying,
    bgcolor character varying,
    tag_ids integer[] DEFAULT '{}'::integer[],
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: tag_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tag_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tag_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tag_groups_id_seq OWNED BY public.tag_groups.id;


--
-- Name: tags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tags (
    id bigint NOT NULL,
    name character varying,
    bgcolor character varying(10),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tags_id_seq OWNED BY public.tags.id;


--
-- Name: taxes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.taxes (
    id bigint NOT NULL,
    name character varying(100),
    abreviation character varying(20),
    percentage numeric(5,2) DEFAULT 0.0,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: taxes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.taxes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: taxes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.taxes_id_seq OWNED BY public.taxes.id;


--
-- Name: units; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.units (
    id bigint NOT NULL,
    name character varying(100),
    symbol character varying(20),
    "integer" boolean DEFAULT false,
    visible boolean DEFAULT true,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: units_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.units_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: units_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.units_id_seq OWNED BY public.units.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    email character varying NOT NULL,
    first_name character varying(80),
    last_name character varying(80),
    phone character varying(40),
    mobile character varying(40),
    website character varying(200),
    description character varying(255),
    encrypted_password character varying,
    password_salt character varying,
    confirmation_token character varying(60),
    confirmation_sent_at timestamp without time zone,
    confirmed_at timestamp without time zone,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    reseted_password_at timestamp without time zone,
    sign_in_count integer DEFAULT 0,
    last_sign_in_at timestamp without time zone,
    change_default_password boolean DEFAULT false,
    address character varying,
    active boolean DEFAULT true,
    auth_token character varying,
    rol character varying(50),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    old_emails text[] DEFAULT '{}'::text[],
    locale character varying DEFAULT 'en'::character varying
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: links id; Type: DEFAULT; Schema: common; Owner: -
--

ALTER TABLE ONLY common.links ALTER COLUMN id SET DEFAULT nextval('common.links_id_seq'::regclass);


--
-- Name: organisations id; Type: DEFAULT; Schema: common; Owner: -
--

ALTER TABLE ONLY common.organisations ALTER COLUMN id SET DEFAULT nextval('common.organisations_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: common; Owner: -
--

ALTER TABLE ONLY common.users ALTER COLUMN id SET DEFAULT nextval('common.users_id_seq'::regclass);


--
-- Name: account_ledgers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_ledgers ALTER COLUMN id SET DEFAULT nextval('public.account_ledgers_id_seq'::regclass);


--
-- Name: accounts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accounts ALTER COLUMN id SET DEFAULT nextval('public.accounts_id_seq'::regclass);


--
-- Name: active_storage_attachments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments ALTER COLUMN id SET DEFAULT nextval('public.active_storage_attachments_id_seq'::regclass);


--
-- Name: active_storage_blobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_blobs ALTER COLUMN id SET DEFAULT nextval('public.active_storage_blobs_id_seq'::regclass);


--
-- Name: attachments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attachments ALTER COLUMN id SET DEFAULT nextval('public.attachments_id_seq'::regclass);


--
-- Name: contacts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contacts ALTER COLUMN id SET DEFAULT nextval('public.contacts_id_seq'::regclass);


--
-- Name: histories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.histories ALTER COLUMN id SET DEFAULT nextval('public.histories_id_seq'::regclass);


--
-- Name: inventories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventories ALTER COLUMN id SET DEFAULT nextval('public.inventories_id_seq'::regclass);


--
-- Name: inventory_details id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_details ALTER COLUMN id SET DEFAULT nextval('public.inventory_details_id_seq'::regclass);


--
-- Name: items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.items ALTER COLUMN id SET DEFAULT nextval('public.items_id_seq'::regclass);


--
-- Name: links id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.links ALTER COLUMN id SET DEFAULT nextval('public.links_id_seq'::regclass);


--
-- Name: movement_details id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.movement_details ALTER COLUMN id SET DEFAULT nextval('public.movement_details_id_seq'::regclass);


--
-- Name: organisations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organisations ALTER COLUMN id SET DEFAULT nextval('public.organisations_id_seq'::regclass);


--
-- Name: projects id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects ALTER COLUMN id SET DEFAULT nextval('public.projects_id_seq'::regclass);


--
-- Name: stocks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stocks ALTER COLUMN id SET DEFAULT nextval('public.stocks_id_seq'::regclass);


--
-- Name: stores id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stores ALTER COLUMN id SET DEFAULT nextval('public.stores_id_seq'::regclass);


--
-- Name: tag_groups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tag_groups ALTER COLUMN id SET DEFAULT nextval('public.tag_groups_id_seq'::regclass);


--
-- Name: tags id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tags ALTER COLUMN id SET DEFAULT nextval('public.tags_id_seq'::regclass);


--
-- Name: taxes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.taxes ALTER COLUMN id SET DEFAULT nextval('public.taxes_id_seq'::regclass);


--
-- Name: units id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units ALTER COLUMN id SET DEFAULT nextval('public.units_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: links links_pkey; Type: CONSTRAINT; Schema: common; Owner: -
--

ALTER TABLE ONLY common.links
    ADD CONSTRAINT links_pkey PRIMARY KEY (id);


--
-- Name: organisations organisations_pkey; Type: CONSTRAINT; Schema: common; Owner: -
--

ALTER TABLE ONLY common.organisations
    ADD CONSTRAINT organisations_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: common; Owner: -
--

ALTER TABLE ONLY common.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: account_ledgers account_ledgers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_ledgers
    ADD CONSTRAINT account_ledgers_pkey PRIMARY KEY (id);


--
-- Name: accounts accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (id);


--
-- Name: active_storage_attachments active_storage_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments
    ADD CONSTRAINT active_storage_attachments_pkey PRIMARY KEY (id);


--
-- Name: active_storage_blobs active_storage_blobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_blobs
    ADD CONSTRAINT active_storage_blobs_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: attachments attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attachments
    ADD CONSTRAINT attachments_pkey PRIMARY KEY (id);


--
-- Name: contacts contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contacts
    ADD CONSTRAINT contacts_pkey PRIMARY KEY (id);


--
-- Name: histories histories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.histories
    ADD CONSTRAINT histories_pkey PRIMARY KEY (id);


--
-- Name: inventories inventories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventories
    ADD CONSTRAINT inventories_pkey PRIMARY KEY (id);


--
-- Name: inventory_details inventory_details_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inventory_details
    ADD CONSTRAINT inventory_details_pkey PRIMARY KEY (id);


--
-- Name: items items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT items_pkey PRIMARY KEY (id);


--
-- Name: links links_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.links
    ADD CONSTRAINT links_pkey PRIMARY KEY (id);


--
-- Name: movement_details movement_details_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.movement_details
    ADD CONSTRAINT movement_details_pkey PRIMARY KEY (id);


--
-- Name: organisations organisations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organisations
    ADD CONSTRAINT organisations_pkey PRIMARY KEY (id);


--
-- Name: projects projects_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: stocks stocks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stocks
    ADD CONSTRAINT stocks_pkey PRIMARY KEY (id);


--
-- Name: stores stores_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stores
    ADD CONSTRAINT stores_pkey PRIMARY KEY (id);


--
-- Name: tag_groups tag_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tag_groups
    ADD CONSTRAINT tag_groups_pkey PRIMARY KEY (id);


--
-- Name: tags tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: taxes taxes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.taxes
    ADD CONSTRAINT taxes_pkey PRIMARY KEY (id);


--
-- Name: units units_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units
    ADD CONSTRAINT units_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_links_on_api_token; Type: INDEX; Schema: common; Owner: -
--

CREATE UNIQUE INDEX index_links_on_api_token ON common.links USING btree (api_token);


--
-- Name: index_links_on_organisation_id; Type: INDEX; Schema: common; Owner: -
--

CREATE INDEX index_links_on_organisation_id ON common.links USING btree (organisation_id);


--
-- Name: index_links_on_tenant; Type: INDEX; Schema: common; Owner: -
--

CREATE INDEX index_links_on_tenant ON common.links USING btree (tenant);


--
-- Name: index_links_on_user_id; Type: INDEX; Schema: common; Owner: -
--

CREATE INDEX index_links_on_user_id ON common.links USING btree (user_id);


--
-- Name: index_organisations_on_country_code; Type: INDEX; Schema: common; Owner: -
--

CREATE INDEX index_organisations_on_country_code ON common.organisations USING btree (country_code);


--
-- Name: index_organisations_on_country_id; Type: INDEX; Schema: common; Owner: -
--

CREATE INDEX index_organisations_on_country_id ON common.organisations USING btree (country_id);


--
-- Name: index_organisations_on_currency; Type: INDEX; Schema: common; Owner: -
--

CREATE INDEX index_organisations_on_currency ON common.organisations USING btree (currency);


--
-- Name: index_organisations_on_due_date; Type: INDEX; Schema: common; Owner: -
--

CREATE INDEX index_organisations_on_due_date ON common.organisations USING btree (due_date);


--
-- Name: index_organisations_on_tenant; Type: INDEX; Schema: common; Owner: -
--

CREATE UNIQUE INDEX index_organisations_on_tenant ON common.organisations USING btree (tenant);


--
-- Name: index_users_on_auth_token; Type: INDEX; Schema: common; Owner: -
--

CREATE UNIQUE INDEX index_users_on_auth_token ON common.users USING btree (auth_token);


--
-- Name: index_users_on_confirmation_token; Type: INDEX; Schema: common; Owner: -
--

CREATE UNIQUE INDEX index_users_on_confirmation_token ON common.users USING btree (confirmation_token);


--
-- Name: index_users_on_email; Type: INDEX; Schema: common; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON common.users USING btree (email);


--
-- Name: index_users_on_first_name; Type: INDEX; Schema: common; Owner: -
--

CREATE INDEX index_users_on_first_name ON common.users USING btree (first_name);


--
-- Name: index_users_on_last_name; Type: INDEX; Schema: common; Owner: -
--

CREATE INDEX index_users_on_last_name ON common.users USING btree (last_name);


--
-- Name: index_account_ledgers_on_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_account_ledgers_on_account_id ON public.account_ledgers USING btree (account_id);


--
-- Name: index_account_ledgers_on_account_to_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_account_ledgers_on_account_to_id ON public.account_ledgers USING btree (account_to_id);


--
-- Name: index_account_ledgers_on_contact_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_account_ledgers_on_contact_id ON public.account_ledgers USING btree (contact_id);


--
-- Name: index_account_ledgers_on_currency; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_account_ledgers_on_currency ON public.account_ledgers USING btree (currency);


--
-- Name: index_account_ledgers_on_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_account_ledgers_on_date ON public.account_ledgers USING btree (date);


--
-- Name: index_account_ledgers_on_has_error; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_account_ledgers_on_has_error ON public.account_ledgers USING btree (has_error);


--
-- Name: index_account_ledgers_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_account_ledgers_on_name ON public.account_ledgers USING btree (name);


--
-- Name: index_account_ledgers_on_operation; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_account_ledgers_on_operation ON public.account_ledgers USING btree (operation);


--
-- Name: index_account_ledgers_on_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_account_ledgers_on_project_id ON public.account_ledgers USING btree (project_id);


--
-- Name: index_account_ledgers_on_reference; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_account_ledgers_on_reference ON public.account_ledgers USING gin (reference public.gin_trgm_ops);


--
-- Name: index_account_ledgers_on_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_account_ledgers_on_status ON public.account_ledgers USING btree (status);


--
-- Name: index_account_ledgers_on_updater_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_account_ledgers_on_updater_id ON public.account_ledgers USING btree (updater_id);


--
-- Name: index_accounts_on_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_accounts_on_active ON public.accounts USING btree (active);


--
-- Name: index_accounts_on_amount; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_accounts_on_amount ON public.accounts USING btree (amount);


--
-- Name: index_accounts_on_approver_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_accounts_on_approver_id ON public.accounts USING btree (approver_id);


--
-- Name: index_accounts_on_contact_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_accounts_on_contact_id ON public.accounts USING btree (contact_id);


--
-- Name: index_accounts_on_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_accounts_on_creator_id ON public.accounts USING btree (creator_id);


--
-- Name: index_accounts_on_currency; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_accounts_on_currency ON public.accounts USING btree (currency);


--
-- Name: index_accounts_on_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_accounts_on_date ON public.accounts USING btree (date);


--
-- Name: index_accounts_on_description; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_accounts_on_description ON public.accounts USING gin (description public.gin_trgm_ops);


--
-- Name: index_accounts_on_due_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_accounts_on_due_date ON public.accounts USING btree (due_date);


--
-- Name: index_accounts_on_extras; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_accounts_on_extras ON public.accounts USING gin (extras);


--
-- Name: index_accounts_on_has_error; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_accounts_on_has_error ON public.accounts USING btree (has_error);


--
-- Name: index_accounts_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_accounts_on_name ON public.accounts USING gin (name public.gin_trgm_ops);


--
-- Name: index_accounts_on_nuller_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_accounts_on_nuller_id ON public.accounts USING btree (nuller_id);


--
-- Name: index_accounts_on_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_accounts_on_project_id ON public.accounts USING btree (project_id);


--
-- Name: index_accounts_on_state; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_accounts_on_state ON public.accounts USING btree (state);


--
-- Name: index_accounts_on_tag_ids; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_accounts_on_tag_ids ON public.accounts USING gin (tag_ids);


--
-- Name: index_accounts_on_tax_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_accounts_on_tax_id ON public.accounts USING btree (tax_id);


--
-- Name: index_accounts_on_tax_in_out; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_accounts_on_tax_in_out ON public.accounts USING btree (tax_in_out);


--
-- Name: index_accounts_on_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_accounts_on_type ON public.accounts USING btree (type);


--
-- Name: index_accounts_on_updater_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_accounts_on_updater_id ON public.accounts USING btree (updater_id);


--
-- Name: index_active_storage_attachments_on_blob_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_active_storage_attachments_on_blob_id ON public.active_storage_attachments USING btree (blob_id);


--
-- Name: index_active_storage_attachments_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_attachments_uniqueness ON public.active_storage_attachments USING btree (record_type, record_id, name, blob_id);


--
-- Name: index_active_storage_blobs_on_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_blobs_on_key ON public.active_storage_blobs USING btree (key);


--
-- Name: index_attachments_on_attachable_id_and_attachable_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_attachments_on_attachable_id_and_attachable_type ON public.attachments USING btree (attachable_id, attachable_type);


--
-- Name: index_attachments_on_image; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_attachments_on_image ON public.attachments USING btree (image);


--
-- Name: index_attachments_on_publish; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_attachments_on_publish ON public.attachments USING btree (publish);


--
-- Name: index_attachments_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_attachments_on_user_id ON public.attachments USING btree (user_id);


--
-- Name: index_contacts_on_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contacts_on_active ON public.contacts USING btree (active);


--
-- Name: index_contacts_on_client; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contacts_on_client ON public.contacts USING btree (client);


--
-- Name: index_contacts_on_first_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contacts_on_first_name ON public.contacts USING btree (first_name);


--
-- Name: index_contacts_on_last_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contacts_on_last_name ON public.contacts USING btree (last_name);


--
-- Name: index_contacts_on_matchcode; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contacts_on_matchcode ON public.contacts USING btree (matchcode);


--
-- Name: index_contacts_on_staff; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contacts_on_staff ON public.contacts USING btree (staff);


--
-- Name: index_contacts_on_supplier; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contacts_on_supplier ON public.contacts USING btree (supplier);


--
-- Name: index_contacts_on_tag_ids; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_contacts_on_tag_ids ON public.contacts USING gin (tag_ids);


--
-- Name: index_histories_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_histories_on_created_at ON public.histories USING btree (created_at);


--
-- Name: index_histories_on_historiable_id_and_historiable_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_histories_on_historiable_id_and_historiable_type ON public.histories USING btree (historiable_id, historiable_type);


--
-- Name: index_histories_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_histories_on_user_id ON public.histories USING btree (user_id);


--
-- Name: index_inventories_on_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_inventories_on_account_id ON public.inventories USING btree (account_id);


--
-- Name: index_inventories_on_contact_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_inventories_on_contact_id ON public.inventories USING btree (contact_id);


--
-- Name: index_inventories_on_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_inventories_on_date ON public.inventories USING btree (date);


--
-- Name: index_inventories_on_has_error; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_inventories_on_has_error ON public.inventories USING btree (has_error);


--
-- Name: index_inventories_on_operation; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_inventories_on_operation ON public.inventories USING btree (operation);


--
-- Name: index_inventories_on_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_inventories_on_project_id ON public.inventories USING btree (project_id);


--
-- Name: index_inventories_on_ref_number; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_inventories_on_ref_number ON public.inventories USING btree (ref_number);


--
-- Name: index_inventories_on_store_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_inventories_on_store_id ON public.inventories USING btree (store_id);


--
-- Name: index_inventories_on_updater_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_inventories_on_updater_id ON public.inventories USING btree (updater_id);


--
-- Name: index_inventory_details_on_inventory_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_inventory_details_on_inventory_id ON public.inventory_details USING btree (inventory_id);


--
-- Name: index_inventory_details_on_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_inventory_details_on_item_id ON public.inventory_details USING btree (item_id);


--
-- Name: index_inventory_details_on_store_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_inventory_details_on_store_id ON public.inventory_details USING btree (store_id);


--
-- Name: index_items_on_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_items_on_code ON public.items USING btree (code);


--
-- Name: index_items_on_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_items_on_creator_id ON public.items USING btree (creator_id);


--
-- Name: index_items_on_for_sale; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_items_on_for_sale ON public.items USING btree (for_sale);


--
-- Name: index_items_on_stockable; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_items_on_stockable ON public.items USING btree (stockable);


--
-- Name: index_items_on_tag_ids; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_items_on_tag_ids ON public.items USING gin (tag_ids);


--
-- Name: index_items_on_unit_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_items_on_unit_id ON public.items USING btree (unit_id);


--
-- Name: index_items_on_updater_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_items_on_updater_id ON public.items USING btree (updater_id);


--
-- Name: index_links_on_api_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_links_on_api_token ON public.links USING btree (api_token);


--
-- Name: index_links_on_organisation_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_links_on_organisation_id ON public.links USING btree (organisation_id);


--
-- Name: index_links_on_tenant; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_links_on_tenant ON public.links USING btree (tenant);


--
-- Name: index_links_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_links_on_user_id ON public.links USING btree (user_id);


--
-- Name: index_movement_details_on_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_movement_details_on_account_id ON public.movement_details USING btree (account_id);


--
-- Name: index_movement_details_on_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_movement_details_on_item_id ON public.movement_details USING btree (item_id);


--
-- Name: index_organisations_on_country_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_organisations_on_country_code ON public.organisations USING btree (country_code);


--
-- Name: index_organisations_on_country_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_organisations_on_country_id ON public.organisations USING btree (country_id);


--
-- Name: index_organisations_on_currency; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_organisations_on_currency ON public.organisations USING btree (currency);


--
-- Name: index_organisations_on_due_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_organisations_on_due_date ON public.organisations USING btree (due_date);


--
-- Name: index_organisations_on_tenant; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_organisations_on_tenant ON public.organisations USING btree (tenant);


--
-- Name: index_projects_on_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_on_active ON public.projects USING btree (active);


--
-- Name: index_stocks_on_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stocks_on_active ON public.stocks USING btree (active);


--
-- Name: index_stocks_on_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stocks_on_item_id ON public.stocks USING btree (item_id);


--
-- Name: index_stocks_on_minimum; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stocks_on_minimum ON public.stocks USING btree (minimum);


--
-- Name: index_stocks_on_quantity; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stocks_on_quantity ON public.stocks USING btree (quantity);


--
-- Name: index_stocks_on_store_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stocks_on_store_id ON public.stocks USING btree (store_id);


--
-- Name: index_stocks_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_stocks_on_user_id ON public.stocks USING btree (user_id);


--
-- Name: index_tag_groups_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_tag_groups_on_name ON public.tag_groups USING btree (name);


--
-- Name: index_tag_groups_on_tag_ids; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tag_groups_on_tag_ids ON public.tag_groups USING gin (tag_ids);


--
-- Name: index_tags_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tags_on_name ON public.tags USING btree (name);


--
-- Name: index_users_on_auth_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_auth_token ON public.users USING btree (auth_token);


--
-- Name: index_users_on_confirmation_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_confirmation_token ON public.users USING btree (confirmation_token);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_on_first_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_first_name ON public.users USING btree (first_name);


--
-- Name: index_users_on_last_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_last_name ON public.users USING btree (last_name);


--
-- Name: active_storage_attachments fk_rails_c3b3935057; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments
    ADD CONSTRAINT fk_rails_c3b3935057 FOREIGN KEY (blob_id) REFERENCES public.active_storage_blobs(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "public"."schema_migrations" (version) VALUES
('20100101101010'),
('20100324202441'),
('20100325221629'),
('20100401192000'),
('20100416193705'),
('20100421174307'),
('20100427190727'),
('20100531141109'),
('20110119140408'),
('20110201153434'),
('20110201161907'),
('20110411174426'),
('20110411182005'),
('20110411182905'),
('20111103143524'),
('20121215153208'),
('20130114144400'),
('20130114164401'),
('20130115020409'),
('20130204171801'),
('20130221151829'),
('20130325155351'),
('20130411141221'),
('20130426151609'),
('20130429120114'),
('20130510144731'),
('20130510222719'),
('20130522125737'),
('20130527202406'),
('20130618172158'),
('20130618184031'),
('20130702144114'),
('20130704130428'),
('20130715185912'),
('20130716131229'),
('20130716131801'),
('20130717190543'),
('20130911005608'),
('20131009131456'),
('20131009141203'),
('20131211134555'),
('20131221130149'),
('20131223155017'),
('20131224080216'),
('20131224080916'),
('20131224081504'),
('20131227025934'),
('20131227032328'),
('20131229164735'),
('20140105165519'),
('20140118184207'),
('20140127023427'),
('20140127025407'),
('20140129135140'),
('20140131140212'),
('20140205123754'),
('20140213135130'),
('20140215130814'),
('20140217120803'),
('20140217134723'),
('20140219170720'),
('20140219210139'),
('20140219210551'),
('20140227163833'),
('20140417145820'),
('20140423120216'),
('20140603135208'),
('20140704132611'),
('20140730171947'),
('20140828122720'),
('20140925003650'),
('20141028104251'),
('20141112132422'),
('20160211130733'),
('20160215132803'),
('20160215133105'),
('20160215135420'),
('20160602111033'),
('20250405015600');


