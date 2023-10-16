# 标准类

本节介绍了在Lean中可以使用类型类重载的各种运算符和函数。
每个运算符或函数对应一个类型类的方法。
与C++不同，Lean中的中缀运算符被定义为具名函数的缩写形式；这意味着为新类型重载它们不是直接使用运算符本身，而是使用底层名称（例如`HAdd.hAdd`）。

## 算术运算符

大多数算术运算符都以异构形式存在，其中参数可能具有不同的类型，输出参数确定结果表达式的类型。
对于每个异构运算符，都有对应的同构版本，可以通过删除字母`h`获得，因此`HAdd.hAdd`变为`Add.add`。
以下算术运算符被重载：

| 表达式 | 解糖 | 类名 |
|------------|------------|------------|
| `{{#example_in Examples/Classes.lean plusDesugar}}` | `{{#example_out Examples/Classes.lean plusDesugar}}` | `HAdd` |
| `{{#example_in Examples/Classes.lean minusDesugar}}` | `{{#example_out Examples/Classes.lean minusDesugar}}` | `HSub` |
| `{{#example_in Examples/Classes.lean timesDesugar}}` | `{{#example_out Examples/Classes.lean timesDesugar}}` | `HMul` |
| `{{#example_in Examples/Classes.lean divDesugar}}` | `{{#example_out Examples/Classes.lean divDesugar}}` | `HDiv` |
| `{{#example_in Examples/Classes.lean modDesugar}}` | `{{#example_out Examples/Classes.lean modDesugar}}` | `HMod` |
| `{{#example_in Examples/Classes.lean powDesugar}}` | `{{#example_out Examples/Classes.lean powDesugar}}` | `HPow` |
| `{{#example_in Examples/Classes.lean negDesugar}}` | `{{#example_out Examples/Classes.lean negDesugar}}` | `Neg` |

## 位运算符

Lean包含了一些使用类型类重载的标准位运算符。
对于固定宽度类型，如 `{{#example_in Examples/Classes.lean UInt8}}`、`{{#example_in Examples/Classes.lean UInt16}}`、`{{#example_in Examples/Classes.lean UInt32}}`、`{{#example_in Examples/Classes.lean UInt64}}` 和 `{{#example_in Examples/Classes.lean USize}}`，都有相应的实例。
后者表示当前平台上的字大小，通常为32位或64位。
以下位运算符被重载：

| 表达式 | 描述 | 类名 |
|------------|------------|------------|
| `{{#example_in Examples/Classes.lean bAndDesugar}}` | `{{#example_out Examples/Classes.lean bAndDesugar}}` | `HAnd` |
| <code class="hljs">x &#x7c;&#x7c;&#x7c; y </code> | `{{#example_out Examples/Classes.lean bOrDesugar}}` | `HOr` |
| `{{#example_in Examples/Classes.lean bXorDesugar}}` | `{{#example_out Examples/Classes.lean bXorDesugar}}` | `HXor` |
| `{{#example_in Examples/Classes.lean complementDesugar}}` | `{{#example_out Examples/Classes.lean complementDesugar}}` | `Complement` |
| `{{#example_in Examples/Classes.lean shrDesugar}}` | `{{#example_out Examples/Classes.lean shrDesugar}}` | `HShiftRight` |
| `{{#example_in Examples/Classes.lean shlDesugar}}` | `{{#example_out Examples/Classes.lean shlDesugar}}` | `HShiftLeft` |

由于 `And` 和 `Or` 的名称已经被用作逻辑连接词的名称，`HAnd` 和 `HOr` 的同构版本被称为 `AndOp` 和 `OrOp`，而不是 `And` 和 `Or`。

## 等式和排序

测试两个值的相等性通常使用 `BEq` 类，它是 "布尔相等" 的缩写。
由于 Lean 用作定理证明器，Lean 中实际上有两种类型的等式运算符：
 * _布尔相等_ 是在其他编程语言中找到的相同类型的相等性。它是一个接受两个值并返回 `Bool` 的函数。布尔相等使用两个等号表示，就像在 Python 和 C# 中一样。由于 Lean 是纯函数式语言，没有引用和值相等性的分离概念——不能直接观察指针。
 * _命题相等_ 是两个事物相等的数学陈述。命题相等不是一个函数，而是一个可以证明的数学陈述。它用单个等号表示。命题相等的陈述类似于一个分类证明这个相等性的证据的类型。
