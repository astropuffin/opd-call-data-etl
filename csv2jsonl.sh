#!/bin/bash
API_KEY=$1
INPUT_FILE=$2
OUTPUT_FILE=$(echo $INPUT_FILE | sed 's/\.csv$/\.jsonl/g')
truncate -s 0 $OUTPUT_FILE
#BigQuery doesn't allow spaces in column names
TMP_FILE=tmp.csv
cat $INPUT_FILE | sed '1s/ /_/g' | sed 's/,NA/,/g' > $TMP_FILE
while read -r entry
do
    ADDRESS=$(echo "$entry" | jq '.Address' | sed 's/ /+/g' | sed 's/&/%26/g')
    IFS=$'\n' read -r -d '' -a ARR < <(curl -sS "https://maps.googleapis.com/maps/api/geocode/json?address=$ADDRESS,+Oakland,+CA&key=$API_KEY" | jq '.results[0].geometry.location | .lng,.lat')
    GEO=$(echo '{"type":"Point"}' | jq '. + {"coordinates":[($lng|tonumber),($lat|tonumber)]}' --arg lng "${ARR[0]}" --arg lat "${ARR[1]}" -c )
    echo "$entry" | jq '. + {"Geo": $geo}' --arg geo "$GEO" -c >> $OUTPUT_FILE
done < <(jq -R -s -f csv2json.jq $TMP_FILE | jq '.[]' -c | jq '.Priority |= tonumber' -c )
rm -f $TMP_FILE
echo "Data outputed to $OUTPUT_FILE"
