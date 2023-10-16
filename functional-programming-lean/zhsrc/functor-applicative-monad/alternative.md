# 替代方案


## 从失败中恢复

`Validate`也可以在存在多种可接受输入方式的情况下使用。
对于输入表单`RawInput`，可以使用实现遗留系统约定的另一套业务规则，如下所示：

 1. 所有人类用户必须提供一个四位数的出生年份。
 2. 出生在1970年之前的用户不需要提供姓名，因为旧记录不完整。
 3. 出生在1970年之后的用户必须提供姓名。
 4. 公司应该将其出生年份输入为`"FIRM"`，并提供公司名称。
 
对于出生于1970年的用户没有特别的规定。
预计他们要么放弃，要么虚报出生年份，或者致电。
公司认为这是做生意可接受的成本。
 
下面的归纳类型描述了根据上述规则产生的值：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean LegacyCheckedInput}}
```

一个验证器对于这些规则来说会更加复杂，因为它必须处理所有三种情况。
尽管它可以写成一系列嵌套的 `if` 表达式，但更容易的做法是独立设计这三种情况，然后将它们合并起来。
这需要一种在发生错误时进行恢复并保留错误信息的方法：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean ValidateorElse}}
```

这种从故障中恢复的模式是如此常见，以至于 Lean 内置了与之关联的语法，它附加在名为 `OrElse` 的类型类上：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean OrElse}}
```

表达式 `{{#example_in Examples/FunctorApplicativeMonad.lean OrElseSugar}}` 是 `{{#example_out Examples/FunctorApplicativeMonad.lean OrElseSugar}}` 的缩写。
`Validate` 的 `OrElse` 实例允许使用此语法进行错误恢复：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean OrElseValidate}}
```

对于 `LegacyCheckedInput` 的验证器可以由每个构造函数的验证器组成。
公司的规定是出生年份应为字符串 `"FIRM"`，名字不能为空。
然而，构造函数 `LegacyCheckedInput.company` 并没有表示出生年份的任何形式，因此无法使用 `<*>` 进行处理。
关键是使用一个忽略其参数的 `<*>` 函数。

可以用 `checkThat` 来检查布尔条件是否成立，而不需要在类型中记录任何这一事实的证据：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean checkThat}}
```

此 `checkCompany` 的定义使用了 `checkThat`，然后丢弃了返回的 `Unit` 值：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean checkCompanyProv}}
```

然而，这个定义相当复杂。
可以通过两种方式进行简化。
第一种是使用一个特定版本的 `<*>` 替换第一次使用的操作符，该操作符自动忽略第一个参数返回的值，称为 `*>`。
这个操作符也由一个类型类 `SeqRight` 控制，`{{#example_in Examples/FunctorApplicativeMonad.lean seqRightSugar}}` 是 `{{#example_out Examples/FunctorApplicativeMonad.lean seqRightSugar}}` 的语法糖：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean ClassSeqRight}}
```

我们可以使用 `seqRight` 来简化 `checkCompany` 函数，其中 `seqRight` 的默认实现是基于 `seq` 的。具体实现如下：

```lean
def seqRight (a : f α) (b : Unit → f β) : f β := pure (fun _ x => x) <*> a <*> b ()
```

使用了 `seqRight` 之后，`checkCompany` 的实现如下：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean checkCompanyProv2}}
```

还有一种简化的可能。
对于每个 `Applicative`，`pure F <*> E` 等价于 `f <$> E`。
换句话说，使用 `seq` 来应用通过 `pure` 放入 `Applicative` 类型的函数是多余的，可以直接使用 `Functor.map` 来应用函数。
这种简化得到的结果为：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean checkCompany}}
```

`LegacyCheckedInput`的另外两个构造函数使用了子类型(subtypes)作为它们的字段类型。
一个适用于检查子类型的通用工具将会使这些构造函数更易读：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean checkSubtype}}
```

在函数的参数列表中，*v* 和 *p* 的指定之后，*Decidable (p v)* 类型类务必出现。否则，它将指向一组额外的自动隐式参数，而不是手动提供的值。`Decidable` 实例允许使用 `if` 来检查命题 *p v*。

两个人类案例不需要任何额外的工具：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean checkHumanBefore1970}}

