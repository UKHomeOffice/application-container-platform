
# **DMS Migration**

### **Prerequisite**

The following need to be true before you follow this guide:
* AWS console logon
* Access the DMS service from console
* A region where STS has been activated

### **DMS Setup** 

Login to the AWS console using your auth, switch to a role with the correct access policies and verify you're in the right region. Next, select DMS from the services on the main dashboard to access to data migration home screen. Under the "Get started" section click on the "create migration" button then next to the Replication instance. You should see the following screen:

![Alt text](pics/dms-doc-1.png?raw=true)

The following are the options and example answer for the replication instance:

Option | Example answer | Description
---- | ------------ | -----------
Name | dev-team-dms | A name for the replication image. This name should be unique.
Description | DMS instance for migration | Brief description of the instance
Instance class | dms.t2.medium | The class of replication resource with the configuration you need for your migration.
VPC | vpc-* | The virtual private cloud resource where you wish to add your dms instance. This should be as close to both the source and target instance as possible.
Multi-AZ | No | Optional parameter to create a standby replica of your replication instance in another Availability Zone. Used for failover.
Publicly Accessible | False | Option to access your instance from the internet

You won't need to set any of the advanced settings. To create the instance click on the next button. You should now see a screen like this: 

![Alt text](pics/dms-doc-2.png?raw=true)

The following are the options and an example of answer for this endpoints instances page:

Option | Example answer | Description
------ | -------------- | -----------
Endpoint identifer | database-source/target | This is the name you want to use to identify the endpoint.
Source/target engine | postgres | Choose the type of database engine that for this endpoint.
Server name | mysqlsrvinst.abcd123456789.us-west-1.rds.amazonaws.com | Type of server name. For an on-premises database, this can be the IP address or the public hostname. For an Amazon RDS DB instance, this can be the endpoint for the DB instance.
Port | 5432 | The port used by the database.
SSL mode | None | SSL mode for encryption for your endpoints. 
Username | root | The user name with the permissions required to allow data migration.
Password | ******** | The password for the account with the required permissions.
Database Name (target) | dev-db | The name of the attached database to the selcted endpoint.

Repeat these options for both source and target and make sure to test connection before clicking next. You might need to append security group rules to allow the replication instance access, for example:

Replication instance has internal ip address 10.20.0.0 and the RDS is on port 5432 and uses TCP. Append rule 

Type | Procol | Port Range | Source
---- | ------ | ---------- | ------
Custom TCP rule | TCP | 5432 | Custom 10.20.0.0/32


 Once this has fully been setup click next and you should be able to view the tasks page:


![Alt text](pics/dms-doc-3.png?raw=true)
![Alt text](pics/dms-doc-4.png?raw=true)

The following are the options and an example of answers for this tasks page:
Option | Example answer | Description
------ | -------------- | -----------
Task name | Migration-task | A name for the task.
Task Description | Task for migrating | A description for the task.
Source endpoint | source-instance | The source endpoint for migration.
Target endpoint | target-instance | The target endpoint for migration.
Replication instance | replication-instance | The replication isntance which will be used.
Migration type | Migrate existing data | Migration method you wnat to use. 
Start task on create | True | When selected the task begins as soon as it is created.
Target table preparation | Drop table on target | Migration strategy on target.
Include LOB columns in replication | Limited LOB mode | Migration of large objects on target.
Max LOB size | 32 kb | Maximum size of large objects.
Enable logging | False | When selected migration events are logged.

After completion the job will automatically run if "start task on create" has been selected. If not, the job can be started in the tasks section by selecting it and clicking on the "Start/Resume" button.