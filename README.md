This is a reference JWT > authentication token exchange mechanism written in
shell script that implements [Snowpark Container Services programmatic
access][doc].

It is useful on its own in environments where python or the cryptography/pyJWT
dependencies are not available.

# Usage

## Generating JWT through Snowflake CLI

Run the script as:

``` shell
JWT=$(snow connection generate-jwt) ./src/spcs-jwt-connect.sh
```

## Generating JWT without Snowflake CLI

This approach requires either specifying environment variables or providing
replies to the script live. See the [script source][./src/spcs-jwt-connect.sh]
for more information.

# Installation

Install:

- `jwt-cli` (or Snowflake CLI >=3.3.0)
- `curl`

`nix` is optional, but it is used for the CI and development.

# Limitations

1. Passphrase-protected keys are not supported when generating a key using
   `jwt-cli`. If the key is protected by a passphrase, use Snowflake CLI to
   generate the JWT and remaining curl commands
2. `OPENSSH PRIVATE KEY` keys are not supported, the key must be RSA

# See also

1. [Sample python code to access SPCS endpoint from the documentation][tutorial]
2. (Only JWT generation) [Python code][sqlapi]
3. (Only JWT generation) [SnowSQL][snowsql]
4. (Only JWT generation) [Snowflake CLI][snowcli]: `snow connection generate-jwt`

[doc]: https://docs.snowflake.com/en/developer-guide/snowpark-container-services/working-with-services#public-endpoint-access-from-outside-snowflake-and-authentication
[snowsql]: https://community.snowflake.com/s/article/How-To-Use-SnowSQL-to-generate-JWT-Token-for-Key-Pair-Authentication-Mechanism
[sqlapi]: https://docs.snowflake.com/en/developer-guide/sql-api/authenticating#generating-a-jwt-in-python
[tutorial]: https://docs.snowflake.com/en/developer-guide/snowpark-container-services/tutorials/tutorial-1#optional-access-the-public-endpoint-programmatically
[snowcli]: https://docs.snowflake.com/developer-guide/snowflake-cli/index
