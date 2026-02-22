# terraform_and_gitHub_action_workflows
Automate AWS Infra Deployment using Terraform and GitHub Actions Workflows

## To create an OIDC identity provider (IdP) in AWS and specify its audience for GitHub (AWS CLI)
- Provider URL (Issuer URL): `https://token.actions.githubusercontent.com`
- Audience (Client ID): `sts.amazonaws.com`
- `https://aws.amazon.com/blogs/security/use-iam-roles-to-connect-github-actions-to-actions-in-aws/`

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::<Account ID>:oidc-provider/token.actions.githubusercontent.com"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "token.actions.githubusercontent.com:sub": "repo:Ran-Itzhack/terraform_and_gitHub_action_workflows:ref:refs/heads/<ExampleBranch>",
                    "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
                }
            }
        }
    ]
}
```
terraform_and_gitHub_action_workflows

Automate AWS Infra Deployment using Terraform and GitHub Actions Workflows