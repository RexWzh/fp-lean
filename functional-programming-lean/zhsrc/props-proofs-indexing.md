# 插曲：命题、证明和索引

和许多语言一样，Lean 使用方括号来索引数组和列表。
例如，如果 `woodlandCritters` 定义如下：

```lean
{{#example_decl Examples/Props.lean woodlandCritters}}
```

那么可以提取出各个组成部分：

```lean
{{#example_decl Examples/Props.lean animals}}
```

然而，尝试提取第四个元素会导致编译时错误，而不是运行时错误：

```lean
{{#example_in Examples/Props.lean outOfBounds}}
```



```output error
{{#example_out Examples/Props.lean outOfBounds}}
```

这个错误提示说 Lean 尝试自动证明 `3 < List.length woodlandCritters` 这个数学命题，这意味着查找是安全的，但它无法做到这一点。
越界错误是一类常见的错误，Lean 使用其作为程序语言和定理证明器的双重特性来排除尽可能多的错误。

理解这一过程需要理解三个关键概念：命题、证明和策略。

## 命题和证明

_命题_ 是可以为真或为假的陈述。
以下都是命题：

 * 1 + 1 = 2
 * 加法是可交换的
 * 存在无穷多个质数
 * 1 + 1 = 15
 * 巴黎是法国的首都
 * 布宜诺斯艾利斯是韩国的首都
 * 所有的鸟都可以飞

另一方面，荒谬的陈述不是命题。
以下都不是命题：

 * 1 + 绿色 = 冰淇淋
 * 所有首都城市都是质数
 * 至少有一个 gorg 是 fleep

命题有两种类型：一种是纯粹数学的，仅依赖于我们对概念的定义；另一种是关于世界的事实。
像 Lean 这样的定理证明器只关注前一种类别，并不对企鹅的飞行能力或城市的法律地位发表意见。

_证明_ 是一个有力的论据，证明一个命题是真的。
对于数学命题，这些论据使用所涉及概念的定义以及逻辑论证的规则。
大多数证明是为了让人理解而编写的，省略了许多繁琐的细节。
像 Lean 这样的计算机辅助定理证明器的设计目的是允许数学家在省略许多细节的情况下编写证明，软件负责填补缺失的显式步骤。
这降低了出现疏忽或错误的可能性。

在 Lean 中，程序的类型描述了它的交互方式。
例如，类型为 `Nat → List String` 的程序是一个接受 `Nat` 参数并产生一个字符串列表的函数。
换句话说，每种类型都规定了什么是具有该类型的程序。

在 Lean 中，命题实际上就是类型。
它们指定了什么样的证据被认为是命题为真的依据。
通过提供这些证据来证明命题。
另一方面，如果命题为假，那么将无法构造这样的证据。
举个例子，命题“1 + 1 = 2”可以直接用 Lean 写出来。
这个命题的证明是构造函数 `rfl`，它是 _反射性_ 的缩写：

```lean
{{#example_decl Examples/Props.lean onePlusOneIsTwo}}
```

另一方面，`rfl` 无法证明错误的命题 "1 + 1 = 15"：

```lean
{{#example_in Examples/Props.lean onePlusOneIsFifteen}}
```



```output error
{{#example_out Examples/Props.lean onePlusOneIsFifteen}}
```

这个错误提示表明，当等式语句的两边已经是相同的数字时，`rfl` 可以证明两个表达式是相等的。
因为 `1 + 1` 直接计算得到 `2`，它们被认为是相同的，这样就允许了 `onePlusOneIsTwo` 的接受。
就像 `Type` 描述了如 `Nat`、`String` 和 `List (Nat × String × (Int → Float))` 这样表示数据结构和函数的类型，`Prop` 描述了命题。

当命题被证明时，它被称为一个 _定理_。
在 Lean 中，习惯上使用 `theorem` 关键字而不是 `def` 声明定理。
这有助于读者看出哪些声明打算被看作数学证明，哪些是定义。
一般来说，对于一个证明而言，重要的是有证据证明一个命题是真的，但提供的证据是什么并不特别重要。
然而，对于定义来说，选择哪个特定的值非常重要，毕竟总是返回 `0` 的加法定义显然是错误的。

前面的例子可以重写为以下形式：

```lean
{{#example_decl Examples/Props.lean onePlusOneIsTwoProp}}
```

## 策略

证明通常使用*策略*来编写，而不是直接提供证据。
策略是一种构建命题证据的小程序。
这些程序在一个*证明状态*中运行，用于跟踪待证明的命题（称为*目标*）以及可用于证明它的假设。
在目标上运行策略会得到一个新的证明状态，其中包含新的目标。
当所有目标都被证明时，证明就完成了。

