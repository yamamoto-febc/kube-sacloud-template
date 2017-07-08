/******************************************************************************
 * for ssh to nodes
 *****************************************************************************/
resource "tls_private_key" "ssh_private_key" {
  algorithm = "RSA"

  provisioner "local-exec" {
    command = "echo '${self.private_key_pem}' > generated/id_rsa; chmod 0600 generated/id_rsa"
  }

  provisioner "local-exec" {
    command = "echo '${self.public_key_openssh}' > generated/id_rsa.pub"
  }

  provisioner "local-exec" {
    when    = "destroy"
    command = "rm -f id_rsa; rm -f id_rsa.pub"
  }
}

/******************************************************************************
 * for CA
 *****************************************************************************/
resource "tls_private_key" "ca_private_key" {
  algorithm = "RSA"

  provisioner "local-exec" {
    command = "echo '${self.private_key_pem}' > generated/ca-key.pem"
  }

  provisioner "local-exec" {
    when    = "destroy"
    command = "rm -f ca-key.pem"
  }
}

resource "tls_self_signed_cert" "ca_cert" {
  key_algorithm   = "RSA"
  private_key_pem = "${tls_private_key.ca_private_key.private_key_pem}"

  subject {
    common_name         = "Kubernetes"
    country             = "JP"
    locality            = "OITA"
    organization        = "Kubernetes"
    organizational_unit = "CA"
    street_address      = ["Usa"]
  }

  validity_period_hours = 8760
  is_ca_certificate     = true

  allowed_uses = [
    "key_encipherment",
    "cert_signing",
    "clr_signing",
    "server_auth",
    "client_auth",
  ]

  provisioner "local-exec" {
    command = "echo '${self.cert_pem}' > generated/ca.pem"
  }

  provisioner "local-exec" {
    when    = "destroy"
    command = "rm -f ca.pem"
  }
}

/******************************************************************************
 * for kubernetes server
 *****************************************************************************/
resource "tls_private_key" "kube_server_private_key" {
  algorithm = "RSA"

  provisioner "local-exec" {
    command = "echo '${self.private_key_pem}' > generated/kubernetes-key.pem"
  }

  provisioner "local-exec" {
    when    = "destroy"
    command = "rm -f kubernetes-key.pem"
  }
}

resource "tls_cert_request" "kube_server_csr" {
  key_algorithm   = "RSA"
  private_key_pem = "${tls_private_key.kube_server_private_key.private_key_pem}"

  subject {
    common_name         = "Kubernetes"
    country             = "JP"
    locality            = "OITA"
    organization        = "kubernetes"
    organizational_unit = "Cluster"
    street_address      = ["Usa"]
  }

  ip_addresses = [
    "10.32.0.1",
    "${var.node_private_ip}",
    "127.0.0.1",
  ]

  dns_names = [
    "kubernetes.default",
    "${sakuracloud_gslb.kubernetes_gslb.FQDN}",
  ]
}

resource "tls_locally_signed_cert" "kube_server_cert" {
  cert_request_pem   = "${tls_cert_request.kube_server_csr.cert_request_pem}"
  ca_key_algorithm   = "RSA"
  ca_private_key_pem = "${tls_private_key.ca_private_key.private_key_pem}"
  ca_cert_pem        = "${tls_self_signed_cert.ca_cert.cert_pem}"

  validity_period_hours = 8760

  allowed_uses = [
    "key_encipherment",
    "cert_signing",
    "clr_signing",
    "server_auth",
    "client_auth",
  ]

  provisioner "local-exec" {
    command = "echo '${self.cert_pem}' > generated/kubernetes.pem"
  }

  provisioner "local-exec" {
    when    = "destroy"
    command = "rm -f kubernetes.pem"
  }
}

/******************************************************************************
 * for kube-proxy client
 *****************************************************************************/
resource "tls_private_key" "kube_proxy_private_key" {
  algorithm = "RSA"

  provisioner "local-exec" {
    command = "echo '${self.private_key_pem}' > generated/kube-proxy-key.pem"
  }

  provisioner "local-exec" {
    when    = "destroy"
    command = "rm -f kube-proxy-key.pem"
  }
}

resource "tls_cert_request" "kube_proxy_csr" {
  key_algorithm   = "RSA"
  private_key_pem = "${tls_private_key.kube_proxy_private_key.private_key_pem}"

  subject {
    common_name         = "system:kube-proxy"
    country             = "JP"
    locality            = "OITA"
    organization        = "system:kube-proxy"
    organizational_unit = "Cluster"
    street_address      = ["Usa"]
  }
}

resource "tls_locally_signed_cert" "kube_proxy_cert" {
  cert_request_pem   = "${tls_cert_request.kube_proxy_csr.cert_request_pem}"
  ca_key_algorithm   = "RSA"
  ca_private_key_pem = "${tls_private_key.ca_private_key.private_key_pem}"
  ca_cert_pem        = "${tls_self_signed_cert.ca_cert.cert_pem}"

  validity_period_hours = 8760

  allowed_uses = [
    "key_encipherment",
    "cert_signing",
    "clr_signing",
    "server_auth",
    "client_auth",
  ]

  provisioner "local-exec" {
    command = "echo '${self.cert_pem}' > generated/kube-proxy.pem"
  }

  provisioner "local-exec" {
    when    = "destroy"
    command = "rm -f kube-proxy.pem"
  }
}

/******************************************************************************
 * for Admin client
 *****************************************************************************/
resource "tls_private_key" "admin_private_key" {
  algorithm = "RSA"

  provisioner "local-exec" {
    command = "echo '${self.private_key_pem}' > generated/admin-key.pem"
  }

  provisioner "local-exec" {
    when    = "destroy"
    command = "rm -f admin-key.pem"
  }
}

resource "tls_cert_request" "admin_csr" {
  key_algorithm   = "RSA"
  private_key_pem = "${tls_private_key.admin_private_key.private_key_pem}"

  subject {
    common_name         = "Admin"
    country             = "JP"
    locality            = "OITA"
    organization        = "system:masters"
    organizational_unit = "Cluster"
    street_address      = ["Usa"]
  }
}

resource "tls_locally_signed_cert" "admin_cert" {
  cert_request_pem   = "${tls_cert_request.admin_csr.cert_request_pem}"
  ca_key_algorithm   = "RSA"
  ca_private_key_pem = "${tls_private_key.ca_private_key.private_key_pem}"
  ca_cert_pem        = "${tls_self_signed_cert.ca_cert.cert_pem}"

  validity_period_hours = 8760

  allowed_uses = [
    "key_encipherment",
    "cert_signing",
    "clr_signing",
    "server_auth",
    "client_auth",
  ]

  provisioner "local-exec" {
    command = "echo '${self.cert_pem}' > generated/admin.pem"
  }

  provisioner "local-exec" {
    when    = "destroy"
    command = "rm -f admin.pem"
  }
}
