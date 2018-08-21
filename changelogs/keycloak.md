### **Keycloak v4.3.0**

**Enhancement**

* [KEYCLOAK-5289] - support hosted domain for Google logins

**Feature Request**

* [KEYCLOAK-7635] - Authenticate clients with x509 certificate
* [KEYCLOAK-7967] - Hostname SPI

**Epic**

* [KEYCLOAK-5522] - Add support for Fuse 7

**Bug**

* [KEYCLOAK-6818] - Keycloak creates an extra AUTH_SESSION_ID cookie with a path of “/auth” when logging in
* [KEYCLOAK-6832] - Destination Validation should ignore whether default port is explicitly specified
* [KEYCLOAK-7528] - Token endpoint doesn't set Cache-Control and Pragma header
* [KEYCLOAK-7562] - ClientInitiatedAccountLinkTest#testErrorConditions fails
* [KEYCLOAK-7946] - Variable rather than intended value showing in RH-SSO doc
* [KEYCLOAK-7954] - OIDC Provider doesn't skip token validation if URL is empty
* [KEYCLOAK-7974] - Fix typo in remove credentials alert
* [KEYCLOAK-7984] - RequiredActionProviderEntity priority migration issue
* [KEYCLOAK-7985] - Version migration the database table names do not match
* [KEYCLOAK-7986] - Migration test fails for migration from 3.4.3.Final
* [KEYCLOAK-7988] - New keycloak-bot commands convention is not mentioned in README.md
* [KEYCLOAK-7989] - Running server config migration fails due the Hostname SPI
* [KEYCLOAK-7994] - Move Fuse examples into test-apps
* [KEYCLOAK-8002] - Cannot build new Account Console
* [KEYCLOAK-8003] - Migration to 4.2.1 extracting RESOURCE_URIs fails with fine-grained admin permissions
* [KEYCLOAK-8007] - Cannot compile Console UI and Welcome Page tests
* [KEYCLOAK-8015] - Migration into 4.2.1.Final fails from version 3.4.3.Final
* [KEYCLOAK-8035] - Failing GitLab Social Login test
* [KEYCLOAK-8036] - Misplaced IdPs buttons on the Login Page
* [KEYCLOAK-8046] - X509 Client Authenticator sends Client entity twice
* [KEYCLOAK-8048] - Testsuite does not compile due to cross-PR interference

### **Keycloak v4.2.1**

**Bug**

* [KEYCLOAK-7984] - RequiredActionProviderEntity priority migration issue
* [KEYCLOAK-7985] - Version migration the database table names do not match
* [KEYCLOAK-7986] - Migration test fails for migration from 3.4.3.Final
* [KEYCLOAK-7998] - File based realm export breaks after migration from Keycloak 3.4.3 to 4.2.1

### **Keycloak v4.2.0**

**Enhancement2**

* [KEYCLOAK-4407] - Ability to restart arquillian containers from test
* [KEYCLOAK-5609] - An option to create claims with dots (.) in them
* [KEYCLOAK-6577] - Unable to map claim attributes with dots (.) in them
* [KEYCLOAK-7703] - PathBasedKeycloakConfigResolver - more generic behavior
* [KEYCLOAK-7792] - Always preserve URL fragment in redirectUri
* [KEYCLOAK-7876] - Improve stability of fuse7 hawtio test
* [KEYCLOAK-7924] - Speed up cross-dc tests
* [KEYCLOAK-7959] - OAuth 2.0 Certificate Bound Access Tokens in Reverse Proxy Deployed Environment
* [KEYCLOAK-7973] - Possibility to add classpath elements to KeycloakServer

**Feature Request**

* [KEYCLOAK-1925] - SAML adapter multitenant support
* [KEYCLOAK-2606] - In-app browser tab support for Cordova
* [KEYCLOAK-5629] - Add credential endpoints to account service
* [KEYCLOAK-6313] - Changing execution order of required actions easily feature
* [KEYCLOAK-7105] - Notification needs to be lower
* [KEYCLOAK-7201] - OIDC Identity Brokering with Client parameter forward
* [KEYCLOAK-7294] - Password Page - Angular
* [KEYCLOAK-7846] - Turn off disallowed features

