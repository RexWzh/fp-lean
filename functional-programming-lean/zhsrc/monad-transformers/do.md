# 更多 do 功能

Lean 的 `do` 表达式提供了一种使用单子写程序的语法，类似于命令式编程语言。
除了提供用于使用某些单子变换器的语法之外，`do` 表达式还为使用单子编写程序提供了方便的语法。

## 单分支的 `if`

在使用单子时，一个常见的模式是只在某个条件为真时执行副作用。
例如，`countLetters` 包含一个检查元音或辅音的条件，并且不是元音或辅音的字母对状态没有影响。
这个模式通过将 `else` 分支的求值结果设为 `pure ()` 来表示，它没有任何副作用：

```lean
{{#example_decl Examples/MonadTransformers/Defs.lean countLettersModify}}
```

当 `if` 在 `do` 块中作为语句而不是表达式时，可以省略 `else pure ()`，Lean 会自动插入它。
下面的 `countLetters` 的定义是完全等价的：

```lean
{{#example_decl Examples/MonadTransformers/Do.lean countLettersNoElse}}
```

下面是一个使用状态monad来计算满足一些monadic检查的列表条目数量的程序示例：

```haskell
import Control.Monad.State

countEntries :: (Monad m) => (a -> m Bool) -> [a] -> m Int
countEntries p xs = stateCount 0 xs
  where
    stateCount n [] = return n
    stateCount n (x:xs) = do
      b <- p x
      if b then stateCount (n+1) xs else stateCount n xs
```

这个程序的类型签名表明，它可以用于任何 Monad m 的实例。参数 `p` 是检查函数，它接受列表中的一个元素并返回一个确定该元素满足要求与否的 monadic 值。参数 `xs` 是要进行检查的列表。

`countEntries` 函数定义了一个局部函数 `stateCount`，它使用 `StateT` monad 进行计数，并递归地遍历列表。当处理完列表时，它返回计数的结果。在每次迭代中，我们使用 `p` 函数对当前元素进行检查，然后根据检查的结果更新计数。如果检查结果为真，我们将计数加一并继续处理下一个元素；如果结果为假，我们仅继续处理下一个元素。

如果我们使用 `State` monad 替代 `StateT` monad，那么这个函数也可以工作，但是我们需要使用 `runState` 函数来提取计数的最终结果：

```haskell
countEntries :: (Monad m) => (a -> m Bool) -> [a] -> m Int
countEntries p xs = evalState (stateCount 0 xs) initialState
  where
    stateCount n [] = return n
    stateCount n (x:xs) = do
      b <- p x
      if b then stateCount (n+1) xs else stateCount n xs
    initialState = 0
```

这个函数可以用于许多不同的场景，只需提供不同的检查函数和列表即可。因为它是一个 monadic 计数器，所以它可以与其他任何 monadic 计算结合使用。

```lean
{{#example_decl Examples/MonadTransformers/Do.lean count}}
```

同样地，`if not E1 then STMT...` 可以被写成 `unless E1 do STMT...`。
通过将 `if` 替换为 `unless`，可以写出与 `count` 相反的函数，它统计不满足单一检查的条目。

```lean
{{#example_decl Examples/MonadTransformers/Do.lean countNot}}
```

理解单分支的 `if` 和 `unless` 并不需要考虑单子变换器。
它们只是用 `pure ()` 替换了缺失的分支。
然而，在本节中的其余扩展需要 Lean 自动重写 `do` 块，以在 `do` 块所在的单子之上添加一个局部变换器。 

## 提早返回

标准库中包含一个函数 `List.find?`，它返回列表中满足某个条件的第一个元素。
一个不利用 `Option` 是单子的事实的简单实现会使用递归函数循环遍历列表，并在找到所需的元素时使用 `if` 来停止循环：

```lean
{{#example_decl Examples/MonadTransformers/Do.lean findHuhSimple}}
```

命令式语言通常支持 `return` 关键字，它可以中断函数的执行，并立即将某个值返回给调用者。
在 Lean 中，这可以在 `do`-notation 中使用，`return` 语句会终止 `do`-block 的执行，并以 `return` 的参数作为 monad 返回的值。
换句话说，`List.find?` 可以这样写：

```lean
{{#example_decl Examples/MonadTransformers/Do.lean findHuhFancy}}
```

