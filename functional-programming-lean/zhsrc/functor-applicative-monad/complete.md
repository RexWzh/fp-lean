## 完整定义

现在，已经介绍了所有相关的语言特性，本节将描述 `Functor`、`Applicative` 和 `Monad` 在 Lean 标准库中的完整、准确定义。
为了便于理解，没有省略任何细节。

## Functor

`Functor` 类的完整定义利用了宇宙多态和默认方法实现：

```lean
{{#example_decl Examples/FunctorApplicativeMonad/ActualDefs.lean HonestFunctor}}
```

在这个定义中，`Function.comp` 是函数的复合，通常用 `∘` 运算符表示。
`Function.const` 是 _常数函数_，它是一个忽略其第二个参数的二元函数。
将此函数应用于一个参数时，会生成一个始终返回同一值的函数，这在 API 需要函数但程序不需要计算不同参数的结果时非常有用。
`Function.const` 的简单版本可以如下编写：

```lean
{{#example_decl Examples/FunctorApplicativeMonad/ActualDefs.lean simpleConst}}
```

将 LEAN 定理证明的文章翻译为中文：

使用 LEAN 定理验证 `List.map` 的一个参数作为函数参数，可以展示它的实用性：

```lean
{{#example_in Examples/FunctorApplicativeMonad/ActualDefs.lean mapConst}}
```



```output info
{{#example_out Examples/FunctorApplicativeMonad/ActualDefs.lean mapConst}}
```

实际函数的签名如下：

```output info
{{#example_out Examples/FunctorApplicativeMonad/ActualDefs.lean FunctionConstType}}
```

在这里，类型参数 `β` 是一个显式的参数，所以 `Functor.mapConst` 的默认定义提供了一个 `_` 参数，它指示 Lean 找到一个唯一的类型传递给 `Function.const`，使得程序能够通过类型检查。
`{{#example_in Examples/FunctorApplicativeMonad/ActualDefs.lean unfoldCompConst}}` 等价于 `{{#example_out Examples/FunctorApplicativeMonad/ActualDefs.lean unfoldCompConst}}`。

`Functor` 类型类的宇宙是 `u+1` 和 `v` 中较大的一个。
在这里，`u` 是作为参数传递给 `f` 的宇宙的级别，而 `v` 是 `f` 返回的宇宙。
为了看到实现 `Functor` 类型类的结构必须在一个比 `u` 更大的宇宙中的原因，从一个简化的类定义开始：

```lean
{{#example_decl Examples/FunctorApplicativeMonad/ActualDefs.lean FunctorSimplified}}
```

这个类型类的结构类型与以下归纳类型等价：

```lean
{{#example_decl Examples/FunctorApplicativeMonad/ActualDefs.lean FunctorDatatype}}
```

`map` 方法的实现作为参数传递给 `Functor.mk` 的方法，其中包含一个接受 `Type u` 中的两种类型作为参数的函数。
这意味着函数本身的类型在 `Type (u+1)`，所以 `Functor` 必须至少在 `u+1` 的层级上。
同样的，函数的其他参数的类型是通过应用 `f` 构建的，所以它必须至少具有 `v` 的层级。
本节中所有的类型类都共享这个属性。

## Applicative

实际上，`Applicative` 类型类是由许多包含一些相关方法的较小的类构建而成的。
首先是 `Pure` 和 `Seq`，它们分别包含 `pure` 和 `seq` 方法：

```lean
{{#example_decl Examples/FunctorApplicativeMonad/ActualDefs.lean Pure}}

{{#example_decl Examples/FunctorApplicativeMonad/ActualDefs.lean Seq}}
```

除此之外，`Applicative` 还依赖于 `SeqRight` 和一个类似的 `SeqLeft` 类：

```lean
{{#example_decl Examples/FunctorApplicativeMonad/ActualDefs.lean SeqRight}}

{{#example_decl Examples/FunctorApplicativeMonad/ActualDefs.lean SeqLeft}}
```

