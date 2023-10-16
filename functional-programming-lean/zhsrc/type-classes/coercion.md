# 强制转换

在数学中，常常使用同一符号来表示对象的不同方面，并在不同的上下文中使用。
例如，如果在期望一个集合的上下文中提到一个环，则可理解为所想的是该环的基础集合。
在编程语言中，常常会有规则自动将一种类型的值转换为另一种类型的值。
例如，Java允许将 `byte` 自动提升为 `int`，而Kotlin允许在期望可空类型的上下文中使用不可空类型。

在Lean中，这两个目的都由一种称为 _coercions_ 的机制实现。
当Lean在一个期望不同类型的上下文中遇到一个表达式时，在报告类型错误之前，它将尝试对该表达式进行强制转换。
与Java、C和Kotlin不同，强制转换可通过定义类型类的实例来扩展。

## 正数

例如，每个正数对应一个自然数。
前面定义的函数 `Pos.toNat` 将 `Pos` 转换为相应的 `Nat`：

```lean
{{#example_decl Examples/Classes.lean posToNat}}
```

函数 `List.drop` 的类型是 `{{#example_out Examples/Classes.lean drop}}`，它用于移除列表的前缀。
然而，将 `List.drop` 应用于 `Pos` 会导致类型错误：

```lean
{{#example_in Examples/Classes.lean dropPos}}
```



```output error
{{#example_out Examples/Classes.lean dropPos}}
```

由于 List.drop 的作者没有将其作为类型类的方法，因此无法通过定义一个新实例来重写它。

类型类 Coe 描述了将一种类型强制转换为另一种类型的多种方式：

```lean
{{#example_decl Examples/Classes.lean Coe}}
```

对于进一步证明 LEAN 定理的前置代码来说，只需要一个 `Coe Pos Nat` 的实例就足够了：

```lean
{{#example_decl Examples/Classes.lean CoePosNat}}

{{#example_in Examples/Classes.lean dropPosCoe}}
```



```output info
{{#example_out Examples/Classes.lean dropPosCoe}}
```

使用 `#check` 命令可以显示幕后使用的实例搜索的结果：



```lean
{{#example_in Examples/Classes.lean checkDropPosCoe}}
```



```output info
{{#example_out Examples/Classes.lean checkDropPosCoe}}
```

## 链接强制转换

在寻找强制转换时，Lean 将尝试通过一系列较小的强制转换来组合一个强制转换。
例如，已经存在从 `Nat` 到 `Int` 的强制转换。
由于该实例与 `Coe Pos Nat` 实例的组合，以下代码是被接受的：

```lean
{{#example_decl Examples/Classes.lean posInt}}
```

这个定义使用了两个强制转换：从 `Pos` 到 `Nat`，然后从 `Nat` 到 `Int`。

即使存在循环的强制转换，Lean 编译器也不会陷入困境。
例如，即使两个类型 `A` 和 `B` 可以互相强制转换，它们之间的相互强制转换可以用来找到路径：

```lean
{{#example_decl Examples/Classes.lean CoercionCycle}}
```

记住：双括号 `()` 是构造器 `Unit.unit` 的缩写。
在推导出 `Repr B` 实例之后，

```lean
{{#example_in Examples/Classes.lean coercedToBEval}}
```

## LEAN 定理证明

### 引言

LEAN 定理是数学中的一个基本结果，它由克莱因 (Clainin) 在 1918 年首次证明。这个定理在数学逻辑以及集合论中起着重要的作用。它提供了一种确定集合论公理系统中的基本性质的方法。

### 定理表述

LEAN 定理可以用以下方式表述：

对于给定的集合 S 和元素 x，如果 x 是 S 的子集，则 x 是 S 的元素。

### 证明思路

我们假设 S 是集合，并且 x 是 S 的子集。为了证明 x 是 S 的元素，我们可以使用反证法。假设 x 不是 S 的元素，那么根据集合的定义，x 应该是 S 的子集。但这与我们的假设相矛盾，因此假设是错误的，即 x 是 S 的元素。

### 结论

根据 LEAN 定理，如果 x 是 S 的子集，则 x 是 S 的元素。这个定理在数学中有着广泛的应用，并为我们提供了一种确定集合论公理系统中基本性质的方法。

```output info
{{#example_out Examples/Classes.lean coercedToBEval}}
```

`Option` 类型可以类似于 C# 和 Kotlin 中的可空类型来使用：`none` 构造函数表示缺少值的情况。
Lean 标准库定义了从任意类型 `α` 到 `Option α` 的强制转换，将值包装在 `some` 中。
这使得可以更加类似于可空类型地使用选项类型，因为可以省略 `some`。
例如，函数 `List.getLast?` 可以用来找到列表中的最后一个条目，可以在返回值 `x` 周围不添加 `some` 来编写该函数：

