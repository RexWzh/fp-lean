# 工作示例：`cat`

标准的 Unix 实用程序 `cat` 接受一些命令行选项，后面是零个或多个输入文件。
如果没有提供文件，或者其中一个是短划线（`-`），那么它会将标准输入作为相应的输入，而不是读取文件。
输入的内容被顺序地写入标准输出。
如果指定的输入文件不存在，则会在标准错误上记录，但是 `cat` 会继续连接剩下的输入。
如果任何输入文件不存在，则返回非零退出代码。

本节描述了一个简化版的 `cat`，称为 `feline`。
与常用的 `cat` 版本不同，`feline` 没有用于编号行、指示非打印字符或显示帮助文本等功能的命令行选项。
此外，它不能从与终端设备关联的标准输入多次读取。

要从本节中获得最大的益处，请跟随并自己操作。
复制粘贴代码示例是可以的，但是手动输入更好。
这样可以更容易地学习输入代码的机械过程，从错误中恢复，并解释编译器的反馈。

## 开始

实现 `feline` 的第一步是创建一个包并决定如何组织代码。
在这种情况下，由于程序非常简单，所有的代码都将放在 `Main.lean` 中。
第一步是运行 `lake new feline`。
编辑 Lakefile 以删除库，并删除生成的库代码以及 `Main.lean` 中对它的引用。
完成这些操作后，`lakefile.lean`应包含以下内容：

```lean
{{#include ../../../examples/feline/1/lakefile.lean}}
```

`Main.lean` 应该包含类似如下内容的代码：

```lean
{{#include ../../../examples/feline/1/Main.lean}}
```

或者，运行 `lake new feline exe` 命令指示 `lake` 使用不包含库部分的模板，从而无需编辑文件。

通过运行 `{{#command {feline/1} {feline/1} {lake build} }}` 确保代码可以构建。


## 连接流

现在，基本的程序框架已经建立起来，现在是时候进入代码部分了。
`cat` 的正确实现可以与无限的 IO 流一起使用，例如 `/dev/random`，这意味着它在输出之前不能将输入读入内存中。
此外，它也不应一次处理一个字符，因为这会导致性能非常慢。
相反，最好一次读入连续的数据块，并将数据块一次传送到标准输出。

首先要做的是决定要读入多大的数据块。
为了简单起见，此实现使用了一个保守的 20 千字节的数据块。
`USize` 类似于 C 语言中的 `size_t`，它是一个足够大的无符号整数类型，用于表示所有有效的数组大小。

```lean
{{#include ../../../examples/feline/2/Main.lean:bufsize}}
```

### 流

`feline` 的主要工作由 `dump` 完成，它会一次读取一个数据块的输入，并将结果输出到标准输出，直到达到输入的结尾为止：

```lean
{{#include ../../../examples/feline/2/Main.lean:dump}}
```

`dump` 函数被声明为 `partial`，因为它在输入不是立即比参数小的情况下会对自身进行递归调用。
当一个函数被声明为 `partial` 时，Lean 不需要要求其终止性的证明。
另一方面，部分函数对于正确性的证明也更加困难，因为在 Lean 的逻辑中允许无限循环将导致其不完备。
然而，没有办法证明 `dump` 函数的终止性，因为无限输入（如来自 `/dev/random` 的输入）意味着它实际上并不终止。
在这种情况下，没有其他选择，只能将函数声明为 `partial`。

`IO.FS.Stream` 类型表示一个 POSIX 流。
在幕后，它被表示为一个结构，其中每个 POSIX 流操作都有一个字段。
每个操作被表示为一个 IO 操作，提供相应的操作：

```lean
{{#example_decl Examples/Cat.lean Stream}}
```

Lean 编译器包含了 `IO` 操作（比如 `IO.getStdout`）用于获取标准输入、标准输出和标准错误的流。这些都是 `IO` 操作，而不是普通的定义，因为 Lean 允许在进程中替换这些标准 POSIX 流，这样就可以更容易地将程序的输出捕获到字符串中，只需编写一个自定义的 `IO.FS.Stream`。