两种等式概念都很重要，并且用于不同的目的。
布尔等式在程序中很有用，当需要决定两个值是否相等时使用。
例如，`{{#example_in Examples/Classes.lean boolEqTrue}}` 的结果为 `{{#example_out Examples/Classes.lean boolEqTrue}}`，而 `{{#example_in Examples/Classes.lean boolEqFalse}}` 的结果为 `{{#example_out Examples/Classes.lean boolEqFalse}}`。
某些值，如函数，无法检查相等性。
例如，`{{#example_in Examples/Classes.lean functionEq}}` 会导致错误：

```output error
{{#example_out Examples/Classes.lean functionEq}}
```

正如本消息所示，`==` 使用类型类进行了重载。
表达式 `{{#example_in Examples/Classes.lean beqDesugar}}` 实际上是 `{{#example_out Examples/Classes.lean beqDesugar}}` 的简写。

命题等式是一个数学陈述，而不是一个程序的调用。
因为命题类似于描述某个陈述的证据的类型，命题等式更类似于 `String` 和 `Nat → List Int` 这样的类型，而不是布尔等式。
这意味着它不能自动检查。
然而，只要两个表达式具有相同的类型，它们的相等性可以在 Lean 中陈述。
`{{#example_in Examples/Classes.lean functionEqProp}}` 是一个非常合理的陈述。
从数学的角度来看，如果两个函数将相等的输入映射到相等的输出，则它们是相等的，所以这个陈述甚至是正确的，尽管需要两行证明才能让 Lean 相信这个事实。

一般来说，在使用 Lean 作为编程语言时，最好使用布尔函数而不是命题。
然而，`Bool` 的构造函数的名称 `true` 和 `false` 表明这种区别有时是模糊的。
一些命题是可判定的，这意味着它们可以像布尔函数一样进行检查。
检查命题真假的函数称为决策过程，它返回命题真假的证据。
一些可判定的命题的例子包括自然数的相等和不等、字符串的相等以及可判定的命题的 "与" 和 "或"。

在 Lean 中，`if` 语句与可判定的命题一起使用。
例如，`2 < 4` 是一个命题：

```lean
{{#example_in Examples/Classes.lean twoLessFour}}
```



```output info
{{#example_out Examples/Classes.lean twoLessFour}}
```

然而，将其作为“if”条件进行编写是完全可以接受的。
例如，`{{#example_in Examples/Classes.lean ifProp}}`的类型是`Nat`，并且求值为`{{#example_out Examples/Classes.lean ifProp}}`。


并非所有命题都是可判定的。
如果是的话，那么计算机只需运行判定过程即可证明任何真命题，数学家也将失业。
更具体地说，可判定命题具有“Decidable”类型类的实例，该类型类具有一个判定过程的方法。
尝试将不可判定的命题当作`Bool`使用会导致无法找到`Decidable`实例的失败。
例如，`{{#example_in Examples/Classes.lean funEqDec}}`的结果是：

```output error
{{#example_out Examples/Classes.lean funEqDec}}
```

下面的命题通常是可判定的，它们都有类型类重载：

| 表达式 | 处理方式 | 类名 |
|--------|----------|------|
| `{{#example_in Examples/Classes.lean ltDesugar}}` | `{{#example_out Examples/Classes.lean ltDesugar}}` | `LT` |
| `{{#example_in Examples/Classes.lean leDesugar}}` | `{{#example_out Examples/Classes.lean leDesugar}}` | `LE` |
| `{{#example_in Examples/Classes.lean gtDesugar}}` | `{{#example_out Examples/Classes.lean gtDesugar}}` | `LT` |
| `{{#example_in Examples/Classes.lean geDesugar}}` | `{{#example_out Examples/Classes.lean geDesugar}}` | `LE` |

因为新命题的定义尚未被证明，因此可能难以定义 `LT` 和 `LE` 的新实例。

此外，使用 `<`、`==` 和 `>` 比较值可能效率低下。
先检查一个值是否小于另一个值，然后再检查它们是否相等，可能需要对大型数据结构进行两次遍历。
为了解决这个问题，Java 和 C# 中提供了标准的 `compareTo` 和 `CompareTo` 方法，可以通过覆盖一个类来同时实现这三个操作。
这些方法返回一个负整数，如果接收者小于参数；返回零，如果它们相等；返回一个正整数，如果接收者大于参数。
与重载整数的含义不同，Lean 使用了一个内置的归纳类型，描述了这三种可能性：

