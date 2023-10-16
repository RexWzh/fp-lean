# 宇宙设计模式

在 Lean 中，诸如 `Type`、`Type 3` 和 `Prop` 这样的类型被称为宇宙，它们用于对其他类型进行分类。
然而，术语“宇宙”也用于表示一种设计模式，其中使用一个数据类型来表示 Lean 中一些类型的子集，并且某个函数将该数据类型的构造函数转换为实际的类型。
该数据类型的值被称为其类型的“代码”。

就像 Lean 内置的宇宙一样，使用这种模式实现的宇宙也是描述一些可用类型的类型，尽管实现机制不同。
在 Lean 中，有一些直接描述其他类型的类型，例如 `Type`、`Type 3` 和 `Prop`。
这种排列方式被称为“Russell 风格的宇宙”。
本节中描述的用户定义的宇宙将所有类型都表示为“数据”，并包含一个显式的函数将这些代码解释为真正的类型。
这种排列方式被称为“Tarski 风格的宇宙”。
虽然基于依赖类型理论的 Lean 等语言几乎总是使用 Russell 风格的宇宙，但 Tarski 风格的宇宙是这些语言中定义 API 的有用模式。

定义一个自定义宇宙可以构建一个可以与 API 一起使用的类型集合。
由于类型集合是封闭的，对代码进行递归使得程序可以对该宇宙中的_任何_类型起作用。
一个自定义宇宙的例子是具有代码 `nat` 表示 `Nat` 和 `bool` 表示 `Bool` 的宇宙：

```lean
{{#example_decl Examples/DependentTypes/Finite.lean NatOrBool}}
```

对代码进行模式匹配能够使类型得到具体化，就像对`Vect`的构造函数进行模式匹配一样，可以具体化期望的长度。
例如，可以按如下方式编写一个从字符串反序列化类型的程序：

```lean
{{#example_decl Examples/DependentTypes/Finite.lean decode}}
```

依赖模式匹配（Dependent pattern matching）在 `t` 上允许将期望的结果类型 `t.asType` 分别细化为 `NatOrBool.nat.asType` 和 `NatOrBool.bool.asType`，这些类型计算结果为实际的类型 `Nat` 和 `Bool`。

与其他数据一样，代码也可以是递归的。
类型 `NestedPairs` 用于编码任意可能的对和自然数类型的嵌套：

```lean
{{#example_decl Examples/DependentTypes/Finite.lean NestedPairs}}
```

在这种情况下，解释函数 `NestedPairs.asType` 是递归的。
这意味着需要对代码进行递归操作，以便为宇宙实现 `BEq` :

```lean
{{#example_decl Examples/DependentTypes/Finite.lean NestedPairsbeq}}
```

尽管`NestedPairs`宇宙中每种类型都已经有了一个 `BEq` 实例，类型类搜索并不会自动检查在实例声明中的每种可能情况，因为可能存在无限多个这样的情况，例如 `NestedPairs`。
试图直接依赖 `BEq` 实例而不用递归地解释给 Lean 如何找到它们会导致错误：

```lean
{{#example_in Examples/DependentTypes/Finite.lean beqNoCases}}
```



```output error
{{#example_out Examples/DependentTypes/Finite.lean beqNoCases}}
```

错误信息中的 `t` 代表了一个未知类型 `NestedPairs` 的值。

## 类型类 vs 宇宙

类型类允许以开放的方式使用一组类型，只要它们具有必要的接口实现即可。在大多数情况下，这是更可取的。很难预测 API 的所有用例，类型类是一种方便的方式，可以让库代码与比原作者预期的类型更多的类型一起使用。

而另一方面，类似 Tarski 宇宙的做法则限制了 API 仅能与预定集合的类型一起使用。在以下情况下很有用：

* 当一个函数的行为取决于传入的类型时——无法对类型进行模式匹配，但可以对类型的代码进行模式匹配
* 当外部系统本质上限制了可提供的数据类型，并且不需要额外的灵活性
* 当需要对类型进行的操作超过某些操作的实现时

