# 数组和索引

[插入篇](../props-proofs-indexing.md)介绍了如何使用索引符号按照位置查找列表中的条目。这个语法也受到类型类的控制，可以用于各种不同的类型。

## 数组
例如，对于大多数用途，Lean 数组要比链表效率更高。在 Lean 中，类型 `Array α` 是一个动态大小的数组，其中存放着类型为 `α` 的值，就像 Java 的 `ArrayList`、C++ 的 `std::vector` 或 Rust 的 `Vec` 一样。与 `List` 不同，每次使用 `cons` 构造器时都需要进行指针间接寻址，而数组占用了一块连续的内存区域，这对于处理器缓存来说更好。此外，在数组中查找一个值的时间是恒定的，而在链表中查找则需要与所访问的索引成比例的时间。

在纯函数式语言中，如 Lean，不可能在数据结构中直接进行变异。相反，被修改后的副本会被创建。当使用数组时，Lean 编译器和运行时包含了一种优化，可以在只有一个对数组的唯一引用时将修改实现为后台的变异。

数组的写法类似于列表，但以 `#` 开头：

```lean
{{#example_decl Examples/Classes.lean northernTrees}}
```

可以使用 `Array.size` 函数来找到数组中的元素个数。
例如，`{{#example_in Examples/Classes.lean northernTreesSize}}` 的输出结果为 `{{#example_out Examples/Classes.lean northernTreesSize}}`。
对于小于数组大小的索引，可以使用索引符号来获取对应的值，就像操作列表一样。
也就是说，`{{#example_in Examples/Classes.lean northernTreesTwo}}` 的输出结果为 `{{#example_out Examples/Classes.lean northernTreesTwo}}`。
类似地，编译器要求提供索引在范围内的证明，如果尝试查找数组范围之外的值，则会在编译时出现错误，就像操作列表时一样。
例如，`{{#example_in Examples/Classes.lean northernTreesEight}}` 的输出结果为：

```output error
{{#example_out Examples/Classes.lean northernTreesEight}}
```

## 非空列表

可以将一个表示非空列表的数据类型定义为一个结构体，其中包含一个字段用于保存列表的头部元素，以及一个字段用于保存尾部元素，尾部元素可以是一个普通的、可能为空的列表：

```lean
{{#example_decl Examples/Classes.lean NonEmptyList}}
```

例如，非空列表 `idahoSpiders`（其中包含一些生长于美国爱达荷州的蜘蛛物种）由 `{{#example_out Examples/Classes.lean firstSpider}}` 开始，并包含四个其他蜘蛛物种，共计五只蜘蛛。

```lean
{{#example_decl Examples/Classes.lean idahoSpiders}}
```

使用递归函数在列表中查找特定索引处的值时，应考虑三种情况：
  1. 索引为 `0`，此时应返回列表的头部。
  2. 索引为 `n + 1` 并且尾部为空，此时索引越界。
  3. 索引为 `n + 1` 并且尾部非空，此时可以对尾部和 `n` 递归调用该函数。

例如，可以编写一个返回 `Option` 的查找函数，如下所示：

```lean
{{#example_decl Examples/Classes.lean NEListGetHuh}}
```

模式匹配中的每个情况都对应上述可能性之一。
对于 `get?` 的递归调用不需要 `NonEmptyList` 的命名空间限定符，因为定义的主体隐式位于定义的命名空间中。
另一种写这个函数的方式是在索引大于零时使用 `get?` 来处理列表：

```lean
{{#example_decl Examples/Classes.lean NEListGetHuhList}}
```

如果列表只包含一个条目，则只有 `0` 是一个有效的索引。
如果列表包含两个条目，则 `0` 和 `1` 都是有效的索引。
如果列表包含三个条目，则 `0`、`1` 和 `2` 都是有效的索引。
换句话说，对于非空列表，有效的索引是严格小于列表长度的自然数，也就是小于等于尾部长度的数。

将索引视为在界限内的定义应该被写为 `abbrev`，因为用于找到索引为可接受的证据的策略可以解决数字的不等式，但他们对于名为 `NonEmptyList.inBounds` 的名称一无所知。

```lean
{{#example_decl Examples/Classes.lean inBoundsNEList}}
```

该函数返回一个可能为真或为假的命题。
例如，`2` 在 `idahoSpiders` 的范围内，而 `5` 则不在。

```leantac
{{#example_decl Examples/Classes.lean spiderBoundsChecks}}
```

逻辑否定运算符的优先级很低，这意味着 `¬idahoSpiders.inBounds 5` 等同于 `¬(idahoSpiders.inBounds 5)`。

这个事实可以用来编写一个查找函数，需要证明索引是有效的，因此不需要返回 `Option`，可以委托给对应的对列表进行编译时检查的版本：

```lean
{{#example_decl Examples/Classes.lean NEListGet}}
```

当然，写一个直接使用证据的函数是可能的，而不是委托给一个恰好能使用相同证据的标准库函数。
这需要使用后面在本书中描述的处理证明和命题的技术。

## 重载索引

对于一个集合类型，可以通过定义`GetElem`类型类的实例来重载索引表示法。
为了灵活性，`GetElem`有四个参数：
 * 集合的类型
 * 索引的类型
 * 从集合中提取的元素的类型
 * 决定索引在范围内的以证据的函数

元素类型和证据函数都是输出参数。
`GetElem`有一个单一的方法`getElem`，它接受一个集合值，一个索引值和证据索引在范围内作为参数，并返回一个元素：

```lean
{{#example_decl Examples/Classes.lean GetElem}}
```

在`NonEmptyList α`这种情况下，这些参数是：
* 集合是 `NonEmptyList α`
* 索引类型是 `Nat`
* 元素的类型是 `α`
* 如果索引小于等于尾部的长度，那么索引是在范围内的

实际上，`GetElem`实例可以直接委托给`NonEmptyList.get`：

```lean
{{#example_decl Examples/Classes.lean GetElemNEList}}
```

通过这个实例，`NonEmptyList` 的使用与 `List` 一样方便。
对 `{{#example_in Examples/Classes.lean firstSpider}}` 进行求值会得到 `{{#example_out Examples/Classes.lean firstSpider}}`，而对 `{{#example_in Examples/Classes.lean tenthSpider}}` 的求值则会导致编译时错误：

```output error
{{#example_out Examples/Classes.lean tenthSpider}}
```

因为集合类型和索引类型都是 `GetElem` 类型类的输入参数，所以可以使用新的类型来索引现有的集合。
正数类型 `Pos` 是一个非常合理的索引方式，可以用来索引 `List`，但要注意不能指向第一个条目。
下面的 `GetElem` 实例允许使用 `Pos` 和使用 `Nat` 一样方便地找到列表的条目：

```lean
{{#example_decl Examples/Classes.lean ListPosElem}}
```

索引也可以适用于非数字索引。
例如，`Bool` 可以用来选择点中的字段，`false` 对应 `x`，`true` 对应 `y`：

```lean
{{#example_decl Examples/Classes.lean PPointBoolGetElem}}
```

在这种情况下，两个布尔值都是有效的索引。
因为每个可能的 `Bool` 都在边界内，所以这个证据就是简单的真命题 `True`。