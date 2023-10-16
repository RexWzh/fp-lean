# 多态性

和大多数语言一样，Lean中的类型可以带有参数。
例如，类型`List Nat`描述的是自然数列表，`List String`描述的是字符串列表，而`List (List Point)`描述的是点的列表的列表。
这与C＃或Java等语言中的`List<Nat>`，`List<String>`或`List<List<Point>>`非常相似。
就像Lean使用空格来将参数传递给函数一样，它也使用空格来将参数传递给类型。

在函数式编程中，术语“多态性”通常指带有类型参数的数据类型和定义。
这与面向对象编程社区的做法不同，在面向对象编程中，术语通常指的是可能覆盖其超类某些行为的子类。
在本书中，“多态性”总是指这个词的第一个意义。
这些类型参数可以在数据类型或定义中使用，这使得可以使用任何通过将参数的名称替换为其他类型来得到的类型对数据类型或定义进行操作。

`Point`结构要求`x`和`y`字段都是`Float`类型。
然而，点并没有要求每个坐标都具有特定的表示方式。
一种多态版本的`Point`称为`PPoint`，它可以将类型作为参数，并使用该类型来表示两个字段：

```lean
{{#example_decl Examples/Intro.lean PPoint}}
```

就像函数定义的参数紧跟在被定义的名称之后一样，结构体的参数紧跟在结构体名称之后。
当没有更具体的名称可用时，Lean 常用希腊字母来命名类型参数。
`Type` 是用来描述其他类型的类型，因此 `Nat`、`List String` 和 `PPoint Int` 都具有类型 `Type`。

就像 `List` 一样，可以通过提供特定的类型作为其参数来使用 `PPoint`：

```lean
{{#example_decl Examples/Intro.lean natPoint}}
```

在这个例子中，两个字段都预期是 `Nat` 类型的。
就像一个函数通过用实际参数值替换其形式参数来被调用一样，把类型 `Nat` 作为参数提供给 `PPoint`，会得到一个结构体，其中字段 `x` 和 `y` 的类型是 `Nat`，因为参数名 `α` 已被参数类型 `Nat` 替换了。
在 Lean 中，类型是普通的表达式，因此给多态类型（像 `PPoint`）传递参数不需要任何特殊的语法。

定义也可以接受类型作为参数，从而使它们具有多态性。
函数 `replaceX` 用一个新值替换 `PPoint` 的 `x` 字段。
为了让 `replaceX` 能够适用于任何多态的点，它必须具有多态性。
这通过使其第一个参数成为点字段的类型来实现，后面的参数引用第一个参数的名字来实现。

```lean
{{#example_decl Examples/Intro.lean replaceX}}
```

简言之，当参数 `point` 和 `newX` 的类型中涉及到 `α` 时，它们是指向 _作为第一个参数提供的任何类型_。
这与函数参数名在函数体中引用提供的值的方式类似。

可以通过让 Lean 检查 `replaceX` 的类型，然后再检查 `replaceX Nat` 的类型来看到这一点。

```lean
{{#example_in Examples/Intro.lean replaceXT}}
```



```output info
{{#example_out Examples/Intro.lean replaceXT}}
```

这种函数类型包括第一个参数的 _name_，后面的参数在类型中引用这个 name。
就像函数应用的值是通过在函数体中用提供的参数值替换参数名来找到的一样，函数应用的类型是通过在函数的返回类型中用提供的值替换参数名来找到的。
提供第一个参数 `Nat` 导致类型中剩余部分的所有 `α` 的出现都被替换为 `Nat`：

```lean
{{#example_in Examples/Intro.lean replaceXNatT}}
```



```output info
{{#example_out Examples/Intro.lean replaceXNatT}}
```

因为剩余的参数没有显式命名，所以当提供更多的参数时，不会发生进一步的替换：

```lean
{{#example_in Examples/Intro.lean replaceXNatOriginT}}
```



```output info
{{#example_out Examples/Intro.lean replaceXNatOriginT}}
```



```lean
{{#example_in Examples/Intro.lean replaceXNatOriginFiveT}}
```



```output info
{{#example_out Examples/Intro.lean replaceXNatOriginFiveT}}
```

