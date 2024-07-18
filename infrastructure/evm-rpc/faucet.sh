# we need to fund some addresses to make sure they have enough balance to send evm tx to the move chain
addresses_move=(
    "0xef484a99792ccba1be68dc29cdad33726f6e6c16817dfff98a7f6a5fa19c9b9b"
    "0xf8be0c08312090f3f9f17ec76d1575d94c032c78c235c3eee562cc5c7b332fcd"
)

amount=1000000000000

for address in "${addresses_move[@]}"
do
    response=$(curl --location --silent --show-error --header 'Content-Type: application/json' --data '{
        "address": "'"$address"'",
        "amount": '"$amount"'
    }' http://127.0.0.1:8081/fund)

    echo "Response for address $address: $response"

    sleep 1
done

# for eth_call, if user not set from , it will use this address instead , so we need to fund this address
addresses_eth=(
    "0x0000000000000000000000000000000000000001"
)

for address in "${addresses_eth[@]}"
do
    response=$(curl --location 'http://127.0.0.1:8998' \
    --header 'Content-Type: application/json' \
    --data '{
        "id": 1,
        "method": "eth_faucet",
        "jsonrpc": "2.0",
        "params": ['"$address"']
    }')
    echo "Response for address $address: $response"

    sleep 1
done