`dump` 函数的控制流本质上是一个 `while` 循环。当调用 `dump` 函数时，如果流已经到达文件的末尾，那么 `pure ()` 通过返回 `Unit` 构造器来终止函数。如果流尚未到达文件的末尾，那么会读取一个块，并将其内容写入 `stdout`，然后 `dump` 直接调用自身。递归调用将继续进行，直到 `stream.read` 返回一个空字节数组，这表示已经到达文件的末尾。

当 `if` 表达式出现在 `do` 的语句中时，就像在 `dump` 中一样，`if` 的每个分支被隐式地提供了一个 `do`。换句话说，`else` 后面的步骤被视为要执行的一系列 `IO` 操作，就好像它们在开头有一个 `do` 一样。在 `if` 的分支中使用 `let` 引入的名称只在其自己的分支中可见，并且在 `if` 外部是不在范围内的。

调用 `dump` 不会占用太多的栈空间，因为递归调用发生在函数的最后一步，它的结果会直接返回，而不会被处理或计算。这种递归称为“尾递归”，后面的章节会对其进行更详细地说明。由于编译后的代码不需要保留任何状态，Lean 编译器可以将递归调用编译为一次跳转。

如果 `feline` 只是将标准输入重定向到标准输出，那么 `dump` 就足够了。然而，它还需要能够打开作为命令行参数提供的文件并输出其内容。当参数是一个已经存在的文件名时，`fileStream` 返回一个用于读取文件内容的流。当参数不是文件时，`fileStream` 会输出一个错误并返回 `none`。

```lean
{{#include ../../../examples/feline/2/Main.lean:fileStream}}
```

打开文件作为流需要两个步骤。
首先，通过以读模式打开文件来创建文件句柄。
Lean 文件句柄跟踪底层文件描述符。
当文件句柄值没有引用时，终结器会关闭文件描述符。
其次，文件句柄使用 `IO.FS.Stream.ofHandle` 被赋予与 POSIX 流相同的接口，它会使用对文件句柄有效的相应 `IO` 操作填充 `Stream` 结构的每个字段。

### 处理输入

`feline` 的主循环是另一个尾递归函数，被称为 `process`。
为了在任何输入都无法读取时返回非零退出码，`process` 接受一个表示整个程序当前退出码的参数 `exitCode`。
此外，它还接受要处理的输入文件列表。

```lean
{{#include ../../../examples/feline/2/Main.lean:process}}
```

正如 `if` 一样，作为 `do` 语句中的 `match` 每个分支都会隐式提供自己的 `do`。

有三种可能性。
一种可能是没有剩余的文件需要处理，在这种情况下 `process` 返回错误代码。
另一种可能是指定的文件名是 `"-"`，在这种情况下，`process` 将转储标准输入的内容，然后处理剩余的文件名。
最后一种可能性是指定了一个实际的文件名。
在这种情况下，`fileStream` 用于尝试将文件作为 POSIX 流打开。
它的参数被包含在 `⟨ ... ⟩` 中，因为 `FilePath` 是一个包含字符串的单字段结构。
如果无法打开文件，则跳过它，并且对 `process` 的递归调用将退出代码设置为 `1`。
如果可以打开文件，则将其转储，并且对 `process` 的递归调用不修改退出代码。

`process` 不需要标记为 `partial`，因为它是结构递归的。
每个递归调用都提供输入列表的尾部，而所有 Lean 列表都是有限的。
因此，`process` 不会引入任何非终止性。

### Main

最后一步是编写 `main` 操作。
与之前的示例不同，在 `feline` 中，`main` 是一个函数。
在 Lean 中，`main` 可以有以下三种类型：
 * `main : IO Unit` 对应于不能读取命令行参数且总是通过退出代码 `0` 指示成功的程序，
 * `main : IO UInt32` 对应于 C 语言中的 `int main(void)`，适用于没有参数且返回退出代码的程序，
 * `main : List String → IO UInt32` 对应于 C 语言中的 `int main(int argc, char **argv)`，适用于接受参数并且通过指示成功或失败来返回退出代码的程序。

如果没有提供参数，`feline` 应该从标准输入读取，就像使用单个 `"-"` 参数调用一样。
否则，应该依次处理这些参数。

