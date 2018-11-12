## **ACP External Addresses**

The ACP clusters all run behind NAT gateways, with fixed external addresses. Note, unless you've specifically choosen to run in a specific availability zone, your pods can run in any of the AZ's for that cluster, so all three addresses should be taken as the external ip's.

| Cluster         | Zone          | External Address   |
| :-------------:  |:-------------:| :-----------------: |
| ACP-CI          | eu-west-2a    | 52.56.254.215      |
|                 | eu-west-2b    | 35.176.205.192     |
|                 | eu-west-2c    | 35.178.14.117      |
| ACP-OPS         | eu-west-2a    | 35.176.238.26      |
|                 | eu-west-2b    | 35.177.41.205      |
|                 | eu-west-2c    | 35.176.100.151     |
| ACP-PROD        | eu-west-2a    | 35.177.82.170      |
|                 | eu-west-2b    | 52.56.249.216      |
|                 | eu-west-2c    | 35.176.70.245      |
| ACP-PROD-PX     | eu-west-2a    | 35.177.156.249     |
|                 | eu-west-2b    | 35.177.245.179     |
|                 | eu-west-2c    | 35.177.14.177      |
| ACP-NOTPROD     | eu-west-2a    | 35.177.248.60      |
|                 | eu-west-2b    | 35.176.168.231     |
|                 | eu-west-2c    | 52.56.158.209      |
| ACP-NOTPROD-PX  | eu-west-2a    | 52.56.221.144      |
|                 | eu-west-2b    | 52.56.45.52        |
|                 | eu-west-2c    | 35.177.167.246     |
| ACP-TEST        | eu-west-2a    | 35.176.184.49      |
|                 | eu-west-2b    | 35.176.217.238     |
|                 | eu-west-2c    | 35.177.169.118     |
| ACP-VPN (Access)| eu-west-2a    | 52.56.221.216      |
|                 | eu-west-2b    | 18.130.11.142      |
|                 | eu-west-2c    | 18.130.6.5         |

Note: The ACP-VPN external IPs addresses only work for the "Tunnel All Traffic" VPN profiles.
