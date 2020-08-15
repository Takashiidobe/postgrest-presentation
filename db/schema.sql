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
-- Name: api; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA api;


--
-- Name: rating; Type: TYPE; Schema: api; Owner: -
--

CREATE TYPE api.rating AS ENUM (
    'positive',
    'neutral',
    'negative'
);


--
-- Name: lowercase_email(); Type: FUNCTION; Schema: api; Owner: -
--

CREATE FUNCTION api.lowercase_email() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW.email = LOWER(NEW.email);
  RETURN NEW;
END;
$$;


--
-- Name: trigger_new_user_email(); Type: FUNCTION; Schema: api; Owner: -
--

CREATE FUNCTION api.trigger_new_user_email() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  PERFORM
    pg_notify('email', NEW.email);
  RETURN NEW;
END;
$$;


--
-- Name: trigger_set_timestamp(); Type: FUNCTION; Schema: api; Owner: -
--

CREATE FUNCTION api.trigger_set_timestamp() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: amenity; Type: TABLE; Schema: api; Owner: -
--

CREATE TABLE api.amenity (
    id integer NOT NULL,
    amenity_name text NOT NULL,
    amenity_address text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: amenity_id_seq; Type: SEQUENCE; Schema: api; Owner: -
--

CREATE SEQUENCE api.amenity_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: amenity_id_seq; Type: SEQUENCE OWNED BY; Schema: api; Owner: -
--

ALTER SEQUENCE api.amenity_id_seq OWNED BY api.amenity.id;


--
-- Name: review; Type: TABLE; Schema: api; Owner: -
--

CREATE TABLE api.review (
    review_id integer NOT NULL,
    review_rating api.rating DEFAULT 'neutral'::api.rating,
    review_text text,
    amenity_id integer NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: review_review_id_seq; Type: SEQUENCE; Schema: api; Owner: -
--

CREATE SEQUENCE api.review_review_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: review_review_id_seq; Type: SEQUENCE OWNED BY; Schema: api; Owner: -
--

ALTER SEQUENCE api.review_review_id_seq OWNED BY api.review.review_id;


--
-- Name: users; Type: TABLE; Schema: api; Owner: -
--

CREATE TABLE api.users (
    id integer NOT NULL,
    email text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: api; Owner: -
--

CREATE SEQUENCE api.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: api; Owner: -
--

ALTER SEQUENCE api.users_id_seq OWNED BY api.users.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: amenity id; Type: DEFAULT; Schema: api; Owner: -
--

ALTER TABLE ONLY api.amenity ALTER COLUMN id SET DEFAULT nextval('api.amenity_id_seq'::regclass);


--
-- Name: review review_id; Type: DEFAULT; Schema: api; Owner: -
--

ALTER TABLE ONLY api.review ALTER COLUMN review_id SET DEFAULT nextval('api.review_review_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: api; Owner: -
--

ALTER TABLE ONLY api.users ALTER COLUMN id SET DEFAULT nextval('api.users_id_seq'::regclass);


--
-- Name: amenity amenity_pkey; Type: CONSTRAINT; Schema: api; Owner: -
--

ALTER TABLE ONLY api.amenity
    ADD CONSTRAINT amenity_pkey PRIMARY KEY (id);


--
-- Name: review review_pkey; Type: CONSTRAINT; Schema: api; Owner: -
--

ALTER TABLE ONLY api.review
    ADD CONSTRAINT review_pkey PRIMARY KEY (review_id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: api; Owner: -
--

ALTER TABLE ONLY api.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: api; Owner: -
--

ALTER TABLE ONLY api.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: users lowercase_emails; Type: TRIGGER; Schema: api; Owner: -
--

CREATE TRIGGER lowercase_emails BEFORE INSERT ON api.users FOR EACH ROW EXECUTE FUNCTION api.lowercase_email();


--
-- Name: users notify_on_account_creation; Type: TRIGGER; Schema: api; Owner: -
--

CREATE TRIGGER notify_on_account_creation AFTER INSERT ON api.users FOR EACH ROW EXECUTE FUNCTION api.trigger_new_user_email();


--
-- Name: amenity set_timestamp; Type: TRIGGER; Schema: api; Owner: -
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON api.amenity FOR EACH ROW EXECUTE FUNCTION api.trigger_set_timestamp();


--
-- Name: review set_timestamp; Type: TRIGGER; Schema: api; Owner: -
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON api.review FOR EACH ROW EXECUTE FUNCTION api.trigger_set_timestamp();


--
-- Name: users set_users_timestamp; Type: TRIGGER; Schema: api; Owner: -
--

CREATE TRIGGER set_users_timestamp BEFORE UPDATE ON api.users FOR EACH ROW EXECUTE FUNCTION api.trigger_set_timestamp();


--
-- Name: review review_amenity_id_fkey; Type: FK CONSTRAINT; Schema: api; Owner: -
--

ALTER TABLE ONLY api.review
    ADD CONSTRAINT review_amenity_id_fkey FOREIGN KEY (amenity_id) REFERENCES api.amenity(id);


--
-- PostgreSQL database dump complete
--


--
-- Dbmate schema migrations
--

INSERT INTO public.schema_migrations (version) VALUES
    ('20200809210648');
