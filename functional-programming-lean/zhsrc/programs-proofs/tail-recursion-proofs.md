# 证明等价性

将程序重写为尾递归形式并使用累加器时，其看起来与原始程序有很大的区别。
原始递归函数通常更易于理解，但运行时可能会耗尽栈空间。
在通过测试排除简单错误之后，可以使用证明来一劳永逸地证明这些程序是等价的。

## 证明 `sum` 是相等的

要证明 `sum` 的两个版本是相等的，首先编写具有桩证明的定理陈述：

```leantac
{{#example_in Examples/ProgramsProofs/TCO.lean sumEq0}}
```

如预期的那样，Lean描述了一个未解决的目标：

```output error
{{#example_out Examples/ProgramsProofs/TCO.lean sumEq0}}
```

在这里无法应用 `rfl` 策略，因为 `NonTail.sum` 和 `Tail.sum` 不具有定义等价关系。
然而，函数之间的相等性可以通过证明它们对于相同的输入产生相等的输出来证明。
换句话说，可以通过证明对于所有可能的输入 \\( x \\)， \\( f(x) = g(x) \\) 来证明 \\( f = g \\)。
这一原则被称为_函数外延性_。
函数外延性正是 `NonTail.sum` 等于 `Tail.sum` 的原因：它们都对列表中的数字求和。

在 Lean 的策略语言中，可以使用 `funext` 来调用函数外延性，后面跟一个用于任意参数的名称。
任意参数将作为假设添加到上下文中，目标也会变为要求证明这些函数应用于该参数时相等：


```leantac
{{#example_in Examples/ProgramsProofs/TCO.lean sumEq1}}
```



```output error
{{#example_out Examples/ProgramsProofs/TCO.lean sumEq1}}
```

这个目标可以通过对参数 `xs` 进行归纳证明来实现。
当应用于空列表时，两个 `sum` 函数都返回 `0`，这作为基础情况。
在输入列表的开头添加一个数字会导致两个函数将该数字加到结果中，这作为归纳步骤。
调用 `induction` 策略会产生两个目标：

```leantac
{{#example_in Examples/ProgramsProofs/TCO.lean sumEq2a}}
```



```output error
{{#example_out Examples/ProgramsProofs/TCO.lean sumEq2a}}
```



```output error
{{#example_out Examples/ProgramsProofs/TCO.lean sumEq2b}}
```

`nil` 的基本情况可以使用 `rfl` 解决，因为当传入空列表时，两个函数都返回 `0` ：


```leantac
{{#example_in Examples/ProgramsProofs/TCO.lean sumEq3}}
```

解决归纳步骤的第一步是简化目标，通过使用 `simp` 展开 `NonTail.sum` 和 `Tail.sum`：

```leantac
{{#example_in Examples/ProgramsProofs/TCO.lean sumEq4}}
```



```output error
{{#example_out Examples/ProgramsProofs/TCO.lean sumEq4}}
```

展开 `Tail.sum` 后发现它立即委托给了 `Tail.sumHelper`，这个函数也应该简化一下：

```leantac
{{#example_in Examples/ProgramsProofs/TCO.lean sumEq5}}
```

在所得到的目标中，`sumHelper` 进行了一步计算，并将 `y` 加到累加器中：

```output error
{{#example_out Examples/ProgramsProofs/TCO.lean sumEq5}}
```

重写归纳假设会从目标中移除所有对`NonTail.sum`的提及：

```leantac
{{#example_in Examples/ProgramsProofs/TCO.lean sumEq6}}
```



```output error
{{#example_out Examples/ProgramsProofs/TCO.lean sumEq6}}
```

这个新目标声明，将某个数字添加到列表的总和中，与将该数字用作 `sumHelper` 的初始累加器是等价的。为了清晰起见，这个新目标可以作为一个独立的定理来证明：

```leantac
{{#example_in Examples/ProgramsProofs/TCO.lean sumEqHelperBad0}}
```



```output error
{{#example_out Examples/ProgramsProofs/TCO.lean sumEqHelperBad0}}
```

再一次，这是一个使用归纳法证明的证明，其中基本情况使用 `rfl`：

```lean
theorem proof : ∀ (n : ℕ), 0 + n = n :=
begin
  intro n,
  induction n with n' ih,
  { -- base case
    exact rfl,
  },
  { -- induction step
    rw add_comm,
    rw zero_add,
    exact ih,
  },
end
```

