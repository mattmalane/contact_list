CREATE TABLE category (
  id serial PRIMARY KEY,
  name text UNIQUE NOT NULL
);

CREATE TABLE contacts (
  id serial PRIMARY KEY,
  name text UNIQUE NOT NULL,
  phone_number varchar(22),
  email_address text,
  category_id integer REFERENCES category (id)
);
