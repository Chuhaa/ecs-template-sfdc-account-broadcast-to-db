# Salesforce to Database - Synchronize Accounts from Salesforce to a DB.


## Integration Use Case 

This integration template listens to the created, updated and deleted Salesforce Accounts and store store them to a database.

## Prerequisites

- [Ballerina Distribution](https://ballerina.io/learn/getting-started/)
- A Text Editor or an IDE ([VSCode](https://marketplace.visualstudio.com/items?itemName=ballerina.ballerina), 
[IntelliJ IDEA](https://plugins.jetbrains.com/plugin/9520-ballerina)).  
- [Salesforce Connector](https://github.com/ballerina-platform/module-ballerinax-sfdc) will be downloaded from 
[Ballerina Central](https://central.ballerina.io/) when running the Ballerina file.

#### Setup Salesforce configurations
Create a Salesforce account and create a connected app by visiting [Salesforce](https://www.salesforce.com). 

Salesforce username, password and the security token that will be needed for initializing the listener. 

For more information on the secret token, please visit [Reset Your Security Token](https://help.salesforce.com/articleView?id=user_security_token.htm&type=5).

#### Create push topic in Salesforce developer console

The Salesforce trigger requires topics to be created for each event. We need to configure topic to listen on 
both Account entity.

1. From the Salesforce UI, select developer console. Go to debug > Open Execute Anonymous Window. 
2. Paste following apex code to create 'AccountBroadcast' topic
```apex
PushTopic pushTopic = new PushTopic();
pushTopic.Name = 'AccountBroadcast';
pushTopic.Query = 'SELECT Id, Name, AccountNumber, OwnerId, NumberOfEmployees, Phone FROM Account';
pushTopic.ApiVersion = 48.0;
pushTopic.NotifyForOperationCreate = true;
pushTopic.NotifyForOperationUpdate = true;
pushTopic.NotifyForFields = 'Referenced';
insert pushTopic;
```
3. Once the creation is done, specify the topic name in the event listener service config.

## Confuring the Integration Template

Once you obtained all configurations, Replace "" in the `ballerina.conf` file with your data.

##### ballerina.conf
```

SF_USERNAME=""
SF_PASSWORD=""
SF_ACCOUNT_BROADCAST_TOPIC=""

DB_USER=""
DB_PWD=""

```

#### Setup Database
1. The account broadcasts are added to a database and this template uses MySQL as the RDBMS. 
2. You can create the required database and the tables using [accounts.sql](./accounts.sql) script. 
3. Based on the use case that you implement, you can change the database schema and the content that you wish to add to the database. 


## Running the Template

1. First you need to build the integration template and create the executable binary. Run the following command from the root directory of the integration template. 
`$ ballerina build`. 

2. Then you can run the integration binary with the following command. 
`$ ballerina run ./target/bin/ecs_template_sfdc_account_broadcast.jar`. 

Successful listener startup will print following in the console.
```
>>>>
[2020-09-25 11:10:55.552] Success:[/meta/handshake]
{ext={replay=true, payload.format=true}, minimumVersion=1.0, clientId=1mc1owacqlmod21gwe8arhpxaxxm, supportedConnectionTypes=[Ljava.lang.Object;@21a089fc, channel=/meta/handshake, id=1, version=1.0, successful=true}
<<<<
>>>>
[2020-09-25 11:10:55.629] Success:[/meta/connect]
{clientId=1mc1owacqlmod21gwe8arhpxaxxm, advice={reconnect=retry, interval=0, timeout=110000}, channel=/meta/connect, id=2, successful=true}
<<<<
```

3. Now you can create or update or delete an existing Salesforce Account and observe that integration template runtime has received the event notification for the broadcasted Salesforce Accounts.

4. Also you can check the Account table of the database to verify that the braodcasted Accounts are added to the table. 

