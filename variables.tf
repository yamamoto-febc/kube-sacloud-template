# 管理者パスワード
variable password {}

# サーバスペック
variable server_spec {
  type = "map"

  default = {
    core      = 2
    memory    = 4
    disk_size = 20
  }
}

# サーバ名
variable server_name {
  default = "kube-sacloud-server"
}

# ディスク名
variable disk_name {
  default = "kube-sacloud-disk"
}

# パケットフィルタ名
variable packet_filter_name {
  default = "kube-sacloud-filter"
}

# GSLB名
variable gslb_name {
  default = "kube-sacloud-gslb"
}

# SSH公開鍵名
variable ssh_key_name {
  default = "kube-sacloud-sshkey"
}

# 内部IPアドレス
variable node_private_ip {
  default = "10.240.0.10"
}
