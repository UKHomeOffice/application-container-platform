
# Artifactory overview

ACP uses Artifactory as its internal binary store for projects to push build time artefacts and dependencies to, such as jars and python modules.

Artifactory organises artefacts into the following repositories:

- Local Repositories
- Remote Repositories
- Virtual Repositories

### Local Repositories

Local repositories are physical, locally-managed repositories into which you can deploy artefact.
You can access artefacts in local repositories using the following URL:

`https://artifactory.digital.homeoffice.gov.uk/artifactory/<local-repository-name>/<artifact-path>`

### Remote Repositories

A remote repository serves as a caching proxy for a repository managed at a remote URL (which may itself be another Artifactory remote repository).  artefacts are stored and updated in remote repositories according to various configuration parameters that control the caching and proxying behavior.

You can remove artefacts from a remote repository cache but you cannot deploy a new artefact into a remote repository.

You can access artefacts in remote repositories using the following URL:

`https://artifactory.digital.homeoffice.gov.uk/artifactory/<remote-repository-name>/<artifact-path>`

### Virtual Repositories

A virtual repository (or "repository group") aggregates several repositories with the same package type under a common URL.

Local and remote repositories are true physical repositories, while a virtual repository is an aggregation of them used to create controlled domains for search and resolution of artefacts.

---------------------------------------------

## Searching for artefacts

There are two ways to search artefacts using the UI and by API.


You can find artefacts in Artifactory using one of the following searches:

- **Quick:** Search by artefact file name
- **Package:** Search for artefacts according to the criteria specific to the package format
- **Archive Entries:** Search for files that reside within archives (e.g. within a jar file)
- **Property:** Search for artefacts based on names and values of properties assigned to them
- **Checksum:** Search for artefacts based on their checksum value
- **JCenter:** Search for artefacts in Bintray's JCenter repository
- **Trash Can:** Search for artefacts in Artifactory's trash can


### Search Results Stash

Artifactory maintains a stash where you can save search results. This provides easy access to artefacts you can find without having to run the search again and also provides a convenient way to perform bulk operations on the result set.
For details, please refer to Saving [Search Results in the Stash](https://www.jfrog.com/confluence/display/RTF6X/Smart+Searches#SmartSearches-SavingSearchResultsintheStash).

### Search through API

Additional advanced search features are available through the REST API, including an advanced Artifactory Query Language.  Below is a list of some of the most useful api search options with its description. You can link any of them for more information.

- **[Artifactory Query Language (AQL):](https://www.jfrog.com/confluence/display/JFROG/Artifactory+REST+API#:~:text=SEARCHES-,Artifactory%20Query%20Language,-%28AQL%29)**  Flexible and high performance search using Artifactory Query Language (AQL).
- **[Artifact Search (Quick Search)](https://www.jfrog.com/confluence/display/JFROG/Artifactory+REST+API#:~:text=Query%20Language%20%28AQL%29-,Artifact%20Search%20%28Quick%20Search%29,-Archive%20Entries%20Search)** : artefact search by part of file name. Searches return file info URIs. Can limit search to specific repositories (local or caches).
- **Archive Entries Search (Class Search):**Search archive for classes or any other resources within an archive. Can limit search to specific repositories (local or caches).
- **[GAVC Search:](https://www.jfrog.com/confluence/display/JFROG/Artifactory+REST+API#:~:text=Search%20%28Class%20Search%29-,GAVC%20Search,-Property%20Search)** Search by Maven coordinates: GroupId, ArtifactId, Version & Classifier. Search must contain at least one argument. Can limit search to specific repositories (local and remote-cache).
- **[artefacts With Date in Date Range:](https://www.jfrog.com/confluence/display/JFROG/Artifactory+REST+API#:~:text=Not%20Downloaded%20Since-,artefacts%20With%20Date%20in%C2%A0Date%20Range,-artefacts%20Created%20in)** Get all artefacts with specified dates within the given range. Search can be limited to specific repositories (local or caches).
- **[artefacts Created in Date Range:](https://www.jfrog.com/confluence/display/JFROG/Artifactory+REST+API#:~:text=in%C2%A0Date%20Range-,artefacts%20Created%20in%20Date%20Range,-Pattern%20Search) ** Get All artefacts Created in Date Range
- **[Pattern Search](https://www.jfrog.com/confluence/display/JFROG/Artifactory+REST+API#:~:text=in%20Date%20Range-,Pattern%20Search,-Builds%20for%20Dependency)** - Get all artefacts matching the given Ant path pattern
- **[List Docker Repositories:](https://www.jfrog.com/confluence/display/JFROG/Artifactory+REST+API#:~:text=Build%20artefacts%20Search-,List%20Docker%20Repositories,-List%20Docker%C2%A0Tags)** Lists all Docker repositories (the registry's _catalog) hosted in an Artifactory Docker repository.
- **[List Docker Tags:](https://www.jfrog.com/confluence/display/JFROG/Artifactory+REST+API#:~:text=List%20Docker%20Repositories-,List%20Docker%C2%A0Tags,-SECURITY)**  Lists all tags of the specified Artifactory Docker repository.


## Example - using the API for search
When searching  for a file using the api and your username and password for authentication, you would use the following command:

`curl -u myUser:myP455w0rd! -X GET “https://artifactory.digital.homeoffice.gov.uk/artifactory//api/search/artifact?name=lib&repos=libs-release-local”`

However if you wish to use an access token  or  API Key, replace the password with your key/token

`curl -u myUser:{access token/API Key} -X GET “https://artifactory.digital.homeoffice.gov.uk/artifactory//api/search/artifact?name=lib&repos=libs-release-local”`


## Deploying artefacts

The Artifact Repository Browser allows you to deploy artefacts into a local repository from the Artifacts module. You can deploy artefacts individually or in multiples.

### Deploying a Single artefact using UI

To deploy a single artefact, simply fill in the fields in the Deploy dialog and click Deploy. Each package type has its own layout.

### Deploying a Single artefact using API

To deploy artefacts to any repository using the Artifactory REST API, see the following example:

`curl -u myUser:myP455w0rd! -X PUT "http://artifactory.digital.homeoffice.gov.uk/artifactory/my-repository/my/new/artifact/directory/file.txt" -T Desktop/myNewFile.txt`

However if you wish to use an access token  or  API Key, replace the password with your key/token.

`curl -u myUser:{access token/API Key} -X PUT "http://artifactory.digital.homeoffice.gov.uk/artifactory/my-repository/my/new/artifact/directory/file.txt" -T Desktop/myNewFile.txt`
