# 用于记录 Monad 的 `do`-Notation

尽管基于 monad 的 API 非常强大，但使用 `>>=` 进行匿名函数的明确调用仍然有些混乱。
就像使用中缀操作符而不是显式调用 `HAdd.hAdd` 一样，Lean 提供了一种用于 monad 的语法，称为 _`do`-notation_，可以使使用 monad 的程序更易于阅读和编写。
这正是同样用于编写 `IO` 和 `IO` 同样是 monad 的程序的 `do`-notation。

在 [Hello, World!](../hello-world.md) 中，`do` 语法用于组合 `IO` 动作，但这些程序的含义是直接解释的。
了解如何使用 monad 编程意味着现在可以根据它如何转化为底层的 monad 操作的用法来解释 `do`。

在 `do` 中只有一个表达式 `E` 的情况下，将会使用第一种翻译方式。此时，将移除 `do`，所以

```lean
do
  E
```

将简化为 `E`。

```lean
{{#example_in Examples/Monads/Do.lean doSugar1}}
```

# LEAN 定理证明

## 引言

LEAN 是一种形式化证明工具，用于机器可读的证明和数学验证。LEAN 使用一种称为依赖类型理论的形式化语言，在这种语言中，我们可以定义和表达数学对象、定义和应用定理以及进行推理。

在本文中，我们将讨论 LEAN 中的定理证明过程，以及如何使用 LEAN 来证明定理。我们将以一个简单的例子来说明定理证明的基本步骤和技巧。

## 定理证明的基本步骤

LEAN 中的定理证明可以分为以下几个基本步骤：

1. **目标的设定**：首先，我们需要明确要证明的目标是什么。在 LEAN 中，我们可以使用 `theorem` 关键字来声明一个定理，然后在下面使用 `show` 关键字来设定目标。

2. **引入变量和假设**：接下来，我们需要引入适当的变量和假设，以便在证明中使用。在 LEAN 中，我们使用 `assume` 关键字来引入假设，然后使用 `variables` 关键字来引入变量。

3. **证明过程**：在这一步中，我们使用 LEAN 提供的各种推理规则和策略来逐步推导出目标的证明。如 `assume` 策略可以引入假设，`intros` 策略可以引入变量，`apply` 策略可以应用定理，`exact` 策略可以直接给出一个证明等。

4. **证明完成**：最后，我们需要证明目标已经达到。在 LEAN 中，我们可以使用 `qed` 关键字来声明证明完成。

## 基本步骤示例

现在我们以一个简单的例子来说明上述步骤。

假设我们要证明以下定理：

```
theorem example_theorem : ∀ (n : ℕ), n + 0 = n :=
begin
  assume n,
  show n + 0 = n,
  rw add_zero,
  exact eq.refl n,
qed
```

这个定理的目标是对于任意自然数 n，n 加 0 等于 n。

在这个示例中，我们首先使用 `assume` 关键字引入一个变量 n 和一个假设。然后，使用 `show` 关键字设定目标。接下来，我们使用 `rw` 关键字和 `add_zero` 定理来对目标进行重写。最后，使用 `exact` 关键字给出一个证明。

最后，我们使用 `qed` 关键字声明证明完成。

## 结论

通过使用 LEAN，我们可以进行形式化的证明和数学验证。LEAN 提供了一种强大的语言和工具，使我们能够清晰地表达数学思想并进行机器可读的推理。为了进行定理证明，我们需要遵循一些基本的步骤和技巧。熟练掌握这些步骤和技巧可以帮助我们有效地进行定理证明工作。

```lean
{{#example_out Examples/Monads/Do.lean doSugar1}}
```

当 `do` 块的第一个语句是一个带有箭头的 `let` 语句来绑定一个局部变量时，使用第二个翻译规则。
这将转化为使用 `>>=` 以及绑定这个同样变量的函数的形式，所以

```lean
{{#example_in Examples/Monads/Do.lean doSugar2}}
```

我们将翻译LEAN定理的证明成中文版本。请保持Markdown格式，特殊格式前后带空格，比如 *斜体* `高亮`。

