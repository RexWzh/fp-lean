# 函数和定义

在 Lean 中，使用 `def` 关键字引入定义。例如，要定义名为 `helloNameVal` 的变量，并将其指向字符串 `"Hello, Lean!"`，可以写成：

```lean
{{#example_decl Examples/Intro.lean hello}}
```

在 Lean 中，使用冒号等号 `:=` 来定义新的名称，而不是 `=`。这是因为 `=` 用于描述已存在表达式之间的相等关系，使用两个不同的运算符有助于防止混淆。

在 `{{#example_in Examples/Intro.lean helloNameVal}}` 的定义中，表达式 `{{#example_out Examples/Intro.lean helloNameVal}}` 足够简单，Lean 可以自动确定定义的类型。然而，大多数定义并不是那么简单，因此通常需要添加类型。这是通过在定义的名称后面加上冒号来完成的。

```lean
{{#example_decl Examples/Intro.lean lean}}
```

现在我们已经定义了这些名字，可以开始使用它们了，所以

``` Lean
{{#example_in Examples/Intro.lean helloLean}}
```

对于算法和程序的正确性来说，证明是一个重要的步骤。LEAF 定理证明是一种流行的方法，用于验证并证明代码执行的正确性。下面将介绍 LEAF 定理证明的基本步骤和原则。

1. **定义问题**: 首先，我们需要明确定义问题，包括输入条件、输出条件和程序的预期行为。这有助于确保我们的证明是针对特定问题而进行的。

2. **推导规则**: LEAF 定理证明使用一组推导规则来推导出正确的证明。这些规则基于逻辑和数学定理，以及编程语言的语法和语义规则。这些规则被称为 "LEMMA"，它们构成了我们证明的基本构建模块。

3. **证明步骤**: 根据推导规则，我们按照一系列证明步骤进行推导。每个步骤都是基于前面步骤的结论，并应用适当的推导规则来得出新的结论。这些步骤应该是简单和可验证的，以确保证明的正确性。

4. **边界条件和循环不变量**: 在证明中，我们需要考虑边界条件和循环不变量。边界条件是对输入和输出的限制，而循环不变量是循环执行期间始终成立的陈述。这些条件对于证明程序的正确性非常关键。

5. **归纳法**: 在证明中，归纳法是一种常用的推理方法。我们使用归纳法来证明程序在不同输入情况下的正确性。通过证明基本情况和归纳步骤，我们可以推导出程序在所有情况下的正确性。

6. **可终止性**: 除了正确性之外，我们还需要确保程序是可终止的。这意味着程序在有限步骤内可以终止，而不会陷入无限循环。通常，我们使用循环不变量来证明程序的可终止性。

LEAF 定理证明可以帮助开发人员确保他们的程序在各种输入情况下都能产生正确的输出。它是一种严格和系统的方法，可以减少程序错误并提高代码质量。通过正确的证明，我们可以信任我们的程序并确保它们按照预期工作。

``` Lean info
{{#example_out Examples/Intro.lean helloLean}}
```

在 Lean 中，只有在定义后才能使用已定义的名称。

在许多语言中，函数的定义语法与其他值的定义语法不同。
例如，Python 函数定义以 `def` 关键字开头，而其他定义则使用等号定义。
在 Lean 中，函数使用与其他值相同的 `def` 关键字进行定义。
尽管如此，像 `hello` 这样的定义引入了直接指向其值的名称，而不是指向每次调用时返回相同结果的零参数函数。

## 定义函数

在 Lean 中有多种方法可以定义函数。最简单的方法是在定义类型之前，用空格分隔函数的参数。例如，一个将其参数加一的函数可以写成：

```lean
{{#example_decl Examples/Intro.lean add1}}
```

使用 `#eval` 测试这个函数得到的结果是 `{{#example_out Examples/Intro.lean add1_7}}`，和预期的一样：

```lean
{{#example_in Examples/Intro.lean add1_7}}
```

正如函数在每个参数之间添加空格进行运算一样，接受多个参数的函数也是通过在参数名称和类型之间添加空格来定义的。函数 `maximum` 接受两个 `Nat` 类型的参数 `n` 和 `k`，并返回一个 `Nat` 类型的结果，该结果等于这两个参数中的最大值。

```lean
{{#example_decl Examples/Intro.lean maximum}}
```