类型类在许多情况下与 Java 或 C# 中的接口很相似，而类似 Tarski 宇宙的做法则可用于类似密封类但无法使用普通归纳数据类型的情况下。

## 一个有限类型的宇宙

将可以与 API 一起使用的类型限制为预先确定的集合，可以实现开放式 API 中不可能的操作。例如，通常无法比较函数是否相等。只有当函数将相同的输入映射到相同的输出时，才应该认为它们是相等的。检查这一点可能需要无限长的时间，因为比较两个类型为 `Nat → Bool` 的函数需要检查函数对每个 `Nat` 返回的 `Bool` 是否相同。

换句话说，一个来自无限类型的函数本身也是无限的。函数可以被视为表格，而参数类型为无限的函数则需要无限多的行来表示每种情况。而来自有限类型的函数仅需要有限多的行来表示它们的表格，使它们成为有限的。两个参数类型为有限的函数可以通过枚举所有可能的参数，对每个参数调用函数，然后比较结果来检查它们是否相等。检查高阶函数的相等性需要生成给定类型的所有可能函数，这还需要返回类型也是有限的，以便将参数类型的每个元素映射到返回类型的每个元素。
这不是一种“快速”的方法，但它能够在有限时间内完成。

表示有限类型的一种方式是使用一个宇宙：

```lean
{{#example_decl Examples/DependentTypes/Finite.lean Finite}}
```

在这个宇宙中，构造函数 `arr` 代表函数类型，用箭头表示。

与 `NestedPairs` 宇宙中的相等比较几乎是一样的。
唯一的重要区别是增加了对 `arr` 的情况，它使用一个名为 `Finite.enumerate` 的辅助函数来生成由 `t1` 编码的类型中的每个值，并检查两个函数在每个可能的输入上返回的结果是否相等：

```lean
{{#example_decl Examples/DependentTypes/Finite.lean FiniteBeq}}
```

标准库函数 `List.all` 检查提供的函数在列表的每个项上返回 `true` 。
该函数可用于比较布尔函数的相等性：

```lean
{{#example_in Examples/DependentTypes/Finite.lean arrBoolBoolEq}}
```



```output info
{{#example_out Examples/DependentTypes/Finite.lean arrBoolBoolEq}}
```

它还可以用于比较标准库中的函数：

```lean
{{#example_in Examples/DependentTypes/Finite.lean arrBoolBoolEq2}}
```



```output info
{{#example_out Examples/DependentTypes/Finite.lean arrBoolBoolEq2}}
```

它甚至可以比较使用函数组合等工具构建的函数：

```lean
{{#example_in Examples/DependentTypes/Finite.lean arrBoolBoolEq3}}
```



```output info
{{#example_out Examples/DependentTypes/Finite.lean arrBoolBoolEq3}}
```

这是因为“有限”宇宙为 Lean 的*真实*函数类型编码，而不是库创建的特殊类比。

“枚举”的实现也是根据“有限”编码的递归进行的。

```lean
{{#include ../../../examples/Examples/DependentTypes/Finite.lean:FiniteAll}}
```

在 `Unit` 的情况下，只有一个值。
在 `Bool` 的情况下，有两个要返回的值（`true` 和 `false`）。
在对成对的情况下，结果应该是由 `t1` 的类型编码的值和 `t2` 的类型编码的值的笛卡尔积。
换句话说，`t1` 的每个值都应该与 `t2` 的每个值进行配对。
辅助函数 `List.product` 可以使用普通递归函数编写，但在这里它使用 `for` 在 identity monad 中定义：

```lean
{{#example_decl Examples/DependentTypes/Finite.lean ListProduct}}
```

最后，对于函数的`Finite.enumerate`的情况，将委托给一个名为`Finite.functions`的辅助函数，该函数将所有要作为参数的返回值列表作为参数。

