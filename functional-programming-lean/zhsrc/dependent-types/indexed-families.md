# 索引家族

多态归纳类型需要类型参数。例如，`List` 接受一个参数，用于确定列表中条目的类型，`Except` 接受参数，用于确定异常或值的类型。这些类型参数在数据类型的每个构造函数中都是相同的，被称为**参数**。

然而，归纳类型的参数并不必须在每个构造函数中相同。根据构造函数的选择，参数的值可能会有所不同的归纳类型称为**索引家族**，而这些不同的参数被称为**索引**。索引家族的“Hello World”是一种包含列表长度以及条目类型的列表，通常被称为“向量”：

```lean
{{#example_decl Examples/DependentTypes.lean Vect}}
```

函数声明可以在冒号前接受一些参数，表示它们在整个定义中都可用，在冒号后接受一些参数，表示希望对它们进行模式匹配，并逐个定义函数的各种情况。

归纳数据类型有一个类似的原则：参数 `α` 在数据类型声明的顶部命名，位于冒号之前，这表示它是一个参数，在定义中 `Vect` 的所有出现中都必须作为第一个参数提供，而 `Nat` 参数位于冒号之后，表示它是一个可能变动的索引。
实际上，在 `nil` 和 `cons` 构造器的声明中，`Vect` 的三个出现都一致地将 `α` 作为第一个参数提供，而第二个参数在每种情况下都不同。

`nil` 的声明表明它是类型为 `Vect α 0` 的构造器。
这意味着在期望 `Vect String 3` 的上下文中使用 `Vect.nil` 是一个类型错误，就像在期望 `List String` 的上下文中使用 `[1, 2, 3]` 一样是一种类型错误：

```lean
{{#example_in Examples/DependentTypes.lean nilNotLengthThree}}
```



```output error
{{#example_out Examples/DependentTypes.lean nilNotLengthThree}}
```

在这个例子中，`0` 和 `3` 之间的不匹配问题与其他类型不匹配问题的作用完全相同，即使 `0` 和 `3` 本身并不是类型。

索引族被称为类型的“族群”，因为不同的索引值可以使不同的构造函数可用于使用。
从某种意义上讲，索引族不是一种类型；它实际上是一组相关的类型，选择索引值也选择了集合中的一种类型。
选择索引 `5` 作为 `Vect` 的索引意味着只有构造函数 `cons` 可用，而选择索引 `0` 意味着只有 `nil` 可用。

如果索引尚未知道（例如因为它是一个变量），则在索引变为已知之前无法使用任何构造函数。
使用 `n` 作为长度既不能使用 `Vect.nil` 也不能使用 `Vect.cons`，因为无法知道变量 `n` 应该表示与 `0` 或 `n + 1` 匹配的 `Nat` 类型。

```lean
{{#example_in Examples/DependentTypes.lean nilNotLengthN}}
```



```output error
{{#example_out Examples/DependentTypes.lean nilNotLengthN}}
```



```lean
{{#example_in Examples/DependentTypes.lean consNotLengthN}}
```



```output error
{{#example_out Examples/DependentTypes.lean consNotLengthN}}
```

将列表的长度作为类型的一部分意味着类型变得更具信息性。
例如，`Vect.replicate` 是一个创建具有给定值的多个副本的 `Vect` 的函数。
可以精确描述此函数的类型如下：

```lean
{{#example_in Examples/DependentTypes.lean replicateStart}}
```

论证 `n` 是结果的长度。
与下划线占位符相关联的消息描述了手头的任务：

```output error
{{#example_out Examples/DependentTypes.lean replicateStart}}
```

当使用索引族时，只有当 Lean 可以看到构造函数的索引与预期类型中的索引匹配时，才可以应用构造函数。
然而，这两个构造函数都没有一个与 `n` 匹配的索引 —— `nil` 匹配 `Nat.zero`，而 `cons` 匹配 `Nat.succ`。
就像之前的类型错误示例中一样，变量 `n` 可以表示两者中的任意一个，这取决于函数作为参数提供给函数的 `Nat`。
解决方案是使用模式匹配来考虑两种可能的情况：

```lean
{{#example_in Examples/DependentTypes.lean replicateMatchOne}}
```

由于`n`出现在预期类型中，对`n`进行模式匹配将在匹配的两种情况下 _细化_ 预期类型。
在第一个下划线中，预期类型变为`Vect α 0`：

```output error
{{#example_out Examples/DependentTypes.lean replicateMatchOne}}
```

在下划线的第二个部分，它变成了“Vect α(k + 1)”：

```output error
{{#example_out Examples/DependentTypes.lean replicateMatchTwo}}
```

当模式匹配在发现值的结构的同时还细化了程序的类型时，这被称为_依赖模式匹配_。

细化的类型使得能够应用构造函数。
第一个下划线匹配 `Vect.nil`，第二个下划线匹配 `Vect.cons`：

```lean
{{#example_in Examples/DependentTypes.lean replicateMatchFour}}
```

`.cons : (α : Type) → (list : List α) → α → List α`

