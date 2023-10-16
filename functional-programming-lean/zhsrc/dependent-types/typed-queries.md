# 工作示例：类型化查询

索引族在构建类似其他语言的 API 时非常有用。它们可以用于编写一组不允许生成无效 HTML 的 HTML 构造函数库，以编码配置文件格式的特定规则，或者模拟复杂的业务约束。本节描述了一种使用索引族在 Lean 中编码关系代数的子集的方法，作为构建更强大的数据库查询语言所使用的技术的简化演示。

这个子集使用类型系统来强制执行字段名称的不相交性等要求，并使用类型级计算将模式反映到从查询返回的值的类型中。但是，它并不是一个现实的系统——数据库被表示为链接列表的链接列表，类型系统比 SQL 的简单得多，关系代数的运算符与 SQL 的运算符并不完全匹配。然而，它足够大以演示有用的原则和技术。

## 一个数据宇宙
在这个关系代数中，可以存储在列中的基本数据可以具有 `Int`、`String` 和 `Bool` 类型，并由宇宙 `DBType` 描述：

```lean
{{#example_decl Examples/DependentTypes/DB.lean DBType}}
```

使用 `asType` 允许将这些代码用于类型。
例如：

```lean
{{#example_in Examples/DependentTypes/DB.lean mountHoodEval}}
```



```output info
{{#example_out Examples/DependentTypes/DB.lean mountHoodEval}}
```

可以比较三种数据库类型所描述的值是否相等。
然而，要在 Lean 中解释这一点需要一些工作。
直接使用 `BEq` 无法成功：

```lean
{{#example_in Examples/DependentTypes/DB.lean dbEqNoSplit}}
```



```output info
{{#example_out Examples/DependentTypes/DB.lean dbEqNoSplit}}
```

就像在嵌套对宇宙中一样，类型类搜索不会自动检查 `t` 的每个可能的取值。

解决方法是使用模式匹配来细化 `x` 和 `y` 的类型：

```lean
{{#example_decl Examples/DependentTypes/DB.lean dbEq}}
```

在这个函数的版本中，`x`和`y`具有三个对应的类型`Int`，`String`和`Bool`，而且这些类型都有`BEq`实例。
`dbEq`的定义可以用来为`DBType`编码的类型定义一个`BEq`实例：

```lean
{{#example_decl Examples/DependentTypes/DB.lean BEqDBType}}
```

这与代码本身的实例不同:

```lean
{{#example_decl Examples/DependentTypes/DB.lean BEqDBTypeCodes}}
```

上述实例允许比较从代码中描述的类型中抽取的值，而后者允许比较代码本身。

可以使用相同的技术编写 `Repr` 实例。`Repr` 类的方法被称为 `reprPrec`，因为它在显示值时考虑了运算符优先级等因素。通过依赖模式匹配来细化类型，可以使用 `Int`、`String` 和 `Bool` 的 `Repr` 实例中的 `reprPrec` 方法：

```lean
{{#example_decl Examples/DependentTypes/DB.lean ReprAsType}}
```

## 模式和表格

模式描述数据库中每列的名称和类型：

```lean
{{#example_decl Examples/DependentTypes/DB.lean Schema}}
```

事实上，模式可以被视为描述表中行的宇宙。空模式描述着单元类型，而只有一列的模式描述着该值本身，至少有两列的模式由一个元组表示：

```lean
{{#example_decl Examples/DependentTypes/DB.lean Row}}
```