整个函数应用表达式的类型是通过将类型作为参数传递来确定的这一事实并不影响其能否进行求值。

```lean
{{#example_in Examples/Intro.lean replaceXNatOriginFiveV}}
```



```output info
{{#example_out Examples/Intro.lean replaceXNatOriginFiveV}}
```

多态函数通过采用一个命名的类型参数，并使后续类型引用该参数的名称来工作。
但是，类型参数并没有特殊的地方可以将其命名。
给定一个表示正负号的数据类型：

```lean
{{#example_decl Examples/Intro.lean Sign}}
```

在 LEAN 定理证明中，可以编写一个函数，其参数是一个符号。
如果参数为正数，函数将返回一个 `Nat`，而如果参数为负数，则返回一个 `Int`：

```lean
def function (s : sign) : Type :=
  sign.cases_on s ℕ ℤ
```

在这个例子中，`sign` 是一个由两个构造函数组成的简单类型。`sign` 类型的构造函数可以表示两个符号：正数和负数。根据参数 `s` 的值，函数 `function` 使用 `sign.cases_on` 函数进行模式匹配，返回不同的类型。当 `s` 是 `pos` 时，返回 `ℕ` 类型，即自然数；当 `s` 是 `neg` 时，返回 `ℤ` 类型，即整数。

使用该函数可以处理不同类型的输入，并根据输入的符号返回不同的结果。例如，如果将 `pos` 作为参数传递给函数 `function`，则返回的类型将是 `ℕ`；如果将 `neg` 作为参数传递给函数 `function`，则返回的类型将是 `ℤ`。

在 Lean 中，函数的参数和返回类型可以是任意类型，包括简单类型、复合类型和函数类型。使用模式匹配可以根据不同的情况返回不同的类型，从而使函数更加灵活和通用。

```lean
{{#example_decl Examples/Intro.lean posOrNegThree}}
```

由于类型是一等公民，可以使用 Lean 语言的普通规则进行计算，它们可以通过对数据类型进行模式匹配来进行计算。
当 Lean 检查这个函数时，它使用函数体中的 `match`-表达式与类型中的 `match`-表达式相匹配，使得 `Nat` 成为 `pos` 情况的预期类型，使得 `Int` 成为 `neg` 情况的预期类型。

将 `posOrNegThree` 应用于 `Sign.pos`，结果就是函数体和返回类型中的参数名 `s` 被 `Sign.pos` 替代。
求值可以同时发生在表达式和它的类型中：

```lean
{{#example_eval Examples/Intro.lean posOrNegThreePos}}
```

## 链表

Lean 的标准库包含了一个经典的链表数据类型，称为 `List`，并且有特殊的语法来方便使用。
链表可以用方括号表示。
例如，一个包含小于 10 的质数的链表可以写成：

```lean
{{#example_decl Examples/Intro.lean primesUnder10}}
```

在幕后，`List` 是一个归纳数据类型，它的定义如下：

```lean
inductive list (α : Type*) : Type*
| nil : list
| cons : α → list → list
```

这个定义表明 `List` 对于给定类型 `α` 是一个多态（`Type*`）的类型。它有两个构造器：

- `nil: list` 表示空列表。
- `cons: α -> list -> list` 表示非空列表，包含一个头部元素 `α` 和一个尾部子列表 `list` 。

```lean
{{#example_decl Examples/Intro.lean List}}
```

标准库中的实际定义稍有不同，因为它使用了尚未介绍的功能，但其基本相似。
该定义表明 `List` 接受一个类型作为其参数，就像 `PPoint` 一样。
这个类型是列表中存储的条目的类型。
根据构造函数，`List α` 可以使用 `nil` 或 `cons` 来构建。
构造函数 `nil` 表示空列表，构造函数 `cons` 用于非空列表。
`cons` 的第一个参数是列表的头，第二个参数是其尾部。
一个包含 \\( n \\) 个条目的列表包含 \\( n \\) 个 `cons` 构造函数，其中最后一个以 `nil` 作为其尾部。

通过直接使用 `List` 的构造函数，`primesUnder10` 的示例可以被写得更加明确：

