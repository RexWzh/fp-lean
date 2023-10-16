# 结构体

编写程序的第一步通常是识别问题领域的概念，然后在代码中找到合适的表示方式。
有时，一个领域概念是其他更简单的概念的集合。
在这种情况下，将这些较简单的组件组合成一个单一的“包裹”，并为其赋予有意义的名称可以非常方便。
在 Lean 中，可以使用 _结构体_ 来实现这一点，结构体类似于 C 或 Rust 中的 `struct`，以及 C# 中的 `record`。

定义一个结构体会引入一个全新的类型到 Lean 中，无法将其简化为任何其他类型。
这是有用的，因为多个结构体可能代表不同的概念，但包含相同的数据。
例如，一个点可以使用笛卡尔坐标或极坐标表示，每种表示方法都是一对浮点数。
定义不同的结构体可以防止 API 客户端将一个结构体与另一个结构体混淆。

Lean 中的浮点数类型称为 `Float`，浮点数使用通常的表示法来表示。

```lean
{{#example_in Examples/Intro.lean onePointTwo}}
```



```output info
{{#example_out Examples/Intro.lean onePointTwo}}
```



```lean
{{#example_in Examples/Intro.lean negativeLots}}
```



```output info
{{#example_out Examples/Intro.lean negativeLots}}
```



```lean
{{#example_in Examples/Intro.lean zeroPointZero}}
```



```output info
{{#example_out Examples/Intro.lean zeroPointZero}}
```

当浮点数以小数点形式书写时，Lean 将推断出类型为 `Float`。如果没有写小数点，则可能需要添加类型注释。

```lean
{{#example_in Examples/Intro.lean zeroNat}}
```



```output info
{{#example_out Examples/Intro.lean zeroNat}}
```



```lean
{{#example_in Examples/Intro.lean zeroFloat}}
```



```output info
{{#example_out Examples/Intro.lean zeroFloat}}
```

一个笛卡尔点是一个包含两个名为 `x` 和 `y` 的 `Float` 字段的结构。
这可以使用 `structure` 关键字来声明。

```lean
{{#example_decl Examples/Intro.lean Point}}
```

在这个声明后面，`Point` 是一个新的结构类型。
最后一行，`deriving Repr`，要求 Lean 生成用于显示 `Point` 类型值的代码。
这段代码被 `#eval` 使用，用于渲染评估结果以供程序员消费，类似于 Python 中的 `repr` 函数。
也可以覆盖编译器生成的显示代码。

创建一个结构类型的值的典型方式是在大括号内为所有字段提供值。
在笛卡尔平面上，原点的 `x` 和 `y` 均为零：

```lean
{{#example_decl Examples/Intro.lean origin}}
```

如果在 `Point` 的定义中省略了 `deriving Repr` 这一行，那么尝试执行 `{{#example_in Examples/Intro.lean PointNoRepr}}` 会产生一个类似于省略函数参数时出现的错误：

```output error
{{#example_out Examples/Intro.lean PointNoRepr}}
```

这段消息是说，评估机制不知道如何将评估结果传回给用户。

幸运的是，通过使用 `deriving Repr`，`{{#example_in Examples/Intro.lean originEval}}` 的结果看起来非常像 `origin` 的定义。

```output info
{{#example_out Examples/Intro.lean originEval}}
```

因为结构体存在于将一系列数据“捆绑”起来，并给予该集合命名并将其视为单个单位的形式中，因此能够提取结构体的各个字段也非常重要。
这可以通过使用点符号表示法进行操作来实现，比如 C、Python 或 Rust 中的方式。

```lean
{{#example_in Examples/Intro.lean originx}}
```



```output info
{{#example_out Examples/Intro.lean originx}}
```



```lean
{{#example_in Examples/Intro.lean originy}}
```



```output info
{{#example_out Examples/Intro.lean originy}}
```

这可以用来定义接受结构体作为参数的函数。
例如，点的相加是通过将底层坐标值相加来完成的。
应该有这样的情况 `{{#example_in Examples/Intro.lean addPointsEx}}` 返回结果为

