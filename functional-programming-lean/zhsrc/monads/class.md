# 梦纳德类型类

不需要为每个是梦纳德的类型导入 `ok` 或 `andThen` 这样的操作符，Lean 标准库提供了一个类型类，可以使它们进行重载，从而可以对**任何**梦纳德使用相同的操作符。
梦纳德具有两个操作，相当于 `ok` 和 `andThen`：

```lean
{{#example_decl Examples/Monads/Class.lean FakeMonad}}
```

这个定义稍微简化了一点。
在 Lean 库中的实际定义会稍微复杂一些，并且将在后面介绍。

`Option` 和 `Except` 的 `Monad` 实例可以通过调整它们各自的 `andThen` 操作的定义来创建：

```lean
{{#example_decl Examples/Monads/Class.lean MonadOptionExcept}}
```

作为一个例子，`firstThirdFifthSeventh` 为 `Option α` 和 `Except String α` 的返回类型分别定义。
现在，它可以为 _任何_ 单子定义多态。
但是，它需要一个查找函数作为参数，因为不同的单子可能会以不同的方式找不到结果。
`bind` 的中缀版本是 `>>=`，在示例中扮演的角色与 `~~>` 相同。

```lean
{{#example_decl Examples/Monads/Class.lean firstThirdFifthSeventhMonad}}
```

给定慢速哺乳动物和快速鸟类的示例列表，`firstThirdFifthSeventh` 的这个实现可以与 `Option` 一起使用：

```scala
def firstThirdFifthSeventh[A](list: List[A]): Option[(A, A, A, A)] = list match {
  case a :: _ :: b :: _ :: c :: _ :: d :: _ => Some((a, b, c, d))
  case _ => None
}

val slowMammals = List("sloth", "anteater", "hippopotamus", "koala", "sloth")

val fastBirds = List("hawk", "eagle", "falcon", "cheetah", "sparrow", "hummingbird")

val slowMammalsResult = firstThirdFifthSeventh(slowMammals)
val fastBirdsResult = firstThirdFifthSeventh(fastBirds)

slowMammalsResult.foreach {
  case (first, third, fifth, seventh) =>
    println(s"First: $first, Third: $third, Fifth: $fifth, Seventh: $seventh")
}

fastBirdsResult.foreach {
  case (first, third, fifth, seventh) => 
    println(s"First: $first, Third: $third, Fifth: $fifth, Seventh: $seventh")
}

```

上述代码演示了 `firstThirdFifthSeventh` 方法的实现。它接受一个列表作为参数，并返回一个 `Option` 类型的元组，其中包含列表中指定位置的四个元素。如果列表中不存在这样的四个元素，则返回 `None`。

使用这个方法，我们可以对给定的慢速哺乳动物和快速鸟类的示例列表进行计算，并打印出相应位置的元素。

```lean
{{#example_decl Examples/Monads/Class.lean animals}}

{{#example_in Examples/Monads/Class.lean noneSlow}}
```



```output info
{{#example_out Examples/Monads/Class.lean noneSlow}}
```



```lean
{{#example_in Examples/Monads/Class.lean someFast}}
```



```output info
{{#example_out Examples/Monads/Class.lean someFast}}
```

将 `Except` 的查找函数 `get` 重命名为更具体的名称后，`firstThirdFifthSeventh` 的实现也可以与 `Except` 一起使用：

```lean
{{#example_decl Examples/Monads/Class.lean getOrExcept}}

{{#example_in Examples/Monads/Class.lean errorSlow}}
```



```output info
{{#example_out Examples/Monads/Class.lean errorSlow}}
```



```lean
{{#example_in Examples/Monads/Class.lean okFast}}
```



```output info
{{#example_out Examples/Monads/Class.lean okFast}}
```

`m` 必须具有 `Monad` 实例的事实意味着 `>>=` 和 `pure` 操作是可用的。

## 通用 Monad 操作

因为许多不同的类型都是 Monad，所以对于任何 Monad 多态的函数非常强大。
例如，函数 `mapM` 是 `map` 的一个版本，它使用 Monad 来顺序和组合应用函数的结果：

```lean
{{#example_decl Examples/Monads/Class.lean mapM}}
```

函数参数 `f` 的返回类型决定了将使用哪个 `Monad` 实例。
换句话说，`mapM` 可以用于产生日志、可能失败或使用可变状态的函数。
由于 `f` 的类型决定了可用的效果，所以可以由 API 设计者进行严格控制。

