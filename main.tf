terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "mel-ciscolabs-com"
    workspaces {
      name = "iks-cpoc-syd-demo-1"
    }
  }
  required_providers {
    intersight = {
      source = "CiscoDevNet/intersight"
      # version = "1.0.12"
    }
  }
}

### Providers ###
provider "intersight" {
  # Configuration options
  apikey    = var.intersight_key
  secretkey = var.intersight_secret
  endpoint =  var.intersight_url
}

### Intersight Organization ###
data "intersight_organization_organization" "org" {
  name = var.org_name
}

## IKS Module ##
module "terraform-intersight-iks" {
  source  = "terraform-cisco-modules/iks/intersight"
  # version = "2.2.0"

  # Cluster information
  cluster = {
    name                = var.cluster_name
    ## Tries to deploy before profile is complete - need to deploy twice ...
    action              = "Unassign" # Unassign, Deploy, Undeploy
    ## Note: You cannot assign the cluster action as "Deploy" and "wait_for_completion" as TRUE at the same time.
    wait_for_completion = false
    worker_nodes        = var.worker_nodes
    load_balancers      = var.load_balancer_ips
    worker_max          = var.worker_nodes_max
    control_nodes       = var.control_nodes
    ssh_user            = var.ssh_user
    ssh_public_key      = var.ssh_key
  }


  # Organization and Tag
  organization = var.org_name
  tags         = var.tags


  # Associated Policies
  ip_pool = {
    use_existing = true
    name         = "tf-iks-ftd-gw"
  }

  sysconfig = {
    # a.k.a Node OS Configuration
    use_existing = true
    name         = "tf-iks-cpoc-sysconfig"
  }

  k8s_network = {
    use_existing = true
    name         = "tf-calico-172"
  }

  versionPolicy = {
    useExisting = true
    policyName  = "tf-iks-1-20-4" #"tf-iks-ob-latest"
  }

  tr_policy = {
    ### Needs to be set with "use_existing" & "create_new" as false to not deploy a Trusted Registry Policy
    use_existing = false
    create_new   = false
  }

  runtime_policy = {
    ### Needs to be set with "use_existing" & "create_new" as false to not deploy a Runtime Policy
    use_existing = false
    create_new   = false
  }

  infraConfigPolicy = {
    use_existing = true
    policyName   = "cpoc-hx"  ## Note: Manual policy - not in TF common policy set
  }

  addons = [
    {
    createNew = false
    addonPolicyName   = "tf-smm-1-8-2"
    }
  ]

  instance_type = {
    use_existing = true
    name = "tf-iks-10C-64G-60G"
  }
}