在命令式编程语言中，早期返回有点像只能导致当前堆栈帧取消的异常。
早期返回和异常都终止了代码块的执行，实际上用抛出的值替换了周围的代码。
在 Lean 中，早期返回使用 `ExceptT` 的一个版本来实现。
每个使用早期返回的 `do` 块都被包装在一个异常处理程序中（可以理解为函数 `tryCatch`）。
早期返回被转换为将值作为异常抛出，处理程序捕获抛出的值并立即返回它。
换句话说，`do` 块的原始返回值类型还用作异常类型。

具体而言，辅助函数 `runCatch` 在异常类型和返回类型相同的情况下从一个单子变换器堆栈的顶部移除了一个 `ExceptT` 层：

```lean
{{#example_decl Examples/MonadTransformers/Do.lean runCatch}}
```

在 `List.find?` 中使用早期返回的 `do`-block，可以通过将其包装在 `runCatch` 的使用中，并用 `throw` 替换早期返回来将其转换为不使用早期返回的 `do`-block：

```purescript
find? :: forall a. (a -> Boolean) -> List a -> Maybe a
find? p xs = runCatch do
  a <- pureUnit
  for_ xs \x -> do
    when (p x) $ throw a x
  catchAll $ const $ pureNothing Unit
```

```lean
{{#example_decl Examples/MonadTransformers/Do.lean desugaredFindHuh}}
```

另一个 early return 有用的情况是在命令行应用程序中，如果参数或输入不正确，就会提前终止。
许多程序在进入主体程序之前，都会开始一个验证参数和输入的部分。
下面这个版本的 `hello-name` 问候程序检查是否没有提供命令行参数：

```lean
{{#include ../../../examples/early-return/EarlyReturn.lean:main}}
```

如果不提供任何参数并输入名字 `David`，得到的结果与先前版本相同：

```
$ {{#command {early-return} {early-return} {./run} {lean --run EarlyReturn.lean}}}
{{#command_out {early-return} {./run} }}
```

将名称作为命令行参数而不是答案提供会导致错误：

```
$ {{#command {early-return} {early-return} {./too-many-args} {lean --run EarlyReturn.lean David}}}
{{#command_out {early-return} {./too-many-args} }}
```

在 LEAN 简论的证明中，如果不提供命名，就会导致另一种错误：

```
$ {{#command {early-return} {early-return} {./no-name} {lean --run EarlyReturn.lean}}}
{{#command_out {early-return} {./no-name} }}
```

使用早期返回的程序避免了需要嵌套控制流的情况，就像不使用早期返回的这个版本一样：

```python
def calculate_square(num):
    if num >= 0:
        if num % 2 == 0:
            square = num ** 2
            return square
        else:
            return 0
    else:
        return -1
```

在这个没有使用早期返回的版本中，必须先检查 `num` 是否大于等于 0，然后再进行下一步的判断。如果 `num` 小于 0，直接返回 -1；如果 `num` 大于等于 0，再检查 `num` 是否为偶数，然后返回平方值或 0。这种嵌套的控制流结构增加了代码的复杂性，使得代码难以阅读和理解。

下面是使用早期返回的版本：

```python
def calculate_square(num):
    if num < 0:
        return -1
    if num % 2 != 0:
        return 0
    square = num ** 2
    return square
```

使用早期返回的版本将判断条件的嵌套减少到最小。首先判断 `num` 是否小于 0，如果是则直接返回 -1；然后判断 `num` 是否为奇数，如果是则直接返回 0；最后计算 `num` 的平方并返回。

这种使用早期返回的编程风格使得代码更加简洁、清晰，能够更直接地表达程序的逻辑。

```lean
{{#include ../../../examples/early-return/EarlyReturn.lean:nestedmain}}
```

Lean语言中的早期返回（early return）与命令式语言中的早期返回有一个重要的区别，即Lean的早期返回仅适用于当前的`do`块。
当一个函数的整个定义在同一个`do`块中时，这个区别并不重要。
但是如果`do`出现在其他某些结构下面，这个区别就会变得明显。
例如，给定下面的`greet`函数的定义：

```lean
{{#example_decl Examples/MonadTransformers/Do.lean greet}}
```

表达式 `{{#example_in Examples/MonadTransformers/Do.lean greetDavid}}` 的计算结果为 `{{#example_out Examples/MonadTransformers/Do.lean greetDavid}}`，而不仅仅是`"David"`。

## 循环

