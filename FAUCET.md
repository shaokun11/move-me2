### Instructions for the Movement Faucet

> Please replace the `google_recaptcha_token` value in the following example requests with the actual token.  
> Please obtain the key from the [Google reCAPTCHA website](https://developers.google.com/recaptcha/docs/display).

### M1

```bash
curl 'https://aptos.devnet.m1.movementlabs.xyz/batch_mint?address=0x873edfd10eb31d51142ba278d0c1dad4a67e1ad3e42ec842afc3216bbb929e05' \
--header 'Token: google_recaptcha_token'
```

- Successful response:
```json
["0x3d00d791d63d1ec6fce429b1b4c83a5d4407b756340fa0564818904aca50cdb4"]
```

### M2

```bash
curl --location 'https://sui.devnet.m2.movementlabs.xyz/faucet/web' \
--header 'token: google_recaptcha_token' \
--header 'Content-Type: application/json' \
--data '{
    "FixedAmountRequest": {
        "recipient":"0x873edfd10eb31d51142ba278d0c1dad4a67e1ad3e42ec842afc3216bbb929e05"
    }
}'
```
- Successful response:
```json
{
    "code":200
}
```

### MEVM

```bash
curl --location 'https://mevm.devnet.m1.movementlabs.xyz' \
--header 'token: google_recaptcha_token' \
--header 'Content-Type: application/json' \
--data '{
    "id": "1",
    "jsonrpc": "2.0",
    "method": "eth_batch_faucet",
    "params": [
        "0xB8f7166496996A7da21cF1f1b04d9B3E26a3d077"
    ]
}'
```
- Successful response:
```json
{
    "jsonrpc": "2.0",
    "id": 1,
    "result": "0x27082064c7bcbf7e322aca7e0bbc9f836869c116273407a044000ca5d4f0ce20"
}
```