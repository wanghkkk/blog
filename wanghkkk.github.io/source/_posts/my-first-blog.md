---
title: 使用hexo + github pages 创建博客
date: 2019-11-01 21:34:00
categories:
  - hexo
tags:
  - hexo
abstract: 使用hexo框架在github pages上创建免费的博客
---

我的第一个hexo 文章,分享从头开始安装使用配置hexo，并设置好自己喜欢的主题，特做此文章记录。

## hexo

首页：
https://hexo.io/
https://hexo.io/zh-cn/

文档：
https://hexo.io/docs/
https://hexo.io/zh-cn/docs/

## hexo安装

### 安装依赖：nodejs

通过nvm来安装管理nodejs

#### 安装nvm：

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | sh
```

#### 通过nvm安装node：

```bash
num install node
```

#### 安装hexo工具：
```bash
npm install -g hexo-cli
```

## 使用hexo命令初始化一个博客
```bash
hexo init myblog
cd myblog
npm install
```

直接启动查看：
```bash
hexo server
```

## 创建自己喜欢的hexo主题

链接：
https://hexo.io/themes/

这里使用：A-Obsidian 主题
https://tridiamond.me/

主题github：
https://github.com/TriDiamond/hexo-theme-obsidian

```bash
cd myblog/themes
git clone https://github.com/TriDiamond/hexo-theme-obsidian.git obsidian
```

配置myblog：
```bash
vim myblog/_config.yml
theme: obsidian

# 关闭hexo高亮，使用主题自带的高亮：
highlight:
  enable: false
  line_number: true
  auto_detect: true
  tab_replace:
```

启动查看：
```bash
hexo server
```

## 通过hexo编写文章：md格式

创建文章post

```bash
hexo new "my first blog"
# 自动生成md文件：位置
myblog/source/_posts/my-first-blog.md
```
然后就是使用markdown格式编写这个文件，这里略过。

启动hexo server查看写的文章
```bash
hexo server
```

没有问题了，下面就是发布到github pages上

## 创建github pages

### 注册github账号，略过

### 创建github pages repo

比如我的github id是：wanghkkk

那么创建的repo名字为：wanghkkk.github.io

## 使用hexo git 将博客推送到上面创建的github pages repo上

安装所需插件：
```bash
# 进入博客目录
cd myblog
npm install hexo-deployer-git --save
```

配置博客：
```bash
vim myblog/_config.yml

# Deployment
## Docs: https://hexo.io/docs/deployment.html
deploy:
  type: git
  repo: https://github.com/wanghkkk/wanghkkk.github.io
  branch: master
  message: 
```

推送到github repo：

```bash
hexo deploy
# 需要手动输入用户名和密码
```

## 大功告成

打开网址（github repo 名字）查看一下吧：

https://wanghkkk.github.io