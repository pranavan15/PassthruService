import ballerina/net.http;
import ballerina/io;

endpoint http:ServiceEndpoint passthruEP {
    port:9090
};

endpoint http:ServiceEndpoint backendEP {
    port:8080
};

endpoint http:ClientEndpoint backendClientEP {
    targets:[{uri: "http://localhost:8080"}]
};

@http:ServiceConfig {
    basePath:"/passthru"
}
service<http: Service> passthrough bind passthruEP {

    @http:ResourceConfig {
        methods:["GET"],
        path:"/"
    }
    passthru (endpoint client, http:Request request) {
        var resp = backendClientEP -> forward("/hello", request);
        match resp {
            http:HttpConnectorError err => io:println("Error occured");
            http:Response response => {
                _ = client -> forward(response);
            }
        }
    }
}

@http:ServiceConfig {
    basePath:"/hello"
}
service<http: Service> hello bind backendEP {

    @http:ResourceConfig {
        methods:["GET"],
        path:"/"
    }
    sayHello (endpoint client, http:Request request) {
        http:Response response = {};
        response. setStringPayload("Hello from Passthrough service!!!");
        _ = client -> respond( response);
    }
}
