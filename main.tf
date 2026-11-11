terraform {

  cloud {

    organization = "snowflake-terraform-lab"
    workspaces {
      name = "gh-actions-demo"
    }

  }

  required_providers {
        snowflake = {
            source = "snowflakedb/snowflake"
            version = "~> 2.0"
        }
  }
  
}

provider "snowflake" {

  organization_name = "TNEULKY"
  account_name = "JT38090"
  role = "ACCOUNTADMIN"
  
}

resource "snowflake_database" "demo_db" {

  name = "DEMO_DB"

}

resource "snowflake_account_role" "demo_db_admin" {
  name = "DEMO_DB_ADMIN"
}

resource "snowflake_grant_privileges_to_account_role" "demo_db_usage" {
  account_role_name = snowflake_account_role.demo_db_admin.name
  privileges        = ["USAGE"]

  on_account_object {
    object_type = "DATABASE"
    object_name = snowflake_database.demo_db.name
  }
}

resource "snowflake_schema" "demo_schema" {
  database = snowflake_database.demo_db.name
  name     = "DEMO_SCHEMA"
  comment  = "Managed by Terraform GitHub Actions CI/CD"
}

resource "snowflake_grant_privileges_to_account_role" "demo_schema_usage" {
  account_role_name = snowflake_account_role.demo_db_admin.name
  privileges        = ["USAGE"]

  on_schema {
    schema_name = "\"${snowflake_database.demo_db.name}\".\"${snowflake_schema.demo_schema.name}\""
  }
}