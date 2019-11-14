---
title: 使用kubeadm快速安装kubernetes 1.15.5测试环境
preview: 300
comments: true
categories:
  - kubernetes
tags:
  - kubernetes
date: 2019-11-12 10:02:02
updated: 2019-11-12 10:02:02
abstract:
cover:
typora-root-url: ..
---

有的时候我们需要快速的安装kubernetes环境来方便我们测试，而不需要类似生产的高可用环境。

这里介绍快速安装kubernetes集群，单台master，2台worker。

## 环境介绍

本机所有机器都在AWS，使用默认的Amazon Linux 2 AMI镜像，采用 m4.xlarge（4C 16G）。

AWS 环境有两点需要注意：

{% note danger %}注意1：安全组需要添加一条允许当前安全组访问组内EC2的规则。{% endnote %}

{% note danger %}

注意2：需要关闭“源/目标检查“，路径：EC2设置--联网--源/目标检查：如下图，选择“是，请禁用”

![](/images/Quick-install-kubernetes-1-15-5-for-test/aws-disable-check.jpg)

{% endnote %}

| IP           | 主机名              | 角色     | Docker            | Kubernetes |
| ------------ | ------------------- | -------- | ----------------- | ---------- |
| 172.17.0.7   | k8s01.test.awsbj.cn | master01 | docker-ce-18.06.3 | 1.15.5     |
| 172.17.0.213 | k8s02.test.awsbj.cn | worker01 | docker-ce-18.06.3 | 1.15.5     |
| 172.17.0.230 | k8s03.test.awsbj.cn | worker02 | docker-ce-18.06.3 | 1.15.5     |



## 环境初始化

直接一条ansible即可：

``` bash
ansible-playbook playbooks/roles/site.yml -e server=test_k8s -e cloud=aws -e env=dev --private-key keys/aws/dev_keyPair2_awsbj_cn.pem -b --become-method=sudo
```

{% note info %}

这里的ansible脚本只是为了初始化安装kubernetes所需的**环境**，其不包含安装kubernetes集群功能。

{% endnote %}

ansible 所做的事情解释：

* common 基础系统配置：部分为非必须
   * yum 更新软件
   * 配置主机名称
   * 创建运维用账户
   * 配置limits
   * 创建标准目录
   * 配置sshd
   * 关闭SELINUX
   * 关闭防火墙
   * 配置sudo
   * 配置ldap
   * 安装jdk
   * 安装python3

* docker安装配置

    * 使用Aliyun镜像源安装docker： docker-ce-18.06.3

    * 配置Docker： 
      ```
      # /etc/docker/daemon.json
      {
        "log-level": "warn",
        "selinux-enabled": false,
        "max-concurrent-downloads": 100,
        "max-concurrent-uploads": 50,
        "live-restore": false,
        "default-shm-size": "128M",
        "registry-mirrors": ["https://nxxx5.mirror.aliyuncs.com","http://exxxd.m.daocloud.io"],
        "exec-opts": ["native.cgroupdriver=systemd"],
        "log-driver": "json-file",
        "log-opts": {
          "max-size": "20m",
          "max-file": "5"
        },
        "storage-driver": "overlay2",
        "storage-opts": [
          "overlay2.override_kernel_check=true"
        ]
      }
     
      # 允许FORWARD
      iptables -P FORWARD ACCEPT
     
      # 配置sysctl
      net.bridge.bridge-nf-call-ip6tables=1
      net.bridge.bridge-nf-call-iptables=1
      net.ipv4.ip_forward=1
      vm.swappiness=0
     
      # 增加运维账户到docker组中，能方便操作docker
      ```

    * 启动docker


