locals {
  #Keep these two values higher or default to 3, it is a daemon set (value should be <= number of nodes available)
  consul_values = {
    "server.replicas"        = 1
    "server.bootstrapExpect" = 1
  }

  vault_values = {
    "server.ha.enabled"  = true
    "server.ha.replicas" = 1 # Keep this higher for higher availabilty
  }
}
