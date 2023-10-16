# 数组和终止

为了编写高效的代码，选择合适的数据结构非常重要。
链表也有其用处：在某些应用中，共享链表尾部的能力非常重要。
然而，在大多数可变长度的顺序数据的使用场景中，数组更适合使用，因为它们具有更少的内存开销和更好的局部性。

然而，相对于链表，数组有两个缺点：
1. 数组通过索引访问，而不是通过模式匹配访问，这需要我们遵循一些[证明义务](../props-proofs-indexing.md)以保证安全性。
2. 处理整个数组的循环是一个尾递归函数，但它没有在每个调用中减少的参数。

要有效使用数组，需要知道如何向 Lean 证明数组索引在界限内，并且如何证明接近数组大小的数组索引也会导致程序终止。
这两个问题都是使用不等号命题表示的，而不是命题等价关系。

## 不等式

因为不同的类型有不同的排序方式，所以不等式由两个被称为 `LE` 和 `LT` 的类型类定义。
在[标准类型类](../type-classes/standard-classes.md#equality-and-ordering)一节中的表格描述了这些类与语法的关系：

| 表达式 | 换码 | 类名 |
|--------|------|------|
| `{{#example_in Examples/Classes.lean ltDesugar}}` | `{{#example_out Examples/Classes.lean ltDesugar}}` | `LT` |
| `{{#example_in Examples/Classes.lean leDesugar}}` | `{{#example_out Examples/Classes.lean leDesugar}}` | `LE` |
| `{{#example_in Examples/Classes.lean gtDesugar}}` | `{{#example_out Examples/Classes.lean gtDesugar}}` | `LT` |
| `{{#example_in Examples/Classes.lean geDesugar}}` | `{{#example_out Examples/Classes.lean geDesugar}}` | `LE` |

换句话说，一个类型可以自定义 `<` 和 `≤` 运算符的含义，而 `>` 和 `≥` 运算符的含义则由 `<` 和 `≤` 决定。
`LT` 和 `LE` 类有返回命题而不是 `Bool` 的方法：

```lean
{{#example_decl Examples/ProgramsProofs/Arrays.lean less}}
```

`Nat`类型对于`LE`的实例将委托给`Nat.le`：

```lean
namespace LE

def le := sorry

instance : LE Nat :=
{ le := le }

end LE
```

在上面的代码片段中，我们定义了一个名为`LE`的命名空间，并在其中声明了一个名为`le`的未定义函数。然后，我们声明了一个名为`LE Nat`的实例，并将其`le`字段`le`的值设置为刚刚定义的`le`函数。在这种情况下，`Nat`类型的`LE`实例会将其`le`字段委托给`Nat.le`函数。

请注意，`sorry`关键字表示我们在这里省略了具体的实现细节。真实的代码将根据具体的需求来提供具体的`le`定义。

```lean
{{#example_decl Examples/ProgramsProofs/Arrays.lean LENat}}
```

定义 `Nat.le` 需要 Lean 的一个尚未介绍的功能：这是一个归纳定义的关系。

### 归纳定义的命题、谓词和关系

`Nat.le` 是一个归纳定义的关系。
就像 `inductive` 可以用来创建新的数据类型一样，它也可以用来创建新的命题。
当一个命题接受一个参数时，它被称为一个可能为某些但不是所有潜在参数成立的 _谓词_。
接受多个参数的命题被称为 _关系_。

归纳定义命题的每个构造器都是一种证明它的方式。
换句话说，命题的声明描述了它为真的不同证明形式。
一个没有参数而只有一个构造器的命题可能很容易证明：

```lean
{{#example_decl Examples/ProgramsProofs/Arrays.lean EasyToProve}}
```

证明有四个步骤，首先是通过推导和逻辑推理来证明引理和定理。其次是用例子来说明定理的正确性。第三个步骤是展示已证明的定理是最小化的。最后一步是通过测量其它证明的尺寸来比较和验证定理的优势。

```lean
{{#example_decl Examples/ProgramsProofs/Arrays.lean fairlyEasy}}
```

事实上，命题 `True`，它应该总是很容易证明的，就像 `EasyToProve` 一样进行定义：

```lean
{{#example_decl Examples/ProgramsProofs/Arrays.lean True}}
```

归纳定义的不带参数的命题并不像归纳定义的数据类型那样有趣。
这是因为数据本身就很有趣 —— 自然数 `3` 不同于数 `35`，如果有人订了 3 个披萨，等到半小时后送来 35 个，他们会非常不高兴。
命题的构造子描述了命题为真的方式，但是一旦一个命题被证明了，就不需要再知道是 _哪些_ 构造子被使用了。
这就是为什么 `Prop` 类型空间中最有趣的归纳定义的类型都带有参数。

归纳定义的谓词 `IsThree` 说明它的参数是三：

```lean
{{#example_decl Examples/ProgramsProofs/Arrays.lean IsThree}}
```

这里使用的机制与索引族（如 `HasCol`）类似，只是产生的类型是可以被证明的命题，而不是可以被使用的数据。

使用这个谓词，可以证明三确实是三：

```lean
{{#example_decl Examples/ProgramsProofs/Arrays.lean threeIsThree}}
```

同样地，`IsFive` 是一个断言，它断言它的参数是 `5`：

```lean
{{#example_decl Examples/ProgramsProofs/Arrays.lean IsFive}}
```

如果一个数是三，那么把它加上两个数的结果应该是五。
这可以用一个定理来表达：

**定理：** 如果 x 是三，则 x 加上两个等于五。

**证明：** 

假设 x 是三，我们可以根据这个假设来推导。

根据加法的定义，把 x 加上两个数的结果可以表示为 x + 2。

根据我们的假设，x 是三，所以 x + 2 可以表示为 3 + 2。

根据加法的定义，3 + 2 等于 5。

因此，根据我们的假设和定义，我们可以得出结论，如果 x 是三，则 x 加上两个数的结果是五。

这样，我们证明了定理的正确性。

```leantac
{{#example_in Examples/ProgramsProofs/Arrays.lean threePlusTwoFive0}}
```

*证明 LEAN 定理*

Lean 定理是一种在计算机科学和数学领域中常用的证明工具。它基于依赖类型理论，可以用来构建严格、形式化的证明，并被广泛应用于形式验证和程序验证领域。

在 Lean 定理中，一个证明被定义为一个对象，它可以被类型推断和检查。这样的对象称为证明项，或简称证明。一个证明项有一个类型，该类型描述了证明的结论。

证明的目标通常具有函数类型。函数类型表示一个映射关系，将输入值映射到输出值。在证明中，目标函数类型描述了所要证明的命题或结论。为了完成证明，我们需要构造一个类型为目标函数类型的证明项。

构建证明的过程通常包括定义，并应用一系列的引理和定理，以逐步推导出目标的函数类型。在 Lean 中，我们可以使用不同的策略来完成证明，如直接证明、归纳证明、反证证明等。

完成证明后，我们可以使用 Lean 的类型检查器来验证证明项是否满足目标函数类型。如果通过验证，我们就可以得到一个形式化的、基于 Lean 的证明。

总结而言，Lean 定理提供了一种形式化证明的方法，可以在计算机科学和数学领域中应用。它的目标类型描述了证明的结论，并通过构建证明项来完成证明。使用 Lean 的类型检查器，可以验证证明的正确性。通过使用 Lean 定理，我们可以更严谨、可靠地进行证明，从而提高问题的解决效率和可信度。

```output error
{{#example_out Examples/ProgramsProofs/Arrays.lean threePlusTwoFive0}}
```

因此，`intro`策略可以用来将论证转化为假设：

```leantac
{{#example_in Examples/ProgramsProofs/Arrays.lean threePlusTwoFive1}}
```



```output error
{{#example_out Examples/ProgramsProofs/Arrays.lean threePlusTwoFive1}}
```

在假设 `n` 为三的前提下，可以使用 `IsFive` 的构造函数来完成证明：

```leantac
{{#example_in Examples/ProgramsProofs/Arrays.lean threePlusTwoFive1a}}
```

然而，这会导致一个错误：

```output error
{{#example_out Examples/ProgramsProofs/Arrays.lean threePlusTwoFive1a}}
```

这个错误发生是因为 `n + 2` 不等于 `5`。
在普通的函数定义中，可以在假设 `three` 上使用依赖模式匹配来将 `n` 精化为 `3`。
依赖模式匹配的策略等价物是 `cases`，其语法与 `induction` 相似：

```leantac
{{#example_in Examples/ProgramsProofs/Arrays.lean threePlusTwoFive2}}
```

在剩下的情况下，`n`已经被推导为 `3`：

```output error
{{#example_out Examples/ProgramsProofs/Arrays.lean threePlusTwoFive2}}
```

因为 `3 + 2` 在定义上等于 `5`，所以现在构造函数是可适用的：

```leantac
{{#example_decl Examples/ProgramsProofs/Arrays.lean threePlusTwoFive3}}
```

标准的错误命题 `False` 没有构造函数，因此不可能提供直接证据。
提供 `False` 的证据的唯一方法是假设本身是不可能的，类似于如何使用 `nomatch` 标记类型系统可以识别到不可达代码。
如 [关于证明的初步交替](../props-proofs-indexing.md#connectives) 中所述，否定 `Not A` 是 `A → False` 的简写形式。
`Not A` 也可以写作 `¬A`。

四不等于三。

```leantac
{{#example_in Examples/ProgramsProofs/Arrays.lean fourNotThree0}}
```

初始证明目标中包含 `Not`：

```output error
{{#example_out Examples/ProgramsProofs/Arrays.lean fourNotThree0}}
```

使用 `simp` 可以暴露出它实际上是一个函数类型的事实：

```lean
example : 0 < 1 :=
begin
  simp,
  -- goal is now `0 < 1`
  exact zero_lt_one
end
```

在这个例子中，我们使用 `simp` 来简化目标。在应用 `simp` 规则之后，目标变为了 `0 < 1`。我们可以使用 `exact zero_lt_one` 来证明这个目标，因为这是一个已知的不等式。

```leantac
{{#example_in Examples/ProgramsProofs/Arrays.lean fourNotThree1}}
```



```output error
{{#example_out Examples/ProgramsProofs/Arrays.lean fourNotThree1}}
```

由于目标是一个函数类型，`intro` 可以将参数转化为假设。
无需保留 `simp`，因为 `intro` 可以展开 `Not` 的定义本身：

```leantac
{{#example_in Examples/ProgramsProofs/Arrays.lean fourNotThree2}}
```



```output error
{{#example_out Examples/ProgramsProofs/Arrays.lean fourNotThree2}}
```

在这个证明中，`cases`策略可以立即解决目标：

```leantac
{{#example_decl Examples/ProgramsProofs/Arrays.lean fourNotThreeDone}}
```

正如对 `Vect String 2` 进行模式匹配时不需要包含 `Vect.nil` 的情况一样，对 `IsThree 4` 进行案例分析时也不需要包含 `isThree` 的情况。

### 自然数的不等式

`Nat.le` 的定义有一个参数和一个索引：

```lean
{{#example_decl Examples/ProgramsProofs/Arrays.lean NatLe}}
```

参数 `n` 是应该更小的数，而索引是应该大于等于 `n` 的数。
当两个数相等时，使用 `refl` 构造函数，而当索引大于 `n` 时，使用 `step` 构造函数。

从证明的角度看，对于 \\( n \leq k \\) 的证明就是找到一个数 \\( d \\)，使得 \\( n + d = m \\)。
在 Lean 中，证明由一个 `Nat.le.refl` 构造函数和 \\( d \\) 个 `Nat.le.step` 实例组成。
每个 `step` 构造函数将其索引参数加一，因此 \\( d \\) 个 `step` 构造函数将较大的数增加了 \\( d \\)。
例如，证明四小于等于七的证据由三个围绕着 `refl` 的 `step` 构成：

```lean
{{#example_decl Examples/ProgramsProofs/Arrays.lean four_le_seven}}
```

严格小于关系通过在左侧的数字上加一来定义：

```lean
{{#example_decl Examples/ProgramsProofs/Arrays.lean NatLt}}
```

证明四小于七的证据包括两个步骤“step”和一个“refl”：

```lean
{{#example_decl Examples/ProgramsProofs/Arrays.lean four_lt_seven}}
```

这是因为 `4 < 7` 等价于 `5 ≤ 7`。

## 证明终止性

函数 `Array.map` 使用一个函数来转换数组，返回一个包含将该函数应用于输入数组的每个元素结果的新数组。
将它写成一个尾递归函数遵循了传递输出数组给委托函数的常规模式。
累加器初始化为空数组。
累加器传递的辅助函数还接受一个参数，用于跟踪当前在数组中的索引，其初始值为 `0`：

```lean
{{#example_decl Examples/ProgramsProofs/Arrays.lean ArrayMap}}
```

助手应该在每次迭代中检查索引是否仍在范围内。
如果是，则应该再次循环，将转换后的元素添加到累加器的末尾，并将索引增加1。
如果不是，则应该终止并返回累加器。
该代码的初始实现失败，因为 Lean 无法证明数组索引是有效的：

```lean
{{#example_in Examples/ProgramsProofs/Arrays.lean mapHelperIndexIssue}}
```



```output error
{{#example_out Examples/ProgramsProofs/Arrays.lean mapHelperIndexIssue}}
```

然而，条件表达式已经检查了数组索引有效性所要求的准确条件（即 `i < arr.size`）。
给 `if` 添加一个名称可以解决这个问题，因为它为数组索引策略添加了一个假设：

```lean
{{#example_in Examples/ProgramsProofs/Arrays.lean arrayMapHelperTermIssue}}
```

然而，Lean 不接受这个修改后的程序，因为递归调用没有在任何一个输入构造函数的参数上进行。
事实上，累加器和索引都在增长，而不是缩小：

```output error
{{#example_out Examples/ProgramsProofs/Arrays.lean arrayMapHelperTermIssue}}
```

然而，这个函数是可以终止的，因此仅仅标记它为 `partial` 是不合适的。

`arrayMapHelper` 为什么会终止呢？
每次迭代都会检查索引 `i` 是否仍在数组 `arr` 的范围内。
如果是，则将 `i` 增加并重复循环。
如果不是，则程序终止。
因为 `arr.size` 是一个有限的数字，所以 `i` 只能增加有限次数。
即使在每次调用中没有参数减少，`arr.size - i` 会减少到接近零的值。

Lean 可以通过在定义的末尾提供 `termination_by` 子句来指示使用另一个表达式来进行终止。
`termination_by` 子句有两个部分：函数参数的名称和一个使用这些名称的表达式，在每次调用中都应减小。
对于 `arrayMapHelper`，最终的定义如下：

```lean
{{#example_decl Examples/ProgramsProofs/Arrays.lean ArrayMapHelperOk}}
```

一个类似的终止证明可以用来编写 `Array.find` 函数，该函数用于在数组中找到满足布尔函数的第一个元素，并返回该元素及其索引：

```lean
{{#example_decl Examples/ProgramsProofs/Arrays.lean ArrayFind}}
```

再次强调，辅助函数之所以终止，是因为 `arr.size - i` 会随着 `i` 的增加而减少：

```lean
{{#example_decl Examples/ProgramsProofs/Arrays.lean ArrayFindHelper}}
```

并非所有的终止论证都像这个一样简单。
然而，基本的结构是在所有的终止证明中，基于函数的参数识别出某个表达式，在每次调用中它都会减少。
有时候，需要创造力来找出函数终止的原因，而且有时候Lean要求额外的证明才能接受终止论证。

## 练习

* 使用一个尾递归的累加传递函数和一个 `termination_by` 从句，实现一个对数组（Array α）的 `ForM` 实例。
* 使用一个不需要 `termination_by` 从句的尾递归累加传递函数，实现一个逆转数组的函数。
* 使用 `for ... in ...` 循环在身份单子中重新实现 `Array.map`、`Array.find` 和 `ForM` 实例，并比较得到的代码。
* 使用身份单子中的 `for ... in ...` 循环重新实现数组逆转。将其与尾递归函数进行比较。