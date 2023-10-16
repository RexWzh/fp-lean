# 附加便利功能

Lean 包含了许多便利功能，这使得程序更加简洁。

## 自动隐式参数

在 Lean 中编写多态函数时，通常不需要列出所有的隐式参数。
相反，它们可以简单地被提到。
如果 Lean 可以确定它们的类型，那么它们会自动作为隐式参数插入。
换句话说，之前的 `length` 定义可以简化为：

```lean
{{#example_decl Examples/Intro.lean lengthImp}}
```

可以不使用 `{α : Type}` 来写出 LEAN 定理证明的文章。

```lean
{{#example_decl Examples/Intro.lean lengthImpAuto}}
```

这可以大大简化那些需要许多隐式参数的高度多态定义。

## 模式匹配定义

在使用`def`定义函数时，常常会给参数命名，然后立即使用模式匹配来处理这个参数。
例如，在`length`中，参数`xs`只在`match`中使用。
在这种情况下，可以直接编写`match`表达式的不同情况，而不需要给参数命名。

第一步是将参数的类型移到冒号的右边，这样返回类型就是一个函数类型。
例如，`length`的类型是`List α → Nat`。
然后，用模式匹配的每个情况替换`:=`：

```lean
{{#example_decl Examples/Intro.lean lengthMatchDef}}
```

这种语法也可以用来定义接受多个参数的函数。
在这种情况下，它们的模式之间用逗号分隔。
例如，`drop` 函数接受一个数字 \\( n \\) 和一个列表，并返回删除了前 \\( n \\) 个元素后的列表。

```lean
{{#example_decl Examples/Intro.lean drop}}
```

命名参数和模式也可以在同一个定义中使用。
例如，一个接受默认值和可选值的函数，在可选值为 `none` 时返回默认值，可以写成：

```lean
{{#example_decl Examples/Intro.lean fromOption}}
```

这个函数在标准库中被称为 `Option.getD`，可以使用点表示法调用：

```lean
{{#example_in Examples/Intro.lean getD}}
```



```output info
{{#example_out Examples/Intro.lean getD}}
```



```lean
{{#example_in Examples/Intro.lean getDNone}}
```



```output info
{{#example_out Examples/Intro.lean getDNone}}
```

## 局部定义

在计算过程中，给中间步骤命名常常是有用的。
在很多情况下，中间值本身就代表了有用的概念，显式地命名可以使程序更易读。
在其他情况下，中间值被使用了多次。
与大多数其他语言一样，在 Lean 中将代码写两次会导致计算两次，而将结果保存在变量中则会保存和重复使用计算结果。

例如，`unzip` 是一个将一对列表转换为一对列表的函数。
当一对列表为空时，`unzip` 的结果是一对空列表。
当一对列表的头部有一对值时，该值的两个字段将被添加到解压剩余列表的结果中。
`unzip` 的定义正是按照上述描述来的：

```lean
{{#example_decl Examples/Intro.lean unzipBad}}
```

不幸的是，存在一个问题：这段代码的运行速度比需求要慢。
列表中的每一个元素都会导致两次递归调用，这使得该函数花费指数级的时间。
然而，两次递归调用的结果是相同的，所以没有必要进行两次递归调用。

在 Lean 中，可以使用 `let` 命名并保存递归调用的结果。
使用 `let` 进行局部定义与使用 `def` 进行顶层定义类似：它需要一个待在局部定义中的名称、可选的参数、类型签名，然后是跟在 `:=` 后面的实现体。
在局部定义之后，该局部定义所在的表达式（称为 `let`-表达式的 _主体_）必须在一个新行上，并且要在文件中的列号小于或等于 `let` 关键字的列号。
例如，`let` 可以在 `unzip` 中这样使用：

```lean
{{#example_decl Examples/Intro.lean unzip}}
```

在单行上使用 `let` 时，需要用分号将局部定义与主体分隔开来。

在使用 `let` 进行局部定义时，当一个模式足以匹配某个数据类型的所有情况时，可以使用模式匹配。
在 `unzip` 函数中，递归调用的结果是一个二元组。
因为二元组只有一个构造函数，所以可以用一个二元组模式来替换 `unzipped` 的名称：

```lean
{{#example_decl Examples/Intro.lean unzipPat}}
```

使用 `let` 带有模式的明智用法可以使代码更易读，相比手动编写访问器调用。

`let` 和 `def` 之间最大的区别是递归 `let` 定义必须通过显式写入 `let rec` 来表示。
例如，反转列表的一种方法涉及到一个递归的辅助函数，就像下面的定义一样：

