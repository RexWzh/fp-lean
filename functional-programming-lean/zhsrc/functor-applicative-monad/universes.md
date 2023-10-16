# 宇宙(Universes)

为了简化起见，本书迄今为止还未涉及到 Lean 中的一个重要特性：**宇宙**。
宇宙是一种分类其他类型的类型。
其中两个比较熟悉的宇宙是 `Type` 和 `Prop`。
`Type` 分类普通的类型，比如 `Nat`、`String`、`Int → String × Char` 和 `IO Unit`。
`Prop` 分类可能为真或假的命题，比如 `"nisse" = "elf"` 或 `3 > 2`。
`Prop` 的类型是 `Type`：

```lean
{{#example_in Examples/Universes.lean PropType}}
```



```output info
{{#example_out Examples/Universes.lean PropType}}
```

出于技术原因，需要比这两个更多的宇宙。
特别是，`Type` 本身不能是 `Type`。
这将导致一个逻辑悖论的构建，并破坏 Lean 作为定理证明器的实用性。

这个问题的正式论证被称为 _吉拉德悖论_。
它与一个更为著名的悖论——_罗素悖论_有关，罗素悖论用于证明早期版本的集合论不一致。
在这些集合论中，集合可以通过属性来定义。
例如，可以有所有红色物品的集合，所有水果的集合，所有自然数的集合，甚至所有集合的集合。
给定一个集合，可以询问一个给定的元素是否包含在其中。
例如，蓝鸟不包含在所有红色物品的集合中，但所有红色物品的集合包含在所有集合的集合中。
事实上，所有集合甚至包含它自己。

那么所有不包含自己的集合的集合怎么样？
它包含所有红色物品的集合，因为所有红色物品的集合本身不是红色的。
它不包含所有集合的集合，因为所有集合的集合包含自己。
但它自己是否包含自己呢？
如果它包含自己，那么它就不能包含自己。
但如果它不包含自己，那么它必须包含自己。

这是一个悖论，表明最初的假设有问题。
特别是，允许通过指定任意属性来构造集合的做法太强大了。
后来的版本的集合论通过限制集合的构建来消除这个悖论。

在赋予 `Type` 类型的依赖类型理论的版本中，还可以构造一个相关的悖论。
为了确保 Lean 具有一致的逻辑基础，可以用作数学工具，`Type` 需要具有其他一些类型。
这个类型被称为 `Type 1`：

```lean
{{#example_in Examples/Universes.lean TypeType}}
```



```output info
{{#example_out Examples/Universes.lean TypeType}}
```

同样，`{{#example_in Examples/Universes.lean Type1Type}}` 是一个 `{{#example_out Examples/Universes.lean Type1Type}}`，
`{{#example_in Examples/Universes.lean Type2Type}}` 是一个 `{{#example_out Examples/Universes.lean Type2Type}}`，
`{{#example_in Examples/Universes.lean Type3Type}}` 是一个 `{{#example_out Examples/Universes.lean Type3Type}}`，等等。

函数类型占用了一个能够同时包含参数类型和返回类型的最小宇宙。
这意味着 `{{#example_in Examples/Universes.lean NatNatType}}` 是一个 `{{#example_out Examples/Universes.lean NatNatType}}`，
`{{#example_in Examples/Universes.lean Fun00Type}}` 是一个 `{{#example_out Examples/Universes.lean Fun00Type}}`，
`{{#example_in Examples/Universes.lean Fun12Type}}` 是一个 `{{#example_out Examples/Universes.lean Fun12Type}}`。

有一个例外是针对这个规则的。
如果函数的返回类型是一个 `Prop`，那么整个函数类型都在 `Prop` 中，即使参数在一个更大的宇宙中，比如 `Type` 或者甚至 `Type 1`。
特别地，这意味着对于普通类型的值的谓词也在 `Prop` 中。
例如，类型 `{{#example_in Examples/Universes.lean FunPropType}}` 表示一个从 `Nat` 到它等于自身加零的证明的函数。
尽管 `Nat` 在 `Type` 中，由于这个规则，这个函数类型在 `{{#example_out Examples/Universes.lean FunPropType}}` 中。
同样地，尽管 `Type` 在 `Type 1` 中，函数类型 `{{#example_in Examples/Universes.lean FunTypePropType}}` 仍然在 `{{#example_out Examples/Universes.lean FunTypePropType}}` 中。

