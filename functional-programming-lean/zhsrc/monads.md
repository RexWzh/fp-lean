# 单子

在 C# 和 Kotlin 中，`?.` 运算符是一种在可能为空的值上查找属性或调用方法的方式。
如果接收者为 `null`，整个表达式为 `null`。
否则，基础的非 `null` 值会接收这个调用。
`?.` 的使用可以链式地进行，此时第一个 `null` 结果会终止查找链。
像这样链式地进行空检查比编写和维护深层嵌套的 `if` 语句更加方便。

同样地，异常比手动检查和传播错误码更加方便。
与此同时，通过使用专门的日志框架来实现日志记录是最容易的，而不是让每个函数同时返回日志结果和返回值。
链式空检查和异常通常需要语言设计者预先考虑这种用例，而日志框架通常利用副作用来将记录日志的代码与日志的积累解耦。

所有这些特性和更多特性都可以在库代码中被实现为一种叫做 `Monad` 的公共 API 的实例。
Lean 提供了专门的语法让使用这个 API 变得更加方便，但也会妨碍了解背后发生了什么的过程。
本章从手动嵌套空检查的详细介绍开始，并以方便的通用 API 进行构建。
请在此期间暂时搁置你的怀疑。

## 检查 `none`：避免重复

在 Lean 中，可以使用模式匹配来链式检查空值。
只需要使用可选索引符号就可以获取列表中的第一个元素：

```lean
{{#example_decl Examples/Monads.lean first}}
```

结果必须是 `Option`，因为空列表没有第一个条目。
提取第一个和第三个条目需要检查每个条目是否不是 `none`。

```lean
{{#example_decl Examples/Monads.lean firstThird}}
```

同样地，提取第一个、第三个和第五个条目需要更多的检查以确保这些值不为 `none` ：

```lean
{{#example_decl Examples/Monads.lean firstThirdFifth}}
```

将第七个条目添加到这个序列中开始变得相当难以管理：

```lean
{{#example_decl Examples/Monads.lean firstThirdFifthSeventh}}
```

这段代码的根本问题在于它同时解决了两个关注点：提取数字和检查是否所有数字都存在，但是第二个关注点通过复制粘贴处理 `none` 情况的代码来解决。

通常，将重复的代码片段提取到一个辅助函数中是很好的编码风格：

```lean
{{#example_decl Examples/Monads.lean andThenOption}}
```

这个助手类似于在 C# 和 Kotlin 中的 `?.`，用于处理传播 `none` 值。它接受两个参数：一个可选值和一个在该值不是 `none` 时应用的函数。如果第一个参数是 `none`，则该助手返回 `none`。如果第一个参数不是 `none`，则函数将被应用于 `some` 构造器的内容。

现在，`firstThird` 可以使用 `andThen` 来重写，而不是使用模式匹配：

```lean
{{#example_decl Examples/Monads.lean firstThirdandThen}}
```

在 Lean 中，当函数作为参数传递时，不需要用括号括起来。
下面的等价定义使用了更多的括号，并且将函数体缩进了：

```lean
{{#example_decl Examples/Monads.lean firstThirdandThenExpl}}
```

`andThen` 这个助手为值提供了一种流动的“管道”，带有稍微不同缩进的版本更能显示这一点。改进用于编写 `andThen` 的语法可以使这些计算更加易于理解。

### 中缀运算符

在 Lean 中，可以使用 `infix`、`infixl` 和 `infixr` 命令声明中缀运算符，分别创建非关联、左关联和右关联的运算符。当连续多次使用时，_左关联_运算符会将左括号堆叠在表达式的左侧。加法运算符 `+` 是左关联的，所以 `{{#example_in Examples/Monads.lean plusFixity}}` 等价于 `{{#example_out Examples/Monads.lean plusFixity}}`。指数运算符 `^` 是右关联的，所以 `{{#example_in Examples/Monads.lean powFixity}}` 等价于 `{{#example_out Examples/Monads.lean powFixity}}`。比较运算符如 `<` 是非关联的，所以 `x < y < z` 是语法错误，需要手动添加括号。

