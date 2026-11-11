# Snowflake Infrastructure Automation with Terraform & GitHub Actions

An Infrastructure as Code (IaC) project demonstrating how to provision, manage, and automate Snowflake infrastructure using **Terraform, HCP Terraform, and GitHub Actions**.

The project implements a CI/CD pipeline that detects infrastructure changes in GitHub, generates Terraform execution plans, and applies approved branch changes to Snowflake through HCP Terraform.

## Architecture

```text
Developer / GitHub Codespaces
            |
            | Git Push / Pull Request
            v
      GitHub Repository
            |
            v
       GitHub Actions
            |
            | Checkout Repository
            | Setup Terraform
            | Authenticate with HCP Terraform
            | Terraform Init
            | Terraform Plan
            | Terraform Apply (main branch only)
            v
        HCP Terraform
            |
            | Remote Execution
            | Terraform State Management
            v
          Snowflake
            |
            +-- DEMO_DB
            |     |
            |     +-- DEMO_SCHEMA
            |
            +-- DEMO_DB_ADMIN (Role)
                  |
                  +-- USAGE on DEMO_DB
                  +-- USAGE on DEMO_DB.DEMO_SCHEMA
```

## Technology Stack

| Technology | Purpose |
|---|---|
| Snowflake | Cloud data platform |
| Terraform | Infrastructure as Code |
| Snowflake Terraform Provider | Snowflake resource management |
| HCP Terraform | Remote Terraform execution and state management |
| GitHub Actions | CI/CD automation |
| GitHub Codespaces | Cloud-based development environment |
| Git | Version control |

## Infrastructure Resources

The following Snowflake resources are managed through Terraform:

| Resource | Name | Description |
|---|---|---|
| Database | `DEMO_DB` | Terraform-managed database |
| Schema | `DEMO_SCHEMA` | Schema inside `DEMO_DB` |
| Account Role | `DEMO_DB_ADMIN` | Custom Snowflake role |
| Database Grant | `USAGE` | Database access permission |
| Schema Grant | `USAGE` | Schema access permission |

All resources are defined declaratively in `main.tf`.

Terraform compares the desired infrastructure configuration against the current infrastructure state and generates an execution plan describing the required changes.

## CI/CD Pipeline

The GitHub Actions workflow is defined in:

`.github/workflows/terraform.yml`

### Pull Request Workflow

When a pull request targets the `main` branch:

1. Check out the repository.
2. Install Terraform.
3. Authenticate with HCP Terraform.
4. Initialize the Terraform configuration.
5. Generate a Terraform execution plan.

Infrastructure changes are not applied during pull request runs.

### Main Branch Workflow

When changes are pushed to `main`:

1. Check out the repository.
2. Install Terraform.
3. Authenticate with HCP Terraform.
4. Initialize Terraform.
5. Generate an execution plan.
6. Execute `terraform apply`.

The apply command uses automatic approval. Production deployments should include appropriate review and access controls.

## HCP Terraform Integration

HCP Terraform is configured as the remote execution and state management platform.

**Configuration:**

- Organization: `snowflake-terraform-lab`
- Workspace: `gh-actions-demo`
- Execution Mode: Remote
- Terraform Version: `1.17.1`
- Snowflake Provider: `snowflakedb/snowflake`

GitHub Actions authenticates with HCP Terraform using an API token stored in GitHub Actions Secrets.

The token is not committed to the repository.

## Infrastructure Change Validation

The CI/CD pipeline was tested by modifying the description of an existing Snowflake schema.

**Terraform configuration change:**

```hcl
resource "snowflake_schema" "demo_schema" {
  database = snowflake_database.demo_db.name
  name     = "DEMO_SCHEMA"
  comment  = "Managed by Terraform GitHub Actions CI/CD"
}
```

**Terraform Plan result:**

```text
Plan: 0 to add, 1 to change, 0 to destroy.
```

**Terraform Apply result:**

```text
snowflake_schema.demo_schema: Modifying...
snowflake_schema.demo_schema: Modifications complete after 1s

Apply complete! Resources: 0 added, 1 changed, 0 destroyed.
```

**Snowflake verification:**

The schema was queried directly using Snowflake CLI.

```json
{
  "name": "DEMO_SCHEMA",
  "database_name": "DEMO_DB",
  "comment": "Managed by Terraform GitHub Actions CI/CD"
}
```

This confirms that the infrastructure change was successfully propagated from GitHub through GitHub Actions and HCP Terraform to Snowflake.

## Repository Structure

```text
snowflake-terraform-github-cicd/
├── .github/
│   └── workflows/
│       └── terraform.yml
├── .gitignore
├── .terraform.lock.hcl
├── main.tf
└── README.md
```

## Key Concepts Demonstrated

- Infrastructure as Code (IaC)
- Declarative infrastructure management
- Snowflake resource provisioning
- Role-Based Access Control (RBAC)
- Terraform dependency management
- Remote Terraform state
- GitHub Actions CI/CD
- Automated infrastructure deployment
- Infrastructure change detection
- Git-based infrastructure version control

## Reference

Based on the official Snowflake developer guide:

[DevOps: Database Change Management with Terraform and GitHub](https://www.snowflake.com/en/developers/guides/devops-dcm-terraform-github/)

## Project Status

**Completed:** Snowflake infrastructure provisioning, Terraform remote execution, GitHub Actions integration, and end-to-end CI/CD deployment validation.