**Epic*
* [KEYCLOAK-6176] - Stable and reliable CI that can be used to test PRs, master and releases

**Bug**
* [KEYCLOAK-2886] - Cluster tests fail when running from IDE
* [KEYCLOAK-4662] - Keycloak adapter missing configuration attribute "proxy-url"
* [KEYCLOAK-6308] - Disable 'secret question credentials' fails
* [KEYCLOAK-6314] - After a terms & conditions rejection, an "internal server error has ocurred" happens
* [KEYCLOAK-6708] - NullPointerException when integrating with IDP that returns a SAML XML that does not contain the fields Keycloak expects by default
* [KEYCLOAK-6866] - Error 404 after changing locale while authenticating using X.509
* [KEYCLOAK-7497] - Remove Babel transpiler
* [KEYCLOAK-7524] - Vertical Nav Doesn't close on secondary click
* [KEYCLOAK-7663] - Deleting identity provider does not delete it's mappers
* [KEYCLOAK-7795] - "Back to <app>" missing from Welcome Page
* [KEYCLOAK-7802] - Broken HoKTest
* [KEYCLOAK-7805] - Broken PayPal and Bitbucket Social Login tests
* [KEYCLOAK-7816] - Tech preview features (like authz) are run by default
* [KEYCLOAK-7823] - Keycloak returns wrong HTTP status during SPNEGO authentication
* [KEYCLOAK-7840] - Secret in keycloak.json and client-import.json doesn't match
* [KEYCLOAK-7860] - proxy-address-forwarding option is not added to https listener in Docker image
* [KEYCLOAK-7872] - Doesn't remove Identity Provider Mapper after removing identity provider
* [KEYCLOAK-7881] - Docker image jboss/keycloak doesn't contain jq
* [KEYCLOAK-7913] - Invalid naming of JPA changelog files
* [KEYCLOAK-7934] - Dataset generator cannot create "empty" mappings
* [KEYCLOAK-7965] - Redundant div end tag in base theme login.ftl
* [KEYCLOAK-7977] - Release failing due the NPE during swagger2markup-maven-plugin execution

**Task**
* [KEYCLOAK-7101] - Investigate failing Social Login Tests
* [KEYCLOAK-7269] - [SPIKE] - Investigate how to support resource-less permissions
* [KEYCLOAK-7310] - Add migration test from 3.4.x to 4.x
* [KEYCLOAK-7328] - Test the RH-SSO 7.2.z EAP 7 adapter with early builds of EAP 7.2.0
* [KEYCLOAK-7329] - Test the RH-SSO 7.3.0 EAP 7 adapter with early builds of EAP 7.2.0
* [KEYCLOAK-7400] - Update Camel / Fuse 7 adapter once CAMEL-12514 is merged to Fuse's Camel component
* [KEYCLOAK-7498] - Remove unused components.
* [KEYCLOAK-7599] - Improve handling of test datasets
* [KEYCLOAK-7620] - Generating performance datasets for authorization services
* [KEYCLOAK-7666] - Adapter tests - add dynamically loaded container - remove abstract classes - EAP6-fuse6
* [KEYCLOAK-7817] - Update eap6.version in testsuite
* [KEYCLOAK-7857] - Fix Notifications - Switch to pf-ng notifications
* [KEYCLOAK-7888] - Update Fuse adapter examples/guide to new way of CXF servlet registration

### **Keycloak v4.1.0**

