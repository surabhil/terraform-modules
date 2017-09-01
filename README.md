# terraform-modules

This is a collection of Terraform modules that can be used to configure various Lambda function endpoints on AWS API Gateway.

These modules can be called in other terraform configurations by referencing their GitHub source, as follows:

* API: creates a REST API on AWS API Gateway from a list of functions

    ```HCL
    module "api" {

        source = "git::git@github.com:API-market/terraform-modules.git//terraform-modules/api"

        aws_region =
            what region to create the API in

        config_bucket =
            what bucket to read/write configs to (needs to be apim-configs for now)

        api_name =
            what name to give the API. for the moment, it will also be used like this: test.api.market/api_name

        authorizers =
            a list of authorizers that the API call validators will accept. currently, only auth_1 exists

        names =
            a list of names of lambda functions to be created. there must be a corresponding file name.js

        paths =
            a list of paths to be created from each lambda. useful for mapping name.js to api_name/anothername

        methods =
            a list of methods each path above should accept. each list element must be a string, not a list.
            if you want to support multiple methods for an endpoint, use ANY and specify in your voucher what you accept

        validations =
            a list of validations to use. each element can either be NONE (unprotected) or CUSTOM (protected)

        environment_variables =
            a map of environment variables that ALL lambdas on the API will be instantiated with
            examples are private keys, or API names (see authorizer for details)

        validator_environment_variables =
            a map of environment variables that the API's validator will be instantiated with (eg naive = 'true')
    }

    ```

* Custom Domain: creates a custom domain from a domain and a subdomain (eg test.api.market)

    ```HCL
    module "test_apimarket_customdomain" {

        source = "git::git@github.com:API-market/terraform-modules.git//customdomain"

        domain =
            name of the custom domain to create (for example api.market)

        subdomain =
            name of the subdomain (for example test, to combine into test.api.market)
    }
    ```

* HTTP Resources: creates the required resources, integrations, and responses for a list of lambdas, paths, and parents. used by the API module. still missing is the ability to batch create lambdas outside of calling the API module

* Custom Validator: creates a lambda function from an included javascript file to validate tokens. used by the API module to create validators

See the hello-world and authorizer terraform files as an example.

Currently, only the root endpoint / is supported; this will be changed in a future version.
