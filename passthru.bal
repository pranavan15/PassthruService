import ballerina/net.http;
import ballerina/io;

// Service endpoint for passthru service
endpoint http:ServiceEndpoint passthruEP {
    port:9090
};

// Service endpoint for 'hello' backend service
endpoint http:ServiceEndpoint backendEP {
    port:8080
};

// Client endpoint
endpoint http:ClientEndpoint backendClientEP {
    targets:[{uri: "http://localhost:8080"}]
};

@http:ServiceConfig {
    basePath:"/passthru"
}
service<http:Service> passthrough bind passthruEP {

    @http:ResourceConfig {
        methods:["GET"],
        path:"/"
    }
    passthru (endpoint client, http:Request request) {
        // Call the 'hello' backend and get the response
        var resp = backendClientEP -> forward("/hello", request);
        // Deconstruct the tuple resp by matching its elements
        match resp {
            http:HttpConnectorError err => io:println("Error occured");
            // Forward the response to the client
            http:Response response => {
                _ = client -> forward(response);
            }
        }
    }
}

@http:ServiceConfig {
    basePath:"/hello"
}
service<http:Service> hello bind backendEP {

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