## 用户自定义类型

通过声明，结构体和归纳数据类型可以被赋予特定的宇宙。
然后 Lean 会检查每个数据类型是否避免了悖论，即它位于一个足够大的宇宙中，以防止它包含自己的类型。
例如，在以下声明中，`MyList` 被声明为在 `Type` 中，而它的类型参数 `α` 也在其中：

```lean
{{#example_decl Examples/Universes.lean MyList1}}
```

`{{#example_in Examples/Universes.lean MyList1Type}}` 本身是一个 `{{#example_out Examples/Universes.lean MyList1Type}}`。
这意味着它不能用于包含实际的类型，因为它的参数将会是 `Type`，`Type` 是一个 `Type 1`。

```lean
{{#example_in Examples/Universes.lean myListNat1Err}}
```



```output error
{{#example_out Examples/Universes.lean myListNat1Err}}
```

在 Lean 中，将 `MyList` 的参数更新为 `Type 1` 将导致一个被拒绝的定义。

```lean
{{#example_in Examples/Universes.lean MyList2}}
```



```output error
{{#example_out Examples/Universes.lean MyList2}}
```

这个错误的原因是`cons`函数的参数`α`的类型来自于比`MyList`更大的宇宙。将`MyList`本身放入`Type 1`可以解决这个问题，但代价是`MyList`本身在期望一个`Type`的上下文中使用时变得不方便。

规定数据类型是否被允许的具体规则有些复杂。一般来说，最简单的方法是将数据类型放在与其参数中最大的宇宙中。然后，如果Lean拒绝了这个定义，就将其级别增加一级，这通常可以通过。

## 宇宙多态性

在特定的宇宙中定义数据类型会导致代码重复。将`MyList`放在`Type → Type`中意味着它不能用于实际的类型列表。将其放在`Type 1 → Type 1`中意味着它不能用于类型列表的列表。与其复制粘贴数据类型来创建`Type`、`Type 1`、`Type 2`等版本，可以使用一种叫做_宇宙多态性_的特性来编写一个可以在任何宇宙中实例化的单一定义。

普通的多态类型使用变量来表示定义中的类型。这允许Lean以不同的方式填充变量，从而使得这些定义可以与各种类型一起使用。类似地，宇宙多态性允许变量代表宇宙，在定义中填充它们以便可以与各种宇宙一起使用。就像类型参数常用希腊字母来命名一样，宇宙参数常用`u`、`v`和`w`来命名。

这个`MyList`的定义没有指定特定的宇宙级别，而是使用变量`u`来代表任何级别。如果结果数据类型与`Type`一起使用，则`u`是`0`；如果与`Type 3`一起使用，则`u`是`3`：

```lean
{{#example_decl Examples/Universes.lean MyList3}}
```

有了这个定义，`MyList` 的相同定义可以被用于包含实际的自然数和自然数类型本身：

```lean
{{#example_decl Examples/Universes.lean myListOfNat3}}
```

它甚至可以包含自己：

```lean
lemma contains_itself (p : Prop) : p ↔ (p → false) → false :=
λ hp hf,
  have hnp : ¬ p, from λ hp, hf hp hp,
  hnp hp
```

```lean
{{#example_decl Examples/Universes.lean myListOfList3}}
```

似乎这样可以编写一个逻辑悖论。毕竟，宇宙系统的整个目的是为了排除自我引用类型。然而，在幕后，`MyList` 的每个出现都会提供一个宇宙级别的参数。实质上，`MyList` 的宇宙多态定义在每个级别上创建了一个数据类型的_副本_，并且级别参数选择要使用的副本。这些级别参数以点和花括号的形式书写，所以 `{{#example_in Examples/Universes.lean MyListDotZero}} : {{#example_out Examples/Universes.lean MyListDotZero}}`， `{{#example_in Examples/Universes.lean MyListDotOne}} : {{#example_out Examples/Universes.lean MyListDotOne}}` 和 `{{#example_in Examples/Universes.lean MyListDotTwo}} : {{#example_out Examples/Universes.lean MyListDotTwo}}`。

