resource helm_release agones {
  name             = "agones"
  repository       = "https://agones.dev/chart/stable"
  force_update     = var.force_update
  chart            = var.chart
  timeout          = 420
  version          = var.agones_version
  namespace        = "agones-system"
  create_namespace = true
  values           = var.values

  dynamic set {
    for_each = var.sets
    content {
      name  = set.key
      value = set.value
    }
  }
}
