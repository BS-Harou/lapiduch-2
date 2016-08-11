-- Schema: public

DROP SCHEMA public CASCADE;

CREATE SCHEMA public AUTHORIZATION postgres;

GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO public;
COMMENT ON SCHEMA public IS 'standard public schema';



-- Sequence: public.users_id_seq

CREATE SEQUENCE public.users_id_seq
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START 4
  CACHE 1;
-- ALTER TABLE public.users_id_seq OWNER TO postgres;

-- Table: public.users

CREATE TABLE public.users (
  id integer NOT NULL DEFAULT nextval('users_id_seq'::regclass),
  username character varying(16),
  norm_username character varying(16),
  password character varying(256),
  salt character varying(128),
  email character varying(64),
  perm character varying(16),
  avatar character varying(128),
  sex character varying(16),
  motto character varying(128),
  web character varying(128),
  created_at bigint,
  activate character varying(64),
  CONSTRAINT users_pk PRIMARY KEY (id),
  CONSTRAINT users_email_uq UNIQUE (email),
  CONSTRAINT users_username_uq UNIQUE (username)
)
WITH (OIDS=FALSE);
-- ALTER TABLE public.users OWNER TO postgres;



-- Sequence: public.categories_id_seq

CREATE SEQUENCE public.categories_id_seq
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START 1
  CACHE 1;
-- ALTER TABLE public.categories_id_seq OWNER TO postgres;

-- Table: public.categories

CREATE TABLE public.categories (
  id integer NOT NULL DEFAULT nextval('categories_id_seq'::regclass),
  name character varying(64),
  norm_name character varying(64),
  description character varying(128),
  created_at bigint,
  CONSTRAINT categories_id_pk PRIMARY KEY (id)
)
WITH (OIDS=FALSE);
-- ALTER TABLE public.categories OWNER TO postgres;




-- Sequence: public.categories_owners_id_seq

CREATE SEQUENCE public.categories_owners_id_seq
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START 1
  CACHE 1;
-- ALTER TABLE public.categories_owners_id_seq OWNER TO postgres;

-- Table: public.categories_owners

CREATE TABLE public.categories_owners (
  id integer NOT NULL DEFAULT nextval('categories_owners_id_seq'::regclass),
  user_id integer,
  category_id integer,
  level integer,
  CONSTRAINT categories_owners_id_pk PRIMARY KEY (id)
)
WITH (OIDS=FALSE);
-- ALTER TABLE public.categories_owners OWNER TO postgres;




-- Sequence: public.clubs_id_seq

CREATE SEQUENCE public.clubs_id_seq
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START 1
  CACHE 1;
-- ALTER TABLE public.clubs_id_seq OWNER TO postgres;

-- Table: public.clubs

CREATE TABLE public.clubs (
  id integer NOT NULL DEFAULT nextval('clubs_id_seq'::regclass),
  category_id integer,
  name character varying(64),
  norm_name character varying(64),
  description character varying(128),
  created_at bigint,
  CONSTRAINT clubs_id_pk PRIMARY KEY (id)
)
WITH (OIDS=FALSE);
-- ALTER TABLE public.clubs OWNER TO postgres;



-- Sequence: public.clubs_owners_id_seq

CREATE SEQUENCE public.clubs_owners_id_seq
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START 1
  CACHE 1;
-- ALTER TABLE public.clubs_owners_id_seq OWNER TO postgres;

-- Table: public.clubs_owners

CREATE TABLE public.clubs_owners (
  id integer NOT NULL DEFAULT nextval('clubs_owners_id_seq'::regclass),
  user_id integer,
  club_id integer,
  level integer,
  CONSTRAINT clubs_owners_id_pk PRIMARY KEY (id)
)
WITH (OIDS=FALSE);
-- ALTER TABLE public.clubs_owners OWNER TO postgres;



-- Sequence: public.posts_id_seq

CREATE SEQUENCE public.posts_id_seq
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START 1
  CACHE 1;
-- ALTER TABLE public.posts_id_seq OWNER TO postgres;

-- Table: public.posts

CREATE TABLE public.posts (
  id integer NOT NULL DEFAULT nextval('posts_id_seq'::regclass),
  title character varying(64),
  message text,
  created_at bigint,
  user_id integer,
  club_id integer,
  CONSTRAINT posts_id_pk PRIMARY KEY (id)
)
WITH (OIDS=FALSE);
-- ALTER TABLE public.posts OWNER TO postgres;