`seqRight` 函数是在[替代方案和验证](alternative.md)部分引入的，从效果的角度来看最容易理解。
`{{#example_in Examples/FunctorApplicativeMonad.lean seqRightSugar}}`，它被展开为 `{{#example_out Examples/FunctorApplicativeMonad.lean seqRightSugar}}`，可以理解为首先执行 `E1`，然后执行 `E2`，只返回 `E2` 的结果。
来自 `E1` 的效果可能导致 `E2` 不被运行，或者被运行多次。
事实上，如果 `f` 有一个 `Monad` 实例，那么 `E1 *> E2` 等价于 `do let _ ← E1; E2`，但是 `seqRight` 可以与像 `Validate` 这样不是单子的类型一起使用。

它的近似功能 `seqLeft` 非常相似，只是返回最左边表达式的值。
`{{#example_in Examples/FunctorApplicativeMonad/ActualDefs.lean seqLeftSugar}}` 被展开为 `{{#example_out Examples/FunctorApplicativeMonad/ActualDefs.lean seqLeftSugar}}`。
`{{#example_in Examples/FunctorApplicativeMonad/ActualDefs.lean seqLeftType}}` 的类型是 `{{#example_out Examples/FunctorApplicativeMonad/ActualDefs.lean seqLeftType}}`，与 `seqRight` 的类型相同，只是返回了 `f α`。
`{{#example_in Examples/FunctorApplicativeMonad/ActualDefs.lean seqLeftSugar}}` 可以理解为一个程序，首先执行 `E1`，然后执行 `E2`，返回 `E1` 的原始结果。
如果 `f` 有一个 `Monad` 实例，那么 `E1 <* E2` 等价于 `do let x ← E1; _ ← E2; pure x`。
一般来说，`seqLeft` 对于在验证或解析器类似的工作流中对一个值指定额外条件而不改变其值很有用。

`Applicative` 的定义扩展了所有这些类，以及 `Functor` 类：

```lean
{{#example_decl Examples/FunctorApplicativeMonad/ActualDefs.lean Applicative}}
```

一种完整的`Applicative`的定义只需要对`pure`和`seq`进行定义。
这是因为对于`Functor`、`SeqLeft`和`SeqRight`的所有方法已经有了默认定义。
`Functor`的`mapConst`方法在`Functor.map`的术语中有自己的默认实现。
这些默认实现只能用行为上等价但更高效的新函数来覆盖。
默认实现应被视为正确性的规范以及自动生成的代码。

`seqLeft`的默认实现非常简洁。
用一些语法糖或者定义替换其中的一些名称可以提供另一种视角，所以：

```lean
{{#example_in Examples/FunctorApplicativeMonad/ActualDefs.lean unfoldMapConstSeqLeft}}
```

# LEAN 定理证明

LEAN（Logical Engine for Analyzing Theorems）是一种用于形式化证明的计算机程序。它的设计目标是能够自动证明和验证数学定理和推理，并提供可读性强的证明输出。

## 1. 引言

LEAN 对定理证明使用的是构造性逻辑和依赖类型理论。这种理论可以表示并操作包括函数和类型在内的所有数学结构。

本文将以一个简单的例子来解释 LEAN 定理证明的基本思想和步骤。我们将使用 LEAN 来证明 "任意两个真命题可以通过逻辑 '否定' 运算进行等价转换"。

## 2. LEAN 证明步骤

### 2.1 定义命题

首先，我们需要定义命题的类型。在 LEAN 中，命题可以是任意类型的成员。

```
inductive Prop : Type
| true : Prop
| false : Prop
```

上述代码定义了一个类型 `Prop`，该类型有两个成员：`true` 和 `false`。这两个成员分别代表真命题和假命题。

### 2.2 定义 '否定' 运算

接下来，我们定义一个函数 `not`，用于执行逻辑 '否定' 运算。

```
def not (p : Prop) : Prop :=
  match p with
  | Prop.true := Prop.false
  | Prop.false := Prop.true
  end
```

上述代码定义了一个函数 `not`，它接受一个命题 `p` 作为参数，并返回对 `p` 进行 '否定' 运算后的结果。

### 2.3 定义等价关系