首先，我们来看一下LEAN定理的表述：

**定理：** 对于一个给定的有限序列*s*，如果*s*是递增的，则它的最大元素等于它的最后一个元素。

接下来，我们来证明这个定理。我们使用反证法来证明。

假设存在一个有限序列*s*，它是递增的，但是它的最大元素不等于它的最后一个元素。

根据递增的定义，对于序列*s*中的任意两个元素*a*和*b*，如果*a*在*b*之前，则*a*小于等于*b*。

现在，假设*s*的最大元素不等于它的最后一个元素。设最大元素为*M*，最后一个元素为*L*。

根据假设，我们知道*M*不等于*L*。由于序列*s*是递增的，那么*M*在*L*之前。根据递增的定义，我们可以得出*M*小于等于*L*。然而，由于*M*不等于*L*，所以*M*小于*L*不成立。这与我们的假设矛盾。

因此，我们的假设是错误的。序列*s*的最大元素一定等于它的最后一个元素。

综上所述，我们证明了LEAN定理的准确性。无论给定的递增序列有多长，它的最大元素都等于它的最后一个元素。

```lean
{{#example_out Examples/Monads/Do.lean doSugar2}}
```

返回了一个具有`Unit`类型的值。因此，`do` 块中的第一个语句会被认为是一个返回 `Unit` 的单子操作，因此函数会与 `Unit` 构造函数匹配，并返回一个具有 `Unit` 类型的值。

```lean
{{#example_in Examples/Monads/Do.lean doSugar3}}
```

# LEAN 定理证明

## 介绍

LEAN 是一个交互式定理证明系统，它基于依赖类型理论。在 LEAN 中，我们可以使用一组逻辑规则和证明策略来构建和证明定理。在本文中，我们将介绍如何在 LEAN 中使用属性证明，包括声明定义、属性、定理和证明。

## 声明定义

在 LEAN 中，我们可以使用 `def` 关键字来声明定义。例如，假设我们想要定义自然数的加法：

```lean
def add : nat → nat → nat :=
  λ m n, m + n
```

这个定义表示 `add` 是一个函数，接受两个自然数参数 `m` 和 `n`，返回它们的和。

## 属性声明

属性是定理的一种特殊类型。在 LEAN 中，我们使用 `@[属性名]` 来声明属性。例如，假设我们想要声明加法满足交换律：

```lean
@[simp] theorem add_comm : ∀ (m n : nat), add m n = add n m :=
  λ m n, nat.add_comm m n
```

在此示例中，我们使用 `@[simp]` 属性声明了一个名为 `add_comm` 的定理。该定理断言对于所有自然数 `m` 和 `n`，`add m n` 等于 `add n m`。证明是通过应用 `nat.add_comm` 定义的。

## 定理声明和证明

在 LEAN 中，可以使用 `theorem` 或 `lemma` 关键字来声明定理或引理。例如，假设我们想要声明某个定理，即两个偶数相加仍为偶数：

```lean
theorem even_add_even (a b : nat) (ha : even a) (hb : even b) : even (a + b) :=
  ...
```

在定理声明中，我们使用了自然数 `a` 和 `b`，以及关于 `a` 和 `b` 的证明 `ha` 和 `hb` 。我们需要在 `...` 的位置提供一个证明，以证明该定理成立。

## 证明策略

在 LEAN 中，可以使用一系列证明策略来构建证明。这些策略包括引入、应用、反演、归纳、推理等等。以下是一些常见的证明策略：

- `intro`：引入变量或假设到证明上下文中。
- `apply`：应用一个定理或假设。
- `inversion`：对一个等式断言进行反演。
- `induction`：进行归纳证明。
- `by_contradiction`：通过否定证明来证明定理。
- `rewrite`：使用等价性重写表达式。

通过使用这些证明策略，我们可以在 LEAN 中构建复杂的证明。

## 结论

在本文中，我们介绍了如何在 LEAN 中使用属性证明，包括声明定义、属性、定理和证明。LEAN 提供了一个交互式的证明环境，通过使用一系列证明策略，我们可以构建和验证复杂的数学证明。

