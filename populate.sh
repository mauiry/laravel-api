#/bin/bash

# This script is used to populate the database with dummy data for testing purposes
# The population script iterates through an array of JSON objects and sends a POST request to the API using cURL

# Array of JSON objects
declare -a arr=(
'{"barcode":"5784","product":"Wood Chips - Regular","description":"Vesic fistula repair NEC","stock":65,"price":44.38}'
'{"barcode":"2189","product":"Assorted Desserts","description":"Nasal repair NEC","stock":28,"price":20.13}'
'{"barcode":"7885","product":"Ecolab - Hobart Upr Prewash Arm","description":"Oth dx proced-femur","stock":31,"price":40.83}'
'{"barcode":"9061","product":"Wine - White, Mosel Gold","description":"Bact smear-spleen/marrow","stock":42,"price":49.16}'
'{"barcode":"2095","product":"Duck - Whole","description":"Elecmag hear dev implant","stock":79,"price":8.11}'
'{"barcode":"4497","product":"Foam Espresso Cup Plain White","description":"Lap rem gast restric dev","stock":63,"price":56.33}'
'{"barcode":"625","product":"Juice - Lemon","description":"Orchiopexy","stock":42,"price":53.03}'
'{"barcode":"6696","product":"Soup - Clam Chowder, Dry Mix","description":"Fallopian tube dilation","stock":21,"price":11.52}'
'{"barcode":"6212","product":"Huck White Towels","description":"Open testicular biopsy","stock":27,"price":72.49}'
'{"barcode":"8922","product":"Pie Box - Cello Window 2.5","description":"Cystometrogram","stock":30,"price":25.45}'
)

# Iterate through the array and send a POST request to the API
for i in "${arr[@]}"
do
    curl -X 'POST' \
    'http://localhost:8000/api/product' \
    -H 'accept: application/json' \
    -H 'Content-Type: application/json' \
    -d "$i"
done    