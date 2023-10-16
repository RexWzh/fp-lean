# Applicative Functors

一个 _Applicative Functor_ 是一个拥有两个额外操作的 Functor：`pure` 和 `seq`。
`pure` 是 `Monad` 中使用的相同的操作符，因为事实上 `Monad` 是从 `Applicative` 继承而来的。
`seq` 和 `map` 类似：它允许使用一个函数来转换数据类型的内容。
然而，`seq` 中的函数本身包含在数据类型中：`{{#example_out Examples/FunctorApplicativeMonad.lean seqType}}`。
在类型为 `f` 的函数中，`Applicative` 实例可以控制函数的应用方式，而 `Functor.map` 则无条件地应用函数。
第二个参数的类型以 `Unit →` 开头，这样可以在函数永远不会被应用的情况下终止 `seq` 的定义。

这种短路行为的价值可以在 `Applicative Option` 的实例中看到：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean ApplicativeOption}}
```

在这种情况下，如果`seq`函数没有需要应用的函数，那么就没有必要计算它的参数，因此`x`永远不会被调用。
同样的考虑也适用于`Except`的`Applicative`实例：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean ApplicativeExcept}}
```

这种短路行为仅取决于_包围_函数的 `Option` 或 `Except` 结构，而不是函数本身。

可以将 Monad 看作是将连续执行语句的概念捕捉到纯函数式语言中的一种方式。
一个语句的结果可以影响后续要运行的语句。
这可以从 `bind` 的类型中看出：`{{#example_out Examples/FunctorApplicativeMonad.lean bindType}}`。
第一个语句的结果值是下一个要执行的函数的输入。
连续使用 `bind` 就像在命令式编程语言中的一系列语句，而 `bind` 足够强大，可以实现控制结构，如条件语句和循环。

根据这个类比，`Applicative` 捕捉了在具有副作用的语言中的函数应用的概念。
在像 Kotlin 或 C# 这样的语言中，函数的参数从左到右进行求值。
由较早参数执行的副作用发生在较晚参数之前。
函数本身无法实现依赖于参数具体_值_的自定义短路运算符。

通常，不直接调用 `seq`。
而是使用 `<*>` 运算符。
此运算符将其第二个参数包装在 `fun () => ...` 中，简化了调用点。
换句话说，`{{#example_in Examples/FunctorApplicativeMonad.lean seqSugar}}` 是 `{{#example_out Examples/FunctorApplicativeMonad.lean seqSugar}}` 的语法糖。


