---
title: docker.io gcr.io k8s.gcr.io quay.io 中国区加速
preview: 300
comments: true
categories:
  - docker
tags:
  - docker
date: 2019-11-13 15:20:42
updated: 2019-11-13 15:20:42
abstract:
cover:
typora-root-url: ..
---

安装Kubernetes默认的image源是：k8s.gcr.io，中国区安装极为痛苦，不FQ就拉取不下来，类似的还有Red Head的quay.io，虽然能下载，但是速度非常的慢。

解决办法来了：

中国区有了以上的docker registry镜像源了：

[中科大镜像](https://github.com/ustclug/mirrorrequest) 和 [Azure中国镜像](https://github.com/Azure/container-service-for-azure-china)

先上总结，方便直接查阅：

## 总结

鉴于中科大的源经常的出现not fount的错误，所以这里使用Azure的镜像源。

### docker.io

#### docker官方维护

``` bash
$ docker pull dockerhub.azk8s.cn/library/xxx:yyy
```

#### 非官方维护

``` bash
$ docker pull dockerhub.azk8s.cn/uuu/xxx:yyy
```



### gcr.io 和 k8s.gcr.io

#### gcr.io

``` bash
$ docker pull gcr.azk8s.cn/xxx/yyy:zzz
```

#### k8s.gcr.io

``` bash
$ docker pull gcr.azk8s.cn/google-containers/xxx:yyy
```



### quay.io

``` bash
$ docker pull quay.azk8s.cn/xxx/yyy:zzz
```



下面详细讲解：

## docker.io 镜像加速

默认的docker registry是：https://hub.docker.com

### 使用中科大镜像 docker.mirrors.ustc.edu.cn

默认的一种拉取方式：

``` bash
$ docker pull xxx:yyy

这里没有指定用户，默认是docker官方维护的镜像
xxx为镜像的名称
yyy为镜像的tag版本
```

那么使用中科大镜像的方式：

``` bash
$ docker pull docker.mirrors.ustc.edu.cn/library/xxx:yyy
```

例如：nginx:1.16-alpine

```bash
$ docker pull docker.mirrors.ustc.edu.cn/library/nginx:1.16-alpine
```



默认的另一种拉取方式：

``` bash
$ docker pull uuu/xxx:yyy

uuu为具体的用户，有其负责维护该镜像
xxx为镜像的名称
yyy为镜像的tag版本
```

那么使用中科大镜像的方式：

``` bash
$ docker pull docker.mirrors.ustc.edu.cn/uuu/xxx:yyy
```

例如：wanghkkk/busyboxplus:latest

``` bash
$ docker pull docker.mirrors.ustc.edu.cn/wanghkkk/busyboxplus
```

{% note danger %}

默认中科大会提示：Error response from daemon: manifest for docker.mirrors.ustc.edu.cn/wanghkkk/busyboxplus:latest not found

因为默认中科大不会换成镜像的，需要多试几次，等中科大缓存完成后才能下载的。**所以这里不推荐用中科大的**。

{% endnote %}



### 使用Azure中国镜像 dockerhub.azk8s.cn

还是使用上面的两个例子：

nginx:1.16-alpine

wanghkkk/busyboxplus

对应的Azure中国镜像是：

``` bash
$ docker pull dockerhub.azk8s.cn/library/nginx:1.16-alpine

$ docker pull dockerhub.azk8s.cn/wanghkkk/busyboxplus
```

{% note sucess %}

这里推荐使用Azure，直接就拉取下来了，不像中科大需要他自己先下载缓存，然后才能下载，至少我试了好几次也没拉取下来。

{% endnote %}

## gcr.io 和 k8s.gcr.io 镜像加速

gcr.io 和 k8s.gcr.io 实际上都是Google的镜像，默认中国区是根本访问不到的。

### gcr.io

#### 使用中科大镜像 gcr.mirrors.ustc.edu.cn

默认gcr.io拉取方式：

``` bash
$ docker pull gcr.io/xxx/yyy:zzz
```

那么更换成中科大的拉取方式：

``` bash
$ docker pull gcr.mirrors.ustc.edu.cn/xxx/yyy:zzz
```

例如：

这里使用gcr.io/kubernetes-helm/tiller:v2.16.1为例：

``` bash
$ docker pull gcr.mirrors.ustc.edu.cn/kubernetes-helm/tiller:v2.16.1
```



#### 使用Azure中国镜像 gcr.azk8s.cn

更换成Azure的拉取方式为：

``` bash
$ docker pull gcr.azk8s.cn/kubernetes-helm/tiller:v2.16.1
```

### k8s.gcr.io

对于按照kubernetes时候，用到的就是k8s.gcr.io开头的镜像，其实k8s.gcr.io就是等价于gcr.io/google-containers

例如：k8s.gcr.io/kube-proxy:v1.15.5

所以呢，对于中科大的拉取方式为：

``` bash
$ docker pull gcr.mirrors.ustc.edu.cn/google-containers/kube-proxy:v1.15.5
```

对于Azure的拉取方式为：

``` bash
$ docker pull gcr.azk8s.cn/google-containers/kube-proxy:v1.15.5
```



{% note danger %}

对于中科大的拉取，经常的出现not found，而对于Azure来说非常的顺畅，很快的拉取下来了，所以非常的推荐使用Azure的镜像源。

{% endnote %}

## quay.io 镜像加速

例如拉取镜像：

quay.io/kubernetes-ingress-controller/nginx-ingress-controller:0.26.1

### 使用中科大镜像 quay.mirrors.ustc.edu.cn

``` bash
$ docker pull quay.mirrors.ustc.edu.cn/kubernetes-ingress-controller/nginx-ingress-controller:0.26.1
```

### 使用Azure中国镜像 quay.azk8s.cn

``` bash
$ docker pull quay.azk8s.cn/kubernetes-ingress-controller/nginx-ingress-controller:0.26.1
```



## 一个python脚本全搞定

docker-wrapper.py

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

使用方式：

``` bash
$ chmod +x docker-wrapper.py
$ sudo mv docker-wrapper.py /usr/local/bin/
$ docker-wrapper.py pull xxx/yyy:zzz
```




> 参考：https://www.ilanni.com/?p=14534#一、docker.io镜像加速

