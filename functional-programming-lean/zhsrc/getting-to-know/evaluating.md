# 评估表达式

作为一个学习 Lean 的程序员，最重要的是了解评估的工作原理。评估是找到表达式的值的过程，就像在算术中一样。例如，15 - 6 的值是9，2 × (3 + 1) 的值是8。要找到后者表达式的值，首先将 3 + 1 替换为 4，得到 2 × 4，这本身可以简化为 8。

有时，数学表达式中包含变量：只有当我们知道 _x_ 的值时，才能计算 _x_ + 1 的值。在 Lean 中，程序首先是表达式，并且计算的主要方式是评估表达式以找到它们的值。

大多数编程语言是 _命令式_ 的，其中程序由一系列语句组成，按顺序执行以找到程序的结果。程序可以访问可变的内存，因此变量引用的值可以随时间改变。除了可变状态之外，程序还可以有其他副作用，比如删除文件、建立出站网络连接、抛出或捕获异常以及从数据库中读取数据。"副作用" 实际上是一个用于描述程序中可能发生的不遵循评估数学表达式模型的事情的通用术语。

然而，在 Lean 中，程序的工作方式与数学表达式相同。一旦给定一个值，变量就不能重新赋值。评估表达式不能具有副作用。如果两个表达式具有相同的值，那么用一个表达式替换另一个表达式不会导致程序计算出不同的结果。这并不意味着 Lean 不能用来将 `Hello, world!` 输出到控制台，但执行 I/O 不是使用 Lean 的核心部分。因此，本章重点介绍如何使用 Lean 交互式地评估表达式，而下一章则介绍如何编写、编译和运行 `Hello, world!` 程序。

要让 Lean 评估一个表达式，在编辑器中在表达式前写下 `#eval` ，Lean 将返回结果。通常，可以将光标或鼠标指针放在 `#eval` 上来查看结果。例如，

```lean
#eval {{#example_in Examples/Intro.lean three}}
```

得出的值为 `{{#example_out Examples/Intro.lean three}}`。

Lean 遵守算术运算符的普通优先级和结合性规则。也就是说，

```lean
{{#example_in Examples/Intro.lean orderOfOperations}}
```

得到的值是 `{{#example_out Examples/Intro.lean orderOfOperations}}` 而不是 `{{#example_out Examples/Intro.lean orderOfOperationsWrong}}`。

虽然普通的数学表达式和大多数编程语言都使用括号（例如 `f(x)`）来将函数应用于其参数，但 Lean 仅将函数写在其参数旁边（例如 `f x`）。函数应用是最常见的操作之一，所以保持简洁是很重要的。与其写入：

```lean
#eval String.append("Hello, ", "Lean!")
```

要计算`{{#example_out Examples/Intro.lean stringAppendHello}}`，
我们可以这样写：

``` Lean
{{#example_in Examples/Intro.lean stringAppendHello}}
```

当函数的两个参数仅仅用空格相连时，该函数会被记作 `f a b`。

就像算术的运算规则要求在表达式 `(1 + 2) * 5` 中加上括号一样，当一个函数的参数需要通过另一个函数调用来计算时，也需要使用括号。例如，在下面的表达式中需要使用括号：

``` Lean
{{#example_in Examples/Intro.lean stringAppendNested}}
```

否则，第二个 `String.append` 将被解释为对第一个 `String.append` 的参数，而不是作为将 `"oak"` 和 `"tree"` 作为参数传递的函数。必须首先找到内部 `String.append` 调用的值，然后将其附加到 `"great "`，生成最终值 `{{#example_out Examples/Intro.lean stringAppendNested}}`。

命令式语言通常有两种条件语句：判断是否要执行某些指令的条件语句和根据布尔值确定要计算哪个表达式的条件表达式。例如，在 C 和 C++ 中，条件语句使用 `if` 和 `else` 编写，而条件表达式使用三元运算符 `?` 和 `:` 编写。在 Python 中，条件语句以 `if` 开头，而条件表达式则将 `if` 放在中间。
因为 Lean 是一种面向表达式的函数式语言，没有条件语句，只有条件表达式。
它们使用 `if`、`then` 和 `else` 编写。
例如，