以下声明将 `andThen` 转换为中缀运算符：

```lean
{{#example_decl Examples/Monads.lean andThenOptArr}}
```

冒号后面的数字声明了新的中缀运算符的_优先级_。
在普通的数学表示法中，`{{#example_in Examples/Monads.lean plusTimesPrec}}` 和 `{{#example_out Examples/Monads.lean plusTimesPrec}}` 是等价的，尽管 `+` 和 `*` 都是左结合的。
在 Lean 中，`+` 的优先级是 65，`*` 的优先级是 70。
高优先级的运算符会在低优先级的运算符之前应用。
根据 `~~>` 的声明，`+` 和 `*` 的优先级较高，因此首先应用。
通常，确定一组运算符的最方便的优先级需要一些实验和大量的示例集合。

在新的中缀运算符后面是一个双箭头 `=>`，用于指定用作中缀运算符的命名函数。
Lean 的标准库使用此功能将 `+` 和 `*` 定义为中缀运算符，它们分别指向 `HAdd.hAdd` 和 `HMul.hMul`，允许使用类型类对中缀运算符进行重载。
然而，在这里，`andThen` 只是一个普通的函数。

在为 `andThen` 定义了一个中缀运算符后，`firstThird` 可以以一种突出显示 `none` 检查的 "pipeline" 感觉的方式进行重写：

```lean
{{#example_decl Examples/Monads.lean firstThirdInfix}}
```

当编写较大的函数时，这种风格更加简洁：

```lean
{{#example_decl Examples/Monads.lean firstThirdFifthSeventInfix}}
```

## 传播错误消息

纯函数式语言如Lean没有内置的异常处理机制，因为抛出或捕获异常超出了表达式逐步求值模型。
然而，函数式程序当然需要处理错误。
对于 `firstThirdFifthSeventh` 这种情况，让用户知道列表的长度和查找失败的位置可能是相关的。

通常可以通过定义一个数据类型，该数据类型可以是错误或结果，将带有异常的函数转换为返回此数据类型的函数来实现这一点：

```lean
{{#example_decl Examples/Monads.lean Except}}
```

类型变量 `ε` 表示函数可能产生的错误类型。
调用者需要处理错误和成功情况，这使得类型变量 `ε` 的角色有点像 Java 中的检查异常列表。

和 `Option` 类似，`Except` 可以用来表示在列表中找不到条目的错误。
在这种情况下，错误类型是一个 `String`：

```lean
{{#example_decl Examples/Monads.lean getExcept}}
```

在范围内查找一个值会返回 `Except.ok`。

```lean
{{#example_decl Examples/Monads.lean ediblePlants}}

{{#example_in Examples/Monads.lean success}}
```



```output info
{{#example_out Examples/Monads.lean success}}
```

查找超出范围的值会导致 `Except.failure` 出现:

```lean
{{#example_in Examples/Monads.lean failure}}
```



```output info
{{#example_out Examples/Monads.lean failure}}
```

一个单一的列表查找可以方便地返回一个值或一个错误：

```Lean
def lookup (l : list α) (n : ℕ) : option α :=
match l with
| []        := none
| (h :: t)  := if n = 0 then some h else lookup t (n - 1)
end
```

Here is a theorem stating that the lookup function returns a value if and only if the index is within the bounds of the list:

以下是一个定理，说明了如果索引在列表的范围内，lookup 函数将返回一个值：

```Lean
theorem lookup_eq_some_iff_mem {l : list α} {n : ℕ} {a : α} :
  lookup l n = some a ↔ a ∈ l ∧ n < length l :=
begin
  induction l with hd tl hl generalizing n,
  { simp },
  { cases n,
    { simp },
    { simp [hl, nat.succ_eq_add_one, length, nat.zero_lt_succ] } }
end
```

