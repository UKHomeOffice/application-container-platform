## Chisel

> *The Problem*: we want to provide services running in ACP access to the third party services as well as the ability to have user-based access controls. At present network access in ACP is provided via Calico, but this becomes redundant when the traffic egresses the cluster. Simply peering networks together either through VPC peering or VPN connections doesn't provide the controls we want. We could rely on user-authentication on third-party service but not all services are authenticated (take POISE) and beyond that peering networks provides no means of auditing traffic that is traversing the bridged networks.

One pattern we are exploring is the use of a proxy cluster with an authenticated side-kick to route traffic and provide end-to-end encryption. Both ACP Notprod and Prod are peered to an respective proxy cluster that is running a [Chisel](https://github.com/jpillora/chisel) server. Below is rough idea of how the chisel service works.

![alt text](https://github.com/UKHomeOffice/application-container-platform/blob/master/docs/how-to-docs/pics/chisel.png "Chisel")

The workflow for this is as follows, note the following example is assuming we have peered with a network in the proxy cluster which is exposing x services.

* A request via BAU the provisioning of a service on the Chisel server.
* Once done user is provided credentials for service.
* You add into your deployment a chisel container running in client mode and add the configuration as described to route the traffic. In regard to DNS and hostnames, kubernetes pods permit the user to add host entries into the container DNS, enabling you to override.
* The traffic is picked up, encrypted over an ssh tunnel and pushed to the Chisel server where the user credentials are evaluated. Assuming everything is ok the traffic is then proxied on to destination.

#### A Working Example

We have a two services called `example-api.internal.homeoffice.gov.uk` and `another-service.example.com` and we wish to consume the API from the pods. Lets assume the service has already been provisioned on the Chisel server and we have the credentials at hand.

```YAML
kind: Deployment
metadata:
  name: consumer
spec:
  replicas: 1
  template:
    metadata:
      labels:
        name: consumer
    spec:
      hostAliases:
      - hostnames:
        - another-service.example.com
        - example-api.internal.homeoffice.gov.uk
        ip: 127.0.0.1
      securityContext:
        fsGroup: 1000
      volumes:
      - name: bundle
        configMap:
          name: bundle
      containers:
      - name: consumer
        image: quay.io/ukhomeofficedigital/someimage:someversion
      - name: chisel
        image: quay.io/ukhomeofficedigital/chisel:v1.3.1 # Both Chisel Client & Server versions must match
        securityContext:
          runAsNonRoot: true
        env:
        # essentially user:password
        - name: AUTH
          valueFrom:
            secretKeyRef:
              name: chisel
              key: chisel.auth
        # this optional BUT recommended this is fingerprint for the SSH service
        - name: CHISEL_KEY
          valueFrom:
            secretKeyRef:
              name: chisel
              key: chisel.key
        args:
        - client
        - -v
        # this the chisel endpoint service hostname
        - gateway-internal.px.notprod.acp.homeoffice.gov.uk:443
        # this is saying listen on port 10443 and route all traffic to another-service.example.com:443 endpoint
        - 127.0.0.1:10443:another-service.example.com:443
        - 127.0.0.1:10444:example-api.internal.homeoffice.gov.uk:443
        volumeMounts:
        - name: bundle
          mountPath: /etc/ssl/certs
          readOnly: true
```

The above embeds the sidekick into the Pod and requests the client to listen on localhost:10443 and 10444 to redirect traffic via the Chisel service. The one annoying point here is the port requirements, placing things on different ports, but unfortunately this is required. You should be able to call the service via `curl https://another-service.example.com:10443` at this point.