**Enhancement**
* [KEYCLOAK-3063] - Check if keycloak-osgi-thirdparty can be removed
* [KEYCLOAK-3370] - Choose Theme by Client
* [KEYCLOAK-4937] - Convert time units in emails into human-friendly format
* [KEYCLOAK-5166] - Setup CI jobs to test RH-SSO quickstarts
* [KEYCLOAK-5578] - The javascript adapter should use native Promises
* [KEYCLOAK-5791] - Add support for multi-valued attributes in ScriptBasedOIDCProtocolMapper
* [KEYCLOAK-5811] - OIDC Client Authentication by JWS Client Assertion in client_secret_jwt
* [KEYCLOAK-5857] - Support for PBKDF2 hashes with different key size
* [KEYCLOAK-5886] - Improvements to Photoz Examples
* [KEYCLOAK-6085] - Allow to customize DB dump download location through a Maven property
* [KEYCLOAK-6222] - Check for script syntax errors on ScriptBasedOIDCProtocolMapper validation
* [KEYCLOAK-6262] - Incorporate new visual design for login pages
* [KEYCLOAK-6298] - SAML adapter script should support offline installation of adapter
* [KEYCLOAK-6299] - Product profile should only include supported JavaDocs
* [KEYCLOAK-6302] - Add support for user defined networks and Docker compose
* [KEYCLOAK-6330] - GitHub social IdP: Use GitHub API for fetching user's private email if no public email is set
* [KEYCLOAK-6335] - Per client authentication flows
* [KEYCLOAK-6336] - Per client authentication flows configuration in admin console
* [KEYCLOAK-6339] - Show SAML IdP-initiated client URI
* [KEYCLOAK-6350] - Refactor SAML parsers
* [KEYCLOAK-6355] - Non-browser multi-request cookieless auth flow support
* [KEYCLOAK-6378] - Clean-up node_modules in themes
* [KEYCLOAK-6493] - [SPIKE] Investigate architecture of new account management console
* [KEYCLOAK-6561] - Add account management and update profile to js-console example
* [KEYCLOAK-6578] - Support other OIDC providers with keycloak.js
* [KEYCLOAK-6589] - Performance issues in Users REST API
* [KEYCLOAK-6618] - Update German Translation
* [KEYCLOAK-6664] - Fix performance testsuite shell scripts to run on macOS
* [KEYCLOAK-6700] - Financial API Read and Write API Security Profile : State hash value (s_hash) to protect state parameter
* [KEYCLOAK-6871] - Make sending a request object mandatory for certain clients
* [KEYCLOAK-4134] - Update paths in adapters when new resources are created on the server
* [KEYCLOAK-5457] - Context accessibility for JS base policies
* [KEYCLOAK-5830] - Automated stress test
* [KEYCLOAK-6448] - Instagram social broker
* [KEYCLOAK-6494] - Address load-time of new account management console
* [KEYCLOAK-6495] - Address number of requests for new account management console
* [KEYCLOAK-6496] - Cleanup and polish current code base for new account management console
* [KEYCLOAK-6699] - Add more recipes to Admin CLI documentation
* [KEYCLOAK-6815] - Use htmlunit browser in adapter tests
* [KEYCLOAK-6838] - Update RH-SSO logo style
* [KEYCLOAK-6857] - [RH-SSO] Remove support for RH-SSO 7.1 from the documentation
* [KEYCLOAK-6992] - Proxy: Configure Request Timeout
* [KEYCLOAK-7033] - Server rendered "Login Success/Failure" for kcinit/KeycloakInstalled browser
* [KEYCLOAK-7044] - kcadm --token support
* [KEYCLOAK-7147] - Support obtaining a buffered input stream in HttpFacade.Request
* [KEYCLOAK-7162] - Expose WWW-Authenticate Header when using CORS
* [KEYCLOAK-7204] - Make sure that sso.redhatkeynote.com route is used just for "sso" project
* [KEYCLOAK-7223] - Increase count of connections at datasource
* [KEYCLOAK-6655] - Javascript Adapter - Allow users to provide cordova-specific options to login and register
* [KEYCLOAK-6656] - Javascript Adapter - Reject 'login' promise when users close their cordova in-app-browser on purpose
* [KEYCLOAK-7274] - Hardcoded config in offline adapter installation scripts
* [KEYCLOAK-7354] - Split ticket management and permission endpoint
* [KEYCLOAK-4828] - LDAP: default groups are not automatically added during user registration
* [KEYCLOAK-6883] - Add "scope" as claim to the access token.
* [KEYCLOAK-7334] - Update vertical nav/Integrate patternfly-ng
* [KEYCLOAK-7356] - Code to Token flow fails if initial redirect_uri contains a session_state parameter
* [KEYCLOAK-7504] - Update Node.js adapter dependencies and deprecate support to Node 4
* [KEYCLOAK-7523] - PathBasedKeycloakConfigResolver uses wrong context path
* [KEYCLOAK-7531] - Javascript Adapter - Typescript definition of login.cordovaOptions
* [KEYCLOAK-7593] - Add setter for httpContext to Fuse 7 adapters' PaxWebIntegrationService
* [KEYCLOAK-7633] - Improve support for DEBUG level logging, including runtime level change
* [KEYCLOAK-7701] - Refactor key providers to support additional algorithms
* [KEYCLOAK-7722] - Move configuration files specific to EAP6 to app-server-eap6 module