```lean
{{#example_decl Examples/Intro.lean reverse}}
```

## 类型推断

在许多情况下，Lean 可以自动确定表达式的类型。
在这些情况下，无需在顶级定义（使用 `def`）和局部定义（使用 `let`）中显式提供类型注解。
例如，对 `unzip` 的递归调用不需要注解：

```lean
{{#example_decl Examples/Intro.lean unzipNT}}
```

作为一个经验法则，通常可以省略文字值（如字符串和数字）的类型，尽管 Lean 可能会选择比意图更具体的字面数字类型。
在函数应用中，Lean通常可以确定类型，因为它已经知道了参数类型和返回类型。
省略函数定义的返回类型通常是可以的，但函数参数通常需要注释。
在示例中的 `unzipped` 这样的非函数定义，如果它们的主体不需要类型注释，就不需要类型注释，而这个定义的主体是一个函数应用。

在使用显式的 `match` 表达式时，可以省略 `unzip` 的返回类型：

```lean
{{#example_decl Examples/Intro.lean unzipNRT}}
```

总的来说，过多而不是过少的类型注解是个好主意。
首先，显式的类型注解能够将代码的假设传达给读者。
即使 Lean 在自动确定类型方面能够胜任，不用反复查询 Lean 即可阅读代码会更加容易。
其次，显式的类型注解有助于缩小出错范围。
程序在类型方面越显式，错误信息就越有信息量。
这在像 Lean 这样具有非常表达能力的类型系统的语言中尤为重要。
第三，显式的类型注解使得初次编写程序更加容易。
类型是一个规范，编译器的反馈可以是编写符合规范的程序的有益工具。
最后，Lean 的类型推断是一个尽力而为的系统。
由于 Lean 的类型系统非常表达能力强，对于所有表达式来说，并没有一个“最佳”的或最通用的类型可以找到。
这意味着，即使你得到了一个类型，也无法保证它是适合于特定应用的“正确”类型。
例如，`14`可以是 `Nat`（自然数）也可以是 `Int`（整数）：

```lean
{{#example_in Examples/Intro.lean fourteenNat}}
```



```output info
{{#example_out Examples/Intro.lean fourteenNat}}
```



```lean
{{#example_in Examples/Intro.lean fourteenInt}}
```



```output info
{{#example_out Examples/Intro.lean fourteenInt}}
```

缺少类型注解会导致混乱的错误信息。
在 `unzip` 的定义中省略所有类型注解：

```lean
{{#example_in Examples/Intro.lean unzipNoTypesAtAll}}
```

导致了有关 `match` 表达式的信息：

```output error
{{#example_out Examples/Intro.lean unzipNoTypesAtAll}}
```

这是因为 `match` 需要知道被检查值的类型，但该类型不可用。
“元变量”是程序中的一个未知部分，错误消息中用 `?m.XYZ` 来表示——它们在[多态性](polymorphism.md)一节中进行了描述。
在这个程序中，参数的类型注解是必需的。

即使是一些非常简单的程序也需要类型注解。
例如，恒等函数只是返回传入的参数。
加上参数和类型注解，它看起来像这样：

```lean
{{#example_decl Examples/Intro.lean idA}}
```

Lean 能够自行确定返回类型：

```lean
{{#example_decl Examples/Intro.lean idB}}
```

然而，省略参数类型会导致错误：

```lean
{{#example_in Examples/Intro.lean identNoTypes}}
```



```output error
{{#example_out Examples/Intro.lean identNoTypes}}
```

通常，像“无法推断”这样的消息或者提及到元变量的消息往往是需要更多类型注释的标志。
特别是在学习 Lean 的过程中，最好将大部分类型提供明确的注释。

## 同时匹配

与定义时的模式匹配类似，模式匹配表达式也可以同时匹配多个值。
要检查的表达式和要匹配的模式都用逗号隔开，与定义中的语法类似。
下面是使用同时匹配的 `drop` 的一个版本：

```lean
{{#example_decl Examples/Intro.lean dropMatch}}
```

## 自然数的模式

在 [数据类型和模式](datatypes-and-patterns.md) 部分，`even` 定义如下：

```lean
def even (n : ℕ) : Prop := ∃ m, n = 2 * m
```

This definition states that a natural number `n` is `even` if there exists another natural number `m` such that `n` can be expressed as `2 * m`. This is a pattern that can be used to check if a number is even or not.

这个定义规定了一个自然数 `n` 如果存在另一个自然数 `m` 使得 `n` 可以表示为 `2 * m`，那么 `n` 就是偶数。这是一个用于判断一个数是否为偶数的模式。

