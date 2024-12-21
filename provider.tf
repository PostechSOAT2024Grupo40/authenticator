

terraform {
  cloud {
    organization = "ambrosia-serve"

    workspaces {
      name = "postech-workspace"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Environment = "Production"
      Owner       = "Grupo-40"
      Project     = "Ambrosia Serve - Autenticacao"
    }
  }
}

