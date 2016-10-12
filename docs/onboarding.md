# Onboarding a New User

To allow a new user onto the platform you need a few things from them, their username, gpg key, office365 account.

## Creating a Kubernetes Token
Firstly import their gpg key.
```
gpg --import <their key>.gpg
```
Create a uid and store it in a file.
```
uuid > uidfile
```
Now create a token for them.
```
gpg -o <username>.gpg --recipient <email> --encrypt uidfile
```
This token can now be sent to them.

## Adding them to the Kubernetes
Using the https://gitlab.digital.homeoffice.gov.uk/Devops/hod-platform repo

Make sure you git pull before doing any of the following steps!

```
./scripts/run-<environment>.sh
./scripts/fetch_secrets.sh
```
This will ensure everything is up to date.

Now you can add the user by editing secrets/tokens.csv
At the end of the file add the uid you used to as part of the gpg process, their username, another uid and any additional groups in the following format.
```
<their-uid>,<their-username>,<another-uid>,"<groups>"
```
Now you can push these changes, make sure to notify people you are doing this to avoid overwriting of either your or someone else's changes!
```
./scripts/upload_secrets.sh
```
Finally you must ssh to one of the CoreOS nodes and restart the Kubernetes api fleet service.
```
fleetctl stop kubernetes-api.service
wait 30
fleetctl start kubernetes-api.service
```
## Allowing them to access the VPN
To get through to the servers they will need vpn access granted to them, you can give them this by going to http://something.homeoffice.gov.uk.
