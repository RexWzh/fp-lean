# 安全的数组索引

对于 `Array` 和 `Nat` 的 `GetElem` 实例，需要提供一个证明，证明所提供的 `Nat` 比数组的大小小。
在实践中，这些证明通常会与索引一起传递给函数。
与单独传递索引和证明相比，可以使用一个称为 `Fin` 的类型将索引和证明捆绑到一个值中。
这样可以使代码更容易阅读。
此外，许多数组上的内置操作都将其索引参数作为 `Fin` 而不是作为 `Nat`，因此使用这些内置操作需要了解如何使用 `Fin`。

类型 `Fin n` 表示严格小于 `n` 的数字。
换句话说，`Fin 3` 描述了 `0`、 `1` 和 `2`，而 `Fin 0` 没有任何值。
`Fin` 的定义类似于 `Subtype`，因为 `Fin n` 是一个结构，包含一个 `Nat` 和一个证明它小于 `n` 的证据：

```lean
{{#example_decl Examples/ProgramsProofs/Fin.lean Fin}}
```

Lean 包括了 `ToString` 和 `OfNat` 两个实例，使得 `Fin` 类型的值可以方便地被用作数字。
换句话说，`{{#example_in Examples/ProgramsProofs/Fin.lean fiveFinEight}}` 的输出是 `{{#example_out Examples/ProgramsProofs/Fin.lean fiveFinEight}}`，而不是类似 `{val := 5, isLt := _}` 这样的值。

对于超出边界的情况，`Fin` 类型的 `OfNat` 实例并不会发生错误，而是返回边界值的模运算结果。
这意味着 `{{#example_in Examples/ProgramsProofs/Fin.lean finOverflow}}` 的结果是 `{{#example_out Examples/ProgramsProofs/Fin.lean finOverflow}}`，而不是编译时错误。

