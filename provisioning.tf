# ubuntuユーザがsudo可能にする
resource "sakuracloud_note" "allow_sudo" {
  name    = "allow_sudo"
  content = "${file("provisioning/allow_sudo.sh")}"
}

# ワーカーの認証設定
data template_file "setup_worker_auth" {
  template = "${file("provisioning/setup_worker_auth.sh")}"

  vars {
    kubernetes_address = "${var.node_private_ip}"
    bootstrap_token    = "${random_id.bootstrap_token.hex}"
  }
}

# eth1へのIPアドレス設定
data template_file "set_eth1" {
  template = "${file("provisioning/set_eth1.sh")}"

  vars {
    ip = "${var.node_private_ip}"
  }
}

resource "sakuracloud_note" "set_eth1" {
  name    = "kube-sacloud-set-eth1"
  content = "${data.template_file.set_eth1.rendered}"
}

# etcdのセットアップ
data template_file "setup_etcd" {
  template = "${file("provisioning/setup_etcd.sh")}"

  vars {
    ip = "${var.node_private_ip}"
  }
}

# 各種コントローラのセットアップ
data template_file "bootstrap_kube_controller" {
  template = "${file("provisioning/bootstrap_kube_controllers.sh")}"

  vars {
    ip = "${var.node_private_ip}"
  }
}

# ワーカーのセットアップ
data template_file "bootstrap_kube_worker" {
  template = "${file("provisioning/bootstrap_kube_workers.sh")}"

  vars {
    ip = "${var.node_private_ip}"
  }
}

# 手元のマシンからkubectl接続を行うための設定ファイル生成
data template_file "set_kubectl_remote" {
  template = "${file("provisioning/set_kubectl_remote.sh")}"

  vars {
    fqdn = "${sakuracloud_gslb.kubernetes_gslb.FQDN}"
  }
}
