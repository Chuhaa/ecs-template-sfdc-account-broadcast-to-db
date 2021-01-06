import ballerina/io;
import ballerina/config;
import ballerina/log;
import ballerinax/sfdc;
import ballerinax/mysql;
import ballerina/sql;

sfdc:ListenerConfiguration listenerConfig = {
    username: config:getAsString("SF_USERNAME"),
    password: config:getAsString("SF_PASSWORD")
};

listener sfdc:Listener sfdcEventListener = new (listenerConfig);
mysql:Client mysqlClient =  check new (user = config:getAsString("DB_USER"),
                                        password = config:getAsString("DB_PWD"));

@sfdc:ServiceConfig {
    topic:config:getAsString("SF_ACCOUNT_BROADCAST_TOPIC")
}
service on sfdcEventListener {
    remote function onEvent(json op) {
        io:StringReader sr = new(op.toJsonString());
        json|error account = sr.readJson();
        if (account is json) {
            sql:Error? result  = addAccountToDB(account);
            if (result is error) {
                log:printError(result.message());
            }
        }
    }
}

function addAccountToDB(json account) returns sql:Error? {
    string id = account.sobject.Id.toString();
    string accountName = account.sobject?.Name.toString();
    string accountNumber = account.sobject?.AccountNumber.toString();
    string ownerId = account.sobject?.OwnerId.toString();
    string numberOfEmployees = account.sobject?.NumberOfEmployees.toString();
    string phone = account.sobject?.Phone.toString();
    string status = account.event.'type.toString();
    log:print("Id " + id + " " + status);

    sql:ParameterizedQuery insertQuery = `INSERT INTO ESC_SFDC_TO_DB.Account (Id, Name, AccountNumber, OwnerId, 
        NumberOfEmployees, Phone, Status) VALUES (${id}, ${accountName}, ${accountNumber}, ${ownerId},
        ${numberOfEmployees}, ${phone}, ${status}) ON DUPLICATE KEY UPDATE Name =  ${accountName},
        AccountNumber =  ${accountNumber}, OwnerId = ${ownerId}, NumberOfEmployees =  ${numberOfEmployees},
        Phone =  ${phone},  Status =  ${status};`;

    sql:ExecutionResult result  =  check mysqlClient->execute(insertQuery);
}
