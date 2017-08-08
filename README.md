This is a collection of Terraform modules that can be used to configure various Lambda function endpoints on AWS API Gateway.

These modules can be called in other terraform configurations by referencing their GitHub source, as follows:

* Resource Authorizer:
    ```HCL
    module "authorizer" {

        source = "git::git@github.com:API-market/terraform-modules.git//resourceauthorizer"

        config_bucket =
            name of the bucket to write details of the authorizer function that was created,
            so it can be used in protected resources

        authorizer_name =
            name of the authorizer to create
            (must be the filename of the Lambda code)
    }
    ```

* Protected Resource:
    ```HCL
    module "protectedresource" {

        source = "git::git@github.com:API-market/terraform-modules.git//protectedresource"

        aws_region =
            name of the region in which to create the protected resource

        resource_name =
            name of the resource to be made availabe and protected
            (must be the filename of the Lambda code)

        authorizer_name =
            authorizer function name to use to protect the resource
            (this is a Lambda function, created by the resource-authorizer code)

        environment_variables (optional) =
            what environment variables (if any) the Lambda function should be instantiated with
    }
    ```

* Unprotected Resource:
    ```HCL
    module "unprotectedresource" {

        source = "git::git@github.com:API-market/terraform-modules.git//unprotectedresource"

        aws_region =
            name of the region in which to create the protected resource

        resource_name =
            name of the resource to be made availabe and protected
            (must be the filename of the Lambda code)

        environment_variables (optional) =
            what environment variables (if any) the Lambda function should be instantiated with
    }
    ```
* Custom Domain:
    ```HCL
    module "test_apimarket_customdomain" {

        source = "git::git@github.com:API-market/terraform-modules.git//customdomain"

        domain =
            name of the custom domain to create (for example api.market)

        subdomain =
            name of the subdomain (for example test, to combine into test.api.market)
    }
    ```
See the hello-world-protected-resource and github-oauth-signin terraform files as an example.

Currently, only the root endpoint / is supported for all HTTP Methods (ANY); this will be changed in a future version.
