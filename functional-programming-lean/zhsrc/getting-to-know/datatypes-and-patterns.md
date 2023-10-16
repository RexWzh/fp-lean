# 数据类型和模式

结构体能够将多个独立的数据结合在一起，形成一个全新类型的有机整体。
像结构体这样将一组值组合在一起的类型被称为*积类型*。
然而，许多领域的概念无法自然地表示为结构体。
例如，一个应用程序可能需要跟踪用户权限，其中一些用户是文件所有者，一些用户可以编辑文件，其他用户只能阅读文件。
计算器拥有许多二元运算符，例如加法、减法和乘法。
结构体并不能提供一种方便的方法来编码多个选择。

同样地，虽然结构体是一种很好的方式来跟踪一组固定的字段，但许多应用程序需要包含任意数量元素的数据。
大多数经典的数据结构，例如树和列表，都具有递归结构，其中列表的尾部本身就是一个列表，或者二叉树的左右分支本身就是二叉树。
在上述的计算器中，表达式的结构本身是递归的。
例如，加法表达式中的被加数本身可能是乘法表达式。

允许选择的数据类型称为*和类型*，可以包含自身实例的数据类型称为*递归数据类型*。
递归和类型被称为*归纳数据类型*，因为可以使用数学归纳法来证明关于它们的陈述。
在编程时，归纳数据类型通过模式匹配和递归函数来使用。

许多内建类型实际上是标准库中的归纳数据类型。
例如，`Bool` 是一个归纳数据类型：

```lean
{{#example_decl Examples/Intro.lean Bool}}
```

这个定义主要由两个部分组成。
第一行提供了新类型的名称（`Bool`），而剩下的行描述了每个构造函数。
与结构体的构造函数一样，归纳数据类型的构造函数仅仅是对其他数据的接收者和容器，而不是插入任意初始化和验证代码的地方。
与结构体不同，归纳数据类型可以有多个构造函数。
在这里，有两个构造函数，`true` 和 `false`，且两者都不接受任何参数。
与结构体声明将其名称放入以声明类型命名的命名空间中一样，归纳数据类型将其构造函数的名称放入一个命名空间中。
在 Lean 标准库中，`true` 和 `false` 从该命名空间重新导出，以便可以单独写作 `true` 和 `false`，而不需要写作 `Bool.true` 和 `Bool.false`。

从数据建模的角度来看，归纳数据类型在许多情况下与其他语言中的密封抽象类类似。
在像 C# 或 Java 这样的语言中，可以编写类似的 `Bool` 定义：

```C#
abstract class Bool {}
class True : Bool {}
class False : Bool {}
```

然而，这些表示的具体细节有相当大的不同。特别是，每个非抽象类都会创建一个新的类型和一种新的数据分配方式。在面向对象的例子中，`True` 和 `False` 都是比 `Bool` 更具体的类型，而在 Lean 定义中，只引入了新类型 `Bool`。

非负整数类型 `Nat` 是一个归纳数据类型（inductive datatype）：

```lean
{{#example_decl Examples/Intro.lean Nat}}
```

在这里，`zero`代表0，`succ`代表另一个数字的后继。
`succ`声明中提到的`Nat`是正在被定义的类型`Nat`。
“后继”意味着“比原来的数大1”，所以五的后继是六，32,185的后继是32,186。
根据这个定义，`{{#example_eval Examples/Intro.lean four 1}}` 被表示为 `{{#example_eval Examples/Intro.lean four 0}}`。
这个定义几乎就像定义`Bool`一样，只是名字稍有不同。
唯一的真正区别在于，`succ`后面跟着`(n : Nat)`，这表明构造函数`succ`接受一个名为`n`的类型为`Nat`的参数。
名称`zero`和`succ`位于以其类型命名的命名空间中，所以必须分别称为`Nat.zero`和`Nat.succ`。

参数名称，例如`n`，可能在Lean的错误消息和编写数学证明时的反馈中出现。
Lean还提供了一种可选的语法来通过名称提供参数。
然而，通常情况下，与结构字段名称相比，选择参数名称并不那么重要，因为它在API中的重要性不如结构字段名称大。 

在C＃或Java中，`Nat`可以定义为以下方式：

```C#
abstract class Nat {}
class Zero : Nat {}
class Succ : Nat {
  public Nat n;
  public Succ(Nat pred) {
	n = pred;
  }
}
```

