### Proxy movement faucet token

### Petra wallet
>
> The default faucet amount has been changed to 1

```bash
curl --location http://127.0.0.1:3001/fund?auth_key=0x6a3fe01b215038663e4bdeaeb41e18047695c4f5e2affd74f343447a4a94d3ab
```

### Aptos CLI
>
> The default faucet amount has been changed to 1

```bash
curl -X POST --location http://127.0.0.1:3001/mint?auth_key=0x6a3fe01b215038663e4bdeaeb41e18047695c4f5e2affd74f343447a4a94d3ab
```

### Faucet with Google Captcha

```bash
curl --location 'http://127.0.0.1:3001/batch_mint?address=0x6a3fe01b215038663e4bdeaeb41e18047695c4f5e2affd74f343447a4a94d3ab' \
--header 'token: google_token'
```
