/******************************************************************************
 * GSLB
 *****************************************************************************/
resource "sakuracloud_gslb" "kubernetes_gslb" {
  name = "${var.gslb_name}"

  health_check = {
    protocol   = "tcp"
    port       = 8080
    delay_loop = 10
  }

  description = "GSLB for kubernetes remote access"
}

resource "sakuracloud_gslb_server" "kubernetes_controllers" {
  gslb_id   = "${sakuracloud_gslb.kubernetes_gslb.id}"
  ipaddress = "${sakuracloud_server.kube_sacloud_server.ipaddress}"
}