允许 `seq` 与多个参数一起使用的关键特征是，多参数的 Lean 函数实际上是一个返回等待其余参数的另一个函数的单参数函数。
换句话说，如果 `seq` 的第一个参数等待多个参数，那么 `seq` 的结果将等待剩余的参数。
例如，`{{#example_in Examples/FunctorApplicativeMonad.lean somePlus}}` 可以具有类型 `{{#example_out Examples/FunctorApplicativeMonad.lean somePlus}}`。
通过提供一个参数，`{{#example_in Examples/FunctorApplicativeMonad.lean somePlusFour}}` 的结果类型为 `{{#example_out Examples/FunctorApplicativeMonad.lean somePlusFour}}`。
这本身可以与 `seq` 一起使用，因此 `{{#example_in Examples/FunctorApplicativeMonad.lean somePlusFourSeven}}` 的类型为 `{{#example_out Examples/FunctorApplicativeMonad.lean somePlusFourSeven}}`。
并不是每个函子都是可应用函子。
`Pair` 类型就像内置的乘积类型 `Prod`：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean Pair}}
```

与 `Except` 类似，`{{#example_in Examples/FunctorApplicativeMonad.lean PairType}}` 具有类型 `{{#example_out Examples/FunctorApplicativeMonad.lean PairType}}`。
这意味着 `Pair α` 的类型是 `Type → Type`，并且可以定义一个 `Functor` 实例：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean FunctorPair}}
```

这个实例遵守 `Functor` 契约。

需要检查的两个属性是 `{{#example_eval Examples/FunctorApplicativeMonad.lean checkPairMapId 0}} = {{#example_eval Examples/FunctorApplicativeMonad.lean checkPairMapId 2}}` 和 `{{#example_eval Examples/FunctorApplicativeMonad.lean checkPairMapComp1 0}} = {{#example_eval Examples/FunctorApplicativeMonad.lean checkPairMapComp2 0}}`。
第一个属性可以通过逐步执行左边的求值过程并注意到它最终等于右边来进行检查：

```lean
{{#example_eval Examples/FunctorApplicativeMonad.lean checkPairMapId}}
```

第二个定理可以通过逐步验证两边的步骤，并注意它们会产生相同的结果来检查：

```lean
{{#example_eval Examples/FunctorApplicativeMonad.lean checkPairMapComp1}}

{{#example_eval Examples/FunctorApplicativeMonad.lean checkPairMapComp2}}
```

试图定义一个 `Applicative` 的实例，但是效果不太好。
这将需要定义 `pure`：

```lean
{{#example_in Examples/FunctorApplicativeMonad.lean Pairpure}}
```



```output error
{{#example_out Examples/FunctorApplicativeMonad.lean Pairpure}}
```

在作用域中有一个类型为 `β` 的值（即 `x`），下划线的错误信息建议下一步使用构造函数 `Pair.mk`：

```lean
{{#example_in Examples/FunctorApplicativeMonad.lean Pairpure2}}
```



```output error
{{#example_out Examples/FunctorApplicativeMonad.lean Pairpure2}}
```

很不幸，这里没有 `α` 可用。
因为 `pure` 需要对 _所有可能的类型_ α 进行处理来定义 `Applicative (Pair α)` 的实例，这是不可能的。
毕竟，调用者可以选择 `α` 为 `Empty`，这个类型根本没有值。

## 非单态 Applicative

当验证用户输入的表单时，通常最好一次提供多个错误，而不是一次一个错误。
这样用户就可以一览需求，了解需要满足计算机的内容，而不会在修复错误的过程中感到不断被骚扰。

理想情况下，验证用户输入的函数类型应该能够反映出来。
它应该返回一个具体的数据类型，检查文本框是否包含一个数字应该返回一个实际的数值类型。
验证程序可以在输入不通过验证时抛出异常。
然而，异常有一个重大的缺点：它们会在第一个错误处终止程序，无法累积错误列表。

另一方面，积累错误列表并在列表非空时失败的常见设计模式也具有问题。
一个长长的嵌套的 `if` 语句序列用于验证输入数据的每个子段是难以维护的，很容易丢失掉其中一两个错误消息。
理想情况下，验证可以使用一个 API 来执行，该 API 可以返回一个新值并自动跟踪和累积错误消息。

一个名为 `Validate` 的 Applicative 函子提供了一种实现这种 API 风格的方法。
与 `Except` Monad 类似，`Validate` 允许构造一个能准确描述已验证数据的新值。
与 `Except` 不同的是，`Validate` 允许累积多个错误，而无需检查列表是否为空。

### 用户输入
以用户输入为例，考虑以下结构：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean RawInput}}
```

需要实现的业务逻辑如下：
 1. 名称不能为空
 2. 出生年份必须是数字且非负数
 3. 出生年份必须大于1900年并且小于等于表单验证的年份
 
将这些条件表示为一种数据类型将需要一个名为“子类型”的新特性。
有了这个工具，可以编写一个验证框架，使用适用函子来跟踪错误，并在框架中实现这些规则。
 
### 子类型
最简单的方法是使用一个额外的 Lean 类型来表示这些条件，称为 `Subtype`：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean Subtype}}
```

