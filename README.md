This is a collection of Terraform modules that can be used to configure various Lambda function endpoints on AWS API Gateway.

These modules can be called in other terraform configurations by referencing their GitHub source:
* Protected Resource:
    ```HCL
    module "protectedresource" {

    source = "git::git@github.com:API-market/terraform-modules.git//protectedresource"

    resource_name = name of the resource to be protected

    authorizer_name =
            authorizer function name to use to protect the resource
    authorizer_arn =
            authorizer function arn
    authorizer_invoke_arn =
            authorizer function invoke arn

    environment_variables (optional) = what environment variables (if any)
            the Lambda function should be instantiated with

    }
    ```

* Unprotected Resource:
    ```HCL
    module "unprotectedresource" {

    source = "git::git@github.com:API-market/terraform-modules.git//unprotectedresource"

    resource_name =
            name of the resource to be protected (must be the filename of the Lambda code)

    environment_variables (optional) =
            what environment variables (if any) the Lambda function
            should be instantiated with

    }
    ```

See the hello-world-protected-resource terraform files as an example.

Currently, only the root endpoint / is supported for all HTTP Methods (ANY); this will be changed in a future version.