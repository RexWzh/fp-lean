# 插入排序和数组变异

尽管插入排序在最坏情况下的时间复杂度不是最优的，但它仍具有许多有用的属性：
 * 简单易懂，易于实现和理解
 * 是一种原地算法，不需要额外的空间
 * 是一种稳定排序算法
 * 当输入数据已经近乎有序时，插入排序速度很快

在 Lean 中，原地算法特别有用，因为它管理内存的方式。
在某些情况下，通常需要复制数组的操作可以优化为变异。
这包括交换数组中的元素。

大多数具有自动内存管理的编程语言和运行时系统，包括 JavaScript、JVM 和 .NET，都使用追踪垃圾收集。
当需要回收内存时，系统从一些 _根_ 开始（如调用栈和全局变量），然后通过递归地追踪指针来确定可以访问哪些值。
无法访问的值将被释放，释放内存。

引用计数是一种替代追踪垃圾收集的方法，许多语言使用它，包括 Python、Swift 和 Lean。
在引用计数系统中，内存中的每个对象都有一个字段用于跟踪对它的引用数量。
当建立新引用时，计数器递增。
当引用不再存在时，计数器递减。
当计数器达到零时，对象立即被释放。

与追踪垃圾收集相比，引用计数有一个主要缺点：循环引用可能导致内存泄漏。
如果对象 \\( A \\) 引用对象 \\( B \\)，而对象 \\( B \\) 又引用对象 \\( A \\)，即使程序中没有其他引用 \\( A \\) 或 \\( B \\)，它们也永远不会被释放。
循环引用要么源自无限递归，要么源自可变引用。
因为 Lean 不支持无限递归和可变引用，所以不可能构造循环引用。

引用计数意味着 Lean 运行时系统用于分配和释放数据结构的原语可以检查引用计数是否即将降至零，并在不分配新对象的情况下重复使用现有对象。
当处理大型数组时，这一点尤为重要。

为 Lean 数组实现的插入排序应满足以下几个条件：
 1. Lean 应该接受没有 `partial` 注释的函数
 2. 如果传递的数组没有其他引用，则应该原地修改数组，而不是分配一个新的数组
第一个判据很容易验证：如果 Lean 接受了定义，那么它就满足了。
然而，第二个判据需要一种测试的方法。
Lean 提供了一个内置函数 `dbgTraceIfShared`，具有以下签名：

```lean
{{#example_in Examples/ProgramsProofs/InsertionSort.lean dbgTraceIfSharedSig}}
```



```output info
{{#example_out Examples/ProgramsProofs/InsertionSort.lean dbgTraceIfSharedSig}}
```

LEAN 定理证明的文章如下：

```markdown
它接受一个字符串和一个值作为参数，并在值具有多个引用时，使用字符串将消息打印到标准错误输出，然后返回该值。
严格来说，这不是一个纯函数。
然而，它只用于开发过程中，以检查一个函数是否能够重用内存而不是分配和复制。

在学习使用`dbgTraceIfShared`时，重要的是要知道，使用`#eval`报告的共享值比在编译的代码中要多得多。
这可能会导致困惑。
重要的是要使用`lake`构建可执行文件，而不是在编辑器中进行实验。

插入排序由两个循环组成。
外部循环将指针从左到右移动到要排序的数组上。
每次迭代后，指针左侧的区域已排序，而右侧的区域可能尚未排序。
内部循环将指针指向的元素向左移动，直到找到合适的位置并恢复循环不变式。
换句话说，每次迭代将数组的下一个元素插入到已排序区域的适当位置处。

## 内部循环