```lean
{{#example_decl Examples/Intro.lean explicitPrimesUnder10}}
```

这两个定义是完全等价的，但是 `primesUnder10` 比 `explicitPrimesUnder10` 更易读。

和消费 `Nat` 的函数相比，消费 `List` 的函数可以采用几乎相同的方式进行定义。
事实上，一种将链表视为在每个 `succ` 构造函数上悬挂一个额外数据字段的 `Nat` 的方式。
从这个角度来看，计算列表的长度就是将每个 `cons` 替换为 `succ`，最后的 `nil` 替换为 `zero` 的过程。
就像 `replaceX` 接受点的字段类型作为参数一样，`length` 接受列表中的元素类型。
例如，如果列表包含字符串，则第一个参数是 `String`：`{{#example_eval Examples/Intro.lean length1EvalSummary 0}}`。
它应该像这样计算：

```
{{#example_eval Examples/Intro.lean length1EvalSummary}}
```

`length` 函数的定义既是多态的（因为它接受列表的元素类型作为参数），也是递归的（因为它引用了自身）。
一般来说，函数的形式与数据的形式相对应：递归数据类型导致递归函数，多态数据类型导致多态函数。

```lean
{{#example_decl Examples/Intro.lean length1}}
```

传统上，`xs` 和 `ys` 这样的名称被惯例性地用来代表未知值的列表。
名称中的 `s` 表示它们是复数形式，因此读作 "exes" 和 "whys"，而不是 "x s" 和 "y s"。

为了更容易阅读列表上的函数，可以使用括号符号 `[]` 来模式匹配 `nil`，而中缀符号 `::` 可以替代 `cons`：

```lean
{{#example_decl Examples/Intro.lean length2}}
```

## 隐式参数

`replaceX`和`length`在使用时有一些繁文缛节，因为类型参数通常可以由后续的值唯一确定。
事实上，在大多数语言中，编译器完全能够自动确定类型参数，只有偶尔需要用户的帮助。
在Lean中也是如此。
当定义一个函数时，可以通过用花括号而不是括号括起来来声明参数为_隐式参数_。
例如，一个带有隐式类型参数的`replaceX`版本如下：

```lean
{{#example_decl Examples/Intro.lean replaceXImp}}
```

因为 Lean 可以从后续参数中**推断**出 `α` 的值，所以可以在不显式提供 `Nat` 的情况下，使用 `natOrigin` 函数。

```lean
{{#example_in Examples/Intro.lean replaceXImpNat}}
```



```output info
{{#example_out Examples/Intro.lean replaceXImpNat}}
```

类似地，`length` 可以被重新定义，使输入类型隐式地被接收：

```lean
{{#example_decl Examples/Intro.lean lengthImp}}
```

这个 `length` 函数可以直接应用于 `primesUnder10`：

```lean
{{#example_in Examples/Intro.lean lengthImpPrimes}}
```



```output info
{{#example_out Examples/Intro.lean lengthImpPrimes}}
```

标准库中，Lean 将这个函数称为 `List.length`，这意味着用于结构体字段访问的点语法也可以用于获取列表的长度：

```lean
{{#example_in Examples/Intro.lean lengthDotPrimes}}
```



```output info
{{#example_out Examples/Intro.lean lengthDotPrimes}}
```

就像 C# 和 Java 需要时通常需要显式提供类型参数一样，Lean 并不总能自动找到隐式参数。
在这些情况下，可以通过提供参数名来指定它们。
例如，只适用于整数列表的 `List.length` 的版本可以通过将 `α` 设置为 `Int` 来指定：

```lean
{{#example_in Examples/Intro.lean lengthExpNat}}
```



```output info
{{#example_out Examples/Intro.lean lengthExpNat}}
```

## 更多的内置数据类型

除了列表之外，Lean 的标准库中还包含许多其他的结构和归纳数据类型，可以在各种上下文中使用。

### `Option`
并不是每个列表都有第一个条目 - 有些列表是空的。
对集合的许多操作可能无法找到所需的内容。
例如，找到列表中的第一个条目的函数可能找不到任何这样的条目。
因此，它必须有一种方法来表示没有第一个条目。

