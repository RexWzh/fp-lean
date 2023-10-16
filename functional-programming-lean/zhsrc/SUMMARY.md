# Lean 中的函数式编程

[Lean 中的函数式编程](./title.md)
[简介](./introduction.md)
[致谢](./acknowledgments.md)

- [了解 Lean](./getting-to-know.md)
  - [求值表达式](./getting-to-know/evaluating.md)
  - [类型](./getting-to-know/types.md)
  - [函数和定义](./getting-to-know/functions-and-definitions.md)
  - [结构体](./getting-to-know/structures.md)
  - [数据类型、模式和递归](./getting-to-know/datatypes-and-patterns.md)
  - [多态](./getting-to-know/polymorphism.md)
  - [额外的便利功能](./getting-to-know/conveniences.md)
  - [总结](./getting-to-know/summary.md)
- [你好，世界！](./hello-world.md)
  - [运行程序](./hello-world/running-a-program.md)
  - [逐步进行](./hello-world/step-by-step.md)
  - [开始一个项目](./hello-world/starting-a-project.md)
  - [实例：`cat`](./hello-world/cat.md)
  - [额外的便利功能](./hello-world/conveniences.md)
  - [总结](./hello-world/summary.md)
- [插曲：命题、证明和索引](props-proofs-indexing.md)
- [重载和类型类](type-classes.md)
  - [正数](type-classes/pos.md)
  - [类型类和多态](type-classes/polymorphism.md)
  - [控制实例搜索](type-classes/out-params.md)
  - [数组和索引](type-classes/indexing.md)
  - [标准类](type-classes/standard-classes.md)
  - [强制转换](type-classes/coercion.md)
  - [额外的便利功能](type-classes/conveniences.md)
  - [总结](type-classes/summary.md)
- [Monad](./monads.md)
  - [Monad 类型类](./monads/class.md)
  - [实例：Monad 中的算术](./monads/arithmetic.md)
  - [Monad 中的 `do` 表达式](./monads/do.md)
- [IO Monad（IO单子）](./monads/io.md)
  - [附加便利功能](monads/conveniences.md)
  - [摘要](monads/summary.md)
- [函子、应用函子和单子](functor-applicative-monad.md)
  - [结构和继承](functor-applicative-monad/inheritance.md)
  - [应用函子](functor-applicative-monad/applicative.md)
  - [应用函子的合约](functor-applicative-monad/applicative-contract.md)
  - [替代方案](functor-applicative-monad/alternative.md)
  - [宇宙](functor-applicative-monad/universes.md)
  - [完整定义](functor-applicative-monad/complete.md)
  - [摘要](functor-applicative-monad/summary.md)
- [单子变换器](monad-transformers.md)
  - [结合 IO 和 Reader](monad-transformers/reader-io.md)
  - [一个单子构造工具包](monad-transformers/transformers.md)
  - [单子变换器的顺序](monad-transformers/order.md)
  - [更多 `do` 特性](monad-transformers/do.md)
  - [附加便利功能](monad-transformers/conveniences.md)
  - [摘要](monad-transformers/summary.md)
- [使用依赖类型进行编程](dependent-types.md)
  - [索引族](dependent-types/indexed-families.md)
  - [宇宙设计模式](dependent-types/universe-pattern.md)
  - [实例：类型化查询](dependent-types/typed-queries.md)
  - [指数、参数和宇宙级别](dependent-types/indices-parameters-universes.md)
  - [使用依赖类型进行编程的陷阱](dependent-types/pitfalls.md)
  - [摘要](./dependent-types/summary.md)
- [插曲：策略、归纳和证明](./tactics-induction-proofs.md)
- [编程、证明和性能](programs-proofs.md)
  - [尾递归](programs-proofs/tail-recursion.md)
  - [证明等价性](programs-proofs/tail-recursion-proofs.md)
  - [数组和终止性](programs-proofs/arrays-termination.md)
## LEAN 定理证明

LENA 是一个交互式的证明辅助系统，它使用了数学上严谨的表达形式来进行定理证明。它采用了依赖类型理论（Dependent Type Theory）作为其数学基础，并在这个理论的基础上构建了一套逻辑系统。

以 [More Inequalities](programs-proofs/inequalities.md) 为例，这篇文章介绍了 LENA 中关于不等式的证明方法。文章首先讨论了数值的比较和不等式的定义，然后介绍了一些基本的不等式性质，如传递性、对称性和等价关系。接着，文章展示了如何使用 LENA 来证明不等式的一些常见技巧，如使用乘法、加法和除法等。最后，文章总结了在证明不等式过程中可能遇到的一些困难，并给出了一些解决方法。

在 [Safe Array Indices](programs-proofs/fin.md) 中，文章介绍了 LENA 中关于数组索引的安全性的证明。它首先定义了数组的索引范围，并介绍了数组访问的语法。然后，文章讨论了在操作数组时可能遇到的索引越界问题，并给出了一些解决方案，如使用 "fin" 类型限制数组索引的范围。最后，文章展示了如何使用 LENA 来证明关于数组索引的一些定理，如数组长度的保持和数组索引的唯一性。

在 [Insertion Sort and Array Mutation](programs-proofs/insertion-sort.md) 中，文章介绍了使用 LENA 来证明插入排序算法的正确性。文章首先介绍了插入排序算法的工作原理和实现方式，然后使用 LENA 定义了数组的排序规则。接着，文章使用归纳法证明了插入排序算法的正确性，即在排序后的数组中，每个元素的值总是比它前面的元素小。最后，文章讨论了插入排序算法的一些优化方法，并给出了一些证明的思路。

在 [Special Types](programs-proofs/special-types.md) 中，文章讨论了 LENA 中的一些特殊类型和属性。文章介绍了递增函数和递减函数，并讨论了它们的一些基本性质和用法。接着，文章介绍了积类型和和类型，并讨论了它们的一些特点和应用场景。最后，文章提出了互补类型和等价类型，并讨论了它们的一些重要性质和应用。

最后，在 [Summary](programs-proofs/summary.md) 中，文章对前面介绍的内容进行了总结，并给出了一些进一步学习的建议和参考资料。

接下来的步骤请参考 [Next Steps](next-steps.md)。