**Feature Request**
* [KEYCLOAK-943] - Account Management REST api
* [KEYCLOAK-1942] - Magic link authenticator prototype
* [KEYCLOAK-3736] - Add display name to clients
* [KEYCLOAK-4547] - Allow deploying themes to deployments dir
* [KEYCLOAK-4721] - Consider Session Language of Realm Also In ReCaptcha
* [KEYCLOAK-4743] - Running keycloak behind web proxy
* [KEYCLOAK-5372] - Add warm-up, test-time, ramp-down times
* [KEYCLOAK-5574] - Add edit this page in Github links to docs
* [KEYCLOAK-6041] - SSSD Federation script to be idempotent
* [KEYCLOAK-6147] - Ability to add nonce attribute to idp request
* [KEYCLOAK-6228] - Client Storage SPI
* [KEYCLOAK-6289] - Add Theme Selector SPI
* [KEYCLOAK-6519] - Theme resource provider
* [KEYCLOAK-4102] - Allow policy enforcer to load paths on demand when no path is provider
* [KEYCLOAK-4538] - Possiblity to allow clock skew between client and server
* [KEYCLOAK-4903] - Pushed Claims
* [KEYCLOAK-5098] - Spring Boot 2 Adapter
* [KEYCLOAK-6305] - Slovak translation
* [KEYCLOAK-6497] - Profile page
* [KEYCLOAK-6498] - Welcome page
* [KEYCLOAK-6499] - Add password update - HTML
* [KEYCLOAK-6500] - Add device activity - HTML
* [KEYCLOAK-6501] - Applications page - wireframe
* [KEYCLOAK-6505] - Authenticator page - wireframe review
* [KEYCLOAK-6622] - admin console support for client storage SPI
* [KEYCLOAK-6798] - Keycloak.js - allow to provide custom adapters
* [KEYCLOAK-6813] - CLI SSO Utility `kcinit`
* [KEYCLOAK-7000] - kcinit whoami
* [KEYCLOAK-7004] - kcinit browser mode
* [KEYCLOAK-7039] - Add support for MariaDB to Docker image
* [KEYCLOAK-7072] - Extended user attributes on Profile Page
* [KEYCLOAK-7196] - Add kc_locale to keycloak.js
* [KEYCLOAK-7197] - Response design for welcome page
* [KEYCLOAK-7090] - Applications page - HTML
* [KEYCLOAK-7148] - Associate sub resources to a parent resource
* [KEYCLOAK-7206] - Search by user id on admin console
* [KEYCLOAK-349] - Scope query parameter support
* [KEYCLOAK-5579] - Change Client Templates to Client Scope
* [KEYCLOAK-6720] - Display promise error massage in GrantManager.prototype.validateToken
* [KEYCLOAK-6771] - Holder of Key mechanism: OAuth 2.0 Certificate Bound Access Tokens
* [KEYCLOAK-7382] - Application Response HTML Update
* [KEYCLOAK-7451] - OAuth Authorization Server Metadata for Proof Key for Code Exchange
* [KEYCLOAK-7500] - Upgrade MySQL driver to 5.1.46
* [KEYCLOAK-6663] - Support OAuth2 installed / native apps using a custom redirect uri
* [KEYCLOAK-7384] - Federated Identity (linked accounts) HTML
* [KEYCLOAK-7641] - Introduce a profile to allow building only server
* [KEYCLOAK-7651] - Docker image support to build Keycloak from source
* [KEYCLOAK-7688] - Offline Session Max for Offline Token
* [KEYCLOAK-7689] - Authenticator - Mobile Setup HTML (including the responsive code)
* [KEYCLOAK-7690] - Authenticator - SMS Code Setup HTML (including the responsive code)
* [KEYCLOAK-7691] - Authenticator - Backup Code Setup HTML (including the responsive code)
* [KEYCLOAK-7705] - Added hardcoded-ldap-group-mapper for user federation