如 [本章介绍](../monads.md#numbering-tree-nodes) 中所述，`State σ α` 表示利用类型为 `σ` 的可变变量并返回类型为 `α` 的值的程序。
这些程序实际上是从初始状态到值和最终状态的一对值的函数。
`Monad` 类要求其参数期望一个单一的类型参数，也就是说，它应该是一个 `Type → Type`。
这意味着 `State` 的实例应该提及状态类型 `σ`，并将其变为一个参数:

```lean
{{#example_decl Examples/Monads/Class.lean StateMonad}}
```

这意味着在使用`bind`按顺序对`get`和`set`进行调用时，状态的类型不能改变，这对于有状态的计算是一个合理的规则。
运算符`increment`通过给定的数量增加保存的状态，并返回旧值：

```lean
{{#example_decl Examples/Monads/Class.lean increment}}
```

使用 `mapM` 结合 `increment` 会得到一个计算列表中所有元素之和的程序。
具体来说，可变变量包含当前的累加和，而结果列表包含一个逐步求和的结果。
换句话说，`{{#example_in Examples/Monads/Class.lean mapMincrement}}` 的类型是 `{{#example_out Examples/Monads/Class.lean mapMincrement}}`，展开 `State` 的定义后得到 `{{#example_out Examples/Monads/Class.lean mapMincrement2}}`。
它接受一个初始累加和作为参数，应为 `0`：

```lean
{{#example_in Examples/Monads/Class.lean mapMincrementOut}}
```



```output info
{{#example_out Examples/Monads/Class.lean mapMincrementOut}}
```

[logging effect](../monads.md#logging)可以使用`WithLog`来表示。与`State`一样，它的`Monad`实例在日志数据类型上保持多态：

```lean
{{#example_decl Examples/Monads/Class.lean MonadWriter}}
```

`saveIfEven` 是一个函数，它会将偶数打印出来，但返回原始参数：

```javascript
const saveIfEven = (num) => {
  if (num % 2 === 0) {
    console.log(num);
  }
  return num;
};
```

The function `saveIfEven` takes in a parameter `num`. It checks if the number is divisible evenly by 2 (i.e., it is an even number). If so, it logs the number to the console. Regardless of whether the number is even or odd, it returns the original number unchanged.

该函数 `saveIfEven` 接受一个参数 `num`。它检查该数字是否可以被 2 整除（即为偶数）。如果是偶数，它会将数字打印到控制台。无论数字是偶数还是奇数，它都会返回原始数字，不做任何改变。

```lean
{{#example_decl Examples/Monads/Class.lean saveIfEven}}
```

使用`mapM`函数，得到的日志记录将会是偶数和未改变的输入列表成对出现：

```lean
{{#example_in Examples/Monads/Class.lean mapMsaveIfEven}}
```



```output info
{{#example_out Examples/Monads/Class.lean mapMsaveIfEven}}
```

## 单子的标识子

单子将带有副作用的程序，比如失败、异常或日志记录，编码为数据和函数的明确表示形式。
然而，有时一个 API 会被编写成使用单子来提供灵活性，但是 API 的客户端可能不需要任何编码后的效果。
**标识子**是一种没有副作用的单子，它允许纯净代码与单子化的 API 一起使用：

```lean
{{#example_decl Examples/Monads/Class.lean IdMonad}}
```

`pure` 的类型应该是 `α → Id α`，但是 `Id α` 可以简化为 `α`。
同样，`bind` 的类型应该是 `α → (α → Id β) → Id β`。
因为这可以简化为 `α → (α → β) → β`，所以第二个参数可以应用于第一个参数来得到结果。

对于身份单子(Id monad)来说，`mapM` 等价于 `map`。
然而，为了以这种方式调用它，Lean 需要一个提示，告诉它目标单子是 `Id`：

```lean
{{#example_in Examples/Monads/Class.lean mapMId}}
```



```output info
{{#example_out Examples/Monads/Class.lean mapMId}}
```

忽略这个提示会导致错误：

```lean
{{#example_in Examples/Monads/Class.lean mapMIdNoHint}}
```



```output error
{{#example_out Examples/Monads/Class.lean mapMIdNoHint}}
```

在这个错误中，一个元变量对另一个元变量的应用表示 Lean 不能将类型级计算进行反向运行。
函数的返回类型应该是 Monad 应用于某个其他类型。
同样地，使用 `mapM` 与一个类型没有提供任何特定提示关于使用哪个 Monad 的函数会导致一个 "instance problem stuck" 的错误信息。

```lean
{{#example_in Examples/Monads/Class.lean mapMIdId}}
```



```output error
{{#example_out Examples/Monads/Class.lean mapMIdId}}
```

## Monad 的契约

正如每对 `BEq` 和 `Hashable` 的实例都应确保任何两个相等的值具有相同的哈希一样，每个 `Monad` 的实例都应该遵守一项契约。

首先，`pure` 应该是 `bind` 的左单位元。也就是说，`bind (pure v) f` 应该与 `f v` 相同。

其次，`pure` 应该是 `bind` 的右单位元，因此 `bind v pure` 应该与 `v` 相同。

最后，`bind` 应该是结合的，所以 `bind (bind v f) g` 应该与 `bind v (fun x => bind (f x) g)` 相同。

这个契约规定了具有效果的程序的预期性质。由于 `pure` 没有效果，将它的效果与 `bind` 结合在一起不应改变结果。`bind` 的结合属性基本上是说，只要保持事物发生的顺序不变，那么序列的管理本身并不重要。

## 练习

### 对树进行映射

定义一个 `BinTree.mapM` 函数。类似于列表的 `mapM`，这个函数应该对树中的每个数据条目应用一个单子函数，作为一种先序遍历。

类型签名应该是：

```
def BinTree.mapM [Monad m] (f : α → m β) : BinTree α → m (BinTree β)
```

### Option Monad（选项模子）的契约

首先，我们先提出一个有说服力的论据，证明 `Option` 的 `Monad` 实例满足了 monad（模子）契约。
然后，我们考虑下面的实例：

```lean
{{#example_decl Examples/Monads/Class.lean badOptionMonad}}
```

*两种方法都具有正确的类型。*
*为什么这个实例违反了单子契约？*