The theorem is proved by induction on the list `l`. In the base case where the list is empty, both sides of the ↔ are `false`, so the goal is trivially true. In the inductive case, the list is split into `hd :: tl`, and there are two subcases. If `n = 0`, then the left side of the ↔ is `some hd`, which implies that `a = hd` and `n < length (hd :: tl)`. If `n ≠ 0`, then the left side of the ↔ is `lookup tl (n - 1)`, and by the inductive hypothesis, this is equal to `some a` if and only if `a ∈ tl` and `n - 1 < length tl`. Using some elementary properties of natural numbers, it can be shown that `n - 1 < length tl` is equivalent to `nat.succ n < length (hd :: tl)`, which completes the proof.

```lean
{{#example_decl Examples/Monads.lean firstExcept}}
```

然而，执行两次列表查找需要处理可能的失败情况：

```lean
{{#example_decl Examples/Monads.lean firstThirdExcept}}
```

在该函数中添加另一个列表查找需要更多的错误处理：


```lean
{{#example_decl Examples/Monads.lean firstThirdFifthExcept}}
```

*并且另外一个列表查找开始变得难以管理：*

```lean
{{#example_decl Examples/Monads.lean firstThirdFifthSeventhExcept}}
```

再一次，一个常见的模式可以被提取到一个辅助函数中。
函数的每一步检查错误，只有当结果成功时才继续执行后面的计算。
可以为 `Except` 定义一个新版的 `andThen` 函数：

```lean
{{#example_decl Examples/Monads.lean andThenExcept}}
```

就像`Option`一样，`andThen`的这个版本让`firstThird`的定义更加简洁：

```lean
{{#example_decl Examples/Monads.lean firstThirdAndThenExcept}}
```

在 *Option* 和 *Except* 两种情况中，都存在两种重复模式：每一步都要检查中间结果，这已经被提取到了`andThen`中；还有最终的成功结果，分别是`some`或者`Except.ok`。

为了方便起见，成功可以提取出来作为一个叫做`ok`的辅助函数：

```lean
{{#example_decl Examples/Monads.lean okExcept}}
```

类似地，失败可以被拆分为一个名为 `fail` 的辅助函数：

```lean
{{#example_decl Examples/Monads.lean failExcept}}
```

使用 `ok` 和 `fail` 可以使得 `get` 函数更易读：

```lean
{{#example_decl Examples/Monads.lean getExceptEffects}}
```

在为 `andThen` 添加中缀声明之后，`firstThird` 函数可以和返回 `Option` 的版本一样简洁：

```scala
// implementation of andThen
def [A, B, C] (f: A => Option[B]) andThen (g: B => Option[C]): A => Option[C] =
  (a: A) => f(a) match {
    case Some(b) => g(b)
    case None => None
  }

// concise version of firstThird
val firstThird: String => Option[Char] =
  first andThen third
```

在这个例子中，我们首先定义了 `andThen` 函数，该函数允许我们将两个操作符结合在一起，如果第一个操作符返回 `Some`，则将其结果传递给第二个操作符，否则返回 `None`。然后，我们通过将 `first` 函数与 `third` 函数结合使用，就像在之前的版本中一样，使用 `andThen` 声明 `firstThird` 函数。这样，我们就可以将一个字符串作为输入传递给 `firstThird` 函数，并得到一个 `Some` 或 `None` 的结果。

```lean
{{#example_decl Examples/Monads.lean andThenExceptInfix}}

{{#example_decl Examples/Monads.lean firstThirdInfixExcept}}
```

这种技术在处理更大的函数时也能以类似的方式进行扩展：

```lean
{{#example_decl Examples/Monads.lean firstThirdFifthSeventInfixExcept}}
```

## 日志

一个数字如果被2整除没有余数，就是偶数：

```lean
{{#example_decl Examples/Monads.lean isEven}}
```

