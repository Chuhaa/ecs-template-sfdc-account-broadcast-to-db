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
    topic:config:getAsString("SF_OPPORTUNITY_TOPIC")
}

service on sfdcEventListener {
    remote function onEvent(json op) {
        io:StringReader sr = new(op.toJsonString());
        json|error account = sr.readJson();
        if (account is json) {
            string accountName = account.sobject.Name.toString();
            log:print(accountName);
            sql:Error? result  = addAccountToDB(account);
            if (result is error) {
                log:printError(result.message());
            }
        }
    }
}

function addAccountToDB(json account) returns sql:Error? {
    string id = account.sobject.Id.toString();
    string accountName = account.sobject.Name.toString();
    
    sql:ParameterizedQuery insertQuery = `INSERT INTO ESC_SFDC_TO_DB.Account (Id, Name) 
            VALUES (${id}, ${accountName}) ON DUPLICATE KEY UPDATE Name =  ${accountName};`;
    sql:ExecutionResult result  =  check mysqlClient->execute(insertQuery);
}
