/******************************************************************************
 * パケットフィルタ
 *****************************************************************************/
resource "sakuracloud_packet_filter" "filter" {
  name        = "${var.packet_filter_name}"
  description = "PacketFilter for kube-sacloud-devel"

  expressions = {
    protocol    = "tcp"
    dest_port   = "8080"
    description = "allow-healthz"
  }

  expressions = {
    protocol    = "tcp"
    dest_port   = "22"
    description = "allow-external"
  }

  expressions = {
    protocol    = "tcp"
    dest_port   = "3389"
    description = "allow-external"
  }

  expressions = {
    protocol    = "tcp"
    dest_port   = "6443"
    description = "allow-external"
  }

  expressions = {
    protocol    = "icmp"
    description = "allow-from-server"
  }

  expressions = {
    protocol    = "fragment"
    description = "allow-from-server"
  }

  expressions = {
    protocol    = "udp"
    source_port = "123"
    description = "allow-from-server"
  }

  expressions = {
    protocol    = "tcp"
    dest_port   = "32768-61000"
    description = "allow-from-server"
  }

  expressions = {
    protocol    = "udp"
    dest_port   = "32768-61000"
    description = "allow-from-server"
  }

  expressions = {
    protocol    = "ip"
    allow       = false
    description = "Deny ALL"
  }
}