```lean
{{#example_decl Examples/Classes.lean Ordering}}
```

`Ord` 类型类可以被重载来实现这些比较操作。
对于 `Pos` 类型，可以有以下实现：

```lean
{{#example_decl Examples/Classes.lean OrdPos}}
```

在Java中，当需要使用`compareTo`时，可以在Lean中使用`Ord.compare`。

##哈希算法

Java和C＃分别具有`hashCode`和`GetHashCode`方法，用于计算值的哈希值，并用于数据结构，如哈希表。
在Lean中，相应的是一个称为`Hashable`的类型类：

```lean
{{#example_decl Examples/Classes.lean Hashable}}
```

如果根据类型的`BEq`实例，两个值被视为相等，那么它们应该具有相同的哈希值。
换句话说，如果 `x == y` 那么 `hash x == hash y`。
如果 `x ≠ y`，那么 `hash x` 不必与 `hash y` 不同（毕竟，`Nat` 值比 `UInt64` 值无限多），但是基于哈希构建的数据结构在不相等的值可能具有不相等的哈希值时性能更好。
这与 Java 和 C# 中的期望一样。

标准库中包含一个名为 `mixHash` 的函数，其类型为 `Nat → Nat → Nat`，可用于组合构造函数的不同字段的哈希值。
可以通过为每个构造函数分配唯一的数值，然后将该数值与每个字段的哈希值混合来编写一个合理的哈希函数，用于递归数据类型。
例如，可以编写一个 `Pos` 的`Hashable` 实例：

```lean
{{#example_decl Examples/Classes.lean HashablePos}}
```

对于多态类型，可以利用递归实例搜索来实现 `Hashable` 实例。
只有当 `α` 可以哈希时，才能对非空列表 `NonEmptyList α` 哈希化：

```lean
{{#example_decl Examples/Classes.lean HashableNonEmptyList}}
```

二叉树在 `BEq` 和 `Hashable` 的实现中使用了递归和递归实例搜索。

## BEq

在 `BEq` 的实现中，我们通过递归比较二叉树的两个节点是否相等。首先，我们比较两个节点的值是否相等。如果不相等，则可以确定这两个节点不相等。如果相等，则需要比较它们的左子树和右子树是否相等。这个过程通过递归调用 `BEq` 的实例来实现。只有当两个节点的值相等且它们的左右子树也都相等时，才能判断这两个节点相等。

## Hashable

在 `Hashable` 的实现中，我们需要生成二叉树的哈希值。为了计算哈希值，我们需要考虑二叉树的值以及它的左右子树。我们可以使用递归来计算子树的哈希值，并将它们与根节点的值进行组合。为了保证哈希值的一致性，我们需要在递归调用中使用 `^` 运算符将根节点的哈希值与左右子树的哈希值进行组合。

这两种实现中都使用了递归和递归实例搜索来处理二叉树的节点和子树。这种方法简单而直观，同时也保证了正确性和一致性。

```lean
{{#example_decl Examples/Classes.lean TreeHash}}
```

## 推导标准类

像 `BEq` 和 `Hashable` 这样的类的实例通常是相当繁琐的手动实现的。
Lean 包括了一个名为 _instance deriving_ 的特性，允许编译器自动构建许多类型类的行为良好的实例。
事实上，在[结构部分](../getting-to-know/structures.md)中定义 `Point` 时的 `deriving Repr` 短语就是一个实例 deriving 的例子。

实例可以通过两种方式推导。
第一种方式可以在定义一个结构或归纳类型时使用。
在这种情况下，在类型声明的末尾添加 `deriving`，后面跟着要推导实例的类的名称。
对于已经定义的类型，可以使用一个独立的 `deriving` 命令。
在后期通过编写 `deriving instance C1, C2, ... for T` 来推导类型 `T` 的实例 `C1, C2, ...`。

使用非常少量的代码可以为 `Pos` 和 `NonEmptyList` 推导出 `BEq` 和 `Hashable` 的实例：

```lean
{{#example_decl Examples/Classes.lean BEqHashableDerive}}
```

可以为以下类派生实例：
 * `Inhabited`
 * `BEq`
 * `Repr`
 * `Hashable`
 * `Ord`

