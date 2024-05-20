### sync evm metadata

```bash
curl -d '{"type":"replace_metadata", "args":'"$(cat hasura_metadata.json)"'}' http://localhost:8090/v1/metadata
```