`.cons` 接受一个类型为 `α` 和一个类型为 `List α` 的参数，并返回一个类型为 `List α` 的结果。

Therefore, in order to apply `.cons`, we need to provide an argument of type `α`.

因此，为了使用 `.cons`，我们需要提供一个类型为 `α` 的参数。

In this case, we have an `α` available, namely `x`. Therefore, we can apply `.cons` with arguments `(α := α) (list := list)` and `x`:

在这种情况下，我们有一个可用的 `α`，即 `x`。因此，我们可以使用 `(α := α) (list := list)` 和 `x` 作为参数来调用 `.cons`：

`.cons α list x`

This will give us a list with `x` as its head and `list` as its tail, satisfying the type signature of `.cons`.

这将给我们一个以 `x` 为头部，`list` 为尾部的列表，符合 `.cons` 的类型签名。

Therefore, the first underscore under the `.cons` is of type `α` and `x` can be used as the value for it.

因此，`.cons` 下面的第一个下划线的类型为 `α`，可以将 `x` 用作它的值。

```output error
{{#example_out Examples/DependentTypes.lean replicateMatchFour}}
```

第二个下划线应该是一个 `Vect α k`，可以通过对 `replicate` 的递归调用来生成：

```output error
{{#example_out Examples/DependentTypes.lean replicateMatchFive}}
```

以下是“复制”（`replicate`）的最终定义：

```lean
def replicate {α : Type u} : ℕ → α → list α
| 0       x := []
| (n + 1) x := x :: (replicate n x)
```

该定义表示，`replicate` 是一个函数，它接受一个类型为 `α` 的参数和一个自然数 `n`，以及一个类型为 `α` 的值 `x`。该函数的返回值是一个列表，其中包含 `n` 个值 `x`。

这个函数定义使用了递归方式来生成列表。当 `n` 为 0 时，返回一个空列表。当 `n` 大于 0 时，将值 `x` 加入到递归调用 `replicate n x` 的结果前面，这样就生成了一个包含 `n` 个 `x` 的列表。

这个 `replicate` 函数可以用来复制一个值多次，生成包含多个相同值的列表。

```lean
{{#example_decl Examples/DependentTypes.lean replicate}}
```

除了在编写函数时提供帮助外，`Vect.replicate` 的信息类型还允许客户端代码排除许多意外函数，而无需阅读源代码。
用于列表的`replicate`版本可能产生错误长度的列表：

```lean
{{#example_decl Examples/DependentTypes.lean listReplicate}}
```

然而，对于 `Vect.replicate` 这个函数来说，犯这个错误是一种类型错误：

```lean
{{#example_in Examples/DependentTypes.lean replicateOops}}
```



```output error
{{#example_out Examples/DependentTypes.lean replicateOops}}
```

函数 `List.zip` 通过将第一个列表的第一项与第二个列表的第一项配对，将第一个列表的第二项与第二个列表的第二项配对，依此类推，将两个列表合并。`List.zip` 可以用来将美国俄勒冈州的三个最高峰与丹麦的三个最高峰进行配对：

```lean
{{#example_in Examples/DependentTypes.lean zip1}}
```

结果是一个包含三个对的列表：

1. **Pair 1:** The first pair in the list.
2. **Pair 2:** The second pair in the list.
3. **Pair 3:** The third pair in the list.

Each pair consists of two elements.

```lean
{{#example_out Examples/DependentTypes.lean zip1}}
```

当两个列表的长度不同时，应该怎样处理有些不太清楚。
像许多编程语言一样，Lean 选择忽略其中一个列表中的额外条目。
例如，将俄勒冈州的五座最高峰与丹麦的三座最高峰的海拔高度进行组合，得到三对。
特别地，

```lean
{{#example_in Examples/DependentTypes.lean zip2}}
```

求值为

```lean
{{#example_out Examples/DependentTypes.lean zip2}}
```

虽然这种方法很方便，因为它总是返回一个答案，但当列表意外地具有不同的长度时，它会丢弃数据。
F# 采用了不同的方法：它的 `List.zip` 在长度不匹配时会抛出异常，可以在以下 `fsi` 会话中看到：

```fsharp
> List.zip [3428.8; 3201.0; 3158.5; 3075.0; 3064.0] [170.86; 170.77; 170.35];;
```