证明：
对于所有自然数 n，有 0 + n = n。

我们使用归纳法证明这个定理。首先，我们验证基本情况，即 n = 0 时，0 + 0 = 0。在此基础上，我们进行归纳步骤，假设对于某个固定的自然数 n'，0 + n' = n' 成立，我们需要证明 0 + (n' + 1) = (n' + 1)。我们使用交换律和加法零元的定义来转换等式，根据归纳假设，我们可以得到此等式成立。

因此，根据归纳法原理，可以证明对于所有自然数 n，0 + n = n。

```leantac
{{#example_in Examples/ProgramsProofs/TCO.lean sumEqHelperBad1}}
```



```output error
{{#example_out Examples/ProgramsProofs/TCO.lean sumEqHelperBad1}}
```

由于这是归纳步骤，目标应该简化，直到与归纳假设 `ih` 匹配。简化使用 `Tail.sum` 和 `Tail.sumHelper` 的定义，得到以下结果：

```leantac
{{#example_in Examples/ProgramsProofs/TCO.lean sumEqHelperBad2}}
```



```output error
{{#example_out Examples/ProgramsProofs/TCO.lean sumEqHelperBad2}}
```

Ideally, the induction hypothesis could be used to replace `Tail.sumHelper (y + n) ys`, but they don't match.

理想情况下，归纳假设可以替换 `Tail.sumHelper (y + n) ys`，但它们不匹配。

The induction hypothesis can be used for `Tail.sumHelper n ys`, not `Tail.sumHelper (y + n) ys`.

归纳假设可以用于 `Tail.sumHelper n ys`，而不是 `Tail.sumHelper (y + n) ys`。

In other words, this proof is stuck.

换言之，这个证明陷入了僵局。

## A Second Attempt

Rather than attempting to muddle through the proof, it's time to take a step back and think. Why is it that the tail-recursive version of the function is equal to the non-tail-recursive version? Fundamentally speaking, at each entry in the list, the accumulator grows by the same amount as would be added to the result of the recursion. This insight can be used to write an elegant proof. Crucially, the proof by induction must be set up such that the induction hypothesis can be applied to _any_ accumulator value.

与其试图通过证明，不如退一步思考。为什么尾递归版本的函数等于非尾递归版本？从根本上说，在列表的每个项中，累加器的增长量与递归结果的增量相同。这个洞见可以用来编写一个优雅的证明。关键是，归纳证明必须设置好，使归纳假设可以应用于**任何**累加器值。

Discarding the prior attempt, the insight can be encoded as the following statement:

放弃之前的尝试，这个洞见可以编码为以下陈述：

```leantac
{{#example_in Examples/ProgramsProofs/TCO.lean nonTailEqHelper0}}
```

在这个陈述中，非常重要的一点是 `n` 是在冒号后面的类型的一部分。
得到的目标以 `∀ (n : Nat)` 开头，这是“对于所有 `n`”的缩写。

```output error
{{#example_out Examples/ProgramsProofs/TCO.lean nonTailEqHelper0}}
```

使用归纳法策略得到的目标将包括这样的“对于所有”的陈述：

```leantac
{{#example_in Examples/ProgramsProofs/TCO.lean nonTailEqHelper1a}}
```

在 `nil` 情况下，我们的目标是：

```output error
{{#example_out Examples/ProgramsProofs/TCO.lean nonTailEqHelper1a}}
```

对于`cons`的归纳步骤来说，归纳假设和具体目标都包含了“对于所有`n`”的表达。

```output error
{{#example_out Examples/ProgramsProofs/TCO.lean nonTailEqHelper1b}}
```

换句话说，证明的目标变得更具挑战性，但归纳假设相应地变得更有用。

对于以“对于所有 \\( x \\)”开头的陈述的数学证明应该假设一些任意的 \\( x \\)，并证明该陈述。
“任意”意味着不假设 \\( x \\) 的任何其他属性，因此得到的陈述适用于 _任意_ \\( x \\)。
在 Lean 中，“对于所有”陈述是一个依赖函数：无论应用到哪个具体的值，它将返回该命题的证据。
类似地，选择任意的 \\( x \\) 的过程与使用 ``fun x => ...`` 相同。
在策略语言中，通过使用 `intro` 策略来执行选择任意的 \\( x \\) 的过程，该策略在策略脚本完成后在后台生成函数。
对于这个任意值，`intro` 策略需要提供一个名称。

在 `nil` 情况中使用 `intro` 策略会从目标中移除 `∀ (n : Nat),`，并添加一个假设 `n : Nat`：

```leantac
{{#example_in Examples/ProgramsProofs/TCO.lean nonTailEqHelper2}}
```



```output error
{{#example_out Examples/ProgramsProofs/TCO.lean nonTailEqHelper2}}
```

这个命题的两边都按照定义等于 `n`，所以 `rfl` 就足够了：

```leantac
{{#example_in Examples/ProgramsProofs/TCO.lean nonTailEqHelper3}}
```

`cons` 目标也包含了一个“对于所有”的要求：

```output error
{{#example_out Examples/ProgramsProofs/TCO.lean nonTailEqHelper3}}
```

这表明可以使用 `intro`。

```leantac
{{#example_in Examples/ProgramsProofs/TCO.lean nonTailEqHelper4}}
```



```output error
{{#example_out Examples/ProgramsProofs/TCO.lean nonTailEqHelper4}}
```

证明目标现在包含了应用 `NonTail.sum` 和 `Tail.sumHelper` 到 `y :: ys` 的部分。
简化器可以使下一步更加清晰：

```leantac
{{#example_in Examples/ProgramsProofs/TCO.lean nonTailEqHelper5}}
```



```output error
{{#example_out Examples/ProgramsProofs/TCO.lean nonTailEqHelper5}}
```

这个目标非常接近归纳假设的匹配。
有两个地方不匹配：
 * 等式的左边是 `n + (y + NonTail.sum ys)`，但是归纳假设要求等式的左边是一个数字加上 `NonTail.sum ys`。
   换句话说，这个目标应该重新写成 `(n + y) + NonTail.sum ys`，这是合法的，因为自然数加法是可结合的。
 * 当等式的左边被重新写成 `(y + n) + NonTail.sum ys` 时，右边的累加器参数应该是 `n + y` 而不是 `y + n`。
   这个重写是合法的，因为加法也是可交换的。

加法的结合性和交换性已经在 Lean 的标准库中被证明过。
结合性的证明被命名为 `{{#example_in Examples/ProgramsProofs/TCO.lean NatAddAssoc}}`，它的类型是 `{{#example_out Examples/ProgramsProofs/TCO.lean NatAddAssoc}}`，而交换性的证明则被称为 `{{#example_in Examples/ProgramsProofs/TCO.lean NatAddComm}}`，其类型为 `{{#example_out Examples/ProgramsProofs/TCO.lean NatAddComm}}`。
通常，`rw` 策略是使用一个类型为等式的表达式作为参数。
然而，如果参数是一个依赖函数，其返回类型为等式，则它试图找到一个使等式匹配目标中的某个内容的函数参数。
虽然只有一次机会可以应用结合性，但重写的方向必须被颠倒，因为 `{{#example_in Examples/ProgramsProofs/TCO.lean NatAddAssoc}}` 中等式的右边才是与证明目标匹配的部分：

```leantac
{{#example_in Examples/ProgramsProofs/TCO.lean nonTailEqHelper6}}
```



```output error
{{#example_out Examples/ProgramsProofs/TCO.lean nonTailEqHelper6}}
```

直接使用 `{{#example_in Examples/ProgramsProofs/TCO.lean NatAddComm}}` 进行重写会得到错误的结果。
`rw` 策略猜测的重写位置错误，导致了意外的目标：

```leantac
{{#example_in Examples/ProgramsProofs/TCO.lean nonTailEqHelper7}}
```



```output error
{{#example_out Examples/ProgramsProofs/TCO.lean nonTailEqHelper7}}
```

这个可以通过将 `y` 和 `n` 作为参数显式地提供给 `Nat.add_comm` 来解决：

```leantac
{{#example_in Examples/ProgramsProofs/TCO.lean nonTailEqHelper8}}
```



```output error
{{#example_out Examples/ProgramsProofs/TCO.lean nonTailEqHelper8}}
```

现在的目标与归纳假设相匹配。
特别地，归纳假设的类型是一个依赖函数类型。
将 `ih` 应用于 `n + y` 就得到了所期望的类型。
`exact` 策略在其参数具有所期望的精确类型时完成证明目标：

```leantac
{{#example_decl Examples/ProgramsProofs/TCO.lean nonTailEqHelperDone}}
```

实际的证明只需要进行一点额外的工作，以使目标与助手的类型相匹配。第一步仍然是调用函数外延性：

```leantac
{{#example_in Examples/ProgramsProofs/TCO.lean nonTailEqReal0}}
```



```output error
{{#example_out Examples/ProgramsProofs/TCO.lean nonTailEqReal0}}
```

下一步是展开`Tail.sum`，暴露`Tail.sumHelper`：

```leantac
{{#example_in Examples/ProgramsProofs/TCO.lean nonTailEqReal1}}
```



```output error
{{#example_out Examples/ProgramsProofs/TCO.lean nonTailEqReal1}}
```

经过上述步骤，类型几乎匹配。
然而，辅助函数在左侧多了一个加数。
换句话说，证明目标是 `NonTail.sum xs = Tail.sumHelper 0 xs`，但是将 `non_tail_sum_eq_helper_accum` 应用于 `xs` 和 `0` 后得到的类型是 `0 + NonTail.sum xs = Tail.sumHelper 0 xs`。
另一个标准库的证明 `{{#example_in Examples/ProgramsProofs/TCO.lean NatZeroAdd}}` 的类型是 `{{#example_out Examples/ProgramsProofs/TCO.lean NatZeroAdd}}`。
将该函数应用于 `NonTail.sum xs` 后得到的表达式的类型是 `{{#example_out Examples/ProgramsProofs/TCO.lean NatZeroAddApplied}}`，因此从右向左进行重写就得到了所需的目标：

```leantac
{{#example_in Examples/ProgramsProofs/TCO.lean nonTailEqReal2}}
```



```output error
{{#example_out Examples/ProgramsProofs/TCO.lean nonTailEqReal2}}
```

最后，助手可以用来完成证明：

```leantac
{{#example_decl Examples/ProgramsProofs/TCO.lean nonTailEqRealDone}}
```

这个证明展示了一种可以用于证明累加器传递的尾递归函数等于非尾递归版本的一般模式。

第一步是发现起始累加器参数和最终结果之间的关系。例如，以累加器 `n` 开始 `Tail.sumHelper` 将导致最终的和加上 `n`，以累加器 `ys` 开始 `Tail.reverseHelper` 将导致最终的反转列表被添加到 `ys` 前面。

第二步是将这种关系写成一个定理陈述，并通过归纳来证明。虽然在实际中累加器始终初始化为某个中性值，比如 `0` 或 `[]`，但是需要一个更一般的陈述来允许起始累加器可以是任何值，从而得到足够强大的归纳假设。

最后，使用这个辅助定理和实际的初始累加器值得到所需的证明。例如，在 `non_tail_sum_eq_tail_sum` 中，累加器被指定为 `0`。这可能需要重新编写目标，使中性初始累加器值出现在正确的位置。

## 练习

### 热身

使用 `induction` 策略编写你自己的 `Nat.zero_add`、`Nat.add_assoc` 和 `Nat.add_comm` 的证明。

### 更多累加器证明

#### 反转列表

将 `sum` 的证明改为 `NonTail.reverse` 和 `Tail.reverse` 的证明。第一步是思考累加器值传递给 `Tail.reverseHelper` 和非尾递归的反转之间的关系。正如在 `Tail.sumHelper` 中将一个数字添加到累加器中等同于将其添加到总和中一样，在 `Tail.reverseHelper` 中使用 `List.cons` 将一个新条目添加到累加器中等同于对结果进行某种变化。用铅笔和纸尝试三到四个不同的累加器值，直到关系变得清晰。使用这个关系来证明一个适当的辅助定理。然后，写下整体定理。因为 `NonTail.reverse` 和 `Tail.reverse` 是多态的，所以陈述它们的相等性时需要使用 `@` 来阻止 Lean 尝试确定要为 `α` 使用哪种类型。一旦 `α` 被视为一个普通参数，应当使用 `funext` 来同时应用于 `α` 和 `xs`：

```leantac
{{#example_in Examples/ProgramsProofs/TCO.lean reverseEqStart}}
```

这导致了一个合适的目标：

```output error
{{#example_out Examples/ProgramsProofs/TCO.lean reverseEqStart}}
```

#### 阶乘

通过找到累加器和结果之间的关系，并证明一个适当的辅助定理，证明前一节中的练习中的 `NonTail.factorial` 等于你的尾递归解法。