### **Keycloak 3.4**

**Enhancement**

* [KEYCLOAK-3303] - Add option to support last two refresh tokens
* [KEYCLOAK-4052] - Use PasswordPolicy for LDAP password updates
* [KEYCLOAK-4803] - Move support for MySQL and PostgreSQL to main Keycloak Docker image
* [KEYCLOAK-4858] - Slow query performance for client with large data volume
* [KEYCLOAK-4928] - Add Primary Key Constraints to all tables of the database
* [KEYCLOAK-5032] - Authorize endpoint, request parameters not transmitted to IDP
* [KEYCLOAK-5165] - Setup CI jobs to test Keycloak quickstarts
* [KEYCLOAK-5186] - create user -> set federationLink if present
* [KEYCLOAK-5298] - Enable autoscaping in Freemarker template
* [KEYCLOAK-5439] - Remove unneeded subsystems/modules from distro
* [KEYCLOAK-5446] - Improve logging of URI mismatch in received vs expected in SAML adapter
* [KEYCLOAK-5510] - Allow import of LDAP groups with missing subgroups
* [KEYCLOAK-5576] - Performance testsuite should allow exporting the dump directly after data generation
* [KEYCLOAK-5577] - Support setting cpu/mem docker limits in performance tests
* [KEYCLOAK-5616] - Processing of claims parameter
* [KEYCLOAK-5624] - Rename import-data profile to generate-data
* [KEYCLOAK-5631] - A lot of 'Unrecognized attribute' warnings in log when WF is configured to run in crossdc
* [KEYCLOAK-5655] - Upgrade FreeMarker
* [KEYCLOAK-5661] - OIDC Financial API Read Only Profile : scope MUST be returned in the response from Token Endpoint
* [KEYCLOAK-5671] - Adding a "policy provider attributes" field to Permission
* [KEYCLOAK-5700] - Add support for jarless server distribution
* [KEYCLOAK-5703] - Improving exception handling and parsing server response
* [KEYCLOAK-5726] - Support define enforcement mode for scopes on the adapter configuration
* [KEYCLOAK-5728] - Allow policy providers to push permission claims
* [KEYCLOAK-5798] - Move keycloak-nodejs-auth-utils and keycloak-nodejs-connect repositories

**Feature Request**

* [KEYCLOAK-2035] - Add ability to get users in role
* [KEYCLOAK-2671] - Allow additional attributes to be pushed into Freemarker templates (login and account themes)
* [KEYCLOAK-3135] - Support Remote Policy Management
* [KEYCLOAK-3599] - Script based ProtocolMapper for ODIC
* [KEYCLOAK-4169] - Document how to run testsuite
* [KEYCLOAK-4374] - Support SAML 2.0 AttributeValue AnyType
* [KEYCLOAK-4580] - Token exchange service
* [KEYCLOAK-4766] - Add Executor Service SPI
* [KEYCLOAK-4982] - Create a job to release Keycloak quickstarts
* [KEYCLOAK-5244] - Blacklist PasswordCredentialPolicy
* [KEYCLOAK-5448] - Login with PayPal
* [KEYCLOAK-5623] - Integrate Keycloak via Jboss Fuse Fabric Profile resource

### **Keycloak 3.3**

**Enhancement**

* [KEYCLOAK-4756] - unversioned keycloak.js cache life too long
* [KEYCLOAK-5067] - Allow refreshable context to have an optional adapter token store
* [KEYCLOAK-5138] - Use build time in resource versions for snapshots
* [KEYCLOAK-5143] - Use auth-server-wildfly on Travis
* [KEYCLOAK-5180] - Add title attribute for keycloak-session-iframe to suppress accessibility errors
* [KEYCLOAK-5190] - Login with BitBucket
* [KEYCLOAK-5194] - Disabling Group and Role Permissions doesn't delete anything
* [KEYCLOAK-5242] - Add means to run test Keycloak server with https
* [KEYCLOAK-5285] - Improve possibility to extend FreeMarkerEmailTemplateProvider

