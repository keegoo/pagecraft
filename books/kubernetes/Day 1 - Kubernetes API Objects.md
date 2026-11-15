---
title: "Day 1 - Kubernetes API Objects"
author: "CY"
date: "2026-11-15"
lang: "en"
---

# 第一阶段 · Day 1
# Kubernetes API Objects

**主题：理解 Kubernetes 世界里的「对象」**

## 本课目标

今天先不写 Controller，也不学习 Rust 语法。

我们只建立一个基础认知：Kubernetes 是如何用 API Objects 描述和保存集群中的各种资源的。

理解这一点，后面学习 CRD、Watch 和 Reconciliation 才有共同的基础。

学完后，你应该能够：

- 解释 Kubernetes API Object 是什么。
- 区分 Resource 和 Object 这两个相关但不同的概念。
- 看懂 Kubernetes YAML 中的 apiVersion、kind、metadata、spec 和 status。

---

## 1. 先从一个问题开始：Kubernetes 管理的是什么？

假设你希望 Kubernetes 运行一个 Nginx 服务，并且希望它始终保持 3 个副本。

你不需要告诉 Kubernetes 每一步应该怎样执行，例如先创建哪个容器、再启动哪个进程。

你只需要向 Kubernetes 描述你希望看到的结果。

这份描述会通过 Kubernetes API 提交给集群。Kubernetes 会把它理解为一个需要管理的对象，并由相关组件持续推动集群接近你声明的状态。

因此，可以先把 Kubernetes API Object 理解为：

**通过 Kubernetes API 表达、保存和管理的一份结构化资源描述。**

## 2. 什么是 API Object？

在 Kubernetes 中，Pod、Deployment、Service、ConfigMap、Namespace 等，都可以通过 API Objects 来表示。

它们不是随意的一段 YAML 文本，而是有明确类型和字段结构的数据。

例如：

- Deployment 对象会描述应用的副本数、Pod 模板以及选择哪些 Pod。
- Service 对象则会描述如何通过稳定的网络入口访问一组 Pod。

不同类型的对象，表达的是不同种类的集群意图或状态。

可以把它想象成一张标准化表单：

- 表单类型：这是什么对象？例如 Deployment。
- 基本信息：它叫什么名字，属于哪个 Namespace？
- 期望内容：你希望它是什么样子？
- 当前状态：集群目前观察到了什么？

## 3. Resource 和 Object 有什么区别？

这两个词经常一起出现，但侧重点不同。

**Resource**

通常指 Kubernetes API 中的一种资源类型或操作入口，例如 deployments、pods、services。

它描述「可以管理哪一类东西」。

**Object**

通常指这种资源类型的一个具体实例，例如名为 web 的 Deployment。

它描述「这一类东西中的某一个对象」。

类比一下：

Resource 像「汽车」这个类别；Object 像「停车场里那辆车」。

Deployment 是一种 Resource，而 default Namespace 中名为 web 的 Deployment，就是一个具体的 Object。

在日常交流中，人们有时会比较宽泛地使用 resource 或 object。今天先掌握这个基本区别即可，不必把术语边界记得过于死板。

## 4. 认识一个 Kubernetes YAML 对象

下面是一个简化的 Deployment 声明。

重点不是记住每个字段，而是看懂它的整体结构：

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
  namespace: default
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
        - name: nginx
          image: nginx:latest
```

## 5. 五个重要字段

**apiVersion**

这个对象使用哪个 Kubernetes API 版本，例如 apps/v1。

**kind**

对象的类型，这里是 Deployment。

**metadata**

对象的身份和管理信息，常见内容包括：

- name
- namespace
- labels
- annotations

**spec**

对象的期望状态，也就是使用者希望 Kubernetes 维护成什么样子。

**status**

对象的当前状态，由 Kubernetes 中负责管理它的组件更新，用来反映实际观察到的情况。

一个很重要的初步认识：

**spec 通常表达期望，status 通常反映观察到的现实。**

后面学习 Reconciliation 时，我们会反复回到这两个字段。

## 6. Object 的身份：名字还不够吗？

很多 Kubernetes 对象是 Namespace 范围内的。

也就是说，两个不同 Namespace 中可以各自存在一个名为 web 的 Deployment。

所以，对于这类对象，通常需要结合 API 资源类型、Namespace 和 Name 才能明确定位一个对象。

例如：

- default Namespace 中的 Deployment/web。
- staging Namespace 中的 Deployment/web。

它们是两个不同对象。

另一方面，像 Node、Namespace 这样的集群级资源，本身不属于某个普通 Namespace。

## 7. 为什么 Controller 必须理解 API Objects？

Controller 的工作对象就是 Kubernetes API Objects。

它通过 API 读取对象，观察对象的变化，再根据对象表达的期望状态采取行动。

例如，一个负责 MyApp 的 Controller 可能会读取 MyApp 对象，看到 spec 中要求 3 个副本。

然后读取或检查对应 Deployment 的状态。

如果实际副本数不是 3，它就会尝试修正 Deployment。

所以，Controller 并不是直接管理抽象的「应用愿望」，而是通过 Kubernetes API 中的对象来理解和操作这些愿望。

---

## 今日总结

今天最重要的是记住以下六点：

1. Kubernetes API Object 是通过 Kubernetes API 表达和管理的结构化对象。
2. Resource 偏向资源类型；Object 偏向某个具体实例。
3. YAML 中的 apiVersion 和 kind 说明对象类型与 API 版本。
4. metadata 描述对象身份及附加信息。
5. spec 表达期望状态，status 反映观察到的当前状态。
6. Controller 通过读取和操作这些对象来完成自己的工作。

## 睡前回想

不需要查资料，也不需要写代码。

试着在脑海里回答三个问题：

1. Deployment 是 Resource 还是一个具体 Object？
2. spec 和 status 分别表达什么？
3. 为什么 Controller 需要通过 Kubernetes API Objects 工作？

**下一课预告：**

我们会进一步认识 CRD 和 Custom Resources，看看 Kubernetes 如何允许开发者定义自己的 API 对象。
