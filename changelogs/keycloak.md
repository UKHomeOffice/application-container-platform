
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