```output info
{{#example_out Examples/Intro.lean addPointsEx}}
```

该函数接受两个 `Points` 类型的参数，分别称为 `p1` 和 `p2`。
返回的点基于 `p1` 和 `p2` 的 `x` 和 `y` 字段：

```lean
{{#example_decl Examples/Intro.lean addPoints}}
```

类似地，两点之间的距离可以写成两点在 `x` 和 `y` 分量差的平方和的平方根形式：

```lean
{{#example_decl Examples/Intro.lean distance}}
```

例如，点 (1, 2) 和 (5, -1) 之间的距离为 5：

```lean
{{#example_in Examples/Intro.lean evalDistance}}
```



```output info
{{#example_out Examples/Intro.lean evalDistance}}
```

多个结构可能具有相同的字段名称。
例如，一个三维点数据类型可能共享字段 `x` 和 `y`，并且可以用相同的字段名称进行实例化：

```lean
{{#example_decl Examples/Intro.lean Point3D}}

{{#example_decl Examples/Intro.lean origin3D}}
```

这意味着在使用花括号语法时必须知道结构的预期类型。
如果类型未知，Lean 将无法实例化这个结构。
例如，

```lean
{{#example_in Examples/Intro.lean originNoType}}
```

**引言**

本文将介绍 LEAN 定理证明的基本原理和步骤。LEAN 是一种基于依赖类型理论的交互式证明助理，能够帮助数学家和计算机科学家以精确且形式化的方式进行证明。LEAN 提供了一种表达定理和构造证明的形式化语言，并通过机器验证来保证证明的正确性。

**LEAN 定理证明的基本原理**

LEAN 定理证明的基本原理基于类型论和构造主义数学的思想。一个证明在 LEAN 中是一个由多个表达式组成的序列，每个表达式都具有一个特定的类型。通过不断应用 LEAN 中的推理规则，可以逐步生成一个证明序列，直到证明一个目标。LEAN 保证每一步的应用都是正确的，并且可以通过机器验证来验证证明的正确性。

**LEAN 定理证明的步骤**

1. **定义问题和目标**：在开始证明之前，需要明确定义问题和想要证明的目标。问题可以是一个数学定理或一个计算机科学问题。目标是对问题的具体陈述或解答。

2. **建立证明的证明类型**：在 LEAN 中，需要为证明建立一个合适的证明类型。这个类型定义了证明的形式和结构。在证明类型中，需要定义所有需要的定义、引理和推理规则。

3. **构造证明序列**：根据证明类型，逐步构造证明序列。每一步都需要应用适当的推理规则，将一个表达式转化为另一个表达式，直到证明满足目标。

4. **机器验证**：完成证明序列后，可以使用 LEAN 提供的机器验证工具来验证证明的正确性。这个工具可以检查每个推理步骤的正确性，并检查证明是否满足所有的推理规则。

5. **完善证明细节**：一旦证明被机器验证通过，可以进一步完善证明的细节，以提高证明的可读性和可理解性。可以添加注释、解释性文字和结构化证明的组织等。

**总结**

LEAN 定理证明提供了一种精确且形式化的方式来进行数学和计算机科学的证明。它基于类型论和构造主义数学的原理，并通过机器验证来保证证明的正确性。使用 LEAN，数学家和计算机科学家可以以一种直观且可验证的方式进行证明，提高证明的效率和准确性。

```output error
{{#example_out Examples/Intro.lean originNoType}}
```

通常情况下，可以通过提供类型注解来解决这个问题。

例如，当使用 LEAN 证明定理时，我们可能会遇到类型错误的问题。为了解决这个问题，我们可以为表达式或变量提供类型注解，显式告知 LEAN 编译器正确的类型信息。

类型注解的示例如下：

```
def example : ℕ := 5
```

在上述示例中，我们明确告诉 LEAN 编译器 `example` 的类型为自然数类型 (`ℕ`)，并将其赋值为 `5`。

