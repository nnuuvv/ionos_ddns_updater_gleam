import gleam/dynamic/decode
import gleam/json

pub type DynDnsResponse {
  DynDnsResponse(
    bulk_id: String,
    update_url: String,
    domains: List(String),
    description: String,
  )
}

pub fn dyn_dns_response_decoder() -> decode.Decoder(DynDnsResponse) {
  use bulk_id <- decode.field("bulkId", decode.string)
  use update_url <- decode.field("updateUrl", decode.string)
  use domains <- decode.field("domains", decode.list(decode.string))
  use description <- decode.field("description", decode.string)
  decode.success(DynDnsResponse(bulk_id:, update_url:, domains:, description:))
}

pub type DynDnsEntry {
  DynDnsEntry(domains: List(String), description: String)
}

pub fn encode_dyn_dns_entry(dyn_dns_entry: DynDnsEntry) -> json.Json {
  json.object([
    #("domains", json.array(dyn_dns_entry.domains, json.string)),
    #("description", json.string(dyn_dns_entry.description)),
  ])
}
