// Copyright (c) 2018 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/http;
import ballerina/testobserve;
import ballerina/observe;

endpoint http:Listener listener1 {
    port : 9091
};

@http:ServiceConfig {
    basePath:"/echoService"
}
service echoService1 bind listener1 {
    resourceOne (endpoint caller, http:Request clientRequest) {
        int spanId = check observe:startSpan("uSpanOne");
        http:Response outResponse = new;
        var response = check callNextResource1();
        outResponse.setTextPayload("Hello, World!");
        _ = caller -> respond(outResponse);
        _ = observe:finishSpan(spanId);
    }

    resourceTwo (endpoint caller, http:Request clientRequest) {
        http:Response res = new;
        res.setTextPayload("Hello, World 2!");
        _ = caller -> respond(res);
    }

    getMockTracers(endpoint caller, http:Request clientRequest) {
        http:Response res = new;
        json returnString = testobserve:getMockTracers();
        res.setJsonPayload(returnString);
        _ = caller -> respond(res);
    }
}

function callNextResource1() returns (http:Response | error) {
    endpoint http:Client httpEndpoint {
        url: "http://localhost:9091/echoService"
    };
    int spanId = check observe:startSpan("uSpanTwo");
    http:Response resp = check httpEndpoint -> get("/resourceTwo");
    _ = observe:finishSpan(spanId);
    return resp;
}