然而，在某些情况下，派生的 `Ord` 实例可能不能在应用程序中产生精确的排序。
在这种情况下，可以手动编写一个 `Ord` 实例。
可以通过高级用户扩展可以派生实例的类的集合。

除了在程序员生产力和代码可读性方面的明显优势之外，派生实例还使代码更易于维护，因为随着类型定义的演变，实例也会得到更新。
涉及对数据类型进行更新的变更集可以更容易阅读，而不需要一行又一行地进行公式化的修改相等性测试和哈希计算。

## 追加

许多数据类型都有某种追加运算符。
在 Lean 中，将两个值进行追加是通过类型类 `HAppend` 进行重载的，它是一种类似于算术运算的混合操作：

```lean
{{#example_decl Examples/Classes.lean HAppend}}
```

语法 `{{#example_in Examples/Classes.lean desugarHAppend}}` 被展开为 `{{#example_out Examples/Classes.lean desugarHAppend}}`。
对于同构情况，只需要实现一个遵循通常模式的 `Append` 实例。

```lean
{{#example_decl Examples/Classes.lean AppendNEList}}
```

在定义了上述实例之后，

```lean
{{#example_in Examples/Classes.lean appendSpiders}}
```

Lean 定理证明
==================

Lean 定理如下：

如果一个集合 A 存在且非空，并且它是一个连通集合（也即，对于集合中的任意两个元素 a 和 b，它们之间存在一条路径），定义一个名称为 a 的元素，且所有在集合 A 中名称为 a 的元素都可以通过一个连通集合中的路径到达，那么集合 A 中所有名称为 a 的元素都是互相可替换的。

下面是该定理的证明。

证明：
------

我们需要证明 A 中所有名称为 a 的元素都是互相可替换的。我们可以通过以下步骤来证明：

1. 假设 A 中存在名称为 a 的元素，且其在集合 A 中是一个连通集合。
2. 遍历集合 A 中的所有元素，检查它们是否可以通过一个连通集合中的路径到达。
3. 如果某个元素不能通过连通集合中的路径到达，则它不属于集合 A，并且与其他元素不可替换。
4. 否则，如果所有元素都可以通过连通集合中的路径到达，则它们是互相可替换的。

从以上步骤可知，如果集合 A 满足定理中的条件，则集合中所有名称为 a 的元素都是互相可替换的。

证毕。

根据以上证明，我们可以得出结论：如果一个集合 A 是一个连通集合，并且满足定理中的条件，那么集合 A 中所有名称为 a 的元素都是互相可替换的。

```output info
{{#example_out Examples/Classes.lean appendSpiders}}
```

类似地，`HAppend` 的定义允许将非空列表附加到普通列表的末尾：

```lean
{{#example_decl Examples/Classes.lean AppendNEListList}}
```

有了这个实例的帮助，我们可以开始证明 LEAN 定理。

```lean
{{#example_in Examples/Classes.lean appendSpidersList}}
```

导致。

```output info
{{#example_out Examples/Classes.lean appendSpidersList}}
```

## 函子

一个多态类型被称为 _函子_（functor）如果它有一个名为 `map` 的函数重载，通过函数对其中包含的每个元素进行转换。
尽管大多数语言使用这个术语，C# 中相当于 `map` 的是 `System.Linq.Enumerable.Select` 函数。
例如，对列表应用一个函数会构造一个新的列表，其中每个起始列表中的条目都被函数的结果所替代。
对 `Option` 类型应用一个函数 `f`，会保持 `none` 不变，并将 `some x` 替换为 `some (f x)`。

以下是函子的一些例子以及它们的 `Functor` 实例重载的 `map` 函数：
  * `{{#example_in Examples/Classes.lean mapList}}` 的结果为 `{{#example_out Examples/Classes.lean mapList}}`
  * `{{#example_in Examples/Classes.lean mapOption}}` 的结果为 `{{#example_out Examples/Classes.lean mapOption}}`
  * `{{#example_in Examples/Classes.lean mapListList}}` 的结果为 `{{#example_out Examples/Classes.lean mapListList}}`