我们需要定义命题之间的等价关系。在 LEAN 中，我们可以使用函数来定义等价关系。

```
def equiv (p q : Prop) : Prop :=
  (not p) = q
```

上述代码定义了一个函数 `equiv`，它接受两个命题 `p` 和 `q` 作为参数，并返回一个新的命题，该命题表示了在对 `p` 进行 '否定' 运算后得到的结果与 `q` 相等。

### 2.4 定义定理

最后，我们定义了一个定理 `not_not_equiv`，它陈述了通过对一个命题进行两次 '否定' 运算可以得到原命题。

```
theorem not_not_equiv (p : Prop) : equiv (not (not p)) p :=
  eq.refl (not (not p))
```

上述代码定义了一个定理 `not_not_equiv`，它使用了等式反射规则 `eq.refl` 来证明了 `not (not p)` 与 `p` 是等价的。

## 3. 结论

通过 LEAN，我们成功证明了任意两个真命题之间可以通过逻辑 '否定' 运算进行等价转换。LEAN 的强大能力和易于理解的证明输出使得它成为一个优秀的定理证明工具。

```lean
{{#example_out Examples/FunctorApplicativeMonad/ActualDefs.lean unfoldMapConstSeqLeft}}
```

如何理解 `(fun x _ => x) <$> a`？
在这里，`a` 的类型是 `f α`，而 `f` 是一个函子。
如果 `f` 是 `List` 类型，那么 `{{#example_in Examples/FunctorApplicativeMonad/ActualDefs.lean mapConstList}}` 的求值结果为 `{{#example_out Examples/FunctorApplicativeMonad/ActualDefs.lean mapConstList}}`。
如果 `f` 是 `Option` 类型，那么 `{{#example_in Examples/FunctorApplicativeMonad/ActualDefs.lean mapConstOption}}` 的求值结果为 `{{#example_out Examples/FunctorApplicativeMonad/ActualDefs.lean mapConstOption}}`。
在每种情况下，函子中的值被替换为返回原始值的函数，忽略它们的参数。
与 `seq` 结合使用时，这个函数会丢弃 `seq` 的第二个参数的值。

`seqRight` 的默认实现与此类似，只是 `const` 多了一个参数 `id`。
可以类似地理解这个定义，首先引入一些标准的语法糖，然后用定义来替换一些名称。

```lean
{{#example_eval Examples/FunctorApplicativeMonad/ActualDefs.lean unfoldMapConstSeqRight}}
```

`(fun _ x => x) <$> a` 的意思是什么？
一次又一次，例子都很有用。

`{{#example_in Examples/FunctorApplicativeMonad/ActualDefs.lean mapConstIdList}}` 等同于 `{{#example_out Examples/FunctorApplicativeMonad/ActualDefs.lean mapConstIdList}}`，
而 `{{#example_in Examples/FunctorApplicativeMonad/ActualDefs.lean mapConstIdOption}}` 等同于 `{{#example_out Examples/FunctorApplicativeMonad/ActualDefs.lean mapConstIdOption}}`。

换句话说，`(fun _ x => x) <$> a` 保留了 `a` 的整体形状，但每个值被替换为恒等函数。

从效果的角度来看，当使用 `seq` 时，`a` 的副作用会发生，但值会被抛弃。

```lean
{{#example_decl Examples/FunctorApplicativeMonad/ActualDefs.lean Bind}}
```

`Monad` 通过扩展 `Applicative` 和 `Bind` 实现。

The `Applicative` typeclass represents values that can be applied to functions of arbitrary arity. It provides the `pure` function which wraps a value in a minimal context and the `ap` function which applies a wrapped function to a wrapped value. The `pure` function is analogous to `return` in some other programming languages, while the `ap` function is analogous to function application.

`Applicative` 类型类表示可以应用于任意个参数函数的值。它提供了 `pure` 函数，用于将一个值包装在最小的上下文中，并提供了 `ap` 函数，用于将一个包装的函数应用于一个包装的值。`pure` 函数类似于其他一些编程语言中的 `return`，而 `ap` 函数类似于函数应用。

