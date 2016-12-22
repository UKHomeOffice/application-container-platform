# Onboarding a New User

To allow a new user onto the dev platform you need a few things from them: their gpg key, office365 account and the namespaces that they need access to.

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

###Automation tip

```
#!/bin/bash
#
# Generate a gpg k8s token line and gpg encrypt token
# usage mk-kubetoken <k8s-user> <k8s-grps> <pubkey>

K8SToken=$(uuidgen)
Token="$1.token"
echo ${K8SToken} > ${Token}

GPGRecip=$(gpg --import < "$3" 2>&1  \
  | grep --only-matching --perl-regexp '(?<=<).*(?=>)')    
gpg --armor -o ${Token}.gpg --recipient ${GPGRecip} --encrypt ${Token}

# insert this line in kubernetes
echo ${K8SToken},$1,$(uuidgen),\""$2"\" | tee ${Token}.line
```



## Adding them to the Kubernetes
Using the https://gitlab.digital.homeoffice.gov.uk/Devops/hod-platform repo

Make sure you git pull before doing any of the following steps!

```
./scripts/run-<environment>.sh
./scripts/fetch_secrets.sh
```
This will ensure everything is up to date.

Now you can add the user by editing `secrets/tokens.csv`
At the end of the file add the uid you used to as part of the gpg process, their username, another uid and any additional groups in the following format.
```
<their-uid>,<their-username>,<another-uid>,"<groups>"
```
Now you can push these changes, make sure to notify people you are doing this to avoid overwriting of either your or someone else's changes!
```
./scripts/upload_secrets.sh
```
## Allowing them to access the VPN
All users now get automatic to the Dev VPN, if they need access to additional profiles go to https://sso.digital.homeoffice.gov.uk and go on to the administration console to add them to the relevant groups.
