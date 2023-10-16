# 后续步骤

本书介绍了Lean中函数式编程的基础知识，包括少量交互式定理证明。
使用依赖类型的函数式语言（如Lean）是一个深入的主题，并且有很多内容可以讲述。
根据你的兴趣，以下资源可能对学习Lean 4有用。

## 学习Lean

以下资源描述了Lean 4本身：

* [在Lean 4中进行定理证明](https://leanprover.github.io/theorem_proving_in_lean4/)是一个使用Lean编写证明的教程。
* [Lean 4手册](https://leanprover.github.io/lean4/doc/)为语言及其特性提供了参考。在撰写本文时，它仍然不完整，但它比本书更详细地描述了Lean的很多方面。
* [如何用Lean证明](https://djvelleman.github.io/HTPIwL/)是一本基于Lean的辅助教材，配合深受好评的教材[_如何证明它_](https://www.cambridge.org/highereducation/books/how-to-prove-it/6D2965D625C6836CD4A785A2C843B3DA#overview)，介绍如何撰写纸笔数学证明。
* [Lean 4的元编程](https://github.com/arthurpaulino/lean4-metaprogramming-book)提供了Lean扩展机制的概述，从中缀运算符和符号到宏、自定义策略和完整的自定义嵌入式语言。
* [在Lean中的函数式编程](https://leanprover.github.io/functional_programming_in_lean/)可能会对喜欢递归笑话的读者产生兴趣。

然而，继续学习Lean的最佳方式是开始阅读和编写代码，在遇到困难时咨询文档。
另外，[Lean Zulip](https://leanprover.zulipchat.com/)是一个优秀的地方，可以与其他Lean用户交流，寻求帮助并帮助他人。

## 标准库

Lean本身只包含一个相当简单的库。
Lean是自托管的，包含的代码仅足以实现Lean本身。
对于许多应用程序，需要一个更大的标准库。

[std4](https://github.com/leanprover/std4)是一个正在进行中的标准库，包括许多数据结构、策略、类型类实例和超出Lean编译器范围的函数。
要使用 `std4`，第一步是在其历史记录中找到一个与你使用的 Lean 4 版本兼容的提交（也就是，其中的 `lean-toolchain` 文件与你的项目中的文件相匹配）。
然后，在你的 `lakefile.lean` 的顶层添加以下内容，其中 `COMMIT_HASH` 是相应的版本：

```lean
require std from git
  "https://github.com/leanprover/std4/" @ "COMMIT_HASH"
```

## 在 Lean 中进行数学

大部分面向数学家的资源都是针对 Lean 3 编写的。
[社区网站](https://leanprover-community.github.io/learn.html)上提供了广泛的选择。
要开始在 Lean 4 中进行数学研究，最简单的方法可能是参与将数学库 `mathlib` 从 Lean 3 迁移到 Lean 4 的过程。
请参阅 [`mathlib4` 说明](https://github.com/leanprover-community/mathlib4) 以获取更多信息。

## 在计算机科学中使用依赖类型

Coq 是一种与 Lean 有很多共同之处的语言。
对于计算机科学家来说，[《软件基础》](https://softwarefoundations.cis.upenn.edu/)系列交互式教材提供了一个优秀的介绍，介绍了 Coq 在计算机科学中的应用。
Lean 和 Coq 的基本思想非常相似，所以在这两个系统之间的技能可以很容易地转移。

## 使用依赖类型进行编程

对于对使用索引族和依赖类型构建程序感兴趣的程序员，Edwin Brady 的《[Type Driven Development with Idris](https://www.manning.com/books/type-driven-development-with-idris)》 提供了一个很好的入门介绍。
像 Coq 一样，Idris 是 Lean 的亲戚，不过它缺少策略（tactics）。

## 理解依赖类型

《[The Little Typer](https://thelittletyper.com/)》是为那些尚未正式学习逻辑或编程语言理论，但希望建立对依赖类型理论核心思想的理解的程序员编写的一本书。
虽然以上所有资源都致力于尽可能实用，但《The Little Typer》从头开始，仅使用编程概念构建了非常基础的依赖类型理论。
注意：《Functional Programming in Lean》的作者也是《The Little Typer》的作者之一。