With this definition, we can now prove some interesting properties about even numbers. Let's start with a lemma that states that the sum of two even numbers is even:

有了这个定义，我们现在可以证明关于偶数的一些有趣性质。让我们先从一个引理开始，它说明了两个偶数的和仍然是一个偶数：

```lean
lemma even_add_even (m n : ℕ) (hm : even m) (hn : even n) : even (m + n) :=
begin
  cases hm with a ha,
  cases hn with b hb,
  use (a + b),
  rw [ha, hb, mul_add]
end
```

This lemma uses the `cases` tactic to destruct the existence proofs `hm` and `hn` into their respective components. We then use the `use` tactic to construct a new existence proof by providing the sum `a + b` of the components. Finally, we use the `rw` tactic to rewrite the original equation `m + n` into the form `2 * (a + b)`. This completes the proof.

这个引理使用 `cases` 策略将存在性证明 `hm` 和 `hn` 解构为它们各自的分量。然后使用 `use` 策略通过提供分量的和 `a + b` 来构造一个新的存在性证明。最后，使用 `rw` 策略将原来的方程 `m + n` 重写为 `2 * (a + b)` 的形式。这完成了证明。

Using this lemma, we can prove that the product of two even numbers is even:

利用这个引理，我们可以证明两个偶数的乘积是一个偶数：

```lean
lemma even_mul_even (m n : ℕ) (hm : even m) (hn : even n) : even (m * n) :=
begin
  cases hm with a ha,
  cases hn with b hb,
  use (2 * a * b),
  rw [ha, hb, ← mul_assoc, mul_comm b 2, mul_assoc]
end
```

This proof follows a similar pattern to the previous proof. We destruct the existence proofs `hm` and `hn` to obtain their respective components, then use the `use` tactic to construct a new existence proof by providing the product `2 * a * b` of the components. Finally, we use the `rw` tactic to rewrite the original equation `m * n` into the form `2 * (2 * a * b)`. This completes the proof.

这个证明与先前的证明遵循了相似的模式。我们解构存在性证明 `hm` 和 `hn` 来获得它们各自的分量，然后使用 `use` 策略通过提供分量的乘积 `2 * a * b` 来构造一个新的存在性证明。最后，使用 `rw` 策略将原来的方程 `m * n` 重写为 `2 * (2 * a * b)` 的形式。这完成了证明。

These examples show how we can use the `even` pattern to prove properties about even numbers. By defining a datatype and defining patterns like `even`, we can reason about natural numbers and derive interesting and useful results.

```lean
{{#example_decl Examples/Intro.lean even}}
```

正如存在着特殊的语法使得列表模式比直接使用 `List.cons` 和 `List.nil` 更易读一样，自然数也可以使用字面数值和 `+` 来进行匹配。
例如，`even` 也可以这样定义：

```lean
{{#example_decl Examples/Intro.lean evenFancy}}
```

在这个表示法中，`+` 模式的参数起到不同的作用。
在背后，左参数（上面的 `n`）成为一些 `Nat.succ` 模式的参数，并且右参数（上面的 `1`）确定要在模式周围包裹多少个 `Nat.succ`。
`halve` 中的显式模式将 `Nat` 数字除以二并丢弃余数：

```lean
{{#example_decl Examples/Intro.lean explicitHalve}}
```

可以用数值定量和 `+` 进行替代：

```lean
{{#example_decl Examples/Intro.lean halve}}
```

在幕后，这两个定义完全等价。
记住：`halve n + 1` 等价于 `(halve n) + 1`，而不是 `halve (n + 1)`。

在使用这个语法时，`+` 的第二个参数应始终是一个字面量 `Nat`。
尽管加法是可交换的，但是在模式中交换参数可能会导致以下错误：

```lean
{{#example_in Examples/Intro.lean halveFlippedPat}}
```



```output error
{{#example_out Examples/Intro.lean halveFlippedPat}}
```

这个限制使得 Lean 能够将模式中的 `+` 表示转化为底层的 `Nat.succ` 使用，从而使得语言在后台更加简化。

## 匿名函数

在 Lean 中，函数不一定要在顶层进行定义。
作为表达式，函数可以使用 `fun` 语法来生成。
函数表达式以关键字 `fun` 开始，接着是一个或多个参数，这些参数与返回表达式使用 `=>` 进行分隔。
例如，一个将一个数加一的函数可以写成：

```lean
{{#example_in Examples/Intro.lean incr}}
```



```output info
{{#example_out Examples/Intro.lean incr}}
```

类型注释的书写方式与 `def` 函数定义一样，使用括号和冒号:

```lean
{{#example_in Examples/Intro.lean incrInt}}
```