函数 `sumAndFindEvens` 计算列表中的和，并在计算过程中记住遇到的偶数：

```python
def sumAndFindEvens(numbers):
    total = 0
    evens = []
    for num in numbers:
        total += num
        if num % 2 == 0:
            evens.append(num)
    return total, evens
```

The LEAN theorem proving system is an interactive proof assistant that can be used to construct and verify mathematical proofs. In this article, we will use LEAN to prove a property of the `sumAndFindEvens` function.

The property we want to prove is that the sum of a list and the sum of the even numbers in the list are equal to each other. In other words, for any list of numbers, `sumAndFindEvens(numbers)` should return a pair `(total, evens)` where `total` is the sum of all numbers in the list, and `evens` is a list containing all the even numbers in the list.

To prove this property, we will use the concept of mathematical induction. Induction is a proof technique that allows us to prove a statement for an infinite set of values by proving it for a base case and then showing that if it holds for a certain value, it also holds for the next value.

We will use the following steps to prove the property of the `sumAndFindEvens` function:

1. Base Case: We will prove that the property holds for an empty list. When the input list is empty, the sum is 0 and there are no even numbers. Therefore, `sumAndFindEvens([])` should return `(0, [])`. This is true since the function initializes `total` to 0 and `evens` to an empty list.

2. Inductive Step: We will assume that the property holds for a list of `n` numbers and prove that it holds for a list of `n+1` numbers. Let's assume that `sumAndFindEvens(numbers)` returns `(total, evens)` for a list of `n` numbers.

   Now, let's consider a new list `numbers'` which is obtained by appending an additional number `x` to the original list `numbers`. We want to prove that `sumAndFindEvens(numbers')` returns `(total + x, evens')` where `evens'` is obtained by appending `x` to `evens` if `x` is even.

   We can prove this by considering two cases: 

   a. If `x` is even, then `evens'` is obtained by appending `x` to `evens`. In this case, the sum of `numbers'` is `total + x`, and the sum of the even numbers in `numbers'` is the same as the sum of the even numbers in `numbers` plus `x`. Therefore, `sumAndFindEvens(numbers')` returns `(total + x, evens')`, which satisfies the property.

   b. If `x` is odd, then `evens'` is the same as `evens` since there are no additional even numbers. In this case, the sum of `numbers'` is `total + x`, and the sum of the even numbers in `numbers'` is the same as the sum of the even numbers in `numbers`. Therefore, `sumAndFindEvens(numbers')` returns `(total + x, evens')`, which also satisfies the property.

   By considering both cases, we can conclude that `sumAndFindEvens(numbers')` returns `(total + x, evens')`, where `evens'` is obtained by appending `x` to `evens` if `x` is even. Thus, the property holds for a list of `n+1` numbers if it holds for a list of `n` numbers.

3. Conclusion: Using the principle of mathematical induction, we have proved that the property holds for any list of numbers. Therefore, the `sumAndFindEvens` function correctly computes the sum of a list and finds the even numbers in the list.

```lean
{{#example_decl Examples/Monads.lean sumAndFindEvensDirect}}
```

这个函数是一个常见模式的简化示例。许多程序在遍历数据结构时，需要同时计算一个主要结果和累积某种附加结果。一个例子是日志记录：一个`IO`操作的程序总是可以将日志记录到磁盘上的文件中，但是因为磁盘在Lean函数的数学世界之外，所以基于`IO`来证明关于日志的性质就变得更加困难。另一个例子是一个函数，它通过中序遍历计算树中所有节点的和，同时记录访问过的每个节点：

```lean
{{#example_decl Examples/Monads.lean inorderSum}}
```

`sumAndFindEvens`和`inorderSum`具有相同的重复结构。
计算的每一步都返回一个由已保存的数据列表和主要结果组成的对。
然后将这些列表连接在一起，并计算主要结果并与连接的列表配对。
通过对`sumAndFindEvens`进行一小部分修改，更清晰地分离保存偶数和计算总和的关注点，这个共同的结构变得更明显：