* 安装配置kubernetes

    * 配置ipvs:
      ``` bash
      # /etc/sysconfig/modules/ipvs.modules

      #!/bin/bash
      ipvs_modules_dir="/usr/lib/modules/`uname -r`/kernel/net/netfilter/ipvs"
      for i in `ls $ipvs_modules_dir | sed  -r 's#(.*).ko.*#\1#'`; do
          /sbin/modinfo -F filename $i  &> /dev/null
          if [ $? -eq 0 ]; then
              /sbin/modprobe $i
          fi
      done

      # 使用Aliyun镜像源安装kubectl，kubeadm，kubelet指定版本

      # 配置好kubectl，kubeadm bash自动补全

      # 下载好kubernetes所需docker镜像
      ```

    * 下载kubernetes所需docker镜像脚本：docker-wrapper.py，参考：{% post_link  docker-io-gcr-io-k8s-gcr-io-quay-io-Chinese-source docker.io gcr.io k8s.gcr.io quay.io 中国区源 %}

      ``` python
      #!/usr/bin/python
      # coding=utf8
    
      import os
      import sys
    
      # azure mirrors for gcr.io,k8s.gcr.io,quay.io in china
      gcr_mirror = "gcr.azk8s.cn"
      docker_mirror = "dockerhub.azk8s.cn"
      quay_mirror = "quay.azk8s.cn"
      
      k8s_namespace = "google_containers"
      
      gcr_prefix = "gcr.io"
  special_gcr_prefix = "k8s.gcr.io"
      quay_prefix = "quay.io"
      
      
      def execute_sys_cmd(cmd):
          result = os.system(cmd)
      if result != 0:
              print(cmd + " failed.")
              sys.exit(-1)
      
      
      def usage():
          print("Usage: " + sys.argv[0] + " pull ")
      print("Examples:")
          print(sys.argv[0] + " pull k8s.gcr.io/kube-apiserver:v1.14.1")
          print(sys.argv[0] + " pull gcr.io/google_containers/kube-apiserver:v1.14.1")
          print(sys.argv[0] + " pull quay.io/kubernetes-ingress-controller/nginx-ingress-controller:0.26.1")
      
      
      if __name__ == "__main__":
          if len(sys.argv) != 3:
          usage()
              sys.exit(-1)
          elif sys.argv[1] != 'pull':
              usage()
          sys.exit(-1)
      
          # image name like k8s.gcr.io/kube-apiserver:v1.14.1 or gcr.io/google_containers/kube-apiserver:v1.14.1
          image = sys.argv[2]
          imageArray = image.split("/")
      
          if imageArray[0] == gcr_prefix:
              imageArray[0] = gcr_mirror
      elif imageArray[0] == special_gcr_prefix:
              imageArray[0] = gcr_mirror
          imageArray.insert(1, k8s_namespace)
          elif imageArray[0] == quay_prefix:
              imageArray[0] = quay_mirror
          elif len(imageArray) == 1:
              imageArray.insert(0, docker_mirror)
              imageArray.insert(1, "library")
          elif len(imageArray) == 2:
              imageArray.insert(0, docker_mirror)
      
          temp_image = "/".join(imageArray)
  
          cmd = "docker pull {image}".format(image=temp_image)
          print("------Execute_cmd: %s" % cmd)
          execute_sys_cmd(cmd)
  
          cmd = "docker tag {newImage} {image}".format(newImage=temp_image, image=image)
          print("------Execute_cmd: %s" % cmd)
          execute_sys_cmd(cmd)
  
          cmd = "docker rmi {newImage}".format(newImage=temp_image)
          print("------Execute_cmd: %s" % cmd)
          execute_sys_cmd(cmd)
      
          print("------Pull %s done" % image)
          sys.exit(0)
    ```
    
    * docker-wrapper.py 使用方式：
    
      ```bash
      docker-wrapper.py pull k8s.gcr.io/kube-apiserver:v1.15.5
      ```
    
      python脚本会自动从Azure中国镜像源下载对应的镜像，并重命名成所需的镜像。

## 初始化k8s master

准备kubeadm-init.yaml文件：

