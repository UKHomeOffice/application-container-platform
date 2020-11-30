## ClamAV

In order to Scan files using the ClamAV deployment in Notprod and Prod, your pod will first need to mount the `bundle` Configmap in your namespace. It should be mounted to `/etc/ssl/certs`.

Once the configmap has been mounted, you should be able to upload a file to be scanned using the following command:

```bash
    curl -F "name=<name>" -F "file=@./<file>" https://clamav.virus-scan.svc.cluster.local/scan
```

If the file is not infected the response should be `Everything ok : true`. If the file is infected the response will be `Everything ok : false`.