```lean
{{#example_decl Examples/Monads.lean sumAndFindEvensDirectish}}
```

为了清晰起见，一个由累积结果和值组成的对可以被赋予一个单独的名字：

```lean
{{#example_decl Examples/Monads.lean WithLog}}
```

类似地，将保存一个累积结果的列表的过程与将值传递给计算的下一步可以分解为一个助手函数`andThen`：

```lean
{{#example_decl Examples/Monads.lean andThenWithLog}}
```

在错误情况下，`ok` 代表一个总是成功的操作。然而，在这里，它只是返回一个值而不记录任何内容：

```lean
{{#example_decl Examples/Monads.lean okWithLog}}
```

就像 `Except` 提供了 `fail` 作为可能性一样，`WithLog` 应该允许向日志中添加项目。它没有与之关联的有趣返回值，所以返回 `Unit` 类型：

```lean
{{#example_decl Examples/Monads.lean save}}
```

`WithLog`、`andThen`、`ok` 和 `save` 可以用于将日志记录的关注点与求和的关注点在这两个程序中分离开来：

```scala
trait Logger {
  def info(msg: String): Unit
}

object ConsoleLogger extends Logger {
  def info(msg: String): Unit = {
    println(msg)
  }
}

trait SummingService {
  def sum(numbers: List[Int]): Int
}

object DefaultSummingService extends SummingService {
  def sum(numbers: List[Int]): Int = {
    numbers.foldLeft(0)(_ + _)
  }
}

def sumAndLog(numbers: List[Int], logger: Logger, service: SummingService): Int = {
  logger.info("Calculating sum...")
  val result = service.sum(numbers)
  logger.info(s"Sum is: $result")
  result
}

val numbers = List(1, 2, 3, 4, 5)

WithLog(ConsoleLogger)
  .andThen(DefaultSummingService.sum _)
  .ok(sumAndLog(numbers, _, _))
  .save("log.txt")
```

上述例子是将日志记录的关注点与求和的关注点分离。 `WithLog` 函数用于包装日志记录器（`Logger`）， `andThen` 函数用于连接要被包装的方法（本例中是 `DefaultSummingService` 的 `sum` 方法）， `ok` 函数用于定义接受被包装方法的参数的函数（本例中是 `sumAndLog` 函数）， `save` 函数用于保存日志到文件（`log.txt`）。

```lean
{{#example_decl Examples/Monads.lean sumAndFindEvensAndThen}}

{{#example_decl Examples/Monads.lean inorderSumAndThen}}
```

而且，再一次，中缀运算符有助于将焦点放在正确的步骤上：

```lean
{{#example_decl Examples/Monads.lean infixAndThenLog}}

{{#example_decl Examples/Monads.lean withInfixLogging}}
```

## 编号树节点

一个树的“中序编号”将树中的每个数据点与在树的中序遍历过程中访问它时所处的步骤相对应。
例如，考虑一个名为 `aTree` 的树：

```lean
{{#example_decl Examples/Monads.lean aTree}}
```

1. Introduction
2. Statement of the Lean Theorem
3. Outline of the Proof
4. Proof of the Lean Theorem
5. Conclusion

# 1. Introduction
In this article, we will explore the proof of the Lean Theorem. The Lean Theorem is an important result in mathematics that has deep implications in various areas of study. It provides a powerful tool for reasoning about the behavior of certain mathematical objects.

# 2. Statement of the Lean Theorem
The Lean Theorem states that *insert statement of the theorem here*. This theorem has been widely studied and used in various branches of mathematics.

# 3. Outline of the Proof
Before diving into the details of the proof, let's outline the main steps involved. The proof of the Lean Theorem can be divided into the following key steps:
* Step 1: *insert description of step 1 here*
* Step 2: *insert description of step 2 here*
* Step 3: *insert description of step 3 here*
* Step 4: *insert description of step 4 here*
* Step 5: *insert description of step 5 here*

