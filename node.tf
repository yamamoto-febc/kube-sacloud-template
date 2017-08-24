/******************************************************************************
 * SSH公開鍵
 *****************************************************************************/
resource sakuracloud_ssh_key "ssh_key" {
  name       = "${var.ssh_key_name}"
  public_key = "${tls_private_key.ssh_private_key.public_key_openssh}"
}

/******************************************************************************
 * ディスク
 *****************************************************************************/
resource sakuracloud_disk "kube_sacloud_disk" {
  name              = "${var.disk_name}"
  source_archive_id = "${data.sakuracloud_archive.archive.id}"
  ssh_key_ids       = ["${sakuracloud_ssh_key.ssh_key.id}"]
  note_ids          = ["${sakuracloud_note.allow_sudo.id}", "${sakuracloud_note.set_eth1.id}"]
  hostname          = "${var.server_name}"
  password          = "${var.password}"
  disable_pw_auth   = true
  size              = "${var.server_spec["disk_size"]}"
}

/******************************************************************************
 * パブリックアーカイブ
 *****************************************************************************/
data sakuracloud_archive "archive" {
  os_type = "ubuntu"
}

/******************************************************************************
 * サーバ
 *****************************************************************************/
resource sakuracloud_server "kube_sacloud_server" {
  name        = "${var.server_name}"
  description = "kube-sacloud server for development"
  tags        = ["kube-sacloud-devel", "worker", "controller"]
  core        = "${var.server_spec["core"]}"
  memory      = "${var.server_spec["memory"]}"

  additional_nics   = [""]
  disks             = ["${sakuracloud_disk.kube_sacloud_disk.id}"]
  packet_filter_ids = ["${sakuracloud_packet_filter.filter.id}"]

  connection {
    host        = "${self.ipaddress}"
    user        = "ubuntu"
    private_key = "${tls_private_key.ssh_private_key.private_key_pem}"
  }

  # CA cert and key
  provisioner "file" {
    content     = "${tls_self_signed_cert.ca_cert.cert_pem}"
    destination = "/home/ubuntu/ca.pem"
  }

  provisioner "file" {
    content     = "${tls_private_key.ca_private_key.private_key_pem }"
    destination = "/home/ubuntu/ca-key.pem"
  }

  # kubernetes server cert and key
  provisioner "file" {
    content     = "${tls_locally_signed_cert.kube_server_cert.cert_pem}"
    destination = "/home/ubuntu/kubernetes.pem"
  }

  provisioner "file" {
    content     = "${tls_private_key.kube_server_private_key.private_key_pem }"
    destination = "/home/ubuntu/kubernetes-key.pem"
  }

  # kube-proxy cert and key
  provisioner "file" {
    content     = "${tls_locally_signed_cert.kube_proxy_cert.cert_pem}"
    destination = "/home/ubuntu/kube-proxy.pem"
  }

  provisioner "file" {
    content     = "${tls_private_key.kube_proxy_private_key.private_key_pem }"
    destination = "/home/ubuntu/kube-proxy-key.pem"
  }

  # tls bootstrap token
  provisioner "file" {
    content     = "${random_id.bootstrap_token.hex},kubelet-bootstrap,10001,\"system:kubelet-bootstrap\""
    destination = "/home/ubuntu/token.csv"
  }

  provisioner "file" {
    source      = "provisioning/wait-for-it.sh"
    destination = "/home/ubuntu/wait-for-it.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "${data.template_file.setup_etcd.rendered}",
      "${data.template_file.bootstrap_kube_controller.rendered}",
    ]
  }

  provisioner "remote-exec" {
    script = "provisioning/create_cluster_role_binding.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "${data.template_file.setup_worker_auth.rendered}",
      "${data.template_file.bootstrap_kube_worker.rendered}",
    ]
  }

  provisioner "remote-exec" {
    script = "provisioning/approve_node_csr.sh"
  }

  provisioner "remote-exec" {
    script = "provisioning/deploy_dns_addon.sh"
  }
}

resource null_resource "set_local_kubect" {
  triggers = {
    kubernetes_servers = "${sakuracloud_server.kube_sacloud_server.id}"
  }

  provisioner "local-exec" {
    command = "${data.template_file.set_kubectl_remote.rendered}"
  }

  provisioner "local-exec" {
    when    = "destroy"
    command = "rm -f generated/sacloud.kubeconfig"
  }
}
