This is a reference JWT > authentication token exchange mechanism written in
shell script that implements [Snowpark Container Services programamtic
access][doc].

It is useful on its own in environments where python or the cryptography/pyJWT
dependencies are not available.

# Installation

- `jwt-cli`
- `curl`

`nix` is optional, but it is used for the CI and development.


[doc]: https://docs.snowflake.com/en/developer-guide/snowpark-container-services/working-with-services#public-endpoint-access-from-outside-snowflake-and-authentication
