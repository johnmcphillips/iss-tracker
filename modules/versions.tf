terraform {
  cloud {
    organization = "johnmcphillips"
    workspaces {
      name = "iss-tracker"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.30"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.7.1"
    }

    archive = {
      source  = "hashicorp/archive"
      version = "2.4.0"
    }
  }

  required_version = ">= 1.11.1"
}