插入排序的内部循环可以作为尾递归函数实现，它接受数组和插入元素的索引作为参数。
插入的元素将与其左侧的元素反复交换，直到左侧的元素较小或数组的开头被到达为止。
内部循环在用于索引数组的`Fin`中的`Nat`上进行结构递归：
```


```leantac
{{#example_decl Examples/ProgramsProofs/InsertionSort.lean insertSorted}}
```

如果索引`i`是`0`，那么被插入已排序区域的元素已经到达区域的开头，并且是最小的。
如果索引是`i’+1`，那么`i’`处的元素应该与`i`处的元素进行比较。
请注意，虽然`i`是`Fin arr.size`类型，但`i’`只是`Nat`类型，因为它是`i`的`val`字段的结果。
因此在使用`i'`作为`arr`的索引之前，需要证明`i' < arr.size`。

省略了关于`i' < arr.size`的证明的`have`表达式，将出现以下目标：

```output error
{{#example_out Examples/ProgramsProofs/InsertionSort.lean insertSortedNoProof}}
```

Lean的标准库中有一个名为`Nat.lt_of_succ_lt`的重要定理。我们可以通过使用命令`{{#example_in Examples/ProgramsProofs/InsertionSort.lean lt_of_succ_lt_type}}`来找到它的签名。

```output info
{{#example_out Examples/ProgramsProofs/InsertionSort.lean lt_of_succ_lt_type}}
```

换句话说，该定理说明如果 `n + 1 < m`，那么 `n < m`。
传递给 `simp` 的 `*` 导致它将 `Nat.lt_of_succ_lt` 与 `i` 的 `isLt` 字段组合，得出最终的证明。

在确立了 `i'` 可以用来查找要插入的元素左侧的元素后，就会查找并比较这两个元素。
如果左侧的元素小于或等于要插入的元素，则循环结束，不变性得到恢复。
如果左侧的元素大于要插入的元素，则交换这两个元素，并再次开始内部循环。
`Array.swap` 接受两个 `Fin` 类型的索引，而 `i' < arr.size` 的 `by assumption` 则使用了 `have`。
下一轮内部循环要检查的索引也是 `i'`，但是这种情况下 `by assumption` 是不够的。
这是因为证明是针对原始数组 `arr` 编写的，而不是交换两个元素后的结果数组。
`simp` 策略的数据库包含了交换数组两个元素不会改变其大小的事实，而 `[*]` 参数指示它额外使用 `have` 引入的假设。

## 外部循环

插入排序的外部循环将指针从左到右移动，在每次迭代中调用 `insertSorted` 将指针处的元素插入数组的正确位置。
循环的基本形式类似于 `Array.map` 的实现：

```lean
{{#example_in Examples/ProgramsProofs/InsertionSort.lean insertionSortLoopTermination}}
```

在 `Array.map` 上没有使用 `termination_by` 子句时，导致的错误和没有降低每个递归调用参数的错误是相同的：

```output error
{{#example_out Examples/ProgramsProofs/InsertionSort.lean insertionSortLoopTermination}}
```

在构建终止证明之前，使用 `partial` 修饰符来测试定义的正确性是很方便的，以确保它能够返回预期的答案：

```lean
{{#example_decl Examples/ProgramsProofs/InsertionSort.lean partialInsertionSortLoop}}
```



```lean
{{#example_in Examples/ProgramsProofs/InsertionSort.lean insertionSortPartialOne}}
```



```output info
{{#example_out Examples/ProgramsProofs/InsertionSort.lean insertionSortPartialOne}}
```



```lean
{{#example_in Examples/ProgramsProofs/InsertionSort.lean insertionSortPartialTwo}}
```



```output info
{{#example_out Examples/ProgramsProofs/InsertionSort.lean insertionSortPartialTwo}}
```

### 终止条件

同样，该函数之所以终止，是因为在每次递归调用时，处理的数组的索引和大小之间的差异减小了。

然而，这一次 Lean 并不接受 `termination_by`：

```lean
{{#example_in Examples/ProgramsProofs/InsertionSort.lean insertionSortLoopProof1}}
```



```output error
{{#example_out Examples/ProgramsProofs/InsertionSort.lean insertionSortLoopProof1}}
```

问题在于 Lean 无法知道 `insertSorted` 返回的数组与传入的数组大小相同。
为了证明 `insertionSortLoop` 的终止性，首先需要证明 `insertSorted` 不会改变数组的大小。
通过将错误消息中的未经证明的终止条件复制到函数中，并使用 `sorry` 进行“证明”，可以暂时接受该函数：

```leantac
{{#example_in Examples/ProgramsProofs/InsertionSort.lean insertionSortLoopSorry}}
```



```output warning
{{#example_out Examples/ProgramsProofs/InsertionSort.lean insertionSortLoopSorry}}
```

因为`insertSorted`在插入的元素索引上具有结构化递归，所以证明应该通过对索引进行归纳来完成。
在基本情况下，数组保持不变，因此它的长度肯定不会改变。
对于归纳步骤，归纳假设是在更小的索引上进行递归调用不会改变数组的长度。
有两种情况需要考虑：要么元素已经完全插入到排序区域，并且数组保持不变，在这种情况下长度也保持不变，要么在递归调用之前，元素被与下一个元素交换。
然而，交换数组中的两个元素不会改变其大小，并且归纳假设表明对于下一个索引的递归调用返回的数组与其参数的大小相同。
因此，大小保持不变。

将这个英文的定理陈述翻译成 Lean，然后使用本章的技术进行推导就足以证明基本情况，并在归纳步骤中取得进展：

```leantac
{{#example_in Examples/ProgramsProofs/InsertionSort.lean insert_sorted_size_eq_0}}
```

在归纳步骤中使用 `insertSorted` 进行简化，揭示出了 `insertSorted` 中的模式匹配。

```output error
{{#example_out Examples/ProgramsProofs/InsertionSort.lean insert_sorted_size_eq_0}}
```

当面对包含 `if` 或 `match` 的目标时，`split` 策略（与在归并排序的定义中使用的 `split` 函数不要混淆）会将目标替换为每个控制流路径的新目标：

```leantac
{{#example_in Examples/ProgramsProofs/InsertionSort.lean insert_sorted_size_eq_1}}
```

另外，每个新目标都有一个假设，指明了导致该目标的分支，这种情况下命名为 `heq✝` ：

```output error
{{#example_out Examples/ProgramsProofs/InsertionSort.lean insert_sorted_size_eq_1}}
```

不必为两种简单情况编写证明，只需在 `split` 后面添加 `<;> try rfl`，这样两种直截了当的情况将立即消失，只剩下一个目标：

```leantac
{{#example_in Examples/ProgramsProofs/InsertionSort.lean insert_sorted_size_eq_2}}
```



```output error
{{#example_out Examples/ProgramsProofs/InsertionSort.lean insert_sorted_size_eq_2}}
```

不幸的是，归纳假设的强度不足以证明这个目标。
归纳假设是指调用`insertSorted`方法时，`arr`的大小不变，但证明目标是要显示调用结果与交换结果的递归调用的大小不变。
成功完成证明需要一个对传递给`insertSorted`方法的任何数组都适用的归纳假设。

通过在`induction`策略中使用`generalizing`选项，可以获得强大的归纳假设。
这个选项会将上下文中的附加假设引入到生成基本情况、归纳假设和归纳步骤中要显示的目标中。
对`arr`进行泛化将导致更强的假设：

```leantac
{{#example_in Examples/ProgramsProofs/InsertionSort.lean insert_sorted_size_eq_3}}
```

在结果目标中，`arr` 现在成为带有 "for all" 声明的归纳假设的一部分：

```output error
{{#example_out Examples/ProgramsProofs/InsertionSort.lean insert_sorted_size_eq_3}}
```

然而，整个证明过程正在变得难以管理。
下一步将是引入一个变量，表示交换后结果的长度，并证明它等于 `arr.size`，然后证明该变量也等于递归调用所得到的数组的长度。
这些等式可以链接在一起，以证明目标。
然而，更容易的方法是仔细重新表述定理陈述，使归纳假设自动足够强大，并且变量已经被引入。
重新表述的陈述如下:

```leantac
{{#example_in Examples/ProgramsProofs/InsertionSort.lean insert_sorted_size_eq_redo_0}}
```

这个版本的定理陈述更容易证明，因为有几个原因：
1. 定理中的索引和索引有效性的证明都被打包在一个 `Fin` 类型中，而这个版本的索引放在数组之前。
   这样一来，归纳假设可以自然地推广到数组和索引为 `i` 的有效性证明。
2. 引入了一个抽象的长度 `len` 来代表 `array.size`。
   证明自动化往往更擅长处理显式的相等性陈述。

得到的证明状态显示了用于生成归纳假设的陈述，以及归纳步骤的基本情况和目标：

```output error
{{#example_out Examples/ProgramsProofs/InsertionSort.lean insert_sorted_size_eq_redo_0}}
```

比较这个陈述与`归纳`策略导致的目标：

LEAN 定理证明的目标可以通过应用 `induction` 策略来生成。该策略用于从一个特定的基础情形开始，逐步推广到更一般的情形。它是一种证明通用命题的强大工具。

然而，从上面的陈述可以看出，与 `induction` 策略的目标相比，此陈述并没有明确指定使用 `induction` 的详细过程。它仅说明了一个定理的证明，缺乏具体的步骤和论证，不能直接应用 `induction` 策略。

为了能够将该陈述与 `induction` 策略进行比较，我们需要进一步分析该陈述的详细内容以及是否适用于 `induction` 策略的应用。

```leantac
{{#example_in Examples/ProgramsProofs/InsertionSort.lean insert_sorted_size_eq_redo_1a}}
```

在基本情况下，每个`i`的出现都被替换为`0`。
使用`intro`引入每个假设，然后使用`insertSorted`进行简化将证明目标，因为`insertSorted`在索引`zero`处返回其参数不变：

```output error
{{#example_out Examples/ProgramsProofs/InsertionSort.lean insert_sorted_size_eq_redo_1a}}
```

在归纳步骤中，归纳假设的强度恰到好处。
只要数组的长度为 `len`，它对于**任何**数组都是有用的：

```output error
{{#example_out Examples/ProgramsProofs/InsertionSort.lean insert_sorted_size_eq_redo_1b}}
```

在基本情况下，`simp` 将目标缩小为 `arr.size = len`：

```leantac
{{#example_in Examples/ProgramsProofs/InsertionSort.lean insert_sorted_size_eq_redo_2}}
```



```output error
{{#example_out Examples/ProgramsProofs/InsertionSort.lean insert_sorted_size_eq_redo_2}}
```

这可以通过使用假设 `hLen` 进行证明。
将 `simp` 函数的参数中添加 `*`，指示它同时使用假设，这样就可以解决当前的目标问题了：

```leantac
{{#example_in Examples/ProgramsProofs/InsertionSort.lean insert_sorted_size_eq_redo_2b}}
```

在归纳步骤中，引入假设并简化目标会再次产生一个包含模式匹配的目标：

```leantac
{{#example_in Examples/ProgramsProofs/InsertionSort.lean insert_sorted_size_eq_redo_3}}
```



```output error
{{#example_out Examples/ProgramsProofs/InsertionSort.lean insert_sorted_size_eq_redo_3}}
```

使用 `split` 策略会为每个模式生成一个目标。
再次强调，前两个目标由没有递归调用的分支产生，因此归纳假设不是必需的：

```leantac
{{#example_in Examples/ProgramsProofs/InsertionSort.lean insert_sorted_size_eq_redo_4}}
```



```output error
{{#example_out Examples/ProgramsProofs/InsertionSort.lean insert_sorted_size_eq_redo_4}}
```

在每个通过 `split` 分割得到的目标中运行 `try assumption` 可以消除这两个非递归目标：

```leantac
{{#example_in Examples/ProgramsProofs/InsertionSort.lean insert_sorted_size_eq_redo_5}}
```



```output error
{{#example_out Examples/ProgramsProofs/InsertionSort.lean insert_sorted_size_eq_redo_5}}
```

在证明目标的新表述中，使用常量 `len` 来表示递归函数中涉及到的所有数组的长度，这样的表述非常适合 `simp` 可以解决的问题类型。
使用 `simp [*]` 可以解决这个最终的证明目标，因为与数组长度有关的假设是重要的：

```leantac
{{#example_decl Examples/ProgramsProofs/InsertionSort.lean insert_sorted_size_eq_redo_6}}
```

最后，因为 `simp [*]` 可以使用前提假设，所以 `try assumption` 这一行可以被 `simp [*]` 替换，以缩短证明的长度：

```leantac
{{#example_decl Examples/ProgramsProofs/InsertionSort.lean insert_sorted_size_eq_redo}}
```

这个证明现在可以用来替换`insertionSortLoop`中的`sorry`。
将`arr.size`作为定理的`len`参数提供，会导致最终结论为`(insertSorted arr ⟨i, isLt⟩).size = arr.size`，所以重写过程以一个非常可处理的证明目标结束：

```leantacnorfl
{{#example_in Examples/ProgramsProofs/InsertionSort.lean insertionSortLoopRw}}
```



```output error
{{#example_out Examples/ProgramsProofs/InsertionSort.lean insertionSortLoopRw}}
```

The proof `{{#example_in Examples/ProgramsProofs/InsertionSort.lean sub_succ_lt_self_type}}` is part of Lean's standard library.
Its type is `{{#example_out Examples/ProgramsProofs/InsertionSort.lean sub_succ_lt_self_type}}`, which is exactly what's needed:

这个证明 `{{#example_in Examples/ProgramsProofs/InsertionSort.lean sub_succ_lt_self_type}}` 是 Lean 标准库的一部分。
它的类型是 `{{#example_out Examples/ProgramsProofs/InsertionSort.lean sub_succ_lt_self_type}}`，这恰好就是我们需要的：

```leantacnorfl
{{#example_decl Examples/ProgramsProofs/InsertionSort.lean insertionSortLoop}}
```

## 驱动函数

插入排序本身调用 `insertionSortLoop` 函数，将标记数组中已排序区域和未排序区域的索引初始化为 `0` ：

```lean
{{#example_decl Examples/ProgramsProofs/InsertionSort.lean insertionSort}}
```

一些快速测试表明这个函数至少没有明显的错误：

```lean
{{#example_in Examples/ProgramsProofs/InsertionSort.lean insertionSortNums}}
```



```output info
{{#example_out Examples/ProgramsProofs/InsertionSort.lean insertionSortNums}}
```



```lean
{{#example_in Examples/ProgramsProofs/InsertionSort.lean insertionSortStrings}}
```



```output info
{{#example_out Examples/ProgramsProofs/InsertionSort.lean insertionSortStrings}}
```

## 这真的是插入排序吗？

插入排序的 _定义_ 是一种原地排序算法。
尽管它的最坏情况运行时间是二次的，但它之所以有用是因为它是一种稳定的排序算法，它不分配额外的空间，并且能有效地处理几乎有序的数据。
如果内循环的每次迭代都分配一个新数组，那么这个算法就不是真正的插入排序。

Lean 的数组操作，如 `Array.set` 和 `Array.swap`，会检查所涉及的数组的引用计数是否大于一。
如果是这样，那么这个数组对代码的多个部分是可见的，这意味着它必须被复制。
否则，Lean 就不再是一个纯函数式语言了。
然而，当引用计数恰好为一时，就没有其他潜在的观察者了。
在这些情况下，数组的基本操作就会原地改变数组。
其他部分不知道的事情对它们并没有坏处。

Lean 的证明逻辑是在纯函数式程序的层面上工作的，而不是底层实现。
这意味着发现一个程序是否不必要地复制数据的最好方法是进行测试。
在希望进行变异的每个点添加对 `dbgTraceIfShared` 的调用，当所涉及值的引用超过一时，会将提供的消息打印到 `stderr`。

插入排序只有一个地方有可能进行复制而不是变异：对 `Array.swap` 的调用。
将 `arr.swap ⟨i', by assumption⟩ i` 替换为 `((dbgTraceIfShared "array to swap" arr).swap ⟨i', by assumption⟩ i)` 会导致程序在无法变异数组时发出 `shared RC array to swap`。
然而，对程序的这种更改也会更改证明，因为现在有一个额外的函数调用。
因为 `dbgTraceIfShared` 直接返回其第二个参数，所以将它添加到 `simp` 的调用足以修复证明。

完整的插入排序的带监视代码是：

```leantacnorfl
{{#include ../../../examples/Examples/ProgramsProofs/InstrumentedInsertionSort.lean:InstrumentedInsertionSort}}
```

要检查仪器是否有效，需要一些巧妙的方法。
首先，当所有参数在编译时已知时，Lean 编译器会积极优化函数调用。
仅仅编写一个将 `insertionSort` 应用到一个大数组的程序是不够的，因为生成的编译代码可能只包含已排序的数组作为常量。
确保编译器不会优化掉排序例程的最简单方法是从 `stdin` 读取数组。
其次，编译器进行了死代码消除优化。
在程序中添加额外的 `let` 并不一定会在运行代码中产生更多的引用，如果 `let` 绑定的变量从未被使用。
为了确保额外的引用不会被完全消除，重要的是确保额外的引用被某种方式使用。

测试仪器的第一步是编写 `getLines` 函数，从标准输入中读取一组行：

```lean
{{#include ../../../examples/Examples/ProgramsProofs/InstrumentedInsertionSort.lean:getLines}}
```

`IO.FS.Stream.getLine` 函数返回一行完整的文本，包括结尾的换行符。
当达到文件尾标记时，它会返回 `""`。

然后，需要两个单独的 `main` 程序。
它们都从标准输入中读取要排序的数组，确保在编译时不会将对 `insertionSort` 的调用替换为它们的返回值。
然后，它们都将结果打印到控制台，确保调用 `insertionSort` 不会被完全优化掉。
其中一个只打印排序后的数组，而另一个打印排序后的数组和原始数组。
第二个函数应该触发一个警告，说明 `Array.swap` 必须分配一个新数组：

```lean
{{#include ../../../examples/Examples/ProgramsProofs/InstrumentedInsertionSort.lean:mains}}
```

实际的 `main` 函数根据提供的命令行参数选择其中一个主要操作：

```lean
{{#include ../../../examples/Examples/ProgramsProofs/InstrumentedInsertionSort.lean:main}}
```

运行时如果没有提供任何参数，将显示预期的用法信息：

```
$ lean
Lean (version 3.20.0)
(https://leanprover.github.io)

Usage: lean [options] file.lean
where options include:
  -h, --help             display this help message
  -j, --jobs <num>       number of threads used to process Lean files (default: 0)
  -q, --quiet            do not print verbose messages
  -v, --version          display Lean version number
```

运行 `lean` 命令而没有输入参数，将会显示预期的用法信息：

```
$ lean
Lean (版本 3.20.0)
(https://leanprover.github.io)

用法：lean [选项] file.lean
其中选项包括：
  -h, --help             显示此帮助信息
  -j, --jobs <num>       用于处理 Lean 文件的线程数量（默认为 0）
  -q, --quiet            不显示详细信息
  -v, --version          显示 Lean 版本号
```


```
$ {{#command {sort-demo} {sort-sharing} {./run-usage} {sort}}}
{{#command_out {sort-sharing} {./run-usage} }}
```

文件 `test-data` 包含以下岩石：

```
{{#file_contents {sort-sharing} {sort-demo/test-data}}}
```

使用插入排序对这些岩石进行排序后，将以字母顺序打印它们：

```
$ {{#command {sort-demo} {sort-sharing} {sort --unique < test-data}}}
{{#command_out {sort-sharing} {sort --unique < test-data} }}
```

然而，保留对原始数组的引用的版本会导致在第一次调用 `Array.swap` 时在 `stderr` 上显示一条通知（即 `shared RC array to swap`）。

```
$ {{#command {sort-demo} {sort-sharing} {sort --shared < test-data}}}
{{#command_out {sort-sharing} {sort --shared < test-data} }}
```

只有出现一个 `shared RC` 通知的事实意味着数组只被复制一次。
这是因为通过调用 `Array.swap` 的复制结果本身是唯一的，所以不需要进行进一步的复制。
在命令式语言中，如果在引用传递之前忘记明确复制数组，可能会导致微妙的错误。
在运行 `sort --shared` 时，为了保持 Lean 程序的纯函数含义，数组按需进行复制，但不会超过需要的次数。


## 其他的变异机会

当引用是唯一的时候，使用变异而不是复制的情况不仅限于数组更新操作符。
Lean 也会试图“回收”引用计数即将降至零的构造器，以重复使用它们而不是分配新的数据。
这意味着，例如，`List.map` 会就地更改链表，至少在没有人能够察觉到的情况下。
在优化 Lean 代码中的热循环时，最重要的一步是确保被修改的数据没有被多个位置引用。

## 练习

 * 编写一个反转数组的函数。测试一下，如果输入数组的引用计数为 1，则你的函数不会分配新的数组。

* 为数组实现归并排序或快速排序。证明你的实现会终止，并测试它不会分配超过预期的数组。这是一个具有挑战性的练习！