使用策略来编写证明时，可以在定义的开头使用 `by`。
使用 `by` 会将 Lean 置于策略模式，直到下一个缩进块的结束。
在策略模式下，Lean 提供有关当前证明状态的持续反馈。
使用策略编写的 `onePlusOneIsTwo` 仍然很简短：

```leantac
{{#example_decl Examples/Props.lean onePlusOneIsTwoTactics}}
```

`tactic`（简写为`tac`）策略在 Lean 证明中扮演着重要角色，其中`simp`策略是`tactic`中最常用、最重要的一个。
`simp`策略的全称是 "simplify"，即简化，它将目标重写为尽可能简单的形式，并处理掉证明中较小的部分。
特别地，它能够证明简单的等式陈述。
在背后，`simp`策略还会构造详细的形式证明，但是使用`simp`策略可以隐藏这种复杂性。

策略在许多方面都很有用：
1. 许多证明在详细记录的最小细节时会变得复杂而乏味，而策略可以自动化这些无趣的部分。
2. 使用策略编写的证明更易于随时间维护，因为灵活的自动化可以弥补定义的微小变化。
3. 由于单个策略可以证明许多不同的定理，Lean 可以在背后使用策略，从而使用户无需手动编写证明。例如，数组查找需要一个证明索引在边界内，而策略通常可以构造出这个证明，而无需用户担心此问题。

在底层，索引符号使用策略来证明用户的查找操作是安全的。
这个策略就是`simp`策略，并配置以考虑特定的算术等式。

## 逻辑连接词

逻辑的基本构建块，例如 "and"、 "or"、 "true"、 "false" 和 "not"，被称为 _逻辑连接词_。
每个连接词定义了什么样的证据可以证明其为真。
例如，要证明语句 "_A_ 且 _B_"，必须同时证明 _A_ 和 _B_。
这意味着 "_A_ 且 _B_" 的证据是一个包含 _A_ 和 _B_ 的证据对。
类似地，"_A_ 或 _B_" 的证据是对 _A_ 或 _B_ 的证据之一。

特别地，大多数连接词像数据类型一样被定义，它们有构造函数。
如果 `A` 和 `B` 是命题，那么 "`A` 且 `B`"（写作 `{{#example_in Examples/Props.lean AndProp}}`）也是一个命题。
`A ∧ B` 的证据包括构造函数 `{{#example_in Examples/Props.lean AndIntro}}`，它的类型是 `{{#example_out Examples/Props.lean AndIntro}}`。
将 `A` 和 `B` 替换为具体的命题，可以使用 `{{#example_in Examples/Props.lean AndIntroEx}}` 来证明 `{{#example_out Examples/Props.lean AndIntroEx}}`。
当然了，`simp`也足够强大，可以找到这个证明：

```lean
import tactic
open tactic

example (p q : Prop) : p ∧ q → q ∧ p :=
begin
  intro h,
  split,
  { apply h.right },
  { apply h.left }
end
```

在这个证明中，我们使用了 `simp` 策略来简化证明步骤。

```leantac
{{#example_decl Examples/Props.lean AndIntroExTac}}
```

同样地，"`A` 或 `B`"（写作 `{{#example_in Examples/Props.lean OrProp}}`）有两种构造方式，因为证明 "`A` 或 `B`" 只需要其中一个命题为真。

有两种构造方式： `{{#example_in Examples/Props.lean OrIntro1}}`，类型为 `{{#example_out Examples/Props.lean OrIntro1}}` 和 `{{#example_in Examples/Props.lean OrIntro2}}`，类型为 `{{#example_out Examples/Props.lean OrIntro2}}`。

蕴含关系（如果 _A_，则 _B_）使用函数表示。
特别地，一个将对 _A_ 的证据转化为对 _B_ 的证据的函数本身就是 _A_ 蕴含 _B_ 的证据。
这与通常对蕴含关系的描述不同，通常 `A → B` 是 `¬A ∨ B` 的简写，但这两种表达是等价的。

由于对于 "and" 的证据是一个构造方式，因此它可以与模式匹配一起使用。
例如，证明 _A_ 和 _B_ 蕴含 _A_ 或 _B_ 的证据是一个函数，它从 _A_ 和 _B_ 的证据中提取出 _A_（或 _B_）的证据，然后使用这些证据来生成 _A_ 或 _B_ 的证据：

```lean
{{#example_decl Examples/Props.lean andImpliesOr}}
```

| 连接词      | Lean 语法 | 证据           |
|----------|---------|--------------|
| 真         | `True`  | `True.intro : True`   |
| 假         | `False` | 无证据          |
| _A_ 与 _B_ | `A ∧ B` | `And.intro : A → B → A ∧ B` |
| _A_ 或 _B_ | `A ∨ B` | 可以使用 `Or.inl : A → A ∨ B` 或 `Or.inr : B → A ∨ B` |
| _A_ 蕴含 _B_ | `A → B` | 将 _A_ 的证据转化成 _B_ 的证据的函数 |
| 非 _A_      | `¬A`    | 将 _A_ 的证据转化成 `False` 的证据的函数 |

