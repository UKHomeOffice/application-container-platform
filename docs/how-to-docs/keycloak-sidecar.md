# Using Keycloak Sidecar

The keycloak gatekeeper (also know as the keycloak sidecar and soon to be know as [louketo-proxy](https://github.com/louketo/louketo-proxy) ) is a general purpose adapter for Keycloak.

## Keycloak sidecar using no role

Below is a example of a keycloak sidecar which uses a no role for all URIs. A user trying to access the URI's of this application will need to be authenticated, but will not require any roles. In this example the configuration options are passed in through environment variables and command arguments.

```yaml
- name: keycloak-gatekeeper
  image: quay.io/keycloak/keycloak-gatekeeper:10.0.0
  ports:
    - containerPort: 10443
      name: https
      protocol: TCP
  env:
      # the secret of the client you are using. You can find this secret under the credentials tab of the client
    - name: PROXY_CLIENT_SECRET
      valueFrom:
        secretKeyRef:
          key: client_secret
          name: gatekeeper
  args:
    # specifies what port the keycloak-gatekeeper is listening on
    - --listen=:10443
    # specififes which client is used
    - --client-id=gatekeeper
    # the url which is used to retrieve the OpenID configuration
    - --discovery-url=https://sso-dev.notprod.homeoffice.gov.uk/auth/realms/hod-test
    # the endpoint where requests are proxied to
    - --upstream-url=https://127.0.0.1:10444
    # The location of the certificate you wish the proxy to use for TLS support
    - --tls-cert=/certs/tls.crt
    # The location of a private key for TLS
    - --tls-private-key=/certs/tls.key
    # URls that you wish to protect.
    - --resources=uri=/*
  resources:
    limits:
      memory: 100Mi
    requests:
      memory: 50Mi
  volumeMounts:
    - mountPath: /certs
      name: certs
    - mountPath: /etc/ssl/certs
      name: bundle
      readOnly: true
```

## Keycloak sidecar using single role

To use a specific role in addition to authentication, replace the `--resources=uri=/*` line in the above code with `--resources=uri=/*|roles=<name of role>`. This role should be assigned to the client specified in the client-id which can be done under the Scope tab of the client, as well as the broker client

## Keycloak sidecar using multiple roles

You can also use multiple roles for different URIs within your application. An example of this can be found below.

```yaml
- name: keycloak-gatekeeper
  image: quay.io/keycloak/keycloak-gatekeeper:10.0.0
  ports:
    - containerPort: 10443
      name: https
      protocol: TCP
  env:
    - name: PROXY_CLIENT_SECRET
      valueFrom:
        secretKeyRef:
          key: client_secret
          name: gatekeeper
  args:
    # specifies what port the keycloak-gatekeeper is listening on
    - --listen=:10443
    # specififes which client is used
    - --client-id=gatekeeper
    # the url which is used to retrieve the OpenID configuration
    - --discovery-url=https://sso-dev.notprod.homeoffice.gov.uk/auth/realms/hod-test
     # the endpoint where requests are proxied to
    - --upstream-url=https://127.0.0.1:10444
    - --tls-cert=/certs/tls.crt
    - --tls-private-key=/certs/tls.key
    # A user trying to access these URIs must have these roles to be successful
    - --resources=uri=/*|roles=users
    - --resources=uri=/admin/*|roles=admin
  resources:
    limits:
      memory: 100Mi
    requests:
      memory: 50Mi
  volumeMounts:
    - mountPath: /certs
      name: certs
    - mountPath: /etc/ssl/certs
      name: bundle
      readOnly: true
```

For more information and configuration options, please take a look at the [Keycloak configuration options page](https://www.keycloak.org/docs/latest/securing_apps/#configuration-options)