```yaml
apiVersion: kubeadm.k8s.io/v1beta2
kind: InitConfiguration
nodeRegistration:
  taints:
  - effect: NoSchedule
    key: node-role.kubernetes.io/master
---
apiVersion: kubeadm.k8s.io/v1beta2
kind: ClusterConfiguration
apiServer:
  timeoutForControlPlane: 4m0s
  extraArgs:
    runtime-config: "api/all=true"
    audit-log-path: /var/log/kubernetes/audit.log
certificatesDir: /etc/kubernetes/pki
clusterName: kubernetes
controllerManager:
  extraArgs:
    horizontal-pod-autoscaler-use-rest-clients: "true"
    horizontal-pod-autoscaler-sync-period: "10s"
    node-monitor-grace-period: "10s"
scheduler:
  extraArgs:
    address: 0.0.0.0
dns:
  type: CoreDNS
etcd:
  local:
    dataDir: /var/lib/etcd
imageRepository: k8s.gcr.io
kubernetesVersion: v1.15.5
networking:
  dnsDomain: cluster.local
  podSubnet: 10.101.0.0/16
  serviceSubnet: 10.100.0.0/16
---
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
bindAddress: 0.0.0.0
mode: "ipvs"
---
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
address: 0.0.0.0
cgroupDriver: systemd
clusterDNS:
- 10.100.0.10
maxPods: 110
staticPodPath: /etc/kubernetes/manifests
```

{% note danger %}

**注意：**

根据自己情况更改：podSubnet、serviceSubnet的网段。

{% endnote %}

如何查询默认的kubeadm init 的yaml呢？很简单，如下命令即可：

``` bash
kubeadm config print init-defaults --component-configs KubeProxyConfiguration,KubeletConfiguration
```

完整默认的init yaml如下：

```yaml
apiVersion: kubeadm.k8s.io/v1beta2
caCertPath: /etc/kubernetes/pki/ca.crt
discovery:
  bootstrapToken:
    apiServerEndpoint: kube-apiserver:6443
    token: abcdef.0123456789abcdef
    unsafeSkipCAVerification: true
  timeout: 5m0s
  tlsBootstrapToken: abcdef.0123456789abcdef
kind: JoinConfiguration
nodeRegistration:
  criSocket: /var/run/dockershim.sock
  name: k8s01.test.awsbj.cn
  taints: null
---
apiVersion: kubeproxy.config.k8s.io/v1alpha1
bindAddress: 0.0.0.0
clientConnection:
  acceptContentTypes: ""
  burst: 10
  contentType: application/vnd.kubernetes.protobuf
  kubeconfig: /var/lib/kube-proxy/kubeconfig.conf
  qps: 5
clusterCIDR: ""
configSyncPeriod: 15m0s
conntrack:
  maxPerCore: 32768
  min: 131072
  tcpCloseWaitTimeout: 1h0m0s
  tcpEstablishedTimeout: 24h0m0s
enableProfiling: false
healthzBindAddress: 0.0.0.0:10256
hostnameOverride: ""
iptables:
  masqueradeAll: false
  masqueradeBit: 14
  minSyncPeriod: 0s
  syncPeriod: 30s
ipvs:
  excludeCIDRs: null
  minSyncPeriod: 0s
  scheduler: ""
  strictARP: false
  syncPeriod: 30s
kind: KubeProxyConfiguration
metricsBindAddress: 127.0.0.1:10249
mode: ""
nodePortAddresses: null
oomScoreAdj: -999
portRange: ""
resourceContainer: /kube-proxy
udpIdleTimeout: 250ms
winkernel:
  enableDSR: false
  networkName: ""
  sourceVip: ""
---
address: 0.0.0.0
apiVersion: kubelet.config.k8s.io/v1beta1
authentication:
  anonymous:
    enabled: false
  webhook:
    cacheTTL: 2m0s
    enabled: true
  x509:
    clientCAFile: /etc/kubernetes/pki/ca.crt
authorization:
  mode: Webhook
  webhook:
    cacheAuthorizedTTL: 5m0s
    cacheUnauthorizedTTL: 30s
cgroupDriver: cgroupfs
cgroupsPerQOS: true
clusterDNS:
- 10.96.0.10
clusterDomain: cluster.local
configMapAndSecretChangeDetectionStrategy: Watch
containerLogMaxFiles: 5
containerLogMaxSize: 10Mi
contentType: application/vnd.kubernetes.protobuf
cpuCFSQuota: true
cpuCFSQuotaPeriod: 100ms
cpuManagerPolicy: none
cpuManagerReconcilePeriod: 10s
enableControllerAttachDetach: true
enableDebuggingHandlers: true
enforceNodeAllocatable:
- pods
eventBurst: 10
eventRecordQPS: 5
evictionHard:
  imagefs.available: 15%
  memory.available: 100Mi
  nodefs.available: 10%
  nodefs.inodesFree: 5%
evictionPressureTransitionPeriod: 5m0s
failSwapOn: true
fileCheckFrequency: 20s
hairpinMode: promiscuous-bridge
healthzBindAddress: 127.0.0.1
healthzPort: 10248
httpCheckFrequency: 20s
imageGCHighThresholdPercent: 85
imageGCLowThresholdPercent: 80
imageMinimumGCAge: 2m0s
iptablesDropBit: 15
iptablesMasqueradeBit: 14
kind: KubeletConfiguration
kubeAPIBurst: 10
kubeAPIQPS: 5
makeIPTablesUtilChains: true
maxOpenFiles: 1000000
maxPods: 110
nodeLeaseDurationSeconds: 40
nodeStatusReportFrequency: 1m0s
nodeStatusUpdateFrequency: 10s
oomScoreAdj: -999
podPidsLimit: -1
port: 10250
registryBurst: 10
registryPullQPS: 5
resolvConf: /etc/resolv.conf
rotateCertificates: true
runtimeRequestTimeout: 2m0s
serializeImagePulls: true
staticPodPath: /etc/kubernetes/manifests
streamingConnectionIdleTimeout: 4h0m0s
syncFrequency: 1m0s
volumeStatsAggPeriod: 1m0s
```

