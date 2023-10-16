# 结合 IO 和 Reader

有一种情况下，Reader Monad非常有用，那就是在应用程序中有一些传递到许多递归调用中的"当前配置"的概念。
一个例子就是 `tree` 程序，它递归地打印当前目录及其子目录中的文件，并使用字符表示它们的树状结构。
这一章中的 `tree` 版本被称为 `doug`，以致敬北美西海岸上装点的强大的道格拉斯冷杉树，并在指示目录结构时提供了使用Unicode框图字符或其ASCII等价物的选项。

例如，以下命令在一个名为 `doug-demo` 的目录中创建了一个目录结构和一些空文件：

```
$ cd doug-demo
$ {{#command {doug-demo} {doug} {mkdir -p a/b/c} }}
$ {{#command {doug-demo} {doug} {mkdir -p a/d} }}
$ {{#command {doug-demo} {doug} {mkdir -p a/e/f} }}
$ {{#command {doug-demo} {doug} {touch a/b/hello} }}
$ {{#command {doug-demo} {doug} {touch a/d/another-file} }}
$ {{#command {doug-demo} {doug} {touch a/e/still-another-file-again} }}
```

运行 `doug` 的结果如下所示：

```
$ {{#command {doug-demo} {doug} {doug} }}
{{#command_out {doug} {doug} }}
```

## 实现

在内部，`doug`通过递归遍历目录结构，向下传递一个配置值。这个配置包含两个字段：`useASCII`确定是否使用Unicode绘图字符还是ASCII垂直线和破折号字符来表示结构，`currentPrefix`包含一个字符串，用于在输出的每一行前面添加前缀。
随着当前目录的深入，前缀字符串累积了表明所在目录的指示符。
配置是一个结构体：

```lean
{{#example_decl Examples/MonadTransformers.lean Config}}
```

这个结构对这两个字段都有默认定义。
默认的 `Config` 使用无前缀的 Unicode 显示。

调用 `doug` 的用户需要能够提供命令行参数。
下面是用法信息：

```lean
{{#example_decl Examples/MonadTransformers.lean usage}}
```

根据此，可以通过检查命令行参数列表来构建配置：

```lean
{{#example_decl Examples/MonadTransformers.lean configFromArgs}}
```

`main`函数是一个包裹着内部工作函数`dirTree`的外壳函数，它根据配置显示目录的内容。
在调用`dirTree`之前，`main`函数负责处理命令行参数。
它还必须返回适当的退出代码给操作系统：

```lean
{{#example_decl Examples/MonadTransformers.lean OldMain}}
```

并非所有的路径都应该在目录树中显示。
特别地，名为 `.` 或者 `..` 的文件应该跳过，因为它们实际上是用于导航而不是文件 _per se_。
那些应该显示的文件分为两种：普通文件和目录：

```lean
{{#example_decl Examples/MonadTransformers.lean Entry}}
```

为了确定是否显示文件以及哪种类型的条目，`doug`使用了`toEntry`函数：

```lean
{{#example_decl Examples/MonadTransformers.lean toEntry}}
```

`System.FilePath.components` 将路径转换为路径组件的列表，将名称在目录分隔符处拆分。
如果没有最后一个组件，那么该路径是根目录。
如果最后一个组件是特殊的导航文件（`.`或`..`），则应该将该文件排除。
否则，目录和文件将包装在相应的构造函数中。

Lean的逻辑无法知道目录树是有限的。
实际上，某些系统允许构建循环目录结构。
因此，`dirTree`被声明为`partial`：

```lean
{{#example_decl Examples/MonadTransformers.lean OldDirTree}}
```

