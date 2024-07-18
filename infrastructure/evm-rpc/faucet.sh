addresses=(
    "0xf8be0c08312090f3f9f17ec76d1575d94c032c78c235c3eee562cc5c7b332fcd"
    "0xef484a99792ccba1be68dc29cdad33726f6e6c16817dfff98a7f6a5fa19c9b9b"
)

amount=1000000000000

for address in "${addresses[@]}"
do
    response=$(curl --location --silent --show-error --header 'Content-Type: application/json' --data '{
        "address": "'"$address"'",
        "amount": '"$amount"'
    }' http://127.0.0.1:8081/fund)

    echo "Response for address $address: $response"

    sleep 1
done