通过提供类型注解，LEAN 编译器可以准确地推断出表达式或变量的类型，从而避免类型错误。类型注解在 LEAN 中被广泛应用，特别是在繁杂的证明过程中，有助于提高代码的可读性和可维护性。

因此，当遇到类型错误时，我们可以尝试通过提供类型注解来解决问题，从而改善情况。

```lean
{{#example_in Examples/Intro.lean originWithAnnot}}
```



```output info
{{#example_out Examples/Intro.lean originWithAnnot}}
```

为了使程序更加简洁，Lean 还允许在花括号内放置结构类型注释。

```lean
{{#example_in Examples/Intro.lean originWithAnnot2}}
```



```output info
{{#example_out Examples/Intro.lean originWithAnnot2}}
```

## 更新结构

想象一个函数 `zeroX`，它会将 `Point` 的 `x` 字段替换为 `0.0`。
在大多数编程语言社区中，这句话意味着 `x` 指向的内存位置将被新值覆盖。
然而，Lean 没有可变状态。
在函数式编程社区中，这种语句几乎总是指的是分配一个新的 `Point`，其中 `x` 字段指向新值，而其他字段仍指向输入中的原始值。
一种编写 `zeroX` 的方法是按照字面意义上的描述进行，填写新值给 `x` 并手动转移 `y` 的值：

```lean
{{#example_decl Examples/Intro.lean zeroXBad}}
```

然而，这种编程样式也有缺点。
首先，如果向一个结构中添加新的字段，那么必须更新所有更新任何字段的地方，导致维护困难。
其次，如果结构中包含多个相同类型的字段，那么存在重复或交换字段内容的风险。
最后，程序变得冗长和繁琐。

Lean对于替换结构中的某些字段并保留其他字段提供了一种便捷的语法。
这是通过在结构初始化时使用`with`关键字来实现的。
未修改的字段出现在`with`之前，新的字段出现在之后。
例如，可以只用新的`x`值来编写`zeroX`：

```lean
{{#example_decl Examples/Intro.lean zeroX}}
```

请记住，这个结构更新语法并不修改现有的值——它创建了一些与旧值共享一些字段的新值。例如，给定点 `fourAndThree`：

```lean
{{#example_decl Examples/Intro.lean fourAndThree}}
```

对它进行评估，然后使用 `zeroX` 对其进行更新并再次进行评估，结果将得到原始值：

```lean
{{#example_in Examples/Intro.lean fourAndThreeEval}}
```



```output info
{{#example_out Examples/Intro.lean fourAndThreeEval}}
```



```lean
{{#example_in Examples/Intro.lean zeroXFourAndThreeEval}}
```



```output info
{{#example_out Examples/Intro.lean zeroXFourAndThreeEval}}
```



```lean
{{#example_in Examples/Intro.lean fourAndThreeEval}}
```



```output info
{{#example_out Examples/Intro.lean fourAndThreeEval}}
```

**LEAN 定理证明**

结构更新不会修改原结构，这一事实的一个结果是在计算新值时更容易进行推理，所有对于旧结构的引用在所有提供的新值中都继续引用相同的字段值。

## 背后的逻辑

每个结构都有一个“构造函数”。这里，“构造函数”这个术语可能会引起混淆。与Java或Python等语言中的构造函数不同，Lean中的构造函数并不是在初始化数据类型时要执行的任意代码。相反，构造函数只是简单地收集要存储在新分配的数据结构中的数据。不能提供一个自定义构造函数来预处理数据或拒绝无效的参数。这实际上是一个词“构造函数”在两个上下文中具有不同但相关的含义的情况。

默认情况下，名为 `S` 的结构的构造函数的名称为 `S.mk`。这里，`S` 是一个命名空间限定符，而 `mk` 是构造函数本身的名称。除了使用大括号初始化语法之外，也可以直接应用构造函数。

```lean
{{#example_in Examples/Intro.lean checkPointMk}}
```

然而，一般来说，这种写法并不被认为是良好的 Lean 风格，甚至 Lean 在返回其反馈时也使用标准的结构初始化器语法。