调用 `toEntry` 是一个 [嵌套操作](../hello-world/conveniences.md#nested-actions)——在箭头无法有其他意义的位置，比如 `match` 部分，括号是可选的。
当文件名与树中的条目不对应时（例如 `..`），`dirTree` 什么都不做。
当文件名指向普通文件时，`dirTree` 调用一个辅助函数以当前配置显示该文件。
当文件名指向一个目录时，通过辅助函数显示该目录，并在一个新的配置中递归地显示其内容，其中前缀已扩展以适应位于新目录中的情况。

使用 `showFileName` 和 `showDirName` 来显示文件和目录的名称。

```lean
{{#example_decl Examples/MonadTransformers.lean OldShowFile}}
```

这两个助手都将委托给 `Config` 上的函数，这些函数考虑了ASCII和Unicode设置的影响：

```lean
{{#example_decl Examples/MonadTransformers.lean filenames}}
```

类似地，`Config.inDirectory` 将前缀与一个目录标记扩展在一起：

```lean
{{#example_decl Examples/MonadTransformers.lean inDirectory}}
```

使用 `doList` 函数可以在目录内容列表上迭代执行 IO 操作。因为 `doList` 在列表中执行所有操作，并且不基于任何操作返回的值进行控制流决策，所以并不需要完整的 `Monad` 功能，它适用于任何 `Applicative` 类型：

```lean
{{#example_decl Examples/MonadTransformers.lean doList}}
```

## 使用自定义 Monad

虽然 `doug` 函数的这个实现是可行的，但是手动传递配置信息显得冗长且容易出错。
如果错误的配置被传递下去，类型系统是无法捕获到的。
读取器效应保证了相同的配置会传递给所有的递归调用，除非手动覆盖，它能够减少代码的冗长程度。

为了创建一个既是 `IO` 的实例又是 `Config` 的读取器的版本，首先需要定义这个类型及其 `Monad` 实例，按照 [求值器示例](../monads/arithmetic.md#custom-environments) 中的说明进行操作：

```lean
{{#example_decl Examples/MonadTransformers.lean ConfigIO}}
```

这个`Monad`实例和`Reader`的实例之间的区别在于，这个实例在`IO` monad中使用`do`-notation作为`bind`返回的函数体，而不是直接将`next`应用于从`result`返回的值。
`result`执行的任何`IO`效果必须在调用`next`之前发生，这由`IO` monad的`bind`操作符确保。
`ConfigIO`不是宇宙多态的，因为底层的`IO`类型也不是宇宙多态的。

运行`ConfigIO` action涉及将其转换为一个带有配置的`IO` action:

```lean
{{#example_decl Examples/MonadTransformers.lean ConfigIORun}}
```

这个函数并不是真的必要的，因为调用者可以直接提供配置。
然而，给操作命名可以更容易地看出代码的哪些部分是在哪个单子中运行的。

下一步是定义一种方式来访问当前配置作为 `ConfigIO` 的一部分：

```lean
{{#example_decl Examples/MonadTransformers.lean currentConfig}}
```

这与[求职例子](../monads/arithmetic.md#custom-environments)中的`read`函数很像，只是它使用了`IO`的`pure`来返回值，而不是直接返回。
由于进入一个目录时会修改当前配置，在递归调用的范围内必须有一种方式来覆盖配置：

```lean
{{#example_decl Examples/MonadTransformers.lean locally}}
```

在`doug`中使用的大部分代码不需要配置，并且`doug`调用了标准库中的普通 Lean `IO` 操作，这些操作显然不需要 `Config`。
可以使用 `runIO` 运行普通的 `IO` 操作，它会忽略配置参数：

```lean
{{#example_decl Examples/MonadTransformers.lean runIO}}
```

使用这些组件，`showFileName` 和 `showDirName` 可以通过 `ConfigIO` 单子隐式地取得它们的配置参数。它们使用 [嵌套操作](../hello-world/conveniences.md#嵌套操作) 来获取配置，并使用 `runIO` 来实际执行对 `IO.println` 的调用：

```lean
{{#example_decl Examples/MonadTransformers.lean MedShowFileDir}}
```

在新版本的 `dirTree` 中，对 `toEntry` 和 `System.FilePath.readDir` 的调用被包装在 `runIO` 中。
此外，不再建立一个新的配置，然后要求程序员跟踪哪一个配置传递给递归调用，而是使用 `locally` 来自然地将修改后的配置限定在程序的一小部分区域内，其中它是唯一有效的配置：

```lean
{{#example_decl Examples/MonadTransformers.lean MedDirTree}}
```

新版本的 `main` 函数使用 `ConfigIO.run` 来使用初始配置来调用 `dirTree` 函数：

```python
import ConfigIO

def main():
    # read configuration from file or user input
    config = ConfigIO.read_config()

    # invoke dirTree with the updated configuration
    result = dirTree(config)

    # do something with the result

if __name__ == "__main__":
    main()
```

在这段代码中，`main` 函数首先通过调用 `ConfigIO.read_config()` 来读取配置信息。这个函数可以从文件中读取配置，也可以从用户输入获取配置。获取到配置后，我们将会使用更新后的配置参数来调用 `dirTree` 函数。`dirTree` 函数将会根据配置参数来生成目录树，并返回结果。最后，我们可以根据需要对结果进行进一步处理。整个过程通过调用 `ConfigIO.run` 函数来实现。

```lean
{{#example_decl Examples/MonadTransformers.lean MedMain}}
```

这个自定义的 monad 相比手动传递配置有一些优点：

1. 更容易确保配置在传递过程中保持不变，除非有需要修改配置
2. 传递配置的关注点与打印目录内容的关注点更清晰地分离开
3. 随着程序的发展，可能会有越来越多的中间层只是传递配置而不做其他操作，这些层不需要在配置逻辑发生变化时重新编写

然而，也存在一些明显的缺点：

1. 随着程序的演进和 monad 需要更多特性，每个基本操作符（如 `locally` 和 `currentConfig`）都需要更新
2. 将普通的 `IO` 操作包裹在 `runIO` 中会产生噪音，分散注意力
3. 手动编写 monad 实例是重复的工作，而将 reader 效应添加到另一个 monad 的技术是一种需要文档和沟通开销的设计模式

通过一种叫做 _monad transformers_ 的技术，可以解决所有这些问题。
Monad transformer 将一个 monad 作为参数，并返回一个新的 monad。
Monad transformer 包含以下内容：
1. 转换器本身的定义，通常是从类型到类型的函数
2. 假设内部类型已经是一个 monad 的 `Monad` 实例
3. 一个操作符，用于将一个动作从内部 monad 提升到转换后的 monad，类似于 `runIO`

## 向任何 Monad 添加 Reader

在 `ConfigIO` 中，通过将 `IO α` 包装在一个函数类型中，实现了向 `IO` 添加 reader 效应。
Lean 标准库中包含了一个可以对 _任何_ 多态类型进行这种操作的函数，叫做 `ReaderT`：

```lean
{{#example_decl Examples/MonadTransformers.lean MyReaderT}}
```

其参数如下：
* `ρ`是可被读者访问的环境
* `m`是正在转换的单子，比如 `IO`
* `α`是单子计算返回的值的类型
`α` 和 `ρ` 在同一个宇宙，因为在单子中检索环境的操作符将具有类型 `m ρ`。

使用 `ReaderT`，`ConfigIO` 变为：

```lean
{{#example_decl Examples/MonadTransformers.lean ReaderTConfigIO}}
```

这是一个缩写，因为在标准库中定义了许多有用的功能，而非可简化的定义将隐藏它们。
与其直接为 `ConfigIO` 使这些功能起作用，还不如让 `ConfigIO` 与 `ReaderT Config IO` 表现完全一致。

手动编写的 `currentConfig` 从 reader 中获取环境。
可以为所有使用 `ReaderT` 的情况定义一个通用形式的 `read` 效果。

```lean
{{#example_decl Examples/MonadTransformers.lean MyReaderTread}}
```

然而，并不是每个提供 reader effect 的 monad 都是用 `ReaderT` 构建的。
类型类 `MonadReader` 允许任何 monad 提供一个 `read` 操作符：

```lean
{{#example_decl Examples/MonadTransformers.lean MonadReader}}
```

类型 `ρ` 是一个输出参数，因为通常每个特定的 monad 通过一个 reader 提供单一类型的环境，所以在已知 monad 的情况下自动选择它使得程序更加方便编写。

`ReaderT` 的 `Monad` 实例本质上与 `ConfigIO` 的 `Monad` 实例相同，只是将 `IO` 替换为某个任意的 monad 参数 `m`：

```lean
{{#example_decl Examples/MonadTransformers.lean MonadMyReaderT}}
```

下一步是消除对`runIO`的使用。
当Lean遇到单子类型不匹配时，它会自动尝试使用一个叫做`MonadLift`的类型类来将实际的单子转换为期望的单子。
这个过程类似于使用强制转换。
`MonadLift`的定义如下：

```lean
{{#example_decl Examples/MonadTransformers.lean MyMonadLift}}
```

方法 `monadLift` 的作用是从 monad `m` 翻译到 monad `n`。
这个过程被称为“lifting”（提升），因为它将嵌套 monad 中的操作转换为外围 monad 中的操作。
在这种情况下，它将被用于从 `IO` 提升到 `ReaderT Config IO`，尽管该实例适用于 _任何_ 内部 monad `m`。

```lean
{{#example_decl Examples/MonadTransformers.lean MonadLiftReaderT}}
```

`monadLift` 的实现与 `runIO` 非常相似。事实上，只需定义 `showFileName` 和 `showDirName` 即可，而无需使用 `runIO`：

```lean
import system.io

def showFileName : io unit :=
do io.put_str_ln "File"

def showDirName : io unit :=
do io.put_str_ln "Directory"

def monadLift {m : Type → Type} {α : Type} [has_monad_lift io m] : io α → m α :=
λ x, monad_lift x
```

```lean
{{#example_decl Examples/MonadTransformers.lean showFileAndDir}}
```

还有一个从原始的 `ConfigIO` 转换成 `ReaderT` 中的最后一个操作：`locally`。这个定义可以直接转换成 `ReaderT`，但是 Lean 标准库提供了一个更一般化的版本。标准版本被称为 `withReader`，它是一个名为 `MonadWithReader` 的类型类的一部分：

```lean
{{#example_decl Examples/MonadTransformers.lean MyMonadWithReader}}
```

就像在 `MonadReader` 中一样，环境 `ρ` 是一个 `outParam`。
`withReader` 操作被导出，所以在使用时不需要在前面写上类型类名字：

```lean
{{#example_decl Examples/MonadTransformers.lean exportWithReader}}
```

`ReaderT`的实例本质上和`locally`的定义是相同的：

```haskell
instance Monad m => MonadReader r (ReaderT r m) where
  ask = ReaderT $ pure
  local f (ReaderT g) = ReaderT $ \r -> g $ f r
```

它们的定义非常相似，都是基于读取环境的数据类型。`ReaderT`是一个将读取环境 `r` 和执行的基础 monad `m` 相结合的 transformer 类型。因此，它可以被看作是一个 monad transformer，该 monad transformer 提供了在 monadic 计算中访问和修改读取环境的能力。

首先，我们来看看 `ask` 函数。`ask` 函数是 `MonadReader` 类型类中的一个函数，它返回当前的读取环境。在 `ReaderT` 的实例中，`ask` 函数使用 `pure` 将当前的读取环境包装成一个 `ReaderT` 计算。

接下来，我们来看看 `local` 函数。`local` 函数可以根据一个函数 `f` 修改读取环境。在 `ReaderT` 的实例中，`local` 函数接受一个函数 `f` 和一个 `ReaderT` 计算，并返回一个新的 `ReaderT` 计算。新的 `ReaderT` 计算使用一个 lambda 表达式来接受当前的读取环境 `r`，首先应用函数 `f` 来修改读取环境，然后将修改后的读取环境传递给原始的 `ReaderT` 计算 `g`。

总结起来，`ReaderT` 的实例为我们提供了在 monadic 计算中访问和修改读取环境的能力。这与 `locally` 的定义非常相似，`locally` 是一个函数，它接受一个函数 `f` 和一个 monadic 计算 `m`，并在计算 `m` 中临时修改读取环境。因此，我们可以说 `ReaderT` 的实例和 `locally` 实际上是相同的。

```lean
{{#example_decl Examples/MonadTransformers.lean ReaderTWithReader}}
```

有了这些定义，`dirTree` 的新版本可以这样写：

```lean
{{#example_decl Examples/MonadTransformers.lean readerTDirTree}}
```

除了将 `locally` 替换为 `withReader`，其他都和以前一样。

在这一节中，用 `ReaderT` 替换自定义的 `ConfigIO` 类型并没有节省太多的代码行数。
然而，使用标准库中的组件来重写代码确实有着长期的好处。
首先，了解 `ReaderT` 的读者无需花时间去理解 `ConfigIO` 的 `Monad` 实例，反推出单子本身的含义。
相反，他们可以对其最初的理解有信心。
其次，向单子添加进一步的效果（例如在每个目录中计算文件数量并在最后显示计数的状态效果）需要对代码进行的更改要少得多，因为库中提供的单子变换器和 `MonadLift` 实例很好地协同工作。
最后，使用标准库中包含的一组类型类，可以以一种能与各种单子一起工作并且无需关心单子变换器应用的顺序等细节的方式编写多态代码。
就像一些函数适用于任何单子一样，其他函数可以适用于任何提供特定类型状态或特定类型异常的单子，而无需特别描述具体单子提供状态或异常的方式。

## 练习

### 控制隐藏文件的显示

以 `.` 字符开头的文件通常表示通常应该隐藏的文件，例如源代码控制元数据和配置文件。
在 `doug` 中添加一个选项，可以显示或隐藏以点开始的文件名。
此选项应该由一个 `-a` 命令行选项控制。

### 起始目录作为参数

修改 `doug`，使其接受一个起始目录作为额外的命令行参数。