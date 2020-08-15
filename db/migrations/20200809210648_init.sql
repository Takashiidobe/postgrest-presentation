-- migrate:up
CREATE SCHEMA api;

-- CREATE EXTENSION IF NOT EXISTS citext;
SET search_path TO api;

-- Ratings enum instead of asking user to type in
CREATE TYPE api.rating AS enum (
  'positive',
  'neutral',
  'negative'
);

CREATE OR REPLACE FUNCTION trigger_set_timestamp ()
  RETURNS TRIGGER
  AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION trigger_new_user_email ()
  RETURNS TRIGGER
  AS $$
BEGIN
  PERFORM
    pg_notify('email', NEW.email);
  RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION lowercase_email ()
  RETURNS TRIGGER
  AS $$
BEGIN
  NEW.email = LOWER(NEW.email);
  RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE TABLE IF NOT EXISTS api.amenity (
  id serial PRIMARY KEY,
  amenity_name text NOT NULL,
  amenity_address text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS api.users (
  id serial PRIMARY KEY,
  email text NOT NULL UNIQUE,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS api.review (
  review_id serial PRIMARY KEY,
  review_rating api.rating DEFAULT 'neutral',
  review_text text,
  amenity_id integer NOT NULL REFERENCES api.amenity (id),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TRIGGER lowercase_emails
  BEFORE INSERT ON api.users
  FOR EACH ROW
  EXECUTE PROCEDURE lowercase_email ();

CREATE TRIGGER notify_on_account_creation
  AFTER INSERT ON api.users
  FOR EACH ROW
  EXECUTE PROCEDURE trigger_new_user_email ();

CREATE TRIGGER set_users_timestamp
  BEFORE UPDATE ON api.users
  FOR EACH ROW
  EXECUTE PROCEDURE trigger_set_timestamp ();

CREATE TRIGGER set_timestamp
  BEFORE UPDATE ON api.amenity
  FOR EACH ROW
  EXECUTE PROCEDURE trigger_set_timestamp ();

CREATE TRIGGER set_timestamp
  BEFORE UPDATE ON api.review
  FOR EACH ROW
  EXECUTE PROCEDURE trigger_set_timestamp ();

-- Create roles
CREATE ROLE api_user nologin;

CREATE ROLE api_anon nologin;

DROP ROLE IF EXISTS authenticator;

CREATE ROLE authenticator WITH NOINHERIT LOGIN PASSWORD 'password';

GRANT api_user TO authenticator;

GRANT api_anon TO authenticator;

GRANT USAGE ON SCHEMA api TO api_anon;

GRANT SELECT ON api.amenity TO api_anon;

GRANT SELECT ON api.review TO api_anon;

GRANT USAGE ON SCHEMA api TO api_user;

GRANT ALL ON api.amenity TO api_user;

GRANT ALL ON api.review TO api_user;

GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA api TO api_user;

-- migrate:down
DROP TABLE IF EXISTS api.amenity CASCADE;

DROP TABLE IF EXISTS api.review CASCADE;

DROP TABLE IF EXISTS api.users CASCADE;

DROP TYPE api.rating;

DROP TRIGGER IF EXISTS lowercase_email ON api.users;

DROP TRIGGER IF EXISTS lowercase_emails ON api.users;

DROP TRIGGER IF EXISTS trigger_new_user_email ON api.users;

DROP TRIGGER IF EXISTS trigger_set_timestamp ON api.users;

DROP TRIGGER IF EXISTS trigger_set_timestamp ON api.review;

DROP SCHEMA api CASCADE;

REASSIGN OWNED BY api_anon TO app_user;

DROP ROLE api_anon;

REASSIGN OWNED BY api_user TO app_user;

DROP ROLE api_user;

REASSIGN OWNED BY authenticator TO app_user;

DROP ROLE authenticator;

