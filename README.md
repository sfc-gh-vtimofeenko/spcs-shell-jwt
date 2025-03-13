This is a reference JWT > authentication token exchange mechanism written in
shell script that implements [Snowpark Container Services programamtic
access][doc].

It is useful on its own in environments where python or the cryptography/pyJWT
dependencies are not available.

# Installation

- `jwt-cli`
- `curl`

`nix` is optional, but it is used for the CI and development.

# Limitations

1. Passphrase-protected keys are not supported. If the key is protected by a
   passphrase, use Snowflake CLI to generate the JWT and remaining curl commands
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