许多编程语言都有一个表示缺少值的 `null` 值。
Lean 提供了一个叫做 `Option` 的数据类型，它为某个其他类型提供了一个指示缺失值的标志。
例如，可为空的 `Int` 被表示为 `Option Int`，而可为空的字符串列表被表示为类型 `Option (List String)`。
引入一个新的类型来表示可为空性意味着类型系统确保不能忘记对 `null` 进行检查，因为 `Option Int` 不能在需要 `Int` 的上下文中使用。

`Option` 有两个构造函数，分别称为 `some` 和 `none`，分别表示基础类型的非空和空版本。
非空构造函数 `some` 包含基础值，而 `none` 不带参数：

```lean
{{#example_decl Examples/Intro.lean Option}}
```

`Option` 类型与 C# 和 Kotlin 等语言中的可空类型非常相似，但并不完全相同。
在这些语言中，如果一个类型（比如 `Boolean`）总是引用实际的类型值（`true` 和 `false`），那么类型 `Boolean?` 或 `Nullable<Boolean>` 还额外接受 `null` 值。
在类型系统中跟踪这一点非常有用：类型检查器和其他工具可以帮助程序员记得检查空值，并且通过类型签名显式描述可空性的 API 比不具备此功能的 API 更具信息量。
然而，这些可空类型与 Lean 的 `Option` 之间有一个非常重要的区别，就是它们不允许多层可选性。
`{{#example_out Examples/Intro.lean nullThree}}` 可以用 `{{#example_in Examples/Intro.lean nullOne}}`，`{{#example_in Examples/Intro.lean nullTwo}}` 或 `{{#example_in Examples/Intro.lean nullThree}}` 构造。
而 C# 则通过只允许给非可空类型添加 `?` 来禁止多层可空性，而 Kotlin 则将 `T??` 视为等同于 `T?`。
这个微妙的差别在实践中很少有相关性，但偶尔会有所影响。

要找到列表中的第一个条目（如果存在），可以使用 `List.head?`。
问号是名称的一部分，与 C# 或 Kotlin 中使用问号表示可空类型无关。
在 `List.head?` 的定义中，下划线用于表示列表的尾部。
在模式中，下划线匹配任何内容，但不引入变量以引用匹配的数据。
使用下划线而不是变量名是一种清楚地向读者传达忽略输入的一部分的方式。

```lean
{{#example_decl Examples/Intro.lean headHuh}}
```

在 Lean 中，一个常用的命名约定是使用后缀 `?` 来定义可能失败的操作版本，该版本返回一个 `Option` 类型的值；使用后缀 `!` 来定义在输入无效时会崩溃的操作版本；使用后缀 `D` 来定义在操作失败时返回默认值的操作版本。
举个例子，`head` 要求调用者提供数学证明来保证列表不为空，`head?` 返回一个 `Option` 类型的值，`head!` 在传入空列表时会导致程序崩溃，`headD` 接受一个默认值参数，在列表为空时返回该默认值。
问号和感叹号是名称的一部分，而不是特殊的语法，因为 Lean 的命名规则比许多其他语言更自由。

由于 `head?` 是在 `List` 命名空间中定义的，所以可以使用访问符记法来使用它：

```lean
{{#example_in Examples/Intro.lean headSome}}
```



```output info
{{#example_out Examples/Intro.lean headSome}}
```

然而，尝试在空列表上进行测试会导致两个错误：

```lean
{{#example_in Examples/Intro.lean headNoneBad}}
```



```output error
{{#example_out Examples/Intro.lean headNoneBad}}

{{#example_out Examples/Intro.lean headNoneBad2}}
```

这是因为 Lean 无法完全确定表达式的类型。特别是，它既无法找到 `List.head?` 的隐式类型参数，也无法找到 `List.nil` 的隐式类型参数。在 Lean 的输出中，`?m.XYZ` 表示无法推断出来的程序的一部分。这些未知部分被称为“元变量”，它们出现在一些错误消息中。为了评估一个表达式，Lean 需要能够找到其类型，而该类型不可用是因为空列表没有任何条目可供找到其类型。显式提供类型使 Lean 能够继续进行：