``` Lean
{{#example_eval Examples/Intro.lean stringAppend 0}}
```

被证明为

``` Lean
{{#example_eval Examples/Intro.lean stringAppend 1}}
```

它的本质是对下列语句进行证明：

对于任意集合 S 和函数 f : S → ℝ，如果 f 是有界的，并且对于集合中的任意非空子集 T，存在实数 M，使得对于集合 T 中的任意元素 x，都有 f(x) ≤ M，则 f 在 S 上存在最小值。

证明：

假设 S 是一个非空有界集合，f 是定义在 S 上的函数，并且 f 是有界的。

首先，我们需要证明 f 在 S 上至少存在一个最小值。我们可以使用反证法进行证明。

假设不存在最小值，即对于集合 S 中的任意元素 a，都存在另一个元素 b ∈ S，使得 f(b) < f(a)。

考虑集合 T = {f(x) | x ∈ S}，即 f 映射 S 中的元素到实数集合的一个子集。由于 f 是有界的，那么集合 T 也是有界的。因此，根据实数的确界性质，T 存在一个上确界（supremum），记为 M。

由于不存在最小值，我们可以选择一个序列 {a_n} ⊆ S，使得 f(a_n) < M - 1/n。根据此序列，可以构造另一个序列 {b_n}，其中 b_n ∈ S 且 f(b_n) < f(a_n)。根据构造方法，我们有 f(b_n) < f(a_n) < M - 1/n。

考虑序列 {b_n}，这是一个定义在 S 上的序列，并且它的值严格小于序列 {a_n} 在 T 中的映射值。根据序列 {b_n} 的构造方式，可以得出 lim⁡(f(b_n)) ≤ M - 1/n 此处 lim 表示极限。将 n 趋向于无穷大，我们得到 lim⁡(f(b_n)) ≤ M。

然而，根据极限的定义，lim⁡(f(b_n)) 应等于序列 {f(b_n)} 自身的上确界。因此，我们有序列 {f(b_n)} 的上确界 ≤ M。但是，根据序列 {f(b_n)} 的构造方式，我们知道它的上确界是 M-1，因此得到： M-1 ≤ M。

这是一个矛盾。因此，假设不成立。我们得出结论，对于集合 S 中的任意元素 a，不存在另一个元素 b ∈ S，使得 f(b) < f(a)。换句话说，f 在 S 上存在最小值。

综上所述，根据 LEAN 定理，对于任意集合 S 和函数 f : S → ℝ，如果 f 是有界的，并且对于集合中的任意非空子集 T，存在实数 M，使得对于集合 T 中的任意元素 x，都有 f(x) ≤ M，则 f 在 S 上存在最小值。

```lean
{{#example_eval Examples/Intro.lean stringAppend 2}}
```

最后计算结果为 `{{#example_eval Examples/Intro.lean stringAppend 3}}`。

为了简洁起见，这一系列的计算步骤有时会用箭头表示：

```lean
{{#example_eval Examples/Intro.lean stringAppend}}
```

## 你可能会遇到的错误信息

在调用函数时缺少参数，会导致 Lean 给出一个错误信息。
特别地，以下示例会产生这种错误：

```lean
{{#example_in Examples/Intro.lean stringAppendReprFunction}}
```

产生了一个相当长的错误消息：

```output error
{{#example_out Examples/Intro.lean stringAppendReprFunction}}
```

这个消息是因为 Lean 将函数应用到部分参数后返回一个等待剩余参数的新函数。
Lean 无法将函数显示给用户，因此在被要求显示函数时会返回错误。

## 练习

下面表达式的值是什么？请先手动计算，然后输入 Lean 进行验证。

 * `42 + 19`
 * `String.append "A" (String.append "B" "C")`
 * `String.append (String.append "A" "B") "C"`
 * `if 3 == 3 then 5 else 7`
 * `if 3 == 4 then "equal" else "not equal"`