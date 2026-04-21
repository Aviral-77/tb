--
-- PostgreSQL database dump
--

\restrict 1HqSZrL1VwueqTXInoUFbgUgu94GJLOApup2B9phG3vD7ZGjIkxAI4DhQ4dZ7mI

-- Dumped from database version 18.3 (Debian 18.3-1.pgdg13+1)
-- Dumped by pg_dump version 18.3 (Debian 18.3-1.pgdg13+1)

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
-- Name: digiwise_schema; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA digiwise_schema;


ALTER SCHEMA digiwise_schema OWNER TO postgres;

--
-- Name: enum_data_voix_data_amount_check_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.enum_data_voix_data_amount_check_status AS ENUM (
    'OK',
    'NOK'
);


ALTER TYPE public.enum_data_voix_data_amount_check_status OWNER TO postgres;

--
-- Name: enum_data_voix_data_followup_status_within_7_days; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.enum_data_voix_data_followup_status_within_7_days AS ENUM (
    'OK',
    'NOK'
);


ALTER TYPE public.enum_data_voix_data_followup_status_within_7_days OWNER TO postgres;

--
-- Name: enum_import_sources_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.enum_import_sources_type AS ENUM (
    'sage',
    'external'
);


ALTER TYPE public.enum_import_sources_type OWNER TO postgres;

--
-- Name: enum_moov_money_data_amountStatus; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public."enum_moov_money_data_amountStatus" AS ENUM (
    'OK',
    'NOK'
);


ALTER TYPE public."enum_moov_money_data_amountStatus" OWNER TO postgres;

--
-- Name: enum_moov_money_data_amount_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.enum_moov_money_data_amount_status AS ENUM (
    'OK',
    'NOK'
);


ALTER TYPE public.enum_moov_money_data_amount_status OWNER TO postgres;

--
-- Name: enum_moov_money_data_within7DaysStatus; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public."enum_moov_money_data_within7DaysStatus" AS ENUM (
    'OK',
    'NOK'
);


ALTER TYPE public."enum_moov_money_data_within7DaysStatus" OWNER TO postgres;

--
-- Name: enum_moov_money_data_within_7_days_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.enum_moov_money_data_within_7_days_status AS ENUM (
    'OK',
    'NOK'
);


ALTER TYPE public.enum_moov_money_data_within_7_days_status OWNER TO postgres;

--
-- Name: enum_moov_money_reactivation_data_matchingNumber; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public."enum_moov_money_reactivation_data_matchingNumber" AS ENUM (
    'OK',
    'NOK'
);


ALTER TYPE public."enum_moov_money_reactivation_data_matchingNumber" OWNER TO postgres;

--
-- Name: enum_moov_money_reactivation_data_matching_number; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.enum_moov_money_reactivation_data_matching_number AS ENUM (
    'OK',
    'NOK'
);


ALTER TYPE public.enum_moov_money_reactivation_data_matching_number OWNER TO postgres;

--
-- Name: enum_navigation_items_level; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.enum_navigation_items_level AS ENUM (
    'module',
    'menu',
    'page'
);


ALTER TYPE public.enum_navigation_items_level OWNER TO postgres;

--
-- Name: enum_notification_tracking_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.enum_notification_tracking_status AS ENUM (
    'pending',
    'uploaded',
    'failed'
);


ALTER TYPE public.enum_notification_tracking_status OWNER TO postgres;

--
-- Name: enum_notifications_is_read; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.enum_notifications_is_read AS ENUM (
    'unread',
    'read'
);


ALTER TYPE public.enum_notifications_is_read OWNER TO postgres;

--
-- Name: enum_notifications_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.enum_notifications_status AS ENUM (
    'pending',
    'uploaded',
    'failed',
    'info',
    'action_required'
);


ALTER TYPE public.enum_notifications_status OWNER TO postgres;

--
-- Name: enum_tbg_report_types_category; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.enum_tbg_report_types_category AS ENUM (
    'Reel',
    'Budget',
    'Actual'
);


ALTER TYPE public.enum_tbg_report_types_category OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: archive_registry; Type: TABLE; Schema: digiwise_schema; Owner: postgres
--