当一个已定义的函数，比如 `maximum`，被提供了参数后，结果是通过首先将参数名替换为提供的值，然后计算得到的结果体来确定的。例如：

```lean
{{#example_eval Examples/Intro.lean maximum_eval}}
```

表达式的类型可以指定为自然数（`Nat`）、整数（`Int`）和字符串（`String`）。
函数也是如此。
接受一个 `Nat` 并返回一个 `Bool` 的函数的类型是 `Nat → Bool`，接受两个 `Nat` 并返回一个 `Nat` 的函数的类型是 `Nat → Nat → Nat`。

作为特例，当直接使用 `#check` 来调用函数名时，Lean 会返回函数的签名。
输入 `{{#example_in Examples/Intro.lean add1sig}}`，输出结果为 `{{#example_out Examples/Intro.lean add1sig}}`。
然而，通过将函数名用括号括起来，我们可以“欺骗”Lean，从而显示函数的类型，因为这样会将函数视为普通表达式。
因此，`{{#example_in Examples/Intro.lean add1type}}` 输出结果为 `{{#example_out Examples/Intro.lean add1type}}`，
`{{#example_in Examples/Intro.lean maximumType}}` 输出结果为 `{{#example_out Examples/Intro.lean maximumType}}`。
函数类型的箭头也可以用 ASCII 中的替代形式 `->` 表示，所以上述函数类型也可以写作 `{{#example_out Examples/Intro.lean add1typeASCII}}` 和 `{{#example_out Examples/Intro.lean maximumTypeASCII}}`。

在幕后，所有函数实际上只需要一个参数。
看起来接受多个参数的函数（例如 `maximum`）实际上是接受一个参数然后返回一个新的函数。
这个新的函数接受下一个参数，这个过程会一直继续，直到不再需要更多的参数为止。
通过为多参数函数提供一个参数，我们可以看到这一点：`{{#example_in Examples/Intro.lean maximum3Type}}` 输出结果为 `{{#example_out Examples/Intro.lean maximum3Type}}`，
`{{#example_in Examples/Intro.lean stringAppendHelloType}}` 输出结果为 `{{#example_out Examples/Intro.lean stringAppendHelloType}}`。
使用返回函数的函数来实现多参数函数的方法被称为 _currying_，得名于数学家 Haskell Curry。
函数箭头向右关联，这意味着 `Nat → Nat → Nat` 应该加括号写作 `Nat → (Nat → Nat)`。

### 练习

 * 定义一个类型为 `String -> String -> String -> String` 的函数 `joinStringsWith`，它通过将第一个参数放置在第二个参数和第三个参数之间创建一个新的字符串。
   `{{#example_eval Examples/Intro.lean joinStringsWithEx 0}}` 应该求值为 `{{#example_eval Examples/Intro.lean joinStringsWithEx 1}}`。
 `joinStringsWith ": "` 的类型是什么？请用 Lean 来检查你的答案。

```lean
def joinStringsWith {α : Type} : List α → String := _

#check joinStringsWith   -- output: joinStringsWith : Π {α : Type}, List α → String
```

答案是 `Π {α : Type}, List α → String`。

## 定义函数

`volume` 是一个具有类型 `Nat → Nat → Nat → Nat` 的函数，它计算给定高度、宽度和深度的长方体体积。

```lean
def volume : Nat → Nat → Nat → Nat := _

#check volume   -- output: volume : Nat → Nat → Nat → Nat
```

这样就定义了这个函数，但是我们还没有给出函数体。

```lean
{{#example_decl Examples/Intro.lean StringTypeDef}}
```

然后，可以使用 ``Str`` 作为定义的类型，而不是 ``String``：

```lean
{{#example_decl Examples/Intro.lean aStr}}
```

这个方法之所以有效，是因为类型遵循了 Lean 的其他规则。
类型本身也是表达式，在表达式中，一个定义过的名称可以被它的定义所替代。
因为 ``Str`` 被定义为 ``String``，所以 ``aStr`` 的定义是合理的。

### 你可能会遇到的问题

在使用类型定义进行实验时，会遇到 Lean 支持重载整数字面量的复杂方式。
如果 ``Nat`` 太短，可以定义一个更长的名称 ``NaturalNumber``：

```lean
{{#example_decl Examples/Intro.lean NaturalNumberTypeDef}}
```

