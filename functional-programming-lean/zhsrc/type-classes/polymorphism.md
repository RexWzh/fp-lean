# 类型类和多态性

编写可以适用于给定函数的任何重载的函数非常有用。
例如，`IO.println` 可以适用于任何具有 `ToString` 实例的类型。
这用方括号表示所需实例的类型：`IO.println` 的类型为 `{{#example_out Examples/Classes.lean printlnType}}`。
这个类型表明 `IO.println` 接受一个类型为 `α` 的参数，Lean 应该自动确定这个类型，并且必须为 `α` 提供一个 `ToString` 实例。
它返回一个 `IO` 动作。

## 检查多态函数的类型

检查带有隐式参数或使用类型类的函数的类型时，需要使用一些额外的语法。
只需简单地写上

```lean
{{#example_in Examples/Classes.lean printlnMetas}}
```

得到一个带有占位符的类型：

```output info
{{#example_out Examples/Classes.lean printlnMetas}}
```

这是因为 Lean 尽其所能发现隐式参数，而占位变量的存在表明它还没有发现足够的类型信息。
为了理解一个函数的签名，可以在函数名之前加上 at 符号（`@`）来抑制这个特性：

```lean
{{#example_in Examples/Classes.lean printlnNoMetas}}
```



```output info
{{#example_out Examples/Classes.lean printlnNoMetas}}
```

在这个输出中，该实例本身被赋予了名称“inst”。
此外，在“Type”之后有一个“u_1”，它使用了LEANS尚未介绍的一个特性。
现在，请忽略这些“Type”参数。

## 使用实例隐式定义多态函数

一个将列表中的所有项相加的函数需要两个实例：`Add`允许将项相加，并且一个`OfNat`实例为空列表提供了一个明智的返回值`0`：

```lean
{{#example_decl Examples/Classes.lean ListSum}}
```

这个函数可以用来处理一个 `Nat` 类型的列表：

```lean
{{#example_decl Examples/Classes.lean fourNats}}

{{#example_in Examples/Classes.lean fourNatsSum}}
```



```output info
{{#example_out Examples/Classes.lean fourNatsSum}}
```

但不适用于 `Pos` 数字列表：

```lean
{{#example_decl Examples/Classes.lean fourPos}}

{{#example_in Examples/Classes.lean fourPosSum}}
```



```output error
{{#example_out Examples/Classes.lean fourPosSum}}
```

方括号中列出的所需实例被称为“实例隐式”。
在幕后，每个类型类都定义了一个结构，其中每个重载操作都有一个字段。
实例是该结构类型的值，每个字段都包含一个实现。
在调用点，Lean 负责为每个实例隐式参数找到一个实例值进行传递。
普通隐式参数和实例隐式的最重要区别在于 Lean 用于查找参数值的策略。
对于普通隐式参数，Lean 使用一种称为“统一”的技术，找到一个单一的、唯一的参数值，使程序能够通过类型检查器。
这个过程仅依赖于函数定义和调用点中所涉及的具体类型。
对于实例隐式，Lean 相反会查询一个内置的实例值表。

就像“OfNat”对于“Pos”的实例需要一个自动隐式参数“n”一样，实例本身也可以接受实例隐式参数。
[关于多态的章节](../getting-to-know/polymorphism.md)中介绍了一个多态的点类型：

```lean
{{#example_decl Examples/Classes.lean PPoint}}
```

对于点而言，加法应该对应于底层的 `x` 和 `y` 字段的加法。因此，对于 `PPoint` 的 `Add` 实例需要对应于这些字段所属类型的 `Add` 实例。换句话说，`PPoint` 的 `Add` 实例需要一个额外的 `α` 的 `Add` 实例：

```lean
{{#example_decl Examples/Classes.lean AddPPoint}}
```

当 Lean 遇到两个点的相加时，它会搜索并找到这个实例。
然后，它会进一步搜索 `Add α` 的实例。

以这种方式构造的实例值是类型类结构类型的值。
成功的递归实例搜索会得到一个引用另一个结构值的结构值。
`Add (PPoint Nat)` 的实例包含了找到的 `Add Nat` 的实例的引用。

这个递归搜索过程意味着类型类比普通的重载函数提供了更大的能力。
多态实例库是一组代码构建块，编译器会按照要求的类型自动组装它们。
带有实例参数的多态函数是对类型类机制的潜在请求，以便在幕后组装辅助函数。
API 的客户端不需要手动组装所有必要的部分。

## 方法和隐式参数

`{{#example_in Examples/Classes.lean ofNatType}}` 的类型可能会让人感到惊讶。
它是 `{{#example_out Examples/Classes.lean ofNatType}}`，其中 `Nat` 类型的参数 `n` 作为显式函数参数出现。
然而，在方法的声明中，`ofNat` 的类型只是 `α`。
这种看似不一致的情况是因为声明一个类型类实际上会产生以下结果：

- 用于包含每个重载操作实现的结构类型
- 与类名相同的命名空间
- 对于每个方法，在类的命名空间中有一个函数，用于从一个实例中获取其实现

这类似于声明一个新的结构体时也会声明访问器函数。
主要的区别是结构体的访问器函数将结构体值作为显式参数，而类型类的方法将实例值作为实例隐式参数，Lean 会自动查找。

为了让 Lean 能够找到一个实例，它的参数必须是可用的。
这意味着类型类的每个参数必须是在实例之前发生的方法的参数。
当这些参数是隐式的时，它们最方便，因为 Lean 会自动发现它们的值。
例如，`{{#example_in Examples/Classes.lean addType}}` 的类型是 `{{#example_out Examples/Classes.lean addType}}`。
在这种情况下，类型参数 `α` 可以是隐式的，因为 `Add.add` 的参数提供了关于用户意图的信息。
Lean使用递归实例搜索来构建`Add`实例。
对于基础实例，Lean会检查是否存在一个类型为`OfNat N n`的构造器，其中`n`是自然数类型`Nat`的一个实例。
如果存在这样的构造器，则它可以作为`Add`实例的参数。

然而，在`ofNat`中，要解码的特定`Nat`字面量不会作为任何其他参数的一部分出现。
这意味着当尝试确定隐式参数`n`时，Lean没有可用的信息。
结果将是一个非常不方便的API。
因此，在这些情况下，Lean会为类的方法使用显式参数。

## 练习

### 偶数字面量

写一个使用递归实例搜索的`OfNat`实例，用于前一节练习中定义的偶数数据类型。
对于基础实例，需要写`OfNat Even Nat.zero`而不是`OfNat Even 0`。

### 递归实例搜索深度

Lean编译器尝试递归实例搜索的次数是有限的。
这限制了在前面的练习中定义的偶数字面量的大小。
可以进行实验以确定限制是什么。