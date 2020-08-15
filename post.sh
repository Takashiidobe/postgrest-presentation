#!/bin/bash

curl --location --request POST 'localhost:4000/amenity' \
--header 'Content-Type: application/json' \
--header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoiYXBpX3VzZXIifQ.zYAgT3olR2cyerCLr8NjojcmIkjWU2qmp68xC5XSpTo' \
--data-raw '{
    "amenity_name": "Lazlo'\''s",
    "amenity_address": "210 N 7th St, Lincoln, NE 68508"
}'
