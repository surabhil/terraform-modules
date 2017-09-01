'use strict';

const crypto = require('crypto');

exports.handler =  (event, context, callback) => {
    let token = event.authorizationToken;

    let splits = event.methodArn.split(':');

    let path = splits[5].split('/');

    let method = path[2];

    let endpoint = path[3];

    if (process.env.hasOwnProperty('naive') && process.env.naive === "true") {
        if (token === 'allow') {
            callback(null, generatePolicy('user', 'Allow', event.methodArn));
        }
    }

    else {
        try {
            token = JSON.parse(token);
        }

        catch (err) {
            callback(null, generatePolicy('user', 'Deny', event.methodArn));
        }
    }

    if (token.hasOwnProperty('api') && token.hasOwnProperty('endpoint') && token.hasOwnProperty('method') && token.hasOwnProperty('authorizer')) {
        if (! process.env.hasOwnProperty(token.authorizer)) {
            callback(null, generatePolicy('user', 'Deny', event.methodArn));
        }

        else {
            if (token.api !== process.env.api || token.endpoint !== endpoint || token.method !== method) {
                callback(null, generatePolicy('user', 'Deny', event.methodArn));
            }

            else {
                let verify = crypto.createVerify('RSA-SHA256');

                let digest = token.api + token.endpoint + token.method + token.authorizer;

                verify.update(digest);

                let verified = verify.verify(process.env[token.authorizer], token.signature, 'hex');

                if (verified) {
                    callback(null, generatePolicy('user', 'Allow', event.methodArn));
                }

                else {
                    callback(null, generatePolicy('user', 'Deny', event.methodArn));
                }
            }
        }
    }

    else {
        callback(null, generatePolicy('user', 'Deny', event.methodArn));
    }

};

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
