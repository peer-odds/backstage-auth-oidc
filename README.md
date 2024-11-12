# [Backstage](https://backstage.io)

## Generate session secret
Run this command to generate a session secret:

```
openssl rand -base64 32
```
Add this secret to the `AUTH_SESSION_SECRET` environment variable in the `app-config.yaml` file.
or
```
export AUTH_SESSION_SECRET=<secret>
```
else <br>
if don't want to add in env use this command:
```
export AUTH_SESSION_SECRET=$(openssl rand -base64 32)
```

## Set up `keycloak` configuration
```
auth:
  session:
    secret: ${AUTH_SESSION_SECRET}
  providers:
    keycloak-provider:
      development:
        metadataUrl: https://<keycloakUrl>/realms/<realmid>/.well-known/openid-configuration
        clientId: <clientId>
        clientSecret: <clientSecret>
        prompt: login
        scopes:
          - openid
          - profile
          - email
```


## To start the app, run:

```sh
yarn install
yarn dev
```