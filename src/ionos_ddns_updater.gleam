import dyn_dns_types.{
  type DynDnsError, type DynDnsResponse, DynDnsDecodeError, DynDnsEntry,
  DynDnsResponseNotOk, UpdateError,
}
import envoy
import gleam/erlang/process
import gleam/http
import gleam/http/request
import gleam/http/response.{type Response}
import gleam/httpc
import gleam/int
import gleam/io
import gleam/json
import gleam/list
import gleam/result
import gleam/string
import repeatedly

pub fn main() {
  let assert Ok(api_key) =
    envoy.get("API_KEY")
    |> result.replace_error("API_KEY environment variable is not set")
  let assert Ok(domain_block) =
    envoy.get("DOMAINS")
    |> result.replace_error("DOMAINS environment variable is not set")
  let domains = string.split(domain_block, ",")

  let update_urls = get_update_urls(domains, api_key)

  case update_urls {
    Error(message) ->
      process.send_abnormal_exit(
        process.self(),
        "get_update_urls encountered an error: " <> string.inspect(message),
      )
    Ok(_) -> {
      update_urls
      |> update_dns_record()
      |> print_update_result(domains)

      repeatedly.call(31_000, Nil, fn(_, _) {
        update_dns_record(update_urls)
        |> print_update_result(domains)

        Nil
      })
      process.receive_forever(process.new_subject())
    }
  }
}

fn update_dns_record(
  result: Result(DynDnsResponse, DynDnsError),
) -> Result(Response(String), DynDnsError) {
  result
  |> result.then(fn(dny_response: DynDnsResponse) {
    let assert Ok(request) = request.to(dny_response.update_url)

    request
    |> request.set_method(http.Get)
    |> httpc.send()
    |> result.replace_error(UpdateError)
  })
}

fn print_update_result(
  update: Result(Response(String), DynDnsError),
  domains: List(String),
) {
  case update {
    Error(message) -> io.println_error(string.inspect(message))
    Ok(_) ->
      io.println(
        "Updated "
        <> int.to_string(list.length(domains))
        <> " domains successfully",
      )
  }
}

fn get_update_urls(
  domains: List(String),
  api_key: String,
) -> Result(DynDnsResponse, DynDnsError) {
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
    |> result.replace_error(DynDnsDecodeError),
  )

  case response.status {
    200 -> {
      json.parse(response.body, dyn_dns_types.dyn_dns_response_decoder())
      |> result.replace_error(DynDnsDecodeError)
    }
    status -> Error(DynDnsResponseNotOk(status))
  }
}
