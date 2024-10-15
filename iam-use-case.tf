terraform {
  required_providers {
    scaleway = {
      source = "scaleway/scaleway"
    }
  }
  required_version = ">= 0.13"
}

variable "access_key" {
  type = string
  sensitive = true
}

variable "secret_key" {
  type = string
  sensitive = true
}

variable "organization_id" {
  type = string
  sensitive = true
}

variable "project_id" {
  type = string
  sensitive = true
}

provider "scaleway" {
  access_key      = var.access_key
  secret_key      = var.secret_key
  organization_id = var.organization_id
  project_id      = var.project_id
}

# Projects
resource "scaleway_account_project" "project_strawberry_development" {
  name = "Strawberry Development"
}
resource "scaleway_account_project" "project_strawberry_production" {
  name = "Strawberry Production"
}
resource "scaleway_account_project" "project_pineapple_development" {
  name = "Pineapple Development"
}
resource "scaleway_account_project" "project_pineapple_production" {
  name = "Pineapple Production"
}

# Groups
resource "scaleway_iam_group" "pineapple_developers"{
  name = "Group - Pineapple Developers"
}

resource "scaleway_iam_group" "strawberry_developers"{
  name = "Group - Strawberry Developers"
}

resource "scaleway_iam_group" "pineapple_production_applications"{
  name = "Group - Pineapple Production"
    application_ids = [
    scaleway_iam_application.app_pineapple_1.id,
  ]

}

resource "scaleway_iam_group" "strawberry_production_applications"{
  name = "Group - Strawberry Production"
  application_ids = [
    scaleway_iam_application.app_strawberry_1.id,
  ]
}
# Applications and their API Keys
resource "scaleway_iam_application" "app_strawberry_1" {
  name       = "Application Strawberry - 1"
}
resource "scaleway_iam_api_key" "apikey_strawberry_1" {
  application_id = scaleway_iam_application.app_strawberry_1.id
}

resource "scaleway_iam_application" "app_pineapple_1" {
  name       = "Application Pineapple - 1"
}
resource "scaleway_iam_api_key" "apikey_pineapple_1" {
  application_id = scaleway_iam_application.app_strawberry_1.id
}
output "secret_key" {
  value = scaleway_iam_api_key.apikey_pineapple_1.secret_key
  sensitive = true
}

#Policies
resource "scaleway_iam_policy" "policy_pineapple_developers"{
  name = "Policy for pineapple Developers"
  description = "gives access to developers pineapple"
  group_id = scaleway_iam_group.pineapple_developers.id
  rule {
    project_ids = [scaleway_account_project.project_pineapple_development.id]
    permission_set_names = ["ObjectStorageFullAccess"]
  }
}

resource "scaleway_iam_policy" "policy_strawberry_developers"{
  name = "Policy for Strawberry Developers"
  description = "gives access to developers strawberry"
  group_id = scaleway_iam_group.strawberry_developers.id
  rule {
    project_ids = [scaleway_account_project.project_strawberry_development.id]
    permission_set_names = ["ObjectStorageFullAccess"]
  }
}

resource "scaleway_iam_policy" "policy_pineapple_production"{
  name = "Policy for pineapple in production"
  description = "gives access to developers in production"
  group_id = scaleway_iam_group.pineapple_production_applications.id
  rule {
    project_ids = [scaleway_account_project.project_pineapple_development.id]
    permission_set_names = ["ObjectStorageObjectsWrite"]
  }
}

resource "scaleway_iam_policy" "policy_strawberry_production"{
  name = "Policy for strawberry in production"
  description = "gives access to developers in production for strawberry"
  group_id = scaleway_iam_group.strawberry_production_applications.id
  rule {
    project_ids = [scaleway_account_project.project_pineapple_development.id]
    permission_set_names = ["ObjectStorageObjectsWrite"]
  }
}