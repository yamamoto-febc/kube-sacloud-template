# kube-sacloud-template

## 概要

[kubernetes](https://kubernetes.io)をさくらのクラウド上に最小構成で構築するための[Terraform](https://terraform.io)テンプレート

## 構成

### インストールされるプロダクトのバージョン

|   Product  | Version |
|------------|---------|
|`kubernetes`| 1.6.1   |
|`etcd`      | 3.1.4   |
|`docker`    | 1.12.6  |

構成の詳細は[kubernetes-the-hard-way](https://github.com/kelseyhightower/kubernetes-the-hard-way)を参照してください。

### さくらのクラウド上に作成されるリソース

|   リソース            | 説明     |
|----------------------|:---------|
|サーバ+ディスク         | スペックは設定ファイルにて調節可能     |
|GSLB                  | クライアント証明書で利用するFQDN発行用 |
|パケットフィルタ        | 必要最低限のポート+サーバへの応答パケットを許可、それ以外を拒否 |
|スタートアップスクリプト | プロビジョニング用 |

注: サーバへの応答を許可するためにパケットフィルタにて以下のパケットを許可しています。   

- ポート番号`32768`から`61000`のサーバ宛パケット(TCP/UDP)

kubernetesで外部からの接続をポート番号`32768`から`61000`以外で行う場合、適切なポートの解放が必要になる場合があります。  

## 利用方法

### 準備

- 1: [Terraform for さくらのクラウド](https://github.com/sacloud/terraform-provider-sakuracloud)の[セットアップ](https://sacloud.github.io/terraform-provider-sakuracloud/installation/)
- 2: このリポジトリをクローン:  

```console
git clone https://github.com/yamamoto-febc/kube-sacloud-template.git
cd kube-sacloud-template`
```

- 3: 設定ファイル編集

```console
$ vi terraform.tfvars

> password = "サーバの管理者パスワードを入力"
> 必要に応じて他の値も修正
```

- オプション1) [さくらのクラウド用CLI usacloud](https://github.com/sacloud/usacloud)のセットアップ

SSH接続やF/W操作が容易となるため`usacloud`のセットアップを推奨します。  

参考: [Usacloudスタートガイド](https://sacloud.github.io/usacloud/start_guide/)

- オプション2) Terraform v0.10以降を利用する場合のみ

terraform v0.10以降では、プラグインのダウンロードなどのためにあらかじめ`terraform init`の実行が必要です。

```console
terraform init
```

### 構築実施

```console
terraform apply
```

`apply`実施後、`generated`ディレクトリに以下のファイルが生成されています。

| ファイル名          | 説明 |
|--------------------|:--------------------|
| id_rsa             | 秘密鍵: サーバへのSSH接続用  |  
| id_rsa.pub         | 公開鍵: サーバへのSSH接続用  | 
| admin-key.pem      | 秘密鍵: APIサーバへの管理者接続用| 
| admin.pem          | 証明書: APIサーバへの管理者接続用| 
| ca-key.pem         | 秘密鍵: CA用| 
| ca.pem             | 証明書: CA用| 
| kube-proxy-key.pem | 秘密鍵: kube-proxy用| 
| kube-proxy.pem     | 証明書: kube-proxy用| 
| kubernetes-key.pem | 秘密鍵: etcd,kubelet,APIサーバ用| 
| kubernetes.pem     | 証明書: etcd,kubelet,APIサーバ用| 
| sacloud.kubeconfig | `kubectl`用の設定ファイル | 

## 各種操作

### kubectlの利用

`kubectl`を利用する場合、  

- 1: 手元のマシンに`kubectl`をインストールして利用
- 2: サーバにSSH接続して利用

の2つの方法があります。

#### 1: 手元のマシンに`kubectl`をインストールする場合

以下のコマンドで`kubectl`をインストールします。

**OS X**

```console
wget https://storage.googleapis.com/kubernetes-release/release/v1.6.1/bin/darwin/amd64/kubectl
chmod +x kubectl
sudo mv kubectl /usr/local/bin
```

**Linux**

```console1
wget https://storage.googleapis.com/kubernetes-release/release/v1.6.1/bin/linux/amd64/kubectl
chmod +x kubectl
sudo mv kubectl /usr/local/bin
```

インストール後は`generated/sacloud.kubeconfig`を指定して利用します。

```console
#毎回設定ファイルへのパスを指定する場合
kubectl --kubeconfig=generated/sacloud.kubeconfig [任意のコマンド]

#環境変数を利用して指定する場合
export KUBECONFIG=generated/sacloud.kubeconfig
kubectl [任意のコマンド]
```

#### 2: サーバにSSH接続して利用する場合

サーバへは秘密鍵`generated/id_rsa`を利用することでSSH接続可能です。

```console
#usacloudコマンドを利用する場合(サーバ名を指定)
usacloud server ssh -i generated_id_rsa kube-sacloud-server

#usacloudを用いない場合、コントロールパネルなどからサーバのIPアドレスを調べて以下コマンドを実施
ssh -i generated/id_rsa ubuntu@サーバのIPアドレス
```

SSH接続後は`kubectl`コマンドが利用可能な状態になっています。  

### dashboardの利用

手元のマシンで`kubectl`を利用する場合、以下のコマンドでdashboardが利用可能です。  

```console
# ダッシュボードの作成
kubectl create -f https://rawgit.com/kubernetes/dashboard/master/src/deploy/kubernetes-dashboard.yaml
# proxyの起動
kubectl proxy

# http://localhost:8001/ui へアクセス
```

Note: `kube-sacloud-template`を用いて構築した場合、dashboardへの直接アクセスにクライアント証明書での認証が要求されます。

直接アクセス: `https://[サーバのIP]:6443/ui`

必要であればgeneratedディレクトリ配下のファイルからクライアント証明書を作成し、ブラウザなどにインポートすることでdashboardへの直接アクセスが可能となります。

## 注意点

Serviceにおいて`type: LoadBalancer`は利用できません。  
必要に応じて[NGINX Ingress Controllers](https://github.com/nginxinc/kubernetes-ingress)などをご利用ください。  

## License

 `kube-sacloud-template` Copyright (C) 2017 Kazumichi Yamamoto.

  This project is published under [Apache 2.0 License](LICENSE.txt).
  
## Author

  * Kazumichi Yamamoto ([@yamamoto-febc](https://github.com/yamamoto-febc))