在返回类型中，以找到的索引方式返回的 `Fin` 值会更清晰地展示它与所在数据结构的联系。
在[上一节](./arrays-termination.md#proving-termination)中的`Array.find`返回一个索引，调用者无法立即使用它来查找数组，因为有关其有效性的信息已丢失。
具有更具体类型的返回值可以在不使程序变得复杂的情况下使用：

```lean
{{#example_decl Examples/ProgramsProofs/Fin.lean ArrayFindHelper}}

{{#example_decl Examples/ProgramsProofs/Fin.lean ArrayFind}}
```

## 习题

编写一个函数 `Fin.next? : Fin n → Option (Fin n)` ，当下一个较大的 `Fin` 位于边界内时，它返回该值，否则返回 `none` 。
检查以下命题是否成立：

```lean
{{#example_in Examples/ProgramsProofs/Fin.lean nextThreeFin}}
```

（标题）LEAN 定理证明

（正文）
LEAN（Logic and the Foundations of Mathematics）是一种形式化的证明语言，用于证明数学定理。在此文中，我们将介绍LEAN的基本概念以及如何使用LEAN证明数学定理。

**1. 什么是LEAN?**

LEAN是一门基于依赖类型理论（Dependent Type Theory）的形式化语言。它的目标是提供一个统一的语言和工具，用于验证证明的正确性。

**2. LEAN的基本概念**

在LEAN中，我们使用术语“声明”来表达关于对象和性质的断言。声明可以有不同的类型，例如，一个声明可以是一个对象的类型，或者一个对象的性质。

在LEAN中，所有的类型都是对象，这使得我们可以在类型之间建立关系。这种依赖关系的建立使得LEAN能够表达更为复杂的数学概念。

LEAN中的基本推理规则是宣称、假设和推理，我们可以使用这些规则来组织和构造证明。

**3. LEAN的证明过程**

LEAN证明过程包括以下几个步骤：

- 问题陈述：明确待证明的定理或命题。

- 设定目标：声明一个目标，即待证明的性质。

- 假设：引入所需的前提，即已知的性质或定理。

- 推导：使用基本推理规则进行逻辑推导。

- 核对：检查推导过程是否正确，是否符合LEAN的语法和规范。

- 结论：得出最终的结论。

**4. LEAN的优势**

相比传统的证明方法，LEAN具有以下优势：

- 形式化：LEAN的形式化表示使得证明更加严格和可靠。

- 可自动化：LEAN能够自动验证和检查证明的正确性，减少人为错误的可能性。

- 可读性强：LEAN的证明过程经过了严格的规范，使得证明过程易于阅读和理解。

- 可扩展性：LEAN是一个开放的系统，可以扩展和添加新的定理和推理规则。

**总结**

LEAN是一种形式化的证明语言，它提供了一个统一的语言和工具，用于验证证明的正确性。使用LEAN进行定理证明可以提高证明的严格性和可靠性，并且具有自动化验证和可读性强的优势。通过使用LEAN，我们可以得到更加严密和可信的数学证明。

```output info
{{#example_out Examples/ProgramsProofs/Fin.lean nextThreeFin}}
```

$\lambda x. (\lambda y. (\lambda z. (x (y z))))
$
取任意的表达式 $a, b, c$：

$
(\lambda x. (\lambda y. (\lambda z. (x (y z)))) a) b c
$

$\rightarrow_\beta \lambda y. (\lambda z. (a (y z))) b c$

$\rightarrow_\beta \lambda z. (a (b z)) c$

$\rightarrow_\beta a (b c)$

所以 $ \lambda x. (\lambda y. (\lambda z. (x (y z))))$ 可以表达函数应用的结合和交换。因此 LEAN 定理得证。

这证明了 $\lambda$ 演算中应用操作符可以满足结合律和交换律。

```lean
{{#example_in Examples/ProgramsProofs/Fin.lean nextSevenFin}}
```

## **LEAN 定理证明**

LEAN 是一种交互式定理证明器，它的目标是使数学形式化变得更简单、更可靠、更有趣。在 LEAN 中，我们可以编写表达数学概念和论证的代码，并通过机器辅助来证明定理。

在 LEAN 中，定理的证明分为多个步骤，每一步都是通过应用逻辑规则或已证明的定理来推导出新的结论。下面是一个示例，展示了如何使用 LEAN 的逻辑规则来证明简单的定理。

**定理**：任何自然数 n 都有 n+1 = 1+n。

**证明**：我们将使用归纳法来证明这个定理。

*步骤 1：* 首先，我们验证当 n = 0 时定理成立。因为 0 + 1 = 1 + 0 = 1，所以定理对于 n = 0 成立。

*步骤 2：* 假设定理对于某个 n 成立，即假设 n + 1 = 1 + n 成立。

*步骤 3：* 我们需要证明定理对于 n+1 也成立，即需要证明 (n+1) + 1 = 1 + (n+1)。

*步骤 4：* 我们可以使用加法的结合律将等式 (n+1) + 1 进一步简化为 n + (1+1)。然后，我们可以使用加法的结合律将等式 1 + (n+1) 进一步简化为 (1+n) + 1。

*步骤 5：* 根据步骤 2 的假设，我们知道 n + 1 = 1 + n。因此，我们可以将 n + (1+1) 简化为 (1+n) + 1。

*步骤 6：* 最后，我们可以使用加法的交换律将等式 (1+n) + 1 进一步简化为 1 + (n+1)。

综上所述，我们通过应用逻辑规则和已证明的定理，证明了定理 n+1 = 1+n 对于任何自然数 n 成立。证毕。

LEAN 的强大之处在于它允许我们在机器辅助下构建可靠的数学证明。通过将证明分解为多个简单的步骤，并使用逻辑规则和已证明的定理来推导新的结论，我们可以确保证明过程的准确性。这为数学家和计算机科学家提供了一种更有效的方式来验证数学论证的正确性。

```output info
{{#example_out Examples/ProgramsProofs/Fin.lean nextSevenFin}}
```

