resource "kubernetes_pod" "createpod" {
  metadata {
    name = "mathgarage"
    labels = {
      App = "mathgarage"
    }
  }

  spec {
    container {
      image = "gcr.io/my-playground-268616/get_multiplication_facts:v0.1"
      name  = "mathgarage"

      port {
        container_port = 80
      }
    }
  }
}

resource "kubernetes_service" "createservice" {
  metadata {
    name = "mathgarage"
  }
  spec {
    selector = {
      App = kubernetes_pod.createpod.metadata[0].labels.App
    }
    port {
      port        = 80
      target_port = 5000
    }

    type = "LoadBalancer"
  }
}