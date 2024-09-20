tables=(
    "evm_logs"
    "evm_move_hash"
    "evm_error_hash"
)

for table in "${tables[@]}"
do
    curl 'http://127.0.0.1:8090/v1/metadata' \
      -H 'content-type: application/json' \
      --data-raw '{
        "type":"bulk",
        "source":"indexer-v2",
        "args":[{
          "type":"pg_track_table",
          "args":{
            "table":{
              "name":"'"$table"'",
              "schema":"public"
            },
            "source":"indexer-v2"
          }
        }]
      }'

    echo "Request sent for table $table"
    sleep 1
done