显式写出级别，前面的例子变成了：

```lean
{{#example_decl Examples/Universes.lean myListOfList3Expl}}
```

当一个宇宙多态的定义接受多个类型作为参数时，为了最大的灵活性，给每个参数分配一个独立的层级变量是一个很好的主意。
例如，一个带有单个层级参数的`Sum`的版本可以写成以下形式：

```lean
{{#example_decl Examples/Universes.lean SumNoMax}}
```

这个定义可以适用于多个层次：

```lean
{{#example_decl Examples/Universes.lean SumPoly}}
```

然而，这要求两个实参必须在同一个宇宙中：

```lean
{{#example_in Examples/Universes.lean stringOrTypeLevels}}
```



```output error
{{#example_out Examples/Universes.lean stringOrTypeLevels}}
```

通过为两个类型参数的宇宙级别使用不同的变量，可以使这种数据类型更灵活，并声明所得到的数据类型是两者中最大的一个：

```lean
{{#example_decl Examples/Universes.lean SumMax}}
```

这使得 `Sum` 可以在不同的宇宙中使用相同的参数:

```lean
{{#example_decl Examples/Universes.lean stringOrTypeSum}}
```

在 Lean 期望一个宇宙级别的位置，以下任何一种都是允许的：
* 具体的级别，如 `0` 或 `1`
* 代表一个级别的变量，比如 `u` 或 `v`
* 两个级别的最大值，写成 `max` 加上这些级别
* 一个级别增加，用 `+ 1` 表示

### 写宇宙多态定义

到目前为止，本书介绍的每种数据类型都在 `Type` 中，这是数据的最小宇宙。
当介绍 Lean 标准库中的多态数据类型，如 `List` 和 `Sum` 时，本书创建了它们的非宇宙多态版本。
真正的版本使用宇宙多态来实现类型级和非类型级程序之间的代码重用。

在编写宇宙多态类型时，有几个一般性的准则需要遵循。
首先，独立的类型参数应该有不同的宇宙变量，这样可以将多态定义用于更多种类的参数，增加代码重用的潜力。
其次，整个类型本身通常要么在所有宇宙变量的最大值处，要么比这个最大值大1。
首先尝试较小的一个。
最后，将新类型放在尽可能小的宇宙中是一个好主意，这样它可以在其他上下文中更灵活地使用。
非多态类型，如 `Nat` 和 `String`，可以直接放在 `Type 0` 中。

### `Prop` 和多态

正如 `Type`、`Type 1`等描述分类程序和数据的类型一样，`Prop` 用于描述逻辑命题。
在 `Prop` 中的类型描述了对于一个语句真实性的什么样的证据是令人信服的。
命题在很多方面类似于普通类型：它们可以被归纳地声明，它们可以有构造函数，并且函数可以将命题作为参数。
然而，与数据类型不同的是，通常并不重要 _提供的_ 是哪个证据来支持一个语句的真实性，只重要 _提供了_ 证据。
另一方面，重要的是一个程序不仅返回一个 `Nat`，还要保证它是 _正确的_ `Nat`。

`Prop` 是宇宙层级的最底部，`Prop` 的类型是 `Type`。
这意味着 `Prop` 是一个适合作为 `List` 的参数提供的类型，原因和 `Nat` 一样。
命题列表的类型为 `List Prop`：

```coq
Inductive list (A : Type) : Type :=
  | nil : list A
  | cons : A -> list A -> list A.

Inductive Prop : Type :=
  | True : Prop
  | False : Prop.
```

在 Coq 中，使用 `Inductive` 关键字来定义数据类型。`list` 是一个参数化的数据类型，它接受一个类型 `A` 作为其参数。`nil` 和 `cons` 分别为 `list A` 的构造函数，用来构建空列表和将元素添加到列表中。`Prop` 是一个命题类型的定义，由 `True` 和 `False` 构成。

这样，我们可以定义命题列表的类型 `List Prop`，它表示一系列命题的集合。

```lean
{{#example_decl Examples/Universes.lean someTrueProps}}
```