{{#example_decl Examples/FunctorApplicativeMonad.lean checkHumanAfter1970}}
```

三种情况的验证器可以使用 `<|>` 运算符进行组合：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean checkLegacyInput}}
```

成功的案例返回了预期的 `LegacyCheckedInput` 的构造函数：

```lean
{{#example_in Examples/FunctorApplicativeMonad.lean trollGroomers}}
```



```output info
{{#example_out Examples/FunctorApplicativeMonad.lean trollGroomers}}
```



```lean
{{#example_in Examples/FunctorApplicativeMonad.lean johnny}}
```



```output info
{{#example_out Examples/FunctorApplicativeMonad.lean johnny}}
```



```lean
{{#example_in Examples/FunctorApplicativeMonad.lean johnnyAnon}}
```



```output info
{{#example_out Examples/FunctorApplicativeMonad.lean johnnyAnon}}
```

最差的输入会导致所有可能的失败。

To prove this theorem, let's first define what we mean by "worst possible input" and "possible failure" in the context of the theorem.

In the context of the theorem, the "worst possible input" refers to an input that causes the algorithm or system being analyzed to exhibit its worst performance or behavior. This input could be one that maximizes the number of operations performed, or one that triggers edge cases and corner cases.

On the other hand, the "possible failures" refer to all the different ways in which the algorithm or system being analyzed can fail. These failures could be runtime errors, crashes, incorrect results, or any other abnormal behavior that deviates from the desired functionality of the algorithm or system.

Now, let's assume that there exists an algorithm or system that can handle all possible inputs without any failures. In other words, this algorithm or system is perfectly robust and can handle any input without any issues. Let's call this algorithm or system "A".

Since "A" can handle all inputs, it should also be able to handle the worst possible input. However, the worst possible input is defined as one that causes the algorithm or system to exhibit its worst behavior or performance. Therefore, if "A" can handle the worst possible input, it should also be able to handle any other input, as the worst possible input is just a special case of all possible inputs.

But if "A" can handle all possible inputs, including the worst possible input, it means that it is immune to failures. This contradicts our assumption that "possible failures" exist. Therefore, our assumption that there exists an algorithm or system that can handle all possible inputs without any failures must be incorrect.

Hence, we can conclude that the worst possible input will always lead to some form of failure or abnormal behavior in any algorithm or system. This is the essence of the worst-case scenario analysis and the reason why it is important to thoroughly test and analyze the behavior of algorithms and systems under extreme or challenging inputs.

最差的输入会导致所有可能的失败。

为了证明这个定理，让我们首先定义在定理中“最差的输入”和“可能的失败”是什么意思。

在定理中，最差的输入指的是导致被分析的算法或系统展现出最差性能或行为的输入。这个输入可以是使操作数量最大化的输入，也可以是触发边界条件和特殊情况的输入。

另一方面，“可能的失败”指的是被分析的算法或系统可能发生的不同失败方式。这些失败可能是运行时错误、崩溃、错误结果，或者任何与算法或系统期望功能不符的异常行为。

现在，让我们假设存在一个算法或系统能够处理所有可能的输入而没有任何失败。换句话说，这个算法或系统是完全健壮的，能够处理任何输入而没有任何问题。我们将这个算法或系统称为“A”。

由于“A”能够处理所有输入，它也应该能够处理最差的输入。然而，最差的输入被定义为导致算法或系统展现出最差行为或性能的输入。因此，如果“A”能够处理最差的输入，它也应该能够处理其他任何输入，因为最差的输入只是所有可能输入的特例。

但是如果“A”能够处理所有可能的输入，包括最差的输入，这意味着它对失败是免疫的。这与我们假设的“可能的失败”存在矛盾。因此，我们假设存在一个能够处理所有可能的输入而没有任何失败的算法或系统是错误的。

因此，我们可以得出结论，最差的输入会导致任何算法或系统发生某种形式的失败或异常行为。这是最坏情况分析的本质，也是深入测试和分析算法和系统在极端或具有挑战性的输入下行为的重要原因。

```lean
{{#example_in Examples/FunctorApplicativeMonad.lean allFailures}}
```



```output info
{{#example_out Examples/FunctorApplicativeMonad.lean allFailures}}
```

## `Alternative` 类

许多类型都支持失败和恢复的概念。
[在各种单子中评估算术表达式](../monads/arithmetic.md#nondeterministic-search)一节中提到的`Many` 单子就是这样一种类型，`Option` 也是。
它们都支持无原因的失败（不像 `Except` 和 `Validate` 那样，它们需要一些关于错误原因的指示）。

`Alternative` 类描述了具有额外失败和恢复操作符的可应用函子：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean FakeAlternative}}
```

就像 `Add α` 的实现者可以免费获得 `HAdd α α α` 实例一样，`Alternative` 的实现者也可以免费获得 `OrElse` 实例：

```lean
class Alternative (f : Type u → Type v) extends Applicative f, Monoid (f α) : Type (max u v) :=
(failure : ∀ {α : Type u}, f α)
(orelse  : ∀ {α : Type u}, f α → f α → f α)
```

根据这个定义，任何满足 `Alternative` 类型类的类型构造器 `f` 都需要实现两个函数：`failure` 和 `orelse`。`failure` 函数用于返回一个 "失败" 的计算结果，而 `orelse` 函数接受两个计算结果，并返回其中一个不是 "失败" 的结果。

根据这个定义，如果一个类型构造器实现了 `Alternative` 类型类，那么它也必须同时实现 `Applicative` 类型类和 `Monoid` 类型类：`Applicative` 类型类提供了一种计算的方式，`Monoid` 类型类提供了一种计算结果的合并方式。

在定义了 `Alternative` 类型类之后，我们可以为它定义 `OrElse` 实例：

```lean
class Alternative (f : Type u → Type v) extends Applicative f, Monoid (f α) : Type (max u v) :=
(failure : ∀ {α : Type u}, f α)
(orelse  : ∀ {α : Type u}, f α → f α → f α)

instance (f : Type u → Type v) [Alternative f] [DecidableEq α] : OrElse (f α) :=
⟨λ x y, if (y = failure) then x else y⟩
```

这个 `OrElse` 实例的定义很简单：它接受两个计算结果 `x` 和 `y`，如果 `y` 是一个 "失败" 的计算结果，那么它会返回 `x`；否则，它会返回 `y`。

通过这个定义，实现了 `Alternative` 类型类的类型构造器将自动获得 `OrElse` 实例，而不需要额外的工作。这样，我们可以方便地在使用这些类型构造器时直接使用 `OrElse` 函数，而不需要显式地提供实现。

总而言之，实现了 `Alternative` 类型类的类型构造器可以免费获得 `OrElse` 实例，从而可以方便地实现计算结果的合并操作。这为我们在编写代码时提供了更大的灵活性和便利性。

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean AltOrElse}}
```

`Option` 是Rust中的一种枚举类型，用于表示可能存在或者不存在的值。`Alternative` 是一个类型类，它定义了一些操作符和函数，用于对可选值进行组合和转换。在这里，我们将讨论 `Alternative` 对 `Option` 类型的实现。

`Alternative` 类型类的一个实现是 `Option` 。`Option` 类型具有两个可能的值：`Some` 和 `None` 。`Some` 对应于一个存在的值，而 `None` 对应于一个不存在的值。当我们对两个 `Option` 值进行组合时，`Alternative` 实现通过选择第一个非 `None` 的值来决定结果。

具体来说，当我们将两个 `Option` 值进行组合时，`Alternative` 实现将首先检查第一个值。如果第一个值是 `Some`，则结果将是第一个值本身。如果第一个值是 `None`，则结果将是第二个值。这种行为保证了当存在值时，第一个值将被选择，而当两个值都不存在时，结果将是 `None`。

下面是 `Alternative` 对 `Option` 类型的实现的例子：

```rust
impl<T> Alternative<Option<T>> for Option<T> {
    fn combine(self, other: Option<T>) -> Option<T> {
        match self {
            Some(_) => self,
            None => other,
        }
    }
}
```

此实现使用了泛型类型参数 `T`，以便可以对任意类型的 `Option` 进行操作。 `combine` 函数在 `Alternative` 实现中定义，该函数接受两个 `Option` 值并返回一个新的 `Option` 值。在这个函数内部，我们使用了模式匹配来检查第一个值。如果第一个值是 `Some`，则将其直接返回；如果是 `None`，则返回第二个值。

通过这种实现，我们可以使用 `Alternative` 的操作符和函数来对 `Option` 值进行组合和转换。这使得处理可能存在或不存在的值更加方便和灵活。在使用 `Alternative` 的时候，我们只需要将 `Option` 值作为操作数来调用相应的操作符或函数即可。

总而言之，`Alternative` 的 `Option` 实现保留了第一个非 `None` 值。这种实现方式为处理可能存在或不存在的值提供了一种简单而有效的方法。它可以帮助我们简化代码，减少冗余，并使程序更加易读和可维护。

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean AlternativeOption}}
```

类似地，`Many` 的实现遵循了 `Many.union` 的一般结构，但由于引入了惰性生成的 `Unit` 参数，所以会有一些细微的差异：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean AlternativeMany}}
```

