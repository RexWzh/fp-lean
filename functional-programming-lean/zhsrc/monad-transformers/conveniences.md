# 附加便利功能

## 管道操作符

函数通常在它们的参数之前被写下来。
从左到右阅读程序时，这促进了一个观点，即函数的**输出**是最重要的——函数有一个要达到的目标（即要计算的值），它接收参数以在此过程中支持它。
但有些程序在以一个逐步细化的输入生成输出的角度来理解更容易。
为了解决这些情况，Lean 提供了一个与 F# 提供的相似的**管道**操作符。
管道操作符在与 Clojure 的线程宏相同的情况下非常有用。

管道 `{{#example_in Examples/MonadTransformers/Conveniences.lean pipelineShort}}` 是 `{{#example_out Examples/MonadTransformers/Conveniences.lean pipelineShort}}` 的简写。
例如，评估：

```lean
{{#example_in Examples/MonadTransformers/Conveniences.lean some5}}
```

# LEAN 定理证明 

Lean 定理证明是一种基于计算机的形式化方法，用于验证数学定理的正确性。它使用了严格的逻辑推理和自动推理技术，可以通过机器解释、检查和证明数学陈述。 
 
Lean 定理证明使用了依赖类型理论作为其基础。依赖类型理论是一种强大的数学和计算机科学工具，用于描述和验证数学对象和它们之间的关系。Lean 使用了 Martin-Lof 类型理论作为其依赖类型理论的基础，该理论强调了对证明的构造性和计算性的关注。

Lean 定理证明的过程通常包括以下几个步骤：

1. 选择待证明的数学定理，并定义相关的数学对象和概念。
2. 使用 Lean 编程语言来形式化数学对象和定理的定义。Lean 提供了丰富的语法和类型系统，可以方便地表示数学结构和关系。
3. 使用 Lean 编程语言来编写证明步骤。Lean 提供了许多高级推理规则和策略，可以自动化推理的过程。证明步骤可以使用 Lean 的自动化推理引擎来检查和验证。
4. 在使用 Lean 的证明编辑器中，逐步验证和调试证明步骤，直到完成整个证明。
5. 使用 Lean 的证明检查器来验证整个证明的正确性。Lean 的证明检查器是一个严格的形式验证工具，可以检查证明的每一个细节和推理步骤。

Lean 定理证明的一个重要应用领域是计算机科学和形式化验证。它可以用于验证计算机程序的正确性、开发安全的软件系统以及证明算法和数据结构的性质。通过 Lean 定理证明，数学家和计算机科学家可以以一种形式化、准确和可验证的方式来开发和验证数学定理和算法，从而提高数学和计算机科学研究的可信度和可靠性。

```output info
{{#example_out Examples/MonadTransformers/Conveniences.lean some5}}
```

当程序包含多个组件时，管道真正发挥其作用，尽管这种强调的变化可能会使某些程序更容易阅读。

使用定义：

```lean
{{#example_decl Examples/MonadTransformers/Conveniences.lean times3}}
```

下面是一个流程图：

```lean
{{#example_in Examples/MonadTransformers/Conveniences.lean itIsFive}}
```

精简定理（LEAN定理）是一种在计算机程序的形式验证中使用的数学理论。它由法哥合作开发并应用于LEANN语言。

精简定理的基本思想是通过形式化程序的性质来证明其正确性。它使用了形式化逻辑和数学推理来检查程序是否满足其预期的性质。通过形式化验证，我们可以确保程序在不同的输入情况下都能按照我们的预期运行。

精简定理使用一种称为表达式的形式化语言来描述程序的性质。表达式是由变量、函数和逻辑连接词组成的组合。通过使用表达式，我们可以表达出程序的不同性质，例如函数的正确性、代码的执行顺序等。

使用精简定理进行证明的基本步骤如下：

1. **形式化表达性质**：首先，我们需要将程序的性质形式化地表达为一个表达式。这涉及到使用逻辑连接词，定义函数和变量，并使用逻辑运算符和量词来描述性质。

