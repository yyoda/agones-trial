variable force_update {
  default = true
}

variable chart {
  default = "agones"
}

variable agones_version {
  default = "1.4.0"
}

variable namespace {
  default = "agones-system"
}

variable values {
  type    = list(string)
  default = [""]
}

variable sets {
  type = map(string)
  default = {
    "crds.CleanupOnDelete"               = "true"
    "agones.image.registry"              = "gcr.io/agones-images"
    "agones.image.controller.pullPolicy" = "IfNotPresent"
    "agones.image.sdk.alwaysPull"        = "false"
    "agones.image.controller.pullSecret" = ""
    "agones.ping.http.serviceType"       = "LoadBalancer"
    "agones.ping.udp.expose"             = "true"
    "agones.ping.udp.serviceType"        = "LoadBalancer"
    "agones.controller.logLevel"         = "info"
    "agones.featureGates"                = ""
    "gameservers.namespaces"             = "default"
    "gameservers.minPort"                = "7000"
    "gameservers.maxPort"                = "8000"
  }
}