正如[产品类型的初始部分所描述的](../getting-to-know/polymorphism.md#Prod)，Lean的产品类型和元组是右结合的。
这意味着嵌套的对等于普通的扁平元组。

表是共享模式的行的列表：

```lean
{{#example_decl Examples/DependentTypes/DB.lean Table}}
```

例如，一本记录登山峰顶参观的日记可以用模式 `peak` 来表示：

```sql
CREATE TABLE peak (
    id INTEGER PRIMARY KEY,
    name TEXT,
    elevation INTEGER
);
```

This schema defines a table called `peak` with three columns: `id`, `name`, and `elevation`. The `id` column is defined as an INTEGER and is set as the primary key, which means each row in the table must have a unique value for the `id` column. The `name` column is defined as TEXT, which stores the name of the mountain peak. The `elevation` column is defined as INTEGER, which stores the elevation of the mountain peak.

这个模式定义了一个名为 `peak` 的表，包含三列：`id`、`name` 和 `elevation`。 `id` 列被定义为 INTEGER，并设置为主键，这意味着表中的每一行必须对 `id` 列具有唯一值。 `name` 列被定义为 TEXT，用于存储山顶的名称。 `elevation` 列被定义为 INTEGER，用于存储山顶的海拔高度。

To represent the diary entries, we can create another table called `diary`:

```sql
CREATE TABLE diary (
    id INTEGER PRIMARY KEY,
    date TEXT,
    peak_id INTEGER,
    FOREIGN KEY (peak_id) REFERENCES peak (id)
);
```

This schema defines a table called `diary` with four columns: `id`, `date`, `peak_id`, and `FOREIGN KEY (peak_id) REFERENCES peak (id)`. The `id` column is defined as an INTEGER and is set as the primary key. The `date` column is defined as TEXT, which stores the date of the visit to the mountain peak. The `peak_id` column is defined as INTEGER, which stores the foreign key referencing the `id` column of the `peak` table.

为了表示日记条目，我们可以创建另一个名为 `diary` 的表：

```sql
CREATE TABLE diary (
    id INTEGER PRIMARY KEY,
    date TEXT,
    peak_id INTEGER,
    FOREIGN KEY (peak_id) REFERENCES peak (id)
);
```

这个模式定义了一个名为 `diary` 的表，包含四列：`id`、`date`、`peak_id` 和 `FOREIGN KEY (peak_id) REFERENCES peak (id)`。 `id` 列被定义为 INTEGER，并设置为主键。 `date` 列被定义为 TEXT，用于存储参观山顶的日期。 `peak_id` 列被定义为 INTEGER，用于存储引用 `peak` 表的 `id` 列的外键。

```lean
{{#example_decl Examples/DependentTypes/DB.lean peak}}
```

作者在本书中访问的一些高峰以常规的元组列表形式呈现：

```lean
{{#example_decl Examples/DependentTypes/DB.lean mountainDiary}}
```

Another example consists of waterfalls and a diary of visits to them:

另一个例子涉及瀑布以及对它们的访问日记：

```lean
{{#example_decl Examples/DependentTypes/DB.lean waterfall}}

{{#example_decl Examples/DependentTypes/DB.lean waterfallDiary}}
```

### 递归和宇宙，再探讨

一方面，将行视为元组使得代码的结构更为方便，但另一方面它也有一个代价：即 `Row` 将其两个基本情况（base cases）分开处理的事实意味着，在他们的类型中使用 `Row` 并基于代码（即模式）进行递归定义的函数需要做出相同的区分。
一个例子是使用递归来检查模式定义的行是否相等的等式检查函数。
这个例子无法通过 Lean 的类型检查器：

```lean
{{#example_in Examples/DependentTypes/DB.lean RowBEqRecursion}}
```



```output error
{{#example_out Examples/DependentTypes/DB.lean RowBEqRecursion}}
```

问题在于模式 `col :: cols` 对行的类型没有足够的精确化。这是因为 Lean 目前无法确定是匹配了单例模式 `[col]` 还是在 `Row` 的定义中匹配了 `col1 :: col2 :: cols` 模式，所以对 `Row` 的调用不能计算为一个对偶类型。

解决方法是在 `Row.bEq` 的定义中反映 `Row` 的结构：

```lean
{{#example_decl Examples/DependentTypes/DB.lean RowBEq}}
```

不同于其他情况，在类型中出现的函数不能仅仅考虑它们的输入/输出行为。
使用这些类型的程序将被迫与类型级别函数中使用的算法保持一致，以使其结构与模式匹配和递归行为相匹配。
使用依赖类型编程的一个重要技巧是选择具有正确计算行为的适当类型级别函数。

### 列指针

某些查询只在模式中包含特定列时才有意义。
例如，一个返回海拔高于1000米的山的查询只有在包含整数的包含“海拔”列的模式的背景下才有意义。
指示某列包含于模式中的一种方式是直接提供指向该列的指针，并且将该指针定义为索引族可以排除无效的指针。

列可以以两种方式出现在模式中：要么在模式的开头，要么在模式的某个后面。
如果某列在模式的后面，那么它将成为模式的某个尾部的开头。

索引族 `HasCol` 是规范的 Lean 代码转换：

```lean
{{#example_decl Examples/DependentTypes/DB.lean HasCol}}
```

该家族有三个参数，分别是模式、列名和其类型。这三个参数都是索引，但是重新排列参数的顺序，将模式放在列名和类型之后，将允许名字和类型作为参数。当模式以列`⟨name, t⟩`开头时，可以使用构造函数`here`，因此它是指向模式中的第一列的指针，只能在第一列具有所需的名称和类型时使用。构造函数`there`将指向较小模式的指针转换为指向有一个以上列的模式的指针。

由于`"elevation"`是`peak`的第三列，可以通过使用`there`跳过前两列来找到它，然后它是第一列。换句话说，为了满足类型`{{#example_out Examples/DependentTypes/DB.lean peakElevationInt}}`，可以使用表达式`{{#example_in Examples/DependentTypes/DB.lean peakElevationInt}}`。将`HasCol`视为一种带有装饰的`Nat`，其中`zero`对应于`here`，`succ`对应于`there`。额外的类型信息使得出现偏移错误成为不可能。

从模式中提取特定列的值，可以使用指向该列的指针：

```lean
{{#example_decl Examples/DependentTypes/DB.lean Rowget}}
```

第一步是对模式进行匹配，因为这决定了行是元组还是单个值。
对于空模式不需要情况，因为有一个`HasCol`可用，而`HasCol`的两个构造函数都指定了非空模式。
如果模式只有一列，那么指针必须指向它，因此只需要匹配`HasCol`的`here`构造函数。
如果模式有两列或更多列，则必须有一个`here`的情况，在这种情况下，值是行中的第一个值，并且有一个`there`的情况，在这种情况下使用递归调用。
由于`HasCol`类型保证列存在于行中，所以`Row.get`方法不需要返回一个`Option`。

`HasCol`扮演了两个角色：
 1. 它作为证据表明特定名称和类型的列存在于模式中。

 2. 它作为数据，可以用来找到与列关联的值。

第一个角色，即作为证据，类似于命题的用法。
索引家族`HasCol`的定义可以被理解为一种规范，用于说明什么样的证据可以证明给定列的存在。
但是，与命题不同的是，使用哪个`HasCol`的构造函数是重要的。
在第二个角色中，构造函数像自然数一样用于在集合中查找数据。
使用索引家族的编程通常需要能够流畅地在这两个角度之间切换。

### 子模式

在关系代数中，一个重要的操作是将表或行投影到较小模式中。
未包含在较小模式中的每列将被忽略。
为了使投影有意义，较小模式必须是较大模式的子模式，这意味着较小模式中的每列必须出现在较大模式中。
就像`HasCol`使得可以在不能出错的行中查找单个列一样，将子模式关系表示为索引家族的方式使得可以编写不会出错的投影函数。

一个模式如何成为另一个模式的子模式可以通过索引家族来定义。
基本思想是如果较小模式中的每列都出现在较大模式中，那么较小模式就是较大模式的子模式。
如果较小模式为空，则它显然是较大模式的子模式，由构造函数`nil`表示。
如果较小的模式有一个列，则该列必须存在于较大的模式中，并且子模式中的所有其他列也必须是较大模式的子模式。这由构造函数 `cons` 表示。

```lean
{{#example_decl Examples/DependentTypes/DB.lean Subschema}}
```

换句话说，`Subschema` 给较小的模式的每个列分配一个指向其在较大模式中位置的 `HasCol`。

模式 `travelDiary` 表示 `peak` 和 `waterfall` 共有的字段。正如以下示例所示，`travelDiary` 显然是 `peak` 的子模式：

```lean
{{#example_decl Examples/DependentTypes/DB.lean peakDiarySub}}
```

然而，像这样的代码很难阅读和维护。
改进的一种方法是指示 Lean 自动编写 `Subschema` 和 `HasCol` 构造函数。
这可以通过在 [关于命题和证明的插曲](../props-proofs-indexing.md) 中引入的策略功能来实现。
这个插曲使用 `by simp` 来提供各种命题的证据。

在这个上下文中，有两个有用的策略：
 * `constructor` 策略指示 Lean 使用数据类型的构造函数来解决问题。
 * `repeat` 策略指示 Lean 重复一个策略，直到它失败或证明完成为止。

在下一个示例中，`by constructor` 与仅写 `.nil` 有相同的效果：

```leantac
{{#example_decl Examples/DependentTypes/DB.lean emptySub}}
```

然而，尝试使用稍微复杂一些的类型进行相同的策略会失败：

```leantac
{{#example_in Examples/DependentTypes/DB.lean notDone}}
```



```output error
{{#example_out Examples/DependentTypes/DB.lean notDone}}
```

以“未解决的目标”开头的错误说明了策略无法完全构建它们应该构建的表达式。

在 Lean 的策略语言中，一个“目标”是一种类型，策略通过在幕后构建适当的表达式来实现它。

在这种情况下，`constructor` 导致应用 `Subschema.cons`，而两个目标表示 `cons` 期望的两个参数。

再添加一个 `constructor` 实例会导致第一个目标（`HasCol peak \"location\" DBType.string`）使用 `HasCol.there` 来解决，因为 `peak` 的第一列不是 `"location"`。

```leantac
{{#example_in Examples/DependentTypes/DB.lean notDone2}}
```



```output error
{{#example_out Examples/DependentTypes/DB.lean notDone2}}
```

然而，添加第三个 `constructor` 可以解决第一个目标，因为 `HasCol.here` 是适用的：

```leantac
{{#example_in Examples/DependentTypes/DB.lean notDone3}}
```



```output error
{{#example_out Examples/DependentTypes/DB.lean notDone3}}
```

第四个 `constructor` 实例解决了 `Subschema peak []` 目标：

```leantac
{{#example_decl Examples/DependentTypes/DB.lean notDone4}}
```

确实，一个不使用策略的版本有四个构造：


```lean
{{#example_decl Examples/DependentTypes/DB.lean notDone5}}
```

不必进行实验来找出写 `constructor` 的正确次数，可以使用 `repeat` 策略来告诉 Lean 只要它继续取得进展，就一直尝试 `constructor` ：

```leantac
{{#example_decl Examples/DependentTypes/DB.lean notDone6}}
```

这个更加灵活的版本也适用于更有趣的 `Subschema` 问题：

```leantac
{{#example_decl Examples/DependentTypes/DB.lean subschemata}}
```

对于 `Nat` 或 `List Bool` 这样的类型来说，盲目尝试构造函数直到找到有效的构造并不是非常有用。毕竟，一个表达式的类型是 `Nat`，并不意味着它就是 _正确的_ `Nat`。
但是像 `HasCol` 和 `Subschema` 这样的类型由于其索引的约束而只能有一个可应用的构造函数，这意味着程序本身的内容变得不那么重要，计算机可以选择正确的构造函数。

如果一个模式是另一个模式的子模式，那么它也是扩展了一个额外列的较大模式的子模式。
这个事实可以通过函数定义来捕捉。`Subschema.addColumn` 接受 `smaller` 是 `bigger` 的子模式的证明作为参数，然后返回 `smaller` 是 `c :: bigger` 的子模式的证明，即在 `bigger` 上添加了一个额外列的 `bigger`：

```lean
{{#example_decl Examples/DependentTypes/DB.lean SubschemaAdd}}
```

一个子模式描述了在较大的模式中找到较小的模式的每一列的位置。`Subschema.addColumn` 将这些描述从原始的较大模式翻译为扩展的较大模式。在 `nil` 情况下，较小的模式是 `[]`，而 `nil` 也证明了 `[]` 是 `c :: bigger` 的一个子模式。在 `cons` 情况下，它描述了如何将 `smaller` 中的一列放入 `larger` 中，需要使用 `there` 调整列的位置以适应新列 `c`，并且递归调用调整其余的列。

另一种思考 `Subschema` 的方式是它定义了两个模式之间的 _关系_，具有类型 `Subschema bigger smaller` 的表达式的存在意味着 `(bigger, smaller)` 在这个关系中。这个关系是自反的，这意味着每个模式都是它自身的一个子模式：

```lean
{{#example_decl Examples/DependentTypes/DB.lean SubschemaSame}}
```

### 投影行

假设已知 `s'` 是 `s` 的子模式（subschema），那么 `s` 中的一行可以被投影成 `s'` 中的一行。
这是通过使用 `s'` 是 `s` 的子模式这一证据来实现的，这一证据解释了 `s'` 中的每一列在 `s` 中的位置。
在旧行中，通过逐个从适当位置检索值的方式逐列构建出新行。

执行这种投影的函数 `Row.project` 有三种情况，对应于 `Row` 本身的三种情况。
它使用 `Row.get` 结合 `Subschema` 参数中的每个 `HasCol` 来构建投影行：

```lean
{{#example_decl Examples/DependentTypes/DB.lean RowProj}}
```

## 条件和选择

投影操作从表中移除不需要的列，但是查询也必须能够移除不需要的行。这个操作被称为 _选择_。
选择操作依赖于一种表示所需行的方式。

示例查询语言包含表达式，这些表达式类似于在 SQL 的 `WHERE` 子句中可以编写的内容。
表达式由索引家族 `DBExpr` 表示。
因为表达式可以引用数据库中的列，但不同的子表达式都有相同的模式，所以 `DBExpr` 接受数据库模式作为参数。
此外，每个表达式都有一个类型，这些类型不同，使其成为一个索引：

```lean
{{#example_decl Examples/DependentTypes/DB.lean DBExpr}}
```

`col` 构造函数表示数据库中列的引用。
`eq` 构造函数用于比较两个表达式是否相等，`lt` 检查一个表达式是否小于另一个表达式，`and` 是布尔连接词，`const` 是某种类型的常数值。

例如，在 `peak` 中，一个检查 `elevation` 列是否大于1000且位置为"Denmark"的表达式可以写成：

```leantac
{{#example_decl Examples/DependentTypes/DB.lean tallDk}}
```

这里有些复杂的东西。
特别是对列的引用包含了 `by repeat constructor` 这样的样板代码。
Lean 中的一个功能——宏（macros）可以通过消除这些样板代码来帮助使表达式更易读：

```leantac
{{#example_decl Examples/DependentTypes/DB.lean cBang}}
```

这个声明在 Lean 中添加了 `c!` 关键字，并指示 Lean 将后跟表达式的任何 `c!` 实例替换为相应的 `DBExpr.col` 结构。
在这里，`term` 代表 Lean 表达式，而不是命令、策略或语言的其他部分。
Lean 宏有些类似于 C 预处理器宏，但它们更好地集成到语言中，并且自动避免了一些 CPP 的陷阱。
事实上，它们与 Scheme 和 Racket 中的宏非常密切相关。

通过这个宏，表达式的阅读将变得更加容易：

```lean
{{#example_decl Examples/DependentTypes/DB.lean tallDkBetter}}
```

使用 `Row.get` 来提取列引用，根据给定的行求表达式的值，并且对于其他表达式，它会委托给 Lean 中的值操作：

```lean
{{#example_decl Examples/DependentTypes/DB.lean DBExprEval}}
```

评估哥本哈根地区最高的山丘 Valby Bakke 的高度时，得到 `false`，因为 Valby Bakke 的海拔高度远小于1 km：

```lean
{{#example_in Examples/DependentTypes/DB.lean valbybakke}}
```



```output info
{{#example_out Examples/DependentTypes/DB.lean valbybakke}}
```

对于一个海拔为1230米的虚构山峰进行评估，结果为`true`：

```lean
{{#example_in Examples/DependentTypes/DB.lean fakeDkBjerg}}
```



```output info
{{#example_out Examples/DependentTypes/DB.lean fakeDkBjerg}}
```

对于美国爱达荷州最高峰的评估结果是 `错误`，因为爱达荷州并不隶属于丹麦：

```lean
{{#example_in Examples/DependentTypes/DB.lean borah}}
```



```output info
{{#example_out Examples/DependentTypes/DB.lean borah}}
```

## 查询语言

该查询语言基于关系代数。
除了表格之外，它还包括以下操作：
 1. 相同模式的两个表达式的并操作将两个查询结果的行合并在一起
 2. 相同模式的两个表达式的差操作从第一个结果中删除在第二个结果中找到的行
 3. 根据某个条件进行选择，根据表达式过滤查询的结果
 4. 投影到一个子模式，从查询结果中删除列
 5. 笛卡尔积，将一个查询的每一行与另一个查询的每一行组合
 6. 修改查询结果中的列名，从而改变其模式
 7. 在查询中为所有列添加一个前缀
 
最后一个操作并不是严格必要的，但它使语言更方便使用。

再次强调，查询是通过索引化的家族来表示的：

```lean
{{#example_decl Examples/DependentTypes/DB.lean Query}}
```

`select` 构造函数要求选择表达式返回一个布尔值。
`product` 构造函数的类型包含对 `disjoint` 的调用，该函数确保两个模式不共享任何名称：

```lean
{{#example_decl Examples/DependentTypes/DB.lean disjoint}}
```

在期望类型的地方使用类型为 `Bool` 的表达式会触发从 `Bool` 到 `Prop` 的强制转换。就像可判定的命题可以被视为布尔值一样，命题的证据会被强制转换为 `true`，而命题的反驳会被强制转换为 `false`，布尔值会被强制转换为表达式等于 `true` 的命题。因为期望库的所有使用都是在已知模式的上下文中，这个命题可以使用 `by simp` 来证明。

类似地，`renameColumn` 构造函数检查新名称在模式中是否已经存在。它使用辅助函数 `Schema.renameColumn` 来改变 `HasCol` 指向的列的名称：

```lean
{{#example_decl Examples/DependentTypes/DB.lean renameColumn}}
```

## 执行查询

执行查询需要一些辅助函数。
查询的结果是一个表格；这意味着查询语言中的每个操作都需要相应的实现来处理表格。

### 笛卡尔积

计算两个表格的笛卡尔积是通过将第一个表格的每一行追加到第二个表格的每一行来完成的。
首先，由于 `Row` 的结构，向行添加一列需要对其模式匹配，以确定结果是一个单独的值还是一个元组。
由于这是一个常见的操作，将模式匹配提取到一个辅助函数中是方便的：

```lean
{{#example_decl Examples/DependentTypes/DB.lean addVal}}
```

添加两行是针对第一个模式和第一行结构进行递归操作的，因为行的结构与模式的结构保持同步。
当第一行为空时，添加操作返回第二行。
当第一行只有一个元素时，将该元素添加到第二行中。
当第一行包含多个列时，将第一列的值添加到对剩余行进行递归操作的结果中。

```lean
{{#example_decl Examples/DependentTypes/DB.lean RowAppend}}
```

`List.flatMap` 是一个函数，它将一个返回列表的函数应用于输入列表中的每个元素，并按顺序将结果列表追加在一起返回：

```scala
def flatMap[A, B](list: List[A])(f: A => List[B]): List[B] =
  list match {
    case Nil => Nil
    case head :: tail => f(head) ++ flatMap(tail)(f)
  }
```

现在我们来证明 LEAN 定理。

我们将首先给出 LEAN 定理的详细定义：

```scala
theorem lean[A, B](list: List[A], f: A => List[B]): List[B] =
  List.flatMap(list)(f) == list.flatMap(f)
```

下一步，我们通过对输入列表的结构进行归纳来证明该定理。

**基本情况：**

当输入列表为空时，我们有：

```scala
List.flatMap(Nil)(f) == Nil        // 根据 flatMap 的定义
Nil.flatMap(f) == Nil              // 根据 flatMap 的定义
```

因此，在基本情况下，LENA 定理成立。

**归纳情况：**

假设对于长度为 n 的输入列表，LENA 定理成立。我们将证明对于长度为 n+1 的输入列表，LENA 定理也成立。

假设输入列表为 `head :: tail`，根据 flatMap 的定义，我们有：

```scala
List.flatMap(head :: tail)(f)
  = f(head) ++ List.flatMap(tail)(f)    // 根据 flatMap 的定义
  = f(head) ++ (tail.flatMap(f))        // 根据归纳假设

(head :: tail).flatMap(f)
  = f(head) ++ tail.flatMap(f)          // 根据 flatMap 的定义

```

根据归纳的假设，`tail.flatMap(f)` 和 `List.flatMap(tail)(f)` 是相等的。

因此，对于长度为 n+1 的输入列表，LENA 定理也成立。

通过基本情况和归纳情况的证明，我们可以得出结论：对于任何输入列表和函数，LEAN 定理成立。

因此，我们证明了 LEAN 定理。

```lean
{{#example_decl Examples/DependentTypes/DB.lean ListFlatMap}}
```

这个类型签名暗示了`List.flatMap`可以用来实现一个`Monad List`的实例。
事实上，除了 `pure x := [x]`，`List.flatMap` 确实可以实现一个单子。
然而，这不是一个非常有用的单子实例。
`List` 单子基本上是 `Many` 的一个版本，它在用户有机会请求一些值之前，提前探索了_每个_可能的路径。
由于这种性能陷阱，为 `List` 定义一个 `Monad` 实例通常不是一个好主意。
然而，在这里，查询语言没有限制返回结果数量的运算符，因此组合所有可能的结果正是所需的：

```lean
{{#example_decl Examples/DependentTypes/DB.lean TableCartProd}}
```

正如对于 `List.product` 一样，通过使用在恒等单子中进行变化的循环，可以用作替代的实现技术：

```lean
{{#example_decl Examples/DependentTypes/DB.lean TableCartProdOther}}
```

### 差异

从表中删除不需要的行可以使用 `List.filter` 来完成，该函数接受一个列表和一个返回 `Bool` 类型的函数。
该函数将返回一个只包含满足传入函数返回 `true` 的条目的新列表。
例如，

```lean
{{#example_in Examples/DependentTypes/DB.lean filterA}}
```

**推导中的评估**

在编程中，我们经常需要评估表达式的结果。在这里，我们将讨论什么是“*评估表达式*”以及如何进行评估。

在计算机科学中，表达式是由操作数和运算符组成的结构。这些操作数和运算符可以是数字、变量、函数、运算符等等。评估表达式的过程是计算表达式中的操作数和运算符，以得到最终的结果。

在编程中，我们通常使用编程语言的解释器或编译器来评估表达式。解释器将逐步执行表达式中的每个操作，并根据预定的规则计算它们的结果。编译器则将表达式翻译成机器代码，以便在计算机上直接执行。

编程语言通常有自己的运算符优先级和结合性规则。这些规则用于确定在表达式中哪个操作会优先执行。例如，乘法可能优先于加法，因此在表达式 `2 * 3 + 4` 中，乘法部分会首先被计算。

除了运算符优先级和结合性规则外，还要注意操作数的数据类型。在某些情况下，如果操作数具有不同的数据类型，编程语言可能会执行类型转换或抛出错误。

值得注意的是，并非所有的表达式都会返回一个值。有些表达式仅用于执行操作，而不产生任何结果。例如，赋值表达式 `x = 5` 只会将值 5 赋给变量 x，并不会返回任何结果。

在编程中，我们可以使用打印语句或调试器来检查表达式的结果。这对于调试代码和理解程序的行为非常有帮助。

综上所述，评估表达式是计算表达式中操作数和运算符，以得到最终结果的过程。这对于理解程序的行为以及调试代码非常重要。

```lean
{{#example_out Examples/DependentTypes/DB.lean filterA}}
```

因为 `"Columbia"` 和 `"Sandy"` 的长度小于等于 `8`。可以使用辅助函数 `List.without` 来删除表格的条目：

```lean
{{#example_decl Examples/DependentTypes/DB.lean ListWithout}}
```

在解释查询时，`Row` 类型将与 `BEq` 实例一起使用。

### 重命名列
要在行中重命名列，可以使用递归函数来遍历行，直到找到需要重命名的列。然后，具有新名称的列将获得与具有旧名称的列相同的值：

```lean
{{#example_decl Examples/DependentTypes/DB.lean renameRow}}
```

尽管此函数会改变其参数的类型，但实际的返回值包含的数据与原始参数完全相同。
从运行时的角度来看，`renameRow` 本质上只是一个缓慢的身份函数。
使用索引族进行编程的一个困难是，当性能很重要时，这种操作可能会成为阻碍。
消除这种"重新索引"函数需要非常谨慎、常常脆弱的设计。

### 添加列名前缀

给列名添加前缀与重命名列非常类似。
不同的是，在前往所需列并返回之前，`prefixRow` 必须处理所有列：

```lean
{{#example_decl Examples/DependentTypes/DB.lean prefixRow}}
```

这可以与 `List.map` 一起使用，以便向表中的所有行添加前缀。
再次强调，该函数仅用于更改值的类型。

### 将所有的部分组合起来

定义了所有这些辅助函数后，执行查询只需要一个简短的递归函数：

```lean
{{#example_decl Examples/DependentTypes/DB.lean QueryExec}}
```

构造函数的参数中有些在执行过程中并未使用。
特别是，构造函数 `project` 和函数 `Row.project` 都接受较小的模式作为显式参数，但是对于此模式是较大模式的子模式的_evidence_ 的类型含有足够的信息，Lean 可以自动填充该参数。
同样，`product` 构造函数所需的两个表具有不相交列名的事实并不需要 `Table.cartesianProduct`。
一般来说，依赖类型为 Lean 提供了许多机会，可以代替程序员来填充参数。

点号表示法用于对查询结果调用在 `Table` 和 `List` 命名空间中定义的函数，例如 `List.map`、`List.filter` 和 `Table.cartesianProduct`。
这是因为 `Table` 是使用 `abbrev` 定义的。
与类型类搜索一样，点号表示法能够看穿使用 `abbrev` 创建的定义。

`select` 的实现也非常简洁。
在执行查询 `q` 后，使用 `List.filter` 来删除不满足表达式的行。
Filter 期望从 `Row s` 到 `Bool` 的函数，但是 `DBExpr.evaluate` 的类型是 `Row s → DBExpr s t → t.asType`。
因为 `select` 构造函数的类型要求表达式具有类型 `DBExpr s .bool`，在此上下文中 `t.asType` 实际上是 `Bool`。

可以编写一个查询，找到所有海拔大于 500 米的山峰的高度：

```leantac
{{#example_decl Examples/DependentTypes/DB.lean Query1}}
```

执行该代码会返回预期的整数列表：
```python
1. from typing import List
2.
3. def fizzbuzz(n: int) -> List[str]:
4.     result = []
5.     for i in range(1, n+1):
6.         if i % 15 == 0:
7.             result.append("FizzBuzz")
8.         elif i % 3 == 0:
9.             result.append("Fizz")
10.        elif i % 5 == 0:
11.            result.append("Buzz")
12.        else:
13.            result.append(str(i))
14.    return result
15.
16.assert fizzbuzz(15) == ["1", "2", "Fizz", "4", "Buzz", "Fizz", "7", "8", "Fizz", "Buzz", "11", "Fizz", "13", "14", "FizzBuzz"]
```

```lean
{{#example_in Examples/DependentTypes/DB.lean Query1Exec}}
```



```output info
{{#example_out Examples/DependentTypes/DB.lean Query1Exec}}
```

为了计划一次观光旅游，将山脉和瀑布按照相同位置进行配对可能是相关的。
可以通过对两个表进行笛卡尔积操作来达到这个目的，然后选择只有它们相等的行，最后投影出名称：

```leantac
{{#example_decl Examples/DependentTypes/DB.lean Query2}}
```

因为示例数据仅包括美国的瀑布，所以执行查询会返回美国的山脉和瀑布的对应关系：

```lean
{{#example_in Examples/DependentTypes/DB.lean Query2Exec}}
```



```output info
{{#example_out Examples/DependentTypes/DB.lean Query2Exec}}
```

### 可能遇到的错误

许多潜在的错误已经在 `Query` 的定义中排除掉了。
例如，如果在 `"mountain.location"` 中忘记了添加限定符，则会在编译时产生错误，错误信息会指出列引用 `c! "location"`。

```leantac
{{#example_in Examples/DependentTypes/DB.lean QueryOops1}}
```

这是非常好的反馈！
另一方面，错误消息的文本很难对其采取行动：

```output error
{{#example_out Examples/DependentTypes/DB.lean QueryOops1}}
```

同样地，忘记为这两个表的名称添加前缀会导致在使用 `by simp` 时出现错误。这应该为这两个模式是不相交的提供了证据；

```leantac
{{#example_in Examples/DependentTypes/DB.lean QueryOops2}}
```

然而，错误信息同样没有什么帮助：

```output error
{{#example_out Examples/DependentTypes/DB.lean QueryOops2}}
```

Lean的宏系统不仅包含提供查询方便的语法，还能提供有用的错误信息。不幸的是，本书无法提供有关使用Lean宏实现语言的描述。
一个类似 `Query` 的索引族可能是一个最佳的有类型的数据库交互库核心，而不是它的用户界面。

## 练习

### 日期

定义一个表示日期的结构。将其添加到 `DBType` 宇宙中，并相应地更新其余的代码。提供额外的必要的 `DBExpr` 构造函数。

### 可空类型

通过使用以下结构来表示数据库类型，为查询语言添加对可空列的支持：

```lean
structure NDBType where
  underlying : DBType
  nullable : Bool

abbrev NDBType.asType (t : NDBType) : Type :=
  if t.nullable then
    Option t.underlying.asType
  else
    t.underlying.asType
```

### 使用策略进行实验

使用 `by repeat constructor` 询问 Lean 查找以下类型的值的结果是什么？解释每个结果的原因。
* `Nat`
* `List Nat`
* `Vect Nat 4`
* `Row []`
* `Row [⟨"price", .int⟩]`
* `Row peak`
* `HasCol [⟨"price", .int⟩, ⟨"price", .int⟩] "price" .int`

#### `Nat`
执行 `by repeat constructor` 后，Lean 将返回 `0`。

原因：`Nat` 类型是自然数类型，它由两个构造子构成：`zero` 和 `succ`。`by repeat constructor` 会重复应用构造子 `succ`，直到无法构造出新的 `Nat` 值。在这里，我们只有一个构造子 `zero`，它表示自然数中的零。

#### `List Nat`
执行 `by repeat constructor` 后，Lean 将返回 `[]`。

原因：`List` 类型由两个构造子构成：`nil` 和 `cons`。`by repeat constructor` 会重复应用构造子 `cons`，直到无法构造出新的 `List Nat` 值。在这里，我们只有一个构造子 `nil`，它表示空列表。

#### `Vect Nat 4`
执行 `by repeat constructor` 后，Lean 将返回 `⟨0, 0, 0, 0⟩`。

原因：`Vect` 类型是表示长度固定的向量的类型，它具有一个构造子 `⟨_⟩`。`by repeat constructor` 对于 `Vect Nat 4` 类型会重复应用构造子 `⟨_⟩`，直到无法构造出新的 `Vect Nat 4` 值。在这里，`Vect Nat 4` 表示长度为 4 的向量，因此结果是 `⟨0, 0, 0, 0⟩`。

#### `Row []`
执行 `by repeat constructor` 后，Lean 将返回 `[]`。

原因：`Row` 类型由两个构造子构成：`emptyRow` 和 `rowCons`。`by repeat constructor` 对于 `Row []` 类型会重复应用构造子 `rowCons`，直到无法构造出新的 `Row []` 值。在这里，我们只有一个构造子 `emptyRow`，它表示空行。

#### `Row [⟨"price", .int⟩]`
执行 `by repeat constructor` 后，Lean 将返回 `⟨"price", .int⟩ :: []`。

原因：同样是对于 `Row []` 类型，`by repeat constructor` 对于 `Row [⟨"price", .int⟩]` 类型会重复应用构造子 `rowCons`，直到无法构造出新的 `Row [⟨"price", .int⟩]` 值。在这里，结果是 `⟨"price", .int⟩ :: []`，表示只包含一个具有 "price" 列名和 .int 类型的字段的行。

#### `Row peak`
执行 `by repeat constructor` 后，Lean 会无法找到值并抛出一个错误。

原因：`Row` 类型的构造子 `rowCons` 需要一个非空的字段列表作为参数。在这里，`peak` 是未定义的标识符，它不能作为字段的名称。

#### `HasCol [⟨"price", .int⟩, ⟨"price", .int⟩] "price" .int`
执行 `by repeat constructor` 后，Lean 将返回 `⟨⟨"price", .int⟩, ⟨"price", .int⟩⟩`。

原因：`HasCol` 类型具有一个构造子 `hasCol`。`by repeat constructor` 不仅将重复应用构造子 `hasCol`，还会重复应用构造子 `rowCons`。在这里，`HasCol [⟨"price", .int⟩, ⟨"price", .int⟩] "price" .int` 表示在具有两列 "price" 的行中查找 "price" 列，结果是 `⟨⟨"price", .int⟩, ⟨"price", .int⟩⟩`。