The `Bind` typeclass extends `Applicative` with the `bind` function. The `bind` function, also known as `flatMap` or `>>=`, takes a value with a context and a function that takes a plain value and returns a value with a context. It applies the function to the plain value, and then "flattens" the resulting nested context into a single context.

`Bind` 类型类通过 `bind` 函数扩展了 `Applicative`。`bind` 函数（也被称为 `flatMap` 或者 `>>=`）接受一个带有上下文的值和一个接受普通值并返回带有上下文的值的函数。它将函数应用于普通值，然后将得到的嵌套上下文“展平”为单个上下文。

The `Monad` typeclass combines the functionality of `Applicative` and `Bind`. It provides the `pure` function for creating a minimal context, the `ap` function for applying a wrapped function to a wrapped value, and the `bind` function for sequentially composing functions that return wrapped values.

`Monad` 类型类结合了 `Applicative` 和 `Bind` 的功能。它提供了 `pure` 函数用于创建最小的上下文，`ap` 函数用于将一个包装的函数应用于一个包装的值，以及 `bind` 函数用于顺序组合返回包装值的函数。

The `Monad` laws are a set of rules that any implementation of the `Monad` typeclass must follow. These laws ensure that the composition of `pure`, `ap`, and `bind` is consistent and behaves as expected. The three laws are as follows:

`Monad` 定律是任何 `Monad` 类型类的实现必须遵循的一组规则。这些定律确保了 `pure`、`ap` 和 `bind` 的组合是一致的并且表现如预期。这三个定律如下：

1. Left identity: `pure a >>= f` is equivalent to `f a`. This law ensures that using `pure` followed by `bind` has the same effect as simply applying the function `f` to the value `a`.

   左单位元：`pure a >>= f` 等价于 `f a`。这个定律确保使用 `pure` 后跟 `bind` 与仅将函数 `f` 应用于值 `a` 具有相同的效果。

2. Right identity: `m >>= pure` is equivalent to `m`. This law ensures that using `bind` with the `pure` function has no effect and simply returns the original value.

   右单位元：`m >>= pure` 等价于 `m`。这个定律确保使用 `bind` 和 `pure` 函数没有效果，只是返回原始值。

3. Associativity: `(m >>= f) >>= g` is equivalent to `m >>= (\x -> f x >>= g)`. This law ensures that the order of applying functions with `bind` does not matter, as long as the composition of functions remains the same.

   结合律：`(m >>= f) >>= g` 等价于 `m >>= (\x -> f x >>= g)`。这个定律确保使用 `bind` 对函数应用的顺序不重要，只要函数的组合保持不变即可。

By following these laws, implementations of the `Monad` typeclass can be guaranteed to behave consistently and accurately. The `Monad` typeclass provides a powerful tool for structuring computations with a context and expressing sequential composition of functions.

```lean
{{#example_decl Examples/FunctorApplicativeMonad/ActualDefs.lean Monad}}
```

追踪从整个继承层次结构中收集到的继承方法和默认方法可知，`Monad` 实例只要求实现 `bind` 和 `pure` 。
换句话说，`Monad` 实例自动提供了 `seq`、 `seqLeft`、 `seqRight`、 `map` 和 `mapConst` 的实现。
从 API 边界的角度来看，任何具有 `Monad` 实例的类型都会得到 `Bind`、 `Pure`、 `Seq`、 `Functor`、 `SeqLeft` 和 `SeqRight` 实例。

## 练习

 1. 通过使用 `Option` 和 `Except` 这样的例子，理解 `Monad` 中 `map`、 `seq`、 `seqLeft` 和 `seqRight` 的默认实现。换句话说，将它们的定义替换为 `bind` 和 `pure` 的默认定义，并简化它们以恢复手动编写的 `map`、 `seq`、 `seqLeft` 和 `seqRight` 版本。
 2. 在纸上或文本文件中，通过自己证明 `map` 和 `seq` 的默认实现满足 `Functor` 和 `Applicative` 的契约。在这个论证中，你可以使用 `Monad` 契约的规则和普通的表达式求值。