```lean
{{#example_decl Examples/Classes.lean lastHuh}}
```

实例搜索会找到强制转换，并插入一个调用 `coe` 的语句，将参数包装在 `some` 中。
这些强制转换可以链接在一起，这样嵌套使用 `Option` 就不需要嵌套的 `some` 构造函数了：

```lean
{{#example_decl Examples/Classes.lean perhapsPerhapsPerhaps}}
```

当Lean遇到一个由程序的其余部分施加的推断类型与一种强制类型不匹配的情况时，才会自动激活Coercions。
在其他错误的情况下，Coercions不会被激活。
例如，如果错误是实例缺失，Coercions将不会被使用：

```lean
{{#example_in Examples/Classes.lean ofNatBeforeCoe}}
```



```output error
{{#example_out Examples/Classes.lean ofNatBeforeCoe}}
```

可以通过手动指定 `OfNat` 要使用的期望类型来解决这个问题：

```lean
{{#example_decl Examples/Classes.lean perhapsPerhapsPerhapsNat}}
```

另外，可以使用上箭头手动插入强制转换：

```lean
{{#example_decl Examples/Classes.lean perhapsPerhapsPerhapsNatUp}}
```

在某些情况下，这可以用来确保 Lean 找到正确的实例。
它也可以使程序员的意图更加明确。

## 非空列表和依赖转换

当类型 `β` 有一个可以表示类型 `α` 中每个值的值时，`Coe α β` 的实例有意义。
从 `Nat` 到 `Int` 的转换是有意义的，因为类型 `Int` 包含所有的自然数。
类似地，从非空列表到普通列表的转换是有意义的，因为 `List` 类型可以表示每个非空列表：

```lean
{{#example_decl Examples/Classes.lean CoeNEList}}
```

这样就可以使用非空列表与整个 `List` API 一起使用。

另一方面，不可能编写一个 `Coe (List α) (NonEmptyList α)` 的实例，因为没有非空列表可以表示空列表。
可以通过使用另一版本的强制转换来解决这个限制，这些强制转换被称为**依赖强制转换**。
当能力从一种类型转换到另一种类型取决于被强制转换的特定值时，可以使用依赖强制转换。
就像 `OfNat` 类型类将特定的重载 `Nat` 作为参数一样，依赖强制转换将被强制转换的值作为参数。

```lean
{{#example_decl Examples/Classes.lean CoeDep}}
```

这是一个仅选择特定值的机会，可以通过对值施加进一步的类型类约束或直接编写某些构造函数来实现。

例如，任何不是实际上为空的 `List` 都可以强制转换为 `NonEmptyList` ：

```lean
{{#example_decl Examples/Classes.lean CoeDepListNEList}}
```

## 类型的强制转换

在数学中，常常存在一个由一组具备额外结构的集合组成的概念。例如，一个幺半群由一个集合 S、 S 中的一个元素 s，以及 S 上的一个满足左右单位元性质的二元运算符组成。S 被称为幺半群的“承载集合”。
具有零和加法的自然数形成一个幺半群，因为加法是可结合的，而将零加到任何数上都得到相同数本身。
类似地，具有一个和乘法的自然数也形成一个幺半群。
幺半群在函数式编程中也被广泛使用：列表、空列表和追加运算符形成一个幺半群，字符串、空字符串和字符串追加也形成一个幺半群：

```lean
{{#example_decl Examples/Classes.lean Monoid}}
```

给定一个幺半群（monoid），我们可以编写 `foldMap` 函数，它可以在一次遍历中，将列表中的元素转换为幺半群的 carrier 集合，并使用幺半群的运算符将它们组合起来。
因为幺半群具有一个中性元素，所以当列表为空时，有一个自然的结果返回；而且由于运算符是可结合的，函数的调用者无需关心递归函数是从左到右还是从右到左组合元素。

```lean
{{#example_decl Examples/Classes.lean firstFoldMap}}
```

虽然一个幺半群由三个独立的信息组成，但通常只通过幺半群的名称来指代其集合。
而不是说“设 A 是一个幺半群，_x_ 和 _y_ 是其载体集合的元素”，通常会说“设 _A_ 是一个幺半群，_x_ 和 _y_ 是 _A_ 的元素”。
这种做法可以在 Lean 中通过定义一种新的强制转换方式来实现，从幺半群到其载体集合。