这个结构有两个类型参数：一个隐式参数，表示数据类型 `α`，和一个显式参数 `p`，表示 `α` 上的谓词。
_谓词_ 是一个逻辑陈述，其中包含一个变量，可以替换为一个值以生成一个实际的陈述，就像 [传递给 `GetElem`](../type-classes/indexing.md#overloading-indexing) 的参数描述了索引在查找时的有效性。
对于 `Subtype` 来说，谓词切分出 `α` 的一些值的子集，使得谓词成立。
该结构的两个字段分别是来自 `α` 的一个值和证据，证明该值满足谓词 `p`。
Lean 对于 `Subtype` 有特殊的语法。
如果 `p` 的类型是 `α → Prop`，那么类型 `Subtype p` 也可以写作 `{{#example_out Examples/FunctorApplicativeMonad.lean subtypeSugar}}`，甚至在类型可以自动推断出来时可以写作 `{{#example_out Examples/FunctorApplicativeMonad.lean subtypeSugar2}}`。

用归纳类型表示正数的方法很清晰，也容易用编程实现。
然而，它存在一个主要的缺点。
虽然从 Lean 程序的角度来看，`Nat` 和 `Int` 具有普通归纳类型的结构，但编译器会特殊对待它们，并使用快速的任意精度数库来实现它们。
对于其他额外定义的用户类型来说，情况并非如此。
然而，对 `Nat` 限制为非零数值的子类型可以使用高效的表示方法，同时在编译时排除零：


```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean FastPos}}
```

最小的正有限数仍然是1。
现在，它不再是归纳类型的构造函数，而是一个用尖括号构造的结构的实例。
第一个参数是基础`Nat`，第二个参数是证明该`Nat`大于零的证据：

```leantac
{{#example_decl Examples/FunctorApplicativeMonad.lean one}}
```

`OfNat` 实例与 `Pos` 非常相似，只是它使用了一个短的策略证明来提供 `n + 1 > 0` 的证据：

```leantac
{{#example_decl Examples/FunctorApplicativeMonad.lean OfNatFastPos}}
```

`tactic`中的`tactic`是一种考虑到额外算术标识的简化版本。

子类型是一把双刃剑。
它们允许有效地表示验证规则，但是它们将维护这些规则的负担转移到库的用户身上，他们必须 _证明_ 他们没有违反重要的不变量。
通常，最好将它们在库的内部使用，为用户提供一个自动确保满足所有不变量的API，任何必要的证明都是库的内部。

检查类型为 `α` 的值是否在子类型 `{x：α // p x}` 中通常需要可判定命题 `p x`。
[关于等式和排序类的部分](../type-classes/standard-classes.md#equality-and-ordering)描述了如何将可判定命题与 `if` 结合使用。
当 `if` 与可判定命题一起使用时，可以提供一个名称。
在 `then` 分支中，该名称绑定到命题为真的证据，在 `else` 分支中，它被绑定到命题为假的证据。
当检查给定的 `Nat` 是否为正时，这非常方便：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean NatFastPos}}
```

在 `then` 分支中，`h` 绑定了 `n > 0` 的证据，这个证据可以作为 `Subtype` 构造函数的第二个参数使用。

### 验证输入

验证过的用户输入是一种使用多种技术表达业务逻辑的结构：
 * 结构类型本身对其有效性进行编码，因此 `CheckedInput 2019` 与 `CheckedInput 2020` 是不同的类型
 * 出生年份以 `Nat` 而不是 `String` 表示
 * 使用子类型来限制名称和出生年份字段中允许的值

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean CheckedInput}}
```

一个输入验证器应该将当前年份和 `RawInput` 作为参数，并返回一个经过检查的输入，或者至少一个验证失败。
这由 `Validate` 类型表示：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean Validate}}
```

这与 `Except` 很相似。
唯一的区别是 `error` 构造函数可以包含多个失败。

`Validate` 是一个函数子函子。
对其映射一个函数将转换可能存在的任何成功值，就像 `Except` 的 `Functor` 实例一样：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean FunctorValidate}}
```

`Validate` 的 `Applicative` 实例与 `Except` 的实例有一个重要的区别：`Except` 的实例在遇到第一个错误时终止，而 `Validate` 的实例则会同时累积来自函数和参数分支的所有错误：

```haskell
instance Applicative Validate where
  pure x = Validate (Success x) []  -- 成功的情况下返回结果以及空的错误列表
  (Validate (Success f) errsF) <*> (Validate (Success x) errsX) =
    Validate (Success (f x)) (errsF ++ errsX)  -- 组合函数和参数的结果，并合并错误列表
  (Validate _ errsF) <*> (Validate _ errsX) =
    Validate (Failure) (errsF ++ errsX)  -- 如果有任何一个分支出现了错误，则返回一个代表失败的结果并合并错误列表
```

在 `Applicative` 实例中，`pure` 函数将一个纯值转换为 `Validate`，结果是一个成功的 `Validate` 对象和一个空的错误列表。当两个 `Validate` 对象都是成功的，函数 `f` 和参数 `x` 都存在时，我们将 `f x` 包装在 `Success` 构造器中，并将两个错误列表合并在一起。如果有任何一个分支出现了错误，我们将返回一个代表失败的结果 `Failure`，并将两个错误列表合并在一起。

