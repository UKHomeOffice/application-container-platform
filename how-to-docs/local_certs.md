## Locally trusted CA import procedure

This page has instructions to import a locally trusted CA for
* [Arch Linux](#arch-linux)
* [Chrome](#chrome)
* [Fedora](#fedora)
* [Firefox](#firefox)
* [Mac OS X](#mac-os-x)
* [Safari](#safari)
* [Ubuntu](#ubuntu)
* [Windows](#windows)

## Arch Linux
* Place the certs in /etc/ca-certificates/trust-source/anchors/
* Run 'trust extract-compat' as root

## Chrome
* Open Chrome certificate settings at chrome://settings/certificates
* Click on Authorities tab
* Click import, browse to your certificate file and click OK
(Windows Chrome: version of Chrome has its own certificate import wizard after heading to chrome://settings/certificates)

## Fedora
* Copy the cert into /etc/pki/ca-trust/source/anchors/
* Run sudo update-ca-trust

## Firefox
* Open firefox settings at about:preferences
* Click on advanced, then certificates
* Click view certificates, then authorities
* Click import certificate, and select the .pem file
* Select the required levels of trust, and click ok

## Mac OS X
* Double click on the certificate file
* Check the validity of the certificate
* Add certificate on a system level and enter administrator password
* Add the root authority PEM as trusted root certificate to the system
* Enable systemwide trust of your root certificate
* When you re-open the root PEM certificate in the key manager you will notice that it is now trusted by OS X

## Safari
* Double click on the certificate file, this will open the Keychain Access application
* When asked which keychain to, select the System Keychain and enter adminisrator password
* Expand the Trust section and select to always trust and enter the administrator password

## Ubuntu
* Get certificate and format it with a .crt file extentension 
* Copy .crt file into /usr/local/share/ca-certificates
* Run sudo update-ca-certificates

## Windows
* Open the run dialog by pressing Windows + R key together, or search run in the start menu
type 'mmc'
* In MMC, go to File -> Add/Remove Snap-in
* Select Certificates from the list of snap-in and click Add
* Select 'Computer Account' and click next, select 'Local Computer' and click finish and ok
* Expand Certficates list by double clicking and right click on Trusted Root Certification Authorities -> All Tasks -> Import
* Import your CA by completing the Certificate Import Wizard provided