`simp` 策略可以证明使用这些连接词的定理。例如：

```leantac
{{#example_decl Examples/Props.lean connectives}}
```

## 证据作为论证

尽管 `simp` 在证明涉及特定数字的等式和不等式的命题时做得很出色，但它并不擅长证明涉及变量的陈述。
例如，`simp` 可以证明 `4 < 15`，但是它不能轻易地告诉我们，因为 `x < 4`，所以 `x < 15` 也是成立的。
因为索引表示使用 `simp` 在后台证明数组访问的安全性，所以可能需要一些辅助操作。

使索引表示运作良好的最简单方法之一是将执行数据结构查找的函数将所需的安全性证据作为参数传递。
例如，返回列表中第三个条目的函数通常是不安全的，因为列表可能包含零个、一个或两个条目：

```lean
{{#example_in Examples/Props.lean thirdErr}}
```



```output error
{{#example_out Examples/Props.lean thirdErr}}
```

然而，要求显示列表至少有三个条目的义务可以通过添加一个参数来强加给调用者，该参数包含索引操作是安全的证据：

```lean
{{#example_decl Examples/Props.lean third}}
```

在这个例子中，`xs.length > 2` 不是一个检查 `xs` 是否有多于2个元素的程序。
它是一个可能为真或者为假的命题，而参数 `ok` 必须是证明它为真的证据。

当在一个具体列表上调用函数时，其长度是已知的。
在这些情况下，`by simp` 可以自动构造证据：

```leantac
{{#example_in Examples/Props.lean thirdCritters}}
```



```output info
{{#example_out Examples/Props.lean thirdCritters}}
```

## 无证据索引

在无法证明索引操作合法的情况下，还有其他的选择。在索引操作前加上一个问号，可以得到一个 `Option`，当索引合法时，结果是 `some`，否则为 `none`。

例如：

```lean
{{#example_decl Examples/Props.lean thirdOption}}

{{#example_in Examples/Props.lean thirdOptionCritters}}
```



```output info
{{#example_out Examples/Props.lean thirdOptionCritters}}
```



```lean
{{#example_in Examples/Props.lean thirdOptionTwo}}
```



```output info
{{#example_out Examples/Props.lean thirdOptionTwo}}
```

还有一个版本，当索引超出范围时，程序会崩溃而不是返回 `Option` ：

```lean
{{#example_in Examples/Props.lean crittersBang}}
```



```output info
{{#example_out Examples/Props.lean crittersBang}}
```

小心！
因为使用 `#eval` 运行的代码是在 Lean 编译器的上下文中运行的，选择错误的索引可能会导致 IDE 崩溃。

## 可能遇到的信息

除了在编译时无法找到索引操作是安全的编译时证据的错误之外，使用不安全索引的多态函数可能会产生以下信息：

```lean
{{#example_in Examples/Props.lean unsafeThird}}
```



```output error
{{#example_out Examples/Props.lean unsafeThird}}
```

这是因为 LEAN 有一个技术限制，它既可以用作证明定理的逻辑，又可以用作编程语言的一部分。

特别是，只有包含至少一个值的类型的程序才被允许崩溃。这是因为在 LEAN 中，命题是一种类型，用于分类证明其真实性的证据。错误的命题没有这样的证据。如果一个空类型的程序能够崩溃，那么这个崩溃的程序就可以被用作一种虚假证据来证明一个错误的命题。

在内部，LEAN 包含一个已知至少有一个值的类型表。这个错误是说某个任意的类型 `α` 不一定在这个表中。下一章将介绍如何向这个表中添加内容，以及如何成功编写像 `unsafeThird` 这样的函数。

在查找时，在列表和用于查找的方括号之间添加空格可能会导致另一条错误消息：

```lean
{{#example_in Examples/Props.lean extraSpace}}
```



```output error
{{#example_out Examples/Props.lean extraSpace}}
```

在 LEAN 中加入一个空格会使其将表达式视为函数应用，并将索引视为包含一个数字的列表。这个错误信息是由于 LEAN 尝试将 `woodlandCritters` 视为一个函数。

## 练习

* 使用 `rfl` 来证明以下定理：`2 + 3 = 5`，`15 - 8 = 7`，`"Hello, ".append "world" = "Hello, world"`。如果使用 `rfl` 来证明 `5 < 18`，会发生什么？为什么？
* 使用 `by simp` 来证明以下定理：`2 + 3 = 5`，`15 - 8 = 7`，`"Hello, ".append "world" = "Hello, world"`，`5 < 18`。
* 编写一个函数，查找列表中的第五个条目。将这个查找安全的证据作为参数传递给函数。