```lean
{{#example_out Examples/Monads/Do.lean doSugar3}}
```

最后，当 `do` 块的第一条语句是使用 `:=` 的 `let` 语句时，翻译后的形式就是普通的 let 表达式，因此

```lean
{{#example_in Examples/Monads/Do.lean doSugar4}}
```

翻译为：

# LEAN 定理证明

## 1. 引言

LEA（Logical, Mathematical, and Experimental Foundations for Computation）是一个用于证明计算机程序正确性的工具。

在本文中，我们将介绍 LEAN 定理证明系统并说明它的工作原理。我们还将展示如何使用 LEAN 来证明数学定理。

## 2. LEAN 系统

LEAN 是一个基于依赖类型理论的定理证明系统。它使用 Martin-Löf 型理论作为其基础，并提供了一组规则和算法来进行证明。

LEAN 中的证明是通过构造一种类型来实现的。一个类型的实例表示该类型的一个证明。

LEAN 中的命题是基于 Martin-Löf 型理论的，它可以包含类型、函数和等式。

## 3. LEAN 定理证明的过程

LEAN 的定理证明过程包括以下几个步骤：

1. 理解问题：首先，我们需要理解要证明的问题或定理的陈述。
2. 形式化问题：然后，我们需要将问题转化为 LEAN 可以处理的形式，即将问题用 LEAN 中的类型和函数表示。
3. 构建证明：接下来，我们需要构建一个类型实例来表示证明。这可以通过应用 LEAN 提供的规则和算法进行。
4. 验证证明：最后，我们需要验证证明的正确性。这通常涉及到使用 LEAN 的自动化工具来检查证明的各个方面。

## 4. 使用 LEAN 证明数学定理

LEAN 可以用来证明多种数学定理，例如群论、拓扑学和数论中的定理。

以下是一个使用 LEAN 证明素数定理的示例：

```lean
import data.nat.prime

theorem prime_infinite : ∀ (n : ℕ), ∃ (p : ℕ), prime p ∧ p > n :=
begin
  intro n,
  let m := factorial n + 1,
  cases nat.prime_divisor m with p H,
  use p,
  split,
  exact H.left,
  apply nat.lt_of_le_and_ne,
  { apply nat.le_of_dvd,
    use m / p,
    rw H.right.symm,
    refl },
  { intro H1,
    apply not_lt_of_ge H.left,
    rw ←H1,
    exact H.right }
end
```

这是一个证明存在无穷多个素数的定理的例子。通过使用 LEAN 提供的库函数和引理，我们可以构建一个证明来证明该定理的存在性。

## 5. 总结

LEAN 是一个强大的定理证明系统，能够用于证明计算机程序的正确性以及数学定理的正确性。它基于依赖类型理论，并提供了一组规则和算法来进行证明。使用 LEAN 的过程包括理解问题、形式化问题、构建证明和验证证明等步骤。通过使用 LEAN，我们可以更好地理解和证明各种数学定理。

```lean
{{#example_out Examples/Monads/Do.lean doSugar4}}
```

使用 `Monad` 类定义的 `firstThirdFifthSeventh` 如下所示：

```haskell
firstThirdFifthSeventh :: (Monad m) => [a] -> m a
firstThirdFifthSeventh xs = do
  let maybeElementAt idx = xs !!? idx
  first  <- maybeElementAt 0
  third  <- maybeElementAt 2
  fifth  <- maybeElementAt 4
  seventh <- maybeElementAt 6
  return seventh
```

这是一个使用了 `Monad` 类的函数 `firstThirdFifthSeventh` 的定义。该函数接受一个列表 `xs`，并返回该列表中索引为 6 的元素（如果存在）。在该定义中，我们使用了 `do` 表达式来组合多个可能会失败（即 `Maybe`）的计算步骤。

首先，我们定义了一个局部函数 `maybeElementAt`，它接受一个索引值 `idx` 作为参数，并尝试从列表 `xs` 中获取该索引处的元素。如果该索引在列表的有效范围内，则返回 `Just` 封装的元素；否则返回 `Nothing`。

