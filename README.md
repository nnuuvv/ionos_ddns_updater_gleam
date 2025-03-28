# ionos_ddns_updater

[![Package Version](https://img.shields.io/hexpm/v/ionos_ddns_updater)](https://hex.pm/packages/ionos_ddns_updater)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/ionos_ddns_updater/)


Uses `$API_KEY` and `$DOMAINS` environment variables to update Ionos Dynamic DNS records

`$API_KEY` your x-api-key (see <https://developer.hosting.ionos.de/docs/getstarted>)

`$DOMAINS` a comma seperated list of domains / subdomains to update or create


Further documentation can be found at <https://hexdocs.pm/ionos_ddns_updater>.

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
```

Ionos api docs <https://developer.hosting.ionos.de/docs/dns>
