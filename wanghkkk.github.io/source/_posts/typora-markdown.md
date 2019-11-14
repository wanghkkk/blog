---
title: markdown 语法参考
preview: 300
comments: true
categories:
  - typora
  - markdown
tags:
  - markdown
date: 2019-11-05 09:47:03
updated: 
abstract: markdown 语法参考，大部分是通用的语法，Hexo不适用的已经标注
cover: /images/logos/typora-big.png
typora-root-url: ..
---

![](/images/logos/markdown.jpg)

Markdown 编辑器有很多，可以用vscode，typora，这里使用typora这个软件，markdown格式自动渲染，非常的不错。

## 整体目录

Hexo 内无法显示，参考左侧的目录

[toc]



## Typora 链接

官网：

https://typora.io

文档：

http://support.typora.io

## Typora 安装

### 下载并安装Typora：

[Windows](https://typora.io/#windows)

[Mac](https://typora.io/download/Typora.dmg)

[Linux](https://typora.io/#linux)

安装步骤下一步即可。

### 下载并安装Pandoc：

typora导出的时候使用，如果不需要导出则不需要安装。[官网参考](http://support.typora.io/Install-and-Use-Pandoc/)

Typora支持的导出格式如下：

![typora导出格式](/images/typora-markdown/typora-export.jpg)

[Pandoc GitHub](https://github.com/jgm/pandoc)

[Pandoc下载](https://github.com/jgm/pandoc/releases/latest)，选择对应版本下载安装即可

## Markdown 语法

[官网参考](http://support.typora.io/Markdown-Reference/)

最原始的Markdown格式[参考](http://daringfireball.net/projects/markdown/syntax), Typora使用的是[GitHub Flavored Markdown](https://help.github.com/cn/github/writing-on-github)。

### 块 （Block Elements）

> Element 
> 英 /ˈelɪmənt/  美 /ˈelɪmənt/  全球(英国) 
> n. 元素；要素；原理；成分；自然环境
> n. (Element)人名；(德)埃勒门特；(英)埃利门特
> 复数 elements

#### 段落和换行符（Paragraph and line breaks）

> paragraph
> 英 /ˈpærəɡrɑːf/ 美 /ˈpærəɡræf/
> n. 段落；短评；段落符号
> vt. 将…分段
>
> line break
> 换行符；输送管线断裂

在typora中段落模式使用2行作为分隔，可以使用快捷键sheift+回车键，进行单行分隔。但是对于其他的markdown解释器可能会忽略单行的，所以还是建议使用默认的2行作为段落分割。

#### 标题 （Headers）

标题使用1-6个#号作为1-6标题：如下：

```
# 标题1
## 标题2
###### 标题6
```

效果如下，这里使用图片抵用，一面影响TOC

---

![标题](/images/typora-markdown/headers.jpg)

---

#### 引用（Blockquotes）

引用使用：> 表示，如下：

```
> 引用内容1
> 引用内容2
>
> 已用内容N
```

效果如下：

---

> 引用内容1
> 引用内容2
>
> 已用内容N

---

#### 列表（lists）

使用\*、+、-来代表无序的列表，使用1. 、2. 来代表有序的列表，在typora中直接键入\*号，然后回车，自动触发，如下：

```
无序列表
* name
* age
* sex

+ name
+ age
+ sex

- name
- age
- sex

有序列表
1. name
2. age
3. sex
```

显示效果：

---

无序列表

* name
* age
* sex

+ name
+ age
+ sex

- name
- age
- sex

有序列表

1. name
2. age
3. sex

---

#### 任务列表（Task List）

任务列表使用：- [ ] 和 - [x]分别代表未完成和已完成的任务列表：

注意：[ ] 两个中括号中间是空格。

在typora中直接键入- [ ]，然后按空格，自动触发

```
- [ ] a task list item
- [ ] list syntax required
- [ ] normal **formatting**, @mentions, #1234 refs
- [ ] incomplete
- [x] completed
```

显示效果如下：你可以点击前边的方块，来完成具体项。

---

- [ ] a task list item
- [ ] list syntax required
- [ ] normal **formatting**, @mentions, #1234 refs
- [ ] incomplete
- [x] completed

---

备注：有的markdown解释器可能无法识别，Hexo内显示正常，贴图如下：

![任务列表](/images/typora-markdown/task.jpg)

#### 代码块（Code Blocks）

使用：三个反引号(```)把代码块包裹起来，手部的反引号后面可以标明代码块的语言，markdown自动进行高亮，如下：我这里为了避免嵌套问题，在每个反引号前加了反斜线\.

在typora中直接键入```号，然后回车，自动触发

```
Here's an example:

\`\`\`
function test() {
  console.log("notice the blank line before this function?");
}
\`\`\`

syntax highlighting:
\`\`\`ruby
require 'redcarpet'
markdown = Redcarpet.new("Hello World!")
puts markdown.to_html
\`\`\`
```

显示效果如下：

---

Here's an example:

```
function test() {
  console.log("notice the blank line before this function?");
}
```

syntax highlighting:
```ruby
require 'redcarpet'
markdown = Redcarpet.new("Hello World!")
puts markdown.to_html
```

---

#### 数学公式（Math Blocks）

你可以通过使用MathJax来表示LaTeX数学表达式，使用$$把数学表达式进行包裹起来：

在typora中直接键入$$号，然后回车，自动触发

```
$$
\mathbf{V}_1 \times \mathbf{V}_2 =  \begin{vmatrix}
\mathbf{i} & \mathbf{j} & \mathbf{k} \\
\frac{\partial X}{\partial u} &  \frac{\partial Y}{\partial u} & 0 \\
\frac{\partial X}{\partial v} &  \frac{\partial Y}{\partial v} & 0 \\
\end{vmatrix}
$$
```

显示效果：

---

$$
\mathbf{V}_1 \times \mathbf{V}_2 =  \begin{vmatrix}
\mathbf{i} & \mathbf{j} & \mathbf{k} \\
\frac{\partial X}{\partial u} &  \frac{\partial Y}{\partial u} & 0 \\
\frac{\partial X}{\partial v} &  \frac{\partial Y}{\partial v} & 0 \\
\end{vmatrix}
$$

---

备注：有的markdown可能无法显示，Hexo无法显示：特贴图如下：

![数学表达式显示效果](/images/typora-markdown/math.jpg)

在Typora中详细的数学表达式[请参考](http://support.typora.io/Math/)

#### 表格（Tables）

键入 |列名1|列名2|列名3|，然后回车，typora自动触发创建表格，如下：

```
|name|age|sex|city|
| - | - | -| - |
| knner | 32 | 1 | Beijing|
```

输入如下：

---

| name  | age  | sex  | city    |
| ----- | ---- | ---- | ------- |
| knner | 32   | 1    | Beijing |

---

在表的第一行（标题行）和第二行（内容行）中可以使用 :- 表示左对齐 –: 表示右对齐 :–: 中间对齐，如下

```
|name|age|sex|city|
| :- | :-: | -: | - |
| knner | 32 | 1 | Beijing|
```

输出如下：

---

| name  | age  |  sex | city    |
| :---- | :--: | ---: | ------- |
| knner |  32  |    1 | Beijing |

---

#### 脚注（Footnotes）

可以使用: [^] 脚注key，使用 [^]: 定义之前的脚注value，鼠标放到脚注上，可以看到脚注定义的内容：

```
可以这样创建脚注：[^footnoteName]，注意格式：[^]，^后面跟脚注名

[^footnoteName]: 这里是上边的脚注啦，注意格式：[^]:  和上面定义的脚注唯一的不同点是最后的冒号。
```

效果如下：Hexo内无法正常显示

---

可以这样创建脚注：[^footnoteName]，注意格式：\[\^\]，^后面跟脚注名

[^footnoteName]: 这里是上边的脚注啦，注意格式：[^]:  和上面定义的脚注唯一的不同点是最后的冒号。

---

把鼠标放到脚注上会显示下面定义的脚注说明，点击脚注可以调转到定义的脚注说明：

![脚注](/images/typora-markdown/footnotes.jpg)

#### 水平线（Horizontal）

上面看到的一行行的横线就是水平线，使用三个星号，或者三个中横线定义：

```
下面是水平线
***
下面也是水平线
---
```

  效果如下：

下面是水平线

***

下面也是水平线

---

#### YAML 前页（Front Matter）

Typora、Hexo、Jekyllrb等，在文章的最开头使用---进行包裹的，里边写入响应的Metadata元数据，来定义响应的规则：

```
---
title: typora-markdown格式参考
preview: 300
comments: true
categories:
  - typora
  - markdown
tags:
  - markdown
date: 2019-11-05 09:47:03
updated: 
abstract: typora-markdown格式参考
typora-root-url: ..
---
```

如上：1-14行就是所谓的Front Matter，2-12行是Hexo以及主题可以使用的元数据，13行是定义的Typora当前文章的图片根目录，后面会详细介绍。

#### 目录（Table of Contents：TOC）

Typora使用：\[toc]，然后按回车，会自动根据标题生成目录，目录会随着内容的变换而更新，例如：文章右侧的目录。

Hexo内无法正常显示

---

### 行内元素（Span Elements）

Span元素将在键入后立即被解析和呈现。将光标移动到这些span元素的中间将会将这些元素展开为markdown源。下面解释每个span元素的语法。

#### 链接（Links）

分为两种链接，一种是Inline（可以链接到任意你想要到的网址，网址在方括号后边的圆括号内定义），另一种是Reference引用（链接到其他网址，网址在另外的行中定义）。

##### Inline：

格式：\[内容](网址 Title)，如下所示，Title是把鼠标放到链接上显示的内容：

```
This is [an example](http://example.com/ "Title") inline link.

[This link](http://example.net/) has no title attribute.
```

效果如下：

This is [an example](http://example.com/ "Title") inline link. 

[This link](http://example.net/) has no title attribute. 

Title的效果图：

![inline-title](/images/typora-markdown/inline-title.jpg)

###### 问题：

如何增加链接跳转到本文内的其他位置呢？

Markdown会自动给每一个h1-h6标题生成一个锚，其`id`就是**标题内容**。目录树中的每一项都是一个跳转链接，点击后就会跳转到其对应的锚点（即标题所在位置）

两种方式：

```html
方式1：通过Markdown语法，推荐
[跳转到目录](#整体目录)

方式2：通过HTML语法：
<a href="#整体目录">跳转到目录</a>
```

显示效果：

---

方式1：通过Markdown语法：
[跳转到目录](#整体目录)

方式2：通过HTML语法：
<a href="#整体目录">跳转到目录</a>

---

###### 那么问题又来了

如果我不想跳转到某个标题呢，只想跳转到某段话呢？

```html
对于要跳转到的地方，需要定义好锚点
<span id="1">跳转到这里1</span>

写超链接，定义跳转到哪里
[跳转到1](#1)
<a href="#1">跳转到1</a>
```

显示效果：

**注意**: Typora不支持这种方式：但是Hexo网页上是可以的。

---

对于要跳转到的地方，需要定义好锚点
<span id="jump">跳转到这里1</span>

写超链接，定义跳转到哪里
[跳转到1](#jump)
<a href="#jump">跳转到1</a>

---

###### 另一个问题：

如何跳转到其他文件呢？

```
[使用hexo + github pages 创建博客](my-first-blog.md)
```

显示效果：

---

[使用hexo + github pages 创建博客](my-first-blog.md)

---

原理：他会在当前目录内找圆括号内的文件，然后跳转打开。

**注意**：上面的链接在Hexo内无法打开，因为`hexo gen`或者`hexo dep`或者`hexp serv`，都会将xxx.md文件渲染成xxx.html。*_config.yml* 内定义的。这种方式只能跳转到和本文件同一目录的其他文件上。

对于hexo如果需要跳转到其他的文章，可能不是同一时间内写的。

本文的链接是：https://knner.wang/2019/11/05/typora-markdown.html

可能要跳转到：https://knner.wang/2019/11/01/my-first-blog.html

如何在markdown内增加链接呢？这就需要用到了Hexo的tag功能：

[官网参考](https://hexo.io/zh-cn/docs/tag-plugins)

```
引用其他文章的链接。
{% post_path slug %}
{% post_link slug [title] [escape] %}
在使用此标签时可以忽略文章文件所在的路径或者文章的永久链接信息、如语言、日期。
例如，在文章中使用 {% post_link how-to-bake-a-cake %} 时，只需有一个名为 how-to-bake-a-cake.md 的文章文件即可。即使这个文件位于站点文件夹的 source/posts/2015-02-my-family-holiday 目录下、或者文章的永久链接是 2018/en/how-to-bake-a-cake，都没有影响。
默认链接文字是文章的标题，你也可以自定义要显示的文本。此时不应该使用 Markdown 语法 []()。

例如：
跳转到"使用hexo + github pages 创建博客"这篇文章：
{% post_link my-first-blog 使用hexo + github pages 创建博客 %}
```

效果：

{% post_link my-first-blog 使用hexo + github pages 创建博客 %}

##### Reference Links

格式：\[内容][链接内容]，如下定义：

```
This is [an example][id] reference-style link.

Then, anywhere in the document, you define your link label on a line by itself like this:

[id]: http://example.com/  "Optional Title Here"
```

显示效果，点击`an example` 会跳转到：下面`[id]` 中定义的网址上。

---

This is [an example][id] reference-style link.

Then, anywhere in the document, you define your link label on a line by itself like this:

[id]: http://example.com/  "Optional Title Here"

---

链接内容可以省略，默认是内容：

```
[Google][]
And then define the link:

[Google]: http://google.com/
```

效果如下：同样，点击`Google` 会跳转到`Google`定义的网址：http://google.com/

---

[Google][]
And then define the link:

[Google]: http://google.com/

---

#### 斜体

使用一个型号*或者一个下划线_把要斜体的内容前后包裹，如下：

```
*single asterisks*

_single underscores_
```

显示效果如下：

---

*single asterisks*

_single underscores_

---

#### 粗体（Strong）

使用两个型号*或者两个下划线_把要加粗的内容前后包裹，如下：

```
**double asterisks**

__double underscores__
```

显示效果：

---

**double asterisks**

__double underscores__

---

#### 加粗斜体

使用三个型号*或者两个下划线_把要加粗斜体的内容前后包裹，如下：

```
***haha***
___haha___
```

显示效果如下：

---

***haha***

___hahaha___

---

#### 代码（code）

使用单个反引号（键盘叹号左边的键）将其包裹即可：

```
Use the `printf()` function.
```

显示效果如下：

---

 Use the `printf()` function. 

---

#### 删除线（Strikethrough）

使用两个波浪线将其包裹即可：

```
~~我被删除了，你能看见的，中间加了一条横线~~
```

显示效果如下：

---

~~我被删除了，你能看见的，中间加了一条横线~~

---

#### 下划线（Unerlines）

在Typora中，下划线使用的是HTML代码：

```html
<u>Underline</u>
```

显示效果：

---

 <u>Underline</u> 

---

### 下面是Markdown的扩展语法

Markdown的扩展语法，需要在Typora内开启，开启方式：文件--偏好设置--Markdown--勾选需要的扩展语法，如下图：

![](/images/typora-markdown/markdown-kuozhan.jpg)

简单介绍：

#### 内联公式：

使用单个$将公式包裹即可：

```
$\lim_{x \to \infty} \exp(-x) = 0$
```

显示效果：

$\lim_{x \to \infty} \exp(-x) = 0$

Hexo无法正常显示，贴图如下：

![](/images/typora-markdown/inline-math.jpg)

#### 下标（Subscript）

使用一个波浪线~(Shift + (数字1左边的键，tab键上边的键))将下标包裹：

```
H~2~O
```

显示效果：

H~2~O

Hexo无法正常显示，贴图如下：

![下标](/images/typora-markdown/xb.jpg)

#### 上标（Superscript）

使用两个尖角号^(Shift + 6)将上标包裹：

```
X^2^
```

显示效果：

X^2^

Hexo无法正常显示，贴图如下：

![上标](/images/typora-markdown/sb.jpg)

#### 高亮（Highlight）

使用两个等号将需要高亮的部分包裹：

```
==我亮嘛==
```

显示效果：

==我亮嘛==

Hexo无法正常显示，贴图如下：

![高亮](/images/typora-markdown/gl.jpg)

---

### HTML

你可以在文件内使用HTML语法来表示markdown不支持的格式，比如颜色：

直接贴上HTML代码在文件内即可：

```
<span style="color:red">this text is red</span>
```

显示效果：

<span style="color:red">this text is red</span>

详细的请参考[HTML](http://support.typora.io/HTML/)


### YAML Copy Test

``` yaml
apiVersion: kubeadm.k8s.io/v1beta2
kind: InitConfiguration
nodeRegistration:
  taints:
  - effect: NoSchedule
    key: node-role.kubernetes.io/master
  kubeletExtraArgs:
    cloud-provider: aws
---
apiServer:
  timeoutForControlPlane: 4m0s
  extraArgs:
    cloud-provider: aws
    runtime-config: "api/all=true"
    audit-log-path: /var/log/kubernetes/audit.log
apiVersion: kubeadm.k8s.io/v1beta2
certificatesDir: /etc/kubernetes/pki
clusterName: kubernetes
controllerManager:
  extraArgs:
    cloud-provider: aws
    horizontal-pod-autoscaler-use-rest-clients: "true"
    horizontal-pod-autoscaler-sync-period: "10s"
    node-monitor-grace-period: "10s"
dns:
  type: CoreDNS
etcd:
  local:
    dataDir: /var/lib/etcd
imageRepository: k8s.gcr.io
kind: ClusterConfiguration
kubernetesVersion: v1.16.1
controlPlaneEndpoint: 172.17.0.180:64443
networking:
  dnsDomain: cluster.local
  podSubnet: 10.101.0.0/16
  serviceSubnet: 10.100.0.0/16
scheduler: {}
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