```output info
{{#example_out Examples/Intro.lean incrInt}}
```

同样，隐式参数可以用花括号来书写：

```lean
{{#example_in Examples/Intro.lean identLambda}}
```



```output info
{{#example_out Examples/Intro.lean identLambda}}
```

这种形式的匿名函数表达式通常被称为 _lambda 表达式_，因为在数学描述编程语言时，使用希腊字母 λ（lambda），而 Lean 使用 `fun` 关键字。
尽管 Lean 允许使用 `λ` 替代 `fun`，但通常还是写作 `fun`。

匿名函数也支持在 `def` 中使用的多模式样式。
例如，一个如果存在自然数的前驱则返回它的函数可以写作：

```lean
{{#example_in Examples/Intro.lean predHuh}}
```



```output info
{{#example_out Examples/Intro.lean predHuh}}
```

值得注意的是，Lean 中关于函数的描述具有一个命名参数和一个 `match` 表达式。
许多 Lean 的便利的语法缩写在后台被展开为更简单的语法，但有时会泄漏抽象。

使用 `def` 定义带有参数的函数可以重写为函数表达式。
例如，一个将其参数加倍的函数可以写成以下形式：

```lean
{{#example_decl Examples/Intro.lean doubleLambda}}
```

当匿名函数非常简单时，例如 `{{#example_eval Examples/Intro.lean incrSteps 0}}`，创建函数的语法可能相当冗长。
在这个特定的例子中，有六个非空白字符用于引入函数，而函数体只包含三个非空白字符。
对于这些简单的情况，Lean 提供了一种简写方式。
在括号括起来的表达式中，中心点字符 `·` 可以表示一个参数，而括号内的表达式成为函数的体。
这个特定的函数也可以写成 `{{#example_eval Examples/Intro.lean incrSteps 1}}`。

中心点始终创建最靠近的一对括号内的函数。
例如，`{{#example_eval Examples/Intro.lean funPair 0}}` 是返回一对数字的函数，而 `{{#example_eval Examples/Intro.lean pairFun 0}}` 是一个函数和一个数字的一对。
如果使用多个点，则它们按从左到右的顺序成为参数：

```lean
{{#example_eval Examples/Intro.lean twoDots}}
```

匿名函数可以与使用 `def` 或 `let` 定义的函数完全相同的方式进行应用。
命令 `{{#example_in Examples/Intro.lean applyLambda}}` 的结果如下所示：

```output info
{{#example_out Examples/Intro.lean applyLambda}}
```

在 `{{#example_in Examples/Intro.lean applyCdot}}` 的情况下，结果为：

```output info
{{#example_out Examples/Intro.lean applyCdot}}
```

## 命名空间

Lean中的每个名称都存在于一个命名空间中，命名空间是一组名称的集合。
使用`.`将名称放置在命名空间中，因此`List.map`是`List`命名空间中的名称`map`。
即使它们在其他方面是相同的，不同命名空间中的名称也不会发生冲突。
这意味着`List.map`和`Array.map`是不同的名称。
命名空间可以嵌套，因此`Project.Frontend.User.loginTime`是嵌套命名空间`Project.Frontend.User`中的名称`loginTime`。

可以在命名空间中直接定义名称。
例如，名称`double`可以在`Nat`命名空间中定义：

```lean
{{#example_decl Examples/Intro.lean NatDouble}}
```

因为 `Nat` 也是一个类型的名称，所以对于类型为 `Nat` 的表达式，可以使用点符号来调用 `Nat.double`：

```lean
{{#example_in Examples/Intro.lean NatDoubleFour}}
```



```output info
{{#example_out Examples/Intro.lean NatDoubleFour}}
```

除了直接在命名空间中定义名称外，也可以使用 `namespace` 和 `end` 命令将一系列声明放在命名空间中。
例如，下面的代码将在命名空间 `NewNamespace` 中定义 `triple` 和 `quadruple`：

```lean
namespace NewNamespace
  def triple (n : ℕ) : ℕ := n * 3
  def quadruple (n : ℕ) : ℕ := n * 4
end
```

在这个例子中，`triple` 和 `quadruple` 分别是在命名空间 `NewNamespace` 中定义的两个函数。在命名空间内部，它们可以使用命名空间作为限定符进行访问，例如 `NewNamespace.triple` 和 `NewNamespace.quadruple`。这样做可以避免命名冲突，特别是当在不同的命名空间中定义相同名称的函数时。

```lean
{{#example_decl Examples/Intro.lean NewNamespace}}
```

为了引用它们，使用 `NewNamespace.` 作为它们名称的前缀：