正如每个具有可变状态的程序都可以重写为将状态作为参数传递的程序一样，每个循环都可以重写为递归函数。
从一个角度来看，`List.find?` 作为递归函数是最清晰的。
毕竟，它的定义反映了列表的结构：如果头部通过了检查，那么应该返回它；否则，继续在尾部查找。
当没有更多的条目时，答案是 `none`。
从另一个角度来看，`List.find?` 作为循环是最清晰的。
毕竟，程序会按顺序查询条目，直到找到满意的条目为止，然后终止。
如果循环在没有返回的情况下终止，答案是 `none`。

### 使用 ForM 进行循环

Lean 包括一个类型类，用于描述在某个单子中循环遍历容器类型。这个类被称为 `ForM`：

```lean
{{#example_decl Examples/MonadTransformers/Do.lean ForM}}
```

这个类是相当通用的。
参数 `m` 是一个带有一些期望效果的 monad，`γ` 是要循环遍历的集合，`α` 是集合中元素的类型。
通常，`m` 被允许是任何 monad，但也可能有一个只支持在 `IO` 中循环的数据结构。
方法 `forM` 接受一个集合，一个对集合中每个元素进行效果运行的 monadic 操作，并且负责运行这些操作。

`List` 的实例允许 `m` 是任何 monad，它将 `γ` 设为 `List α`，并且将类的 `α` 设置为列表中相同的 `α`：

```lean
{{#example_decl Examples/MonadTransformers/Do.lean ListForM}}
```