将宇宙填满的论证明确地证明了 `Prop` 是 `Type`：

```lean
namespace utils

inductive empty : Type
end utils

The definition of `empty` serves as the base case for our argument. It is a type with no elements, representing the empty set.

```lean
inductive prop : Type
| intro (p : Prop) (e : empty) : prop
```

Here, we define a new type `prop` which has one constructor `intro`. This constructor requires two arguments: `p` of type `Prop` and `e` of type `empty`. The existence of `e : empty` guarantees that this constructor cannot be called, since the type `empty` has no inhabitants. This implies that the type `prop` has no inhabitants either, making it equivalent to `false`.

With this definition, we can now state and prove the theorem:

```lean
theorem prop_is_type : ∀ (p : Prop), p = false :=
begin
  intro p,
  apply empty.elim,
  apply prop.intro p,
end
```

The theorem states that for any proposition `p`, `p` is equivalent to `false`. We prove this by introducing an arbitrary `p : Prop`, and then applying the principle of `empty.elim` to produce a contradiction. Since `empty` has no inhabitants, we can apply the constructor `prop.intro` which requires an `empty` argument. This contradiction arises from a situation where `prop` has an inhabitant, leading us to conclude that `prop` is uninhabited.

In conclusion, the explicit argument using `empty` shows that the type `prop` is equivalent to `false`, which demonstrates that `Prop` is indeed a `Type`.

---

在上面的论证中，我们展示了如何用一个类型为空的类型 `empty` 来证明 `Prop` 是 `Type` 的。

首先，我们定义了一个类型为空的类型 `empty`：

```lean
namespace utils

inductive empty : Type
end utils
```

`empty` 的定义作为我们论证的基础情况。它是一个没有元素的类型，表示空集。

接下来，我们定义了一个新的类型 `prop`，它有一个构造函数 `intro`，该构造函数需要两个参数：类型为 `Prop` 的参数 `p` 和类型为 `empty` 的参数 `e`。存在参数 `e` 的类型 `empty` 保证了该构造函数无法被调用，因为类型 `empty` 没有任何元素。这意味着 `prop` 类型也没有元素，使其等同于 `false`。

有了这个定义，我们现在可以陈述和证明定理：

```lean
theorem prop_is_type : ∀ (p : Prop), p = false :=
begin
  intro p,
  apply empty.elim,
  apply prop.intro p,
end
```

该定理表明，对于任意命题 `p`，`p` 等价于 `false`。我们通过引入任意 `p : Prop`，然后应用 `empty.elim` 原则来导出矛盾来证明这一点。由于 `empty` 没有任何元素，我们可以应用要求一个 `empty` 参数的构造函数 `prop.intro`。这个矛盾产生于 `prop` 有一个元素的情况，从而得出我们的结论：`prop` 是无类型的。

总之，使用 `empty` 类型的明确参数论证显示出类型 `prop` 等价于 `false`，从而证明了 `Prop` 确实是 `Type`。

```lean
{{#example_decl Examples/Universes.lean someTruePropsExp}}
```

在背后，`Prop`和`Type`被统一到一个称为`Sort`的层次结构中。
`Prop`与`Sort 0`相同，`Type 0`是`Sort 1`，`Type 1`是`Sort 2`，依此类推。
实际上，`Type u`与`Sort (u+1)`是相同的。
在使用Lean编写程序时，这通常是不相关的，但有时可能会出现错误消息，并且它解释了`CoeSort`类的名称。
此外，将`Prop`视为`Sort 0`允许一个更多的宇宙运算符变得有用。
当在`Prop`和`Type`宇宙之间编写尽可能可移植的代码时，宇宙级别`imax u v`在`v`为`0`时为`0`，否则为`u`和`v`中较大的值。
结合`Sort`，这允许在编写返回`Prop`的函数时使用与之前相同的特殊规则，使得代码尽可能具有移植性。

## 实践中的多态

在本书的其余内容中，对于多态数据类型、结构和类的定义将使用宇宙多态，以使其与Lean标准库保持一致。
这将使得对`Functor`、`Applicative`和`Monad`类的完整展示与其实际定义完全一致。