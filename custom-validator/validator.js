'use strict';

const crypto = require('crypto');

exports.handler =  (event, context, callback) => {

    // get token
    let token = event.authorizationToken;

    // get method and endpoint; we already know what API we're on (process.env.api)
    let splits = event.methodArn.split(':');

    // magic numbers come from looking at event.methodArn, still need to implement multi-part paths
    let path = splits[5].split('/');

    let method = path[2];

    let endpoint = path[3];

    // check if we're naive, if we are, check if the token simply reads 'allow', if it does, validate the request
    if (process.env.hasOwnProperty('naive') && process.env.naive === "true") {
        if (token === 'allow') {
            callback(null, generatePolicy('user', 'Allow', event.methodArn));
        }
    }

    // otherwise try to parse the token, if we can't, deny the request
    else {
        try {
            token = JSON.parse(token);
        }

        catch (err) {
            callback(null, generatePolicy('user', 'Deny', event.methodArn));
        }
    }

    // check that the token isn't missing any required properties
    if (token.hasOwnProperty('api') && token.hasOwnProperty('endpoint') && token.hasOwnProperty('method') && token.hasOwnProperty('authorizer')) {

        // check that the authorizer that signed the token is one that we accept, if we don't, deny the request
        if (! process.env.hasOwnProperty(token.authorizer)) {
            callback(null, generatePolicy('user', 'Deny', event.methodArn));
        }

        // if we accept the authorizer, verify that the token's api, method, and endpoint match what's actually being requested
        else {
            if (token.api !== process.env.api || token.endpoint !== endpoint || token.method !== method) {
                callback(null, generatePolicy('user', 'Deny', event.methodArn));
            }

            // if they do, we can finally try to verify the signature
            else {
                let verify = crypto.createVerify('RSA-SHA256');

                let digest = token.api + token.endpoint + token.method + token.authorizer;

                verify.update(digest);

                let verified = verify.verify(process.env[token.authorizer], token.signature, 'hex');

                // if we are able to verify the signature, allow the request, otherwise deny it
                if (verified) {
                    callback(null, generatePolicy('user', 'Allow', event.methodArn));
                }

                else {
                    callback(null, generatePolicy('user', 'Deny', event.methodArn));
                }
            }
        }
    }

    // if it is missing any required properties, deny the request
    else {
        callback(null, generatePolicy('user', 'Deny', event.methodArn));
    }

};

// policy generator copied from AWS API GW docs
let generatePolicy = function(principalId, effect, resource) {
    let authResponse = {};

    authResponse.principalId = principalId;
    if (effect && resource) {
        let policyDocument = {};
        policyDocument.Version = '2012-10-17'; // default version
        policyDocument.Statement = [];
        let statementOne = {};
        statementOne.Action = 'execute-api:Invoke'; // default action
        statementOne.Effect = effect;
        statementOne.Resource = resource;
        policyDocument.Statement[0] = statementOne;
        authResponse.policyDocument = policyDocument;
    }

    return authResponse;
};
