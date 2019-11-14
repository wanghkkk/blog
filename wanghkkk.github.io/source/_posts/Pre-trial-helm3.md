---
title: 抢先试用Helm3，并安装nginx-ingress-controller
preview: 300
comments: true
categories:
  - kubernetes
  - helm
tags:
  - helm
date: 2019-11-14 14:16:28
updated: 2019-11-14 14:16:28
abstract:
cover:
typora-root-url: ..
---

Helm3 今天stable了，所以今天先抢先试用一下Helm3。

![Helm](/images/logos/helm-logo-small.jpg)

官网：

 https://helm.sh/ 

GitHub：

 https://github.com/helm/helm 

Docs：

 https://helm.sh/docs 

[toc]



相对于Helm2，Helm3的改进如下：

* 移除了Tiller组件，Helm的权限通过 [kubeconfig文件](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/) 来确定；
* 改进了upgrade升级策略；
* Helm2 中release的默认被安装到了Tiller所在的namespace，在Helm3中默认是Context中指定的名称空间；
* Helm2 将数据信息存储在了Configmap上，Helm3中存储在了Secret上；
* 如果指定安装到新的namespace上，Helm3默认自动创建这个不存在的namespace；
* local or stable repositories默认已经被移除；
* 迁移Helm2 --> Helm3，请参考：[官方]( https://github.com/helm/helm-2to3 )，[Blog]( https://helm.sh/blog/migrate-from-helm-v2-to-helm-v3/ )，[GitHub]( https://github.com/helm/helm-2to3 )
* 其他详尽的变化请参考[官方]( https://helm.sh/docs/faq/#changes-since-helm-2 )；

## 前提依赖

快速搭建一套测试的Kubernetes环境，请参考：

{% post_link Quick-install-kubernetes-1-15-5-for-test  使用kubeadm快速安装kubernetes 1.15.5测试环境 %}



## 安装Helm3

首先从GitHub Release下载最新版的Helm3：

``` bash
# 下载
$ wget -c "https://get.helm.sh/helm-v3.0.0-linux-amd64.tar.gz"

# 安装很简单，只需要将helm移动到 $PATH 即可
$ tar xf helm-v3.0.0-linux-amd64.tar.gz
$ sudo mv linux-amd64/helm /usr/local/bin/
```

安装完成，测试一下：

``` bash
$ helm version
version.BuildInfo{Version:"v3.0.0", GitCommit:"e29ce2a54e96cd02ccfce88bee4f58bb6e2a28b6", GitTreeState:"clean", GoVersion:"go1.13.4"}

# 查看一下帮助：
$ helm --help
The Kubernetes package manager

Common actions for Helm:

- helm search:    search for charts
- helm pull:      download a chart to your local directory to view
- helm install:   upload the chart to Kubernetes
- helm list:      list releases of charts

Environment variables: # 这里列出了有用的环境变量

+------------------+-----------------------------------------------------------------------------+
| Name             | Description                                                                 |
+------------------+-----------------------------------------------------------------------------+
| $XDG_CACHE_HOME  | set an alternative location for storing cached files.                       |
| $XDG_CONFIG_HOME | set an alternative location for storing Helm configuration.                 |
| $XDG_DATA_HOME   | set an alternative location for storing Helm data.                          |
| $HELM_DRIVER     | set the backend storage driver. Values are: configmap, secret, memory       |
| $HELM_NO_PLUGINS | disable plugins. Set HELM_NO_PLUGINS=1 to disable plugins.                  |
| $KUBECONFIG      | set an alternative Kubernetes configuration file (default "~/.kube/config") |
+------------------+-----------------------------------------------------------------------------+

Helm stores configuration based on the XDG base directory specification, so

- cached files are stored in $XDG_CACHE_HOME/helm
- configuration is stored in $XDG_CONFIG_HOME/helm
- data is stored in $XDG_DATA_HOME/helm

# 这里列出了有用的存储目录
By default, the default directories depend on the Operating System. The defaults are listed below:

+------------------+---------------------------+--------------------------------+-------------------------+
| Operating System | Cache Path                | Configuration Path             | Data Path               |
+------------------+---------------------------+--------------------------------+-------------------------+
| Linux            | $HOME/.cache/helm         | $HOME/.config/helm             | $HOME/.local/share/helm |
| macOS            | $HOME/Library/Caches/helm | $HOME/Library/Preferences/helm | $HOME/Library/helm      |
| Windows          | %TEMP%\helm               | %APPDATA%\helm                 | %APPDATA%\helm          |
+------------------+---------------------------+--------------------------------+-------------------------+

Usage:
  helm [command]

Available Commands:
  completion  Generate autocompletions script for the specified shell (bash or zsh) # 命令自动补全
  create      create a new chart with the given name # 创建chart
  dependency  manage a chart's dependencies # 管理chart依赖
  env         Helm client environment information # 列出helm 环境
  get         download extended information of a named release # 获取release的额外信息
  help        Help about any command
  history     fetch release history # 获取历史release
  install     install a chart # 安装chart
  lint        examines a chart for possible issues # 检查chart是否有问题
  list        list releases # 列出release
  package     package a chart directory into a chart archive # 打包一个chart目录
  plugin      install, list, or uninstall Helm plugins # helm plugin 插件子命令
  pull        download a chart from a repository and (optionally) unpack it in local directory # 从chart仓库下载chart，并解压到当前目录
  repo        add, list, remove, update, and index chart repositories # helm repo 子命令
  rollback    roll back a release to a previous revision # 回滚一个release
  search      search for a keyword in charts # 搜索chart
  show        show information of a chart # 查看chart的信息
  status      displays the status of the named release # 查看release的状态
  template    locally render templates  # helm 模板
  test        run tests for a release # 测试一个release
  uninstall   uninstall a release # 卸载release
  upgrade     upgrade a release # 升级release
  verify      verify that a chart at the given path has been signed and is valid # 验证chart
  version     print the client version information

Flags:
      --add-dir-header                   If true, adds the file directory to the header
      --alsologtostderr                  log to standard error as well as files
      --debug                            enable verbose output
  -h, --help                             help for helm
      --kube-context string              name of the kubeconfig context to use
      --kubeconfig string                path to the kubeconfig file
      --log-backtrace-at traceLocation   when logging hits line file:N, emit a stack trace (default :0)
      --log-dir string                   If non-empty, write log files in this directory
      --log-file string                  If non-empty, use this log file
      --log-file-max-size uint           Defines the maximum size a log file can grow to. Unit is megabytes. If the value is 0, the maximum file size is unlimited. (default 1800)
      --logtostderr                      log to standard error instead of files (default true)
  -n, --namespace string                 namespace scope for this request
      --registry-config string           path to the registry config file (default "/home/microoak/.config/helm/registry.json")
      --repository-cache string          path to the file containing cached repository indexes (default "/home/microoak/.cache/helm/repository")
      --repository-config string         path to the file containing repository names and URLs (default "/home/microoak/.config/helm/repositories.yaml")
      --skip-headers                     If true, avoid header prefixes in the log messages
      --skip-log-headers                 If true, avoid headers when opening log files
      --stderrthreshold severity         logs at or above this threshold go to stderr (default 2)
  -v, --v Level                          number for the log level verbosity
      --vmodule moduleSpec               comma-separated list of pattern=N settings for file-filtered logging

Use "helm [command] --help" for more information about a command.
```

{% note info %}

什么是chart，什么是release，什么是repository呢？

chart，类似于一个yaml文件，当然他是多个yaml的集合，还没有被安装到kubernetes集群中的包。可以认为它是一个服务的安装包。

release，就是已经被安装到kubernetes集群中的了，可以认为它是一个服务吧。

repository，就是一个专门存放chart的仓库，类似于yum源，apt源等

{% endnote %}

{% note info %}

来自官方的解释：三个组件，[参考](https://helm.sh/docs/intro/using_helm/#three-big-concepts)

A *Chart* is a Helm package. It contains all of the resource definitions necessary to run an application, tool, or service inside of a Kubernetes cluster. Think of it like the Kubernetes equivalent of a Homebrew formula, an Apt dpkg, or a Yum RPM file.

A *Repository* is the place where charts can be collected and shared. It’s like Perl’s [CPAN archive](https://www.cpan.org/) or the [Fedora Package Database](https://admin.fedoraproject.org/pkgdb/), but for Kubernetes packages.

A *Release* is an instance of a chart running in a Kubernetes cluster. One chart can often be installed many times into the same cluster. And each time it is installed, a new *release* is created. Consider a MySQL chart. If you want two databases running in your cluster, you can install that chart twice. Each one will have its own *release*, which will in turn have its own *release name*.

With these concepts in mind, we can now explain Helm like this:

Helm installs *charts* into Kubernetes, creating a new *release* for each installation. And to find new charts, you can search Helm chart *repositories*.

Helm 专业术语：请[参考]( https://helm.sh/docs/glossary/ )

{% endnote %}



使用Helm，参考[Using Helm](https://helm.sh/docs/intro/using_helm/)

### 配置helm的自动补全

``` bash
# 这里只是给当前用户配置的，如果要给所有用户配置，则插入到/etc/profile即可。
$ cat >> ~/.bashrc <<EOF
source <(helm completion bash)
EOF

# 应用
$ source ~/.bashrc

# 测试
$ helm <tab键>
completion  dependency  get         install     list        plugin      repo        search      status      test        upgrade     version
create      env         history     lint        package     pull        rollback    show        template    uninstall   verify

# 如果报错，需要安装：bash-completion
$ sudo yum install bash-completion -y
```



### 查看默认helm的环境变量

``` bash
$ helm env
HELM_DEBUG="false" # 是否开启debug
HELM_PLUGINS="/home/user/.local/share/helm/plugins" # 插件目录
HELM_REGISTRY_CONFIG="/home/user/.config/helm/registry.json" # registry仓库配置文件
HELM_REPOSITORY_CACHE="/home/user/.cache/helm/repository" # repo仓库缓存目录
HELM_REPOSITORY_CONFIG="/home/user/.config/helm/repositories.yaml" # repo配置文件
HELM_NAMESPACE="default" # 默认使用的kubernetes命名空间是default
HELM_KUBECONTEXT="" # 默认使用的kubernetes context，~/.kube/config 中配置的
HELM_BIN="helm"
```



### 查看配置helm repo

首先查看一下repo子命令帮助：

``` bash
$ helm repo

This command consists of multiple subcommands to interact with chart repositories.

It can be used to add, remove, list, and index chart repositories.

Usage:
  helm repo [command]

Available Commands:
  add         add a chart repository
  index       generate an index file given a directory containing packaged charts
  list        list chart repositories
  remove      remove a chart repository
  update      update information of available charts locally from chart repositories
```

查看默认的repo：helm2 初始化完是有一个默认的stable的存放在google的repo的，helm3则完全需要自己配置repo。

```bash
$ helm repo list
Error: no repositories to show
```

安装一个Helm repo：参考：[QuickStart]( https://helm.sh/docs/intro/quickstart/ )

``` bash
# 官方的repo，存放在google，需要FQ
$ helm repo add stable https://kubernetes-charts.storage.googleapis.com/

# 这里使用Azure中国区镜像源
$ helm repo add stable http://mirror.azure.cn/kubernetes/charts

# 查看一下repo的配置文件吧，还记得在哪里吧？helm env查看一下就知道了：
$ cat .config/helm/repositories.yaml
apiVersion: ""
generated: "0001-01-01T00:00:00Z"
repositories:
- caFile: ""
  certFile: ""
  keyFile: ""
  name: stable
  password: ""
  url: http://mirror.azure.cn/kubernetes/charts
  username: ""
```

类似于ubuntu的apt源，用之前需要update一下：

```bash
$ helm repo list
NAME  	URL                                     
stable	http://mirror.azure.cn/kubernetes/charts

$ helm repo update 
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "stable" chart repository
Update Complete. ⎈ Happy Helming!⎈
```

现在OK了，之前快速安装Kubernetes 1.15了：{% post_link Quick-install-kubernetes-1-15-5-for-test  使用kubeadm快速安装kubernetes 1.15.5测试环境 %}

接着安装一个nginx ingress吧，方便后续使用。



## 使用Helm3 安装nginx-ingress

因为nginx-ingress有很多的参数需要定义，先下载chart，修改后再安装：

``` bash
# 先查找一下，看一下search子命令帮助：
$ helm search --help

Search provides the ability to search for Helm charts in the various places
they can be stored including the Helm Hub and repositories you have added. Use
search subcommands to search different locations for charts.

Usage:
  helm search [command]

Available Commands:
  hub         search for charts in the Helm Hub or an instance of Monocular # 这里多了个Helm Hub
  repo        search repositories for a keyword in charts # 这是以前的概念
  
# 查找nginx-ingress
$ helm search repo nginx-ingress
NAME                	CHART VERSION	APP VERSION	DESCRIPTION                                       
stable/nginx-ingress	1.24.7       	0.26.1     	An nginx Ingress controller that uses ConfigMap...
stable/nginx-lego   	0.3.1        	           	Chart for nginx-ingress-controller and kube-lego

# 下载stable/nginx-ingress
$ helm pull stable/nginx-ingress
$ ll
nginx-ingress-1.24.7.tgz
$ tar xf nginx-ingress-1.24.7.tgz
```

{% note info %}

Helm Hub 是Helm官方的repo，地址是： https://hub.helm.sh/ 。

Repo 可以是用户自己搭建的repo。

{% endnote %}

配置nginx-ingress chart：

首先备份一下values.yaml，免得改的太多，改错了。

``` bash
$ cd nginx-ingress/
$ cp values.yaml{,.ori}
```

更改values.yaml文件如下：

``` yaml
# ngxin ingress controller 配置：
controller:
  image:
    repository: quay.azk8s.cn/kubernetes-ingress-controller/nginx-ingress-controller
  hostNetwork: true
  daemonset:
    useHostPort: true
  kind: DaemonSet
  minReadySeconds: 5
  updateStrategy: 
    rollingUpdate:
      maxUnavailable: 1
    type: RollingUpdate
  tolerations:
    - operator: "Exists"
  nodeSelector:
    canruningress: run
  resources: 
    limits:
      cpu: 100m
      memory: 256Mi
    requests:
      cpu: 100m
      memory: 128Mi
  service:
    type: ClusterIP
  metrics:
    enabled: true

# 默认后端配置
defaultBackend:
  image:
    repository: gcr.azk8s.cn/google-containers/defaultbackend-amd64
  resources: 
   limits:
     cpu: 10m
     memory: 20Mi
   requests:
     cpu: 10m
     memory: 20Mi
```

{% note sucess %}

配置说明：

1. 使用azure中国区源代替默认的quay，gcr.azk8s.cn中国区无法拉取的源，参考：{% post_link  docker-io-gcr-io-k8s-gcr-io-quay-io-Chinese-source docker.io gcr.io k8s.gcr.io quay.io 中国区源 %}

2. 我这里使用了daemonset方式只在master主机上安装，并且使用了hostNetwork。

{% note danger %}

生产上建议单独加入多台cpu核数多的主机当worker节点，并设置上污点；

nginx-ingress 使用主机网络，以daemonset的方式跑在这几个worker节点中，然后上层在使用LB，给这几个nginx-ingress创建单独高可用的入口。

{% endnote %}

3. 建议将所有的pod都设置上允许的资源量，以免将来pod资源请求不受控制，同时建议配置上prometheus+grafana方便观察pod占用量大小，根据这些数据再修改分配的资源，已达到运行pod所需资源量，但又不浪费的临界点。

{% endnote %}

上面的配置：设定了nodeSelector，我这里就在master节点打上对应的标签，让nginx-ingress跑在master节点上。

``` bash
$ kubectl get node
NAME                  STATUS   ROLES    AGE   VERSION
k8s01.test.awsbj.cn   Ready    master   26h   v1.15.5
k8s02.test.awsbj.cn   Ready    <none>   26h   v1.15.5
k8s03.test.awsbj.cn   Ready    <none>   26h   v1.15.5

$ kubectl label nodes k8s01.test.awsbj.cn canruningress=run
node/k8s01.test.awsbj.cn labeled

$ kubectl get node --show-labels 
NAME                  STATUS   ROLES    AGE   VERSION   LABELS
k8s01.test.awsbj.cn   Ready    master   26h   v1.15.5   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,canruningress=run,kubernetes.io/arch=amd64,kubernetes.io/hostname=k8s01.test.awsbj.cn,kubernetes.io/os=linux,node-role.kubernetes.io/master=
k8s02.test.awsbj.cn   Ready    <none>   26h   v1.15.5   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=k8s02.test.awsbj.cn,kubernetes.io/os=linux
k8s03.test.awsbj.cn   Ready    <none>   26h   v1.15.5   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=k8s03.test.awsbj.cn,kubernetes.io/os=linux
```

安装nginx-ingress：

还一样，先查看对应命名的帮助：

```bash
$ helm install --help

This command installs a chart archive.

The install argument must be a chart reference, a path to a packaged chart,
a path to an unpacked chart directory or a URL.

To override values in a chart, use either the '--values' flag and pass in a file
or use the '--set' flag and pass configuration from the command line, to force
a string value use '--set-string'. In case a value is large and therefore
you want not to use neither '--values' nor '--set', use '--set-file' to read the
single large value from file.

    $ helm install -f myvalues.yaml myredis ./redis

or

    $ helm install --set name=prod myredis ./redis

or

    $ helm install --set-string long_int=1234567890 myredis ./redis

or
    $ helm install --set-file my_script=dothings.sh myredis ./redis

You can specify the '--values'/'-f' flag multiple times. The priority will be given to the
last (right-most) file specified. For example, if both myvalues.yaml and override.yaml
contained a key called 'Test', the value set in override.yaml would take precedence:

    $ helm install -f myvalues.yaml -f override.yaml  myredis ./redis

You can specify the '--set' flag multiple times. The priority will be given to the
last (right-most) set specified. For example, if both 'bar' and 'newbar' values are
set for a key called 'foo', the 'newbar' value would take precedence:

    $ helm install --set foo=bar --set foo=newbar  myredis ./redis


To check the generated manifests of a release without installing the chart,
the '--debug' and '--dry-run' flags can be combined.

If --verify is set, the chart MUST have a provenance file, and the provenance
file MUST pass all verification steps.

There are five different ways you can express the chart you want to install:

1. By chart reference: helm install mymaria example/mariadb
2. By path to a packaged chart: helm install mynginx ./nginx-1.2.3.tgz
3. By path to an unpacked chart directory: helm install mynginx ./nginx
4. By absolute URL: helm install mynginx https://example.com/charts/nginx-1.2.3.tgz
5. By chart reference and repo url: helm install --repo https://example.com/charts/ mynginx nginx

CHART REFERENCES

A chart reference is a convenient way of referencing a chart in a chart repository.

When you use a chart reference with a repo prefix ('example/mariadb'), Helm will look in the local
configuration for a chart repository named 'example', and will then look for a
chart in that repository whose name is 'mariadb'. It will install the latest stable version of that chart
until you specify '--devel' flag to also include development version (alpha, beta, and release candidate releases), or
supply a version number with the '--version' flag.

To see the list of chart repositories, use 'helm repo list'. To search for
charts in a repository, use 'helm search'.

Usage: # 命令格式
  helm install [NAME] [CHART] [flags]

Flags:
      --atomic                   if set, installation process purges chart on fail. The --wait flag will be set automatically if --atomic is used
      --ca-file string           verify certificates of HTTPS-enabled servers using this CA bundle
      --cert-file string         identify HTTPS client using this SSL certificate file
      --dependency-update        run helm dependency update before installing the chart
      --devel                    use development versions, too. Equivalent to version '>0.0.0-0'. If --version is set, this is ignored
      --dry-run                  simulate an install
  -g, --generate-name            generate the name (and omit the NAME parameter)
  -h, --help                     help for install
      --key-file string          identify HTTPS client using this SSL key file
      --keyring string           location of public keys used for verification (default "/home/microoak/.gnupg/pubring.gpg")
      --name-template string     specify template used to name the release
      --no-hooks                 prevent hooks from running during install
  -o, --output format            prints the output in the specified format. Allowed values: table, json, yaml (default table)
      --password string          chart repository password where to locate the requested chart
      --render-subchart-notes    if set, render subchart notes along with the parent
      --replace                  re-use the given name, even if that name is already used. This is unsafe in production
      --repo string              chart repository url where to locate the requested chart
      --set stringArray          set values on the command line (can specify multiple or separate values with commas: key1=val1,key2=val2)
      --set-file stringArray     set values from respective files specified via the command line (can specify multiple or separate values with commas: key1=path1,key2=path2)
      --set-string stringArray   set STRING values on the command line (can specify multiple or separate values with commas: key1=val1,key2=val2)
      --skip-crds                if set, no CRDs will be installed. By default, CRDs are installed if not already present
      --timeout duration         time to wait for any individual Kubernetes operation (like Jobs for hooks) (default 5m0s)
      --username string          chart repository username where to locate the requested chart
  -f, --values strings           specify values in a YAML file or a URL(can specify multiple)
      --verify                   verify the package before installing it
      --version string           specify the exact chart version to install. If this is not specified, the latest version is installed
      --wait                     if set, will wait until all Pods, PVCs, Services, and minimum number of Pods of a Deployment, StatefulSet, or ReplicaSet are in a ready state before marking the release as successful. It will wait for as long as --timeout

Global Flags:
      --add-dir-header                   If true, adds the file directory to the header
      --alsologtostderr                  log to standard error as well as files
      --debug                            enable verbose output
      --kube-context string              name of the kubeconfig context to use
      --kubeconfig string                path to the kubeconfig file
      --log-backtrace-at traceLocation   when logging hits line file:N, emit a stack trace (default :0)
      --log-dir string                   If non-empty, write log files in this directory
      --log-file string                  If non-empty, use this log file
      --log-file-max-size uint           Defines the maximum size a log file can grow to. Unit is megabytes. If the value is 0, the maximum file size is unlimited. (default 1800)
      --logtostderr                      log to standard error instead of files (default true)
  -n, --namespace string                 namespace scope for this request
      --registry-config string           path to the registry config file (default "/home/microoak/.config/helm/registry.json")
      --repository-cache string          path to the file containing cached repository indexes (default "/home/microoak/.cache/helm/repository")
      --repository-config string         path to the file containing repository names and URLs (default "/home/microoak/.config/helm/repositories.yaml")
      --skip-headers                     If true, avoid header prefixes in the log messages
      --skip-log-headers                 If true, avoid headers when opening log files
      --stderrthreshold severity         logs at or above this threshold go to stderr (default 2)
  -v, --v Level                          number for the log level verbosity
      --vmodule moduleSpec               comma-separated list of pattern=N settings for file-filtered logging
```

--dry-run看看再：我们看到helm根据chart模板自动帮我们生成了对应的kubernetes yaml文件。

``` yaml
# 这里估计是一个小Bug：我这里指定了namespace为kube-system，但是看到的yaml中没有namespace这项，如下：

$ helm install nginx-ingress --namespace=kube-system ./ --dry-run --debug
install.go:148: [debug] Original chart version: ""
install.go:165: [debug] CHART PATH: /home/microoak/nginx-ingress

NAME: nginx-ingress
LAST DEPLOYED: Wed Nov 13 15:54:30 2019
NAMESPACE: default
STATUS: pending-install
REVISION: 1
TEST SUITE: None
USER-SUPPLIED VALUES:
{}

COMPUTED VALUES:
controller:
  addHeaders: {}
  admissionWebhooks:
    enabled: false
    failurePolicy: Fail
    patch:
      enabled: true
      image:
        pullPolicy: IfNotPresent
        repository: jettech/kube-webhook-certgen
        tag: v1.0.0
      nodeSelector: {}
      podAnnotations: {}
      priorityClassName: ""
    port: 8443
    service:
      annotations: {}
      clusterIP: ""
      externalIPs: []
      loadBalancerIP: ""
      loadBalancerSourceRanges: []
      omitClusterIP: false
      servicePort: 443
      type: ClusterIP
  affinity: {}
  autoscaling:
    enabled: false
    maxReplicas: 11
    minReplicas: 1
    targetCPUUtilizationPercentage: 50
    targetMemoryUtilizationPercentage: 50
  config: {}
  configMapNamespace: ""
  containerPort:
    http: 80
    https: 443
  customTemplate:
    configMapKey: ""
    configMapName: ""
  daemonset:
    hostPorts:
      http: 80
      https: 443
    useHostPort: true
  defaultBackendService: ""
  dnsPolicy: ClusterFirst
  electionID: ingress-controller-leader
  extraArgs: {}
  extraContainers: []
  extraEnvs: []
  extraInitContainers: []
  extraVolumeMounts: []
  extraVolumes: []
  hostNetwork: true
  image:
    allowPrivilegeEscalation: true
    pullPolicy: IfNotPresent
    repository: quay.azk8s.cn/kubernetes-ingress-controller/nginx-ingress-controller
    runAsUser: 33
    tag: 0.26.1
  ingressClass: nginx
  kind: DaemonSet
  lifecycle: {}
  livenessProbe:
    failureThreshold: 3
    initialDelaySeconds: 10
    periodSeconds: 10
    port: 10254
    successThreshold: 1
    timeoutSeconds: 1
  metrics:
    enabled: true
    port: 10254
    prometheusRule:
      additionalLabels: {}
      enabled: false
      namespace: ""
      rules: []
    service:
      annotations: {}
      clusterIP: ""
      externalIPs: []
      loadBalancerIP: ""
      loadBalancerSourceRanges: []
      omitClusterIP: false
      servicePort: 9913
      type: ClusterIP
    serviceMonitor:
      additionalLabels: {}
      enabled: false
      namespace: ""
      scrapeInterval: 30s
  minAvailable: 1
  minReadySeconds: 5
  name: controller
  nodeSelector:
    canruningress: run
  podAnnotations: {}
  podLabels: {}
  podSecurityContext: {}
  priorityClassName: ""
  proxySetHeaders: {}
  publishService:
    enabled: false
    pathOverride: ""
  readinessProbe:
    failureThreshold: 3
    initialDelaySeconds: 10
    periodSeconds: 10
    port: 10254
    successThreshold: 1
    timeoutSeconds: 1
  replicaCount: 1
  reportNodeInternalIp: false
  resources:
    limits:
      cpu: 100m
      memory: 256Mi
    requests:
      cpu: 100m
      memory: 128Mi
  scope:
    enabled: false
    namespace: ""
  service:
    annotations: {}
    clusterIP: ""
    enableHttp: true
    enableHttps: true
    enabled: true
    externalIPs: []
    externalTrafficPolicy: ""
    healthCheckNodePort: 0
    labels: {}
    loadBalancerIP: ""
    loadBalancerSourceRanges: []
    nodePorts:
      http: ""
      https: ""
      tcp: {}
      udp: {}
    omitClusterIP: false
    ports:
      http: 80
      https: 443
    targetPorts:
      http: http
      https: https
    type: clusterIP
  tcp:
    configMapNamespace: ""
  terminationGracePeriodSeconds: 60
  tolerations:
  - operator: Exists
  udp:
    configMapNamespace: ""
  updateStrategy:
    rollingUpdate:
      maxUnavailable: 1
    type: RollingUpdate
defaultBackend:
  affinity: {}
  enabled: true
  extraArgs: {}
  extraEnvs: []
  image:
    pullPolicy: IfNotPresent
    repository: gcr.azk8s.cn/google-containers/defaultbackend-amd64
    runAsUser: 65534
    tag: "1.5"
  livenessProbe:
    failureThreshold: 3
    initialDelaySeconds: 30
    periodSeconds: 10
    successThreshold: 1
    timeoutSeconds: 5
  minAvailable: 1
  name: default-backend
  nodeSelector: {}
  podAnnotations: {}
  podLabels: {}
  podSecurityContext: {}
  port: 8080
  priorityClassName: ""
  readinessProbe:
    failureThreshold: 6
    initialDelaySeconds: 0
    periodSeconds: 5
    successThreshold: 1
    timeoutSeconds: 5
  replicaCount: 1
  resources:
    limits:
      cpu: 10m
      memory: 20Mi
    requests:
      cpu: 10m
      memory: 20Mi
  service:
    annotations: {}
    clusterIP: ""
    externalIPs: []
    loadBalancerIP: ""
    loadBalancerSourceRanges: []
    omitClusterIP: false
    servicePort: 80
    type: ClusterIP
  serviceAccount:
    create: true
    name: null
  tolerations: []
imagePullSecrets: []
podSecurityPolicy:
  enabled: false
rbac:
  create: true
revisionHistoryLimit: 10
serviceAccount:
  create: true
  name: null
tcp: {}
udp: {}

HOOKS:
MANIFEST:
---
# Source: nginx-ingress/templates/controller-serviceaccount.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    app: nginx-ingress
    chart: nginx-ingress-1.24.7
    heritage: Helm
    release: nginx-ingress
  name: nginx-ingress
---
# Source: nginx-ingress/templates/default-backend-serviceaccount.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    app: nginx-ingress
    chart: nginx-ingress-1.24.7
    heritage: Helm
    release: nginx-ingress
  name: nginx-ingress-backend
---
# Source: nginx-ingress/templates/clusterrole.yaml
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRole
metadata:
  labels:
    app: nginx-ingress
    chart: nginx-ingress-1.24.7
    heritage: Helm
    release: nginx-ingress
  name: nginx-ingress
rules:
  - apiGroups:
      - ""
    resources:
      - configmaps
      - endpoints
      - nodes
      - pods
      - secrets
    verbs:
      - list
      - watch
  - apiGroups:
      - ""
    resources:
      - nodes
    verbs:
      - get
  - apiGroups:
      - ""
    resources:
      - services
    verbs:
      - get
      - list
      - update
      - watch
  - apiGroups:
      - extensions
      - "networking.k8s.io" # k8s 1.14+
    resources:
      - ingresses
    verbs:
      - get
      - list
      - watch
  - apiGroups:
      - ""
    resources:
      - events
    verbs:
      - create
      - patch
  - apiGroups:
      - extensions
      - "networking.k8s.io" # k8s 1.14+
    resources:
      - ingresses/status
    verbs:
      - update
---
# Source: nginx-ingress/templates/clusterrolebinding.yaml
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  labels:
    app: nginx-ingress
    chart: nginx-ingress-1.24.7
    heritage: Helm
    release: nginx-ingress
  name: nginx-ingress
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: nginx-ingress
subjects:
  - kind: ServiceAccount
    name: nginx-ingress
    namespace: default
---
# Source: nginx-ingress/templates/controller-role.yaml
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: Role
metadata:
  labels:
    app: nginx-ingress
    chart: nginx-ingress-1.24.7
    heritage: Helm
    release: nginx-ingress
  name: nginx-ingress
rules:
  - apiGroups:
      - ""
    resources:
      - namespaces
    verbs:
      - get
  - apiGroups:
      - ""
    resources:
      - configmaps
      - pods
      - secrets
      - endpoints
    verbs:
      - get
      - list
      - watch
  - apiGroups:
      - ""
    resources:
      - services
    verbs:
      - get
      - list
      - update
      - watch
  - apiGroups:
      - extensions
      - "networking.k8s.io" # k8s 1.14+
    resources:
      - ingresses
    verbs:
      - get
      - list
      - watch
  - apiGroups:
      - extensions
      - "networking.k8s.io" # k8s 1.14+
    resources:
      - ingresses/status
    verbs:
      - update
  - apiGroups:
      - ""
    resources:
      - configmaps
    resourceNames:
      - ingress-controller-leader-nginx
    verbs:
      - get
      - update
  - apiGroups:
      - ""
    resources:
      - configmaps
    verbs:
      - create
  - apiGroups:
      - ""
    resources:
      - endpoints
    verbs:
      - create
      - get
      - update
  - apiGroups:
      - ""
    resources:
      - events
    verbs:
      - create
      - patch
---
# Source: nginx-ingress/templates/controller-rolebinding.yaml
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: RoleBinding
metadata:
  labels:
    app: nginx-ingress
    chart: nginx-ingress-1.24.7
    heritage: Helm
    release: nginx-ingress
  name: nginx-ingress
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: nginx-ingress
subjects:
  - kind: ServiceAccount
    name: nginx-ingress
    namespace: default
---
# Source: nginx-ingress/templates/controller-metrics-service.yaml
apiVersion: v1
kind: Service
metadata:
  labels:
    app: nginx-ingress
    chart: nginx-ingress-1.24.7
    component: "controller"
    heritage: Helm
    release: nginx-ingress
  name: nginx-ingress-controller-metrics
spec:
  clusterIP: ""
  ports:
    - name: metrics
      port: 9913
      targetPort: metrics
  selector:
    app: nginx-ingress
    component: "controller"
    release: nginx-ingress
  type: "ClusterIP"
---
# Source: nginx-ingress/templates/controller-service.yaml
apiVersion: v1
kind: Service
metadata:
  labels:
    app: nginx-ingress
    chart: nginx-ingress-1.24.7
    component: "controller"
    heritage: Helm
    release: nginx-ingress
  name: nginx-ingress-controller
spec:
  clusterIP: ""
  ports:
    - name: http
      port: 80
      protocol: TCP
      targetPort: http
    - name: https
      port: 443
      protocol: TCP
      targetPort: https
  selector:
    app: nginx-ingress
    component: "controller"
    release: nginx-ingress
  type: "ClusterIP"
---
# Source: nginx-ingress/templates/default-backend-service.yaml
apiVersion: v1
kind: Service
metadata:
  labels:
    app: nginx-ingress
    chart: nginx-ingress-1.24.7
    component: "default-backend"
    heritage: Helm
    release: nginx-ingress
  name: nginx-ingress-default-backend
spec:
  clusterIP: ""
  ports:
    - name: http
      port: 80
      protocol: TCP
      targetPort: http
  selector:
    app: nginx-ingress
    component: "default-backend"
    release: nginx-ingress
  type: "ClusterIP"
---
# Source: nginx-ingress/templates/controller-daemonset.yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  labels:
    app: nginx-ingress
    chart: nginx-ingress-1.24.7
    component: "controller"
    heritage: Helm
    release: nginx-ingress
  name: nginx-ingress-controller
spec:
  selector:
    matchLabels:
      app: nginx-ingress
      release: nginx-ingress
  revisionHistoryLimit: 10
  updateStrategy:
    rollingUpdate:
      maxUnavailable: 1
    type: RollingUpdate
  minReadySeconds: 5
  template:
    metadata:
      labels:
        app: nginx-ingress
        component: "controller"
        release: nginx-ingress
    spec:
      dnsPolicy: ClusterFirst
      containers:
        - name: nginx-ingress-controller
          image: "quay.azk8s.cn/kubernetes-ingress-controller/nginx-ingress-controller:0.26.1"
          imagePullPolicy: "IfNotPresent"
          args:
            - /nginx-ingress-controller
            - --default-backend-service=default/nginx-ingress-default-backend
            - --election-id=ingress-controller-leader
            - --ingress-class=nginx
            - --configmap=default/nginx-ingress-controller
          securityContext:
            capabilities:
                drop:
                - ALL
                add:
                - NET_BIND_SERVICE
            runAsUser: 33
            allowPrivilegeEscalation: true
          env:
            - name: POD_NAME
              valueFrom:
                fieldRef:
                  fieldPath: metadata.name
            - name: POD_NAMESPACE
              valueFrom:
                fieldRef:
                  fieldPath: metadata.namespace
          livenessProbe:
            httpGet:
              path: /healthz
              port: 10254
              scheme: HTTP
            initialDelaySeconds: 10
            periodSeconds: 10
            timeoutSeconds: 1
            successThreshold: 1
            failureThreshold: 3
          ports:
            - name: http
              containerPort: 80
              protocol: TCP
              hostPort: 80
            - name: https
              containerPort: 443
              protocol: TCP
              hostPort: 443
            - name: metrics
              containerPort: 10254
              protocol: TCP
          readinessProbe:
            httpGet:
              path: /healthz
              port: 10254
              scheme: HTTP
            initialDelaySeconds: 10
            periodSeconds: 10
            timeoutSeconds: 1
            successThreshold: 1
            failureThreshold: 3
          resources:
            limits:
              cpu: 100m
              memory: 256Mi
            requests:
              cpu: 100m
              memory: 128Mi
      hostNetwork: true
      nodeSelector:
        canruningress: run
      tolerations:
        - operator: Exists
      serviceAccountName: nginx-ingress
      terminationGracePeriodSeconds: 60
---
# Source: nginx-ingress/templates/default-backend-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx-ingress
    chart: nginx-ingress-1.24.7
    component: "default-backend"
    heritage: Helm
    release: nginx-ingress
  name: nginx-ingress-default-backend
spec:
  selector:
    matchLabels:
      app: nginx-ingress
      release: nginx-ingress
  replicas: 1
  revisionHistoryLimit: 10
  template:
    metadata:
      labels:
        app: nginx-ingress
        component: "default-backend"
        release: nginx-ingress
    spec:
      containers:
        - name: nginx-ingress-default-backend
          image: "gcr.azk8s.cn/google-containers/defaultbackend-amd64:1.5"
          imagePullPolicy: "IfNotPresent"
          args:
          securityContext:
            runAsUser: 65534
          livenessProbe:
            httpGet:
              path: /healthz
              port: 8080
              scheme: HTTP
            initialDelaySeconds: 30
            periodSeconds: 10
            timeoutSeconds: 5
            successThreshold: 1
            failureThreshold: 3
          readinessProbe:
            httpGet:
              path: /healthz
              port: 8080
              scheme: HTTP
            initialDelaySeconds: 0
            periodSeconds: 5
            timeoutSeconds: 5
            successThreshold: 1
            failureThreshold: 6
          ports:
            - name: http
              containerPort: 8080
              protocol: TCP
          resources:
            limits:
              cpu: 10m
              memory: 20Mi
            requests:
              cpu: 10m
              memory: 20Mi
      serviceAccountName: nginx-ingress-backend
      terminationGracePeriodSeconds: 60

NOTES:
The nginx-ingress controller has been installed.

An example Ingress that makes use of the controller:

  apiVersion: extensions/v1beta1
  kind: Ingress
  metadata:
    annotations:
      kubernetes.io/ingress.class: nginx
    name: example
    namespace: foo
  spec:
    rules:
      - host: www.example.com
        http:
          paths:
            - backend:
                serviceName: exampleService
                servicePort: 80
              path: /
    # This section is only required if TLS is to be enabled for the Ingress
    tls:
        - hosts:
            - www.example.com
          secretName: example-tls

If TLS is enabled for the Ingress, a Secret containing the certificate and key must also be provided:

  apiVersion: v1
  kind: Secret
  metadata:
    name: example-tls
    namespace: foo
  data:
    tls.crt: <base64 encoded cert>
    tls.key: <base64 encoded key>
  type: kubernetes.io/tls

```

正式安装：

``` bash
$ helm install nginx-ingress --namespace=kube-system ./ 
NAME: nginx-ingress
LAST DEPLOYED: Wed Nov 13 16:05:22 2019
NAMESPACE: kube-system
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
The nginx-ingress controller has been installed.
Get the application URL by running these commands:
  export POD_NAME=$(kubectl --namespace kube-system get pods -o jsonpath="{.items[0].metadata.name}" -l "app=nginx-ingress,component=controller,release=nginx-ingress")
  kubectl --namespace kube-system port-forward $POD_NAME 8080:80
  echo "Visit http://127.0.0.1:8080 to access your application."

An example Ingress that makes use of the controller:

  apiVersion: extensions/v1beta1
  kind: Ingress
  metadata:
    annotations:
      kubernetes.io/ingress.class: nginx
    name: example
    namespace: foo
  spec:
    rules:
      - host: www.example.com
        http:
          paths:
            - backend:
                serviceName: exampleService
                servicePort: 80
              path: /
    # This section is only required if TLS is to be enabled for the Ingress
    tls:
        - hosts:
            - www.example.com
          secretName: example-tls

If TLS is enabled for the Ingress, a Secret containing the certificate and key must also be provided:

  apiVersion: v1
  kind: Secret
  metadata:
    name: example-tls
    namespace: foo
  data:
    tls.crt: <base64 encoded cert>
    tls.key: <base64 encoded key>
  type: kubernetes.io/tls
```



安装完成，查看一下吧：

helm：

``` bash
$ helm ls
NAME	NAMESPACE	REVISION	UPDATED	STATUS	CHART	APP VERSION

# 噫，为啥是空的？我明明安装了啊？还记的helm env嘛？来看一下再：
$ helm env
HELM_DEBUG="false"
HELM_PLUGINS="/home/user/.local/share/helm/plugins"
HELM_REGISTRY_CONFIG="/home/user/.config/helm/registry.json"
HELM_REPOSITORY_CACHE="/home/user/.cache/helm/repository"
HELM_REPOSITORY_CONFIG="/home/user/.config/helm/repositories.yaml"
HELM_NAMESPACE="default"
HELM_KUBECONTEXT=""
HELM_BIN="helm"

# 看到了啥？
HELM_NAMESPACE="default"
# 哦我们helm ls默认是查看的defaut命名空间啊，需要加上--namespace=kube-system的
$ helm ls --namespace=kube-system
NAME         	NAMESPACE  	REVISION	UPDATED                                	STATUS  	CHART               	APP VERSION
nginx-ingress	kube-system	1       	2019-11-13 16:05:22.499188795 +0800 CST	deployed	nginx-ingress-1.24.7	0.26.1


```

kubectl：

``` bash
$ kubectl -n kube-system get po
NAME                                             READY   STATUS    RESTARTS   AGE
calico-kube-controllers-7b4657785d-7gw8s         1/1     Running   0          22h
calico-node-cwwpx                                1/1     Running   0          22h
calico-node-t4msz                                1/1     Running   0          22h
calico-node-v26zq                                1/1     Running   0          22h
coredns-5c98db65d4-f6bjz                         1/1     Running   0          26h
coredns-5c98db65d4-xn6fg                         1/1     Running   0          26h
etcd-k8s01.test.awsbj.cn                         1/1     Running   0          26h
kube-apiserver-k8s01.test.awsbj.cn               1/1     Running   0          26h
kube-controller-manager-k8s01.test.awsbj.cn      1/1     Running   0          26h
kube-proxy-9gtz5                                 1/1     Running   0          26h
kube-proxy-pwb7l                                 1/1     Running   0          26h
kube-proxy-qm9q8                                 1/1     Running   0          26h
kube-scheduler-k8s01.test.awsbj.cn               1/1     Running   0          26h
nginx-ingress-controller-228lr                   1/1     Running   0          11m
nginx-ingress-default-backend-576bbf498f-2kxns   1/1     Running   0          11m

# 看见最后两个没，一个是nginx-ingress-controller，一个是默认的后端
```



{% note info %}

kubectl小技巧：

``` bash
# 配置好kubectl自动补全

$ cat >> ~/.bashrc <<EOF
source <(kubectl completion bash)
EOF

# 应用
$ source ~/.bashrc
```

然后如果想要查看某个命名空间下的资源时，要先-n NAMESPACE来来指定名称空间，然后就可以tab了，很方便的。

``` bash
$ kubectl -n kube-system <tab键>
annotate       apply          autoscale      completion     cordon         delete         drain          explain        kustomize      options        port-forward   rollout        set            uncordon       
api-resources  attach         certificate    config         cp             describe       edit           expose         label          patch          proxy          run            taint          version        
api-versions   auth           cluster-info   convert        create         diff           exec           get            logs           plugin         replace        scale          top            wait
```

同理也是适用于helm的：

``` bash
$ helm -n kube- <tab键>
kube-node-lease  kube-public      kube-system      

$ helm -n kube-system status nginx-ingress # 输入完status，直接tab键，如果只有一个默认就自动帮你输入上了。
NAME: nginx-ingress
LAST DEPLOYED: Wed Nov 13 16:05:22 2019
NAMESPACE: kube-system
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
The nginx-ingress controller has been installed.
Get the application URL by running these commands:
  export POD_NAME=$(kubectl --namespace kube-system get pods -o jsonpath="{.items[0].metadata.name}" -l "app=nginx-ingress,component=controller,release=nginx-ingress")
  kubectl --namespace kube-system port-forward $POD_NAME 8080:80
  echo "Visit http://127.0.0.1:8080 to access your application."

An example Ingress that makes use of the controller:

  apiVersion: extensions/v1beta1
  kind: Ingress
  metadata:
    annotations:
      kubernetes.io/ingress.class: nginx
    name: example
    namespace: foo
  spec:
    rules:
      - host: www.example.com
        http:
          paths:
            - backend:
                serviceName: exampleService
                servicePort: 80
              path: /
    # This section is only required if TLS is to be enabled for the Ingress
    tls:
        - hosts:
            - www.example.com
          secretName: example-tls

If TLS is enabled for the Ingress, a Secret containing the certificate and key must also be provided:

  apiVersion: v1
  kind: Secret
  metadata:
    name: example-tls
    namespace: foo
  data:
    tls.crt: <base64 encoded cert>
    tls.key: <base64 encoded key>
  type: kubernetes.io/tls
```



{% endnote %}



### 测试nginx-ingress

nginx-ingress安装完了，测试一下吧：

``` bash
$ curl localhost
default backend - 404

# 返回了默认的404，因为我们还没有配置ingress呢。
```



#### 创建nginx deploy：

``` yaml
$ cat nginx-deploy.yaml 
kind: Deployment
apiVersion: apps/v1
metadata:
  name: nginx
  namespace: default
spec:
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.16-alpine
        ports:
        - name: http
          containerPort: 80
```

应用：

``` bash
$ kubectl apply -f nginx-deploy.yaml 
deployment.apps/nginx created
```



#### 创建nginx service:

```yaml
$ cat nginx-service.yaml 
apiVersion: v1
kind: Service
metadata:
  name: nginx
  namespace: default
spec:
  type: ClusterIP
  selector:
    app: nginx
  ports:
  - name: http
    port: 80
    protocol: TCP
    targetPort: http
```

应用：

``` bash
$ kubectl apply -f nginx-service.yaml 
service/nginx created
```

#### 创建nginx ingress 规则

``` yaml
$ cat nginx-ingress.yaml 
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: nginx
  annotations:
    kubernetes.io/ingress.class: nginx
  namespace: default
spec:
  rules:
  - host: nginx.test.com
    http:
      paths:
      - backend:
          serviceName: nginx
          servicePort: 80
        path: /
```

应用：

``` bash
$ kubectl apply -f nginx-ingress.yaml 
ingress.extensions/nginx created
```

检查：

``` bash
$ kubectl get deploy,pod,svc,ingress
NAME                          READY   UP-TO-DATE   AVAILABLE   AGE
deployment.extensions/nginx   1/1     1            1           15m

NAME                        READY   STATUS    RESTARTS   AGE
pod/nginx-9cb7f8c7d-wk89s   1/1     Running   0          15m

NAME                 TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.100.0.1     <none>        443/TCP   27h
service/nginx        ClusterIP   10.100.54.82   <none>        80/TCP    11m

NAME                       HOSTS            ADDRESS   PORTS   AGE
ingress.extensions/nginx   nginx.test.com             80      8m13s
```

测试ingress，因为master节点已经安装了nginx-ingress-controller并且使用的是hostNetwork，为了排除感染，我们登陆到worker节点测试：

``` bash
$ curl 172.17.0.7
default backend - 404

# 通过IP访问master节点，返回是404，因为我们的ingress规则配置了是nginx.test.com域名访问
# 我们加上主机头：Host: nginx.test.com 访问到了nginx pod。
$ curl -H "Host: nginx.test.com" 172.17.0.7
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```



{% note info %}

小疑问：

我安装的nginx的pod、service，ingress都是在default空间下，而我的nginx-ingress-controller安装kube-system下，配置的ingress为啥能够访问呢？

解释：

首先namespace只是逻辑的分组，并不是隔离的，所以不同namespace下默认的pod是可以互相访问的。当然后面可以用个网络规则禁止掉。

其次：我们来查看一下nginx-ingress-controller的启动参数吧：

``` bash
$ kubectl -n kube-system get po nginx-ingress-controller-228lr -o yaml
...
  containers:
  - args:
    - /nginx-ingress-controller
    - --default-backend-service=kube-system/nginx-ingress-default-backend
    - --election-id=ingress-controller-leader
    - --ingress-class=nginx
    - --configmap=kube-system/nginx-ingress-controller
...
```

在进入到nginx-ingress-controller容器内部看看命令的参数：

``` bash
$ kubectl -n kube-system exec -it nginx-ingress-controller-228lr -- bash

$ /nginx-ingress-controller --help
-------------------------------------------------------------------------------
NGINX Ingress controller
  Release:       0.26.1
  Build:         git-2de5a893a
  Repository:    https://github.com/kubernetes/ingress-nginx
  nginx version: openresty/1.15.8.2

-------------------------------------------------------------------------------

Usage of :
      --add_dir_header                          If true, adds the file directory to the header
      --alsologtostderr                         log to standard error as well as files
      --annotations-prefix string               Prefix of the Ingress annotations specific to the NGINX controller. (default "nginx.ingress.kubernetes.io")
      --apiserver-host string                   Address of the Kubernetes API server.
                                                Takes the form "protocol://address:port". If not specified, it is assumed the
                                                program runs inside a Kubernetes cluster and local discovery is attempted.
      --configmap string                        Name of the ConfigMap containing custom global configurations for the controller.
      --default-backend-service string          Service used to serve HTTP requests not matching any known server name (catch-all).
                                                Takes the form "namespace/name". The controller configures NGINX to forward
                                                requests to the first port of this Service.
      --default-server-port int                 Port to use for exposing the default server (catch-all). (default 8181)
      --default-ssl-certificate string          Secret containing a SSL certificate to be used by the default HTTPS server (catch-all).
                                                Takes the form "namespace/name".
      --disable-catch-all                       Disable support for catch-all Ingresses
      --election-id string                      Election id to use for Ingress status updates. (default "ingress-controller-leader")
      --enable-metrics                          Enables the collection of NGINX metrics (default true)
      --enable-ssl-chain-completion             Autocomplete SSL certificate chains with missing intermediate CA certificates.
                                                Certificates uploaded to Kubernetes must have the "Authority Information Access" X.509 v3
                                                extension for this to succeed.
      --enable-ssl-passthrough                  Enable SSL Passthrough.
      --health-check-path string                URL path of the health check endpoint.
                                                Configured inside the NGINX status server. All requests received on the port
                                                defined by the healthz-port parameter are forwarded internally to this path. (default "/healthz")
      --health-check-timeout int                Time limit, in seconds, for a probe to health-check-path to succeed. (default 10)
      --healthz-port int                        Port to use for the healthz endpoint. (default 10254)
      --http-port int                           Port to use for servicing HTTP traffic. (default 80)
      --https-port int                          Port to use for servicing HTTPS traffic. (default 443)
      --ingress-class string                    Name of the ingress class this controller satisfies.
                                                The class of an Ingress object is set using the annotation "kubernetes.io/ingress.class".
                                                All ingress classes are satisfied if this parameter is left empty.
      --kubeconfig string                       Path to a kubeconfig file containing authorization and API server information.
      --log_backtrace_at traceLocation          when logging hits line file:N, emit a stack trace (default :0)
      --log_dir string                          If non-empty, write log files in this directory
      --log_file string                         If non-empty, use this log file
      --log_file_max_size uint                  Defines the maximum size a log file can grow to. Unit is megabytes. If the value is 0, the maximum file size is unlimited. (default 1800)
      --logtostderr                             log to standard error instead of files (default true)
      --metrics-per-host                        Export metrics per-host (default true)
      --profiler-port int                       Port to use for expose the ingress controller Go profiler when it is enabled. (default 10245)
      --profiling                               Enable profiling via web interface host:port/debug/pprof/ (default true)
      --publish-service string                  Service fronting the Ingress controller.
                                                Takes the form "namespace/name". When used together with update-status, the
                                                controller mirrors the address of this service's endpoints to the load-balancer
                                                status of all Ingress objects it satisfies.
      --publish-status-address string           Customized address to set as the load-balancer status of Ingress objects this controller satisfies.
                                                Requires the update-status parameter.
      --report-node-internal-ip-address         Set the load-balancer status of Ingress objects to internal Node addresses instead of external.
                                                Requires the update-status parameter.
      --skip_headers                            If true, avoid header prefixes in the log messages
      --skip_log_headers                        If true, avoid headers when opening log files
      --ssl-passthrough-proxy-port int          Port to use internally for SSL Passthrough. (default 442)
      --status-port int                         Port to use for the lua HTTP endpoint configuration. (default 10246)
      --stderrthreshold severity                logs at or above this threshold go to stderr (default 2)
      --stream-port int                         Port to use for the lua TCP/UDP endpoint configuration. (default 10247)
      --sync-period duration                    Period at which the controller forces the repopulation of its local object stores. Disabled by default.
      --sync-rate-limit float32                 Define the sync frequency upper limit (default 0.3)
      --tcp-services-configmap string           Name of the ConfigMap containing the definition of the TCP services to expose.
                                                The key in the map indicates the external port to be used. The value is a
                                                reference to a Service in the form "namespace/name:port", where "port" can
                                                either be a port number or name. TCP ports 80 and 443 are reserved by the
                                                controller for servicing HTTP traffic.
      --udp-services-configmap string           Name of the ConfigMap containing the definition of the UDP services to expose.
                                                The key in the map indicates the external port to be used. The value is a
                                                reference to a Service in the form "namespace/name:port", where "port" can
                                                either be a port name or number.
      --update-status                           Update the load-balancer status of Ingress objects this controller satisfies.
                                                Requires setting the publish-service parameter to a valid Service reference. (default true)
      --update-status-on-shutdown               Update the load-balancer status of Ingress objects when the controller shuts down.
                                                Requires the update-status parameter. (default true)
  -v, --v Level                                 number for the log level verbosity
      --validating-webhook string               The address to start an admission controller on to validate incoming ingresses.
                                                Takes the form "<host>:port". If not provided, no admission controller is started.
      --validating-webhook-certificate string   The path of the validating webhook certificate PEM.
      --validating-webhook-key string           The path of the validating webhook key PEM.
      --version                                 Show release information about the NGINX Ingress controller and exit.
      --vmodule moduleSpec                      comma-separated list of pattern=N settings for file-filtered logging
      --watch-namespace string                  Namespace the controller watches for updates to Kubernetes objects.
                                                This includes Ingresses, Services and all configuration resources. All
                                                namespaces are watched if this parameter is left empty.
```

注意到有一条参数：

``` 
--watch-namespace string
Namespace the controller watches for updates to Kubernetes objects.This includes Ingresses, Services and all configuration resources. All namespaces are watched if this parameter is left empty.

解释：如果这个为空，代表watches所有kubernetes namespace下的ingresses，通过默认的nginx-ingress-controller启动参数我们发现没有这个参数：--watch-namespace，所以也就说明了上面的疑问。
```

{% note danger %}

这里衍生出了生产的建议：

可以安装配置多个nginx-ingress-controller组来分担不同的服务域名，比如：一组nginx-ingress-controller监听namespace SVCA，通过域名访问SVCA.test.com；

另一组nginx-ingress-controller监听另一个namespace SVCB，通过域名访问：SVCB.test.com；

而每组nginx-ingress-controller都结合前面的建议，各自放到独立的主机上，启动多台；

这样就把域名分开了，而不会都配置到一个nginx-ingress-controller而造成一挂全挂的局面。

{% endnote %}

{% endnote %}



本分到这里就完毕了。