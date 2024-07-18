addresses=(
    "0x5135d3d458e4d4567026220738928390dc3ae79cc35fa6065119d0bc7cf59166"
    "0x45b956a878da0357805a735ce9f7539890565026d2e94579a957656be3c502ab"
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
