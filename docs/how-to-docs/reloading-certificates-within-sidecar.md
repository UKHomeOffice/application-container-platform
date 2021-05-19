##Using Cert Manager with an Nginx sidecar


If you are using Nginx sidecar to terminate TLS in pods then you will need to make some updates to your deployment and add a new Certificate when migrating over to Cert Manager.

This can be achieved in two steps.
1.Creating a new certificate.
2.Updating your deployment to load use the new certificate and periodically reload it

###1.Creating new certificate.
Let's start by making a new certificate.

```YAML
apiVersion: cert-manager.io/v1alpha2
kind: Certificate
metadata:
  name: {{ .DEPLOYMENT_NAME }}-service-tls
spec:
  secretName: {{ .DEPLOYMENT_NAME }}-service-tls-cmio
  issuerRef:
    name: platform-ca
    kind: ClusterIssuer
  commonName: app.{{ .KUBE_NAMESPACE }}.svc.cluster.local
  dnsNames:
  - app
  - app.{{ .KUBE_NAMESPACE }}.svc
```


###2.Updating your deployment.

In your deployment, you need to add a secret volume and a volume mount.

A secret volume is used to pass sensitive information, such as passwords, to Pods. You can store secrets in the Kubernetes API and mount them as files for use by pods without coupling to Kubernetes directly. Secret volumes are backed by TMPDS (a RAM-backed filesystem) so they are never written to non-volatile storage.
```YAML
       volumes:
        - name: certs
          secret:
            secretName: {{ .DEPLOYMENT_NAME }}-service-tls-cmio
```
-------------------------


Now we need to mount that volume to the Nginx sidecar container we just added.

```YAML
       volumeMounts:
            - mountPath: /certs
              name: certs
              readOnly: true

```

###3.Make a trigger for the sidecar to receive new certificates.

After we make these changes we need to allow Nginx to receive new certificates. We can do this by reloading Nginx. This can be done automatically by using Container Lifecycle Hooks below is a code that can be added to the deployment.

```YAML
   lifecycle:
      postStart:
        exec:
          command: ["/bin/sh", "-c", "while true; do sleep 43200; nginx -s reload; done &"]
```
This command will check in the background for new certificates every 12 hours


This is the solution that we're recommending for now. However we are planning on making changes to the nginx image so that postStart hook don't have to be used.