然而，使用 ``自然数`` 作为定义的类型而不是 ``Nat`` 并没有产生预期的效果。
特别是，下面的定义：

```lean
{{#example_in Examples/Intro.lean thirtyEight}}
```

导致以下错误的结果：

```output error
{{#example_out Examples/Intro.lean thirtyEight}}
```

这个错误的原因是 Lean 允许对数字字面量进行**重载**。
如果有意义，自然数字面量可以用于新类型，就好像这些类型已经内置到系统中一样。
这是 Lean 的使命的一部分，使得使用数字表示数学变得更加方便，不同的数学分支使用数字表示法的目的也有所不同。
允许重载的具体特性并不会在寻找重载时用定义名替换所有已定义的定义名，这就导致了上面的错误消息。

解决这个限制的一种方法是在定义的右侧提供 `Nat` 类型，使得 `Nat` 的重载规则可以用于 `38`：

```lean
{{#example_decl Examples/Intro.lean thirtyEightFixed}}
```

定义仍然是类型正确的，因为`{{#example_eval Examples/Intro.lean NaturalNumberDef 0}}` 和 `{{#example_eval Examples/Intro.lean NaturalNumberDef 1}}` 是相同类型的——根据定义！

另一个解决方案是为 `NaturalNumber` 定义一个重载函数，使其和 `Nat` 的重载函数等效。
然而，这需要 Lean 的更高级特性。

最后，使用 `abbrev` 而不是 `def` 来定义 `Nat` 的新名称，允许重载解析将定义的名称替换为其定义。
使用 `abbrev` 编写的定义始终会展开。
例如，

```lean
{{#example_decl Examples/Intro.lean NTypeDef}}
```

# LEAN 定理证明

## 引言

LEAN 是一种交互式定理证明工具，用于形式化验证数学定理。在 LEAN 中定义了一套严密的逻辑系统，同时提供了一种编程语言作为验证的工具。

本文将介绍 LEAN 中推导定理的基本步骤和方法。

## 定理证明的基本结构

在 LEAN 中，定理证明的基本结构由以下几个部分组成：

1. 声明定理：使用关键字 `theorem` 或 `lemma` 声明需要证明的定理。

2. 证明状态：使用关键字 `begin ... end` 创建一个证明状态，其中通过一系列步骤来逐步推导出定理的正确性。

3. 证明步骤：使用关键字 `assume`、`show`、`apply`、`have` 等来引入前提、展示目标、应用已知定理以及证明中间结果。

4. 结束证明：使用关键字 `end` 结束证明。

## 定理证明的示例

下面通过一个简单的示例来演示 LEAN 中定理证明的过程。假设我们要证明以下定理：

**定理：任意两个实数的和等于它们的交换顺序的和。**

首先使用 `theorem` 关键字声明定理：

```lean
theorem add_comm : ∀ (a b : ℝ), a + b = b + a.
```

接下来，使用 `begin ... end` 创建一个证明状态：

```lean
begin
```

在证明状态中，我们可以使用 `assume` 关键字引入前提：

```lean
  assume a b : ℝ,
```

然后，使用 `show` 关键字展示目标：

```lean
  show a + b = b + a,
```

接下来，我们可以使用 `apply` 关键字来应用由已知定理推导出的中间结果：

```lean
  apply add_comm,
```

最后，使用 `end` 关键字结束证明：

```lean
end
```

完成以上步骤后，我们就完成了这个简单定理的证明。

## 结论

通过使用 LEAN 工具，我们可以以交互式的方式进行定理证明。LEAN 提供了一套严格的逻辑系统，使得定理证明更加规范和可靠。

在实践中，定理证明通常需要更加复杂的推理过程和更多的中间步骤。但是基本的证明步骤和结构在不同的定理证明中是通用的。通过不断练习和实践，我们可以逐渐提高定理证明的技巧和效率。

```lean
{{#example_decl Examples/Intro.lean thirtyNine}}
```

没有问题地被接受。

在幕后，一些定义在重载解析过程中被内部标记为可展开，而其他定义则没有被标记。
要被展开的定义被称为 _可简化的_。
对可简化性的控制是使 Lean 能够扩展的关键：完全展开所有定义可能导致非常大的类型，这对于计算机的处理速度很慢，对用户理解上也很困难。
使用 `abbrev` 产生的定义会被标记为可简化的。