CREATE TABLE digiwise_schema.archive_registry (
    id bigint NOT NULL,
    file_name character varying(255) NOT NULL,
    archive_date timestamp with time zone NOT NULL,
    storage_path character varying(255) NOT NULL,
    si_registry_id integer,
    network_registry_id integer,
    vendor_registry_id integer,
    created_at timestamp with time zone,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE digiwise_schema.archive_registry OWNER TO postgres;

--
-- Name: archive_registry_id_seq; Type: SEQUENCE; Schema: digiwise_schema; Owner: postgres
--

CREATE SEQUENCE digiwise_schema.archive_registry_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE digiwise_schema.archive_registry_id_seq OWNER TO postgres;

--
-- Name: archive_registry_id_seq; Type: SEQUENCE OWNED BY; Schema: digiwise_schema; Owner: postgres
--

ALTER SEQUENCE digiwise_schema.archive_registry_id_seq OWNED BY digiwise_schema.archive_registry.id;


--
-- Name: financial_annual_data; Type: TABLE; Schema: digiwise_schema; Owner: postgres
--

CREATE TABLE digiwise_schema.financial_annual_data (
    id integer NOT NULL,
    financial_type_id integer,
    financial_metric_id integer,
    financial_submetric_id integer,
    date date NOT NULL,
    real_value double precision,
    budget_value double precision,
    actual1_value double precision,
    actual2_value double precision,
    actual3_value double precision,
    last_year_real_value double precision,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE digiwise_schema.financial_annual_data OWNER TO postgres;

--
-- Name: financial_annual_data_id_seq; Type: SEQUENCE; Schema: digiwise_schema; Owner: postgres
--

CREATE SEQUENCE digiwise_schema.financial_annual_data_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE digiwise_schema.financial_annual_data_id_seq OWNER TO postgres;

--
-- Name: financial_annual_data_id_seq; Type: SEQUENCE OWNED BY; Schema: digiwise_schema; Owner: postgres
--

ALTER SEQUENCE digiwise_schema.financial_annual_data_id_seq OWNED BY digiwise_schema.financial_annual_data.id;


--
-- Name: financial_categories; Type: TABLE; Schema: digiwise_schema; Owner: postgres
--

CREATE TABLE digiwise_schema.financial_categories (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE digiwise_schema.financial_categories OWNER TO postgres;

--
-- Name: financial_categories_id_seq; Type: SEQUENCE; Schema: digiwise_schema; Owner: postgres
--

CREATE SEQUENCE digiwise_schema.financial_categories_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE digiwise_schema.financial_categories_id_seq OWNER TO postgres;

--
-- Name: financial_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: digiwise_schema; Owner: postgres
--

ALTER SEQUENCE digiwise_schema.financial_categories_id_seq OWNED BY digiwise_schema.financial_categories.id;


--
-- Name: financial_cumulative_data; Type: TABLE; Schema: digiwise_schema; Owner: postgres
--

CREATE TABLE digiwise_schema.financial_cumulative_data (
    id integer NOT NULL,
    financial_type_id integer,
    financial_metric_id integer,
    financial_submetric_id integer,
    date date NOT NULL,
    real_value double precision,
    budget_value double precision,
    last_year_real_value double precision,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    actual1_value double precision,
    actual2_value double precision,
    actual3_value double precision
);


ALTER TABLE digiwise_schema.financial_cumulative_data OWNER TO postgres;

--
-- Name: financial_cumulative_data_id_seq; Type: SEQUENCE; Schema: digiwise_schema; Owner: postgres
--

CREATE SEQUENCE digiwise_schema.financial_cumulative_data_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE digiwise_schema.financial_cumulative_data_id_seq OWNER TO postgres;

--
-- Name: financial_cumulative_data_id_seq; Type: SEQUENCE OWNED BY; Schema: digiwise_schema; Owner: postgres
--

ALTER SEQUENCE digiwise_schema.financial_cumulative_data_id_seq OWNED BY digiwise_schema.financial_cumulative_data.id;


--
-- Name: financial_metric; Type: TABLE; Schema: digiwise_schema; Owner: postgres
--

CREATE TABLE digiwise_schema.financial_metric (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    sequence_id integer NOT NULL,
    financial_type_id integer,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE digiwise_schema.financial_metric OWNER TO postgres;

--
-- Name: financial_metric_id_seq; Type: SEQUENCE; Schema: digiwise_schema; Owner: postgres
--

CREATE SEQUENCE digiwise_schema.financial_metric_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE digiwise_schema.financial_metric_id_seq OWNER TO postgres;

--
-- Name: financial_metric_id_seq; Type: SEQUENCE OWNED BY; Schema: digiwise_schema; Owner: postgres
--

ALTER SEQUENCE digiwise_schema.financial_metric_id_seq OWNED BY digiwise_schema.financial_metric.id;


--
-- Name: financial_metrics_data; Type: TABLE; Schema: digiwise_schema; Owner: postgres
--

CREATE TABLE digiwise_schema.financial_metrics_data (
    id integer NOT NULL,
    financial_type_id integer,
    financial_metric_id integer,
    financial_submetric_id integer,
    date date NOT NULL,
    real_value double precision,
    budget_value double precision,
    actual1_value double precision,
    actual2_value double precision,
    actual3_value double precision,
    last_year_real_value double precision,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    parent_id integer
);


ALTER TABLE digiwise_schema.financial_metrics_data OWNER TO postgres;

--
-- Name: financial_metrics_data_id_seq; Type: SEQUENCE; Schema: digiwise_schema; Owner: postgres
--

CREATE SEQUENCE digiwise_schema.financial_metrics_data_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE digiwise_schema.financial_metrics_data_id_seq OWNER TO postgres;

--
-- Name: financial_metrics_data_id_seq; Type: SEQUENCE OWNED BY; Schema: digiwise_schema; Owner: postgres
--

ALTER SEQUENCE digiwise_schema.financial_metrics_data_id_seq OWNED BY digiwise_schema.financial_metrics_data.id;


--
-- Name: financial_submetric; Type: TABLE; Schema: digiwise_schema; Owner: postgres
--

CREATE TABLE digiwise_schema.financial_submetric (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    sequence_id integer NOT NULL,
    financial_metric_id integer,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE digiwise_schema.financial_submetric OWNER TO postgres;

--
-- Name: financial_submetric_id_seq; Type: SEQUENCE; Schema: digiwise_schema; Owner: postgres
--

CREATE SEQUENCE digiwise_schema.financial_submetric_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE digiwise_schema.financial_submetric_id_seq OWNER TO postgres;

--
-- Name: financial_submetric_id_seq; Type: SEQUENCE OWNED BY; Schema: digiwise_schema; Owner: postgres
--

ALTER SEQUENCE digiwise_schema.financial_submetric_id_seq OWNED BY digiwise_schema.financial_submetric.id;


--
-- Name: financial_types; Type: TABLE; Schema: digiwise_schema; Owner: postgres
--

CREATE TABLE digiwise_schema.financial_types (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    sequence_id integer NOT NULL,
    financial_category_id integer,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE digiwise_schema.financial_types OWNER TO postgres;

--
-- Name: financial_types_id_seq; Type: SEQUENCE; Schema: digiwise_schema; Owner: postgres
--

CREATE SEQUENCE digiwise_schema.financial_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE digiwise_schema.financial_types_id_seq OWNER TO postgres;

--
-- Name: financial_types_id_seq; Type: SEQUENCE OWNED BY; Schema: digiwise_schema; Owner: postgres
--

ALTER SEQUENCE digiwise_schema.financial_types_id_seq OWNED BY digiwise_schema.financial_types.id;


--
-- Name: network_registry; Type: TABLE; Schema: digiwise_schema; Owner: postgres
--

CREATE TABLE digiwise_schema.network_registry (
    id integer NOT NULL,
    network_type character varying(255) NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE digiwise_schema.network_registry OWNER TO postgres;

--
-- Name: network_registry_id_seq; Type: SEQUENCE; Schema: digiwise_schema; Owner: postgres
--

CREATE SEQUENCE digiwise_schema.network_registry_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE digiwise_schema.network_registry_id_seq OWNER TO postgres;

--
-- Name: network_registry_id_seq; Type: SEQUENCE OWNED BY; Schema: digiwise_schema; Owner: postgres
--

ALTER SEQUENCE digiwise_schema.network_registry_id_seq OWNED BY digiwise_schema.network_registry.id;


--
-- Name: si_registry; Type: TABLE; Schema: digiwise_schema; Owner: postgres
--

CREATE TABLE digiwise_schema.si_registry (
    id integer NOT NULL,
    si_type character varying(255) NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE digiwise_schema.si_registry OWNER TO postgres;

--
-- Name: si_registry_id_seq; Type: SEQUENCE; Schema: digiwise_schema; Owner: postgres
--

CREATE SEQUENCE digiwise_schema.si_registry_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE digiwise_schema.si_registry_id_seq OWNER TO postgres;

--
-- Name: si_registry_id_seq; Type: SEQUENCE OWNED BY; Schema: digiwise_schema; Owner: postgres
--

ALTER SEQUENCE digiwise_schema.si_registry_id_seq OWNED BY digiwise_schema.si_registry.id;


--
-- Name: vendor_registry; Type: TABLE; Schema: digiwise_schema; Owner: postgres
--

CREATE TABLE digiwise_schema.vendor_registry (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    network_registry_id integer,
    created_at timestamp with time zone,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE digiwise_schema.vendor_registry OWNER TO postgres;

--
-- Name: vendor_registry_id_seq; Type: SEQUENCE; Schema: digiwise_schema; Owner: postgres
--

CREATE SEQUENCE digiwise_schema.vendor_registry_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE digiwise_schema.vendor_registry_id_seq OWNER TO postgres;

--
-- Name: vendor_registry_id_seq; Type: SEQUENCE OWNED BY; Schema: digiwise_schema; Owner: postgres
--

ALTER SEQUENCE digiwise_schema.vendor_registry_id_seq OWNED BY digiwise_schema.vendor_registry.id;


--
-- Name: DownloadRequests; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."DownloadRequests" (
    id integer NOT NULL,
    "userId" character varying(255),
    "versionId" character varying(255),
    "fileName" character varying(255) NOT NULL,
    "destFileName" character varying(255) NOT NULL,
    "bucketName" character varying(255) NOT NULL,
    "filePath" character varying(255) NOT NULL,
    status character varying(255) NOT NULL,
    "errorMessage" character varying(255),
    "expiresOn" timestamp with time zone,
    "fileUrl" text,
    "dateModified" timestamp with time zone,
    size character varying(255),
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone NOT NULL
);


ALTER TABLE public."DownloadRequests" OWNER TO postgres;

--
-- Name: DownloadRequests_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."DownloadRequests_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."DownloadRequests_id_seq" OWNER TO postgres;

--
-- Name: DownloadRequests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."DownloadRequests_id_seq" OWNED BY public."DownloadRequests".id;


--
-- Name: SequelizeMeta; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."SequelizeMeta" (
    name character varying(255) NOT NULL
);


ALTER TABLE public."SequelizeMeta" OWNER TO postgres;

--
-- Name: activity_events; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.activity_events (
    id bigint NOT NULL,
    event_timestamp timestamp with time zone NOT NULL,
    user_id character varying(255) NOT NULL,
    module_name character varying(255) NOT NULL,
    action_type character varying(255) DEFAULT 'MODULE_VIEW'::character varying NOT NULL,
    duration_seconds integer,
    country character varying(255),
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE public.activity_events OWNER TO postgres;

--
-- Name: activity_events_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.activity_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.activity_events_id_seq OWNER TO postgres;

--
-- Name: activity_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.activity_events_id_seq OWNED BY public.activity_events.id;


--
-- Name: alert_notifications; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.alert_notifications (
    id integer NOT NULL,
    app_id integer,
    sent_at timestamp with time zone NOT NULL,
    recipients jsonb,
    subject text,
    body text,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE public.alert_notifications OWNER TO postgres;

--
-- Name: alert_notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.alert_notifications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.alert_notifications_id_seq OWNER TO postgres;

--
-- Name: alert_notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.alert_notifications_id_seq OWNED BY public.alert_notifications.id;


--
-- Name: app_icons; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.app_icons (
    id integer NOT NULL,
    icon_key character varying(255) NOT NULL,
    country_code character varying(255) DEFAULT 'ALL'::character varying NOT NULL,
    svg_content text NOT NULL,
    default_color character varying(255),
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone
);


ALTER TABLE public.app_icons OWNER TO postgres;

--
-- Name: COLUMN app_icons.icon_key; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.app_icons.icon_key IS 'The key used in the frontend code (e.g., "home", "dashboard")';


--
-- Name: COLUMN app_icons.country_code; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.app_icons.country_code IS 'Country specific code (e.g., "BENIN", "MALI") or "ALL" for default';


--
-- Name: COLUMN app_icons.svg_content; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.app_icons.svg_content IS 'Raw SVG string content';


--
-- Name: COLUMN app_icons.default_color; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.app_icons.default_color IS 'Optional hex color override (e.g., "#FF5733")';


--
-- Name: app_icons_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.app_icons_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.app_icons_id_seq OWNER TO postgres;

--
-- Name: app_icons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.app_icons_id_seq OWNED BY public.app_icons.id;


--
-- Name: archive_registry; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.archive_registry (
    id bigint NOT NULL,
    file_name character varying(255) NOT NULL,
    archive_date timestamp with time zone NOT NULL,
    storage_path character varying(255) NOT NULL,
    si_registry_id integer,
    network_registry_id integer,
    vendor_registry_id integer,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    raw_size bigint,
    compressed_size bigint,
    archive_start_date date,
    archive_end_date date,
    file_extension character varying(255)
);


ALTER TABLE public.archive_registry OWNER TO postgres;

--
-- Name: archive_registry_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.archive_registry_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.archive_registry_id_seq OWNER TO postgres;

--
-- Name: archive_registry_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.archive_registry_id_seq OWNED BY public.archive_registry.id;


--
-- Name: archive_storage_kpis; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.archive_storage_kpis (
    id integer NOT NULL,
    record_date date NOT NULL,
    file_count integer NOT NULL,
    used_storage_bytes bigint NOT NULL,
    available_storage_bytes bigint NOT NULL,
    total_storage_bytes bigint NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.archive_storage_kpis OWNER TO postgres;

--
-- Name: archive_storage_kpis_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.archive_storage_kpis_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.archive_storage_kpis_id_seq OWNER TO postgres;

--
-- Name: archive_storage_kpis_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.archive_storage_kpis_id_seq OWNED BY public.archive_storage_kpis.id;


--
-- Name: base_lineage_benin; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.base_lineage_benin (
    id uuid NOT NULL,
    filename text,
    event_type text,
    status text,
    stage text,
    event_ts timestamp without time zone,
    group_id uuid,
    CONSTRAINT base_lineage_benin_status_check CHECK ((status = ANY (ARRAY['success'::text, 'failure'::text, 'inprogress'::text])))
);


ALTER TABLE public.base_lineage_benin OWNER TO postgres;

--
-- Name: base_lineage_mali; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.base_lineage_mali (
    id uuid NOT NULL,
    filename text,
    event_type text,
    status text,
    stage text,
    event_timestamp timestamp without time zone,
    group_id uuid,
    CONSTRAINT base_lineage_mali_status_check CHECK ((status = ANY (ARRAY['success'::text, 'failure'::text])))
);


ALTER TABLE public.base_lineage_mali OWNER TO postgres;

--
-- Name: capex_data; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.capex_data (
    id integer NOT NULL,
    capex_projects_id integer NOT NULL,
    month integer NOT NULL,
    year integer NOT NULL,
    equipment bigint,
    services bigint,
    additional_costs bigint
);


ALTER TABLE public.capex_data OWNER TO postgres;

--
-- Name: capex_data_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.capex_data_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.capex_data_id_seq OWNER TO postgres;

--
-- Name: capex_data_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.capex_data_id_seq OWNED BY public.capex_data.id;


--
-- Name: capex_projects; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.capex_projects (
    id integer NOT NULL,
    supplier_name character varying(255),
    direction_name character varying(255),
    project_title character varying(255) NOT NULL,
    contract_no character varying(255) NOT NULL,
    contract_date date,
    sequence_id integer NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.capex_projects OWNER TO postgres;

--
-- Name: capex_projects_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.capex_projects_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.capex_projects_id_seq OWNER TO postgres;

--
-- Name: capex_projects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.capex_projects_id_seq OWNED BY public.capex_projects.id;


--
-- Name: cashflow_categories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cashflow_categories (
    id integer NOT NULL,
    cashflow_section_id integer,
    name character varying(255) NOT NULL,
    is_category boolean DEFAULT true NOT NULL,
    sequence_id integer,
    tbg_key character varying(255)
);


ALTER TABLE public.cashflow_categories OWNER TO postgres;

--
-- Name: cashflow_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.cashflow_categories_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cashflow_categories_id_seq OWNER TO postgres;

--
-- Name: cashflow_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.cashflow_categories_id_seq OWNED BY public.cashflow_categories.id;


--
-- Name: cashflow_data; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cashflow_data (
    id integer NOT NULL,
    entity_id integer NOT NULL,
    entity_type character varying(255) NOT NULL,
    year integer NOT NULL,
    last_year_total double precision,
    current_year_total double precision,
    jan double precision,
    feb double precision,
    mar double precision,
    apr double precision,
    may double precision,
    jun double precision,
    jul double precision,
    aug double precision,
    sep double precision,
    oct double precision,
    nov double precision,
    "dec" double precision,
    version_id integer
);


ALTER TABLE public.cashflow_data OWNER TO postgres;

--
-- Name: cashflow_data_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.cashflow_data_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cashflow_data_id_seq OWNER TO postgres;

--
-- Name: cashflow_data_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.cashflow_data_id_seq OWNED BY public.cashflow_data.id;


--
-- Name: cashflow_sections; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cashflow_sections (
    id integer NOT NULL,
    realised_cashflow_id integer,
    parent_section_id integer,
    name character varying(255) NOT NULL,
    type character varying(255) NOT NULL,
    sequence_id integer,
    tbg_key character varying(255)
);


ALTER TABLE public.cashflow_sections OWNER TO postgres;

--
-- Name: cashflow_sections_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.cashflow_sections_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cashflow_sections_id_seq OWNER TO postgres;

--
-- Name: cashflow_sections_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.cashflow_sections_id_seq OWNED BY public.cashflow_sections.id;


--
-- Name: cashflow_subcategories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cashflow_subcategories (
    id integer NOT NULL,
    cashflow_category_id integer,
    name character varying(255) NOT NULL,
    sequence_id integer,
    tbg_key character varying(255)
);


ALTER TABLE public.cashflow_subcategories OWNER TO postgres;

--
-- Name: cashflow_subcategories_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.cashflow_subcategories_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cashflow_subcategories_id_seq OWNER TO postgres;

--
-- Name: cashflow_subcategories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.cashflow_subcategories_id_seq OWNED BY public.cashflow_subcategories.id;


--
-- Name: collapse_annual_data; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.collapse_annual_data (
    id integer NOT NULL,
    entity_id integer NOT NULL,
    entity_type character varying(255) NOT NULL,
    date date NOT NULL,
    real_value double precision,
    budget_value double precision,
    actual1_value double precision,
    actual2_value double precision,
    actual3_value double precision,
    last_year_real_value double precision,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    version_id integer
);


ALTER TABLE public.collapse_annual_data OWNER TO postgres;

--
-- Name: collapse_annual_data_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.collapse_annual_data_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.collapse_annual_data_id_seq OWNER TO postgres;

--
-- Name: collapse_annual_data_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.collapse_annual_data_id_seq OWNED BY public.collapse_annual_data.id;


--
-- Name: collapse_categories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.collapse_categories (
    id integer NOT NULL,
    collapse_type_id integer,
    name character varying(255) NOT NULL,
    unique_name character varying(255),
    sequence_id integer NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    tbg_key text,
    sage_source_key text
);


ALTER TABLE public.collapse_categories OWNER TO postgres;

--
-- Name: collapse_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.collapse_categories_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.collapse_categories_id_seq OWNER TO postgres;

--
-- Name: collapse_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.collapse_categories_id_seq OWNED BY public.collapse_categories.id;


--
-- Name: collapse_cumul_data; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.collapse_cumul_data (
    id integer NOT NULL,
    entity_id integer NOT NULL,
    entity_type character varying(255) NOT NULL,
    date date NOT NULL,
    real_value double precision,
    budget_value double precision,
    actual1_value double precision,
    actual2_value double precision,
    actual3_value double precision,
    last_year_real_value double precision,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    version_id integer
);


ALTER TABLE public.collapse_cumul_data OWNER TO postgres;

--
-- Name: collapse_cumul_data_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.collapse_cumul_data_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.collapse_cumul_data_id_seq OWNER TO postgres;

--
-- Name: collapse_cumul_data_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.collapse_cumul_data_id_seq OWNED BY public.collapse_cumul_data.id;


--
-- Name: collapse_monthly_data; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.collapse_monthly_data (
    id integer NOT NULL,
    entity_id integer NOT NULL,
    entity_type character varying(255) NOT NULL,
    date date NOT NULL,
    real_value double precision,
    budget_value double precision,
    actual1_value double precision,
    actual2_value double precision,
    actual3_value double precision,
    last_year_real_value double precision,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    version_id integer,
    delta_value double precision,
    sage_cumul_value double precision
);


ALTER TABLE public.collapse_monthly_data OWNER TO postgres;

--
-- Name: collapse_monthly_data_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.collapse_monthly_data_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.collapse_monthly_data_id_seq OWNER TO postgres;

--
-- Name: collapse_monthly_data_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.collapse_monthly_data_id_seq OWNED BY public.collapse_monthly_data.id;


--
-- Name: collapse_subcategories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.collapse_subcategories (
    id integer NOT NULL,
    collapse_category_id integer,
    name character varying(255) NOT NULL,
    unique_name character varying(255),
    sequence_id integer NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    tbg_key text,
    sage_source_key text
);


ALTER TABLE public.collapse_subcategories OWNER TO postgres;

--
-- Name: collapse_subcategories_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.collapse_subcategories_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.collapse_subcategories_id_seq OWNER TO postgres;

--
-- Name: collapse_subcategories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.collapse_subcategories_id_seq OWNED BY public.collapse_subcategories.id;


--
-- Name: collapse_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.collapse_types (
    id integer NOT NULL,
    collapsible_item_id integer,
    name character varying(255) NOT NULL,
    unique_name character varying(255),
    sequence_id integer NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    tbg_key text,
    sage_source_key text
);


ALTER TABLE public.collapse_types OWNER TO postgres;

--
-- Name: collapse_types_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.collapse_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.collapse_types_id_seq OWNER TO postgres;

--
-- Name: collapse_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.collapse_types_id_seq OWNED BY public.collapse_types.id;


--
-- Name: collapsible_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.collapsible_items (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    unique_name character varying(255),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    financial_categories_id integer
);


ALTER TABLE public.collapsible_items OWNER TO postgres;

--
-- Name: collapsible_items_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.collapsible_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.collapsible_items_id_seq OWNER TO postgres;

--
-- Name: collapsible_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.collapsible_items_id_seq OWNED BY public.collapsible_items.id;


--
-- Name: commission_calculation_histories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.commission_calculation_histories (
    id integer NOT NULL,
    parent_id integer NOT NULL,
    field_name character varying(255) NOT NULL,
    old_value character varying(255),
    new_value character varying(255),
    "userName" character varying(255) NOT NULL,
    "userId" integer,
    table_key character varying(255),
    "createdAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.commission_calculation_histories OWNER TO postgres;

--
-- Name: commission_calculation_histories_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.commission_calculation_histories_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.commission_calculation_histories_id_seq OWNER TO postgres;

--
-- Name: commission_calculation_histories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.commission_calculation_histories_id_seq OWNED BY public.commission_calculation_histories.id;


--
-- Name: commission_calculation_rules; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.commission_calculation_rules (
    id integer NOT NULL,
    commission_type_id integer NOT NULL,
    min_threshold double precision NOT NULL,
    max_threshold double precision,
    commission_rate double precision NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


ALTER TABLE public.commission_calculation_rules OWNER TO postgres;

--
-- Name: commission_calculation_rules_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.commission_calculation_rules_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.commission_calculation_rules_id_seq OWNER TO postgres;

--
-- Name: commission_calculation_rules_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.commission_calculation_rules_id_seq OWNED BY public.commission_calculation_rules.id;


--
-- Name: commission_calculation_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.commission_calculation_types (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


ALTER TABLE public.commission_calculation_types OWNER TO postgres;

--
-- Name: commission_calculation_types_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.commission_calculation_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.commission_calculation_types_id_seq OWNER TO postgres;

--
-- Name: commission_calculation_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.commission_calculation_types_id_seq OWNED BY public.commission_calculation_types.id;


--
-- Name: commission_enlevements; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.commission_enlevements (
    id integer NOT NULL,
    prodium bigint,
    linarcels bigint,
    easycom bigint,
    somac bigint,
    d_commercial bigint,
    aftel bigint,
    month integer,
    year integer,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    senaniminde bigint
);


ALTER TABLE public.commission_enlevements OWNER TO postgres;

--
-- Name: commission_enlevements_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.commission_enlevements_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.commission_enlevements_id_seq OWNER TO postgres;

--
-- Name: commission_enlevements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.commission_enlevements_id_seq OWNED BY public.commission_enlevements.id;


--
-- Name: commission_file_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.commission_file_types (
    id integer NOT NULL,
    file_name character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.commission_file_types OWNER TO postgres;

--
-- Name: commission_file_types_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.commission_file_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.commission_file_types_id_seq OWNER TO postgres;

--
-- Name: commission_file_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.commission_file_types_id_seq OWNED BY public.commission_file_types.id;


--
-- Name: commission_files; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.commission_files (
    id integer NOT NULL,
    file_name character varying(255) NOT NULL,
    file_path character varying(255) NOT NULL,
    file_type character varying(255) NOT NULL,
    group_id integer NOT NULL,
    type_id integer NOT NULL,
    description text,
    commission_type character varying(255) NOT NULL,
    month integer NOT NULL,
    year integer NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.commission_files OWNER TO postgres;

--
-- Name: commission_files_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.commission_files_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.commission_files_id_seq OWNER TO postgres;

--
-- Name: commission_files_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.commission_files_id_seq OWNED BY public.commission_files.id;


--
-- Name: commission_groups; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.commission_groups (
    id integer NOT NULL,
    group_name character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.commission_groups OWNER TO postgres;

--
-- Name: commission_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.commission_groups_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.commission_groups_id_seq OWNER TO postgres;

--
-- Name: commission_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.commission_groups_id_seq OWNED BY public.commission_groups.id;


--
-- Name: commission_histories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.commission_histories (
    id integer NOT NULL,
    group_id integer NOT NULL,
    type_id integer NOT NULL,
    description text,
    input_files_uploaded text[],
    calculation_files_uploaded text[],
    month integer NOT NULL,
    year integer NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    status character varying(255),
    error_message text,
    user_id character varying(255),
    user_name character varying(255),
    notification_id integer
);


ALTER TABLE public.commission_histories OWNER TO postgres;

--
-- Name: commission_histories_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.commission_histories_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.commission_histories_id_seq OWNER TO postgres;

--
-- Name: commission_histories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.commission_histories_id_seq OWNED BY public.commission_histories.id;


--
-- Name: commission_subtypes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.commission_subtypes (
    id integer NOT NULL,
    type_id integer NOT NULL,
    subtype_name character varying(255) NOT NULL,
    calculation_fields jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.commission_subtypes OWNER TO postgres;

--
-- Name: commission_subtypes_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.commission_subtypes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.commission_subtypes_id_seq OWNER TO postgres;

--
-- Name: commission_subtypes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.commission_subtypes_id_seq OWNED BY public.commission_subtypes.id;


--
-- Name: commission_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.commission_types (
    id integer NOT NULL,
    group_id integer NOT NULL,
    type_name character varying(255) NOT NULL,
    input_file_types integer[],
    calc_file_types integer[],
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.commission_types OWNER TO postgres;

--
-- Name: commission_types_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.commission_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.commission_types_id_seq OWNER TO postgres;

--
-- Name: commission_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.commission_types_id_seq OWNED BY public.commission_types.id;


--
-- Name: component_file_upload_rule_sheets; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.component_file_upload_rule_sheets (
    id integer NOT NULL,
    rule_sheet_name character varying(255) NOT NULL,
    upload_sheet_id integer NOT NULL,
    sheet_data jsonb,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    is_active boolean DEFAULT false NOT NULL,
    verify_name boolean DEFAULT true NOT NULL,
    max_size_kb integer DEFAULT 10240 NOT NULL
);


ALTER TABLE public.component_file_upload_rule_sheets OWNER TO postgres;

--
-- Name: component_file_upload_rule_sheets_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.component_file_upload_rule_sheets_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.component_file_upload_rule_sheets_id_seq OWNER TO postgres;

--
-- Name: component_file_upload_rule_sheets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.component_file_upload_rule_sheets_id_seq OWNED BY public.component_file_upload_rule_sheets.id;


--
-- Name: configuration; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.configuration (
    id integer NOT NULL,
    si_registry_id integer NOT NULL,
    sftp_username character varying(100),
    sftp_password character varying(255),
    sftp_directory character varying(255),
    sftp_threshold integer,
    sftp_url character varying(255),
    sftp_port integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.configuration OWNER TO postgres;

--
-- Name: configuration_archive; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.configuration_archive (
    id integer NOT NULL,
    archive_threshold integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.configuration_archive OWNER TO postgres;

--
-- Name: configuration_archive_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.configuration_archive_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.configuration_archive_id_seq OWNER TO postgres;

--
-- Name: configuration_archive_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.configuration_archive_id_seq OWNED BY public.configuration_archive.id;


--
-- Name: configuration_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.configuration_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.configuration_id_seq OWNER TO postgres;

--
-- Name: configuration_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.configuration_id_seq OWNED BY public.configuration.id;


--
-- Name: country_module_configs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.country_module_configs (
    id integer NOT NULL,
    country character varying(255) NOT NULL,
    module_key character varying(255) NOT NULL,
    is_enabled boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.country_module_configs OWNER TO postgres;

--
-- Name: COLUMN country_module_configs.country; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.country_module_configs.country IS 'Country code matching COUNTRY env var e.g. BENIN, CENTRAL_AFRICA';


--
-- Name: country_module_configs_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.country_module_configs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.country_module_configs_id_seq OWNER TO postgres;

--
-- Name: country_module_configs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.country_module_configs_id_seq OWNED BY public.country_module_configs.id;


--
-- Name: data_cormant_metics; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.data_cormant_metics (
    id integer NOT NULL,
    nc_voix_number integer NOT NULL,
    nc_voix_perc integer NOT NULL,
    nc_moov_number integer NOT NULL,
    nc_moov_perc integer NOT NULL,
    c_voix_number integer NOT NULL,
    c_voix_perc integer NOT NULL,
    c_moov_number integer NOT NULL,
    c_moov_perc integer NOT NULL,
    "createdAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.data_cormant_metics OWNER TO postgres;

--
-- Name: data_cormant_metics_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.data_cormant_metics_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.data_cormant_metics_id_seq OWNER TO postgres;

--
-- Name: data_cormant_metics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.data_cormant_metics_id_seq OWNED BY public.data_cormant_metics.id;


--
-- Name: data_cormat_upload_files; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.data_cormat_upload_files (
    id integer NOT NULL,
    file_name character varying(255) NOT NULL,
    file_path character varying(255) NOT NULL,
    file_type character varying(255) NOT NULL,
    sheet_type character varying(255) NOT NULL,
    upload_date timestamp with time zone NOT NULL
);


ALTER TABLE public.data_cormat_upload_files OWNER TO postgres;

--
-- Name: data_cormat_upload_files_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.data_cormat_upload_files_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.data_cormat_upload_files_id_seq OWNER TO postgres;

--
-- Name: data_cormat_upload_files_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.data_cormat_upload_files_id_seq OWNED BY public.data_cormat_upload_files.id;


--
-- Name: data_dormant_metadata; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.data_dormant_metadata (
    id integer NOT NULL,
    status character varying(255) NOT NULL,
    client_sheet_id integer,
    partner_sheet_id integer,
    dormant_file_type character varying(255) NOT NULL,
    processing_start_date timestamp with time zone NOT NULL,
    description character varying(255),
    error_message text,
    "createdAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    notification_id integer,
    user_id character varying(255),
    user_name character varying(255)
);


ALTER TABLE public.data_dormant_metadata OWNER TO postgres;

--
-- Name: data_dormant_metadata_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.data_dormant_metadata_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.data_dormant_metadata_id_seq OWNER TO postgres;

--
-- Name: data_dormant_metadata_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.data_dormant_metadata_id_seq OWNED BY public.data_dormant_metadata.id;


--
-- Name: data_dormant_metics; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.data_dormant_metics (
    id integer NOT NULL,
    nc_voix_number integer NOT NULL,
    nc_voix_perc integer NOT NULL,
    nc_moov_number integer NOT NULL,
    nc_moov_perc integer NOT NULL,
    c_voix_number integer NOT NULL,
    c_voix_perc integer NOT NULL,
    c_moov_number integer NOT NULL,
    c_moov_perc integer NOT NULL,
    "createdAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.data_dormant_metics OWNER TO postgres;

--
-- Name: data_dormant_metics_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.data_dormant_metics_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.data_dormant_metics_id_seq OWNER TO postgres;

--
-- Name: data_dormant_metics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.data_dormant_metics_id_seq OWNED BY public.data_dormant_metics.id;


--
-- Name: data_dormant_upload_files; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.data_dormant_upload_files (
    id integer NOT NULL,
    file_name character varying(255) NOT NULL,
    file_path character varying(255) NOT NULL,
    file_type character varying(255) NOT NULL,
    sheet_type character varying(255) NOT NULL,
    upload_date timestamp with time zone NOT NULL
);


ALTER TABLE public.data_dormant_upload_files OWNER TO postgres;

--
-- Name: data_dormant_upload_files_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.data_dormant_upload_files_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.data_dormant_upload_files_id_seq OWNER TO postgres;

--
-- Name: data_dormant_upload_files_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.data_dormant_upload_files_id_seq OWNED BY public.data_dormant_upload_files.id;


--
-- Name: data_lineage_alerts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.data_lineage_alerts (
    id integer NOT NULL,
    notification_id integer,
    type character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.data_lineage_alerts OWNER TO postgres;

--
-- Name: data_lineage_alerts_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.data_lineage_alerts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.data_lineage_alerts_id_seq OWNER TO postgres;

--
-- Name: data_lineage_alerts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.data_lineage_alerts_id_seq OWNED BY public.data_lineage_alerts.id;


--
-- Name: data_lineage_configs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.data_lineage_configs (
    id integer NOT NULL,
    key character varying(255) NOT NULL,
    value jsonb NOT NULL,
    "createdAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.data_lineage_configs OWNER TO postgres;

--
-- Name: data_lineage_configs_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.data_lineage_configs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.data_lineage_configs_id_seq OWNER TO postgres;

--
-- Name: data_lineage_configs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.data_lineage_configs_id_seq OWNED BY public.data_lineage_configs.id;


--
-- Name: data_lineage_edges; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.data_lineage_edges (
    id character varying(255) NOT NULL,
    source character varying(255) NOT NULL,
    target character varying(255) NOT NULL,
    animated boolean DEFAULT false NOT NULL,
    stage_id integer NOT NULL,
    "createdAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.data_lineage_edges OWNER TO postgres;

--
-- Name: data_lineage_events; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.data_lineage_events (
    id integer NOT NULL,
    event_name character varying(255) NOT NULL,
    display_name character varying(255) NOT NULL,
    style jsonb,
    description character varying(255),
    sequence_number integer NOT NULL,
    icon character varying(255),
    country text,
    project_type text,
    "position" jsonb,
    source_position character varying(255),
    target_position character varying(255),
    stage_id integer,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE public.data_lineage_events OWNER TO postgres;

--
-- Name: data_lineage_events_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.data_lineage_events_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.data_lineage_events_id_seq OWNER TO postgres;

--
-- Name: data_lineage_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.data_lineage_events_id_seq OWNED BY public.data_lineage_events.id;


--
-- Name: data_lineage_notification; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.data_lineage_notification (
    id integer NOT NULL,
    type character varying(255) NOT NULL,
    title character varying(255) NOT NULL,
    description text,
    user_id character varying(255) NOT NULL,
    user_name character varying(255) NOT NULL,
    is_read character varying(255) DEFAULT 'unread'::character varying NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.data_lineage_notification OWNER TO postgres;

--
-- Name: data_lineage_notification_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.data_lineage_notification_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.data_lineage_notification_id_seq OWNER TO postgres;

--
-- Name: data_lineage_notification_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.data_lineage_notification_id_seq OWNED BY public.data_lineage_notification.id;


--
-- Name: data_lineage_stage; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.data_lineage_stage (
    id integer NOT NULL,
    stage_name text NOT NULL,
    description text,
    display_name text NOT NULL,
    sequence_number integer NOT NULL,
    country text,
    project_type text,
    "createdAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.data_lineage_stage OWNER TO postgres;

--
-- Name: data_lineage_stage_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.data_lineage_stage_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.data_lineage_stage_id_seq OWNER TO postgres;

--
-- Name: data_lineage_stage_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.data_lineage_stage_id_seq OWNED BY public.data_lineage_stage.id;


--
-- Name: data_voix_auto_rechargement_data; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.data_voix_auto_rechargement_data (
    id integer NOT NULL,
    report_date timestamp with time zone NOT NULL,
    department character varying(255),
    commune character varying(255),
    neighborhood character varying(255),
    subscriber_number character varying(255),
    agent_name character varying(255),
    agent_number character varying(255),
    deposit_amount bigint,
    activation_type character varying(255),
    activation_amount bigint,
    total_amount bigint,
    matching_status boolean
);


ALTER TABLE public.data_voix_auto_rechargement_data OWNER TO postgres;

--
-- Name: data_voix_auto_rechargement_data_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.data_voix_auto_rechargement_data_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.data_voix_auto_rechargement_data_id_seq OWNER TO postgres;

--
-- Name: data_voix_auto_rechargement_data_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.data_voix_auto_rechargement_data_id_seq OWNED BY public.data_voix_auto_rechargement_data.id;


--
-- Name: data_voix_data; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.data_voix_data (
    id integer NOT NULL,
    date timestamp with time zone NOT NULL,
    subscriber_number character varying(255),
    point_of_sale character varying(255),
    amount bigint,
    amount_check_status boolean,
    unique_transaction_status boolean,
    first_transaction_date timestamp with time zone,
    followup_status_within_7_days boolean
);


ALTER TABLE public.data_voix_data OWNER TO postgres;

--
-- Name: data_voix_data_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.data_voix_data_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.data_voix_data_id_seq OWNER TO postgres;

--
-- Name: data_voix_data_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.data_voix_data_id_seq OWNED BY public.data_voix_data.id;


--
-- Name: data_voix_subscriber_details; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.data_voix_subscriber_details (
    id integer NOT NULL,
    agent_name character varying(255) NOT NULL,
    agent_number character varying(255) NOT NULL,
    ok_count integer NOT NULL,
    nok_count integer NOT NULL,
    total_activation integer NOT NULL,
    total_deposit integer NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.data_voix_subscriber_details OWNER TO postgres;

--
-- Name: data_voix_subscriber_details_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.data_voix_subscriber_details_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.data_voix_subscriber_details_id_seq OWNER TO postgres;

--
-- Name: data_voix_subscriber_details_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.data_voix_subscriber_details_id_seq OWNED BY public.data_voix_subscriber_details.id;


--
-- Name: decoder_configuration; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.decoder_configuration (
    id integer NOT NULL,
    profile_name character varying(255),
    mediation character varying(255) NOT NULL,
    user_name character varying(255),
    user_id character varying(255) NOT NULL,
    download_path character varying(255),
    status character varying(255) DEFAULT 'pending'::character varying NOT NULL,
    error_message text,
    pdu character varying(255) NOT NULL,
    choices jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.decoder_configuration OWNER TO postgres;

--
-- Name: decoder_configuration_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.decoder_configuration_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.decoder_configuration_id_seq OWNER TO postgres;

--
-- Name: decoder_configuration_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.decoder_configuration_id_seq OWNED BY public.decoder_configuration.id;


--
-- Name: distributor_ristournes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.distributor_ristournes (
    id integer NOT NULL,
    prodium bigint,
    linarcels bigint,
    easycom bigint,
    somac bigint,
    d_commercial bigint,
    aftel bigint,
    month integer,
    year integer,
    "createdAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.distributor_ristournes OWNER TO postgres;

--
-- Name: distributor_ristournes_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.distributor_ristournes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.distributor_ristournes_id_seq OWNER TO postgres;

--
-- Name: distributor_ristournes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.distributor_ristournes_id_seq OWNED BY public.distributor_ristournes.id;


--
-- Name: feature_prerequisites; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.feature_prerequisites (
    id integer NOT NULL,
    feature_id integer NOT NULL,
    title character varying(255) NOT NULL,
    description text,
    is_checked boolean DEFAULT false NOT NULL,
    status character varying(255) DEFAULT 'Pending'::character varying NOT NULL,
    "createdAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.feature_prerequisites OWNER TO postgres;

--
-- Name: feature_prerequisites_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.feature_prerequisites_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.feature_prerequisites_id_seq OWNER TO postgres;

--
-- Name: feature_prerequisites_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.feature_prerequisites_id_seq OWNED BY public.feature_prerequisites.id;


--
-- Name: feature_section; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.feature_section (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    key character varying(255) NOT NULL,
    description text,
    is_enable boolean DEFAULT true NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    is_depend integer,
    "createdAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    country character varying(255)
);


ALTER TABLE public.feature_section OWNER TO postgres;

--
-- Name: feature_section_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.feature_section_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.feature_section_id_seq OWNER TO postgres;

--
-- Name: feature_section_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.feature_section_id_seq OWNED BY public.feature_section.id;


--
-- Name: feuil1_metrics; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.feuil1_metrics (
    id integer NOT NULL,
    date date NOT NULL,
    data_usage bigint NOT NULL,
    sms_count bigint NOT NULL,
    voice_usage bigint NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE public.feuil1_metrics OWNER TO postgres;

--
-- Name: feuil1_metrics_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.feuil1_metrics_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.feuil1_metrics_id_seq OWNER TO postgres;

--
-- Name: feuil1_metrics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.feuil1_metrics_id_seq OWNED BY public.feuil1_metrics.id;


--
-- Name: financial_annual_data; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.financial_annual_data (
    id integer NOT NULL,
    financial_type_id integer,
    financial_metric_id integer,
    financial_submetric_id integer,
    date date NOT NULL,
    real_value double precision,
    budget_value double precision,
    actual1_value double precision,
    actual2_value double precision,
    actual3_value double precision,
    last_year_real_value double precision,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    parent_id integer,
    version_id integer
);


ALTER TABLE public.financial_annual_data OWNER TO postgres;

--
-- Name: financial_annual_data_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.financial_annual_data_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.financial_annual_data_id_seq OWNER TO postgres;

--
-- Name: financial_annual_data_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.financial_annual_data_id_seq OWNED BY public.financial_annual_data.id;


--
-- Name: financial_categories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.financial_categories (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    sequence_id integer
);


ALTER TABLE public.financial_categories OWNER TO postgres;

--
-- Name: financial_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.financial_categories_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.financial_categories_id_seq OWNER TO postgres;

--
-- Name: financial_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.financial_categories_id_seq OWNED BY public.financial_categories.id;


--
-- Name: financial_cumulative_data; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.financial_cumulative_data (
    id integer NOT NULL,
    financial_type_id integer,
    financial_metric_id integer,
    financial_submetric_id integer,
    date date NOT NULL,
    real_value double precision,
    budget_value double precision,
    last_year_real_value double precision,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    actual1_value double precision,
    actual2_value double precision,
    actual3_value double precision,
    parent_id integer,
    version_id integer
);


ALTER TABLE public.financial_cumulative_data OWNER TO postgres;

--
-- Name: financial_cumulative_data_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.financial_cumulative_data_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.financial_cumulative_data_id_seq OWNER TO postgres;

--
-- Name: financial_cumulative_data_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.financial_cumulative_data_id_seq OWNED BY public.financial_cumulative_data.id;


--
-- Name: financial_metric; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.financial_metric (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    sequence_id integer NOT NULL,
    financial_type_id integer,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    tbg_key text,
    sage_source_key text
);


ALTER TABLE public.financial_metric OWNER TO postgres;

--
-- Name: financial_metric_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.financial_metric_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.financial_metric_id_seq OWNER TO postgres;

--
-- Name: financial_metric_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.financial_metric_id_seq OWNED BY public.financial_metric.id;


--
-- Name: financial_metrics_data; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.financial_metrics_data (
    id integer NOT NULL,
    financial_type_id integer,
    financial_metric_id integer,
    financial_submetric_id integer,
    date date NOT NULL,
    real_value double precision,
    budget_value double precision,
    actual1_value double precision,
    actual2_value double precision,
    actual3_value double precision,
    last_year_real_value double precision,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    parent_id integer,
    version_id integer,
    delta_value double precision,
    sage_cumul_value bigint
);


ALTER TABLE public.financial_metrics_data OWNER TO postgres;

--
-- Name: financial_metrics_data_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.financial_metrics_data_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.financial_metrics_data_id_seq OWNER TO postgres;

--
-- Name: financial_metrics_data_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.financial_metrics_data_id_seq OWNED BY public.financial_metrics_data.id;


--
-- Name: financial_submetric; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.financial_submetric (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    sequence_id integer NOT NULL,
    financial_metric_id integer,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    tbg_key text,
    sage_source_key text
);


ALTER TABLE public.financial_submetric OWNER TO postgres;

--
-- Name: financial_submetric_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.financial_submetric_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.financial_submetric_id_seq OWNER TO postgres;

--
-- Name: financial_submetric_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.financial_submetric_id_seq OWNED BY public.financial_submetric.id;


--
-- Name: financial_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.financial_types (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    sequence_id integer NOT NULL,
    financial_category_id integer,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    tbg_key text,
    sage_source_key text
);


ALTER TABLE public.financial_types OWNER TO postgres;

--
-- Name: financial_types_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.financial_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.financial_types_id_seq OWNER TO postgres;

--
-- Name: financial_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.financial_types_id_seq OWNED BY public.financial_types.id;


--
-- Name: fixed_commissions_calculation; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.fixed_commissions_calculation (
    id integer NOT NULL,
    commission_type_id integer NOT NULL,
    name character varying(255) NOT NULL,
    commission_rate double precision NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


ALTER TABLE public.fixed_commissions_calculation OWNER TO postgres;

--
-- Name: fixed_commissions_calculation_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.fixed_commissions_calculation_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.fixed_commissions_calculation_id_seq OWNER TO postgres;

--
-- Name: fixed_commissions_calculation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.fixed_commissions_calculation_id_seq OWNED BY public.fixed_commissions_calculation.id;


--
-- Name: health_apps; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.health_apps (
    id integer NOT NULL,
    app_key text NOT NULL,
    name text,
    url text NOT NULL,
    consecutive_failures integer DEFAULT 0 NOT NULL,
    last_alert_at timestamp with time zone,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE public.health_apps OWNER TO postgres;

--
-- Name: health_apps_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.health_apps_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.health_apps_id_seq OWNER TO postgres;

--
-- Name: health_apps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.health_apps_id_seq OWNED BY public.health_apps.id;


--
-- Name: health_checks; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.health_checks (
    id bigint NOT NULL,
    app_id integer NOT NULL,
    check_time timestamp with time zone NOT NULL,
    reported_timestamp timestamp with time zone,
    http_status integer,
    status text,
    status_bool boolean,
    response_time_ms numeric(12,3),
    reported_response_time_ms numeric(12,3),
    url text,
    raw_response jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.health_checks OWNER TO postgres;

--
-- Name: health_checks_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.health_checks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.health_checks_id_seq OWNER TO postgres;

--
-- Name: health_checks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.health_checks_id_seq OWNED BY public.health_checks.id;


--
-- Name: import_sources; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.import_sources (
    id integer NOT NULL,
    file_name character varying(255) NOT NULL,
    report_type character varying(255) NOT NULL,
    month integer NOT NULL,
    year integer NOT NULL,
    status character varying(255) NOT NULL,
    type public.enum_import_sources_type NOT NULL,
    uploaded_type character varying(255),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    file_path character varying(255),
    file_type character varying(255)
);


ALTER TABLE public.import_sources OWNER TO postgres;

--
-- Name: import_sources_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.import_sources_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.import_sources_id_seq OWNER TO postgres;

--
-- Name: import_sources_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.import_sources_id_seq OWNED BY public.import_sources.id;


--
-- Name: lineage_benin; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.lineage_benin (
    id uuid NOT NULL,
    message text,
    filesize double precision,
    vendor_type text,
    base_lineage_id uuid
);


ALTER TABLE public.lineage_benin OWNER TO postgres;

--
-- Name: lineage_mali; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.lineage_mali (
    id uuid NOT NULL,
    message text,
    filesize double precision,
    si_type text,
    network_type text,
    vendor_type text,
    is_encrypted boolean,
    row_count integer,
    base_lineage_id uuid
);


ALTER TABLE public.lineage_mali OWNER TO postgres;

--
-- Name: localization_reference_history; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.localization_reference_history (
    id integer NOT NULL,
    file_name character varying(255) NOT NULL,
    file_path character varying(255) NOT NULL,
    bucket_name character varying(255) DEFAULT 'localization-reference'::character varying NOT NULL,
    uploaded_by_user_id character varying(255) NOT NULL,
    uploaded_by_user_name character varying(255),
    uploaded_at timestamp with time zone NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    release_date timestamp with time zone NOT NULL,
    is_active boolean NOT NULL
);


ALTER TABLE public.localization_reference_history OWNER TO postgres;

--
-- Name: COLUMN localization_reference_history.file_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.localization_reference_history.file_name IS 'Original name of the uploaded file';


--
-- Name: COLUMN localization_reference_history.file_path; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.localization_reference_history.file_path IS 'Full path (object key) in the MinIO bucket';


--
-- Name: COLUMN localization_reference_history.bucket_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.localization_reference_history.bucket_name IS 'MinIO bucket name';


--
-- Name: COLUMN localization_reference_history.uploaded_by_user_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.localization_reference_history.uploaded_by_user_id IS 'ID of the user who uploaded the file';


--
-- Name: COLUMN localization_reference_history.uploaded_by_user_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.localization_reference_history.uploaded_by_user_name IS 'Name or email of the user who uploaded the file';


--
-- Name: COLUMN localization_reference_history.uploaded_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.localization_reference_history.uploaded_at IS 'Date and time of the upload';


--
-- Name: COLUMN localization_reference_history.release_date; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.localization_reference_history.release_date IS 'Date when this localization reference was released';


--
-- Name: COLUMN localization_reference_history.is_active; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.localization_reference_history.is_active IS 'Indicates if this localization reference is active';


--
-- Name: localization_reference_history_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.localization_reference_history_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.localization_reference_history_id_seq OWNER TO postgres;

--
-- Name: localization_reference_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.localization_reference_history_id_seq OWNED BY public.localization_reference_history.id;


--
-- Name: login_events; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.login_events (
    id bigint NOT NULL,
    event_timestamp timestamp with time zone NOT NULL,
    is_login_success boolean DEFAULT false NOT NULL,
    user_id character varying(255),
    username character varying(255),
    is_first_login boolean DEFAULT false NOT NULL,
    user_departments jsonb,
    country character varying(255) NOT NULL,
    failure_reason text,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE public.login_events OWNER TO postgres;

--
-- Name: login_events_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.login_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.login_events_id_seq OWNER TO postgres;

--
-- Name: login_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.login_events_id_seq OWNED BY public.login_events.id;


--
-- Name: mail_recipient_lists; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.mail_recipient_lists (
    id integer NOT NULL,
    email character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


ALTER TABLE public.mail_recipient_lists OWNER TO postgres;

--
-- Name: mail_recipient_lists_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.mail_recipient_lists_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.mail_recipient_lists_id_seq OWNER TO postgres;

--
-- Name: mail_recipient_lists_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.mail_recipient_lists_id_seq OWNED BY public.mail_recipient_lists.id;


--
-- Name: modules; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.modules (
    id integer NOT NULL,
    key character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    category character varying(255) NOT NULL,
    is_core boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.modules OWNER TO postgres;

--
-- Name: COLUMN modules.category; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.modules.category IS 'e.g. tbg, reporting, archive';


--
-- Name: COLUMN modules.is_core; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.modules.is_core IS 'Core modules cannot be disabled';


--
-- Name: modules_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.modules_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.modules_id_seq OWNER TO postgres;

--
-- Name: modules_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.modules_id_seq OWNED BY public.modules.id;


--
-- Name: monthly_evolution; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.monthly_evolution (
    id integer NOT NULL,
    month integer NOT NULL,
    current_year integer NOT NULL,
    ca_global double precision,
    ca_voix_globale double precision,
    ca_voix_classique double precision,
    ca_forfaits_voix double precision,
    ca_pass_bonus double precision,
    ca_data double precision,
    autres_ca double precision,
    rechargement double precision,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone
);


ALTER TABLE public.monthly_evolution OWNER TO postgres;

--
-- Name: monthly_evolution_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.monthly_evolution_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.monthly_evolution_id_seq OWNER TO postgres;

--
-- Name: monthly_evolution_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.monthly_evolution_id_seq OWNED BY public.monthly_evolution.id;


--
-- Name: moov_money_data; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.moov_money_data (
    id integer NOT NULL,
    transaction_date timestamp with time zone NOT NULL,
    msisdn character varying(255),
    transaction_type character varying(255),
    amount bigint,
    amount_status boolean,
    first_operation_date timestamp with time zone,
    unique_trans_status boolean,
    within_7_days_status boolean
);


ALTER TABLE public.moov_money_data OWNER TO postgres;

--
-- Name: moov_money_data_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.moov_money_data_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.moov_money_data_id_seq OWNER TO postgres;

--
-- Name: moov_money_data_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.moov_money_data_id_seq OWNED BY public.moov_money_data.id;


--
-- Name: moov_money_reactivation_data; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.moov_money_reactivation_data (
    id integer NOT NULL,
    report_date timestamp with time zone NOT NULL,
    department character varying(255),
    commune character varying(255),
    district character varying(255),
    subscriber_number character varying(255),
    agent_name character varying(255),
    agent_number character varying(255),
    transaction_amount bigint,
    matching_status boolean
);


ALTER TABLE public.moov_money_reactivation_data OWNER TO postgres;

--
-- Name: moov_money_reactivation_data_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.moov_money_reactivation_data_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.moov_money_reactivation_data_id_seq OWNER TO postgres;

--
-- Name: moov_money_reactivation_data_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.moov_money_reactivation_data_id_seq OWNED BY public.moov_money_reactivation_data.id;


--
-- Name: moov_money_subscriber_details; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.moov_money_subscriber_details (
    id integer NOT NULL,
    agent_name character varying(255) NOT NULL,
    agent_number character varying(255) NOT NULL,
    ok_count integer NOT NULL,
    nok_count integer NOT NULL,
    total_trans integer NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.moov_money_subscriber_details OWNER TO postgres;

--
-- Name: moov_money_subscriber_details_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.moov_money_subscriber_details_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.moov_money_subscriber_details_id_seq OWNER TO postgres;

--
-- Name: moov_money_subscriber_details_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.moov_money_subscriber_details_id_seq OWNED BY public.moov_money_subscriber_details.id;


--
-- Name: moyenne_jour; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.moyenne_jour (
    id integer NOT NULL,
    month integer NOT NULL,
    year integer NOT NULL,
    ca_global double precision,
    ca_voix_classique double precision,
    ca_forfaits_voix double precision,
    ca_pass_bonus double precision,
    ca_data double precision,
    moov_saya double precision,
    autres double precision,
    rechargement double precision,
    parc_attache double precision,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone
);


ALTER TABLE public.moyenne_jour OWNER TO postgres;

--
-- Name: moyenne_jour_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.moyenne_jour_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.moyenne_jour_id_seq OWNER TO postgres;

--
-- Name: moyenne_jour_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.moyenne_jour_id_seq OWNED BY public.moyenne_jour.id;


--
-- Name: navigation_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.navigation_items (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    name_key character varying(255) NOT NULL,
    parent_id integer,
    level public.enum_navigation_items_level NOT NULL,
    actions character varying(255)[],
    sequence_id integer NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.navigation_items OWNER TO postgres;

--
-- Name: navigation_items_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.navigation_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.navigation_items_id_seq OWNER TO postgres;

--
-- Name: navigation_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.navigation_items_id_seq OWNED BY public.navigation_items.id;


--
-- Name: network_registry; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.network_registry (
    id integer NOT NULL,
    network_type character varying(255) NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE public.network_registry OWNER TO postgres;

--
-- Name: network_registry_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.network_registry_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.network_registry_id_seq OWNER TO postgres;

--
-- Name: network_registry_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.network_registry_id_seq OWNED BY public.network_registry.id;


--
-- Name: nifi_connection_ids; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.nifi_connection_ids (
    id integer NOT NULL,
    stage_id integer NOT NULL,
    connection_ids text[] NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


ALTER TABLE public.nifi_connection_ids OWNER TO postgres;

--
-- Name: nifi_connection_ids_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.nifi_connection_ids_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.nifi_connection_ids_id_seq OWNER TO postgres;

--
-- Name: nifi_connection_ids_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.nifi_connection_ids_id_seq OWNED BY public.nifi_connection_ids.id;


--
-- Name: notification_tracking; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.notification_tracking (
    id integer NOT NULL,
    user_id character varying(100) NOT NULL,
    user_name character varying(100),
    user_email character varying(100),
    upload_tbg_file_type_id integer NOT NULL,
    month character varying(2) NOT NULL,
    year integer NOT NULL,
    deadline_day integer NOT NULL,
    status public.enum_notification_tracking_status DEFAULT 'pending'::public.enum_notification_tracking_status NOT NULL,
    is_read boolean DEFAULT false NOT NULL,
    is_read_admin boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.notification_tracking OWNER TO postgres;

--
-- Name: notification_tracking_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.notification_tracking_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.notification_tracking_id_seq OWNER TO postgres;

--
-- Name: notification_tracking_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.notification_tracking_id_seq OWNED BY public.notification_tracking.id;


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.notifications (
    id integer NOT NULL,
    feature_type character varying(255) NOT NULL,
    feature_id integer NOT NULL,
    title character varying(255) NOT NULL,
    description text,
    actor_id character varying(255),
    actor_name character varying(255),
    user_id character varying(255) NOT NULL,
    user_name character varying(255) NOT NULL,
    is_read public.enum_notifications_is_read DEFAULT 'unread'::public.enum_notifications_is_read NOT NULL,
    status public.enum_notifications_status,
    extra_data jsonb,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.notifications OWNER TO postgres;

--
-- Name: notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.notifications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.notifications_id_seq OWNER TO postgres;

--
-- Name: notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.notifications_id_seq OWNED BY public.notifications.id;


--
-- Name: paygo_data; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.paygo_data (
    id integer NOT NULL,
    date date,
    ttc integer,
    ht integer,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.paygo_data OWNER TO postgres;

--
-- Name: paygo_data_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.paygo_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.paygo_data_id_seq OWNER TO postgres;

--
-- Name: paygo_data_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.paygo_data_id_seq OWNED BY public.paygo_data.id;


--
-- Name: portal_settings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.portal_settings (
    id integer NOT NULL,
    time_in_mins integer DEFAULT 60 NOT NULL,
    emails jsonb NOT NULL,
    retry_threshold integer DEFAULT 3 NOT NULL,
    alert_cooldown_mins integer DEFAULT 60 NOT NULL,
    country character varying(100) NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE public.portal_settings OWNER TO postgres;

--
-- Name: portal_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.portal_settings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.portal_settings_id_seq OWNER TO postgres;

--
-- Name: portal_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.portal_settings_id_seq OWNED BY public.portal_settings.id;


--
-- Name: prefix_history; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.prefix_history (
    id integer NOT NULL,
    operator_id integer NOT NULL,
    old_value character varying(255),
    new_value character varying(255),
    changed_by character varying(255) NOT NULL,
    action character varying(255),
    changed_at timestamp with time zone NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    old_prefix_value character varying(255)
);


ALTER TABLE public.prefix_history OWNER TO postgres;

--
-- Name: prefix_history_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.prefix_history_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.prefix_history_id_seq OWNER TO postgres;

--
-- Name: prefix_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.prefix_history_id_seq OWNED BY public.prefix_history.id;


--
-- Name: prepaid_plan; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.prepaid_plan (
    id integer NOT NULL,
    plan_name character varying(255) NOT NULL,
    sequence_id integer NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE public.prepaid_plan OWNER TO postgres;

--
-- Name: prepaid_plan_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.prepaid_plan_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.prepaid_plan_id_seq OWNER TO postgres;

--
-- Name: prepaid_plan_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.prepaid_plan_id_seq OWNED BY public.prepaid_plan.id;


--
-- Name: primes_promoteur_calculation; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.primes_promoteur_calculation (
    id integer NOT NULL,
    prime_code character varying(255),
    critere text,
    unite_quantite text,
    valeur_par_unite numeric,
    seuil_min numeric,
    seuil_max numeric,
    valeur_unitaire numeric,
    "createdAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.primes_promoteur_calculation OWNER TO postgres;

--
-- Name: primes_promoteur_calculation_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.primes_promoteur_calculation_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.primes_promoteur_calculation_id_seq OWNER TO postgres;

--
-- Name: primes_promoteur_calculation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.primes_promoteur_calculation_id_seq OWNED BY public.primes_promoteur_calculation.id;


--
-- Name: primes_promoteur_nord; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.primes_promoteur_nord (
    id integer NOT NULL,
    seuil_min numeric NOT NULL,
    seuil_max numeric NOT NULL,
    "createdAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.primes_promoteur_nord OWNER TO postgres;

--
-- Name: primes_promoteur_nord_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.primes_promoteur_nord_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.primes_promoteur_nord_id_seq OWNER TO postgres;

--
-- Name: primes_promoteur_nord_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.primes_promoteur_nord_id_seq OWNED BY public.primes_promoteur_nord.id;


--
-- Name: ratio_conso_segment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ratio_conso_segment (
    id integer NOT NULL,
    segment_date_id integer,
    poids_data_dans_conso_pass_bonus double precision,
    ca_data_global double precision,
    ca_data_souscriptions double precision,
    ca_data_dans_pass_mixte double precision,
    ca_data_paygo double precision,
    cumul_ca_data double precision,
    budget_data_prepaid double precision,
    var_ca_data_vs_budget double precision,
    gap_data double precision,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.ratio_conso_segment OWNER TO postgres;

--
-- Name: ratio_conso_segment_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ratio_conso_segment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.ratio_conso_segment_id_seq OWNER TO postgres;

--
-- Name: ratio_conso_segment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ratio_conso_segment_id_seq OWNED BY public.ratio_conso_segment.id;


--
-- Name: realisation_budget_segment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.realisation_budget_segment (
    id integer NOT NULL,
    segment_date_id integer,
    ca_global_ht double precision,
    budget_journalier double precision,
    taux_de_realisation double precision,
    ca_global_cumule double precision,
    budget_journalier_cumule double precision,
    taux_de_realisation_cumule double precision,
    ca_global_cumule_mensuel double precision,
    budget_mensuel double precision,
    taux_de_realisation_mensuel double precision,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.realisation_budget_segment OWNER TO postgres;

--
-- Name: realisation_budget_segment_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.realisation_budget_segment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.realisation_budget_segment_id_seq OWNER TO postgres;

--
-- Name: realisation_budget_segment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.realisation_budget_segment_id_seq OWNED BY public.realisation_budget_segment.id;


--
-- Name: realised_cashflow; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.realised_cashflow (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    sequence_id integer
);


ALTER TABLE public.realised_cashflow OWNER TO postgres;

--
-- Name: realised_cashflow_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.realised_cashflow_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.realised_cashflow_id_seq OWNER TO postgres;

--
-- Name: realised_cashflow_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.realised_cashflow_id_seq OWNED BY public.realised_cashflow.id;


--
-- Name: resource_monthly_values; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.resource_monthly_values (
    id integer NOT NULL,
    resource_type_id integer NOT NULL,
    resource_subtype_id integer,
    year integer NOT NULL,
    month character varying(255) NOT NULL,
    value integer,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.resource_monthly_values OWNER TO postgres;

--
-- Name: resource_monthly_values_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.resource_monthly_values_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.resource_monthly_values_id_seq OWNER TO postgres;

--
-- Name: resource_monthly_values_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.resource_monthly_values_id_seq OWNED BY public.resource_monthly_values.id;


--
-- Name: resource_subtype; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.resource_subtype (
    id integer NOT NULL,
    resource_type_id integer NOT NULL,
    subtype_name character varying(255) NOT NULL,
    sequence_id integer NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.resource_subtype OWNER TO postgres;

--
-- Name: resource_subtype_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.resource_subtype_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.resource_subtype_id_seq OWNER TO postgres;

--
-- Name: resource_subtype_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.resource_subtype_id_seq OWNED BY public.resource_subtype.id;


--
-- Name: resource_type; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.resource_type (
    id integer NOT NULL,
    type_name character varying(255) NOT NULL,
    sequence_id integer NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.resource_type OWNER TO postgres;

--
-- Name: resource_type_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.resource_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.resource_type_id_seq OWNER TO postgres;

--
-- Name: resource_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.resource_type_id_seq OWNED BY public.resource_type.id;


--
-- Name: revenue_metadata; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.revenue_metadata (
    id integer NOT NULL,
    raw_data_id integer,
    pay_go_id integer,
    feuil5_id integer,
    feuil1_id integer,
    status character varying(255) DEFAULT 'pending'::character varying NOT NULL,
    date date NOT NULL,
    error_message text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    user_id character varying(255),
    user_name character varying(255),
    notification_id integer
);


ALTER TABLE public.revenue_metadata OWNER TO postgres;

--
-- Name: revenue_metadata_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.revenue_metadata_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.revenue_metadata_id_seq OWNER TO postgres;

--
-- Name: revenue_metadata_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.revenue_metadata_id_seq OWNED BY public.revenue_metadata.id;


--
-- Name: revenue_raw_data; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.revenue_raw_data (
    id integer NOT NULL,
    jour character varying(255),
    date date NOT NULL,
    observations character varying(255),
    ca_global double precision,
    ca_voix_classique double precision,
    ca_forfaits_voix double precision,
    ca_pass_bonus double precision,
    ca_data double precision,
    moov_sayaa double precision,
    autres double precision,
    rechargement double precision,
    ratio_conso_rechargement double precision,
    parc_abonnes_global integer,
    parc_journalier integer,
    gross_add integer,
    churn integer,
    net_add integer,
    reconnexions integer,
    ratio_reconnexions_gross_add double precision,
    parc_attache integer,
    parc_global_data integer,
    parc_attache_data integer,
    parc_data_2g integer,
    parc_data_3g integer,
    parc_data_4g integer,
    trafic_voix double precision,
    trafic_data_ko double precision,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.revenue_raw_data OWNER TO postgres;

--
-- Name: revenue_raw_data_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.revenue_raw_data_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.revenue_raw_data_id_seq OWNER TO postgres;

--
-- Name: revenue_raw_data_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.revenue_raw_data_id_seq OWNED BY public.revenue_raw_data.id;


--
-- Name: revenue_uploaded_files; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.revenue_uploaded_files (
    id integer NOT NULL,
    file_name character varying(255) NOT NULL,
    type character varying(255) NOT NULL,
    date timestamp with time zone,
    status text,
    file_path character varying(255) NOT NULL,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone
);


ALTER TABLE public.revenue_uploaded_files OWNER TO postgres;

--
-- Name: revenue_uploaded_files_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.revenue_uploaded_files_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.revenue_uploaded_files_id_seq OWNER TO postgres;

--
-- Name: revenue_uploaded_files_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.revenue_uploaded_files_id_seq OWNED BY public.revenue_uploaded_files.id;


--
-- Name: roaming_comite_history; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.roaming_comite_history (
    id integer NOT NULL,
    operator_id integer NOT NULL,
    old_value character varying(255),
    old_prefix_value text[] NOT NULL,
    new_value character varying(255),
    action character varying(255),
    changed_by character varying(255) NOT NULL,
    changed_at timestamp with time zone DEFAULT now() NOT NULL,
    "createdAt" timestamp with time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.roaming_comite_history OWNER TO postgres;

--
-- Name: roaming_comite_history_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.roaming_comite_history_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.roaming_comite_history_id_seq OWNER TO postgres;

--
-- Name: roaming_comite_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.roaming_comite_history_id_seq OWNED BY public.roaming_comite_history.id;


--
-- Name: roaming_comitie; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.roaming_comitie (
    id integer NOT NULL,
    operator character varying(255) NOT NULL,
    "outgoingTrunks" text[] DEFAULT ARRAY[]::text[],
    "incomingTrunks" text[] DEFAULT ARRAY[]::text[],
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    release_date timestamp with time zone
);


ALTER TABLE public.roaming_comitie OWNER TO postgres;

--
-- Name: COLUMN roaming_comitie.release_date; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.roaming_comitie.release_date IS 'Date when this roaming committee configuration was released';


--
-- Name: roaming_comitie_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.roaming_comitie_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.roaming_comitie_id_seq OWNER TO postgres;

--
-- Name: roaming_comitie_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.roaming_comitie_id_seq OWNED BY public.roaming_comitie.id;


--
-- Name: roaming_prefix; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.roaming_prefix (
    id integer NOT NULL,
    operator character varying(255) NOT NULL,
    prefixes text[] NOT NULL,
    mccmnc character varying(255) NOT NULL,
    "createdAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    release_date timestamp with time zone NOT NULL
);


ALTER TABLE public.roaming_prefix OWNER TO postgres;

--
-- Name: COLUMN roaming_prefix.release_date; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.roaming_prefix.release_date IS 'Date when this roaming prefix configuration was released';


--
-- Name: roaming_prefix_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.roaming_prefix_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.roaming_prefix_id_seq OWNER TO postgres;

--
-- Name: roaming_prefix_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.roaming_prefix_id_seq OWNED BY public.roaming_prefix.id;


--
-- Name: sage_yexptdb; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sage_yexptdb (
    updtick_0 text,
    txsnam_0 text,
    version_0 text,
    lig_0 text,
    col_0 text,
    ind_0 text,
    amtval_0 text,
    amtdeb_0 text,
    amtcdt_0 text,
    updval_0 text,
    fcy_0 text,
    coa_0 text,
    acc_0 text,
    bpr_0 text,
    die1_0 text,
    die2_0 text,
    die3_0 text,
    die4_0 text,
    die5_0 text,
    die6_0 text,
    die7_0 text,
    die8_0 text,
    die9_0 text,
    cce1_0 text,
    cce2_0 text,
    cce3_0 text,
    cce4_0 text,
    cce5_0 text,
    cce6_0 text,
    cce7_0 text,
    cce8_0 text,
    cce9_0 text,
    fcyinf_0 text,
    accinf_0 text,
    bprinf_0 text,
    cceinf_0 text,
    typamt_0 text,
    ymode_0 text,
    ymois_0 text,
    yannee_0 text,
    yperiod_0 text,
    strdat_0 text,
    enddat_0 text,
    credat_0 text,
    credattim_0 text,
    upddattim_0 text,
    auuid_0 text,
    creusr_0 text,
    updusr_0 text,
    sage_version character varying(255)
);


ALTER TABLE public.sage_yexptdb OWNER TO postgres;

--
-- Name: segment_date; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.segment_date (
    id integer NOT NULL,
    day character varying(255),
    date date,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.segment_date OWNER TO postgres;

--
-- Name: segment_date_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.segment_date_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.segment_date_id_seq OWNER TO postgres;

--
-- Name: segment_date_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.segment_date_id_seq OWNED BY public.segment_date.id;


--
-- Name: si_registry; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.si_registry (
    id integer NOT NULL,
    si_type character varying(255) NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE public.si_registry OWNER TO postgres;

--
-- Name: si_registry_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.si_registry_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.si_registry_id_seq OWNER TO postgres;

--
-- Name: si_registry_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.si_registry_id_seq OWNED BY public.si_registry.id;


--
-- Name: smtp_details; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.smtp_details (
    id integer NOT NULL,
    host character varying(255) NOT NULL,
    port character varying(255) NOT NULL,
    "user" character varying(255) NOT NULL,
    password character varying(255) NOT NULL,
    from_email character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.smtp_details OWNER TO postgres;

--
-- Name: smtp_details_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.smtp_details_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.smtp_details_id_seq OWNER TO postgres;

--
-- Name: smtp_details_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.smtp_details_id_seq OWNED BY public.smtp_details.id;


--
-- Name: standard_impact; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.standard_impact (
    id integer NOT NULL,
    standard_id character varying(255),
    standard_name character varying(255) NOT NULL,
    sequence_id integer NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.standard_impact OWNER TO postgres;

--
-- Name: standard_impact_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.standard_impact_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.standard_impact_id_seq OWNER TO postgres;

--
-- Name: standard_impact_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.standard_impact_id_seq OWNED BY public.standard_impact.id;


--
-- Name: standard_impact_monthly_values; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.standard_impact_monthly_values (
    id integer NOT NULL,
    standard_impact_id integer NOT NULL,
    year integer NOT NULL,
    month character varying(255) NOT NULL,
    value integer,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.standard_impact_monthly_values OWNER TO postgres;

--
-- Name: standard_impact_monthly_values_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.standard_impact_monthly_values_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.standard_impact_monthly_values_id_seq OWNER TO postgres;

--
-- Name: standard_impact_monthly_values_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.standard_impact_monthly_values_id_seq OWNED BY public.standard_impact_monthly_values.id;


--
-- Name: superset_dashboard; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.superset_dashboard (
    id integer NOT NULL,
    dashboard_id character varying(255) NOT NULL,
    dashboard_uuid character varying(255),
    name character varying(255) NOT NULL,
    description character varying(255),
    key character varying(255),
    "createdAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.superset_dashboard OWNER TO postgres;

--
-- Name: superset_dashboard_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.superset_dashboard_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.superset_dashboard_id_seq OWNER TO postgres;

--
-- Name: superset_dashboard_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.superset_dashboard_id_seq OWNED BY public.superset_dashboard.id;


--
-- Name: tbg_alerts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tbg_alerts (
    id integer NOT NULL,
    notification_id integer,
    user_id character varying(100) NOT NULL,
    upload_tbg_file_type_id integer NOT NULL,
    month character varying(2) NOT NULL,
    year integer NOT NULL,
    deadline_day integer NOT NULL,
    is_read_admin boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.tbg_alerts OWNER TO postgres;

--
-- Name: tbg_alerts_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tbg_alerts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tbg_alerts_id_seq OWNER TO postgres;

--
-- Name: tbg_alerts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tbg_alerts_id_seq OWNED BY public.tbg_alerts.id;


--
-- Name: tbg_calculation_category_fields; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tbg_calculation_category_fields (
    id integer NOT NULL,
    input_type character varying(255) NOT NULL,
    label character varying(255) NOT NULL,
    parent_id integer,
    is_parent boolean DEFAULT false NOT NULL,
    "createdAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.tbg_calculation_category_fields OWNER TO postgres;

--
-- Name: tbg_calculation_category_fields_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tbg_calculation_category_fields_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tbg_calculation_category_fields_id_seq OWNER TO postgres;

--
-- Name: tbg_calculation_category_fields_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tbg_calculation_category_fields_id_seq OWNED BY public.tbg_calculation_category_fields.id;


--
-- Name: tbg_calculation_fields; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tbg_calculation_fields (
    id integer NOT NULL,
    month integer NOT NULL,
    year integer NOT NULL,
    input_value numeric NOT NULL,
    input_field_id integer NOT NULL,
    tbg_version_id integer NOT NULL,
    "createdAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.tbg_calculation_fields OWNER TO postgres;

--
-- Name: tbg_calculation_fields_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tbg_calculation_fields_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tbg_calculation_fields_id_seq OWNER TO postgres;

--
-- Name: tbg_calculation_fields_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tbg_calculation_fields_id_seq OWNED BY public.tbg_calculation_fields.id;


--
-- Name: tbg_calculation_fields_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tbg_calculation_fields_types (
    id integer NOT NULL,
    cat_type_id integer NOT NULL,
    label character varying(255) NOT NULL,
    key character varying(255) NOT NULL,
    tbg_key character varying(255) NOT NULL,
    "createdAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.tbg_calculation_fields_types OWNER TO postgres;

--
-- Name: tbg_calculation_fields_types_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tbg_calculation_fields_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tbg_calculation_fields_types_id_seq OWNER TO postgres;

--
-- Name: tbg_calculation_fields_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tbg_calculation_fields_types_id_seq OWNED BY public.tbg_calculation_fields_types.id;


--
-- Name: tbg_capex_project_details; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tbg_capex_project_details (
    id integer NOT NULL,
    file_name character varying(255),
    file_path character varying(255),
    uploaded_date timestamp with time zone,
    status character varying(255),
    error_message text,
    uploaded_by character varying(255),
    month integer,
    year integer,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.tbg_capex_project_details OWNER TO postgres;

--
-- Name: tbg_capex_project_details_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tbg_capex_project_details_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tbg_capex_project_details_id_seq OWNER TO postgres;

--
-- Name: tbg_capex_project_details_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tbg_capex_project_details_id_seq OWNED BY public.tbg_capex_project_details.id;


--
-- Name: tbg_formula_edit_history; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tbg_formula_edit_history (
    id integer NOT NULL,
    tbg_formula_id integer,
    tbg_key character varying(255) NOT NULL,
    formula_type character varying(255) NOT NULL,
    user_id character varying(255) NOT NULL,
    user_name character varying(255) NOT NULL,
    previous_data jsonb,
    updated_data jsonb NOT NULL,
    status character varying(50) NOT NULL,
    error_message text,
    description text,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.tbg_formula_edit_history OWNER TO postgres;

--
-- Name: tbg_formula_edit_history_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tbg_formula_edit_history_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tbg_formula_edit_history_id_seq OWNER TO postgres;

--
-- Name: tbg_formula_edit_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tbg_formula_edit_history_id_seq OWNED BY public.tbg_formula_edit_history.id;


--
-- Name: tbg_formulas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tbg_formulas (
    id integer NOT NULL,
    tbg_key character varying(255) NOT NULL,
    report_type_id character varying(255),
    formula_type character varying(255) NOT NULL,
    account_details jsonb,
    include_sage boolean,
    formula character varying(255),
    is_adjustable boolean,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    sequence integer
);


ALTER TABLE public.tbg_formulas OWNER TO postgres;

--
-- Name: tbg_formulas_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tbg_formulas_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tbg_formulas_id_seq OWNER TO postgres;

--
-- Name: tbg_formulas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tbg_formulas_id_seq OWNED BY public.tbg_formulas.id;


--
-- Name: tbg_reel_status_history; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tbg_reel_status_history (
    id integer NOT NULL,
    user_id character varying(150) NOT NULL,
    user_name character varying(150) NOT NULL,
    reel_edits jsonb DEFAULT '[]'::jsonb NOT NULL,
    reel_type character varying(50) NOT NULL,
    report_name character varying(50) NOT NULL,
    status character varying(50) NOT NULL,
    error_message text,
    description text,
    month character varying(2) NOT NULL,
    year integer NOT NULL,
    tbg_version character varying(50),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    notification_id integer,
    is_delta boolean
);


ALTER TABLE public.tbg_reel_status_history OWNER TO postgres;

--
-- Name: tbg_reel_status_history_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tbg_reel_status_history_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tbg_reel_status_history_id_seq OWNER TO postgres;

--
-- Name: tbg_reel_status_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tbg_reel_status_history_id_seq OWNED BY public.tbg_reel_status_history.id;


--
-- Name: tbg_report_request; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tbg_report_request (
    id integer NOT NULL,
    tbg_name character varying(255) NOT NULL,
    description text NOT NULL,
    month integer NOT NULL,
    year integer NOT NULL,
    "user" character varying(255) NOT NULL,
    export_status character varying(255) DEFAULT 'pending'::character varying NOT NULL,
    status character varying(255) DEFAULT 'pending'::character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    tbg_version_id integer,
    files jsonb,
    user_id character varying(255),
    notification_id integer,
    is_regenerate boolean DEFAULT false NOT NULL,
    is_hide boolean DEFAULT false NOT NULL,
    regeneration_history jsonb
);


ALTER TABLE public.tbg_report_request OWNER TO postgres;

--
-- Name: tbg_report_request_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tbg_report_request_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tbg_report_request_id_seq OWNER TO postgres;

--
-- Name: tbg_report_request_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tbg_report_request_id_seq OWNED BY public.tbg_report_request.id;


--
-- Name: tbg_report_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tbg_report_types (
    id integer NOT NULL,
    label character varying(100) NOT NULL,
    report_key character varying(100) NOT NULL,
    category public.enum_tbg_report_types_category NOT NULL,
    parent_id integer,
    file_verification_id integer,
    display_label character varying(150),
    is_active boolean DEFAULT true NOT NULL,
    sequence integer,
    visible_months integer[],
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.tbg_report_types OWNER TO postgres;

--
-- Name: COLUMN tbg_report_types.label; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.tbg_report_types.label IS 'Display label shown in the UI, e.g. Extractions, CA Mobile';


--
-- Name: COLUMN tbg_report_types.report_key; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.tbg_report_types.report_key IS 'Unique code-level key used for mapping, e.g. MARGE_BRUTE_EXTRACTIONS, Realise_DETTE_NETTE';


--
-- Name: COLUMN tbg_report_types.category; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.tbg_report_types.category IS 'Category of the report type: Reel, Budget, or Actual';


--
-- Name: COLUMN tbg_report_types.parent_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.tbg_report_types.parent_id IS 'Self-referencing FK for parent-child relationships, e.g. DETTE_NETTE -> Realise';


--
-- Name: COLUMN tbg_report_types.file_verification_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.tbg_report_types.file_verification_id IS 'FK to file_verifications table';


--
-- Name: COLUMN tbg_report_types.display_label; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.tbg_report_types.display_label IS 'Human-friendly display name for missing-report messages';


--
-- Name: COLUMN tbg_report_types.sequence; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.tbg_report_types.sequence IS 'Display order within same category';


--
-- Name: COLUMN tbg_report_types.visible_months; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.tbg_report_types.visible_months IS 'Array of month numbers (1-12) in which this report type is visible/required, null means always visible';


--
-- Name: tbg_report_types_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tbg_report_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tbg_report_types_id_seq OWNER TO postgres;

--
-- Name: tbg_report_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tbg_report_types_id_seq OWNED BY public.tbg_report_types.id;


--
-- Name: tbg_version; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tbg_version (
    id integer NOT NULL,
    version_name character varying(255) NOT NULL,
    description text,
    month integer NOT NULL,
    year integer NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    is_default boolean DEFAULT false NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    export_status character varying(255),
    user_id character varying(255),
    user_name character varying(255),
    notification_id integer,
    get_delta character varying(255),
    delta_error text,
    is_generate_delta boolean DEFAULT false,
    delta_user_id character varying(255),
    delta_user_name character varying(255),
    delta_notification_id integer
);


ALTER TABLE public.tbg_version OWNER TO postgres;

--
-- Name: tbg_version_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tbg_version_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tbg_version_id_seq OWNER TO postgres;

--
-- Name: tbg_version_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tbg_version_id_seq OWNED BY public.tbg_version.id;


--
-- Name: telecom_metric; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.telecom_metric (
    id integer NOT NULL,
    plan_name_id integer NOT NULL,
    metric_name character varying(255) NOT NULL,
    sequence_id integer NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE public.telecom_metric OWNER TO postgres;

--
-- Name: telecom_metric_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.telecom_metric_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.telecom_metric_id_seq OWNER TO postgres;

--
-- Name: telecom_metric_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.telecom_metric_id_seq OWNED BY public.telecom_metric.id;


--
-- Name: telecom_metric_values; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.telecom_metric_values (
    id integer NOT NULL,
    telecom_metric_id integer,
    month integer NOT NULL,
    year integer NOT NULL,
    value double precision NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    prepaid_plan_id integer
);


ALTER TABLE public.telecom_metric_values OWNER TO postgres;

--
-- Name: telecom_metric_values_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.telecom_metric_values_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.telecom_metric_values_id_seq OWNER TO postgres;

--
-- Name: telecom_metric_values_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.telecom_metric_values_id_seq OWNED BY public.telecom_metric_values.id;


--
-- Name: theme_configurations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.theme_configurations (
    id character varying(50) NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    user_id character varying(50),
    primary_color character varying(7) NOT NULL,
    secondary_color character varying(7) NOT NULL,
    background_color character varying(7) NOT NULL,
    colors json NOT NULL,
    is_default boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.theme_configurations OWNER TO postgres;

--
-- Name: COLUMN theme_configurations.colors; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.theme_configurations.colors IS 'Complete color configuration object with nested properties';


--
-- Name: COLUMN theme_configurations.is_default; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.theme_configurations.is_default IS 'Whether this theme is the default theme for the user';


--
-- Name: tva_aib_calculation; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tva_aib_calculation (
    id integer NOT NULL,
    tva double precision NOT NULL,
    aib double precision NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


ALTER TABLE public.tva_aib_calculation OWNER TO postgres;

--
-- Name: tva_aib_calculation_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tva_aib_calculation_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tva_aib_calculation_id_seq OWNER TO postgres;

--
-- Name: tva_aib_calculation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tva_aib_calculation_id_seq OWNED BY public.tva_aib_calculation.id;


--
-- Name: upload_component_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.upload_component_types (
    id integer NOT NULL,
    name text NOT NULL,
    description text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE public.upload_component_types OWNER TO postgres;

--
-- Name: upload_component_types_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.upload_component_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.upload_component_types_id_seq OWNER TO postgres;

--
-- Name: upload_component_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.upload_component_types_id_seq OWNED BY public.upload_component_types.id;


--
-- Name: upload_data; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.upload_data (
    id integer NOT NULL,
    report character varying(255) NOT NULL,
    value character varying(255) NOT NULL,
    year integer NOT NULL,
    month integer,
    file_name character varying(255) NOT NULL,
    file_size integer NOT NULL,
    path character varying(255),
    additional_file_name character varying(255),
    additional_file_size integer,
    additional_path character varying(255),
    status character varying(255) DEFAULT 'pending'::character varying NOT NULL,
    message text,
    uploaded_by character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.upload_data OWNER TO postgres;

--
-- Name: upload_data_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.upload_data_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.upload_data_id_seq OWNER TO postgres;

--
-- Name: upload_data_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.upload_data_id_seq OWNED BY public.upload_data.id;


--
-- Name: upload_sheet_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.upload_sheet_types (
    id integer NOT NULL,
    component_id integer NOT NULL,
    name text NOT NULL,
    description text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE public.upload_sheet_types OWNER TO postgres;

--
-- Name: upload_sheet_types_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.upload_sheet_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.upload_sheet_types_id_seq OWNER TO postgres;

--
-- Name: upload_sheet_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.upload_sheet_types_id_seq OWNED BY public.upload_sheet_types.id;


--
-- Name: upload_tbg_file_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.upload_tbg_file_types (
    id integer NOT NULL,
    label character varying(100) NOT NULL,
    category character varying(50) NOT NULL,
    allowed_role character varying(100) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.upload_tbg_file_types OWNER TO postgres;

--
-- Name: upload_tbg_file_types_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.upload_tbg_file_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.upload_tbg_file_types_id_seq OWNER TO postgres;

--
-- Name: upload_tbg_file_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.upload_tbg_file_types_id_seq OWNED BY public.upload_tbg_file_types.id;


--
-- Name: valorization_tariff_history; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.valorization_tariff_history (
    id bigint NOT NULL,
    changed_by_username character varying(255) NOT NULL,
    tariff_id bigint NOT NULL,
    field_changed character varying(255) NOT NULL,
    old_value character varying(255),
    new_value character varying(255),
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE public.valorization_tariff_history OWNER TO postgres;

--
-- Name: valorization_tariff_history_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.valorization_tariff_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.valorization_tariff_history_id_seq OWNER TO postgres;

--
-- Name: valorization_tariff_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.valorization_tariff_history_id_seq OWNED BY public.valorization_tariff_history.id;


--
-- Name: valorization_tariff_schedules; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.valorization_tariff_schedules (
    id bigint NOT NULL,
    tariff_id bigint NOT NULL,
    field_changed character varying(255) NOT NULL,
    scheduled_value text NOT NULL,
    scheduled_by_username character varying(255) NOT NULL,
    effective_at date NOT NULL,
    status character varying(255) DEFAULT 'pending'::character varying NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    user_id character varying(255),
    notification_id integer
);


ALTER TABLE public.valorization_tariff_schedules OWNER TO postgres;

--
-- Name: valorization_tariff_schedules_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.valorization_tariff_schedules_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.valorization_tariff_schedules_id_seq OWNER TO postgres;

--
-- Name: valorization_tariff_schedules_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.valorization_tariff_schedules_id_seq OWNED BY public.valorization_tariff_schedules.id;


--
-- Name: valorization_tariffs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.valorization_tariffs (
    id bigint NOT NULL,
    operator_name character varying(255) NOT NULL,
    tariff_voice numeric(10,2) DEFAULT 0 NOT NULL,
    tariff_sms numeric(10,2) DEFAULT 0 NOT NULL,
    tariff_data numeric(10,2) DEFAULT 0 NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    release_date timestamp with time zone NOT NULL,
    is_active boolean NOT NULL
);


ALTER TABLE public.valorization_tariffs OWNER TO postgres;

--
-- Name: COLUMN valorization_tariffs.release_date; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.valorization_tariffs.release_date IS 'Date when this tariff configuration was released';


--
-- Name: COLUMN valorization_tariffs.is_active; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.valorization_tariffs.is_active IS 'Indicates if this tariff configuration is active';


--
-- Name: valorization_tariffs_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.valorization_tariffs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.valorization_tariffs_id_seq OWNER TO postgres;

--
-- Name: valorization_tariffs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.valorization_tariffs_id_seq OWNED BY public.valorization_tariffs.id;


--
-- Name: vendor_registry; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.vendor_registry (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    network_registry_id integer,
    created_at timestamp with time zone,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE public.vendor_registry OWNER TO postgres;

--
-- Name: vendor_registry_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.vendor_registry_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.vendor_registry_id_seq OWNER TO postgres;

--
-- Name: vendor_registry_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.vendor_registry_id_seq OWNED BY public.vendor_registry.id;


--
-- Name: voix_segment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.voix_segment (
    id integer NOT NULL,
    segment_date_id integer,
    ca_voix_global double precision,
    voix_classique double precision,
    moov_sayaa double precision,
    forfait_voix double precision,
    pass_bonus_voix double precision,
    cumul_ca_voix double precision,
    budget_voix_prepaid double precision,
    var_ca_voix_vs_budget double precision,
    gap_voix double precision,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.voix_segment OWNER TO postgres;

--
-- Name: voix_segment_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.voix_segment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.voix_segment_id_seq OWNER TO postgres;

--
-- Name: voix_segment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.voix_segment_id_seq OWNED BY public.voix_segment.id;


--
-- Name: weekly_evolution; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.weekly_evolution (
    id integer NOT NULL,
    current_week_date date NOT NULL,
    ca_global double precision,
    ca_voix_globale double precision,
    ca_voix_classique double precision,
    ca_forfaits_voix double precision,
    moov_sayaa double precision,
    ca_pass_bonus double precision,
    ca_data double precision,
    autres_ca double precision,
    rechargement double precision,
    trafic_voix double precision,
    trafic_data double precision,
    parc_attache double precision,
    parc_attache_data double precision,
    ratio_consommation_rechargement double precision,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone
);


ALTER TABLE public.weekly_evolution OWNER TO postgres;

--
-- Name: weekly_evolution_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.weekly_evolution_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.weekly_evolution_id_seq OWNER TO postgres;

--
-- Name: weekly_evolution_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.weekly_evolution_id_seq OWNED BY public.weekly_evolution.id;


--
-- Name: yearly_evolution; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.yearly_evolution (
    id integer NOT NULL,
    current_year_date date NOT NULL,
    ca_global double precision,
    ca_voix_globale double precision,
    ca_voix_classique double precision,
    ca_forfaits_voix double precision,
    ca_pass_bonus double precision,
    ca_data double precision,
    autres_ca double precision,
    rechargement double precision,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone
);


ALTER TABLE public.yearly_evolution OWNER TO postgres;

--
-- Name: yearly_evolution_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.yearly_evolution_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.yearly_evolution_id_seq OWNER TO postgres;

--
-- Name: yearly_evolution_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.yearly_evolution_id_seq OWNED BY public.yearly_evolution.id;


--
-- Name: archive_registry id; Type: DEFAULT; Schema: digiwise_schema; Owner: postgres
--

ALTER TABLE ONLY digiwise_schema.archive_registry ALTER COLUMN id SET DEFAULT nextval('digiwise_schema.archive_registry_id_seq'::regclass);


--
-- Name: financial_annual_data id; Type: DEFAULT; Schema: digiwise_schema; Owner: postgres
--

ALTER TABLE ONLY digiwise_schema.financial_annual_data ALTER COLUMN id SET DEFAULT nextval('digiwise_schema.financial_annual_data_id_seq'::regclass);


--
-- Name: financial_categories id; Type: DEFAULT; Schema: digiwise_schema; Owner: postgres
--

ALTER TABLE ONLY digiwise_schema.financial_categories ALTER COLUMN id SET DEFAULT nextval('digiwise_schema.financial_categories_id_seq'::regclass);


--
-- Name: financial_cumulative_data id; Type: DEFAULT; Schema: digiwise_schema; Owner: postgres
--

ALTER TABLE ONLY digiwise_schema.financial_cumulative_data ALTER COLUMN id SET DEFAULT nextval('digiwise_schema.financial_cumulative_data_id_seq'::regclass);


--
-- Name: financial_metric id; Type: DEFAULT; Schema: digiwise_schema; Owner: postgres
--

ALTER TABLE ONLY digiwise_schema.financial_metric ALTER COLUMN id SET DEFAULT nextval('digiwise_schema.financial_metric_id_seq'::regclass);


--
-- Name: financial_metrics_data id; Type: DEFAULT; Schema: digiwise_schema; Owner: postgres
--

ALTER TABLE ONLY digiwise_schema.financial_metrics_data ALTER COLUMN id SET DEFAULT nextval('digiwise_schema.financial_metrics_data_id_seq'::regclass);


--
-- Name: financial_submetric id; Type: DEFAULT; Schema: digiwise_schema; Owner: postgres
--

ALTER TABLE ONLY digiwise_schema.financial_submetric ALTER COLUMN id SET DEFAULT nextval('digiwise_schema.financial_submetric_id_seq'::regclass);


--
-- Name: financial_types id; Type: DEFAULT; Schema: digiwise_schema; Owner: postgres
--

ALTER TABLE ONLY digiwise_schema.financial_types ALTER COLUMN id SET DEFAULT nextval('digiwise_schema.financial_types_id_seq'::regclass);


--
-- Name: network_registry id; Type: DEFAULT; Schema: digiwise_schema; Owner: postgres
--

ALTER TABLE ONLY digiwise_schema.network_registry ALTER COLUMN id SET DEFAULT nextval('digiwise_schema.network_registry_id_seq'::regclass);


--
-- Name: si_registry id; Type: DEFAULT; Schema: digiwise_schema; Owner: postgres
--

ALTER TABLE ONLY digiwise_schema.si_registry ALTER COLUMN id SET DEFAULT nextval('digiwise_schema.si_registry_id_seq'::regclass);


--
-- Name: vendor_registry id; Type: DEFAULT; Schema: digiwise_schema; Owner: postgres
--

ALTER TABLE ONLY digiwise_schema.vendor_registry ALTER COLUMN id SET DEFAULT nextval('digiwise_schema.vendor_registry_id_seq'::regclass);


--
-- Name: DownloadRequests id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."DownloadRequests" ALTER COLUMN id SET DEFAULT nextval('public."DownloadRequests_id_seq"'::regclass);


--
-- Name: activity_events id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activity_events ALTER COLUMN id SET DEFAULT nextval('public.activity_events_id_seq'::regclass);


--
-- Name: alert_notifications id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.alert_notifications ALTER COLUMN id SET DEFAULT nextval('public.alert_notifications_id_seq'::regclass);


--
-- Name: app_icons id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_icons ALTER COLUMN id SET DEFAULT nextval('public.app_icons_id_seq'::regclass);


--
-- Name: archive_registry id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.archive_registry ALTER COLUMN id SET DEFAULT nextval('public.archive_registry_id_seq'::regclass);


--
-- Name: archive_storage_kpis id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.archive_storage_kpis ALTER COLUMN id SET DEFAULT nextval('public.archive_storage_kpis_id_seq'::regclass);


--
-- Name: capex_data id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.capex_data ALTER COLUMN id SET DEFAULT nextval('public.capex_data_id_seq'::regclass);


--
-- Name: capex_projects id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.capex_projects ALTER COLUMN id SET DEFAULT nextval('public.capex_projects_id_seq'::regclass);


--
-- Name: cashflow_categories id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cashflow_categories ALTER COLUMN id SET DEFAULT nextval('public.cashflow_categories_id_seq'::regclass);


--
-- Name: cashflow_data id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cashflow_data ALTER COLUMN id SET DEFAULT nextval('public.cashflow_data_id_seq'::regclass);


--
-- Name: cashflow_sections id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cashflow_sections ALTER COLUMN id SET DEFAULT nextval('public.cashflow_sections_id_seq'::regclass);


--
-- Name: cashflow_subcategories id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cashflow_subcategories ALTER COLUMN id SET DEFAULT nextval('public.cashflow_subcategories_id_seq'::regclass);


--
-- Name: collapse_annual_data id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collapse_annual_data ALTER COLUMN id SET DEFAULT nextval('public.collapse_annual_data_id_seq'::regclass);


--
-- Name: collapse_categories id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collapse_categories ALTER COLUMN id SET DEFAULT nextval('public.collapse_categories_id_seq'::regclass);


--
-- Name: collapse_cumul_data id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collapse_cumul_data ALTER COLUMN id SET DEFAULT nextval('public.collapse_cumul_data_id_seq'::regclass);


--
-- Name: collapse_monthly_data id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collapse_monthly_data ALTER COLUMN id SET DEFAULT nextval('public.collapse_monthly_data_id_seq'::regclass);


--
-- Name: collapse_subcategories id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collapse_subcategories ALTER COLUMN id SET DEFAULT nextval('public.collapse_subcategories_id_seq'::regclass);


--
-- Name: collapse_types id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collapse_types ALTER COLUMN id SET DEFAULT nextval('public.collapse_types_id_seq'::regclass);


--
-- Name: collapsible_items id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collapsible_items ALTER COLUMN id SET DEFAULT nextval('public.collapsible_items_id_seq'::regclass);


--
-- Name: commission_calculation_histories id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.commission_calculation_histories ALTER COLUMN id SET DEFAULT nextval('public.commission_calculation_histories_id_seq'::regclass);


--
-- Name: commission_calculation_rules id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.commission_calculation_rules ALTER COLUMN id SET DEFAULT nextval('public.commission_calculation_rules_id_seq'::regclass);


--
-- Name: commission_calculation_types id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.commission_calculation_types ALTER COLUMN id SET DEFAULT nextval('public.commission_calculation_types_id_seq'::regclass);


--
-- Name: commission_enlevements id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.commission_enlevements ALTER COLUMN id SET DEFAULT nextval('public.commission_enlevements_id_seq'::regclass);


--
-- Name: commission_file_types id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.commission_file_types ALTER COLUMN id SET DEFAULT nextval('public.commission_file_types_id_seq'::regclass);


--
-- Name: commission_files id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.commission_files ALTER COLUMN id SET DEFAULT nextval('public.commission_files_id_seq'::regclass);


--
-- Name: commission_groups id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.commission_groups ALTER COLUMN id SET DEFAULT nextval('public.commission_groups_id_seq'::regclass);


--
-- Name: commission_histories id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.commission_histories ALTER COLUMN id SET DEFAULT nextval('public.commission_histories_id_seq'::regclass);


--
-- Name: commission_subtypes id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.commission_subtypes ALTER COLUMN id SET DEFAULT nextval('public.commission_subtypes_id_seq'::regclass);


--
-- Name: commission_types id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.commission_types ALTER COLUMN id SET DEFAULT nextval('public.commission_types_id_seq'::regclass);


--
-- Name: component_file_upload_rule_sheets id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.component_file_upload_rule_sheets ALTER COLUMN id SET DEFAULT nextval('public.component_file_upload_rule_sheets_id_seq'::regclass);


--
-- Name: configuration id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.configuration ALTER COLUMN id SET DEFAULT nextval('public.configuration_id_seq'::regclass);


--
-- Name: configuration_archive id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.configuration_archive ALTER COLUMN id SET DEFAULT nextval('public.configuration_archive_id_seq'::regclass);


--
-- Name: country_module_configs id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.country_module_configs ALTER COLUMN id SET DEFAULT nextval('public.country_module_configs_id_seq'::regclass);


--
-- Name: data_cormant_metics id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.data_cormant_metics ALTER COLUMN id SET DEFAULT nextval('public.data_cormant_metics_id_seq'::regclass);


--
-- Name: data_cormat_upload_files id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.data_cormat_upload_files ALTER COLUMN id SET DEFAULT nextval('public.data_cormat_upload_files_id_seq'::regclass);


--
-- Name: data_dormant_metadata id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.data_dormant_metadata ALTER COLUMN id SET DEFAULT nextval('public.data_dormant_metadata_id_seq'::regclass);


--
-- Name: data_dormant_metics id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.data_dormant_metics ALTER COLUMN id SET DEFAULT nextval('public.data_dormant_metics_id_seq'::regclass);


--
-- Name: data_dormant_upload_files id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.data_dormant_upload_files ALTER COLUMN id SET DEFAULT nextval('public.data_dormant_upload_files_id_seq'::regclass);


--
-- Name: data_lineage_alerts id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.data_lineage_alerts ALTER COLUMN id SET DEFAULT nextval('public.data_lineage_alerts_id_seq'::regclass);


--
-- Name: data_lineage_configs id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.data_lineage_configs ALTER COLUMN id SET DEFAULT nextval('public.data_lineage_configs_id_seq'::regclass);


--
-- Name: data_lineage_events id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.data_lineage_events ALTER COLUMN id SET DEFAULT nextval('public.data_lineage_events_id_seq'::regclass);


--
-- Name: data_lineage_notification id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.data_lineage_notification ALTER COLUMN id SET DEFAULT nextval('public.data_lineage_notification_id_seq'::regclass);


--
-- Name: data_lineage_stage id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.data_lineage_stage ALTER COLUMN id SET DEFAULT nextval('public.data_lineage_stage_id_seq'::regclass);


--
-- Name: data_voix_auto_rechargement_data id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.data_voix_auto_rechargement_data ALTER COLUMN id SET DEFAULT nextval('public.data_voix_auto_rechargement_data_id_seq'::regclass);


--
-- Name: data_voix_data id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.data_voix_data ALTER COLUMN id SET DEFAULT nextval('public.data_voix_data_id_seq'::regclass);


--
-- Name: data_voix_subscriber_details id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.data_voix_subscriber_details ALTER COLUMN id SET DEFAULT nextval('public.data_voix_subscriber_details_id_seq'::regclass);


--
-- Name: decoder_configuration id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.decoder_configuration ALTER COLUMN id SET DEFAULT nextval('public.decoder_configuration_id_seq'::regclass);


--
-- Name: distributor_ristournes id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.distributor_ristournes ALTER COLUMN id SET DEFAULT nextval('public.distributor_ristournes_id_seq'::regclass);


--
-- Name: feature_prerequisites id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.feature_prerequisites ALTER COLUMN id SET DEFAULT nextval('public.feature_prerequisites_id_seq'::regclass);


--
-- Name: feature_section id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.feature_section ALTER COLUMN id SET DEFAULT nextval('public.feature_section_id_seq'::regclass);


--
-- Name: feuil1_metrics id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.feuil1_metrics ALTER COLUMN id SET DEFAULT nextval('public.feuil1_metrics_id_seq'::regclass);


--
-- Name: financial_annual_data id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.financial_annual_data ALTER COLUMN id SET DEFAULT nextval('public.financial_annual_data_id_seq'::regclass);


--
-- Name: financial_categories id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.financial_categories ALTER COLUMN id SET DEFAULT nextval('public.financial_categories_id_seq'::regclass);


--
-- Name: financial_cumulative_data id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.financial_cumulative_data ALTER COLUMN id SET DEFAULT nextval('public.financial_cumulative_data_id_seq'::regclass);


--
-- Name: financial_metric id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.financial_metric ALTER COLUMN id SET DEFAULT nextval('public.financial_metric_id_seq'::regclass);


--
-- Name: financial_metrics_data id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.financial_metrics_data ALTER COLUMN id SET DEFAULT nextval('public.financial_metrics_data_id_seq'::regclass);


--
-- Name: financial_submetric id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.financial_submetric ALTER COLUMN id SET DEFAULT nextval('public.financial_submetric_id_seq'::regclass);


--
-- Name: financial_types id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.financial_types ALTER COLUMN id SET DEFAULT nextval('public.financial_types_id_seq'::regclass);


--
-- Name: fixed_commissions_calculation id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fixed_commissions_calculation ALTER COLUMN id SET DEFAULT nextval('public.fixed_commissions_calculation_id_seq'::regclass);


--
-- Name: health_apps id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.health_apps ALTER COLUMN id SET DEFAULT nextval('public.health_apps_id_seq'::regclass);


--
-- Name: health_checks id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.health_checks ALTER COLUMN id SET DEFAULT nextval('public.health_checks_id_seq'::regclass);


--
-- Name: import_sources id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.import_sources ALTER COLUMN id SET DEFAULT nextval('public.import_sources_id_seq'::regclass);


--
-- Name: localization_reference_history id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.localization_reference_history ALTER COLUMN id SET DEFAULT nextval('public.localization_reference_history_id_seq'::regclass);


--
-- Name: login_events id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.login_events ALTER COLUMN id SET DEFAULT nextval('public.login_events_id_seq'::regclass);


--
-- Name: mail_recipient_lists id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mail_recipient_lists ALTER COLUMN id SET DEFAULT nextval('public.mail_recipient_lists_id_seq'::regclass);


--
-- Name: modules id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.modules ALTER COLUMN id SET DEFAULT nextval('public.modules_id_seq'::regclass);


--
-- Name: monthly_evolution id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.monthly_evolution ALTER COLUMN id SET DEFAULT nextval('public.monthly_evolution_id_seq'::regclass);


--
-- Name: moov_money_data id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.moov_money_data ALTER COLUMN id SET DEFAULT nextval('public.moov_money_data_id_seq'::regclass);


--
-- Name: moov_money_reactivation_data id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.moov_money_reactivation_data ALTER COLUMN id SET DEFAULT nextval('public.moov_money_reactivation_data_id_seq'::regclass);


--
-- Name: moov_money_subscriber_details id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.moov_money_subscriber_details ALTER COLUMN id SET DEFAULT nextval('public.moov_money_subscriber_details_id_seq'::regclass);


--
-- Name: moyenne_jour id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.moyenne_jour ALTER COLUMN id SET DEFAULT nextval('public.moyenne_jour_id_seq'::regclass);


--
-- Name: navigation_items id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.navigation_items ALTER COLUMN id SET DEFAULT nextval('public.navigation_items_id_seq'::regclass);


--
-- Name: network_registry id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.network_registry ALTER COLUMN id SET DEFAULT nextval('public.network_registry_id_seq'::regclass);


--
-- Name: nifi_connection_ids id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.nifi_connection_ids ALTER COLUMN id SET DEFAULT nextval('public.nifi_connection_ids_id_seq'::regclass);


--
-- Name: notification_tracking id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification_tracking ALTER COLUMN id SET DEFAULT nextval('public.notification_tracking_id_seq'::regclass);


--
-- Name: notifications id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications ALTER COLUMN id SET DEFAULT nextval('public.notifications_id_seq'::regclass);


--
-- Name: paygo_data id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.paygo_data ALTER COLUMN id SET DEFAULT nextval('public.paygo_data_id_seq'::regclass);


--
-- Name: portal_settings id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.portal_settings ALTER COLUMN id SET DEFAULT nextval('public.portal_settings_id_seq'::regclass);


--
-- Name: prefix_history id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prefix_history ALTER COLUMN id SET DEFAULT nextval('public.prefix_history_id_seq'::regclass);


--
-- Name: prepaid_plan id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prepaid_plan ALTER COLUMN id SET DEFAULT nextval('public.prepaid_plan_id_seq'::regclass);


--
-- Name: primes_promoteur_calculation id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.primes_promoteur_calculation ALTER COLUMN id SET DEFAULT nextval('public.primes_promoteur_calculation_id_seq'::regclass);


--
-- Name: primes_promoteur_nord id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.primes_promoteur_nord ALTER COLUMN id SET DEFAULT nextval('public.primes_promoteur_nord_id_seq'::regclass);


--
-- Name: ratio_conso_segment id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ratio_conso_segment ALTER COLUMN id SET DEFAULT nextval('public.ratio_conso_segment_id_seq'::regclass);


--
-- Name: realisation_budget_segment id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.realisation_budget_segment ALTER COLUMN id SET DEFAULT nextval('public.realisation_budget_segment_id_seq'::regclass);


--
-- Name: realised_cashflow id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.realised_cashflow ALTER COLUMN id SET DEFAULT nextval('public.realised_cashflow_id_seq'::regclass);


--
-- Name: resource_monthly_values id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.resource_monthly_values ALTER COLUMN id SET DEFAULT nextval('public.resource_monthly_values_id_seq'::regclass);


--
-- Name: resource_subtype id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.resource_subtype ALTER COLUMN id SET DEFAULT nextval('public.resource_subtype_id_seq'::regclass);


--
-- Name: resource_type id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.resource_type ALTER COLUMN id SET DEFAULT nextval('public.resource_type_id_seq'::regclass);


--
-- Name: revenue_metadata id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.revenue_metadata ALTER COLUMN id SET DEFAULT nextval('public.revenue_metadata_id_seq'::regclass);


--
-- Name: revenue_raw_data id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.revenue_raw_data ALTER COLUMN id SET DEFAULT nextval('public.revenue_raw_data_id_seq'::regclass);


--
-- Name: revenue_uploaded_files id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.revenue_uploaded_files ALTER COLUMN id SET DEFAULT nextval('public.revenue_uploaded_files_id_seq'::regclass);


--
-- Name: roaming_comite_history id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roaming_comite_history ALTER COLUMN id SET DEFAULT nextval('public.roaming_comite_history_id_seq'::regclass);


--
-- Name: roaming_comitie id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roaming_comitie ALTER COLUMN id SET DEFAULT nextval('public.roaming_comitie_id_seq'::regclass);


--
-- Name: roaming_prefix id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roaming_prefix ALTER COLUMN id SET DEFAULT nextval('public.roaming_prefix_id_seq'::regclass);


--
-- Name: segment_date id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.segment_date ALTER COLUMN id SET DEFAULT nextval('public.segment_date_id_seq'::regclass);


--
-- Name: si_registry id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.si_registry ALTER COLUMN id SET DEFAULT nextval('public.si_registry_id_seq'::regclass);


--
-- Name: smtp_details id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.smtp_details ALTER COLUMN id SET DEFAULT nextval('public.smtp_details_id_seq'::regclass);


--
-- Name: standard_impact id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.standard_impact ALTER COLUMN id SET DEFAULT nextval('public.standard_impact_id_seq'::regclass);


--
-- Name: standard_impact_monthly_values id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.standard_impact_monthly_values ALTER COLUMN id SET DEFAULT nextval('public.standard_impact_monthly_values_id_seq'::regclass);


--
-- Name: superset_dashboard id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.superset_dashboard ALTER COLUMN id SET DEFAULT nextval('public.superset_dashboard_id_seq'::regclass);


--
-- Name: tbg_alerts id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbg_alerts ALTER COLUMN id SET DEFAULT nextval('public.tbg_alerts_id_seq'::regclass);


--
-- Name: tbg_calculation_category_fields id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbg_calculation_category_fields ALTER COLUMN id SET DEFAULT nextval('public.tbg_calculation_category_fields_id_seq'::regclass);


--
-- Name: tbg_calculation_fields id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbg_calculation_fields ALTER COLUMN id SET DEFAULT nextval('public.tbg_calculation_fields_id_seq'::regclass);


--
-- Name: tbg_calculation_fields_types id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbg_calculation_fields_types ALTER COLUMN id SET DEFAULT nextval('public.tbg_calculation_fields_types_id_seq'::regclass);


--
-- Name: tbg_capex_project_details id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbg_capex_project_details ALTER COLUMN id SET DEFAULT nextval('public.tbg_capex_project_details_id_seq'::regclass);


--
-- Name: tbg_formula_edit_history id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbg_formula_edit_history ALTER COLUMN id SET DEFAULT nextval('public.tbg_formula_edit_history_id_seq'::regclass);


--
-- Name: tbg_formulas id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbg_formulas ALTER COLUMN id SET DEFAULT nextval('public.tbg_formulas_id_seq'::regclass);


--
-- Name: tbg_reel_status_history id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbg_reel_status_history ALTER COLUMN id SET DEFAULT nextval('public.tbg_reel_status_history_id_seq'::regclass);


--
-- Name: tbg_report_request id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbg_report_request ALTER COLUMN id SET DEFAULT nextval('public.tbg_report_request_id_seq'::regclass);


--
-- Name: tbg_report_types id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbg_report_types ALTER COLUMN id SET DEFAULT nextval('public.tbg_report_types_id_seq'::regclass);


--
-- Name: tbg_version id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbg_version ALTER COLUMN id SET DEFAULT nextval('public.tbg_version_id_seq'::regclass);


--
-- Name: telecom_metric id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.telecom_metric ALTER COLUMN id SET DEFAULT nextval('public.telecom_metric_id_seq'::regclass);


--
-- Name: telecom_metric_values id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.telecom_metric_values ALTER COLUMN id SET DEFAULT nextval('public.telecom_metric_values_id_seq'::regclass);


--
-- Name: tva_aib_calculation id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tva_aib_calculation ALTER COLUMN id SET DEFAULT nextval('public.tva_aib_calculation_id_seq'::regclass);


--
-- Name: upload_component_types id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.upload_component_types ALTER COLUMN id SET DEFAULT nextval('public.upload_component_types_id_seq'::regclass);


--
-- Name: upload_data id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.upload_data ALTER COLUMN id SET DEFAULT nextval('public.upload_data_id_seq'::regclass);


--
-- Name: upload_sheet_types id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.upload_sheet_types ALTER COLUMN id SET DEFAULT nextval('public.upload_sheet_types_id_seq'::regclass);


--
-- Name: upload_tbg_file_types id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.upload_tbg_file_types ALTER COLUMN id SET DEFAULT nextval('public.upload_tbg_file_types_id_seq'::regclass);


--
-- Name: valorization_tariff_history id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.valorization_tariff_history ALTER COLUMN id SET DEFAULT nextval('public.valorization_tariff_history_id_seq'::regclass);


--
-- Name: valorization_tariff_schedules id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.valorization_tariff_schedules ALTER COLUMN id SET DEFAULT nextval('public.valorization_tariff_schedules_id_seq'::regclass);


--
-- Name: valorization_tariffs id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.valorization_tariffs ALTER COLUMN id SET DEFAULT nextval('public.valorization_tariffs_id_seq'::regclass);


--
-- Name: vendor_registry id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vendor_registry ALTER COLUMN id SET DEFAULT nextval('public.vendor_registry_id_seq'::regclass);


--
-- Name: voix_segment id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.voix_segment ALTER COLUMN id SET DEFAULT nextval('public.voix_segment_id_seq'::regclass);


--
-- Name: weekly_evolution id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.weekly_evolution ALTER COLUMN id SET DEFAULT nextval('public.weekly_evolution_id_seq'::regclass);


--
-- Name: yearly_evolution id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.yearly_evolution ALTER COLUMN id SET DEFAULT nextval('public.yearly_evolution_id_seq'::regclass);


--
-- Name: archive_registry archive_registry_pkey; Type: CONSTRAINT; Schema: digiwise_schema; Owner: postgres
--

ALTER TABLE ONLY digiwise_schema.archive_registry
    ADD CONSTRAINT archive_registry_pkey PRIMARY KEY (id);


--
-- Name: financial_annual_data financial_annual_data_pkey; Type: CONSTRAINT; Schema: digiwise_schema; Owner: postgres
--

ALTER TABLE ONLY digiwise_schema.financial_annual_data
    ADD CONSTRAINT financial_annual_data_pkey PRIMARY KEY (id);


--
-- Name: financial_categories financial_categories_pkey; Type: CONSTRAINT; Schema: digiwise_schema; Owner: postgres
--

ALTER TABLE ONLY digiwise_schema.financial_categories
    ADD CONSTRAINT financial_categories_pkey PRIMARY KEY (id);


--
-- Name: financial_cumulative_data financial_cumulative_data_pkey; Type: CONSTRAINT; Schema: digiwise_schema; Owner: postgres
--

ALTER TABLE ONLY digiwise_schema.financial_cumulative_data
    ADD CONSTRAINT financial_cumulative_data_pkey PRIMARY KEY (id);


--
-- Name: financial_metric financial_metric_pkey; Type: CONSTRAINT; Schema: digiwise_schema; Owner: postgres
--

ALTER TABLE ONLY digiwise_schema.financial_metric
    ADD CONSTRAINT financial_metric_pkey PRIMARY KEY (id);


--
-- Name: financial_metrics_data financial_metrics_data_pkey; Type: CONSTRAINT; Schema: digiwise_schema; Owner: postgres
--

ALTER TABLE ONLY digiwise_schema.financial_metrics_data
    ADD CONSTRAINT financial_metrics_data_pkey PRIMARY KEY (id);


--
-- Name: financial_submetric financial_submetric_pkey; Type: CONSTRAINT; Schema: digiwise_schema; Owner: postgres
--

ALTER TABLE ONLY digiwise_schema.financial_submetric
    ADD CONSTRAINT financial_submetric_pkey PRIMARY KEY (id);


--
-- Name: financial_types financial_types_pkey; Type: CONSTRAINT; Schema: digiwise_schema; Owner: postgres
--

ALTER TABLE ONLY digiwise_schema.financial_types
    ADD CONSTRAINT financial_types_pkey PRIMARY KEY (id);


--
-- Name: network_registry network_registry_pkey; Type: CONSTRAINT; Schema: digiwise_schema; Owner: postgres
--

ALTER TABLE ONLY digiwise_schema.network_registry
    ADD CONSTRAINT network_registry_pkey PRIMARY KEY (id);


--
-- Name: si_registry si_registry_pkey; Type: CONSTRAINT; Schema: digiwise_schema; Owner: postgres
--

ALTER TABLE ONLY digiwise_schema.si_registry
    ADD CONSTRAINT si_registry_pkey PRIMARY KEY (id);


--
-- Name: vendor_registry vendor_registry_pkey; Type: CONSTRAINT; Schema: digiwise_schema; Owner: postgres
--

ALTER TABLE ONLY digiwise_schema.vendor_registry
    ADD CONSTRAINT vendor_registry_pkey PRIMARY KEY (id);


--
-- Name: DownloadRequests DownloadRequests_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."DownloadRequests"
    ADD CONSTRAINT "DownloadRequests_pkey" PRIMARY KEY (id);


--
-- Name: SequelizeMeta SequelizeMeta_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SequelizeMeta"
    ADD CONSTRAINT "SequelizeMeta_pkey" PRIMARY KEY (name);


--
-- Name: activity_events activity_events_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.activity_events
    ADD CONSTRAINT activity_events_pkey PRIMARY KEY (id);


--
-- Name: alert_notifications alert_notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.alert_notifications
    ADD CONSTRAINT alert_notifications_pkey PRIMARY KEY (id);


--
-- Name: app_icons app_icons_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_icons
    ADD CONSTRAINT app_icons_pkey PRIMARY KEY (id);


--
-- Name: archive_registry archive_registry_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.archive_registry
    ADD CONSTRAINT archive_registry_pkey PRIMARY KEY (id);


--
-- Name: archive_storage_kpis archive_storage_kpis_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.archive_storage_kpis
    ADD CONSTRAINT archive_storage_kpis_pkey PRIMARY KEY (id);


--
-- Name: base_lineage_benin base_lineage_benin_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.base_lineage_benin
    ADD CONSTRAINT base_lineage_benin_pkey PRIMARY KEY (id);


--
-- Name: base_lineage_mali base_lineage_mali_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.base_lineage_mali
    ADD CONSTRAINT base_lineage_mali_pkey PRIMARY KEY (id);


--
-- Name: capex_data capex_data_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.capex_data
    ADD CONSTRAINT capex_data_pkey PRIMARY KEY (id);


--
-- Name: capex_projects capex_projects_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.capex_projects
    ADD CONSTRAINT capex_projects_pkey PRIMARY KEY (id);


--
-- Name: cashflow_categories cashflow_categories_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cashflow_categories
    ADD CONSTRAINT cashflow_categories_name_key UNIQUE (name);


--
-- Name: cashflow_categories cashflow_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cashflow_categories
    ADD CONSTRAINT cashflow_categories_pkey PRIMARY KEY (id);


--
-- Name: cashflow_data cashflow_data_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cashflow_data
    ADD CONSTRAINT cashflow_data_pkey PRIMARY KEY (id);


--
-- Name: cashflow_sections cashflow_sections_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cashflow_sections
    ADD CONSTRAINT cashflow_sections_pkey PRIMARY KEY (id);


--
-- Name: cashflow_subcategories cashflow_subcategories_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cashflow_subcategories
    ADD CONSTRAINT cashflow_subcategories_name_key UNIQUE (name);


--
-- Name: cashflow_subcategories cashflow_subcategories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cashflow_subcategories
    ADD CONSTRAINT cashflow_subcategories_pkey PRIMARY KEY (id);


--
-- Name: collapse_annual_data collapse_annual_data_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collapse_annual_data
    ADD CONSTRAINT collapse_annual_data_pkey PRIMARY KEY (id);


--
-- Name: collapse_categories collapse_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collapse_categories
    ADD CONSTRAINT collapse_categories_pkey PRIMARY KEY (id);


--
-- Name: collapse_categories collapse_categories_unique_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collapse_categories
    ADD CONSTRAINT collapse_categories_unique_name_key UNIQUE (unique_name);


--
-- Name: collapse_cumul_data collapse_cumul_data_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collapse_cumul_data
    ADD CONSTRAINT collapse_cumul_data_pkey PRIMARY KEY (id);


--
-- Name: collapse_monthly_data collapse_monthly_data_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collapse_monthly_data
    ADD CONSTRAINT collapse_monthly_data_pkey PRIMARY KEY (id);


--
-- Name: collapse_subcategories collapse_subcategories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collapse_subcategories
    ADD CONSTRAINT collapse_subcategories_pkey PRIMARY KEY (id);


--
-- Name: collapse_subcategories collapse_subcategories_unique_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collapse_subcategories
    ADD CONSTRAINT collapse_subcategories_unique_name_key UNIQUE (unique_name);


--
-- Name: collapse_types collapse_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collapse_types
    ADD CONSTRAINT collapse_types_pkey PRIMARY KEY (id);


--
-- Name: collapse_types collapse_types_unique_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collapse_types
    ADD CONSTRAINT collapse_types_unique_name_key UNIQUE (unique_name);


--
-- Name: collapsible_items collapsible_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collapsible_items
    ADD CONSTRAINT collapsible_items_pkey PRIMARY KEY (id);


--
-- Name: collapsible_items collapsible_items_unique_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collapsible_items
    ADD CONSTRAINT collapsible_items_unique_name_key UNIQUE (unique_name);


--
-- Name: commission_calculation_histories commission_calculation_histories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.commission_calculation_histories
    ADD CONSTRAINT commission_calculation_histories_pkey PRIMARY KEY (id);


--
-- Name: commission_calculation_rules commission_calculation_rules_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.commission_calculation_rules
    ADD CONSTRAINT commission_calculation_rules_pkey PRIMARY KEY (id);


--
-- Name: commission_calculation_types commission_calculation_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.commission_calculation_types
    ADD CONSTRAINT commission_calculation_types_pkey PRIMARY KEY (id);


--
-- Name: commission_enlevements commission_enlevements_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.commission_enlevements
    ADD CONSTRAINT commission_enlevements_pkey PRIMARY KEY (id);


--
-- Name: commission_file_types commission_file_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.commission_file_types
    ADD CONSTRAINT commission_file_types_pkey PRIMARY KEY (id);


--
-- Name: commission_files commission_files_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.commission_files
    ADD CONSTRAINT commission_files_pkey PRIMARY KEY (id);


--
-- Name: commission_groups commission_groups_group_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.commission_groups
    ADD CONSTRAINT commission_groups_group_name_key UNIQUE (group_name);


--
-- Name: commission_groups commission_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.commission_groups
    ADD CONSTRAINT commission_groups_pkey PRIMARY KEY (id);


--
-- Name: commission_histories commission_histories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.commission_histories
    ADD CONSTRAINT commission_histories_pkey PRIMARY KEY (id);


--
-- Name: commission_subtypes commission_subtypes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.commission_subtypes
    ADD CONSTRAINT commission_subtypes_pkey PRIMARY KEY (id);


--
-- Name: commission_types commission_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.commission_types
    ADD CONSTRAINT commission_types_pkey PRIMARY KEY (id);


--
-- Name: component_file_upload_rule_sheets component_file_upload_rule_sheets_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.component_file_upload_rule_sheets
    ADD CONSTRAINT component_file_upload_rule_sheets_pkey PRIMARY KEY (id);


--
-- Name: configuration_archive configuration_archive_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.configuration_archive
    ADD CONSTRAINT configuration_archive_pkey PRIMARY KEY (id);


--
-- Name: configuration configuration_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.configuration
    ADD CONSTRAINT configuration_pkey PRIMARY KEY (id);


--
-- Name: country_module_configs country_module_configs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.country_module_configs
    ADD CONSTRAINT country_module_configs_pkey PRIMARY KEY (id);


--
-- Name: data_cormant_metics data_cormant_metics_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.data_cormant_metics
    ADD CONSTRAINT data_cormant_metics_pkey PRIMARY KEY (id);


--
-- Name: data_cormat_upload_files data_cormat_upload_files_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.data_cormat_upload_files
    ADD CONSTRAINT data_cormat_upload_files_pkey PRIMARY KEY (id);


--
-- Name: data_dormant_metadata data_dormant_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.data_dormant_metadata
    ADD CONSTRAINT data_dormant_metadata_pkey PRIMARY KEY (id);


--
-- Name: data_dormant_metics data_dormant_metics_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.data_dormant_metics
    ADD CONSTRAINT data_dormant_metics_pkey PRIMARY KEY (id);


--
-- Name: data_dormant_upload_files data_dormant_upload_files_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.data_dormant_upload_files
    ADD CONSTRAINT data_dormant_upload_files_pkey PRIMARY KEY (id);


--
-- Name: data_lineage_alerts data_lineage_alerts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.data_lineage_alerts
    ADD CONSTRAINT data_lineage_alerts_pkey PRIMARY KEY (id);


--
-- Name: data_lineage_configs data_lineage_configs_key_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.data_lineage_configs
    ADD CONSTRAINT data_lineage_configs_key_key UNIQUE (key);


--
-- Name: data_lineage_configs data_lineage_configs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.data_lineage_configs
    ADD CONSTRAINT data_lineage_configs_pkey PRIMARY KEY (id);


--
-- Name: data_lineage_edges data_lineage_edges_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.data_lineage_edges
    ADD CONSTRAINT data_lineage_edges_pkey PRIMARY KEY (id);


--
-- Name: data_lineage_events data_lineage_events_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.data_lineage_events
    ADD CONSTRAINT data_lineage_events_pkey PRIMARY KEY (id);


--
-- Name: data_lineage_notification data_lineage_notification_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.data_lineage_notification
    ADD CONSTRAINT data_lineage_notification_pkey PRIMARY KEY (id);


--
-- Name: data_lineage_stage data_lineage_stage_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.data_lineage_stage
    ADD CONSTRAINT data_lineage_stage_pkey PRIMARY KEY (id);


--
-- Name: data_voix_auto_rechargement_data data_voix_auto_rechargement_data_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.data_voix_auto_rechargement_data
    ADD CONSTRAINT data_voix_auto_rechargement_data_pkey PRIMARY KEY (id);


--
-- Name: data_voix_data data_voix_data_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.data_voix_data
    ADD CONSTRAINT data_voix_data_pkey PRIMARY KEY (id);


--
-- Name: data_voix_subscriber_details data_voix_subscriber_details_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.data_voix_subscriber_details
    ADD CONSTRAINT data_voix_subscriber_details_pkey PRIMARY KEY (id);


--
-- Name: decoder_configuration decoder_configuration_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.decoder_configuration
    ADD CONSTRAINT decoder_configuration_pkey PRIMARY KEY (id);


--
-- Name: distributor_ristournes distributor_ristournes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.distributor_ristournes
    ADD CONSTRAINT distributor_ristournes_pkey PRIMARY KEY (id);


--
-- Name: feature_prerequisites feature_prerequisites_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.feature_prerequisites
    ADD CONSTRAINT feature_prerequisites_pkey PRIMARY KEY (id);


--
-- Name: feature_section feature_section_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.feature_section
    ADD CONSTRAINT feature_section_pkey PRIMARY KEY (id);


--
-- Name: feuil1_metrics feuil1_metrics_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.feuil1_metrics
    ADD CONSTRAINT feuil1_metrics_pkey PRIMARY KEY (id);


--
-- Name: financial_annual_data financial_annual_data_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.financial_annual_data
    ADD CONSTRAINT financial_annual_data_pkey PRIMARY KEY (id);


--
-- Name: financial_categories financial_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.financial_categories
    ADD CONSTRAINT financial_categories_pkey PRIMARY KEY (id);


--
-- Name: financial_cumulative_data financial_cumulative_data_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.financial_cumulative_data
    ADD CONSTRAINT financial_cumulative_data_pkey PRIMARY KEY (id);


--
-- Name: financial_metric financial_metric_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.financial_metric
    ADD CONSTRAINT financial_metric_pkey PRIMARY KEY (id);


--
-- Name: financial_metrics_data financial_metrics_data_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.financial_metrics_data
    ADD CONSTRAINT financial_metrics_data_pkey PRIMARY KEY (id);


--
-- Name: financial_submetric financial_submetric_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.financial_submetric
    ADD CONSTRAINT financial_submetric_pkey PRIMARY KEY (id);


--
-- Name: financial_types financial_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.financial_types
    ADD CONSTRAINT financial_types_pkey PRIMARY KEY (id);


--
-- Name: fixed_commissions_calculation fixed_commissions_calculation_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fixed_commissions_calculation
    ADD CONSTRAINT fixed_commissions_calculation_pkey PRIMARY KEY (id);


--
-- Name: health_apps health_apps_app_key_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.health_apps
    ADD CONSTRAINT health_apps_app_key_key UNIQUE (app_key);


--
-- Name: health_apps health_apps_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.health_apps
    ADD CONSTRAINT health_apps_pkey PRIMARY KEY (id);


--
-- Name: health_checks health_checks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.health_checks
    ADD CONSTRAINT health_checks_pkey PRIMARY KEY (id);


--
-- Name: import_sources import_sources_file_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.import_sources
    ADD CONSTRAINT import_sources_file_name_key UNIQUE (file_name);


--
-- Name: import_sources import_sources_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.import_sources
    ADD CONSTRAINT import_sources_pkey PRIMARY KEY (id);


--
-- Name: lineage_benin lineage_benin_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lineage_benin
    ADD CONSTRAINT lineage_benin_pkey PRIMARY KEY (id);


--
-- Name: lineage_mali lineage_mali_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lineage_mali
    ADD CONSTRAINT lineage_mali_pkey PRIMARY KEY (id);


--
-- Name: localization_reference_history localization_reference_history_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.localization_reference_history
    ADD CONSTRAINT localization_reference_history_pkey PRIMARY KEY (id);


--
-- Name: login_events login_events_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.login_events
    ADD CONSTRAINT login_events_pkey PRIMARY KEY (id);


--
-- Name: mail_recipient_lists mail_recipient_lists_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mail_recipient_lists
    ADD CONSTRAINT mail_recipient_lists_pkey PRIMARY KEY (id);


--
-- Name: modules modules_key_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.modules
    ADD CONSTRAINT modules_key_key UNIQUE (key);


--
-- Name: modules modules_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.modules
    ADD CONSTRAINT modules_pkey PRIMARY KEY (id);


--
-- Name: monthly_evolution monthly_evolution_month_current_year_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.monthly_evolution
    ADD CONSTRAINT monthly_evolution_month_current_year_key UNIQUE (month, current_year);


--
-- Name: monthly_evolution monthly_evolution_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.monthly_evolution
    ADD CONSTRAINT monthly_evolution_pkey PRIMARY KEY (id);


--
-- Name: moov_money_data moov_money_data_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.moov_money_data
    ADD CONSTRAINT moov_money_data_pkey PRIMARY KEY (id);


--
-- Name: moov_money_reactivation_data moov_money_reactivation_data_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.moov_money_reactivation_data
    ADD CONSTRAINT moov_money_reactivation_data_pkey PRIMARY KEY (id);


--
-- Name: moov_money_subscriber_details moov_money_subscriber_details_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.moov_money_subscriber_details
    ADD CONSTRAINT moov_money_subscriber_details_pkey PRIMARY KEY (id);


--
-- Name: moyenne_jour moyenne_jour_month_year_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.moyenne_jour
    ADD CONSTRAINT moyenne_jour_month_year_key UNIQUE (month, year);


--
-- Name: moyenne_jour moyenne_jour_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.moyenne_jour
    ADD CONSTRAINT moyenne_jour_pkey PRIMARY KEY (id);


--
-- Name: navigation_items navigation_items_name_key_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.navigation_items
    ADD CONSTRAINT navigation_items_name_key_key UNIQUE (name_key);


--
-- Name: navigation_items navigation_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.navigation_items
    ADD CONSTRAINT navigation_items_pkey PRIMARY KEY (id);


--
-- Name: network_registry network_registry_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.network_registry
    ADD CONSTRAINT network_registry_pkey PRIMARY KEY (id);


--
-- Name: nifi_connection_ids nifi_connection_ids_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.nifi_connection_ids
    ADD CONSTRAINT nifi_connection_ids_pkey PRIMARY KEY (id);


--
-- Name: notification_tracking notification_tracking_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification_tracking
    ADD CONSTRAINT notification_tracking_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: paygo_data paygo_data_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.paygo_data
    ADD CONSTRAINT paygo_data_pkey PRIMARY KEY (id);


--
-- Name: portal_settings portal_settings_country_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.portal_settings
    ADD CONSTRAINT portal_settings_country_key UNIQUE (country);


--
-- Name: portal_settings portal_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.portal_settings
    ADD CONSTRAINT portal_settings_pkey PRIMARY KEY (id);


--
-- Name: prefix_history prefix_history_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prefix_history
    ADD CONSTRAINT prefix_history_pkey PRIMARY KEY (id);


--
-- Name: prepaid_plan prepaid_plan_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prepaid_plan
    ADD CONSTRAINT prepaid_plan_pkey PRIMARY KEY (id);


--
-- Name: primes_promoteur_calculation primes_promoteur_calculation_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.primes_promoteur_calculation
    ADD CONSTRAINT primes_promoteur_calculation_pkey PRIMARY KEY (id);


--
-- Name: primes_promoteur_nord primes_promoteur_nord_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.primes_promoteur_nord
    ADD CONSTRAINT primes_promoteur_nord_pkey PRIMARY KEY (id);


--
-- Name: ratio_conso_segment ratio_conso_segment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ratio_conso_segment
    ADD CONSTRAINT ratio_conso_segment_pkey PRIMARY KEY (id);


--
-- Name: realisation_budget_segment realisation_budget_segment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.realisation_budget_segment
    ADD CONSTRAINT realisation_budget_segment_pkey PRIMARY KEY (id);


--
-- Name: realised_cashflow realised_cashflow_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.realised_cashflow
    ADD CONSTRAINT realised_cashflow_name_key UNIQUE (name);


--
-- Name: realised_cashflow realised_cashflow_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.realised_cashflow
    ADD CONSTRAINT realised_cashflow_pkey PRIMARY KEY (id);


--
-- Name: resource_monthly_values resource_monthly_values_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.resource_monthly_values
    ADD CONSTRAINT resource_monthly_values_pkey PRIMARY KEY (id);


--
-- Name: resource_subtype resource_subtype_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.resource_subtype
    ADD CONSTRAINT resource_subtype_pkey PRIMARY KEY (id);


--
-- Name: resource_type resource_type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.resource_type
    ADD CONSTRAINT resource_type_pkey PRIMARY KEY (id);


--
-- Name: resource_type resource_type_type_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.resource_type
    ADD CONSTRAINT resource_type_type_name_key UNIQUE (type_name);


--
-- Name: revenue_metadata revenue_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.revenue_metadata
    ADD CONSTRAINT revenue_metadata_pkey PRIMARY KEY (id);


--
-- Name: revenue_raw_data revenue_raw_data_date_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.revenue_raw_data
    ADD CONSTRAINT revenue_raw_data_date_key UNIQUE (date);


--
-- Name: revenue_raw_data revenue_raw_data_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.revenue_raw_data
    ADD CONSTRAINT revenue_raw_data_pkey PRIMARY KEY (id);


--
-- Name: revenue_uploaded_files revenue_uploaded_files_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.revenue_uploaded_files
    ADD CONSTRAINT revenue_uploaded_files_pkey PRIMARY KEY (id);


--
-- Name: roaming_comite_history roaming_comite_history_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roaming_comite_history
    ADD CONSTRAINT roaming_comite_history_pkey PRIMARY KEY (id);


--
-- Name: roaming_comitie roaming_comitie_operator_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roaming_comitie
    ADD CONSTRAINT roaming_comitie_operator_key UNIQUE (operator);


--
-- Name: roaming_comitie roaming_comitie_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roaming_comitie
    ADD CONSTRAINT roaming_comitie_pkey PRIMARY KEY (id);


--
-- Name: roaming_prefix roaming_prefix_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roaming_prefix
    ADD CONSTRAINT roaming_prefix_pkey PRIMARY KEY (id);


--
-- Name: segment_date segment_date_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.segment_date
    ADD CONSTRAINT segment_date_pkey PRIMARY KEY (id);


--
-- Name: si_registry si_registry_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.si_registry
    ADD CONSTRAINT si_registry_pkey PRIMARY KEY (id);


--
-- Name: smtp_details smtp_details_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.smtp_details
    ADD CONSTRAINT smtp_details_pkey PRIMARY KEY (id);


--
-- Name: standard_impact_monthly_values standard_impact_monthly_values_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.standard_impact_monthly_values
    ADD CONSTRAINT standard_impact_monthly_values_pkey PRIMARY KEY (id);


--
-- Name: standard_impact standard_impact_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.standard_impact
    ADD CONSTRAINT standard_impact_pkey PRIMARY KEY (id);


--
-- Name: superset_dashboard superset_dashboard_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.superset_dashboard
    ADD CONSTRAINT superset_dashboard_pkey PRIMARY KEY (id);


--
-- Name: tbg_alerts tbg_alerts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbg_alerts
    ADD CONSTRAINT tbg_alerts_pkey PRIMARY KEY (id);


--
-- Name: tbg_calculation_category_fields tbg_calculation_category_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbg_calculation_category_fields
    ADD CONSTRAINT tbg_calculation_category_fields_pkey PRIMARY KEY (id);


--
-- Name: tbg_calculation_fields tbg_calculation_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbg_calculation_fields
    ADD CONSTRAINT tbg_calculation_fields_pkey PRIMARY KEY (id);


--
-- Name: tbg_calculation_fields_types tbg_calculation_fields_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbg_calculation_fields_types
    ADD CONSTRAINT tbg_calculation_fields_types_pkey PRIMARY KEY (id);


--
-- Name: tbg_capex_project_details tbg_capex_project_details_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbg_capex_project_details
    ADD CONSTRAINT tbg_capex_project_details_pkey PRIMARY KEY (id);


--
-- Name: tbg_formula_edit_history tbg_formula_edit_history_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbg_formula_edit_history
    ADD CONSTRAINT tbg_formula_edit_history_pkey PRIMARY KEY (id);


--
-- Name: tbg_formulas tbg_formulas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbg_formulas
    ADD CONSTRAINT tbg_formulas_pkey PRIMARY KEY (id);


--
-- Name: tbg_reel_status_history tbg_reel_status_history_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbg_reel_status_history
    ADD CONSTRAINT tbg_reel_status_history_pkey PRIMARY KEY (id);


--
-- Name: tbg_report_request tbg_report_request_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbg_report_request
    ADD CONSTRAINT tbg_report_request_pkey PRIMARY KEY (id);


--
-- Name: tbg_report_types tbg_report_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbg_report_types
    ADD CONSTRAINT tbg_report_types_pkey PRIMARY KEY (id);


--
-- Name: tbg_report_types tbg_report_types_report_key_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbg_report_types
    ADD CONSTRAINT tbg_report_types_report_key_key UNIQUE (report_key);


--
-- Name: tbg_version tbg_version_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbg_version
    ADD CONSTRAINT tbg_version_pkey PRIMARY KEY (id);


--
-- Name: telecom_metric telecom_metric_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.telecom_metric
    ADD CONSTRAINT telecom_metric_pkey PRIMARY KEY (id);


--
-- Name: telecom_metric_values telecom_metric_values_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.telecom_metric_values
    ADD CONSTRAINT telecom_metric_values_pkey PRIMARY KEY (id);


--
-- Name: theme_configurations theme_configurations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.theme_configurations
    ADD CONSTRAINT theme_configurations_pkey PRIMARY KEY (id);


--
-- Name: tva_aib_calculation tva_aib_calculation_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tva_aib_calculation
    ADD CONSTRAINT tva_aib_calculation_pkey PRIMARY KEY (id);


--
-- Name: paygo_data unique_date; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.paygo_data
    ADD CONSTRAINT unique_date UNIQUE (date);


--
-- Name: feuil1_metrics unique_date_feuil1; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.feuil1_metrics
    ADD CONSTRAINT unique_date_feuil1 UNIQUE (date);


--
-- Name: telecom_metric_values unique_metric_month_year; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.telecom_metric_values
    ADD CONSTRAINT unique_metric_month_year UNIQUE (telecom_metric_id, month, year);


--
-- Name: paygo_data unique_paygo_date; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.paygo_data
    ADD CONSTRAINT unique_paygo_date UNIQUE (date);


--
-- Name: telecom_metric unique_plan_metric; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.telecom_metric
    ADD CONSTRAINT unique_plan_metric UNIQUE (plan_name_id, metric_name);


--
-- Name: prepaid_plan unique_plan_name; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prepaid_plan
    ADD CONSTRAINT unique_plan_name UNIQUE (plan_name);


--
-- Name: tbg_formulas unique_tbg_formula_per_type; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbg_formulas
    ADD CONSTRAINT unique_tbg_formula_per_type UNIQUE (tbg_key, formula_type);


--
-- Name: notification_tracking unique_user_file_month_year; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification_tracking
    ADD CONSTRAINT unique_user_file_month_year UNIQUE (user_id, upload_tbg_file_type_id, month, year);


--
-- Name: tbg_alerts unique_user_file_month_year_alert; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbg_alerts
    ADD CONSTRAINT unique_user_file_month_year_alert UNIQUE (user_id, upload_tbg_file_type_id, month, year);


--
-- Name: upload_component_types upload_component_types_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.upload_component_types
    ADD CONSTRAINT upload_component_types_name_key UNIQUE (name);


--
-- Name: upload_component_types upload_component_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.upload_component_types
    ADD CONSTRAINT upload_component_types_pkey PRIMARY KEY (id);


--
-- Name: upload_data upload_data_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.upload_data
    ADD CONSTRAINT upload_data_pkey PRIMARY KEY (id);


--
-- Name: upload_sheet_types upload_sheet_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.upload_sheet_types
    ADD CONSTRAINT upload_sheet_types_pkey PRIMARY KEY (id);


--
-- Name: upload_tbg_file_types upload_tbg_file_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.upload_tbg_file_types
    ADD CONSTRAINT upload_tbg_file_types_pkey PRIMARY KEY (id);


--
-- Name: valorization_tariff_history valorization_tariff_history_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.valorization_tariff_history
    ADD CONSTRAINT valorization_tariff_history_pkey PRIMARY KEY (id);


--
-- Name: valorization_tariff_schedules valorization_tariff_schedules_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.valorization_tariff_schedules
    ADD CONSTRAINT valorization_tariff_schedules_pkey PRIMARY KEY (id);


--
-- Name: valorization_tariffs valorization_tariffs_operator_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.valorization_tariffs
    ADD CONSTRAINT valorization_tariffs_operator_name_key UNIQUE (operator_name);


--
-- Name: valorization_tariffs valorization_tariffs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.valorization_tariffs
    ADD CONSTRAINT valorization_tariffs_pkey PRIMARY KEY (id);


--
-- Name: vendor_registry vendor_registry_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vendor_registry
    ADD CONSTRAINT vendor_registry_pkey PRIMARY KEY (id);


--
-- Name: voix_segment voix_segment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.voix_segment
    ADD CONSTRAINT voix_segment_pkey PRIMARY KEY (id);


--
-- Name: weekly_evolution weekly_evolution_current_week_date_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.weekly_evolution
    ADD CONSTRAINT weekly_evolution_current_week_date_key UNIQUE (current_week_date);


--
-- Name: weekly_evolution weekly_evolution_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.weekly_evolution
    ADD CONSTRAINT weekly_evolution_pkey PRIMARY KEY (id);


--
-- Name: yearly_evolution yearly_evolution_current_year_date_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.yearly_evolution
    ADD CONSTRAINT yearly_evolution_current_year_date_key UNIQUE (current_year_date);


--
-- Name: yearly_evolution yearly_evolution_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.yearly_evolution
    ADD CONSTRAINT yearly_evolution_pkey PRIMARY KEY (id);


--
-- Name: activity_events_event_timestamp_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX activity_events_event_timestamp_idx ON public.activity_events USING btree (event_timestamp);


--
-- Name: activity_events_module_name_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX activity_events_module_name_idx ON public.activity_events USING btree (module_name);


--
-- Name: activity_events_user_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX activity_events_user_id_idx ON public.activity_events USING btree (user_id);


--
-- Name: alert_notifications_app_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX alert_notifications_app_id_idx ON public.alert_notifications USING btree (app_id);


--
-- Name: app_icons_key_country_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX app_icons_key_country_unique ON public.app_icons USING btree (icon_key, country_code);


--
-- Name: health_checks_app_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX health_checks_app_id_idx ON public.health_checks USING btree (app_id);


--
-- Name: health_checks_check_time_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX health_checks_check_time_idx ON public.health_checks USING btree (check_time);


--
-- Name: health_checks_status_bool_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX health_checks_status_bool_idx ON public.health_checks USING btree (status_bool);


--
-- Name: idx_data_lineage_alerts_notification_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_data_lineage_alerts_notification_id ON public.data_lineage_alerts USING btree (notification_id);


--
-- Name: idx_notifications_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_notifications_created_at ON public.notifications USING btree (created_at);


--
-- Name: idx_notifications_feature_lookup; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_notifications_feature_lookup ON public.notifications USING btree (feature_type, feature_id);


--
-- Name: idx_notifications_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_notifications_user_id ON public.notifications USING btree (user_id);


--
-- Name: idx_notifications_user_id_is_read; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_notifications_user_id_is_read ON public.notifications USING btree (user_id, is_read);


--
-- Name: idx_tbg_alerts_notification_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tbg_alerts_notification_id ON public.tbg_alerts USING btree (notification_id);


--
-- Name: idx_tbg_report_types_category; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tbg_report_types_category ON public.tbg_report_types USING btree (category);


--
-- Name: idx_tbg_report_types_parent_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tbg_report_types_parent_id ON public.tbg_report_types USING btree (parent_id);


--
-- Name: idx_tbg_report_types_visible_months; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tbg_report_types_visible_months ON public.tbg_report_types USING gin (visible_months);


--
-- Name: idx_val_tariff_sched_status_effective; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_val_tariff_sched_status_effective ON public.valorization_tariff_schedules USING btree (status, effective_at);


--
-- Name: idx_val_tariff_sched_tariff_field; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_val_tariff_sched_tariff_field ON public.valorization_tariff_schedules USING btree (tariff_id, field_changed);


--
-- Name: login_events_event_timestamp_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX login_events_event_timestamp_idx ON public.login_events USING btree (event_timestamp);


--
-- Name: login_events_is_first_login_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX login_events_is_first_login_idx ON public.login_events USING btree (is_first_login);


--
-- Name: login_events_is_login_success_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX login_events_is_login_success_idx ON public.login_events USING btree (is_login_success);


--
-- Name: login_events_user_departments_gin_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX login_events_user_departments_gin_idx ON public.login_events USING gin (user_departments);


--
-- Name: login_events_user_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX login_events_user_id_idx ON public.login_events USING btree (user_id);


--
-- Name: portal_settings_emails_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX portal_settings_emails_idx ON public.portal_settings USING gin (emails);


--
-- Name: tbg_formula_edit_history_tbg_formula_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tbg_formula_edit_history_tbg_formula_id ON public.tbg_formula_edit_history USING btree (tbg_formula_id);


--
-- Name: tbg_formula_edit_history_tbg_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tbg_formula_edit_history_tbg_key ON public.tbg_formula_edit_history USING btree (tbg_key);


--
-- Name: tbg_formula_edit_history_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tbg_formula_edit_history_user_id ON public.tbg_formula_edit_history USING btree (user_id);


--
-- Name: unique_country_module_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX unique_country_module_key ON public.country_module_configs USING btree (country, module_key);


--
-- Name: unique_default_per_month_year; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX unique_default_per_month_year ON public.tbg_version USING btree (month, year) WHERE (is_default = true);


--
-- Name: upload_sheet_types_component_id_name_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX upload_sheet_types_component_id_name_unique ON public.upload_sheet_types USING btree (component_id, name);


--
-- Name: valorization_tariff_history_changed_by_username_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX valorization_tariff_history_changed_by_username_idx ON public.valorization_tariff_history USING btree (changed_by_username);


--
-- Name: valorization_tariff_history_tariff_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX valorization_tariff_history_tariff_id_idx ON public.valorization_tariff_history USING btree (tariff_id);


--
-- Name: valorization_tariffs_operator_name_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX valorization_tariffs_operator_name_idx ON public.valorization_tariffs USING btree (operator_name);


--
-- Name: archive_registry archive_registry_network_registry_id_fkey; Type: FK CONSTRAINT; Schema: digiwise_schema; Owner: postgres
--

ALTER TABLE ONLY digiwise_schema.archive_registry
    ADD CONSTRAINT archive_registry_network_registry_id_fkey FOREIGN KEY (network_registry_id) REFERENCES digiwise_schema.network_registry(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: archive_registry archive_registry_si_registry_id_fkey; Type: FK CONSTRAINT; Schema: digiwise_schema; Owner: postgres
--

ALTER TABLE ONLY digiwise_schema.archive_registry
    ADD CONSTRAINT archive_registry_si_registry_id_fkey FOREIGN KEY (si_registry_id) REFERENCES digiwise_schema.si_registry(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: archive_registry archive_registry_vendor_registry_id_fkey; Type: FK CONSTRAINT; Schema: digiwise_schema; Owner: postgres
--

ALTER TABLE ONLY digiwise_schema.archive_registry
    ADD CONSTRAINT archive_registry_vendor_registry_id_fkey FOREIGN KEY (vendor_registry_id) REFERENCES digiwise_schema.vendor_registry(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: financial_annual_data financial_annual_data_financial_metric_id_fkey; Type: FK CONSTRAINT; Schema: digiwise_schema; Owner: postgres
--

ALTER TABLE ONLY digiwise_schema.financial_annual_data
    ADD CONSTRAINT financial_annual_data_financial_metric_id_fkey FOREIGN KEY (financial_metric_id) REFERENCES digiwise_schema.financial_metric(id);


--
-- Name: financial_annual_data financial_annual_data_financial_submetric_id_fkey; Type: FK CONSTRAINT; Schema: digiwise_schema; Owner: postgres
--

ALTER TABLE ONLY digiwise_schema.financial_annual_data
    ADD CONSTRAINT financial_annual_data_financial_submetric_id_fkey FOREIGN KEY (financial_submetric_id) REFERENCES digiwise_schema.financial_submetric(id);


--
-- Name: financial_annual_data financial_annual_data_financial_type_id_fkey; Type: FK CONSTRAINT; Schema: digiwise_schema; Owner: postgres
--

ALTER TABLE ONLY digiwise_schema.financial_annual_data
    ADD CONSTRAINT financial_annual_data_financial_type_id_fkey FOREIGN KEY (financial_type_id) REFERENCES digiwise_schema.financial_types(id);


--
-- Name: financial_cumulative_data financial_cumulative_data_financial_metric_id_fkey; Type: FK CONSTRAINT; Schema: digiwise_schema; Owner: postgres
--

ALTER TABLE ONLY digiwise_schema.financial_cumulative_data
    ADD CONSTRAINT financial_cumulative_data_financial_metric_id_fkey FOREIGN KEY (financial_metric_id) REFERENCES digiwise_schema.financial_metric(id);


--
-- Name: financial_cumulative_data financial_cumulative_data_financial_submetric_id_fkey; Type: FK CONSTRAINT; Schema: digiwise_schema; Owner: postgres
--

ALTER TABLE ONLY digiwise_schema.financial_cumulative_data
    ADD CONSTRAINT financial_cumulative_data_financial_submetric_id_fkey FOREIGN KEY (financial_submetric_id) REFERENCES digiwise_schema.financial_submetric(id);


--
-- Name: financial_cumulative_data financial_cumulative_data_financial_type_id_fkey; Type: FK CONSTRAINT; Schema: digiwise_schema; Owner: postgres
--

ALTER TABLE ONLY digiwise_schema.financial_cumulative_data
    ADD CONSTRAINT financial_cumulative_data_financial_type_id_fkey FOREIGN KEY (financial_type_id) REFERENCES digiwise_schema.financial_types(id);


--
-- Name: financial_metric financial_metric_financial_type_id_fkey; Type: FK CONSTRAINT; Schema: digiwise_schema; Owner: postgres
--

ALTER TABLE ONLY digiwise_schema.financial_metric
    ADD CONSTRAINT financial_metric_financial_type_id_fkey FOREIGN KEY (financial_type_id) REFERENCES digiwise_schema.financial_types(id) ON DELETE CASCADE;


--
-- Name: financial_metrics_data financial_metrics_data_financial_metric_id_fkey; Type: FK CONSTRAINT; Schema: digiwise_schema; Owner: postgres
--

ALTER TABLE ONLY digiwise_schema.financial_metrics_data
    ADD CONSTRAINT financial_metrics_data_financial_metric_id_fkey FOREIGN KEY (financial_metric_id) REFERENCES digiwise_schema.financial_metric(id);


--
-- Name: financial_metrics_data financial_metrics_data_financial_submetric_id_fkey; Type: FK CONSTRAINT; Schema: digiwise_schema; Owner: postgres
--

ALTER TABLE ONLY digiwise_schema.financial_metrics_data
    ADD CONSTRAINT financial_metrics_data_financial_submetric_id_fkey FOREIGN KEY (financial_submetric_id) REFERENCES digiwise_schema.financial_submetric(id);


--
-- Name: financial_metrics_data financial_metrics_data_financial_type_id_fkey; Type: FK CONSTRAINT; Schema: digiwise_schema; Owner: postgres
--

ALTER TABLE ONLY digiwise_schema.financial_metrics_data
    ADD CONSTRAINT financial_metrics_data_financial_type_id_fkey FOREIGN KEY (financial_type_id) REFERENCES digiwise_schema.financial_types(id);


--
-- Name: financial_submetric financial_submetric_financial_metric_id_fkey; Type: FK CONSTRAINT; Schema: digiwise_schema; Owner: postgres
--

ALTER TABLE ONLY digiwise_schema.financial_submetric
    ADD CONSTRAINT financial_submetric_financial_metric_id_fkey FOREIGN KEY (financial_metric_id) REFERENCES digiwise_schema.financial_metric(id) ON DELETE CASCADE;


--
-- Name: financial_types financial_types_financial_category_id_fkey; Type: FK CONSTRAINT; Schema: digiwise_schema; Owner: postgres
--

ALTER TABLE ONLY digiwise_schema.financial_types
    ADD CONSTRAINT financial_types_financial_category_id_fkey FOREIGN KEY (financial_category_id) REFERENCES digiwise_schema.financial_categories(id) ON DELETE CASCADE;


--
-- Name: vendor_registry vendor_registry_network_registry_id_fkey; Type: FK CONSTRAINT; Schema: digiwise_schema; Owner: postgres
--

ALTER TABLE ONLY digiwise_schema.vendor_registry
    ADD CONSTRAINT vendor_registry_network_registry_id_fkey FOREIGN KEY (network_registry_id) REFERENCES digiwise_schema.network_registry(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: alert_notifications alert_notifications_app_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.alert_notifications
    ADD CONSTRAINT alert_notifications_app_id_fkey FOREIGN KEY (app_id) REFERENCES public.health_apps(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: archive_registry archive_registry_network_registry_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.archive_registry
    ADD CONSTRAINT archive_registry_network_registry_id_fkey FOREIGN KEY (network_registry_id) REFERENCES public.network_registry(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: archive_registry archive_registry_si_registry_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.archive_registry
    ADD CONSTRAINT archive_registry_si_registry_id_fkey FOREIGN KEY (si_registry_id) REFERENCES public.si_registry(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: archive_registry archive_registry_vendor_registry_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.archive_registry
    ADD CONSTRAINT archive_registry_vendor_registry_id_fkey FOREIGN KEY (vendor_registry_id) REFERENCES public.vendor_registry(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: capex_data capex_data_capex_projects_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.capex_data
    ADD CONSTRAINT capex_data_capex_projects_id_fkey FOREIGN KEY (capex_projects_id) REFERENCES public.capex_projects(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cashflow_categories cashflow_categories_cashflow_section_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cashflow_categories
    ADD CONSTRAINT cashflow_categories_cashflow_section_id_fkey FOREIGN KEY (cashflow_section_id) REFERENCES public.cashflow_sections(id) ON DELETE CASCADE;


--
-- Name: cashflow_sections cashflow_sections_parent_section_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cashflow_sections
    ADD CONSTRAINT cashflow_sections_parent_section_id_fkey FOREIGN KEY (parent_section_id) REFERENCES public.cashflow_sections(id) ON DELETE CASCADE;


--
-- Name: cashflow_sections cashflow_sections_realised_cashflow_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cashflow_sections
    ADD CONSTRAINT cashflow_sections_realised_cashflow_id_fkey FOREIGN KEY (realised_cashflow_id) REFERENCES public.realised_cashflow(id) ON DELETE CASCADE;


--
-- Name: cashflow_subcategories cashflow_subcategories_cashflow_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cashflow_subcategories
    ADD CONSTRAINT cashflow_subcategories_cashflow_category_id_fkey FOREIGN KEY (cashflow_category_id) REFERENCES public.cashflow_categories(id) ON DELETE CASCADE;


--
-- Name: collapse_categories collapse_categories_collapse_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collapse_categories
    ADD CONSTRAINT collapse_categories_collapse_type_id_fkey FOREIGN KEY (collapse_type_id) REFERENCES public.collapse_types(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: collapse_subcategories collapse_subcategories_collapse_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collapse_subcategories
    ADD CONSTRAINT collapse_subcategories_collapse_category_id_fkey FOREIGN KEY (collapse_category_id) REFERENCES public.collapse_categories(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: collapse_types collapse_types_collapsible_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collapse_types
    ADD CONSTRAINT collapse_types_collapsible_item_id_fkey FOREIGN KEY (collapsible_item_id) REFERENCES public.collapsible_items(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: collapsible_items collapsible_items_financial_categories_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collapsible_items
    ADD CONSTRAINT collapsible_items_financial_categories_id_fkey FOREIGN KEY (financial_categories_id) REFERENCES public.financial_categories(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: commission_calculation_rules commission_calculation_rules_commission_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.commission_calculation_rules
    ADD CONSTRAINT commission_calculation_rules_commission_type_id_fkey FOREIGN KEY (commission_type_id) REFERENCES public.commission_calculation_types(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: commission_files commission_files_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.commission_files
    ADD CONSTRAINT commission_files_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.commission_groups(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: commission_files commission_files_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.commission_files
    ADD CONSTRAINT commission_files_type_id_fkey FOREIGN KEY (type_id) REFERENCES public.commission_types(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: commission_histories commission_histories_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.commission_histories
    ADD CONSTRAINT commission_histories_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.commission_groups(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: commission_histories commission_histories_notification_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.commission_histories
    ADD CONSTRAINT commission_histories_notification_id_fkey FOREIGN KEY (notification_id) REFERENCES public.notifications(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: commission_histories commission_histories_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.commission_histories
    ADD CONSTRAINT commission_histories_type_id_fkey FOREIGN KEY (type_id) REFERENCES public.commission_types(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: commission_subtypes commission_subtypes_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.commission_subtypes
    ADD CONSTRAINT commission_subtypes_type_id_fkey FOREIGN KEY (type_id) REFERENCES public.commission_types(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: commission_types commission_types_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.commission_types
    ADD CONSTRAINT commission_types_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.commission_groups(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: configuration configuration_si_registry_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.configuration
    ADD CONSTRAINT configuration_si_registry_id_fkey FOREIGN KEY (si_registry_id) REFERENCES public.si_registry(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: country_module_configs country_module_configs_module_key_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.country_module_configs
    ADD CONSTRAINT country_module_configs_module_key_fkey FOREIGN KEY (module_key) REFERENCES public.modules(key) ON DELETE CASCADE;


--
-- Name: data_dormant_metadata data_dormant_metadata_notification_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.data_dormant_metadata
    ADD CONSTRAINT data_dormant_metadata_notification_id_fkey FOREIGN KEY (notification_id) REFERENCES public.notifications(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: data_lineage_alerts data_lineage_alerts_notification_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.data_lineage_alerts
    ADD CONSTRAINT data_lineage_alerts_notification_id_fkey FOREIGN KEY (notification_id) REFERENCES public.notifications(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: feature_prerequisites feature_prerequisites_feature_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.feature_prerequisites
    ADD CONSTRAINT feature_prerequisites_feature_id_fkey FOREIGN KEY (feature_id) REFERENCES public.feature_section(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: financial_annual_data financial_annual_data_financial_metric_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.financial_annual_data
    ADD CONSTRAINT financial_annual_data_financial_metric_id_fkey FOREIGN KEY (financial_metric_id) REFERENCES public.financial_metric(id);


--
-- Name: financial_annual_data financial_annual_data_financial_submetric_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.financial_annual_data
    ADD CONSTRAINT financial_annual_data_financial_submetric_id_fkey FOREIGN KEY (financial_submetric_id) REFERENCES public.financial_submetric(id);


--
-- Name: financial_annual_data financial_annual_data_financial_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.financial_annual_data
    ADD CONSTRAINT financial_annual_data_financial_type_id_fkey FOREIGN KEY (financial_type_id) REFERENCES public.financial_types(id);


--
-- Name: financial_cumulative_data financial_cumulative_data_financial_metric_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.financial_cumulative_data
    ADD CONSTRAINT financial_cumulative_data_financial_metric_id_fkey FOREIGN KEY (financial_metric_id) REFERENCES public.financial_metric(id);


--
-- Name: financial_cumulative_data financial_cumulative_data_financial_submetric_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.financial_cumulative_data
    ADD CONSTRAINT financial_cumulative_data_financial_submetric_id_fkey FOREIGN KEY (financial_submetric_id) REFERENCES public.financial_submetric(id);


--
-- Name: financial_cumulative_data financial_cumulative_data_financial_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.financial_cumulative_data
    ADD CONSTRAINT financial_cumulative_data_financial_type_id_fkey FOREIGN KEY (financial_type_id) REFERENCES public.financial_types(id);


--
-- Name: financial_metric financial_metric_financial_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.financial_metric
    ADD CONSTRAINT financial_metric_financial_type_id_fkey FOREIGN KEY (financial_type_id) REFERENCES public.financial_types(id) ON DELETE CASCADE;


--
-- Name: financial_metrics_data financial_metrics_data_financial_metric_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.financial_metrics_data
    ADD CONSTRAINT financial_metrics_data_financial_metric_id_fkey FOREIGN KEY (financial_metric_id) REFERENCES public.financial_metric(id);


--
-- Name: financial_metrics_data financial_metrics_data_financial_submetric_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.financial_metrics_data
    ADD CONSTRAINT financial_metrics_data_financial_submetric_id_fkey FOREIGN KEY (financial_submetric_id) REFERENCES public.financial_submetric(id);


--
-- Name: financial_metrics_data financial_metrics_data_financial_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.financial_metrics_data
    ADD CONSTRAINT financial_metrics_data_financial_type_id_fkey FOREIGN KEY (financial_type_id) REFERENCES public.financial_types(id);


--
-- Name: financial_submetric financial_submetric_financial_metric_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.financial_submetric
    ADD CONSTRAINT financial_submetric_financial_metric_id_fkey FOREIGN KEY (financial_metric_id) REFERENCES public.financial_metric(id) ON DELETE CASCADE;


--
-- Name: financial_types financial_types_financial_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.financial_types
    ADD CONSTRAINT financial_types_financial_category_id_fkey FOREIGN KEY (financial_category_id) REFERENCES public.financial_categories(id) ON DELETE CASCADE;


--
-- Name: fixed_commissions_calculation fixed_commissions_calculation_commission_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fixed_commissions_calculation
    ADD CONSTRAINT fixed_commissions_calculation_commission_type_id_fkey FOREIGN KEY (commission_type_id) REFERENCES public.commission_calculation_types(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: health_checks health_checks_app_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.health_checks
    ADD CONSTRAINT health_checks_app_id_fkey FOREIGN KEY (app_id) REFERENCES public.health_apps(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: lineage_benin lineage_benin_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lineage_benin
    ADD CONSTRAINT lineage_benin_id_fkey FOREIGN KEY (id) REFERENCES public.base_lineage_benin(id);


--
-- Name: lineage_mali lineage_mali_base_lineage_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lineage_mali
    ADD CONSTRAINT lineage_mali_base_lineage_id_fkey FOREIGN KEY (base_lineage_id) REFERENCES public.base_lineage_mali(id);


--
-- Name: navigation_items navigation_items_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.navigation_items
    ADD CONSTRAINT navigation_items_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.navigation_items(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: notification_tracking notification_tracking_upload_tbg_file_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification_tracking
    ADD CONSTRAINT notification_tracking_upload_tbg_file_type_id_fkey FOREIGN KEY (upload_tbg_file_type_id) REFERENCES public.upload_tbg_file_types(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ratio_conso_segment ratio_conso_segment_segment_date_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ratio_conso_segment
    ADD CONSTRAINT ratio_conso_segment_segment_date_id_fkey FOREIGN KEY (segment_date_id) REFERENCES public.segment_date(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: realisation_budget_segment realisation_budget_segment_segment_date_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.realisation_budget_segment
    ADD CONSTRAINT realisation_budget_segment_segment_date_id_fkey FOREIGN KEY (segment_date_id) REFERENCES public.segment_date(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: resource_monthly_values resource_monthly_values_resource_subtype_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.resource_monthly_values
    ADD CONSTRAINT resource_monthly_values_resource_subtype_id_fkey FOREIGN KEY (resource_subtype_id) REFERENCES public.resource_subtype(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: resource_monthly_values resource_monthly_values_resource_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.resource_monthly_values
    ADD CONSTRAINT resource_monthly_values_resource_type_id_fkey FOREIGN KEY (resource_type_id) REFERENCES public.resource_type(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: resource_subtype resource_subtype_resource_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.resource_subtype
    ADD CONSTRAINT resource_subtype_resource_type_id_fkey FOREIGN KEY (resource_type_id) REFERENCES public.resource_type(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: revenue_metadata revenue_metadata_feuil1_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.revenue_metadata
    ADD CONSTRAINT revenue_metadata_feuil1_id_fkey FOREIGN KEY (feuil1_id) REFERENCES public.revenue_uploaded_files(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: revenue_metadata revenue_metadata_feuil5_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.revenue_metadata
    ADD CONSTRAINT revenue_metadata_feuil5_id_fkey FOREIGN KEY (feuil5_id) REFERENCES public.revenue_uploaded_files(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: revenue_metadata revenue_metadata_notification_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.revenue_metadata
    ADD CONSTRAINT revenue_metadata_notification_id_fkey FOREIGN KEY (notification_id) REFERENCES public.notifications(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: revenue_metadata revenue_metadata_pay_go_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.revenue_metadata
    ADD CONSTRAINT revenue_metadata_pay_go_id_fkey FOREIGN KEY (pay_go_id) REFERENCES public.revenue_uploaded_files(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: revenue_metadata revenue_metadata_raw_data_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.revenue_metadata
    ADD CONSTRAINT revenue_metadata_raw_data_id_fkey FOREIGN KEY (raw_data_id) REFERENCES public.revenue_uploaded_files(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: standard_impact_monthly_values standard_impact_monthly_values_standard_impact_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.standard_impact_monthly_values
    ADD CONSTRAINT standard_impact_monthly_values_standard_impact_id_fkey FOREIGN KEY (standard_impact_id) REFERENCES public.standard_impact(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: tbg_alerts tbg_alerts_notification_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbg_alerts
    ADD CONSTRAINT tbg_alerts_notification_id_fkey FOREIGN KEY (notification_id) REFERENCES public.notifications(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: tbg_alerts tbg_alerts_upload_tbg_file_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbg_alerts
    ADD CONSTRAINT tbg_alerts_upload_tbg_file_type_id_fkey FOREIGN KEY (upload_tbg_file_type_id) REFERENCES public.upload_tbg_file_types(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: tbg_formula_edit_history tbg_formula_edit_history_tbg_formula_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbg_formula_edit_history
    ADD CONSTRAINT tbg_formula_edit_history_tbg_formula_id_fkey FOREIGN KEY (tbg_formula_id) REFERENCES public.tbg_formulas(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: tbg_reel_status_history tbg_reel_status_history_notification_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbg_reel_status_history
    ADD CONSTRAINT tbg_reel_status_history_notification_id_fkey FOREIGN KEY (notification_id) REFERENCES public.notifications(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: tbg_report_request tbg_report_request_notification_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbg_report_request
    ADD CONSTRAINT tbg_report_request_notification_id_fkey FOREIGN KEY (notification_id) REFERENCES public.notifications(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: tbg_report_request tbg_report_request_tbg_version_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbg_report_request
    ADD CONSTRAINT tbg_report_request_tbg_version_id_fkey FOREIGN KEY (tbg_version_id) REFERENCES public.tbg_version(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: tbg_report_types tbg_report_types_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbg_report_types
    ADD CONSTRAINT tbg_report_types_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.tbg_report_types(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: tbg_version tbg_version_delta_notification_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbg_version
    ADD CONSTRAINT tbg_version_delta_notification_id_fkey FOREIGN KEY (delta_notification_id) REFERENCES public.notifications(id) ON DELETE SET NULL;


--
-- Name: tbg_version tbg_version_notification_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tbg_version
    ADD CONSTRAINT tbg_version_notification_id_fkey FOREIGN KEY (notification_id) REFERENCES public.notifications(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: telecom_metric telecom_metric_plan_name_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.telecom_metric
    ADD CONSTRAINT telecom_metric_plan_name_id_fkey FOREIGN KEY (plan_name_id) REFERENCES public.prepaid_plan(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: telecom_metric_values telecom_metric_values_prepaid_plan_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.telecom_metric_values
    ADD CONSTRAINT telecom_metric_values_prepaid_plan_id_fkey FOREIGN KEY (prepaid_plan_id) REFERENCES public.prepaid_plan(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: telecom_metric_values telecom_metric_values_telecom_metric_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.telecom_metric_values
    ADD CONSTRAINT telecom_metric_values_telecom_metric_id_fkey FOREIGN KEY (telecom_metric_id) REFERENCES public.telecom_metric(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: upload_sheet_types upload_sheet_types_component_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.upload_sheet_types
    ADD CONSTRAINT upload_sheet_types_component_id_fkey FOREIGN KEY (component_id) REFERENCES public.upload_component_types(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: valorization_tariff_history valorization_tariff_history_tariff_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.valorization_tariff_history
    ADD CONSTRAINT valorization_tariff_history_tariff_id_fkey FOREIGN KEY (tariff_id) REFERENCES public.valorization_tariffs(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: valorization_tariff_schedules valorization_tariff_schedules_notification_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.valorization_tariff_schedules
    ADD CONSTRAINT valorization_tariff_schedules_notification_id_fkey FOREIGN KEY (notification_id) REFERENCES public.notifications(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: valorization_tariff_schedules valorization_tariff_schedules_tariff_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.valorization_tariff_schedules
    ADD CONSTRAINT valorization_tariff_schedules_tariff_id_fkey FOREIGN KEY (tariff_id) REFERENCES public.valorization_tariffs(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: vendor_registry vendor_registry_network_registry_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vendor_registry
    ADD CONSTRAINT vendor_registry_network_registry_id_fkey FOREIGN KEY (network_registry_id) REFERENCES public.network_registry(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: voix_segment voix_segment_segment_date_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.voix_segment
    ADD CONSTRAINT voix_segment_segment_date_id_fkey FOREIGN KEY (segment_date_id) REFERENCES public.segment_date(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict 1HqSZrL1VwueqTXInoUFbgUgu94GJLOApup2B9phG3vD7ZGjIkxAI4DhQ4dZ7mI

