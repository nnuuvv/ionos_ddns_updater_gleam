import dyn_dns_types.{type DynDnsResponse, DynDnsEntry}
import envoy
import gleam/erlang/process
import gleam/http
import gleam/http/request
import gleam/http/response.{type Response}
import gleam/httpc
import gleam/json
import gleam/result
import gleam/string
import repeatedly

pub fn main() {
  let assert Ok(api_key) = envoy.get("API_KEY")
  let assert Ok(domain_block) = envoy.get("DOMAINS")
  let domains = string.split(domain_block, ",")

  let _ = update_dyndns(domains, api_key)

  repeatedly.call(31_000, Nil, fn(_, _) {
    let _ = update_dyndns(domains, api_key)

    Nil
  })
  process.receive_forever(process.new_subject())
}

fn update_dyndns(
  domains: List(String),
  api_key: String,
) -> Result(Response(String), Nil) {
  get_update_urls(domains, api_key)
  |> echo
  |> update_dns_record
  |> echo
}

fn get_update_urls(
  domains: List(String),
  api_key: String,
) -> Result(DynDnsResponse, Nil) {
  let dyn_entry = DynDnsEntry(domains, "My Dynamic Dns")

  let assert Ok(request) =
    request.to("https://api.hosting.ionos.com/dns/v1/dyndns")

  use response: Response(String) <- result.then(
    request
    |> request.set_method(http.Post)
    |> request.set_header("X-API-Key", api_key)
    |> request.set_header("Content-Type", "application/json")
    |> request.set_header("accept", "application/json")
    |> request.set_body(
      json.to_string(dyn_dns_types.encode_dyn_dns_entry(dyn_entry)),
    )
    |> httpc.send()
    |> result.replace_error(Nil),
  )

  case response.status {
    200 -> {
      json.parse(response.body, dyn_dns_types.dyn_dns_response_decoder())
      |> result.replace_error(Nil)
    }
    _ -> Error(Nil)
  }
}

fn update_dns_record(
  result: Result(DynDnsResponse, Nil),
) -> Result(Response(String), Nil) {
  result
  |> result.then(fn(dny_response: DynDnsResponse) {
    let assert Ok(request) = request.to(dny_response.update_url)

    request
    |> request.set_method(http.Get)
    |> httpc.send()
    |> result.replace_error(Nil)
  })
}