```output info
{{#example_out Examples/Intro.lean checkPointMk}}
```

构造函数具有函数类型，这意味着它们可以在需要函数的任何地方使用。例如，`Point.mk` 是一个函数，它接受两个 `Float`（分别是 `x` 和 `y`）并返回一个新的 `Point`。

```lean
{{#example_in Examples/Intro.lean Pointmk}}
```



```output info
{{#example_out Examples/Intro.lean Pointmk}}
```

要重写结构体的构造函数名字，需要在开头写上两个冒号。例如，要使用 `Point.mk` 代替 `Point.point`，可以写成：

```lean
{{#example_decl Examples/Intro.lean PointCtorName}}
```

除了构造函数之外，还为结构的每个字段定义了一个访问器函数。这些函数与字段具有相同的名称，处于结构的命名空间中。对于 `Point` 结构，生成了访问器函数 `Point.x` 和 `Point.y`。

```lean
{{#example_in Examples/Intro.lean Pointx}}
```



```output info
{{#example_out Examples/Intro.lean Pointx}}
```



```lean
{{#example_in Examples/Intro.lean Pointy}}
```



```output info
{{#example_out Examples/Intro.lean Pointy}}
```

事实上，正如花括号结构的构造语法被转换为对结构体构造函数的调用一样，在`addPoints`的先前定义中的语法`p1.x`被转换为对`Point.x`访问器的调用。
也就是说，`{{＃example_in Examples/Intro.lean originx}}`和`{{＃example_in Examples/Intro.lean originx1}}`都会产生相同的结果。

```output info
{{#example_out Examples/Intro.lean originx1}}
```

访问器点表示法不仅可用于结构字段，还可用于接受任意数量参数的函数。
更一般地，访问器表示法的形式为`TARGET.f ARG1 ARG2 ...`。
如果`TARGET`具有类型`T`，则调用名为`T.f`的函数。
`TARGET`成为其左侧类型为`T`的最左参数，通常情况下是第一个参数，但不总是如此，`ARG1 ARG2 ...`按顺序作为剩余参数提供。
例如，即使`String`不是具有`append`字段的结构，也可以使用访问器表示法从字符串中调用`String.append`。

```lean
{{#example_in Examples/Intro.lean stringAppendDot}}
```



```output info
{{#example_out Examples/Intro.lean stringAppendDot}}
```

在这个例子中，`TARGET` 代表 `"one string"`，而 `ARG1` 代表 `" and another"`。

`Point.modifyBoth` 函数（即在 `Point` 命名空间中定义的 `modifyBoth` 函数）将一个函数应用于 `Point` 中的两个字段：

```lean
{{#example_decl Examples/Intro.lean modifyBoth}}
```

即使 `Point` 参数出现在函数参数之后，也可以使用点符号表示法来使用它：

```lean
{{#example_in Examples/Intro.lean modifyBothTest}}
```



```output info
{{#example_out Examples/Intro.lean modifyBothTest}}
```

在这种情况下，`TARGET` 表示 `fourAndThree`，而 `ARG1` 是 `Float.floor`。
这是因为访问符号的目标被用作第一个参数，其中类型匹配，而不一定是第一个参数。

## 练习

* 定义一个名为 `RectangularPrism` 的结构，包含一个 `Float` 类型的高度、宽度和深度。
* 定义一个名为 `volume : RectangularPrism → Float` 的函数，用于计算矩形棱柱的体积。
* 定义一个名为 `Segment` 的结构，用它的端点表示一条线段，并定义一个名为 `length : Segment → Float` 的函数，用于计算线段的长度。`Segment` 应该最多有两个字段。
* `RectangularPrism` 的声明引入了哪些名字？
* 下面的 `Hamster` 和 `Book` 的声明引入了哪些名字？它们的类型是什么？

```lean
{{#example_decl Examples/Intro.lean Hamster}}
```



```lean
{{#example_decl Examples/Intro.lean Book}}
```