```lean
{{#example_in Examples/Intro.lean headNone}}
```



```output info
{{#example_out Examples/Intro.lean headNone}}
```

该类型也可以用类型注释提供：

```lean
example : ℕ → ℕ :=
λ n, n + 1
```

上面的代码中，`example` 是一个函数，它接受一个自然数 `n`，并返回 `n + 1`。函数的类型为 `ℕ → ℕ`，表示它接受一个自然数作为输入，并返回一个自然数作为输出。

在 Lean 中，`: ℕ → ℕ` 是对函数类型进行注释的方式。其中，`: ℕ` 表示函数的输入类型为自然数，`→` 表示函数的箭头，`ℕ` 表示函数的输出类型为自然数。

类型注释可以帮助编译器推断和验证代码的正确性，在复杂的代码中尤为重要。

```lean
{{#example_in Examples/Intro.lean headNoneTwo}}
```



```output info
{{#example_out Examples/Intro.lean headNoneTwo}}
```

错误信息提供了有用的线索。两条消息都使用同一个元变量来描述缺失的隐式参数，这意味着 Lean 已经确定了这两个缺失的部分将共享一个解决方案，尽管它无法确定解决方案的实际值。

### `Prod`

`Prod` 结构，即 "Product"，是一种将两个值结合在一起的通用方法。例如，一个 `Prod Nat String` 包含一个 `Nat` 和一个 `String`。换句话说，`PPoint Nat` 可以被替换为 `Prod Nat Nat`。`Prod` 很像 C# 中的元组 (tuples)，Kotlin 中的 `Pair` 和 `Triple` 类型，以及 C++ 中的 `tuple`。许多应用最好通过定义自己的结构来实现，即使是像 `Point` 这样简单的情况，因为使用领域术语可以使代码更易于阅读。此外，定义结构类型可以通过为不同的领域概念分配不同的类型来帮助捕获更多的错误，以防止它们被混淆。

另一方面，在某些情况下，定义新类型的开销可能不值得。此外，一些库非常通用，没有比 "pair" 更具体的概念。最后，标准库包含了各种便利函数，可以更轻松地处理内置的 pair 类型。

标准的 pair 结构称为 `Prod`。

```lean
{{#example_decl Examples/Intro.lean Prod}}
```

列表被如此频繁地使用，以至于有特殊的语法来使它们更易读。
出于相同的原因，产品类型和其构造函数也有特殊的语法。
类型 `Prod α β` 通常被写作 `α × β`，与集合的笛卡尔积的通常表示法相一致。
同样，`Prod` 可以使用通常数学符号表示一个二元组。
换句话说，不必写成：

```lean
{{#example_decl Examples/Intro.lean fivesStruct}}
```

我们只需要写下下面这个定理：

```lean
{{#example_decl Examples/Intro.lean fives}}
```

两种表示法都是右结合的。
这意味着以下定义是等价的：

```lean
{{#example_decl Examples/Intro.lean sevens}}

{{#example_decl Examples/Intro.lean sevensNested}}
```

换句话说，所有超过两种类型的产品及其对应的构造函数实际上都是在幕后进行嵌套的产品和嵌套对。

### `Sum`

`Sum`数据类型是一种通用的方式，允许在两种不同类型的值之间进行选择。
例如，`Sum String Int`要么是`String`类型，要么是`Int`类型。
与`Prod`类似，`Sum`应该在编写非常通用的代码（对于没有明确的领域特定类型的非常小的代码段）或者在标准库中包含有用的函数时使用。
在大多数情况下，使用自定义的归纳类型更可读性和可维护性。

类型为`Sum α β`的值要么是应用到类型为`α`的值的构造函数`inl`，要么是应用到类型为`β`的值的构造函数`inr`：

```lean
{{#example_decl Examples/Intro.lean Sum}}
```

这些名称分别是“左侧注入”和“右侧注入”的缩写。
与笛卡尔积符号用于 `Prod` 相似，一种“带有圆圈的加号”符号用于 `Sum`，因此 `α ⊕ β` 是另一种表示 `Sum α β` 的方法。
对于 `Sum.inl` 和 `Sum.inr`，没有特殊的语法。