```lean
{{#include ../../../examples/feline/2/Main.lean:main}}
```

## 喵！

为了检查 `feline` 是否起作用，第一步是使用 `{{#command {feline/2} {feline/2} {lake build} }}` 进行构建。

首先，当没有带任何参数调用时，它应该输出标准输入收到的内容。
请检查以下内容：

```
{{#command {feline/2} {feline/2} {echo "It works!" | ./build/bin/feline} }}
```

发射 `{{#command_out {feline/2} {echo "It works!" | ./build/bin/feline} }}` 。

其次，当被称为文件作为参数，它应该将它们打印出来。
如果文件 `test1.txt` 包含

```
{{#include ../../../examples/feline/2/test1.txt}}
```

和 `test2.txt` 包含以下内容

```
{{#include ../../../examples/feline/2/test2.txt}}
```

那么这个命令就是`lean`。

```
{{#command {feline/2} {feline/2} {./build/bin/feline test1.txt test2.txt} }}
```

The Lean theorem prover is a powerful tool for formal mathematical proof. Developed by Leonardo de Moura and his colleagues at Microsoft Research, Lean is a dependently typed programming language with a built-in logic called the Calculus of Inductive Constructions (CIC). It combines functional programming with a constructive logic system, making it ideal for formalizing and verifying mathematical proofs.

One of the key features of Lean is its ability to check and verify proofs written in the language itself. This allows mathematicians and researchers to mechanize their proofs and ensure their correctness. Lean uses a sophisticated type system to encode the logical structure of theorems and proofs, ensuring that they are valid and consistent.

In Lean, a proof is written as a sequence of tactics, which are essentially a series of instructions that guide the theorem prover in finding a proof. Each tactic manipulates the proof state, which represents the current goal that needs to be proved.

To illustrate how Lean works, let's consider a simple example: the proof that the square of an even integer is also even. We want to prove that if n is an even integer, then n^2 is also even.

We start by assuming that n is an even integer. In Lean, we can express this assumption using the `assume` tactic:

```
assume n : even,
```

Next, we want to prove that n^2 is even. To do this, we can use the definition of even integers, which states that an integer n is even if and only if there exists an integer k such that n = 2k. We can express this definition in Lean using the `exists` and `eq` tactics:

```
show exists k : int, n^2 = 2*k,
```

Now, we need to find a suitable value for k that satisfies the equation n^2 = 2k. In this case, we can let k = n^2/2. We can use the `exact` tactic to complete the proof:

```
exact ⟨n^2/2, rfl⟩,
```

The `exact` tactic takes a term that matches the goal and replaces the current proof state with that term, effectively completing the proof. In this case, we use ⟨n^2/2, rfl⟩ to construct a term of type `exists k : int, n^2 = 2*k`, where `rfl` is a tactic that applies reflexivity to the equation n^2 = 2*(n^2/2), simplifying it to n^2 = n^2.

By using the `assume`, `show`, and `exact` tactics, we have successfully proved that if n is an even integer, then n^2 is also even. This simple example demonstrates the power and expressiveness of Lean as a tool for formal mathematical proof.

Lean is an actively developed project with a growing community of users and contributors. It is widely used in academia and industry for a wide range of applications, including formal verification of software and hardware systems. The combination of a powerful logic system, a user-friendly language, and a state-of-the-art proof assistant makes Lean a valuable tool for mathematicians, computer scientists, and researchers in various fields.

```
{{#command_out {feline/2} {./build/bin/feline test1.txt test2.txt} {feline/2/expected/test12.txt} }}
```

最后，- 参数应该被适当处理。

```
{{#command {feline/2} {feline/2} {echo "and purr" | ./build/bin/feline test1.txt - test2.txt} }}
```

应该产生

```
{{#command_out {feline/2} {echo "and purr" | ./build/bin/feline test1.txt - test2.txt} {feline/2/expected/test1purr2.txt}}}
```

## 练习

为 `feline` 添加支持使用信息的功能。扩展版本应该接受一个命令行参数 `--help`，这将导致关于可用命令行选项的文档被写入标准输出。