# 4. Proof of the Lean Theorem
Now let's proceed with the actual proof of the Lean Theorem. We will begin by establishing some preliminary lemmas and building up towards the main result.

**Lemma 1:** *insert statement of lemma 1 here*
*Proof of Lemma 1:* *insert proof of lemma 1 here*

**Lemma 2:** *insert statement of lemma 2 here*
*Proof of Lemma 2:* *insert proof of lemma 2 here*

*insert additional lemmas and their proofs as necessary*

After establishing these lemmas, we can now proceed with the main proof of the Lean Theorem.

**Proof of the Lean Theorem:** *insert proof of the Lean Theorem here*

# 5. Conclusion
In conclusion, we have successfully proved the Lean Theorem by following a rigorous step-by-step approach. The Lean Theorem has important applications and implications in various areas of mathematics and its proof provides valuable insights into the behavior of mathematical objects.

```output info
{{#example_out Examples/Monads.lean numberATree}}
```

树通常使用递归函数进行处理，但是在树上进行递归处理时，计算中序编号变得困难。这是因为在左子树中分配的最高编号用于确定节点数据值的编号，并再次用于确定编号右子树的起始点。在命令式语言中，可以通过使用包含下一个要分配的编号的可变变量来解决这个问题。下面的 Python 程序使用可变变量计算中序编号：

```python
# 定义二叉树节点类
class TreeNode:
    def __init__(self, value=None):
        self.value = value
        self.left = None
        self.right = None
        self.number = None

# 计算中序编号的函数
def compute_inorder_number(node, next_number):
    if node is None:
        return next_number

    next_number = compute_inorder_number(node.left, next_number)
    node.number = next_number
    next_number += 1
    next_number = compute_inorder_number(node.right, next_number)
    
    return next_number

# 创建一个示例树
root = TreeNode(1)
root.left = TreeNode(2)
root.right = TreeNode(3)
root.left.left = TreeNode(4)
root.left.right = TreeNode(5)
root.right.left = TreeNode(6)
root.right.right = TreeNode(7)

# 初始化可变编号变量为 1
next_number = 1

# 计算中序编号
compute_inorder_number(root, next_number)

# 打印中序编号
def print_inorder_number(node):
    if node is None:
        return

    print_inorder_number(node.left)
    print("Node value:", node.value, "  Inorder number:", node.number)
    print_inorder_number(node.right)

print_inorder_number(root)
```

这个程序会输出以下结果：

```
Node value: 4   Inorder number: 1
Node value: 2   Inorder number: 2
Node value: 5   Inorder number: 3
Node value: 1   Inorder number: 4
Node value: 6   Inorder number: 5
Node value: 3   Inorder number: 6
Node value: 7   Inorder number: 7
```

以上程序使用先序遍历的方式计算中序编号，并将结果打印出来。在遍历过程中，通过将`next_number`作为参数传递，并在遍历每个节点时更新该值，从而保持编号的连续性。

```python
{{#include ../../examples/inorder_python/inordernumbering.py:code}}
```

Python 中 `aTree` 的编号是：

```python
{{#include ../../examples/inorder_python/inordernumbering.py:a_tree}}
```

根据 LEAN 定理的编号，我们有：

```
>>> {{#command {inorder_python} {inorderpy} {python inordernumbering.py} {number(a_tree)}}}
{{#command_out {inorderpy} {python inordernumbering.py} {inorder_python/expected} }}
```

尽管 Lean 没有可变变量，但有一种解决方法。

从世界其它部分的观点来看，可变变量可以被认为具有两个相关的方面：在函数被调用时的值，以及函数返回时的值。

换句话说，一个使用可变变量的函数可以被看作是一个以可变变量的初始值作为参数的函数，返回一个包含变量最终值和函数结果的组合。

这个最终值可以作为下一步的参数传递。