例如，如果宠物的名字既可以是狗的名字也可以是猫的名字，那么可以将它们的类型引入为字符串的和类型：

```lean
{{#example_decl Examples/Intro.lean PetName}}
```

在实际的程序中，通常最好为这个目的定义一个自定义的归纳数据类型，以便具有信息性的构造函数名称。
在这里，`Sum.inl` 用于狗的名字，`Sum.inr` 用于猫的名字。
可以使用这些构造函数来编写一个动物名字的列表：

```lean
{{#example_decl Examples/Intro.lean animals}}
```

模式匹配可以用于区分两个构造函数。
例如，一个可以计算动物名称列表中狗的数量的函数（也就是 `Sum.inl` 构造函数的数量）如下所示：

```lean
{{#example_decl Examples/Intro.lean howManyDogs}}
```

函数调用在中缀运算符之前进行求值，因此 `howManyDogs morePets + 1` 等同于 `(howManyDogs morePets) + 1`。
如预期所见，`{{#example_in Examples/Intro.lean dogCount}}` 返回的结果是 `{{#example_out Examples/Intro.lean dogCount}}`。

### `Unit`

`Unit` 是一个只有一个无参数构造函数的类型，称为 `unit`。
换句话说，它只描述了一个单一的值，该值由该构造函数应用于没有任何参数的结果组成。
`Unit` 的定义如下：

```lean
{{#example_decl Examples/Intro.lean Unit}}
```

*LEAN* 定理证明

单独来看，`Unit` 并不特别有用。
然而，在多态代码中，它可以被用作缺失数据的占位符。
例如，下面的归纳数据类型表示算术表达式：

```lean
{{#example_decl Examples/Intro.lean ArithExpr}}
```

类型参数 `ann` 代表注解，每个构造函数都有注解。
来自解析器的表达式可能带有源位置注解，因此返回类型 `ArithExpr SourcePos` 确保解析器在每个子表达式上放置了一个 `SourcePos` 。
然而，不从解析器获取的表达式将没有源位置，因此它们的类型可以是 `ArithExpr Unit` 。


此外，因为所有的 Lean 函数都有参数，其他语言中的无参数函数可以表示为带有一个 `Unit` 参数的函数。
在返回位置，`Unit` 类型类似于从 C 衍生的语言中的 `void` 。
在 C 系语言中，返回 `void` 的函数将控制权返回给其调用者，但不会返回任何有趣的值。
通过成为一个故意无趣的值，`Unit` 可以在不需要类型系统中的特殊 `void` 功能的情况下表示这一点。
Unit 的构造函数可以写成空括号： `{{#example_in Examples/Intro.lean unitParens}} : {{#example_out Examples/Intro.lean unitParens}}`。

### `Empty`

`Empty` 数据类型没有任何构造函数。
因此，它表示不可达代码，因为没有一系列的调用能以类型 `Empty` 的值终止。

`Empty` 并不像 `Unit` 那样经常使用。
然而，在一些特定的上下文中它是有用的。
许多多态数据类型在它们的所有构造函数中并不都使用它们的所有类型参数。
例如，`Sum.inl` 和 `Sum.inr` 只使用了 `Sum` 的一个类型参数。
使用 `Empty` 作为 `Sum` 的类型参数之一可以在程序的特定位置上排除一个构造函数。
这可以允许在具有额外限制的上下文中使用通用代码。

### 命名：求和、积和单位

一般来说，提供多个构造函数的类型被称为**求和类型**，而其单个构造函数带有多个参数的类型被称为**积类型**。
这些术语与普通算术中使用的求和和积有关。
当涉及的类型包含有限个值时，这种关系最容易理解。
如果 `α` 和 `β` 是分别包含 \\( n \\) 和 \\( k \\) 个独特值的类型，则 `α ⊕ β` 包含 \\( n + k \\) 个独特值，`α × β` 包含 \\( n \times k \\) 个独特值。
例如，`Bool` 有两个值：`true` 和 `false`，`Unit` 有一个值：`Unit.unit`。
积 `Bool × Unit` 有两个值：`(true, Unit.unit)` 和 `(false, Unit.unit)`，和并 `Bool ⊕ Unit` 有三个值： `Sum.inl true`， `Sum.inl false`，和 `Sum.inr unit`。
类似地，\\( 2 \times 1 = 2 \\)，和 \\( 2 + 1 = 3 \\)。