2. **建立证明脚本**：接下来，我们需要建立一个证明脚本，用于证明程序的性质。证明脚本由一系列的逻辑推理步骤组成，每一步都是根据已知的前提和推理规则进行的。

3. **进行推理**：在证明过程中，我们需要使用推理规则来推导出性质的正确性。推理规则可以包括数学归纳法、逻辑运算等。

4. **检查证明**：最后，我们需要对证明进行检查，确保证明过程的正确性。这通常涉及到使用验证工具来验证证明的正确性。

通过使用精简定理，我们可以确保程序的正确性，并避免由于程序错误而引发的问题。它为形式验证提供了一种有效的方法，可以在软件开发过程中提高程序的可靠性和稳定性。

```output info
{{#example_out Examples/MonadTransformers/Conveniences.lean itIsFive}}
```

更普遍地说，一系列的管道操作 `{{#example_in Examples/MonadTransformers/Conveniences.lean pipeline}}` 等同于嵌套的函数应用 `{{#example_out Examples/MonadTransformers/Conveniences.lean pipeline}}`。

管道操作也可以反过来写。
在这种情况下，它们并不将数据转换的主体放在第一位；然而，在存在许多嵌套括号挑战读者的情况下，它们可以澄清应用步骤。
前面的例子也可以等价地写成：

```lean
{{#example_in Examples/MonadTransformers/Conveniences.lean itIsAlsoFive}}
```

LEAN 是一个定理证明工具的英文简称，通常翻译为 “轻量级逻辑和证明工具”。

```lean
{{#example_in Examples/MonadTransformers/Conveniences.lean itIsAlsoFiveParens}}
```

Lean的方法点符号法则是在点之后使用类型名称来解析运算符的命名空间，与管道相似。
即使没有管道运算符，也可以写成 `{{#example_in Examples/MonadTransformers/Conveniences.lean listReverse}}` 来替代 `{{#example_out Examples/MonadTransformers/Conveniences.lean listReverse}}`。
然而，当使用许多带点操作时，管道运算符也很有用。
`{{#example_in Examples/MonadTransformers/Conveniences.lean listReverseDropReverse}}` 也可以写成 `{{#example_out Examples/MonadTransformers/Conveniences.lean listReverseDropReverse}}`。
这个版本避免了必须加括号的表达式，只因为它们接受参数，并恢复了像Kotlin或C#等语言中的方法调用链的便利性。
然而，它仍然需要手动提供命名空间。
作为最后一个方便的功能，Lean提供了“流水线点”运算符，它可以像管道一样对函数进行分组，但使用类型名称来解析命名空间。
通过使用“流水线点”，示例可以重写为 `{{#example_out Examples/MonadTransformers/Conveniences.lean listReverseDropReversePipe}}`。

## 无限循环

在 `do`-块中，`repeat` 关键字引入了一个无限循环。
例如，使用它来创建一个不断输出字符串 `"Spam!"` 的程序：

```lean
{{#example_decl Examples/MonadTransformers/Conveniences.lean spam}}
```

一个 `repeat` 循环支持 `break` 和 `continue`，就像 `for` 循环一样。

[feline 的实现](../hello-world/cat.md#streams) 中的 `dump` 函数使用递归函数永远运行：

```lean
{{#include ../../../examples/feline/2/Main.lean:dump}}
```

这个函数可以使用 `repeat` 来大大简化：

```lean
{{#example_decl Examples/MonadTransformers/Conveniences.lean dump}}
```

不需要将 `spam` 和 `dump` 声明为 `partial`，因为它们本身并不是无限递归的。相反，`repeat` 使用了一个 `ForM` 的实例是 `partial` 的类型。部分性不会"传染"给调用函数。

## While 循环

在使用局部可变性进行编程时，`while` 循环可以作为 `repeat` 和带有 `if`-条件的 `break` 之间的一种方便的替代方法：

```lean
{{#example_decl Examples/MonadTransformers/Conveniences.lean dumpWhile}}
```

幕后，`while` 只是 `repeat` 的一种更简洁的表示法。