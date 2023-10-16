# 索引、参数和宇宙级别

索引和参数的区别不仅仅是一种描述归纳类型参数在构造函数间变化与否的方式。
当我们确定它们的宇宙级别之间的关系时，一个归纳类型的参数或索引也很重要。
特别是，一个归纳类型的宇宙级别可能与一个参数相同，但必须在比它的索引所在的宇宙级别更大的宇宙中。
这个限制是为了确保 Lean 可以用作定理证明器以及编程语言，没有这个限制，Lean 的逻辑将是不一致的。
通过试验错误消息可以很好地说明这些规则，以及确定类型的参数是参数还是索引的精确规则。

一般来说，归纳类型的定义在冒号之前给出参数，冒号之后给出索引。
参数像函数参数一样被命名，而索引只描述它们的类型。
这可以在`Vect`的定义中看到：

```lean
{{#example_decl Examples/DependentTypes.lean Vect}}
```

在这个定义中，`α` 是一个参数，`Nat` 是一个索引。
参数可以在整个定义过程中被引用（例如，`Vect.cons` 使用 `α` 作为它的第一个参数的类型），但它们必须始终被一致地使用。
由于索引被认为是会改变的，所以在每个构造函数中为它们分配独立的值，而不是在数据类型定义的顶部提供它们作为参数。

一个非常简单的带有参数的数据类型是 `WithParameter`：

```lean
{{#example_decl Examples/DependentTypes/IndicesParameters.lean WithParameter}}
```

宇宙级别 `u` 可以同时用于参数和归纳类型本身，这说明参数不会增加数据类型的宇宙级别。
类似地，当存在多个参数时，归纳类型将获得较大的宇宙级别：

```lean
{{#example_decl Examples/DependentTypes/IndicesParameters.lean WithTwoParameters}}
```

因为参数不会增加数据类型的宇宙级别，所以使用参数会更加方便。
Lean试图识别类似索引（在冒号后面描述）但在使用时类似参数的参数，并将其转换为参数：
以下两种归纳数据类型都将其参数写在冒号后面：

```lean
{{#example_decl Examples/DependentTypes/IndicesParameters.lean WithParameterAfterColon}}

{{#example_decl Examples/DependentTypes/IndicesParameters.lean WithParameterAfterColon2}}
```

当在初始的数据类型声明中没有给参数命名时，在每个构造函数中可以使用不同的名称，只要它们是一致的。
以下声明是被接受的：

```lean
{{#example_decl Examples/DependentTypes/IndicesParameters.lean WithParameterAfterColonDifferentNames}}
```

然而，这种灵活性不适用于显式声明参数名称的数据类型：

```lean
{{#example_in Examples/DependentTypes/IndicesParameters.lean WithParameterBeforeColonDifferentNames}}
```



```output error
{{#example_out Examples/DependentTypes/IndicesParameters.lean WithParameterBeforeColonDifferentNames}}
```

同样，试图给索引命名会引发一个错误：

```lean
{{#example_in Examples/DependentTypes/IndicesParameters.lean WithNamedIndex}}
```



```output error
{{#example_out Examples/DependentTypes/IndicesParameters.lean WithNamedIndex}}
```

使用一个适当的宇宙级别，在冒号之后放置索引会得到一个可接受的声明：

```lean
{{#example_decl Examples/DependentTypes/IndicesParameters.lean WithIndex}}
```

尽管 Lean 有时可以确定在归纳类型声明中冒号后的参数在所有构造函数中被一致使用，但所有参数仍然必须在所有索引之前。
试图在索引之后放置一个参数会导致该参数被视为一个索引本身，这将需要增加该数据类型的宇宙级别：

```lean
{{#example_in Examples/DependentTypes/IndicesParameters.lean ParamAfterIndex}}
```



```output error
{{#example_out Examples/DependentTypes/IndicesParameters.lean ParamAfterIndex}}
```

参数不必是类型。
下面的例子展示了普通的数据类型（如`Nat`）可以用作参数：

```lean
{{#example_in Examples/DependentTypes/IndicesParameters.lean NatParamFour}}
```



```output error
{{#example_out Examples/DependentTypes/IndicesParameters.lean NatParamFour}}
```

使用建议的 `n` 导致声明被接受：

```lean
{{#example_decl Examples/DependentTypes/IndicesParameters.lean NatParam}}
```

从这些实验中可以得出什么结论呢？
参数和指标的规则如下：
 1. 参数在每个构造函数的类型中必须以相同的方式使用。
 2. 所有参数必须在所有指标之前。
 3. 定义的数据类型的宇宙级别必须至少与最大参数相同，并且严格大于最大指标。
 4. 冒号之前的命名参数始终是参数，而冒号之后的参数通常是指标。如果在所有构造函数中一致使用且没有在任何指标之后出现，Lean 可以确定在冒号之后使用的参数类型为参数。

当有疑问时，可以使用 Lean 命令 `#print` 来检查数据类型的参数数量。
例如，对于 `Vect`，它指出参数的数量为1：

```lean
{{#example_in Examples/DependentTypes/IndicesParameters.lean printVect}}
```



```output info
{{#example_out Examples/DependentTypes/IndicesParameters.lean printVect}}
```

在选择数据类型的参数顺序时，是否将哪些参数和索引应该是一个值得思考的问题。
让尽可能多的参数成为参数有助于控制宇宙级别，这可以使复杂的程序更容易类型检查。
其中一种方法是确保参数列表中的所有参数都出现在索引之前。

此外，尽管 Lean 能够通过使用情况确定冒号后的参数仍然是参数，但最好写出具有明确名称的参数。
这使读者清楚地了解意图，并且如果参数在构造函数中被错误地不一致使用，Lean 会报告错误。