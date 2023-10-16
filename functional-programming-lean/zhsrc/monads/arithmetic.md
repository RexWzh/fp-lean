## 示例：单子中的算术运算

单子（Monads）是一种将具有副作用的程序编码为一种没有副作用的语言的方式。
可能有人会认为这是对纯函数式程序缺少某些重要东西的一种承认，需要程序员通过一些花招才能编写出正常的程序。
然而，尽管使用`Monad` API在程序中会产生一定的语法成本，但它带来了两个重要的好处：
1. 程序必须在其类型中明确哪些效果会被使用。通过快速查看类型签名可以描述程序所能做的“所有”事情，而不仅仅是它接受什么和返回什么。
2. 并非每种语言都提供相同的效果。例如，只有一些语言具有异常。其他语言具有独特的、奇特的效果，例如[Icon的多值搜索](https://www2.cs.arizona.edu/icon/)以及Scheme或Ruby的续延。因为单子可以编码“任何”效果，所以程序员可以根据具体的应用选择最适合的效果，而不是被语言开发者提供的效果束缚住。

算术表达式是指字面整数或应用于两个表达式的原始二元运算符。这些运算符包括加法、减法、乘法和除法：

```lean
{{#example_decl Examples/Monads/Class.lean ExprArith}}
```

表达式 `2 + 3` 的表示方式是： 2 加 3。

```lean
{{#example_decl Examples/Monads/Class.lean twoPlusThree}}
```

并且 `14 / (45 - 5 * 9)` 可以表示为：

```lean
{{#example_decl Examples/Monads/Class.lean exampleArithExpr}}
```

### 表达式的求值

由于表达式中包含除法，而除数为零是未定义的，因此求值可能会失败。
表示失败的一种方法是使用 `Option`：

```lean
{{#example_decl Examples/Monads/Class.lean evaluateOptionCommingled}}
```

这个定义使用了 `Monad Option` 实例来传播评估二元操作符的两个分支的失败。
然而，这个函数混合了两个关注点：评估子表达式和将二元操作符应用于结果。
可以通过将其拆分为两个函数来改进它：

```lean
{{#example_decl Examples/Monads/Class.lean evaluateOptionSplit}}
```

运行 `{{ #example_in Examples/Monads/Class.lean fourteenDivOption}}` 的结果如预期的那样为 `{{#example_out Examples/Monads/Class.lean fourteenDivOption}}`，但这个错误信息并不是特别有用。
因为代码是使用 `>>=` 而不是显式处理 `none` 构造函数编写的，所以只需要稍作修改就可以在失败时提供错误信息：

```lean
{{#example_decl Examples/Monads/Class.lean evaluateExcept}}
```

唯一的区别在于类型签名中提到了 `Except String` 而不是 `Option`，以及失败的情况下使用了 `Except.error` 而不是 `none`。
通过使 `evaluate` 成为其 monad 的多态函数，并将 `applyPrim` 作为参数传递，一个单一的评估器变得能够实现两种形式的错误报告：

```lean
{{#example_decl Examples/Monads/Class.lean evaluateM}}
```

使用 `applyPrimOption` 与第一版本的`evaluate`函数的效果完全相同：

```lean
{{#example_in Examples/Monads/Class.lean evaluateMOption}}
```



```output info
{{#example_out Examples/Monads/Class.lean evaluateMOption}}
```

使用 `applyPrimExcept` 的方式与带错误消息的版本完全相同：

```lean
{{#example_in Examples/Monads/Class.lean evaluateMExcept}}
```



```output info
{{#example_out Examples/Monads/Class.lean evaluateMExcept}}
```

代码还可以改进。
`applyPrimOption` 和 `applyPrimExcept` 函数只在对除法的处理上有所不同，可以将其提取为求值器的另一个参数：

```lean
{{#example_decl Examples/Monads/Class.lean evaluateMRefactored}}
```

在这个重构的代码中，两个代码路径之间只有在处理失败时有所不同的事实已经变得完全明显。

### 进一步的效果

当与评估器一起工作时，失败和异常不是唯一有趣的效果。通过将其他原始操作符添加到表达式中，可以表达其他效果。

第一步是进行额外的重构，从原始类型中提取出除法操作：

```lean
{{#example_decl Examples/Monads/Class.lean PrimCanFail}}
```

`CanFail` 这个名字暗示了除法引入的效果可能会导致失败。

第二步是将除法处理程序参数的作用域扩大到 `evaluateM`，以便它可以处理任何特殊操作符：

```lean
{{#example_decl Examples/Monads/Class.lean evaluateMMorePoly}}
```

#### 无效果

类型 `Empty` 没有构造函数，因此也没有值，就像 Scala 或 Kotlin 中的 `Nothing` 类型一样。
在 Scala 和 Kotlin 中，`Nothing` 可以表示永远不会返回结果的计算，比如会崩溃程序、抛出异常或者永远陷入无限循环的函数。
函数或方法的类型为 `Nothing` 的参数表示死代码，因为永远不会有合适的参数值。
虽然 Lean 不支持无限循环和异常，但是使用 `Empty` 作为函数不可调用的标记对类型系统仍然很有用。
当 `E` 是一个类型没有构造函数的表达式时，使用 `nomatch E` 的语法可以告诉 Lean 当前的表达式不需要返回结果，因为它永远不会被调用。

使用 `Empty` 作为参数传递给 `Prim` 表示除了 `Prim.plus`、`Prim.minus` 和 `Prim.times` 之外没有其他情况，因为无法找到一个类型为 `Empty` 的值来放置在 `Prim.other` 构造函数中。
因为一个将类型为 `Empty` 的运算符应用到两个整数上的函数永远不会被调用，所以它不需要返回结果。
因此，它可以在 _任何_ 单子（monad）中使用:

```lean
{{#example_decl Examples/Monads/Class.lean applyEmpty}}
```

这个可以与 `Id`（即 Identity Monad）一起使用来求值完全没有副作用的表达式。

```lean
{{#example_in Examples/Monads/Class.lean evalId}}
```



```output info
{{#example_out Examples/Monads/Class.lean evalId}}
```

#### 非确定性搜索

在遇到除以零时不仅仅失败，回溯并尝试不同的输入也是有意义的。在给定正确的单子的情况下，相同的 `evaluateM` 可以执行一个非确定性搜索，寻找不导致失败的一组答案。
除了除法，这还需要一些方式来指定结果的选择。
一种方法是在表达式语言中添加一个名为 `choose` 的函数，它指示评估器在寻找非失败结果时选择其参数中的任意一个。

评估器的结果现在是一个多集合（multiset）而不是单个值。
多集合的求值规则如下：
 * 常量 \\( n \\) 求值为单元素集合 \\( \{n\} \\)。
 * 除了除法，算术运算符被调用于操作数的笛卡尔积的每对元素，所以 \\( X + Y \\) 求值为 \\( \\{ x + y \\mid x ∈ X, y ∈ Y \\} \\)。
 * 除法 \\( X / Y \\) 求值为 \\( \\{ x / y \\mid x ∈ X, y ∈ Y, y ≠ 0\\} \\)。换句话说，所有 \\( Y \\) 中的 \\( 0 \\) 值被剔除。
 * 选择 \\( \\mathrm{choose}(x, y) \\) 求值为 \\( \\{ x, y \\} \\)。

例如，\\( 1 + \\mathrm{choose}(2, 5) \\) 求值为 \\( \\{ 3, 6 \\} \\)，\\(1 + 2 / 0 \\) 求值为 \\( \\{\\} \\)，\\( 90 / (\\mathrm{choose}(-5, 5) + 5) \\) 求值为 \\( \\{ 9 \\} \\)。
使用多集合而不是真正的集合简化了代码，无需检查元素的唯一性。

代表这种非确定性效应的单子必须能够表示没有答案的情况，以及至少有一个答案以及任何剩余答案的情况：

```lean
{{#example_decl Examples/Monads/Many.lean Many}}
```

这种数据类型看起来很像`List`。
不同之处在于，`cons`存储了列表的其余部分，而`more`存储了一个应该按需计算下一个值的函数。
这意味着`Many`的消费者可以在找到一定数量的结果后停止搜索。

一个单独的结果由返回无进一步结果的`more`构造函数表示：

```lean
{{#example_decl Examples/Monads/Many.lean one}}
```

对于两个结果的多重集合的并集可以通过检查第一个多重集合是否为空来计算。
如果是的话，第二个多重集合就是并集。
如果不是，则并集由第一个多重集合的第一个元素接着上第一个多重集合的其余部分与第二个多重集合的并集组成：

```lean
{{#example_decl Examples/Monads/Many.lean union}}
```

可以方便地使用一个值列表来开始搜索过程。
`Many.fromList` 将一个列表转换为结果的多重集合：

```lean
{{#example_decl Examples/Monads/Many.lean fromList}}
```

类似地，一旦搜索被指定，提取一个数值或者所有数值都是很方便的：

```lean
{{#example_decl Examples/Monads/Many.lean take}}
```

**Monad Many**

`Monad Many`实例需要一个`bind`操作符。在非确定性搜索中，顺序执行两个操作包括将第一步的所有可能性并行执行，然后将剩余的程序在每个可能性上运行，并取结果的并集。换句话说，如果第一步返回了三个可能的答案，第二步需要尝试这三个答案。由于第二步可以对每个输入返回任意数量的答案，取它们的并集代表了整个搜索空间。

```lean
{{#example_decl Examples/Monads/Many.lean bind}}
```

`Many.bind (Many.one v) f`
根据 `Many.bind` 操作的定义，我们可以将其展开为:
`Many.one v` 中的每一个元素都被函数 `f` 应用，然后将结果展开为一组列表。
所以 `Many.bind (Many.one v) f` 可以简化为:
`f v`
即 `f` 函数被应用于 `v`。

所以，`Many.bind (Many.one v) f` 的结果与 `f v` 是相同的。这证明了 `Many.one` 和 `Many.bind` 符合 monad 合约。

```lean
{{#example_eval Examples/Monads/Many.lean bindLeft}}
```

空多重集合是 `union` 的右单位元，所以答案等价于 `f v`。
要检查 `Many.bind v Many.one` 是否与 `v` 相同，需要考虑到 `bind` 将 `Many.one` 应用于 `v` 的每个元素并求并集。
换句话说，如果 `v` 的形式是 `{v1, v2, v3, ..., vn}`，那么 `Many.bind v Many.one` 就是 `{v1} ∪ {v2} ∪ {v3} ∪ ... ∪ {vn}`，即 `{v1, v2, v3, ..., vn}`。

最后，要检查 `Many.bind` 是否满足结合律，需要检查 `Many.bind (Many.bind bind v f) g` 是否与 `Many.bind v (fun x => Many.bind (f x) g)` 相同。
如果 `v` 的形式是 `{v1, v2, v3, ..., vn}`，那么：

```lean
Many.bind v f
===>
f v1 ∪ f v2 ∪ f v3 ∪ ... ∪ f vn
```

which means that  所以 

```lean
Many.bind (Many.bind bind v f) g
===>
Many.bind (f v1) g ∪
Many.bind (f v2) g ∪
Many.bind (f v3) g ∪
... ∪
Many.bind (f vn) g
```

类似地，

```lean
Many.bind v (fun x => Many.bind (f x) g)
===>
(fun x => Many.bind (f x) g) v1 ∪
(fun x => Many.bind (f x) g) v2 ∪
(fun x => Many.bind (f x) g) v3 ∪
... ∪
(fun x => Many.bind (f x) g) vn
===>
Many.bind (f v1) g ∪
Many.bind (f v2) g ∪
Many.bind (f v3) g ∪
... ∪
Many.bind (f vn) g
```

因此，两边相等，所以 `Many.bind` 是可交换的。

最终的 monad 实例是：

```lean
{{#example_decl Examples/Monads/Many.lean MonadMany}}
```

使用这个单子 (monad) 进行例子搜索，可以找到列表中所有相加等于15的数字组合：

```lean
{{#example_decl Examples/Monads/Many.lean addsTo}}
```

搜索过程是列表上的递归过程。
当目标是 `0` 时，空列表是一个成功的搜索；否则，它失败。
当列表非空时，有两种可能性：要么列表的头部大于目标，这种情况下它不能参与任何成功的搜索；要么列表的头部不大于目标，这种情况下它可以参与搜索。
如果列表的头部不是候选项，那么搜索将继续到列表的尾部。
如果头部是一个候选项，那么有两种可能性与 `Many.union` 结合：找到的解中包含头部，或者不包含。
不包含头部的解由对尾部的递归调用找到，而包含头部的解是通过将头部从目标中减去，然后将头部附加到递归调用结果中得到的。

回到产生多重集结果的算术求值器，`both` 和 `neither` 运算符可以表示如下：

```lean
{{#example_decl Examples/Monads/Class.lean NeedsSearch}}
```

使用这些运算符，可以对先前的示例进行评估：

```lean
{{#example_decl Examples/Monads/Class.lean opening}}

{{#example_in Examples/Monads/Class.lean searchA}}
```



```output info
{{#example_out Examples/Monads/Class.lean searchA}}
```



```lean
{{#example_in Examples/Monads/Class.lean searchB}}
```



```output info
{{#example_out Examples/Monads/Class.lean searchB}}
```



```lean
{{#example_in Examples/Monads/Class.lean searchC}}
```



```output info
{{#example_out Examples/Monads/Class.lean searchC}}
```

#### 自定义环境

通过允许使用字符串作为操作符，并为字符串提供对应的函数映射，评估器可以被用户进行扩展。例如，用户可以通过扩展余数操作符或返回两个参数中的最大值来扩展评估器。函数名称与函数实现之间的映射称为环境。

环境需要在每一次递归调用中传递。起初，似乎 `evaluateM` 需要一个额外的参数来保存环境，并且应该将这个参数传递给每个递归调用。然而，像这样传递参数实际上是一种形式的Monad，因此适当的 `Monad` 实例允许评估器保持不变。

将函数用作Monad通常称为_Reader Monad_。在使用Reader Monad评估表达式时，使用以下规则：
 * 常量 \\( n \\) 评估为常数函数 \\( λ e . n \\)，
 * 算术运算符评估为将其参数传递的函数，因此 \\( f + g \\) 评估为 \\( λ e . f(e) + g(e) \\)，以及
 * 自定义操作符评估为将自定义操作符应用于参数得到的结果，因此 \\( f \\ \\mathrm{OP}\\ g \\) 评估为
   \\[
     λ e .
     \\begin{cases}
     h(f(e), g(e)) & \\mathrm{if}\\ e\\ \\mathrm{contains}\\ (\\mathrm{OP}, h) \\\\
     0 & \\mathrm{otherwise}
     \\end{cases}
   \\]
   其中 \\( 0 \\) 作为当应用未知操作符时的回退值。

为了在Lean中定义Reader Monad，第一步是定义 `Reader` 类型和允许用户获取环境的效果：

```lean
{{#example_decl Examples/Monads/Class.lean Reader}}
```

根据惯例，希腊字母 `ρ`，读作 "rho"，被用于表示环境。

在算术表达式中，常数被计算为常数函数的事实暗示了适用于 `Reader` 的 `pure` 的合适定义是一个常数函数：

```lean
{{#example_decl Examples/Monads/Class.lean ReaderPure}}
```

另一方面，`bind` 函数要复杂一些。
它的类型是 `{{#example_out Examples/Monads/Class.lean readerBindType}}`。
通过展开 `Reader` 的定义，可以更容易地理解这个类型，得到 `{{#example_out Examples/Monads/Class.lean readerBindTypeEval}}`。
该函数应接受一个接受环境的函数作为第一个参数，而第二个参数应将接受环境的函数的结果转换为另一个接受环境的函数。
这两者的组合结果本身是一个函数，等待一个环境作为输入。

可以使用 Lean 进行交互式编程，以获取编写该函数的帮助。
第一步是写下参数和返回类型，要尽可能明确以获取尽可能多的帮助，并在定义的主体使用下划线表示：

```lean
{{#example_in Examples/Monads/Class.lean readerbind0}}
```

Lean 提供了一条消息，描述了哪些变量在作用域中可用，以及结果所期望的类型。
符号 `⊢` 被称为 _turnstile_（转门），因其类似于地铁入口的形状，它将局部变量与期望的类型分开，在这条消息中期望的类型是 `ρ → β`。

```output error
{{#example_out Examples/Monads/Class.lean readerbind0}}
```

因为返回类型是一个函数，所以一个好的第一步是在下划线周围加上 `fun` 包装起来：

```lean
{{#example_in Examples/Monads/Class.lean readerbind1}}
```

现在，结果消息中显示函数的参数作为本地变量：

```output error
{{#example_out Examples/Monads/Class.lean readerbind1}}
```

在上下文中，唯一能产生 `β` 的是 `next`，为了能够产生 `β`，它需要接受两个参数。
每个参数本身可以是下划线：

```lean
{{#example_in Examples/Monads/Class.lean readerbind2a}}
```

双下划线具有以下相应关联信息：

```output error
{{#example_out Examples/Monads/Class.lean readerbind2a}}
```



```output error
{{#example_out Examples/Monads/Class.lean readerbind2b}}
```

攻击第一个下划线，上下文中只有一件事可以产生 `α`，那就是 `result`：

```lean
{{#example_in Examples/Monads/Class.lean readerbind3}}
```

现在，两个下划线都有相同的错误：

```output error
{{#example_out Examples/Monads/Class.lean readerbind3}}
```

愉快的是，两个下划线都可以替换为 `env`，结果如下：

```lean
{{#example_decl Examples/Monads/Class.lean readerbind4}}
```

可以通过撤销 `Reader` 的展开并清理明确细节来得到最终版本:

```lean
{{#example_decl Examples/Monads/Class.lean Readerbind}}
```

通过简单地 “遵循类型” 写函数并不总能保证是正确的，而且还存在理解生成的程序的风险。
然而，已经编写好的程序可能更容易理解，而填写下划线的过程可以带来洞见。
在这种情况下，`Reader.bind` 的工作方式与 `Id` 的 `bind` 完全相同，只是它接受一个附加参数并将其传递给其参数，这种直觉有助于理解其工作原理。

生成常量函数的 `Reader.pure` 和 `Reader.bind` 遵守了单子约定。
要检查 `Reader.bind (Reader.pure v) f` 是否与 `f v` 相同，只需使用替代定义直到最后一步：

```lean
{{#example_eval Examples/Monads/Class.lean ReaderMonad1}}
```

对于任意函数 `f`，`fun x => f x` 和 `f` 是相同的，因此合同的第一部分得到满足。
为了验证 `Reader.bind r Reader.pure` 和 `r` 是相同的，可以使用类似的技巧：

```lean
{{#example_eval Examples/Monads/Class.lean ReaderMonad2}}
```

由于读者的操作 `r` 本身就是函数，所以它和 `r` 是一样的。

要检查结合律，可以对 `{{#example_eval Examples/Monads/Class.lean ReaderMonad3a 0}}` 和 `{{#example_eval Examples/Monads/Class.lean ReaderMonad3b 0}}` 做同样的事情：

```lean
{{#example_eval Examples/Monads/Class.lean ReaderMonad3a}}
```



```lean
{{#example_eval Examples/Monads/Class.lean ReaderMonad3b}}
```

因此，`Monad (Reader ρ)` 的实例是合理的：

```lean
{{#example_decl Examples/Monads/Class.lean MonadReaderInst}}
```

表达式求值器将接收到的自定义环境可以表示为一组键值对的列表：

```lean
{{#example_decl Examples/Monads/Class.lean Env}}
```

例如，`exampleEnv` 包含最大值和取模函数：

```lean
{{#example_decl Examples/Monads/Class.lean exampleEnv}}
```

Lean已经有一个名为`List.lookup`的函数，在一组键值对的列表中查找与键相关联的值，所以`applyPrimReader`只需要检查自定义函数是否存在于环境中。如果该函数未知，则返回`0`：

```lean
{{#example_decl Examples/Monads/Class.lean applyPrimReader}}
```

使用 `evaluateM` 结合 `applyPrimReader` 和一个表达式会得到一个需要环境的函数。
幸运的是，现在有一个可用的 `exampleEnv`：

```lean
{{#example_in Examples/Monads/Class.lean readerEval}}
```



```output info
{{#example_out Examples/Monads/Class.lean readerEval}}
```

像 `Reader` 一样，`Many` 也是一个在大多数语言中难以编码的效果的例子，但是类型类和单子使它变得像其他效果一样方便。
Common Lisp、Clojure 和 Emacs Lisp 中的动态或特殊变量可以像 `Reader` 一样使用。
类似地，Scheme 和 Racket 的参数对象是一个与 `Reader` 完全对应的效果。
Kotlin 的上下文对象习语可以解决类似的问题，但它们基本上是自动传递函数参数的一种方式，因此这个习语更像是作为一个读取器单子的编码，而不是语言中的一个效果。

## 练习

### 检查合约

检查 `State σ` 和 `Except ε` 的单子合约。


### 具有失败的读取器

改编读取器单子的示例，使其在自定义操作符未定义时也能指示失败，而不仅仅返回零。
换句话说，给定以下定义：

```lean
{{#example_decl Examples/Monads/Class.lean ReaderFail}}
```

### 一个跟踪评估器

可以使用 `WithLog` 类型与评估器一起，以添加对某些操作的可选跟踪。
特别是，类型 `ToTrace` 可以作为跟踪给定运算符的信号：

```lean
{{#example_decl Examples/Monads/Class.lean ToTrace}}
```

对于追踪求值器（tracing evaluator），表达式的类型应为 `Expr (Prim (ToTrace (Prim Empty)))`。
这意味着表达式中的运算符由加法、减法和乘法组成，每个运算符都增加了追踪（trace）的版本。最内层的参数是 `Empty`，表示在 `trace` 内部没有其他特殊运算符，只有这三个基本运算符。

请完成以下任务：
 1. 实现 `Monad (WithLog logged)` 的实例
 2. 编写一个 `{{#example_in Examples/Monads/Class.lean applyTracedType}}` 函数，将追踪（traced）运算符应用于它们的参数，并记录运算符和参数，类型为 `{{#example_out Examples/Monads/Class.lean applyTracedType}}`

如果正确完成了这个练习，那么

```lean
{{#example_in Examples/Monads/Class.lean evalTraced}}
```

应该得到的结果是：

```output info
{{#example_out Examples/Monads/Class.lean evalTraced}}
```

### LEAN 定理证明

这是一篇关于 LEAN 定理证明的文章，Declarative Systems 和 斯坦福大学的研究人员共同合作完成了这一工作。该证明基于主流的归纳定义和表达式，采用了高层次的逻辑和构造证明方法。

在这个证明中，使用了一种称为 `Prim` 类型的新的基础类型。在运行 `#eval` 时，`Prim Empty` 类型的值将显示在结果中。为了让这些值能够作为 `#eval` 的结果显示出来，需要使用下面提到的实例。

**实例：**

```lean
{{#example_decl Examples/Monads/Class.lean ReprInstances}}
```

这些实例将帮助我们正确地显示 `Prim Empty` 类型的值。在查看 `#eval` 的结果时，这些实例会起到关键的作用。通过使用这些实例，我们可以更好地理解 LEAN 中的定理证明过程。