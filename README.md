# ionos_ddns_updater

Uses `$API_KEY` and `$DOMAINS` environment variables to update Ionos Dynamic DNS records

`$API_KEY` your x-api-key (see <https://developer.hosting.ionos.de/docs/getstarted>)

`$DOMAINS` a comma seperated list of domains / subdomains to update or create

```sh
docker compose up -d --build
```

Ionos api docs <https://developer.hosting.ionos.de/docs/dns>


[Example deployment](https://github.com/nnuuvv/docker/blob/7f5f7bc0c53e55f45d65ecaa5c493921d7f8f33e/ionos-ddns-updater/docker-compose.yml)  
With a .env file like this:
```
API_KEY=YOUR-X-API-KEY 
DOMAINS=example.com,second.example.com,third.example.com
```