一般来说，从某个有限类型到一组结果值的所有函数生成被视为生成函数的表格。
每个函数将一个输出分配给每个输入，这意味着当有\\( k \\)个可能的参数时，给定函数在其表格中有\\( k \\)行。
由于表格的每一行都可以选择任何\\( n \\)个可能的输出之一，因此有\\( n ^ k \\)个潜在函数可生成。

再次强调，从有限类型到某个值列表的函数生成依赖于描述有限类型的代码的递归结构：

```lean
{{#include ../../../examples/Examples/DependentTypes/Finite.lean:FiniteFunctionSigStart}}
```

从`Unit`到函数的表格只有一行，因为函数无法根据提供的不同输入选择不同的结果。这意味着为每个潜在输入生成一个函数。

```lean
{{#include ../../../examples/Examples/DependentTypes/Finite.lean:FiniteFunctionUnit}}
```

当结果值有 \\( n \\) 个时，从 `Bool` 到结果值的函数有 \\( n^2 \\) 个，因为每个类型为 `Bool → α` 的函数会使用 `Bool` 来选择两个特定的 `α` 之间的一个。

```lean
{{#include ../../../examples/Examples/DependentTypes/Finite.lean:FiniteFunctionBool}}
```

通过利用柯里化，可以生成从对中导出函数。可以将从一对导出的函数转换为一个函数，该函数接受对的第一个元素并返回一个等待对的第二个元素的函数。通过这样做，可以在这种情况下递归地使用 `Finite.functions`：

```python
def functions(finiteSet1, finiteSet2):
    # 如果第一个集合为空，则返回一个空字典作为结果
    if not finiteSet1:
        return {}
    
    # 否则，取出第一个集合的第一个元素和剩余的元素
    element, remainingElements = finiteSet1[0], finiteSet1[1:]
    
    # 对第二个集合中的每个元素应用递归，并将结果保存在字典中
    # 字典的键是第一个集合的元素，值是递归调用的结果
    result = {element: {}}
    for element2 in finiteSet2:
        result[element][element2] = functions(remainingElements, finiteSet2)
    
    # 返回结果字典
    return result
```

这样，当调用 `functions(finiteSet1, finiteSet2)` 时，会生成一个字典，字典的键是第一个集合中的元素，值是一个字典，字典的键是第二个集合中的元素，值是一个字典，以此类推。这样的嵌套字典表示了从一对中生成的函数。注意，这里使用了递归来处理第一个集合的每个元素和第二个集合的每个元素。

```lean
{{#include ../../../examples/Examples/DependentTypes/Finite.lean:FiniteFunctionPair}}
```

生成高阶函数有点令人费解。
每个高阶函数都以一个函数作为其参数。
这个参数函数可以根据其输入/输出行为与其他函数区分开来。
一般来说，高阶函数可以将参数函数应用于每个可能的参数，并且可以根据应用参数函数的结果执行任何可能的行为。
这提示了一种构建高阶函数的方法：
 * 从作为参数的函数的所有可能参数列表开始。
 * 对于每个可能的参数，构造可能的行为，这些行为可以作为应用参数函数到可能的参数上的结果观察的结果。这可以使用 `Finite.functions` 和对其余可能参数的递归来完成，因为递归的结果表示基于对其余可能参数的观察的函数。`Finite.functions` 根据当前参数的观察构造所有实现这些的方式。
 * 对于这些观察结果中的潜在行为，构造一个高阶函数，将参数函数应用于当前可能的参数。然后将此结果传递给观察行为。
 * 递归的基本情况是对于每个结果值都没有观察到的高阶函数 - 它忽略参数函数并简单地返回结果值。

直接定义这个递归函数会导致 Lean 无法证明整个函数终止。
然而，使用一种更简单的递归形式——_右折叠_可以使终止检查器清楚地看到函数的终止。
右折叠接受三个参数：步骤函数，它将列表的头部与对尾部递归的结果相结合；当列表为空时要返回的默认值；以及正在处理的列表。
然后，它分析列表，实际上将列表中的每个 `::` 替换为对步骤函数的调用，并将 `[]` 替换为默认值：