登陆k8s master，初始化kubernetes：

```bash
kubeadm init --config=kubeadm-init.yaml
```

初始化如下输出，代表成功：

```
[init] Using Kubernetes version: v1.15.5
[preflight] Running pre-flight checks
[preflight] Pulling images required for setting up a Kubernetes cluster
[preflight] This might take a minute or two, depending on the speed of your internet connection
[preflight] You can also perform this action in beforehand using 'kubeadm config images pull'
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Activating the kubelet service
[certs] Using certificateDir folder "/etc/kubernetes/pki"
[certs] Generating "front-proxy-ca" certificate and key
[certs] Generating "front-proxy-client" certificate and key
[certs] Generating "etcd/ca" certificate and key
[certs] Generating "etcd/server" certificate and key
[certs] etcd/server serving cert is signed for DNS names [k8s01.test.awsbj.cn localhost] and IPs [172.17.0.7 127.0.0.1 ::1]
[certs] Generating "etcd/peer" certificate and key
[certs] etcd/peer serving cert is signed for DNS names [k8s01.test.awsbj.cn localhost] and IPs [172.17.0.7 127.0.0.1 ::1]
[certs] Generating "etcd/healthcheck-client" certificate and key
[certs] Generating "apiserver-etcd-client" certificate and key
[certs] Generating "ca" certificate and key
[certs] Generating "apiserver" certificate and key
[certs] apiserver serving cert is signed for DNS names [k8s01.test.awsbj.cn kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local] and IPs [10.100.0.1 172.17.0.7]
[certs] Generating "apiserver-kubelet-client" certificate and key
[certs] Generating "sa" key and public key
[kubeconfig] Using kubeconfig folder "/etc/kubernetes"
[kubeconfig] Writing "admin.conf" kubeconfig file
[kubeconfig] Writing "kubelet.conf" kubeconfig file
[kubeconfig] Writing "controller-manager.conf" kubeconfig file
[kubeconfig] Writing "scheduler.conf" kubeconfig file
[control-plane] Using manifest folder "/etc/kubernetes/manifests"
[control-plane] Creating static Pod manifest for "kube-apiserver"
[control-plane] Creating static Pod manifest for "kube-controller-manager"
[control-plane] Creating static Pod manifest for "kube-scheduler"
[etcd] Creating static Pod manifest for local etcd in "/etc/kubernetes/manifests"
[wait-control-plane] Waiting for the kubelet to boot up the control plane as static Pods from directory "/etc/kubernetes/manifests". This can take up to 4m0s
[apiclient] All control plane components are healthy after 13.002203 seconds
[upload-config] Storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace
[kubelet] Creating a ConfigMap "kubelet-config-1.15" in namespace kube-system with the configuration for the kubelets in the cluster
[upload-certs] Skipping phase. Please see --upload-certs
[mark-control-plane] Marking the node k8s01.test.awsbj.cn as control-plane by adding the label "node-role.kubernetes.io/master=''"
[mark-control-plane] Marking the node k8s01.test.awsbj.cn as control-plane by adding the taints [node-role.kubernetes.io/master:NoSchedule]
[bootstrap-token] Using token: 4m9zlz.0l3waicmvgl6envz
[bootstrap-token] Configuring bootstrap tokens, cluster-info ConfigMap, RBAC Roles
[bootstrap-token] configured RBAC rules to allow Node Bootstrap tokens to post CSRs in order for nodes to get long term certificate credentials
[bootstrap-token] configured RBAC rules to allow the csrapprover controller automatically approve CSRs from a Node Bootstrap Token
[bootstrap-token] configured RBAC rules to allow certificate rotation for all node client certificates in the cluster
[bootstrap-token] Creating the "cluster-info" ConfigMap in the "kube-public" namespace
[addons] Applied essential addon: CoreDNS
[addons] Applied essential addon: kube-proxy

Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 172.17.0.7:6443 --token 4m9zlz.0l3waicmvgl6envz \
    --discovery-token-ca-cert-hash sha256:3ff0b4136b1af325e603f1f3d6d2554c7c3d04f78dc6d134696da3594ad63e0e
```