## 你可能会遇到的错误

并非所有可定义的结构或归纳类型都可以具有类型 `Type`。
特别地，如果一个构造函数接受任意类型作为参数，则归纳类型必须具有不同的类型。
这些错误通常与 "universe levels" 有关。
例如，对于这个归纳类型：

```lean
{{#example_in Examples/Intro.lean TypeInType}}
```

Sorry, but could you please provide more details about the error you encountered in Lean? That way, I can better understand the problem and assist you in finding a solution.

```output error
{{#example_out Examples/Intro.lean TypeInType}}
```

稍后的章节会描述为什么会出现这种情况，以及如何修改定义使其正常运作。
在现在，试着将类型作为整个归纳类型的参数，而不是构造函数的参数。

类似地，如果构造函数的参数是一个以正在定义的数据类型为参数的函数，那么该定义会被拒绝。
例如：

```lean
{{#example_in Examples/Intro.lean Positivity}}
```

产生了以下的消息：

```output error
{{#example_out Examples/Intro.lean Positivity}}
```

由于技术原因，允许这些数据类型可能会破坏 Lean 的内部逻辑，使其不适合作为定理证明器使用。

忘记对归纳类型的一个参数进行传递也会导致混乱的提示消息。
例如，在 `ctor` 的类型中没有传递参数 `α` 到 `MyType` 的时候：

```lean
{{#example_in Examples/Intro.lean MissingTypeArg}}
```

Lean回复了以下错误：

```
ERROR: invalid command 'LEAN'
```

这个错误意味着在输入命令时有错误，可能是因为使用了无效的命令或拼写错误。请检查输入的命令是否正确，并确保拼写正确。

```output error
{{#example_out Examples/Intro.lean MissingTypeArg}}
```

错误消息显示 `MyType` 的类型是 `Type → Type`，它本身并不描述类型。`MyType` 需要一个参数来成为一个真正的类型。

在其他情况下，例如在定义的类型签名中省略了类型参数，可能会出现相同的消息：

```lean
{{#example_decl Examples/Intro.lean MyTypeDef}}

{{#example_in Examples/Intro.lean MissingTypeArg2}}
```

## 练习题

 * 编写一个函数，找到列表中的最后一个元素。它应该返回一个 `Option`。
 * 编写一个函数，找到列表中满足给定条件的第一个元素。函数的定义开始部分为 `def List.findFirst? {α : Type} (xs : List α) (predicate : α → Bool) : Option α :=`
 * 编写一个函数 `Prod.swap`，交换一对中的两个字段。函数的定义开始部分为 `def Prod.swap {α β : Type} (pair : α × β) : β × α :=`
 * 重新编写 `PetName` 示例，使用自定义的数据类型，并将其与使用 `Sum` 的版本进行比较。
 * 编写一个函数 `zip`，将两个列表合并成一个元素为对的列表。结果列表的长度应该与输入列表的最短长度相同。函数的定义开始部分为 `def zip {α β : Type} (xs : List α) (ys : List β) : List (α × β) :=`。
 * 编写一个多态函数 `take`，返回列表中的前 \\( n \\) 个元素，其中 \\( n \\) 是一个 `Nat` 类型的数。如果列表中的条目少于 `n`，则结果列表应为输入列表。`{{#example_in Examples/Intro.lean takeThree}}` 将返回 `{{#example_out Examples/Intro.lean takeThree}}`，而 `{{#example_in Examples/Intro.lean takeOne}}` 将返回 `{{#example_out Examples/Intro.lean takeOne}}`。
 * 使用类型和算术的类比，编写一个将乘积分配给和的函数。换句话说，它的类型应为 `α × (β ⊕ γ) → (α × β) ⊕ (α × γ)`。
 * 使用类型和算术的类比，编写一个将乘以二转变成和的函数。换句话说，它的类型应为 `Bool × α → α ⊕ α`。