因为 `Functor.map` 对于这个常见的操作有点太长了，所以 Lean 还提供了一个中缀操作符来进行函数映射，它就是 `<$>`。
上述的例子可以重写为如下形式：
  * `{{#example_in Examples/Classes.lean mapInfixList}}` 的结果为 `{{#example_out Examples/Classes.lean mapInfixList}}`
  * `{{#example_in Examples/Classes.lean mapInfixOption}}` 的结果为 `{{#example_out Examples/Classes.lean mapInfixOption}}`
  * `{{#example_in Examples/Classes.lean mapInfixListList}}` 的结果为 `{{#example_out Examples/Classes.lean mapInfixListList}}`

`NonEmptyList` 的 `Functor` 实例需要指定 `map` 函数。

```lean
{{#example_decl Examples/Classes.lean FunctorNonEmptyList}}
```

在这里，`map`使用了`List`的`Functor`实例，将函数映射到尾部上。
这个实例是为`NonEmptyList`定义的，而不是为`NonEmptyList α`定义的，因为类型类的解析过程中参数类型`α`没有起到任何作用。
`NonEmptyList`可以对其进行函数映射，而无论条目的类型是什么。
如果`α`是类型类的参数，那么可能会生成仅适用于`NonEmptyList Nat`的`Functor`的版本，但`Functor`的一部分是`map`适用于任何输入类型。

这是`PPoint`的`Functor`实例：

```lean
{{#example_decl Examples/Classes.lean FunctorPPoint}}
```

在这种情况下，`f` 已经被应用到了 `x` 和 `y`。

即使一个函子中包含的类型本身也是一个函子，映射一个函数只会进行一层。
也就是说，当对 `NonEmptyList (PPoint Nat)` 使用 `map` 时，被映射的函数应该以 `PPoint Nat` 作为参数，而不是 `Nat`。

`Functor` 类的定义使用了另一个还未讨论的语言特性：默认方法定义。
通常，一个类会指定一些最小的可重载操作，这些操作在一起是有意义的，然后使用带有实例隐含参数的多态函数来基于这些重载操作提供更大的库功能。
例如，函数 `concat` 可以连接任何条目可追加的非空列表：

```lean
{{#example_decl Examples/Classes.lean concat}}
```

然而，对于某些类，如果了解数据类型的内部情况，可以更高效地实现一些操作。

在这些情况下，可以提供默认方法定义。
默认方法定义是根据其他方法提供方法的默认实现。
但是，实例实现者可以选择覆盖这个默认实现，使用更高效的方法。
默认方法定义在 `class` 定义中使用 `:=` 。

对于 `Functor` 类来说，某些类型在实现 `map` 时可能有更高效的方式，特别是当要映射的函数忽略了其参数。
忽略参数的函数被称为 _常量函数_ ，因为它们总是返回相同的值。
以下是 `Functor` 的定义，其中 `mapConst` 有一个默认实现：

```lean
{{#example_decl Examples/Classes.lean FunctorDef}}
```

就像一个没有遵守 *BEq* 接口的 `Hashable` 实例是有缺陷的一样，一个在映射函数的同时移动数据的 *Functor* 实例也是有缺陷的。例如，`List` 的一个有缺陷的 *Functor* 实例可能会丢弃它的参数并始终返回空列表，或者它可能会翻转列表。而对于 `PPoint` 的一个糟糕实例可能会将 `f x` 放在 `x` 和 `y` 两个字段中。

具体来说，*Functor* 的实例应该遵循两个规则：
1. 对于 *identity* 函数进行映射应该得到原始参数。
2. 对于两个复合函数进行映射应该具有与它们的映射的复合相同的效果。

更正式地说，第一个规则表明 `id <$> x` 等于 `x`。
第二个规则表明 `map (fun y => f (g y)) x` 等于 `map f (map g x)`。
这些规则防止了对数据进行移动或删除的 *map* 实现。

## 可能遇到的问题

Lean 并不能为所有类自动生成实例。
例如，以下代码：

```lean
{{#example_in Examples/Classes.lean derivingNotFound}}
```

导致以下错误：

```output error
{{#example_out Examples/Classes.lean derivingNotFound}}
```

调用 `deriving instance` 会导致 Lean 查找类型类实例的代码生成器的内部表。
如果找到了代码生成器，那么它会根据提供的类型来创建实例。
然而，此消息表示没有找到 `ToString` 的代码生成器。

## 练习

*编写一个 `HAppend (List α) (NonEmptyList α) (NonEmptyList α)` 的实例，并对其进行测试。
*为二叉树数据类型实现一个 `Functor` 实例。