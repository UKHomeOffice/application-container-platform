## Run Performance Tests on a service hosted on ACP

#### As a Service, I should:

- Always have a baseline set of metrics of my isolated service
- Understand what those metrics need to be for each functionality i.e. how long file uploads should take vs a generic GET request
- Make sure the baseline does not include any other components i.e. networks, infrastructure etc.
- Expose a set of metrics, see [Metrics](../services.md##metrics-monitoring)
- Make performance testing part of my Continuous Integration workflow
- Have a history of performance over time

#### Assessed tools summary:

- An example usage of Blazemeter's Taurus in a drone pipeline can be seen in the [taurus-project-x repo](https://github.com/UKHomeOffice/taurus-project-x).
- [Artillery](https://github.com/shoreditch-ops/artillery) ([npm](https://www.npmjs.com/package/artillery)) was also tested w/ the [statsd plugin](https://github.com/shoreditch-ops/artillery-plugin-statsd), visualising data in grafana.
- SonarQube plugin jmeter-sonar is now deprecated. The latest version of sonarqube does not to have plugin support for jmeter
- another option is [k6](https://docs.k6.io/docs) - tool is written in go and tests are written in javascript. To visualise the only option is InfluxDB and Grafana.