```lean
{{#example_decl Examples/DependentTypes/Finite.lean foldr}}
```

使用 `foldr` 可以计算列表中 `Nat` 的总和：

```lean
{{#example_eval Examples/DependentTypes/Finite.lean foldrSum}}
```

使用 `foldr`，可以通过以下方式创建高阶函数：

```lean
{{#include ../../../examples/Examples/DependentTypes/Finite.lean:FiniteFunctionArr}}
```

The complete definition of `Finite.Functions` is:

A finite function, or function of finite support, is a function that has a finite number of nonzero output values. Formally, a function *f* from a set *X* to a set *Y* is said to be a finite function if and only if there exists a finite subset *S* of *X* such that for every element *x* in *X* not in *S*, *f(x)* is equal to the zero element of *Y*.

In other words, a finite function is a function that is nonzero only for a finite number of input values.

The concept of finite functions is important in various areas of mathematics, including algebra, calculus, and discrete mathematics. In algebra, finite functions are used to model and manipulate finite sets. In calculus, they are used to define and analyze functions with limited domains. In discrete mathematics, they are used to study and solve problems involving finite sets and combinatorial structures.

To illustrate the concept of finite functions, consider the following example. Let *X* be the set {1, 2, 3} and *Y* be the set {A, B, C}. We define a function *f* from *X* to *Y* as follows: *f(1)* = A, *f(2)* = B, and *f(3)* = 0. In this example, the subset *S* of *X* is {3}, and *f(x)* is equal to the zero element of *Y* for every *x* not in *S*. Therefore, *f* is a finite function.

In summary, a finite function is a function that has a finite number of nonzero output values. It is a fundamental concept in mathematics, especially in algebra, calculus, and discrete mathematics. Understanding and working with finite functions is essential in many areas of mathematical research and application.

```lean
{{#include ../../../examples/Examples/DependentTypes/Finite.lean:FiniteFunctions}}
```

由于 `Finite.enumerate` 和 `Finite.functions` 相互调用，它们必须在一个 `mutual` 块中定义。
换句话说，在 `Finite.enumerate` 的定义之前使用 `mutual` 关键字：

```lean
{{#include ../../../examples/Examples/DependentTypes/Finite.lean:MutualStart}}
```

在 `Finite.functions` 的定义之后，紧接着是 `end` 关键字。

```lean
{{#include ../../../examples/Examples/DependentTypes/Finite.lean:MutualEnd}}
```

这个用于比较函数的算法并不是特别实用。
需要检查的情况数量呈指数增长；即使是像 `((Bool × Bool) → Bool) → Bool` 这样简单的类型，也描述了 {{#example_out Examples/DependentTypes/Finite.lean nestedFunLength}} 个不同的函数。
为什么会有这么多函数呢？
根据上述推理，假设 \\( \\left| T \\right| \\) 表示类型 \\( T \\) 描述的值的数量，我们应该预期
\\[ \\left| \\left( \\left( \\mathtt{Bool} \\times \\mathtt{Bool} \\right) \\rightarrow \\mathtt{Bool} \\right) \\rightarrow \\mathtt{Bool} \\right| \\]
应该是
\\[ \\left|\\mathrm{Bool}\\right|^{\\left| \\left( \\mathtt{Bool} \\times \\mathtt{Bool} \\right) \\rightarrow \\mathtt{Bool} \\right| }, \\]
即
\\[ 2^{2^{\\left| \\mathtt{Bool} \\times \\mathtt{Bool} \\right| }}, \\]
即
\\[ 2^{2^4} \\]
等于 65536。
嵌套指数增长迅速，并且存在许多高阶函数。


## 练习

 * 编写一个函数，将 `Finite` 类型编码的任何值转换为字符串。函数应该使用表格表示。
 * 将空类型 `Empty` 添加到 `Finite` 和 `Finite.beq` 中。
 * 将 `Option` 添加到 `Finite` 和 `Finite.beq` 中。