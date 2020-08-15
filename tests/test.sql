-- Start transaction and plan the tests.
BEGIN;
SET ROLE api_user;
SELECT
  plan (1);
INSERT INTO api.amenity (amenity_name, amenity_address)
  VALUES ('The Oven', '210 N 7th St, Lincoln, NE 68508');
SELECT
  *
FROM
  api.amenity;
SELECT
  pass ('worked');
SELECT
  *
FROM
  finish ();
ROLLBACK;