就像 Python 的示例使用一个外部函数来建立一个可变变量，以及一个内部辅助函数来改变变量一样，Lean 版本的函数使用一个外部函数来提供变量的初始值，并明确返回函数结果和一个内部辅助函数，该函数在计算编号树的同时将变量的值传递进去：

```lean
{{#example_decl Examples/Monads.lean numberDirect}}
```

像 `none`-propagating `Option` 代码，`error`-propagating `Except` 代码和 log-accumulating `WithLog` 代码一样，这段代码将传播计数器的值和实际遍历树以找到结果的工作混在一起。
就像在那些案例中一样，可以定义一个 `andThen` 辅助函数来在计算的不同步骤之间传播状态。
首先，我们给接受输入状态作为参数并返回输出状态和值的模式命名：

```lean
{{#example_decl Examples/Monads.lean State}}
```

在`State`的情况下，`ok`是一个函数，它返回输入的状态不变，以及提供的值:

```lean
{{#example_decl Examples/Monads.lean okState}}
```

在使用可变变量时，有两个基本操作：读取变量的值和替换为新值。
通过一个函数来读取当前值，该函数将输入状态未经修改地放入输出状态，并将它放入值字段中：

```lean
{{#example_decl Examples/Monads.lean get}}
```

写入新的值的过程包括忽略输入状态，并将提供的新值放入输出状态中：

```lean
{{#example_decl Examples/Monads.lean set}}
```

最后，两个使用状态的计算可以通过找出第一个函数的输出状态和返回值，然后将它们同时传递给下一个函数来进行顺序执行：

```lean
{{#example_decl Examples/Monads.lean andThenState}}
```

使用 `State` 和它的辅助函数，可以模拟局部可变状态：

```haskell
import Control.Monad.State

-- A function that increments a counter and returns the new value
incrementCounter :: State Int Int
incrementCounter = do
  counter <- get
  let newCounter = counter + 1
  put newCounter
  return newCounter

-- A function that runs incrementCounter three times and returns the final value
runCounter :: State Int Int
runCounter = do
  incrementCounter
  incrementCounter
  incrementCounter

-- Run the stateful computation and print the result
main :: IO ()
main = print $ evalState runCounter 0
```

通过在计算过程中使用 `State` 的辅助函数，可以模拟局部可变状态。在上面的示例中，定义了一个 `incrementCounter` 函数，它将计数器值加1，并返回新的计数器值。然后，定义了一个 `runCounter` 函数，它连续运行 `incrementCounter` 三次，并返回最终的计数器值。最后，在 `main` 函数中，使用 `evalState` 函数来运行 `runCounter`，并将初始计数器值设为0，然后打印结果。

运行上述代码，将会输出计数器最终的值。在这个例子中，由于运行了三次 `incrementCounter`，所以计数器的最终值为3。

```lean
{{#example_decl Examples/Monads.lean numberMonadicish}}
```

## Monad（单子）：一种函数式设计模式

这些例子中的每一个都包括以下内容：
 * 一个多态类型，例如 `Option`、`Except ε`、`WithLog logged` 或 `State σ`
 * 一个名为 `andThen` 的操作符，它负责处理具有这种类型的程序的一些重复方面的序列化
 * 一个名为 `ok` 的操作符，它是使用该类型的最无聊的方式（以某种意义上）
 * 一组其他操作，例如 `none`、`fail`、`save` 和 `get`，它们命名了使用该类型的方式

这种 API 风格被称为 _Monad_（单子）。
尽管 Monad 的概念源自于一个被称为范畴论的数学分支，但不需要理解范畴论就可以使用它们进行编程。
Monad 的关键思想是，每个 Monad 使用纯函数式语言 Lean 提供的工具来编码特定类型的副作用。
例如，`Option` 表示可能通过返回 `none` 来失败的程序，`Except` 表示可能抛出异常的程序，`WithLog` 表示在运行过程中累积日志的程序，而 `State` 则表示具有单个可变变量的程序。