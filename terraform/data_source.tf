data "terraform_remote_state" "geral" {
  backend = "remote"

  config = {
    organization = "ambrosia-serve"
    workspaces = {
      name = "postech-workspace"
    }
  }
}