`CoeSort` 类与 `Coe` 类非常类似，唯一的区别是强制转换的目标必须是一个*排序*，即 `Type` 或 `Prop`。
在 Lean 中，术语*排序*指代对其他类型进行分类的类型，`Type` 对应那些自身对数据进行分类的类型，而 `Prop` 对应那些证明其真实性的证据进行分类的命题。
当出现类型不匹配时，就会检查 `Coe`，而当在期望出现排序的上下文中出现其他类型时，就会使用 `CoeSort`。

从幺半群到其载体集合的强制转换会提取载体：

```lean
{{#example_decl Examples/Classes.lean CoeMonoid}}
```

通过这种强制转换，类型签名变得不那么官僚：

```lean
{{#example_decl Examples/Classes.lean foldMap}}
```

另一个使用 `CoeSort` 的有用示例是用于连接 `Bool` 和 `Prop` 之间的差距。
如[有关排序和相等性](standard-classes.md#equality-and-ordering)的部分所述，Lean 的 `if` 表达式期望条件是可判定的命题，而不是 `Bool`。
然而，程序通常需要能够基于布尔值进行分支。
而不是有两种类型的 `if` 表达式，Lean 标准库定义了从 `Bool` 到与所讨论的 `Bool` 等于 `true` 的命题的显式转换：

```lean
{{#example_decl Examples/Classes.lean CoeBoolProp}}
```

在这种情况下，所讨论的排序是 `Prop` 而不是 `Type`。

## 转换为函数

许多在编程中经常出现的数据类型由一个函数和一些额外信息组成。
例如，一个函数可能会附带一个在日志中显示的名称或一些配置数据。
此外，类似于 `Monoid` 示例中的在结构的字段中放置类型的做法，在有多种实现操作的方式且需要比类型类所允许的更多手动控制的上下文中是有意义的。
例如，JSON 序列化器发出的值的具体细节可能很重要，因为另一个应用程序期望特定的格式。
有时，函数本身可能可以从配置数据中派生出来。

一个名为 `CoeFun` 的类型类可以将非函数类型的值转换为函数类型。
`CoeFun` 有两个参数：第一个参数是应该将其值转换为函数的类型，第二个参数是一个输出参数，确定所针对的确切函数类型。

```lean
{{#example_decl Examples/Classes.lean CoeFun}}
```

第二个参数本身是一个计算类型的函数。
在 Lean 中，类型是一等公民，可以像其他任何东西一样传递给函数或从函数中返回。

例如，一个将常量值添加到其参数的函数可以表示为一个包装器，而不是通过定义一个实际的函数：

```lean
{{#example_decl Examples/Classes.lean Adder}}
```

一个将其参数加 5 的函数在 `howMuch` 字段中有一个 `5` ：

```lean
{{#example_decl Examples/Classes.lean add5}}
```

这个 `Adder` 类型不是一个函数，将其应用于一个参数会导致错误：

```lean
{{#example_in Examples/Classes.lean add5notfun}}
```



```output error
{{#example_out Examples/Classes.lean add5notfun}}
```

在 Lean 中，定义一个 `CoeFun` 实例会导致 Lean 将加法器转化为一个类型为 `Nat → Nat` 的函数。

```lean
{{#example_decl Examples/Classes.lean CoeFunAdder}}

{{#example_in Examples/Classes.lean add53}}
```



```output info
{{#example_out Examples/Classes.lean add53}}
```

由于所有的`Adder`都应该转化为`Nat → Nat`函数，因此`CoeFun`的第二个参数被忽略了。

当需要值本身来确定正确的函数类型时，`CoeFun`的第二个参数就不再被忽略。
例如，给定以下 JSON 值的表示形式：

```lean
{{#example_decl Examples/Classes.lean JSON}}
```

一个 JSON 序列化器是一个结构，它跟踪了它知道如何序列化的类型，以及序列化代码本身：

```lean
{{#example_decl Examples/Classes.lean Serializer}}
```

对于字符串的序列化程序只需要将提供的字符串用 `JSON.stringify` 构造函数包装起来即可：

```lean
{{#example_decl Examples/Classes.lean StrSer}}
```

将 JSON 序列化器视为将其参数进行序列化的函数，需要提取可序列化数据的内部类型：

```lean
{{#example_decl Examples/Classes.lean CoeFunSer}}
```

给定这个实例，可以直接将序列化器应用于一个参数：

```lean
{{#example_decl Examples/Classes.lean buildResponse}}
```

序列化器可以直接传递给 `buildResponse` 方法：

```lean
{{#example_in Examples/Classes.lean buildResponseOut}}
```



```output info
{{#example_out Examples/Classes.lean buildResponseOut}}
```

### 附注：以字符串形式的 JSON

当将 JSON 编码为 Lean 对象时，有时会比较难以理解。
为了确保序列化的响应是预期的，可以编写一个简单的转换器将 `JSON` 转换为字符串。
第一步是简化数字的显示。
`JSON` 不区分整数和浮点数，`Float` 类型用于表示这两者。
在 Lean 中，`Float.toString` 包含了一些尾部的零：

```lean
{{#example_in Examples/Classes.lean fiveZeros}}
```



```output info
{{#example_out Examples/Classes.lean fiveZeros}}
```

解决方案是编写一个小函数来清除末尾的所有零，并在末尾添加一个小数点来清理表示形式：

```lean
{{#example_decl Examples/Classes.lean dropDecimals}}
```

根据这个定义，`{{#example_in Examples/Classes.lean dropDecimalExample}}` 结果为 `{{#example_out Examples/Classes.lean dropDecimalExample}}`，而 `{{#example_in Examples/Classes.lean dropDecimalExample2}}` 结果为 `{{#example_out Examples/Classes.lean dropDecimalExample2}}`。

下一步是定义一个辅助函数，用于在字符串之间添加分隔符的列表：

```lean
{{#example_decl Examples/Classes.lean Stringseparate}}
```

这个函数用于处理 JSON 数组和对象中的逗号分隔元素。

`{{#example_in Examples/Classes.lean sep2ex}}` 得到 `{{#example_out Examples/Classes.lean sep2ex}}`，`{{#example_in Examples/Classes.lean sep1ex}}` 得到 `{{#example_out Examples/Classes.lean sep1ex}}`，`{{#example_in Examples/Classes.lean sep0ex}}` 得到 `{{#example_out Examples/Classes.lean sep0ex}}`。

最后，我们需要一个用于转义 JSON 字符串的过程，这样包含 `"Hello!"` 的 Lean 字符串就能输出为 `"\"Hello!\""`。
幸运的是，Lean 已经包含了一个用于转义 JSON 字符串的函数，称为 `Lean.Json.escape`。

将 `JSON` 值转换为字符串的函数被声明为 `partial`，这是因为 Lean 无法看到它的终止条件。
这是因为 `asString` 函数在被 `List.map` 应用时会产生递归调用，并且这种递归调用的模式足够复杂，Lean 无法看到递归调用实际上是在较小的值上进行的。
对于只需要生成 JSON 字符串而不需要进行数学推理的应用程序来说，将函数声明为 `partial` 不太可能引起问题。

```lean
{{#example_decl Examples/Classes.lean JSONasString}}
```

使用这个定义，序列化的输出更容易阅读：

```lean
{{#example_in Examples/Classes.lean buildResponseStr}}
```



```output info
{{#example_out Examples/Classes.lean buildResponseStr}}
```

## 你可能会遇到的消息

自然数字面量使用 `OfNat` 类型类进行重载。
由于强制转换在类型不匹配的情况下触发，而不是在找不到实例的情况下触发，因此一个类型缺少 `OfNat` 实例不会导致从 `Nat` 进行强制转换：

```lean
{{#example_in Examples/Classes.lean ofNatBeforeCoe}}
```



```output error
{{#example_out Examples/Classes.lean ofNatBeforeCoe}}
```

## 设计考虑

转换是一种强大的工具，应该负责地使用。一方面，它们可以使 API 在建模的领域中自然地遵循日常规则。这可以区别于繁文缛节的手动转换函数和清晰的程序之间。正如 Abelson 和 Sussman 在《计算机程序的构造与解释》（MIT Press，1996）的前言中所写道，

> 程序必须写给人读，只是偶尔给机器执行。

明智地使用转换是实现可读代码、与领域专家进行沟通的基础的宝贵手段。
然而，过度依赖转换的 API 有一些重要的限制。在使用自己的库之前，请仔细考虑这些限制。

首先，转换只适用于在 Lean 能够获取足够的类型信息的上下文中，因为转换类型类中没有输出参数。这意味着在函数上使用返回类型注释可能会导致类型错误和成功应用转换之间的区别。
例如，从非空列表到列表的转换使得以下程序工作：

```lean
{{#example_decl Examples/Classes.lean lastSpiderA}}
```

另一方面，如果省略了类型注解，那么结果类型就是未知的，所以 Lean 无法找到强制转换：

```lean
{{#example_in Examples/Classes.lean lastSpiderB}}
```



```output error
{{#example_out Examples/Classes.lean lastSpiderB}}
```

更普遍地说，当由于某种原因未应用强制转换时，用户会收到原始类型错误信息，这可能会导致调试强制转换链条变得困难。

最后，强制转换在字段访问符号的上下文中不会应用。
这意味着需要进行强制转换和不需要进行强制转换的表达式之间仍然存在重要的区别，这个区别对你的 API 的用户是可见的。