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
* [KEYCLOAK-4501] - Federated identity managment
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
