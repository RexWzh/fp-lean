# 结构体和继承

为了正确理解`Functor`、`Applicative`和`Monad`的完整定义，需要使用另一个Lean特性：结构体继承。
结构体继承允许一个结构体类型提供另一个结构体的接口，同时还可以增加其他字段。
这在建模具有明确分类关系的概念时非常有用。
例如，以神话生物的模型为例。
其中一些是大型的，而一些是小型的：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean MythicalCreature}}
```

在幕后，定义 `MythicalCreature` 结构会创建一个带有单个构造函数 `mk` 的归纳类型：

```lean
{{#example_in Examples/FunctorApplicativeMonad.lean MythicalCreatureMk}}
```



```output info
{{#example_out Examples/FunctorApplicativeMonad.lean MythicalCreatureMk}}
```

类似地，我们创建一个名为`MythicalCreature.large`的函数，用于从构造函数中提取字段：

```python
def large(creature):
    return creature.large
```

This function takes an instance of `MythicalCreature` as an argument and returns the value of the `large` field.

```lean
{{#example_in Examples/FunctorApplicativeMonad.lean MythicalCreatureLarge}}
```



```output info
{{#example_out Examples/FunctorApplicativeMonad.lean MythicalCreatureLarge}}
```

在大多数古老的故事中，每个怪物都有一种可以打败它的方式。
怪物的描述应包含这些信息，以及它是否巨大：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean Monster}}
```

标题中的`extends MythicalCreature`表示每个怪物都是神秘的。
要定义一个`Monster`，需要提供`MythicalCreature`的字段和`Monster`的字段。
巨魔是一个对阳光很脆弱的大型怪物：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean troll}}
```

在幕后，继承是通过组合来实现的。
构造函数 `Monster.mk` 接受一个 `MythicalCreature` 作为其参数：

```lean
{{#example_in Examples/FunctorApplicativeMonad.lean MonsterMk}}
```



```output info
{{#example_out Examples/FunctorApplicativeMonad.lean MonsterMk}}
```

除了定义函数来提取每个新字段的值之外，还定义了一个类型为 `{{#example_out Examples/FunctorApplicativeMonad.lean MonsterToCreature}}` 的函数 `{{#example_in Examples/FunctorApplicativeMonad.lean MonsterToCreature}}`。
这个函数可以用来提取底层的生物。

在 Lean 中，向上移动继承层次结构并不等同于面向对象语言中的向上转型（upcasting）。
向上转型操作符使得派生类的值被视为父类的实例，但值保留其身份和结构。
然而，在 Lean 中，向上移动继承层次结构实际上会抹除底层信息。
要看到这一点的效果，请考虑评估 `troll.toMythicalCreature` 的结果：

```lean
{{#example_in Examples/FunctorApplicativeMonad.lean evalTrollCast}}
```



```output info
{{#example_out Examples/FunctorApplicativeMonad.lean evalTrollCast}}
```

只有 `MythicalCreature` 的字段保留。

就像 `where` 语法一样，使用带有字段名的大括号符号也适用于结构继承：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean troll2}}
```

然而，委托给底层构造函数的匿名尖括号表示法揭示了内部细节：

```lean
{{#example_in Examples/FunctorApplicativeMonad.lean wrongTroll1}}
```



```output error
{{#example_out Examples/FunctorApplicativeMonad.lean wrongTroll1}}
```

需要添加一个额外的角括号，调用 `MythicalCreature.mk`，传入 `true`：

```
MythicalCreature.mk(true)
```

This will create a new instance of the `MythicalCreature` class and invoke its `mk` method with the argument `true`.

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean troll3}}
```

Lean的点表示法可以考虑继承关系。
换句话说，现有的 `MythicalCreature.large` 可以与 `Monster` 一起使用，并且Lean会在调用 `MythicalCreature.large` 之前自动插入调用 `{{#examples_in Examples/FunctorApplicativeMonad.lean MonsterToCreature}}`。
然而，这仅在使用点表示法时发生，并且使用普通的函数调用语法应用字段查找函数会导致类型错误：

```lean
{{#example_in Examples/FunctorApplicativeMonad.lean trollLargeNoDot}}
```



```output error
{{#example_out Examples/FunctorApplicativeMonad.lean trollLargeNoDot}}
```

 Dot notation可以针对用户定义的函数考虑继承。小的生物是不大的生物：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean small}}
```

评估 `{{#example_in Examples/FunctorApplicativeMonad.lean smallTroll}}` 得到的结果是 `{{#example_out Examples/FunctorApplicativeMonad.lean smallTroll}}`，而尝试评估 `{{#example_in 示例/函子应用单子.lean smallTrollWrong}}` 的结果是：

```output error
{{#example_out Examples/FunctorApplicativeMonad.lean smallTrollWrong}}
```

### 多继承

Helper（辅助者）是一种神秘的生物，当给予正确的报酬时可以提供帮助：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean Helper}}
```

例如，*Nisse* 是一种小精灵，据说只要给它可口的粥，它就会帮助家务。

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean elf}}
```

如果被驯化，巨魔可以成为出色的助手。
它们足够强壮，在一夜之间就能翻耕整片田地，但是它们需要模型山羊来满足它们在生活中的需求。
一个怪物助手是既是怪物又是助手的怪物：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean MonstrousAssistant}}
```

这种结构类型的值必须填写父结构的所有字段：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean domesticatedTroll}}
```

所涉及的两个父结构类型都继承自 `MythicalCreature`。
如果多重继承被朴素地实现，那么就会出现“菱形问题”，即对于一个给定的 `MonstrousAssistant`，不清楚应该从哪个路径继承 `large` 。 应该从包含的 `Monster` 还是从包含的 `Helper` 继承呢？
在 Lean 中，答案是采用指定的第一个路径来继承父级结构，并且额外的父结构字段是复制而不是直接包含在新结构中。

可以通过检查 `MonstrousAssistant` 的构造函数签名来证明这一点：

```lean
{{#example_in Examples/FunctorApplicativeMonad.lean checkMonstrousAssistantMk}}
```



```output info
{{#example_out Examples/FunctorApplicativeMonad.lean checkMonstrousAssistantMk}}
```

它接受一个 `Monster` 作为参数，还有 `Helper` 在 `MythicalCreature` 之上引入的两个字段。
同样地，虽然 `MonstrousAssistant.toMonster` 只是从构造函数中提取 `Monster`，但是 `MonstrousAssistant.toHelper` 没有 `Helper` 可以提取。
`#print` 命令暴露了它的实现：

```lean
{{#example_in Examples/FunctorApplicativeMonad.lean printMonstrousAssistantToHelper}}
```



```output info
{{#example_out Examples/FunctorApplicativeMonad.lean printMonstrousAssistantToHelper}}
```

这个函数根据 `MonstrousAssistant` 的字段构造一个 `Helper`。
`@[reducible]` 属性和 `abbrev` 的作用相同。

### 默认声明

当一个结构继承另一个结构时，可以使用默认字段定义来基于子结构的字段实例化父结构的字段。
如果需要更多的尺寸特异性，那么可以使用描述尺寸的专用数据类型，结合继承使用，从而得到一个结构，其中 `large` 字段是根据 `size` 字段的内容计算得出的：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean SizedCreature}}
```

然而，这个默认定义只是一个默认定义。
与C＃或Scala等语言中的属性继承不同，子结构中的定义仅在未提供特定`large`值时使用，并且可能会导致荒谬的结果：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean nonsenseCreature}}
```

如果子结构不应偏离父结构，有几个选择：

 1. 文档化关系，就像 `BEq` 和 `Hashable` 一样
 2. 定义一个命题，表明字段之间存在适当的关系，并设计 API 要求提供关于命题为真的证据，这在关键场景中是必要的
 3. 完全不使用继承

第二个选择可能如下所示：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean sizesMatch}}
```

请注意，一个等号用来表示等式 _命题_ ，而两个等号用来表示一个检查等式并返回 `Bool` 值的函数。
`SizesMatch` 被定义为 `abbrev` ，因为它在证明中应该自动展开，这样 `simp` 可以看到应该被证明的等式。

_huldre_ 是一种中等大小的神话生物——事实上，它们与人类的大小相同。
`huldre` 上的两个大小字段是相匹配的：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean huldresize}}
```

### 类型类的继承

在幕后，类型类是一种结构。
定义一个新的类型类就定义了一个新的结构，并且定义一个实例就会创建一个该结构类型的值。
然后它们被添加到 Lean 中的内部表中，以便在需要时可以找到这些实例。
这意味着类型类可以继承其他类型类。

由于它使用了同样的语言特性，类型类继承支持结构继承的所有功能，包括多重继承、父类型方法的默认实现和钻石继承时的自动合并。
这在许多情况下与 Java、C# 和 Kotlin 等语言中的多接口继承的用途相似。
通过仔细设计类型类继承层次结构，程序员可以获得最好的两个世界：一个细粒度的可独立实现的抽象集合，以及从更大、更通用的抽象中自动构建这些具体抽象。