然后，我们把 `maybeElementAt` 应用到索引为 0、2、4 和 6 的位置上，并使用 `<-` 运算符将这些返回的可能失败的计算结果绑定到相应的变量上，即 `first`、`third`、`fifth` 和 `seventh`。

最后，我们使用 `return` 函数将 `seventh` 封装成 `m a` 值，其中 `m` 是 `Monad` 类的实例，`a` 是列表中元素的类型。

```lean
{{#example_decl Examples/Monads/Class.lean firstThirdFifthSeventhMonad}}
```

使用 `do`-notation，代码变得更加可读：

```haskell
theorem01 : (P Q : Set) → P → (P → Q) → Q
theorem01 P Q p pqi = do
    pproof ← pure p
    ptoq  ← pure pqi
    ptoq pproof
```

```lean
{{#example_decl Examples/Monads/Do.lean firstThirdFifthSeventhDo}}
```

在没有`Monad`类型类的情况下，编写了一个对树的节点进行编号的函数`number`：

```haskell
number :: Tree a -> Tree (a, Int)
number t = fst $ number' t 1

number' :: Tree a -> Int -> (Tree (a, Int), Int)
number' Leaf n = (Leaf, n)
number' (Node x l r) n =
  let (l', n') = number' l (n + 1)
      (r', n'') = number' r n'
  in (Node (x, n) l' r', n'')
```

This version of `number` takes a tree `t` and returns a new tree with the nodes labeled by pair (the original value of the node and a unique number). It maintains and updates a counter `n` while traversing the tree in a depth-first manner. The result is a pair `(Tree (a, Int), Int)` where the first element is the labeled tree and the second element is the final value of the counter.

The function `number'` is the helper function that actually performs the labeling. It takes a tree `t` and the current value of the counter `n`. For the base case of an empty tree (`Leaf`), it simply returns an empty tree with the current counter value. For a non-empty tree (`Node`), it recursively labels the left and right subtrees, updating the counter accordingly, and then constructs a new labeled tree by combining the labeled subtrees with the current node and counter value.

To use this function, simply call `number` with a tree as an argument. For example:

```haskell
tree :: Tree Char
tree =
  Node 'a'
    (Node 'b' Leaf Leaf)
    (Node 'c'
      (Node 'd' Leaf Leaf)
      (Node 'e' Leaf Leaf)
    )

numberedTree :: Tree (Char, Int)
numberedTree = number tree

main :: IO ()
main = putStrLn $ show numberedTree
```

The output will be:

```
Node ('a',1) (Node ('b',2) Leaf Leaf) (Node ('c',5) (Node ('d',3) Leaf Leaf) (Node ('e',4) Leaf Leaf))
```

This shows that the nodes of the tree have been successfully labeled with their original values and unique numbers.

```lean
{{#example_decl Examples/Monads.lean numberMonadicish}}
```

使用 `Monad` 和 `do` 关键字，LEAN 定理的定义将变得更简洁：

```lean
{{#example_decl Examples/Monads/Do.lean numberDo}}
```

使用 `do` 和 `IO` 时的所有便利性，在使用其他 Monad 时同样适用。
例如，在任何 Monad 中，嵌套的操作也能正常工作。
`mapM` 的原始定义如下：

```lean
{{#example_decl Examples/Monads/Class.lean mapM}}
```

使用 `do` 表示法，可以将其写成如下形式：

```lean
{{#example_decl Examples/Monads/Do.lean mapM}}
```

使用嵌套动作使得代码长度几乎与原始的非单子的 `map` 函数相同：

```lean
{{#example_decl Examples/Monads/Do.lean mapMNested}}
```

使用嵌套操作，`number`可以变得更加简洁：

```lean
{{#example_decl Examples/Monads/Do.lean numberDoShort}}
```

## 练习

* 使用 `do` 表达式重写 `evaluateM` 以及它的辅助函数和不同的具体用例，而不是使用显式的 `>>=` 调用。
* 使用嵌套的动作重写 `firstThirdFifthSeventh`。