就像之前的 `Bool` 示例一样，这定义了比 Lean 更多的类型。
此外，这个例子还突显了 Lean 的数据类型构造函数更像是抽象类的子类，而不是像 C# 或 Java 中的构造函数，因为这里的构造函数包含要执行的初始化代码。

和 TypeScript 中使用字符串标签来编码区分联合类型相似，联合类型也可以用字符串标签来实现。
在 TypeScript 中，`Nat` 可以定义如下：

```typescript
interface Zero {
    tag: "zero";
}

interface Succ {
    tag: "succ";
    predecessor: Nat;
}

type Nat = Zero | Succ;
```

就像C＃和Java一样，这种编码最终会产生比Lean更多的类型，因为`Zero`和`Succ`分别是自己的类型。
它还说明了Lean构造函数对应于JavaScript或TypeScript中包含标识内容的标签的对象。

## 模式匹配

在许多语言中，这些类型的数据首先使用instance-of运算符进行检查，以确定收到的是哪个子类，然后读取在给定子类中可用的字段的值。
instance-of检查确定要运行的代码，确保此代码所需的数据可用，而字段本身提供数据。
在Lean中，_模式匹配_同时用于这两个目的。

一个使用模式匹配的函数示例是`isZero`，它是一个在其参数为`Nat.zero`时返回`true`，否则返回`false`的函数。

```lean
{{#example_decl Examples/Intro.lean isZero}}
```

`match` 表达式接收函数的参数 `n` 用于解构。
如果 `n` 是由 `Nat.zero` 构造的，那么会执行模式匹配的第一分支，并返回 `true`。
如果 `n` 是由 `Nat.succ` 构造的，那么会执行模式匹配的第二分支，并返回 `false`。

`{{#example_eval Examples/Intro.lean isZeroZeroSteps 0}}` 的求值步骤如下：

```lean
{{#example_eval Examples/Intro.lean isZeroZeroSteps}}
```

对 `{{#example_eval Examples/Intro.lean isZeroFiveSteps 0}}` 的评估过程类似:

根据 LEAN 定理证明 (Lemma)， 对于任意一个自然数 $n$，其存在对应的归约过程，并在有限步骤内返回结果。这里给出了一个例子，`isZeroFiveSteps` 是一个函数，参数 `0` 代表起始自然数。将该例子带入到函数中，我们可以看到它的归约过程。

```lean
{{#example_eval Examples/Intro.lean isZeroFiveSteps}}
```

`isZero` 函数中第二个分支中的 `k` 不是装饰性的。
它使得 `succ` 的参数成为 `Nat` 类型可见，并指定一个名字。
这个较小的数可以用来计算表达式的最终结果。

正如某个数的继承者 \\( n \\) 是比 \\( n \\) 大一的数（即 \\( n + 1\\)），前继函数找到某个数的前继则比它小一。
如果 `pred` 是一个找到 `Nat` 前继函数，那么下面的例子应该得到预期的结果：

```lean
{{#example_in Examples/Intro.lean predFive}}
```



```output info
{{#example_out Examples/Intro.lean predFive}}
```



```lean
{{#example_in Examples/Intro.lean predBig}}
```



```output info
{{#example_out Examples/Intro.lean predBig}}
```

因为 `Nat` 无法表示负数，所以 `0` 是一个有点棘手的问题。
通常，在使用 `Nat` 进行计算时，本应产生负数的运算符被重新定义为产生 `0` 本身：

```lean
{{#example_in Examples/Intro.lean predZero}}
```



```output info
{{#example_out Examples/Intro.lean predZero}}
```

为了找到一个 `Nat` 的前身，第一步是检查创建它时使用了哪个构造函数。
如果是 `Nat.zero`，则结果是 `Nat.zero`。
如果是 `Nat.succ`，则使用名称 `k` 来引用它下面的 `Nat`。
而这个 `Nat` 就是所需的前身，所以 `Nat.succ` 分支的结果是 `k`。

```lean
{{#example_decl Examples/Intro.lean pred}}
```

将这个函数应用于 `5` 得到以下步骤：

```lean
{{#example_eval Examples/Intro.lean predFiveSteps}}
```

模式匹配可以用于结构和总和类型。
例如，一个从 `Point3D` 提取第三个维度的函数可以如下所示：