这种积累错误的方式使得我们能够获取所有分支的错误信息，而不仅仅是第一个错误。这对于需要一次性处理所有错误的场景来说非常有用。

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean ApplicativeValidate}}
```

使用 `.errors` 和 `NonEmptyList` 构造函数一起有点冗长。`reportError` 这样的辅助函数可以使代码更易读。在这个应用程序中，错误报告将由字段名和消息组成的对形式表示：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean Field}}

{{#example_decl Examples/FunctorApplicativeMonad.lean reportError}}
```

`if` 应用于 `Validate` 实例允许独立编写并组合每个字段的检查程序。
检查姓名需要确保字符串非空，然后以 `Subtype` 的形式返回这个事实的证据。
这里使用的是 `if` 的有证据绑定版本：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean checkName}}
```

在 `then` 分支中，`h` 绑定到 `name = ""` 的证据，而在 `else` 分支中，它绑定到 `¬name = ""` 的证据。

确实有一些验证错误会使其他检查变得不可能。
例如，如果一个困惑的用户将单词 `"syzygy"` 写成了一个数字，那么检查出生年份字段是否大于 1900 就没有意义。
只有在确保该字段实际包含数字之后，检查数字的允许范围才有意义。
这可以使用函数 `andThen` 来表示：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean ValidateAndThen}}
```

尽管这个函数的类型签名使得它适合作为`Monad`实例中的`bind`使用，但不这样做有很好的原因。详细信息可在“ Applicative”合同一节中阅读。（补充规定）。

要检查出生年份是否为数字，可以使用一个名为`String.toNat？：String→Option Nat`的内置函数非常有用。首先最好使用`String.trim`去除前导和尾随空格，这样最符合用户友好性：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean checkYearIsNat}}
```

为了检查提供的年份是否在预期范围内，我们需要嵌套地使用提供证据的 `if` 来进行判断：

```leantac
{{#example_decl Examples/FunctorApplicativeMonad.lean checkBirthYear}}
```

最后，这三个组件可以使用 `seq` 组合起来：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean checkInput}}
```

测试`checkInput`函数表明它确实可以返回多个反馈信息：

```python
test_input = "1234"
result = checkInput(test_input)
print(result)
```

输出应该是：

```
Input is valid.
```

但是当我们测试一个无效的输入时：

```python
test_input = "ABCD"
result = checkInput(test_input)
print(result)
```

输出应该是：

```
Invalid input. Input should consist of digits.
```

这证明了`checkInput`函数可以根据不同的情况返回不同的反馈信息。

```lean
{{#example_in Examples/FunctorApplicativeMonad.lean checkDavid1984}}
```



```output info
{{#example_out Examples/FunctorApplicativeMonad.lean checkDavid1984}}
```



```lean
{{#example_in Examples/FunctorApplicativeMonad.lean checkBlank2045}}
```



```output info
{{#example_out Examples/FunctorApplicativeMonad.lean checkBlank2045}}
```



```lean
{{#example_in Examples/FunctorApplicativeMonad.lean checkDavidSyzygy}}
```



```output info
{{#example_out Examples/FunctorApplicativeMonad.lean checkDavidSyzygy}}
```

使用`checkInput`进行表单验证是展示`Applicative`比`Monad`更具优势的关键。
因为`>>=`提供了足够的能力来根据第一步的值修改程序执行的剩余部分，所以必须传递一个值给它以继续执行。
如果没有收到任何值（例如因为发生了错误），那么`>>=`就无法执行程序的剩余部分。
`Validate`展示了为什么在任何情况下运行程序的剩余部分都是有用的：在不需要先前的数据的情况下，运行程序的剩余部分可以提供有用的信息（在这种情况下，更多的验证错误）。
`Applicative`的`<*>`可以在再组合结果之前同时运行它的两个参数。
类似地，`>>=`强制顺序执行。
每一步必须在下一步运行之前完成。
这通常是有用的，但它使得无法对自然地从程序的实际数据依赖中产生的不同线程进行并行执行。
像`Monad`这样更强大的抽象增加了API消费者可用的灵活性，但它减少了API实现者可用的灵活性。