[`doug`](reader-io.md#implementation) 中的函数 `doList` 是列表的 `forM` 函数。
由于 `forM` 旨在在 `do` 块中使用，它使用 `Monad` 而不是 `Applicative`。
可以使用 `forM` 来使 `countLetters` 的代码更加简洁：

```lean
{{#example_decl Examples/MonadTransformers/Do.lean countLettersForM}}
```

`Many` 实例非常相似：

```lean
{{#example_decl Examples/MonadTransformers/Do.lean ManyForM}}
```

因为 `γ` 可以是任何类型，所以 `ForM` 可以支持非多态集合。
一个非常简单的集合是某个给定数字之间的自然数，以倒序的方式排列：

```lean
{{#example_decl Examples/MonadTransformers/Do.lean AllLessThan}}
```

其 `forM` 操作符将提供的动作应用于每个较小的 `Nat` ：

```lean
{{#example_decl Examples/MonadTransformers/Do.lean AllLessThanForM}}
```

使用 `forM` 可以在小于五的每个数字上执行 `IO.println`：

```lean
{{#example_in Examples/MonadTransformers/Do.lean AllLessThanForMRun}}
```



```output info
{{#example_out Examples/MonadTransformers/Do.lean AllLessThanForMRun}}
```

一个只在特定单子中工作的 `ForM` 实例的例子是循环读取从 IO 流中读取的行，比如标准输入：

```lean
{{#include ../../../examples/formio/ForMIO.lean:LinesOf}}
```

`forM` 的定义被标记为 `partial`，因为不能保证流是有限的。在这种情况下，`IO.FS.Stream.getLine` 只能在 `IO` 单子中工作，所以不能使用其他单子来进行循环。

这个示例程序使用这个循环结构来过滤掉不包含字母的行：

```lean
{{#include ../../../examples/formio/ForMIO.lean:main}}
```

文件 `test-data` 包含以下内容：

```
{{#include ../../../examples/formio/test-data}}
```

运行存储在 `ForMIO.lean` 中的程序会产生以下输出：

```
$ {{#command {formio} {formio} {lean --run ForMIO.lean < test-data}}}
{{#command_out {formio} {lean --run ForMIO.lean < test-data} {formio/expected}}}
```

### 停止迭代

使用 `forM` 提前终止循环是比较困难的。
编写一个函数，在 `AllLessThan` 中迭代 `Nat` 直到达到 `3`，需要中途停止循环的方法。
实现这一点的一种方法是使用带有 `OptionT` 单子变换器的 `forM`。
第一步是定义 `OptionT.exec`，它舍弃有关转换后计算的返回值和是否成功的信息：

```lean
{{#example_decl Examples/MonadTransformers/Do.lean OptionTExec}}
```

然后，在 `Alternative` 的 `OptionT` 实例中发生失败，可以用于提前终止循环：

```lean
{{#example_decl Examples/MonadTransformers/Do.lean OptionTcountToThree}}
```

一个快速的测试证明了这个解决方案的可行性：

```lean
{{#example_in Examples/MonadTransformers/Do.lean optionTCountSeven}}
```



```output info
{{#example_out Examples/MonadTransformers/Do.lean optionTCountSeven}}
```

然而，这段代码不太容易阅读。
提前终止一个循环是一个常见的任务，Lean提供了更多的语法糖来使得这个操作更加简单。
同样的函数也可以写成如下形式：

```lean
{{#example_decl Examples/MonadTransformers/Do.lean countToThree}}
```

测试发现它的工作方式与之前的版本完全相同：

```lean
{{#example_in Examples/MonadTransformers/Do.lean countSevenFor}}
```



```output info
{{#example_out Examples/MonadTransformers/Do.lean countSevenFor}}
```

在撰写本文时，`for ... in ... do ...` 语法会展开为使用一个叫做 `ForIn` 的类型类，它是 `ForM` 的一种稍微复杂一些的版本，它会跟踪状态并进行提前终止。
然而，计划对 `for` 循环进行重构，以使用更简单的 `ForM`，并在必要时插入单子变换器。
与此同时，提供了一个适配器，名为 `ForM.forIn`，它将 `ForM` 实例转换为 `ForIn` 实例。
要基于 `ForM` 实例启用基于 `for` 循环的代码，可以添加如下内容，需要适用于 `AllLessThan` 和 `Nat` 的替代内容：

```lean
{{#example_decl Examples/MonadTransformers/Do.lean ForInIOAllLessThan}}
```

然而，请注意，这个适配器只适用于保持单子未加约束的 `ForM` 实例，因为大多数实例都是如此。这是因为适配器使用 `StateT` 和 `ExceptT`，而不是底层的单子。

在 `for` 循环中支持早期返回。
将具有早期返回的 `do` 块的翻译转换为使用异常单子变换器的使用，同样适用于 `forM` 下面的早期使用 `OptionT` 终止迭代的情况。这个版本的 `List.find?` 同时使用了这两种方法：

```lean
{{#example_decl Examples/MonadTransformers/Do.lean findHuh}}
```

除了 `break` 之外，`for` 循环还支持 `continue` ，在迭代中跳过剩余的循环体部分。
`List.find?` 的另一种（但容易造成困惑）表达方式是跳过不满足条件的元素：

```lean
{{#example_decl Examples/MonadTransformers/Do.lean findHuhCont}}
```

`Range` 是一个由起始数字、结束数字和步长组成的结构。
它们表示一个自然数序列，从起始数字到结束数字，每次增加步长。
Lean 有特殊的语法来构造范围，由方括号、数字和冒号组成，有四种变体。
必须始终提供停止点，而起点和步长是可选的，默认分别为 `0` 和 `1`：

| 表达式 | 起点      | 终点       | 步长 | 作为列表 |
|------------|------------|------------|------|---------|
| `[:10]` | `0` | `10` | `1` | `{{#example_out Examples/MonadTransformers/Do.lean rangeStopContents}}` |
| `[2:10]` | `2` | `10` | `1` | `{{#example_out Examples/MonadTransformers/Do.lean rangeStartStopContents}}` |
| `[:10:3]` | `0` | `10` | `3` | `{{#example_out Examples/MonadTransformers/Do.lean rangeStopStepContents}}` |
| `[2:10:3]` | `2` | `10` | `3` | `{{#example_out Examples/MonadTransformers/Do.lean rangeStartStopStepContents}}` |

需要注意的是，起始数字 _是_ 范围的一部分，而停止数字不是。
所有三个参数都是 `Nat` 类型的，这意味着范围不能倒数——当起始数字大于或等于结束数字时，范围中不包含任何数字。

范围可以与 `for` 循环一起使用，从范围中获取数字。
下面的程序从四到八计算偶数：

```lean
{{#example_decl Examples/MonadTransformers/Do.lean fourToEight}}
```

运行它会产生：

```output info
{{#example_out Examples/MonadTransformers/Do.lean fourToEightOut}}
```

最后，**for** 循环支持通过使用逗号将**in**子句分隔开，同时在多个集合中进行并行迭代。
当第一个集合的元素用尽时，循环停止，所以声明为：

```lean
{{#example_decl Examples/MonadTransformers/Do.lean parallelLoop}}
```

产生三行输出：

```lean
{{#example_in Examples/MonadTransformers/Do.lean parallelLoopOut}}
```



```output info
{{#example_out Examples/MonadTransformers/Do.lean parallelLoopOut}}
```

## 可变变量

除了`return`，`else`-less `if`和`for`循环之外，Lean还支持`do`块中的局部可变变量。
在背后，这些可变变量展开为对`StateT`的使用，而不是真正的可变变量的实现。
再次，函数式编程被用来模拟命令式编程。

局部的可变变量使用`let mut`引入，而不是简单的`let`。
下面的`two`定义使用恒等态`Id`来启用`do`语法而不引入任何影响，用于计数到`2`：

```lean
{{#example_decl Examples/MonadTransformers/Do.lean two}}
```

这段代码等价于使用 `StateT` 添加 `1` 两次的定义：

```lean
{{#example_decl Examples/MonadTransformers/Do.lean twoStateT}}
```

本地可变变量与`do`-notation的所有其他特性很好地配合，为单子变换器提供了方便的语法。
定义`three`计算了一个包含三个条目的列表的数量：

```lean
{{#example_decl Examples/MonadTransformers/Do.lean three}}
```

类似地，`six`将列表中的元素相加：

```lean
{{#example_decl Examples/MonadTransformers/Do.lean six}}
```

`List.count` 函数用于计算满足某个条件的列表中的元素数量：

```lean
def count (l : list α) (p : α → Prop) : nat :=
list.foldr (λ a n, if p a then n + 1 else n) 0 l
```

It takes two arguments: a list `l` of type `list α`, and a predicate `p` that takes an element of type `α` and returns a proposition or a boolean value indicating whether the element satisfies the check.

函数接受两个参数：一个类型为 `list α` 的列表 `l`，以及一个谓词 `p`，该谓词接受一个类型为 `α` 的元素，并返回一个命题或布尔值，指示元素是否满足检查。

The function applies the predicate to each element of the list using `list.foldr`, which performs a right fold over the list. The fold starts with an initial value of `0` and increments the count if the predicate `p` returns `true` for the current element.

该函数使用 `list.foldr` 将谓词应用于列表的每个元素，`list.foldr` 在列表上执行从右侧开始的折叠操作。折叠操作从初始值 `0` 开始，并在当前元素的谓词 `p` 返回 `true` 时递增计数。

Finally, the function returns the total count of elements satisfying the predicate.

最后，函数返回满足谓词的元素的总数。

Here is an example usage of `List.count`:

以下是对 `List.count` 的示例用法：

```lean
def evens (n : ℕ) : Prop := n % 2 = 0

#eval List.count [1,2,3,4,5,6] evens -- returns 3
```

In this example, the function `evens` is a predicate that checks whether a given natural number is even. We apply `List.count` to the list `[1,2,3,4,5,6]` and the predicate `evens`, which returns the count of even numbers in the list, resulting in `3`.

```lean
{{#example_decl Examples/MonadTransformers/Do.lean ListCount}}
```

局部可变变量比显式地使用 `StateT` 更方便使用和易于阅读。然而，它们没有来自命令式语言的无限制可变变量的全部功能。尤其是，它们只能在引入它们的 `do` 块中被修改。这意味着，例如，`for` 循环无法被等价的递归辅助函数替代。`List.count` 的这个版本：

```lean
{{#example_in Examples/MonadTransformers/Do.lean nonLocalMut}}
```

对`found`的尝试突变产生了以下错误：

```
Cannot mutate a borrowed variable
```

错误提示：无法对借用变量执行突变操作

```output info
{{#example_out Examples/MonadTransformers/Do.lean nonLocalMut}}
```

这是因为递归函数是在 identity monad 中编写的，只有 `do` 块的 monad 才会通过 `StateT` 进行转换。

## 什么被视为 `do` 块？

`do`-notation 的许多特性仅适用于单个 `do` 块。
早期返回会终止当前的块，并且可变变量只能在定义它们的块中进行修改。
为了有效使用它们，重要的是要知道什么被视为“同一块”。

一般来说，紧随 `do` 关键词的缩进块被视为一个块，下面的立即序列语句是该块的一部分。
独立块中的语句，即使它们被包含在一个块中，也不被视为该块的一部分。
然而，准确衡量什么被视为同一块的规则稍微有点复杂，因此需要一些示例。
可以通过设置含有可变变量的程序来测试规则的确切性质，并查看在哪里允许修改。
这个程序中有一个显然在与可变变量相同的块中的修改：

```lean
{{#example_decl Examples/MonadTransformers/Do.lean sameBlock}}
```

当发生突变时，如果这个突变发生在 `let` 语句中定义了一个使用了 `:=` 的名称的 `do` 块中，那么它不被认为是该块的一部分。

这个规则是根据 LEAN 证明系统中的定义而来的。LEAN 采用的是依赖类型理论作为其形式化基础，其中的 `let` 和 `do` 关键字具有特定的语义。

在 LEAN 中，`let` 语句用于定义局部变量，并将表达式的结果绑定到一个名称上。而 `do` 关键字则用于构建一个执行序列，它允许使用代码块对操作进行分组。

当一个 `let` 语句中的局部变量使用 `:=` 定义，并且这个变量在 `do` 块中被突变时，由于 `:=` 是一种引入名字的机制，任何对该变量的突变操作（如赋值或修改）都将被看作是对这个名称的重新定义，并且不会影响 `do` 块中的其它操作。

这种规则确保了在随后的计算中，`do` 块可以使用最新的值来进行推理和变换，从而使得证明过程更加准确和可靠。此外，这也使得代码更加清晰，因为开发者可以明确区分何时是定义名字，何时是执行操作。

总之，LEAD 证明系统中的 `let` 和 `do` 关键字在定义和执行过程中遵循严格的规则，其中包括当发生突变时 `do` 块中的操作不会被视为 `let` 语句的一部分。

```lean
{{#example_in Examples/MonadTransformers/Do.lean letBodyNotBlock}}
```



```output error
{{#example_out Examples/MonadTransformers/Do.lean letBodyNotBlock}}
```

然而，在使用 `←` 定义名称的 `let` 语句下出现的 `do` 块被认为是周围块的一部分。
以下程序被接受：

```lean
{{#example_decl Examples/MonadTransformers/Do.lean letBodyArrBlock}}
```

类似地，作为函数参数的 `do`-块与其周围的块是相互独立的。
下面的程序是不被接受的：

```lean
{{#example_in Examples/MonadTransformers/Do.lean funArgNotBlock}}
```



```output error
{{#example_out Examples/MonadTransformers/Do.lean funArgNotBlock}}
```

如果 `do` 关键字完全是多余的，那么它不会引入一个新的块。
这个程序被接受，并且与本节中的第一个程序等价：

```lean
{{#example_decl Examples/MonadTransformers/Do.lean collapsedBlock}}
```

在 `do` 下的分支（比如 `match` 或 `if` 中的分支）被视为是包围块的一部分，无论是否添加了多余的 `do`。
以下程序都是可以接受的：

```lean
{{#example_decl Examples/MonadTransformers/Do.lean ifDoSame}}

{{#example_decl Examples/MonadTransformers/Do.lean ifDoDoSame}}

{{#example_decl Examples/MonadTransformers/Do.lean matchDoSame}}

{{#example_decl Examples/MonadTransformers/Do.lean matchDoDoSame}}
```

同样，作为 `for` 和 `unless` 语法的一部分，出现的 `do` 只是它们语法的一部分，并不引入一个新的 `do` 块。
这些程序也被接受：

```lean
{{#example_decl Examples/MonadTransformers/Do.lean doForSame}}

{{#example_decl Examples/MonadTransformers/Do.lean doUnlessSame}}
```

## 命令式或者函数式编程？

Lean的`do`-notation提供了命令式特性，使得很多程序非常接近Rust、Java或C#等语言中的对应程序。
当将一个命令式算法转换成Lean时，这种相似性非常方便，并且有些任务就是最自然地以命令式方式进行思考。
单子（monads）和单子转换器（monad transformers）的引入使得可以在纯函数式语言中编写命令式程序，而`do`-notation作为单子的专用语法（可能在局部上进行转换）允许函数式程序员在以下两个方面都拥有：通过不可变性提供的强大推理原则以及通过类型系统对可用效果进行严格控制。语法和库允许使用效果的程序看起来熟悉且易读。
单子和单子转换器使得函数式与命令式编程成为一种观点的问题。


## 练习

* 将`doug`重写为使用`for`而不是`doList`函数。是否还有其他机会使用本节介绍的特性来改进代码？如果有，请使用它们！