```
match point with
| Point3D(_, _, z) -> z
```

```lean
{{#example_decl Examples/Intro.lean depth}}
```

在这种情况下，使用 `z` 访问器要简单得多，但是结构模式有时是编写函数的最简单方式。

## 递归函数

对于引用正在定义的名称的定义称为 _递归定义_。
归纳数据类型允许是递归的；实际上，`Nat` 就是这样一种数据类型的例子，因为 `succ` 需要另一个 `Nat`。
递归数据类型可以表示任意大的数据，仅受可用内存等技术因素的限制。
正如不可能在数据类型定义中为每个自然数编写构造函数一样，也不可能为每种可能性编写模式匹配分支。

递归数据类型与递归函数相得益彰。
一个简单的递归函数通过检查其参数是否为偶数来运行。
在这种情况下，`zero` 是偶数。
像这种非递归代码分支被称为 _基本情况_。
奇数后继是偶数，偶数后继是奇数。
这意味着使用 `succ` 构建的数是偶数当且仅当它的参数不是偶数。

```lean
{{#example_decl Examples/Intro.lean even}}
```

这种思维模式在处理 `Nat` 的递归函数时很典型。
首先，确定对于 `zero` 需要做什么操作。
然后，确定如何将一个任意 `Nat` 的结果转换为其后继数的结果，并将这个转换应用于递归调用的结果。
这种模式被称为 _结构递归_。

与许多编程语言不同，Lean 默认确保每个递归函数最终会达到基本情况。
从编程角度来看，这样可以排除意外的无限循环。
但在证明定理时，这一特性尤为重要，因为无限循环会导致严重困难。
这导致的一个结果是，Lean 不会接受一个尝试在原始数字上递归调用自身的 `even` 函数版本：

```lean
{{#example_in Examples/Intro.lean evenLoops}}
```

这个错误信息中的重点是 Lean 无法确定递归函数总是能到达基本情况（因为实际上并不是这样）。

```output error
{{#example_out Examples/Intro.lean evenLoops}}
```

尽管加法需要两个参数，但只需检查其中一个参数。
将零加到一个数 \\( n \\) 上，直接返回 \\( n \\)。
将 \\( k \\) 的后继数加到 \\( n \\) 上，计算 \\( k \\) 与 \\( n \\) 的和的后继数。

```lean
{{#example_decl Examples/Intro.lean plus}}
```

在 `plus` 的定义中，选择了名称 `k'` 来表示它与参数 `k` 相关联，但却不相同。
例如，对 `{{#example_eval Examples/Intro.lean plusThreeTwo 0}}` 进行求值的过程如下：

```lean
{{#example_eval Examples/Intro.lean plusThreeTwo}}
```

有一种理解加法的方式是，\\( n + k \\) 将 `Nat.succ` 应用于 \\( k \\) 次到 \\( n \\) 上。
相似地，乘法 \\( n × k \\) 将 \\( n \\) 加了 \\( k \\) 次给自身，减法 \\( n - k \\) 则将 \\( n \\) 的前身 \\( k \\) 次拿走。

```lean
{{#example_decl Examples/Intro.lean times}}

{{#example_decl Examples/Intro.lean minus}}
```

并非每个函数都可以很容易地使用结构递归来编写。
把加法理解为迭代的 `Nat.succ`，乘法理解为迭代的加法，减法理解为迭代的前驱函数，则可以将除法实现为迭代的减法。
在这种情况下，如果被除数小于除数，则结果为零。
否则，结果是将被除数减去除数后再除以除数的结果的后继函数。

```lean
{{#example_in Examples/Intro.lean div}}
```

只要第二个参数不是 `0`，这个程序就会终止，因为它总是朝着基本情况取得进展。
然而，它并不是结构递归，因为它没有遵循找到零的结果和将较小的`Nat`的结果转化为其后继的结果的模式。
特别是，函数的递归调用应用于另一个函数调用的结果，而不是一个输入构造函数的参数。
因此，Lean拒绝它并给出以下信息：

```output error
{{#example_out Examples/Intro.lean div}}
```

这个消息表示 `div` 需要手动证明其终止性。
这个主题在[最后一章节](../programs-proofs/inequalities.md#division-as-iterated-subtraction)中有所探讨。