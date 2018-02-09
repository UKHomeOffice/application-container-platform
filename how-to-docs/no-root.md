### Unprivileged containers 

Containers cannot be run with root privileges on acp-notprod. 

Resources must be created with an appropriate [security context](https://kubernetes.io/docs/tasks/configure-pod-container/security-context). The following example creates a mysql pod and mounts a persistent volume without the need for root privileges: 

```yaml
---
apiVersion: v1
kind: Pod
metadata:
  name: mysql
  labels:
    name: mysql
spec:
  containers:
  - image: mysql:5.7
    name: mysql
    args:
      - "--ignore-db-dir"
      - "lost+found"
    env:
      - name: MYSQL_ROOT_PASSWORD
        value: changeme
    securityContext:
      runAsNonRoot: true
    ports:
      - containerPort: 3306
        name: mysql
    volumeMounts:
      - name: mysql-pvc
        mountPath: /var/lib/mysql
  securityContext:
    runAsUser: 1000
    fsGroup: 1000
  volumes:
  - name: mysql-pvc
    persistentVolumeClaim:  
      claimName: mysql-pvc-vol
---    
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  annotations:
    volume.beta.kubernetes.io/storage-provisioner: kubernetes.io/aws-ebs
  name: mysql-pvc-vol
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  storageClassName: gp2
---        
apiVersion: v1
kind: Service
metadata:
  labels:
    name: mysql
  name: mysql
spec:
  ports:
    - port: 3306
  selector:
    name: mysql
```