**Feature Request**

* [KEYCLOAK-3877] - Expose adapter config for public clients through the management interface
* [KEYCLOAK-4253] - Functional tests for quickstarts
* [KEYCLOAK-4439] - WildFly/EAP Management UI SSO
* [KEYCLOAK-4477] - Upgrade server to WildFly 11 Alpha1
* [KEYCLOAK-4663] - Elytron subsystem
* [KEYCLOAK-4900] - Passing login_hint up to Identity Provider
* [KEYCLOAK-5086] - Provide Chinese translation in keycloak themes
* [KEYCLOAK-5203] - Keycloak Proxy Docker image
* [KEYCLOAK-5249] - gitlab.com identity provider
* [KEYCLOAK-5269] - account service unlink REST API doesn't work
* [KEYCLOAK-5291] - token references feature
* [KEYCLOAK-5307] - Provide Dutch translation in keycloak themes
* [KEYCLOAK-5319] - Source maps for keycloak.js

### **Keycloak 3.2.0**

**Enhancement***

* [KEYCLOAK-3056] - Option to verify signature on SAML assertion in SAML Identity broker
* [KEYCLOAK-3631] - Make user actions tokens independently from -user- +client+ sessions so they can live a long time
* [KEYCLOAK-3988] - Multiple missing indexes on FKs
* [KEYCLOAK-3990] - Too many autoFlush checks by Hibernate and explicit em.flush()
* [KEYCLOAK-4016] - Provide a Link to go Back to The Application on a Timeout
* [KEYCLOAK-4097] - Better session sharing / handling of multiple logins
* [KEYCLOAK-4119] - Allow debugging Keycloak when running tests
* [KEYCLOAK-4497] - Update French Translation
* [KEYCLOAK-4670] - Back/forward/refresh button issues
* [KEYCLOAK-4765] - QueryParamTokenRequestAuthenticator fails when access_token query param is not a valid bearer
* [KEYCLOAK-4770] - Development version of keycloak-connect should depend on GitHub version of auth-utils
* [KEYCLOAK-4814] - disable security via configuration (i.e. for testing) in Spring Boot Adapter
* [KEYCLOAK-4862] - Expose client description in ClientBean
* [KEYCLOAK-4888] - Change default hashing provider for realm
* [KEYCLOAK-4889] - Improve error messages for password policies
* [KEYCLOAK-4929] - Refactor Authz caching and jpa API
* [KEYCLOAK-4933] - Use server-provisioning to create WildFly adapter dist and server overlay
* [KEYCLOAK-4940] - Typo in German email verification body
* [KEYCLOAK-4961] - Group policy
* [KEYCLOAK-5033] - Quickstarts integration tests should be parallelized on Travis CI
* [KEYCLOAK-5051] - Invalidate authz cache when realm cache is cleared
* [KEYCLOAK-5064] - add configuration property option realmPublicKey
* [KEYCLOAK-5069] - Provide a way to add a custom KeycloakConfigResolver instance for initialization
* [KEYCLOAK-5072] - JSPolicyProvider should use ScriptingSPI

**Feature Request**

* [KEYCLOAK-3168] - Group-Based Access Control
* [KEYCLOAK-3297] - Add option for setting CORS Access-Control-Expose-Headers header
* [KEYCLOAK-3316] - Remove the IDToken if scope=openid is not used
* [KEYCLOAK-3444] - Fine-grained permissions in admin console and endpoints
* [KEYCLOAK-3592] - Docker Auth V2 Protocol Support
* [KEYCLOAK-4007] - Add integration tests for the nodejs adapter "admin" endpoints
* [KEYCLOAK-4204] - Extend brute force protection with permanent lockout on failed attempts
* [KEYCLOAK-4444] - Allow sending test email
* [KEYCLOAK-4773] - Remove 'providers' directory
* [KEYCLOAK-4815] - Making Proxy address forwarding configurable in Docker container
* [KEYCLOAK-4826] - Docker image for OpenShift
* [KEYCLOAK-4886] - Support creation of multiple OpenShift v3 Identity Providers
* [KEYCLOAK-4951] - Update Spring Boot documentation to reflect usage of the starter
* [KEYCLOAK-4955] - Partial export through admin console
* [KEYCLOAK-4965] - Node.js testsuite occasionally stuck on Travis CI
* [KEYCLOAK-4967] - Setup Travis CI to build development version of the quickstarts
* [KEYCLOAK-4980] - SAML adapter should return 401 when unauthenticated Ajax client accesses
* [KEYCLOAK-5082] - Unable to access webapp which URL being rewritten

