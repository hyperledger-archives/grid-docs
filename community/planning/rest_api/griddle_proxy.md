# Griddle Proxy

<!--
  Copyright 2018-2022 Cargill Incorporated
  Licensed under Creative Commons Attribution 4.0 International License
  https://creativecommons.org/licenses/by/4.0/
-->

## Summary

Griddle is a client daemon that will allow for requests to be signed,
if needed, and proxied to a Grid Daemon.

## Motivation

Griddle's Rest API, including signing utility, will be used to
interact with Grid. Griddle can be deployed in a different security
zone than the Grid daemon. Read requests are immediately proxied to
the grid daemon. Griddle endpoints that accept transactions will use a
private key to construct and sign the resulting batch, then proxy the
request payload to the grid daemon’s batches endpoint.

## Guide-level explanation

As a proxy for the Grid daemon, the Griddle REST API will send all
read requests to the Grid daemon. The request is turned into a generic
request object that maintains all integral pieces of the initial
request. It will then send the request to the corresponding endpoint.
The proxy will respond with the data it received from the endpoint. If
the proxy encounters an error, it will return the error data as
received.

The Griddle rest endpoint that will receive the request needs to copy
the request to be sent to the grid daemon. The griddle endpoint will
use a client in order to send the request to the grid daemon. The
proxy client will send the request to the Grid daemon and return the
JSON response as a generic JSON value. The Griddle endpoint will then
return this JSON data received by the client.

## Reference-level explanation

The proxying for griddle is able to be genericized, as a trait. The
trait follows suit of other clients, in that it is able to be sent
over threads. The proxy client trait is defined below:

```rust
pub trait ProxyClient: Send {
    fn proxy(&self, req: ProxyRequestBuilder) -> ProxyResponse;

    fn cloned_box(&self) -> Box<dyn ProxyClient>;
}
```

The first method, proxy, is a generic method for sending a request to
the proxy client’s internal `url`. The method takes in a generic
`ProxyRequestBuilder` object, which reflects the original request,
excluding the request’s `uri`. The builder differs from the
`ProxyRequest` in that all fields are optional. The builder has a
`build` method that returns the resulting `ProxyRequest` or an error
if any required fields are not supplied. The `ProxyClient` provides
the request’s `uri` using its internal `url` value.

The `ProxyRequest` object is defined below:

```rust
pub struct ProxyRequest {
    headers: HeaderList,
    uri: String,
    path: String,
    query_params: Option<String>,
    body: Option<ProxyRequestBody>,
    method: ProxyMethod,
}
```

The request headers are represented as bytes. To avoid raw bytes in
the public API, the `HeaderName` and `HeaderValue` types wrap the
header bytes.

```rust
pub type HeaderName = Vec<u8>;

pub type HeaderValue = Vec<u8>;

pub type HeaderList = Vec<(HeaderName, HeaderValue)>;
```

The body of the request is generic, representing the basic structure
of an HTTP request body.

```rust
pub struct ProxyRequestBody {
    content_type: String,
    content: Vec<u8>,
}
```

The `ProxyMethod` struct supports the basic HTTP request methods defined in
[HTTP RFC 7231](https://datatracker.ietf.org/doc/html/rfc7231#section-4.1). The
enum also includes methods, `Patch` and `Custom`, to reflect the methods
provided by the REST API backend. The REST API is implemented using
[Actix-Web](https://crates.io/crates/actix-web), which uses the
[Http](https://crates.io/crates/http) crate’s `Method` implementation.
`ProxyMethod` is defined below:

```rust
pub enum ProxyMethod {
    Get,
    Post,
    Put,
    Delete,
    Connect,
    Head,
    Options,
    Trace,
    Patch,
    Custom(Vec<u8>),
}
```

The `ProxyClient` responds with a `ProxyResponse` object. This struct reflects
a basic HTTP response, containing a message represented by a String and the
status code represented as a u16 value. This allows the message and status code
to be converted into any other representation of an HTTP response. This object
is defined below:

```rust
pub struct ProxyResponse {
    status_code: u16,
    body: ProxyResponseBody,
}

pub struct ProxyResponseBody {
    content: Vec<u8>,
}
```

The `ProxyResponseBody` contains the body of the response, represented as
bytes. This value may be deserialized as needed by the endpoint receiving this
response.

The second method, `cloned_box`, allows the object to be used as a boxed trait
and moved to the REST API thread.

The endpoint that retrieves a `GET` request to proxy will have a signature
similar to the following:

```rust
pub async fn proxy_get(
    req: HttpRequest,
    proxy_client: web::Data<Box<dyn ProxyClient>>,
) -> HttpResponse;
```

This endpoint holds the `proxy_client` that will be used to send the request to
the Grid Daemon backend. The `HttpRequest` is then converted into a
`ProxyRequest` and sent to the proxy client for handling. This method would be
able to be used across multiple `GET` endpoints, as it returns a generic JSON
value as returned by the daemon’s endpoints.

## Unresolved questions

Response object is relatively simplified. Is there value for making this object
more robust, such as returning headers from the original HTTP response?