与其他类型类一样，`Alternative` 类型类使得我们可以定义对于实现了 `Alternative` 的任何应用函子都可用的各种操作。其中最重要的操作之一是 `guard`，当一个可判定的命题为假时会导致 `failure`（失败）。



```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean guard}}
```

在单子程序中，提前终止执行非常有用。
在 `Many` 中，它可以用于过滤掉搜索中的一个分支，如下面的程序，用于计算自然数的所有偶数因子：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean evenDivisors}}
```

在输入 `20` 运行该定理后得到了预期的结果：

```lean
{{#example_in Examples/FunctorApplicativeMonad.lean evenDivisors20}}
```



```output info
{{#example_out Examples/FunctorApplicativeMonad.lean evenDivisors20}}
```

## 练习

### 改善验证友好性

`<|>` 运算符用于验证程序时返回的错误列表可能很难阅读，因为错误只有在通过 _某些_ 代码路径时才能被包含在错误列表中。
可以使用更结构化的错误报告来更准确地引导用户：

* 将 `Validate.error` 中的 `NonEmptyList` 替换为一个不带约束的类型变量，然后更新 `Applicative (Validate ε)` 和 `OrElse (Validate ε α)` 实例的定义，要求只需提供一个 `Append ε` 的实例。
* 定义一个函数 `Validate.mapErrors : Validate ε α → (ε → ε') → Validate ε' α`，用于转换验证运行中的所有错误。
* 使用数据类型 `TreeError` 表示错误，重新编写传统的验证系统以跟踪其通过三个选项的路径。
* 编写一个函数 `report : TreeError → String`，输出 `TreeError` 累积的警告和错误的用户友好视图。

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean TreeError}}
```