如果初始化失败，需要清理，如下：

``` bash
kubeadm reset
iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X
ipvsadm --clear
```

拷贝admin.conf

```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```



## 初始化k8s worker节点

在所有其他的worker节点上都执行如下命令：从初始化master节点中输出的

``` bash
kubeadm join 172.17.0.7:6443 --token 4m9zlz.0l3waicmvgl6envz \
    --discovery-token-ca-cert-hash sha256:3ff0b4136b1af325e603f1f3d6d2554c7c3d04f78dc6d134696da3594ad63e0e
```

完整输出如下：

```
[preflight] Running pre-flight checks
[preflight] Reading configuration from the cluster...
[preflight] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -oyaml'
[kubelet-start] Downloading configuration for the kubelet from the "kubelet-config-1.15" ConfigMap in the kube-system namespace
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Activating the kubelet service
[kubelet-start] Waiting for the kubelet to perform the TLS Bootstrap...

This node has joined the cluster:
* Certificate signing request was sent to apiserver and a response was received.
* The Kubelet was informed of the new secure connection details.

Run 'kubectl get nodes' on the control-plane to see this node join the cluster.
```



## 检查Kubernetes集群

登陆master节点，查看nodes

```bash
[root@k8s01.test.awsbj.cn kubernetes]# kubectl get node
NAME                  STATUS     ROLES    AGE     VERSION
k8s01.test.awsbj.cn   NotReady   master   6m30s   v1.15.5
k8s02.test.awsbj.cn   NotReady   <none>   117s    v1.15.5
k8s03.test.awsbj.cn   NotReady   <none>   43s     v1.15.5

[root@k8s01.test.awsbj.cn microoak]# kubectl cluster-info 
Kubernetes master is running at https://172.17.0.7:6443
KubeDNS is running at https://172.17.0.7:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
```

都是NotReady状态，因为还没有安装网络插件呢。



## 安装网络插件：calico

这里使用calico 3.6版本，[参考](https://docs.projectcalico.org/v3.6/getting-started/kubernetes/installation/calico)

下载yaml文件：

``` bash
curl \
https://docs.projectcalico.org/v3.6/getting-started/kubernetes/installation/hosted/kubernetes-datastore/calico-networking/1.7/calico.yaml \
-O
```

更改podSubnet：

搜索：CALICO_IPV4POOL_CIDR，将其value更改成：10.101.0.0/16

应用calico.yaml:

``` bash
kubectl apply -f calico.yaml
```

稍等片刻再次查看nodes状态：

```bash
[microoak@k8s01.test.awsbj.cn kubernetes]$ kubectl get nodes 
NAME                  STATUS   ROLES    AGE     VERSION
k8s01.test.awsbj.cn   Ready    master   4h29m   v1.15.5
k8s02.test.awsbj.cn   Ready    <none>   4h25m   v1.15.5
k8s03.test.awsbj.cn   Ready    <none>   4h23m   v1.15.5
```

至此kubernetes已经快速安装完成。