```output error
System.ArgumentException: The lists had different lengths.
list2 is 2 elements shorter than list1 (Parameter 'list2')
   at Microsoft.FSharp.Core.DetailedExceptions.invalidArgDifferentListLength[?](String arg1, String arg2, Int32 diff) in /builddir/build/BUILD/dotnet-v3.1.424-SDK/src/fsharp.3ef6f0b514198c0bfa6c2c09fefe41a740b024d5/src/fsharp/FSharp.Core/local.fs:line 24
   at Microsoft.FSharp.Primitives.Basics.List.zipToFreshConsTail[a,b](FSharpList`1 cons, FSharpList`1 xs1, FSharpList`1 xs2) in /builddir/build/BUILD/dotnet-v3.1.424-SDK/src/fsharp.3ef6f0b514198c0bfa6c2c09fefe41a740b024d5/src/fsharp/FSharp.Core/local.fs:line 918
   at Microsoft.FSharp.Primitives.Basics.List.zip[T1,T2](FSharpList`1 xs1, FSharpList`1 xs2) in /builddir/build/BUILD/dotnet-v3.1.424-SDK/src/fsharp.3ef6f0b514198c0bfa6c2c09fefe41a740b024d5/src/fsharp/FSharp.Core/local.fs:line 929
   at Microsoft.FSharp.Collections.ListModule.Zip[T1,T2](FSharpList`1 list1, FSharpList`1 list2) in /builddir/build/BUILD/dotnet-v3.1.424-SDK/src/fsharp.3ef6f0b514198c0bfa6c2c09fefe41a740b024d5/src/fsharp/FSharp.Core/list.fs:line 466
   at <StartupCode$FSI_0006>.$FSI_0006.main@()
Stopped due to error
```

这样就避免了意外丢失信息的问题，但是程序崩溃也会带来其它的困难。
Lean 等价的方式，可以使用 `Option` 或者 `Except` monads，但是这样会引入一些负担，可能并不值得为了安全而付出。

然而，使用 `Vect`，可以编写一个要求两个参数具有相同长度的类型的 `zip` 版本：

```lean
{{#example_decl Examples/DependentTypes.lean VectZip}}
```

这个定义只有在两个参数都是 `Vect.nil` 或者两个参数都是 `Vect.cons` 的情况下才有模式，而且 Lean 接受该定义而不会出现类似于对 `List` 进行类似定义时出现的 "缺少情况" 错误：

```lean
{{#example_in Examples/DependentTypes.lean zipMissing}}
```



```output error
{{#example_out Examples/DependentTypes.lean zipMissing}}
```

这是因为第一个模式中使用的构造函数 `nil` 或 `cons` _精化_了类型检查器对长度 `n` 的知识。
当第一个模式为 `nil` 时，类型检查器还可以确定长度为 `0`，因此第二个模式的唯一可能选择就是 `nil`。
同样地，当第一个模式为 `cons` 时，类型检查器可以确定长度为某个 `Nat` 类型的 `k+1`，因此第二个模式的唯一可能选择就是 `cons`。
的确，添加一个同时使用 `nil` 和 `cons` 的案例是一个类型错误，因为长度不匹配：

```lean
{{#example_in Examples/DependentTypes.lean zipExtraCons}}
```



```output error
{{#example_out Examples/DependentTypes.lean zipExtraCons}}
```

通过将 `n` 变成一个显式参数，可以观察到长度的细化。

```lean
{{#example_decl Examples/DependentTypes.lean VectZipLen}}
```

## 练习

对于使用依赖类型编程的感觉需要经验，本节中的练习非常重要。
对于每个练习，请尝试通过实验来看看类型检查器可以捕捉到什么错误，以及不能捕捉到什么错误。
这也是培养对错误消息的感觉的好方法。

* 再次检查 `Vect.zip` 在将俄勒冈州的三个最高峰与丹麦的三个最高峰合并时是否给出了正确的答案。
  由于 `Vect` 没有 `List` 那种语法糖，所以定义 `oregonianPeaks : Vect String 3` 和 `danishPeaks : Vect String 3` 可以很有帮助。

* 定义一个具有类型 `(α → β) → Vect α n → Vect β n` 的函数 `Vect.map`。

* 定义一个函数 `Vect.zipWith`，它可以一次将 `Vect` 中的条目与一个函数结合起来。
  它的类型应为 `(α → β → γ) → Vect α n → Vect β n → Vect γ n`。

* 定义一个函数 `Vect.unzip`，它将一组成对的 `Vect` 拆分为一对 `Vect`。它的类型应为 `Vect (α × β) n → Vect α n × Vect β n`。

* 定义一个函数 `Vect.snoc`，它将一个条目添加到 `Vect` 的*末尾*。它的类型应为 `Vect α n → α → Vect α (n + 1)`，并且 `{{#example_in Examples/DependentTypes.lean snocSnowy}}` 应返回 `{{#example_out Examples/DependentTypes.lean snocSnowy}}`。`snoc` 是一个传统的函数式编程双关语：它代表了 `cons` 的逆。
 
* 定义一个函数 `Vect.reverse`，用于颠倒一个 `Vect` 的顺序。
 
* 定义具有以下类型的函数 `Vect.drop`：`(n : Nat) → Vect α (k + n) → Vect α k`。
  验证它的正确性，通过检查 `{{#example_in Examples/DependentTypes.lean ejerBavnehoej}}` 返回的结果是否为 `{{#example_out Examples/DependentTypes.lean ejerBavnehoej}}`。

* 定义一个函数 `Vect.take`，具有类型 `(n : Nat) → Vect α (k + n) → Vect α n`，返回 `Vect` 中的前 `n` 个条目。检查它在一个例子上的工作是否正常。