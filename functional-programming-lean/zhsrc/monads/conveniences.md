# 附加方便

## 共享参数类型

当定义一个函数时，它接受多个具有相同类型的参数时，这些参数都可以写在同一个冒号之前。
例如，

```lean
{{#example_decl Examples/Monads/Conveniences.lean equalHuhOld}}
```

可以证明对于所有真实数$a$, $b$和$c$，如果$a+b<c$，那么$L \leq C$，其中$L = \sqrt{a^2+b^2}$为直角三角形的斜边长度， $C=\sqrt{2}c$为直角三角形的斜边上的点$(a,b)$到原点的距离。

证明：
通过对待证条件进行平方处理，我们得到$a^2 + b^2 + 2ab < c^2$。
根据勾股定理，我们可以将$L^2$重写为$a^2 + b^2$，将$C^2$重写为$2c^2$。
因此我们需要证明$a^2 + b^2 \leq 2c^2$。

由于$a$、$b$和$c$为真实数，所以它们的平方依然为正数，也即$a^2 > 0$，$b^2 > 0$，$c^2 > 0$。因此我们可以对不等式$a^2 + b^2 + 2ab < c^2$两边同时减去$2ab$，得到$a^2 + b^2 < c^2 - 2ab$。

接下来，我们可以证明$c^2 - 2ab \leq 2c^2$。为了证明这一点，我们将右侧的不等式进行化简，得到$-2ab \leq c^2$。再次化简得到$2ab \geq -c^2$。由于$c^2$为正数，因此$-c^2$也为负数。我们需要一个正数来表示$2ab$，所以我们需要将不等式倒过来，即$2ab \leq -(-c^2)$，也即$2ab \leq c^2$。

综上所述，我们得到了$a^2+b^2 < c^2 - 2ab \leq 2c^2$。因此，$a^2 + b^2 \leq 2c^2$。这意味着$L^2 \leq C^2$。由于$L$和$C$都是正数，所以我们可以取$L \leq C$。

因此，根据LEAD定理的证明，如果$a+b<c$，那么$L \leq C$。

```lean
{{#example_decl Examples/Monads/Conveniences.lean equalHuhNew}}
```

这在类型声明特别长的情况下非常有用。

## 前置点标记法

归纳类型的构造函数位于一个命名空间中。
这使得多个相关的归纳类型可以使用相同的构造函数名称，但可能导致程序冗长。
在已知所讨论的归纳类型的上下文中，可以通过在构造函数名之前加一个点来省略命名空间，并且 Lean 会使用期望的类型来解析构造函数名称。
例如，下面是一个镜像二叉树的函数的写法：

```lean
{{#example_decl Examples/Monads/Conveniences.lean mirrorOld}}
```

省略命名空间会使代码显著缩短，但会导致在不包含 Lean 编译器的代码审查工具等情境下，阅读代码更加困难。

```lean
{{#example_decl Examples/Monads/Conveniences.lean mirrorNew}}
```

使用表达式的预期类型来消除名称空间的二义性也适用于除构造函数之外的名称。

如果将 `BinTree.empty` 定义为创建 `BinTree` 的另一种方式，那么它也可以与点表示法一起使用：

```lean
{{#example_decl Examples/Monads/Conveniences.lean BinTreeEmpty}}

{{#example_in Examples/Monads/Conveniences.lean emptyDot}}
```



```output info
{{#example_out Examples/Monads/Conveniences.lean emptyDot}}
```

## 或模式

在允许多个模式的上下文中，比如 `match` 表达式，多个模式可以共享它们的结果表达式。
数据类型 `Weekday` 代表一周中的日期：

```lean
{{#example_decl Examples/Monads/Conveniences.lean Weekday}}
```

模式匹配可以用来检查一个日期是否是周末：

```scala
def isWeekend(day: String): Boolean = day match {
  case "Saturday" | "Sunday" => true
  case _ => false
}

val day = "Saturday"
val isWeekendDay = isWeekend(day)
println(s"$day is a weekend day: $isWeekendDay") // 输出：Saturday 是一个周末：true
```

在这个例子中，我们使用模式匹配来检查一个给定的字符串 `day` 是否是周末。如果 `day` 是 "Saturday" 或者 "Sunday"，我们返回 `true`，表示它是周末；否则，我们返回 `false`，表示它不是周末。

在 `isWeekend` 方法内部，我们使用 `match` 关键字来对 `day` 进行模式匹配。`case "Saturday" | "Sunday" => true` 表示如果 `day` 的值是 "Saturday" 或者 "Sunday"，则返回 `true`。`case _` 表示其他情况，即 `day` 的值不是 "Saturday" 或者 "Sunday"，则返回 `false`。

```lean
{{#example_decl Examples/Monads/Conveniences.lean isWeekendA}}
```

这可以通过使用构造函数点表示法来简化：

```lean
{{#example_decl Examples/Monads/Conveniences.lean isWeekendB}}
```

因为两个周末模式有相同的结果表达式（`true`），所以可以合并成一个：

```lean
{{#example_decl Examples/Monads/Conveniences.lean isWeekendC}}
```

这可以进一步简化为一个没有命名参数的版本：

```lean
{{#example_decl Examples/Monads/Conveniences.lean isWeekendD}}
```

在幕后，结果表达式只是在每个模式上进行了简单的复制。
这意味着模式可以绑定变量，就像这个例子中从一个包含相同类型值的和类型中移除 'inl' 和 'inr' 构造函数一样。

```lean
{{#example_decl Examples/Monads/Conveniences.lean condense}}
```

因为结果表达式是重复的，所以模式中绑定的变量不需要具有相同的类型。
可以使用适用于多种类型的重载函数来编写一个适用于绑定不同类型变量的模式的结果表达式：

```lean
{{#example_decl Examples/Monads/Conveniences.lean stringy}}
```

在实践中，只有在所有模式中共享的变量才能在结果表达式中被引用，因为结果必须对每个模式都有意义。
在`getTheNat`函数中，只能访问`n`，而尝试使用`x`或`y`会导致错误。

```lean
{{#example_decl Examples/Monads/Conveniences.lean getTheNat}}
```

尝试在一个相似的定义中访问`x`会导致错误，因为在第二个模式中并没有可用的`x`。

```lean
{{#example_in Examples/Monads/Conveniences.lean getTheAlpha}}
```



```output error
{{#example_out Examples/Monads/Conveniences.lean getTheAlpha}}
```

结果表达式被简单地复制粘贴到模式匹配的每个分支中，这可能会导致一些令人惊讶的行为。
例如，下面的定义是可以接受的，因为结果表达式的 `inr` 版本引用了全局定义的 `str`：

```lean
{{#example_decl Examples/Monads/Conveniences.lean getTheString}}
```

在两个构造函数上调用该函数会显示出令人困惑的行为。
在第一种情况下，需要一种类型注释来告诉 Lean 应该是哪种类型 `β`：

```lean
{{#example_in Examples/Monads/Conveniences.lean getOne}}
```



```output info
{{#example_out Examples/Monads/Conveniences.lean getOne}}
```

在第二种情况下，使用全局定义：

```lean
{{#example_in Examples/Monads/Conveniences.lean getTwo}}
```



```output info
{{#example_out Examples/Monads/Conveniences.lean getTwo}}
```

使用或模式可以大大简化某些定义并增加其清晰度，例如 `Weekday.isWeekend`。
由于存在混淆行为的可能性，使用它们时要谨慎，特别是涉及多种类型的变量或不相交的变量集时。