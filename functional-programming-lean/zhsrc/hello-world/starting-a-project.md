# 开始一个项目

随着 Lean 编写的程序变得更加严肃，一种提前编译的基于编译器的工作流程，生成可执行文件变得更加吸引人。
与其他语言一样，Lean 也有用于构建多文件包和管理依赖项的工具。
标准的 Lean 构建工具称为 Lake（Lean Make 的缩写），并且是在 Lean 中进行配置的。
就像 Lean 包含用于编写带有效果的程序的特殊目的语言（`do` 语言）一样，Lake 包含用于配置构建的特殊目的语言。
这些语言被称为 _嵌入式领域特定语言_（也有时称为 _领域特定嵌入语言_，简称 EDSL 或 DSEL）。
它们是_领域特定_的，意味着它们用于特定的目的，带有某个子域中的概念，并且通常不适用于通用编程。
它们是_嵌入式的_，因为它们出现在另一种语言的语法中。
尽管 Lean 包含创建 EDSL 的丰富工具，但它们超出了本书的范围。

## 第一步

要开始使用 Lake 的项目，请在尚未包含名为 `greeting` 的文件或目录的目录中使用命令 `{{#command {first-lake} {lake} {lake new greeting} }}`。
这将创建一个名为 `greeting` 的目录，其中包含以下文件:

 * `Main.lean` 是 Lean 编译器将查找 `main` 动作的文件。
 * `Greeting.lean` 是程序的支持库的框架。
 * `lakefile.lean` 包含了 `lake` 构建应用所需的配置。
 * `lean-toolchain` 包含了项目所使用的特定版本的 Lean 的标识符。

此外，`lake new` 还将初始化项目为 Git 存储库，并配置其 `.gitignore` 文件以忽略中间构建产品。
通常，大部分应用程序逻辑将位于一组用于程序的库中，而 `Main.lean` 将包含这些部分的小包装器，用于执行解析命令行和执行中心应用程序逻辑等任务。
要在已经存在的目录中创建项目，请运行 `lake init` 而不是 `lake new`。

默认情况下，库文件 `Greeting.lean` 包含以下定义：

```lean
{{#file_contents {lake} {first-lake/greeting/Greeting.lean} {first-lake/expected/Greeting.lean}}}
```

虽然可执行源文件 `Main.lean` 包含以下内容：

```lean
{{#file_contents {lake} {first-lake/greeting/Main.lean} {first-lake/expected/Main.lean}}}
```

`import` 行使得 `Greeting.lean` 中的内容可以在 `Main.lean` 中使用。
将名称用书名号括起来，比如 `«Greeting»`，允许它包含空格或其他在 Lean 名称中通常不允许出现的字符，并且它允许使用保留关键字作为普通名称，如 `«if»` 或 `«def»`。
这样可以避免在 `lake new` 提供的包名中包含这些字符时出现问题。

要构建该包，请运行命令 `{{#command {first-lake/greeting} {lake} {lake build} }}`。
一些构建命令会显示出来，最终生成的二进制文件将被放置在 `build/bin` 目录中。
运行 `{{#command {first-lake/greeting} {lake} {./build/bin/greeting} }}` 将得到 `{{#command_out {lake} {./build/bin/greeting} }}`。

## Lakefiles

`lakefile.lean` 描述了一个 _包_，它是一组连贯的用于分发的 Lean 代码，类似于 `npm` 或 `nuget` 包或 Rust 的 crate。
一个包可以包含任意数量的库或可执行文件。
虽然 [Lake 的文档](https://github.com/leanprover/lake#readme) 描述了 lakefile 中可用的选项，但它使用了一些尚未在这里介绍的 Lean 特性。
生成的 `lakefile.lean` 如下所示：

```lean
{{#file_contents {lake} {first-lake/greeting/lakefile.lean} {first-lake/expected/lakefile.lean}}}
```

这个初始的Lakefile包含了三个项目：

* 一个名为 `greeting` 的 _包_ 声明，
* 一个名为 `Greeting` 的 _库_ 声明，
* 一个也名为 `greeting` 的 _可执行文件_。

每个名称都用法式引号括起来，以便用户在选择包名时有更多的自由。

每个Lakefile只包含一个包，但可以包含任意数量的库或可执行文件。
此外，Lakefiles 可能包含 _外部库_，这些库不是用 Lean 编写的，而是与生成的可执行文件静态链接的库，_自定义目标_，即不适合放入库/可执行文件层次结构的构建目标，_依赖项_，即其他 Lean 包（可以是本地或远程 Git 存储库）的声明，以及 _脚本_，这些本质上是 `IO` 操作（类似于 `main`），但还可以访问有关包配置的元数据。
Lakefile 中的项目允许配置源文件位置、模块层次结构和编译器标志。
一般来说，使用默认值就足够了。

库、可执行文件和自定义目标都称为 _目标_。
默认情况下，`lake build` 命令会构建用 `@[default_target]` 注解的目标。
这个注解是一个 _属性_，它是可以与 Lean 声明关联起来的元数据。
属性类似于 Java 注解或 C# 和 Rust 属性。
在 Lean 中，它们被广泛地使用。
要构建未用 `@[default_target]` 注解的目标，请在 `lake build` 后面指定目标的名称作为参数。

## 库和导入

Lean 库是一个层次组织的源文件集合，可以从中导入名称，这些文件被称为 _模块_。
默认情况下，一个库有一个与其名称匹配的根文件。
在这种情况下，库 `Greeting` 的根文件是 `Greeting.lean`。
`Main.lean` 的第一行代码 `import Greeting` 将 `Greeting.lean` 的内容导入到 `Main.lean` 中。

可以通过创建一个名为 `Greeting` 的目录并将其他模块文件放在其中来向库中添加额外的模块。
这些模块可以通过将目录分隔符替换为点来导入。
例如，可以创建文件 `Greeting/Smile.lean`，其内容为：

```lean
{{#file_contents {lake} {second-lake/greeting/Greeting/Smile.lean}}}
```

这意味着 `Main.lean` 可以使用以下定义：

```lean
{{#file_contents {lake} {second-lake/greeting/Main.lean}}}
```

模块名称的层次结构与命名空间的层次结构是解耦的。
在 Lean 中，模块是代码分发的单位，而命名空间是代码组织的单位。
也就是说，在模块 `Greeting.Smile` 中定义的名称不会自动进入相应的命名空间 `Greeting.Smile`。
模块可以将名称放置在任何他们喜欢的命名空间中，导入它们的代码可以选择是否 `open` 命名空间。
使用 `import` 可以使源文件的内容可用，而使用 `open` 可以使命名空间的名称在当前上下文中可用，无需加前缀。
在 Lakefile 中，`import Lake` 这一行使得 `Lake` 模块的内容可用，而 `open Lake DSL` 这一行则使得 `Lake` 和 `Lake.DSL` 这两个命名空间的内容在当前上下文中可用，无需加任何前缀。
打开 `Lake.DSL` 是因为打开 `Lake` 后，`Lake.DSL` 也可通过 `DSL` 来访问，就像 `Lake` 命名空间中的其他名称一样。
`Lake` 模块将名称放置在 `Lake` 和 `Lake.DSL` 两个命名空间中。

命名空间也可以被进行有选择地打开，只有它们的某些名称可以在当前上下文中无需显式前缀地使用。
这可以通过在括号中写入所需的名称来实现。
例如，`Nat.toFloat` 将自然数转换为 `Float` 类型。
可以使用 `open Nat (toFloat)` 将其作为 `toFloat` 可用。