```lean
{{#example_in Examples/Intro.lean tripleNamespace}}
```



```output info
{{#example_out Examples/Intro.lean tripleNamespace}}
```



```lean
{{#example_in Examples/Intro.lean quadrupleNamespace}}
```



```output info
{{#example_out Examples/Intro.lean quadrupleNamespace}}
```

命名空间可以被“打开”，这样可以在不必显式限定的情况下使用其中的名称。
在表达式之前写上 `open MyNamespace in` 可以使 `MyNamespace` 的内容在表达式中可用。
例如，在打开 `NewNamespace` 之后，`timesTwelve` 使用了 `quadruple` 和 `triple`。

```lean
{{#example_decl Examples/Intro.lean quadrupleOpenDef}}
```

命名空间也可以在命令之前打开。
这样可以使命令的所有部分都可以引用命名空间的内容，而不仅仅是单个表达式。
为了做到这一点，在命令之前加上 `open ... in` 语句。

```lean
{{#example_in Examples/Intro.lean quadrupleNamespaceOpen}}
```



```output info
{{#example_out Examples/Intro.lean quadrupleNamespaceOpen}}
```

## 如果 let

当使用具有和类型的值时，通常只关心一个构造函数。
例如，给定表示 Markdown 内联元素子集的该类型：

```lean
{{#example_decl Examples/Intro.lean Inline}}
```

我们可以编写一个识别字符串元素并提取它们内容的函数：

```lean
{{#example_decl Examples/Intro.lean inlineStringHuhMatch}}
```

这个函数的主体可以使用 `if` 和 `let` 的方式来替代编写：

```lean
{{#example_decl Examples/Intro.lean inlineStringHuh}}
```

这非常类似于模式匹配 `let` 语法。
不同之处在于它可以与和类型一起使用，因为在 `else` 语句中提供了一个后备机制。
在某些情况下，使用 `if let` 而不是 `match` 可以使代码更易读。

## 位置结构参数

[结构部分](structures.md) 提供了两种构建结构的方法：
 1. 可以直接调用构造函数，例如 `{{#example_in Examples/Intro.lean pointCtor}}`。
 2. 可以使用花括号标记，例如 `{{#example_in Examples/Intro.lean pointBraces}}`。

在某些情况下，通过位置而不是通过名称传递参数可能更方便，但又不直接命名构造函数。
例如，定义各种相似的结构类型可以帮助保持领域概念的分离，但是自然阅读代码的方式可能会将它们视为元组。
在这些情况下，参数可以用尖括号 `⟨` 和 `⟩` 包围起来。
一个 `Point` 可以写作 `{{#example_in Examples/Intro.lean pointPos}}`。
要注意！
尽管它们看起来像小于号 `<` 和大于号 `>`，但这些括号是不同的。
可以分别使用 `\<` 和 `\>` 输入它们。

就像使用命名构造函数参数的花括号标记一样，此位置语法仅在 Lean 可以从类型注解或程序中的其他类型信息中确定结构的类型的上下文中使用。
例如，`{{#example_in Examples/Intro.lean pointPosEvalNoType}}` 会产生以下错误：

```output error
{{#example_out Examples/Intro.lean pointPosEvalNoType}}
```

错误中的元变量是因为没有可用的类型信息。
添加注释会解决这个问题，比如在 `{{#example_in Examples/Intro.lean pointPosWithType}}` 中。

```output info
{{#example_out Examples/Intro.lean pointPosWithType}}
```

## 字符串插值

在 Lean 中，使用 `s!` 作为字符串的前缀会触发 _插值_，其中大括号中包含的表达式会被替换为它们的值。
这与 Python 的 `f` 字符串和 C＃ 的 `$` 前缀字符串类似。
例如，

```lean
{{#example_in Examples/Intro.lean interpolation}}
```

得到输出

```output info
{{#example_out Examples/Intro.lean interpolation}}
```

并非所有的表达式都可以插入字符串中进行内插。
例如，尝试插入一个函数会导致错误。

```lean
{{#example_in Examples/Intro.lean interpolationOops}}
```

产出是一个 **Markdown** 格式的文章。请提供输入，我将翻译成中文。

```output info
{{#example_out Examples/Intro.lean interpolationOops}}
```

这是因为没有标准的方法将函数转换为字符串。
Lean编译器维护了一个表，描述了如何将不同类型的值转换为字符串，而 `failed to synthesize instance` 这个消息意味着Lean编译器在该表中没有找到给定类型的条目。
这使用了与在[结构体部分](structures.md)中描述的 `deriving Repr` 语法相同的语言特性。