### **Keycloak Release 3.1.0-3"

An update to the govuk themes from v1.1.0 to v1.1.1 (https://github.com/UKHomeOffice/keycloak-theme-govuk)

- this will change the govuk, govuk-internal and social themes

### **Keycloak Releases**

You can find the Keycloak Release pages [here](https://issues.jboss.org/projects/KEYCLOAK?selectedItem=com.atlassian.jira.jira-projects-plugin%3Arelease-page&status=released-unreleased). Note a JBOSS Developer login is required (it's free)

#### **[v3.1.0](https://issues.jboss.org/secure/ReleaseNote.jspa?projectId=12313920&version=12333194)**

**Enhancement:**

* [KEYCLOAK-2122] - Config of AssertionConsumerServiceUrl in Saml Adapter
* [KEYCLOAK-4361] - Remove auth-server-standalone from domain.xml
* [KEYCLOAK-4502] - Update Russian translation
* [KEYCLOAK-4528] - Identity Provider for Openshift
* [KEYCLOAK-4602] - Improve path matcher when using handling patterns and caching
* [KEYCLOAK-4614] - Fix tooltip reference for linkOnly field in identity providers section
* [KEYCLOAK-4644] - Have option to not synchronize a linked account on login
* [KEYCLOAK-4652] - PolicyEvaluationService.evaluate() handles Role Policy for composite role incorrectly
* [KEYCLOAK-4664] - linking doesn't update token
* [KEYCLOAK-4665] - Parent IDP not logged out if account was linked during session
* [KEYCLOAK-4671] - Add server-private-spi to dependency deployer
* [KEYCLOAK-4727] - move PolicyEvaluationService into admin client
* [KEYCLOAK-4728] - Update French Translation
* [KEYCLOAK-4729] - Update German Translation
* [KEYCLOAK-4734] - Update Italian Translations
* [KEYCLOAK-4751] - Send default access denied page when requests don't match any path config
* [KEYCLOAK-4762] - Improve French translations
* [KEYCLOAK-4792] - AuthzClient should support credential types other than secret

**Feature Request:**

* [KEYCLOAK-2604] - Proof Key for Code Exchange by OAuth Public Clients
* [KEYCLOAK-3468] - Upgrade server to WildFly 10.1.0.Final
* [KEYCLOAK-3573] - Elytron adapters
* [KEYCLOAK-3999] - Add Key Rotation support for Spring Security Adapter
* [KEYCLOAK-4000] - Add Key Rotation support for Spring Boot Adapter
* [KEYCLOAK-4163] - Improve support for e-mail addresses
* [KEYCLOAK-4168] - Add proxy debug endpoint
* [KEYCLOAK-4335] - X509 Certificate user authentication
* [KEYCLOAK-4396] - TypeScript type definitions for keycloak.js
* [KEYCLOAK-4691] - Extract Initial Token Generator to a separate method
* [KEYCLOAK-4697] - [RHSSO] Upgrade to EAP 7.1.0 Alpha16
* [KEYCLOAK-4736] - Extend security defenses with header X-XSS-Protection
* [KEYCLOAK-4804] - Add spring-boot-container-bundle

#### **[v3.0.0](https://issues.jboss.org/secure/ReleaseNote.jspa?projectId=12313920&version=12332008)**

**Enhancement:**

* [KEYCLOAK-3964] - No-import LDAP option
* [KEYCLOAK-3989] - Realm creation/deletion drops all admin composite roles and re-inserts them.
* [KEYCLOAK-4224] - Allow hiding identity providers on login page
* [KEYCLOAK-4362] - Split migration-domain script into two separate scripts
* [KEYCLOAK-4363] - ComponentFactory.onUpdate needs old model too
* [KEYCLOAK-4381] - Merge ModelReadOnlyException with ReadOnlyException
* [KEYCLOAK-4382] - Merge ModelReadOnlyException with ReadOnlyException
* [KEYCLOAK-4385] - Simple KeycloakConfigResolver to easily find keycloak.json inside OSGI bundle
* [KEYCLOAK-4475] - Minor improvements in hawtio integration docs
* [KEYCLOAK-4505] - ScriptBasedAuthenticator should expose clientSession as script binding
* [KEYCLOAK-4515] - Make it possible to clean-up other DB types than mysql or postgres
* [KEYCLOAK-4520] - Enable testsuite logging when running test from IDE

**Feature Request:**

* [KEYCLOAK-3621] - Node.js service quickstart
* [KEYCLOAK-3955] - Add module for testing domain dependant tests
* [KEYCLOAK-4008] - Add checksums to file downloads
* [KEYCLOAK-4195] - Keycloak adapter and SPI bom
* [KEYCLOAK-4360] - Add OneTimeUse condition to SAMLResponse
* [KEYCLOAK-4501] - Federated identity management
* [KEYCLOAK-4504] - SAML Broker: Support redirect logout, even when using POST for SAML response
* [KEYCLOAK-4537] - Adapter for Jetty 9.4
* [KEYCLOAK-4565] - Javadocument the adapter properties and add the metadata generator
* [KEYCLOAK-4581] - Swedish translations

#### **[v2.5.0](https://issues.jboss.org/secure/ReleaseNote.jspa?projectId=12313920&version=12332009)**

**Enhancement:**

* [KEYCLOAK-2654] - KC invokes UserInfo Endpoint call against external Identity Provider
* [KEYCLOAK-2962] - OAuthRequestAuthenticator shouldn't redirect on XHR / AJAX requests
* [KEYCLOAK-3124] - Have adapter tests running on embedded undertow during default build
* [KEYCLOAK-3474] - Provide a filter to enable authorizations
* [KEYCLOAK-3678] - [Fuse] Add example using Camel RestDSL
* [KEYCLOAK-3823] - Adapters should clear key caches when not before policy is sent
* [KEYCLOAK-3933] - Remove UserFederationProvidersResource.getUserFederationInstanceWithFallback() once UserFederation SPI is removed
* [KEYCLOAK-3973] - Migration strategy for deprecated custom UserFed
* [KEYCLOAK-3987] - Grant the new role from the saml token if it exist
* [KEYCLOAK-4002] - realmRevisions cache size needs to be configurable
* [KEYCLOAK-4003] - Slow role checks on Infinispan RoleAdapter with composite roles.
* [KEYCLOAK-4004] - Display client name in referrer link instead of id
* [KEYCLOAK-4040] - Unable to import SAML metadata with OrganizationUrl
* [KEYCLOAK-4046] - Setting the 'Credentials - Temporary' flag when creating a new user causes the user to be disabled in MSAD
* [KEYCLOAK-4062] - Provide GUI for KeyName format in identity broker and client
* [KEYCLOAK-4074] - Decoupling of default provider implementations

**Feature Request:**

* [KEYCLOAK-912] - Admin CLI
* [KEYCLOAK-3339] - Enable authorization services to EAP6 adapter
* [KEYCLOAK-3479] - Providers in JEE deployment
* [KEYCLOAK-3648] - Support for importing SAML response multi-valued attributes
* [KEYCLOAK-3731] - Support broker initiated SSO
* [KEYCLOAK-3824] - Add expiration to keys cached by clients
* [KEYCLOAK-4005] - Add support for "not before" in the NodeJS adapter
* [KEYCLOAK-4009] - Compatibility with AD LDS
* [KEYCLOAK-4018] - Client-Based Policy
* [KEYCLOAK-4059] - Support for duplicate emails
* [KEYCLOAK-4087] - LDAP group mapping should be possible via uid in memberUid mode
* [KEYCLOAK-4092] - Add key provider for HMAC signatures
* [KEYCLOAK-4109] - Ability to disable impersonation
