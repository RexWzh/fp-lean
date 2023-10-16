# 依赖类型编程的陷阱

依赖类型的灵活性使得类型检查器能够接受更有用的程序，因为类型的语言足够表达出其他不太表达能力的类型系统无法描述的变化。
与此同时，依赖类型的能力可以表达出非常精细的规范，使得更多有缺陷的程序被类型检查器拒绝。
这种能力来自于一定的代价。

像 `Row` 这样的返回类型为类型的函数与它们所产生的类型之间的紧密耦合，是更大的困难的一种例子：当将函数用于类型时，接口和实现的区别开始崩溃。
通常情况下，只要不改变函数的类型签名或输入输出行为，所有的重构都是有效的。
函数可以重写为使用更高效的算法和数据结构，可以修复错误，可以提高代码的清晰性，而不会破坏客户端代码。
然而，当函数被用于类型时，函数实现的内部部分成为类型的一部分，因此也成为另一个程序的接口的一部分。

以以下两个关于 `Nat` 上的加法实现为例。
`Nat.plusL` 对其第一个参数进行递归：

```lean
{{#example_decl Examples/DependentTypes/Pitfalls.lean plusL}}
```

`Nat.plusR`与此相反，在它的第二个参数上是递归的：

```lean
{{#example_decl Examples/DependentTypes/Pitfalls.lean plusR}}
```

两种加法实现都忠实于基本的数学概念，因此在给定相同参数时会返回相同的结果。

然而，当在类型中使用这两个实现时，它们呈现出非常不同的接口。
举个例子，考虑一个将两个 `Vect` 追加起来的函数。
这个函数应该返回一个长度等于参数长度之和的 `Vect`。
因为 `Vect` 本质上是一个 `List`，但其类型更具说明性，所以写这个函数时可以像对待 `List.append` 一样使用模式匹配和递归。
从一个类型签名和初始模式匹配开始，可以得到两条消息：

```lean
{{#example_in Examples/DependentTypes/Pitfalls.lean appendL1}}
```

第一个案例，对于 `nil` 的情况，说明占位符应该被一个长度为 `plusL 0 k` 的 `Vect` 替换：

```output error
{{#example_out Examples/DependentTypes/Pitfalls.lean appendL1}}
```

第二条消息，在 `cons` 的情况下，说明了占位符应该被一个长度为 `plusL (n✝ + 1) k` 的 `Vect` 替换：

```output error
{{#example_out Examples/DependentTypes/Pitfalls.lean appendL2}}
```

在 `n` 之后的符号称为 _dagger_，用于表示 Lean 内部发明的名称。
在幕后，对第一个 `Vect` 进行模式匹配会隐式导致第一个 `Nat` 的值被细化，因为构造函数 `cons` 上的索引是 `n + 1`，而 `Vect` 的尾部长度为 `n`。
在这里，`n✝` 表示比参数 `n` 小 `1` 的 `Nat`。

## 定义等式

在 `plusL` 的定义中，有一个模式情况 `0, k => k`。
这适用于在第一个占位符中使用的长度，因此可以将下划线的类型 `Vect α (Nat.plusL 0 k)` 另写为 `Vect α k`。
类似地，`plusL` 包含一个模式情况 `n + 1, k => plusN n k + 1`。
这意味着第二个下划线的类型可以等价地写为 `Vect α (plusL n✝ k + 1)`。

为了揭示幕后发生的事情，第一步是显式地写出 `Nat` 参数，这样也会导致没有被标记的错误消息，因为名称现在在程序中显式地写出来了：

```lean
{{#example_in Examples/DependentTypes/Pitfalls.lean appendL3}}
```



```output error
{{#example_out Examples/DependentTypes/Pitfalls.lean appendL3}}
```



```output error
{{#example_out Examples/DependentTypes/Pitfalls.lean appendL4}}
```

在使用简化版本的类型对下划线进行注释不会引入类型错误，这意味着程序中写的类型与 Lean 自己找到的类型是等价的：

```lean
{{#example_in Examples/DependentTypes/Pitfalls.lean appendL5}}
```



```output error
{{#example_out Examples/DependentTypes/Pitfalls.lean appendL5}}
```



```output error
{{#example_out Examples/DependentTypes/Pitfalls.lean appendL6}}
```

第一种情况需要一个 `Vect α k` 类型的值，并且 `ys` 具有该类型。
这与将空列表附加到任何其他列表的方式是平行的，返回的结果是另一个列表。
使用 `ys` 而不是第一个下划线来细化定义，得到的程序只剩下一个下划线需要填充：

```lean
{{#example_in Examples/DependentTypes/Pitfalls.lean appendL7}}
```



```output error
{{#example_out Examples/DependentTypes/Pitfalls.lean appendL7}}
```

在这里发生了一些非常重要的事情。
在一个上下文中，Lean 期望一个 `Vect α (Nat.plusL 0 k)`，但实际收到了一个 `Vect α k`。
然而，`Nat.plusL` 不是一个 `abbrev` ，所以看起来它在类型检查过程中不应该运行。
还有其他的事情发生了。

理解所发生的事情的关键在于，在类型检查过程中，Lean 不仅会展开 `abbrev` ，还会在检查两个类型是否等价时执行计算，以确保一个类型的任何表达式都可以在期望另一个类型的上下文中使用。
这个属性被称为定义等价，它是微妙的。

显然，写法相同的两个类型被认为是定义等价的——`Nat` 和 `Nat` 或者 `List String` 和 `List String` 应该被认为是相等的。
任何由不同数据类型构建的具体类型都不相等，所以 `List Nat` 不等于 `Int` 。
此外，只有内部名称不同的类型是相等的，所以 `(n : Nat) → Vect String n` 和 `(k : Nat) → Vect String k` 是相同的。
因为类型可以包含普通数据，定义等价也必须描述数据何时相等。
使用相同构造函数的数据是相等的，所以 `0` 等于 `0`，`[5, 3, 1]` 等于 `[5, 3, 1]`。

然而，类型不仅包含函数箭头、数据类型和构造函数，还包含变量和函数。
变量的定义等价比较简单：每个变量只等于它自己，所以 `(n k : Nat) → Vect Int n` 不等于 `(n k : Nat) → Vect Int k`。
函数则更复杂。
尽管数学上认为如果两个函数具有相同的输入-输出行为，则它们是相等的，但没有高效的算法可以检查这一点，而定义等价的整个目的就是让 Lean 检查两个类型是否可互换。
相反，Lean认为函数在以下情况下是定义等价的：它们都是带有定义等价的函数体的 `fun` 表达式。
换句话说，两个函数必须使用相同的算法调用相同的助手才被认为是定义等价的。
这通常不太有用，所以函数的定义等价主要用于在两个类型中完全相同的定义函数出现时。
当在类型中调用函数时，检查定义相等性可能涉及到函数调用的简化。类型 `Vect String (1 + 4)` 在定义上等于类型 `Vect String (3 + 2)`，因为 `1 + 4` 在定义上等于 `3 + 2`。为了检查它们的相等性，它们都简化为 `5`，然后可以使用构造函数规则五次。函数应用于数据的定义相等性可以首先通过检查它们是否已经相同来进行检查——毕竟，没有必要简化 `["a", "b"] ++ ["c"]` 来检查它是否等于 `["a", "b"] ++ ["c"]`。如果不相等，函数将被调用并替换为其值，然后可以检查该值。

并非所有函数参数都是具体的数据。例如，类型可能包含不是从 `zero` 和 `succ` 构造函数构建的 `Nat`。在类型 `(n : Nat) → Vect String n` 中，变量 `n` 是一个 `Nat`，但在调用函数之前无法知道它是_哪个_ `Nat`。实际上，函数可能首先使用 `0` 调用，然后再使用 `17` 调用，然后再使用 `33` 调用。如 `appendL` 的定义所示，类型为 `Nat` 的变量也可以传递给诸如 `plusL` 的函数。实际上，类型 `(n : Nat) → Vect String n` 在定义上等于类型 `(n : Nat) → Vect String (Nat.plusL 0 n)`。

`n` 和 `Nat.plusL 0 n` 定义上相等的原因是 `plusL` 的模式匹配检查其_第一个_参数。这是有问题的：`(n : Nat) → Vect String n` _不_等于 `(n : Nat) → Vect String (Nat.plusL n 0)`，尽管零应该是加法的左和右单位元。这是因为在遇到变量时，模式匹配会被卡住。在实际值 `n` 可知之前，无法知道应该选择哪种 `Nat.plusL n 0` 情况。

查询示例中的 `Row` 函数也存在相同的问题。类型 `Row (c :: cs)` 不会简化为任何数据类型，因为 `Row` 的定义对于具有一个元素和至少两个元素的列表有不同的情况。
换句话说，当尝试将变量 `cs` 与具体的 `List` 构造函数相匹配时，它就会卡住。这就是为什么几乎每个拆卸或构造 `Row` 的函数都需要与 `Row` 本身匹配相同的三种情况：将其解除卡住可以揭示出可以用于模式匹配或构造函数的具体类型。

在 `appendL` 中缺少的情况需要一个 `Vect α (Nat.plusL n k + 1)`。索引中的 `+ 1` 表示下一步是使用 `Vect.cons`：

```lean
{{#example_in Examples/DependentTypes/Pitfalls.lean appendL8}}
```



```output error
{{#example_out Examples/DependentTypes/Pitfalls.lean appendL8}}
```

递归调用`appendL`可以构造出长度符合要求的`Vect`（向量）：

```lean
def appendL {α : Type} : Π {n m : ℕ}, Vect α n -> Vect α m -> Vect α (n + m)
| _ _ [] v2 := v2
| _ _ (x :: xs) v2 := x :: (appendL xs v2)
```
我们可以看到，`appendL`函数是一个基于列表的递归函数。它以两个参数`n`和`m`作为输入，这两个参数分别代表了待连接向量的长度。

对于空向量，即`[]`，`appendL`函数的输出结果就是第二个向量`v2`。

对于非空向量，即`(x :: xs)`，我们首先取出向量的头元素`x`，然后将它添加到递归调用`appendL xs v2`的结果之前。这样就将两个向量连接起来。

通过这个递归定义，我们可以不断地将`x`添加到`v2`的前面，直到将`v1 = (x :: xs)`中的所有元素都添加到`v2`之前。最终得到的结果就是一个长度为`n + m`的向量。

```lean
{{#example_decl Examples/DependentTypes/Pitfalls.lean appendL9}}
```

程序已经完成了，移除了对 `n` 和 `k` 的显式匹配，使得代码更易读，也更容易调用函数：

```lean
{{#example_decl Examples/DependentTypes/Pitfalls.lean appendL}}
```

使用定义相等来比较类型意味着一切涉及到定义相等的东西，包括函数定义的内部，成为使用依赖类型和索引家族的程序的接口的一部分。
在类型中暴露函数的内部意味着重构暴露的程序可能会导致使用它的程序无法通过类型检查。
特别是 `plusL` 在 `appendL` 的类型中使用的事实意味着无法将 `plusL` 的定义替换为其他等价的 `plusR`。

## 在加法上陷入困境

如果使用 `plusR` 来定义 `append`，通过以相同的方式开始，使用显式长度和占位下划线，可以得到以下有用的错误信息：

```lean
{{#example_in Examples/DependentTypes/Pitfalls.lean appendR1}}
```



```output error
{{#example_out Examples/DependentTypes/Pitfalls.lean appendR1}}
```



```output error
{{#example_out Examples/DependentTypes/Pitfalls.lean appendR2}}
```

然而，尝试在第一个占位符周围放置 `Vect α k` 类型的注释会导致类型不匹配错误：

```lean
{{#example_in Examples/DependentTypes/Pitfalls.lean appendR3}}
```



```output error
{{#example_out Examples/DependentTypes/Pitfalls.lean appendR3}}
```

这个错误指出 `plusR 0 k` 和 `k` _不是_ 定义上相等的。

这是因为 `plusR` 的定义如下：

```lean
{{#example_decl Examples/DependentTypes/Pitfalls.lean plusR}}
```

LEA 定理是一个关于加法交换律的数学定理，它可以用来证明两个自然数相加的结果不受加法运算数的顺序影响。下面是 LEA 定理的证明：

```lean
theorem lea (a b : ℕ) : a + b = b + a :=
nat.rec_on a
  (show 0 + b = b + 0, by rw [zero_add, add_zero])
  (assume k,
    assume ih : k + b = b + k,
    show succ k + b = b + succ k, by rw [succ_add, add_succ, ih])
```

这个证明使用了自然数归纳法。基础情况是 `a = 0`，我们需要证明 `0 + b = b + 0`，这可以通过应用加法的单位元性质（即 `zero_add` 和 `add_zero`）来完成。

归纳步骤中，我们假设对于某个自然数 `k`，我们已经证明了 `k + b = b + k`。我们需要证明 `succ k + b = b + succ k`。我们可以通过应用加法的递归性质（即 `succ_add` 和 `add_succ`）以及归纳假设来完成证明。

因此，我们可以得出结论，对于任意的自然数 `a` 和 `b`，都有 `a + b = b + a`，即加法是可交换的。这个定理的证明使用了归纳法和对自然数加法的属性的引用。

```lean
{{#example_in Examples/DependentTypes/Pitfalls.lean appendR4}}
```



```output error
{{#example_out Examples/DependentTypes/Pitfalls.lean appendR4}}
```

加法在变量上出现了“陷入困境”的状态。
要解决这个问题，需要使用[命题相等](../type-classes/standard-classes.md#equality-and-ordering)。

## 命题相等

命题相等是数学语句，它说明两个表达式相等。
尽管定义上的相等是一种环境事实，Lean在需要时自动检查它，但命题相等的陈述需要明确的证明。
一旦相等命题被证明，它可以在程序中使用，通过将等式的一边替换为另一边来修改类型，从而解决类型检查的问题。

定义上的相等之所以如此有限，是为了使其可以通过算法检查。
命题相等更加灵活，但计算机通常无法检查两个表达式是否命题相等，尽管可以验证所谓的证明是否确实是一个证明。
定义等式和命题相等之间的区别代表了人类和机器之间的分工：最无聊的相等关系会自动作为定义等式的一部分自动检查，从而使人类的思维能够解决命题等式中有趣的问题。
同样，类型检查器会自动调用定义等式，而命题相等必须明确地使用。

在[命题、证明和索引](../props-proofs-indexing.md)中，使用了 `simp` 来证明几个等式陈述。
所有这些等式陈述实际上都是命题相等，它们已经是定义等式。
通常，命题相等的陈述是通过将它们转化为定义等式或与已有证明的等式相近的形式，然后使用 `simp` 等工具来处理简化的情况。
`simp` 策略非常强大：在背后，它使用了许多快速自动化工具来构造证明。
一个更简单的策略称为 `rfl`，它专门使用定义等式来证明命题相等。
`rfl` 的名称是 _reflexivity_ 的缩写，它是等式的一个属性，它表明每个元素都等于其自身。

要解决 `appendR` 的卡在 `k = Nat.plusR 0 k` 的问题，需要提供一个证明，即证明 `k = Nat.plusR 0 k`，这不是一个定义等式，因为 `plusR` 在其第二个参数中陷入困境。
为了使其计算，`k` 必须成为一个具体的构造函数。
这是模式匹配的一种工作。

特别地，因为 `k` 可以是**任意**的 `Nat`，所以这个任务需要一个函数，可以为**任意**的 `k` 返回 `k = Nat.plusR 0 k` 的证据。
这应该是一个返回相等性证明的函数，类型为 `(k: Nat) → k = Nat.plusR 0 k`。
使用初始模式和占位符开始，得到以下消息：

```lean
{{#example_in Examples/DependentTypes/Pitfalls.lean plusR_zero_left1}}
```



```output error
{{#example_out Examples/DependentTypes/Pitfalls.lean plusR_zero_left1}}
```



```output error
{{#example_out Examples/DependentTypes/Pitfalls.lean plusR_zero_left2}}
```

通过模式匹配将 `k` 精炼为 `0` 后，第一个占位符表示的是一个能够被定义满足的陈述的证据。
`tactic` 策略会处理这个情况，只留下第二个占位符：

```lean
{{#example_in Examples/DependentTypes/Pitfalls.lean plusR_zero_left3}}
```

第二个占位符稍微棘手一些。
表达式 `{{#example_in Examples/DependentTypes/Pitfalls.lean plusRStep}}` 在定义上等于 `{{#example_out Examples/DependentTypes/Pitfalls.lean plusRStep}}`。
这意味着目标也可以写作 `k + 1 = Nat.plusR 0 k + 1`：

```lean
{{#example_in Examples/DependentTypes/Pitfalls.lean plusR_zero_left4}}
```



```output error
{{#example_out Examples/DependentTypes/Pitfalls.lean plusR_zero_left4}}
```

在等式语句的两边的 `+ 1` 下面是函数本身返回的另一个实例。
换句话说，对于 `k` 的递归调用将返回 `k = Nat.plusR 0 k` 的证据。
如果等式不适用于函数参数，那么它就不是等式。
换句话说，如果 `x = y`，那么 `f x = f y`。
标准库中包含一个函数 `congrArg`，它接受一个函数和一个等式证明，并返回一个新的证明，在这个证明中函数已应用于等式的两边。
在这个例子中，函数是 `(· + 1)`：

```lean
{{#example_decl Examples/DependentTypes/Pitfalls.lean plusR_zero_left_done}}
```

命题等式可以使用向右三角运算符 `▸` 在程序中应用。
给定一个等式证明作为第一个参数，以及另一个表达式作为第二个参数，这个运算符会将第二个参数的类型中的左边替换为等式的右边。
换句话说，下面的定义不会出现类型错误：

```lean
{{#example_in Examples/DependentTypes/Pitfalls.lean appendRsubst}}
```

第一个占位符的类型符合预期：

```output error
{{#example_out Examples/DependentTypes/Pitfalls.lean appendRsubst}}
```

现在可以用 `ys` 填充：

```lean
{{#example_in Examples/DependentTypes/Pitfalls.lean appendR5}}
```

要填写剩下的占位符，需要解决另一个加法实例的问题：

```output error
{{#example_out Examples/DependentTypes/Pitfalls.lean appendR5}}
```

这里要证明的命题是 `Nat.plusR (n + 1) k = Nat.plusR n k + 1`，可以使用 `▸` 将 `+ 1` 提取到表达式的顶部，以便与 `cons` 的索引匹配。
这个证明是一个递归函数，它对 `plusR` 的第二个参数 `k` 进行模式匹配。
这是因为 `plusR` 本身对它的第二个参数进行了模式匹配，所以证明可以通过模式匹配来 "去除" 它，暴露出计算行为。
证明的骨架与 `plusR_zero_left` 极为相似：

```lean
{{#example_in Examples/DependentTypes/Pitfalls.lean plusR_succ_left_0}}
```

剩余案例的类型在定义上等于 `Nat.plusR (n + 1) k + 1 = Nat.plusR n (k + 1) + 1`，因此可以使用 `congrArg` 来解决，就像在 `plusR_zero_left` 中一样：

```output error
{{#example_out Examples/DependentTypes/Pitfalls.lean plusR_succ_left_2}}
```

这一步将得到一个完成的证明：

```lean
{{#example_decl Examples/DependentTypes/Pitfalls.lean plusR_succ_left}}
```

完成的证明可以用来解决`appendR`中的第二种情况：

```lean
{{#example_decl Examples/DependentTypes/Pitfalls.lean appendR}}
```

当将 `appendR` 函数的长度参数再次改为隐式参数时，它们不再需要在证明中显式命名。
尽管如此，Lean 的类型检查器仍然具有足够的信息来自动填充它们，因为没有其他的值可以使类型匹配：

```lean
{{#example_decl Examples/DependentTypes/Pitfalls.lean appendRImpl}}
```

## 优点与缺点

索引类型族具有一个重要的特性：对它们的模式匹配会影响定义相等性。
例如，在对 `Vect` 进行 `match` 表达式时的 `nil` 情况中，长度就是 `0`。
定义相等性非常方便，因为它总是处于活动状态，不需要显式调用。

然而，使用依赖类型和模式匹配的定义相等性也存在严重的软件工程问题。
首先，函数必须专门编写以供在类型中使用，而在类型中使用方便的函数可能没有使用最高效的算法。
一旦一个函数通过在类型中使用而暴露出来，它的实现就成为了接口的一部分，导致未来重构时出现困难。
其次，定义相等性可能会很慢。
当要求检查两个表达式是否定义相等时，Lean 可能需要运行大量的代码，如果涉及的函数复杂且包含许多抽象层次。
第三，定义相等性失败导致的错误消息通常很难理解，因为它们可能用函数的内部术语来表达。
不容易理解错误消息中表达式的来源。
最后，在一组索引类型族和依赖类型函数中编码非平凡的不变性往往是脆弱的。
当函数的暴露还没有提供方便的定义相等性时，往往需要改变系统中的早期定义。
另一个选择是在程序中散发相等性证明，但它们可能会变得非常笨重。

在惯用的 Lean 代码中，索引数据类型并不经常使用。
而是通常使用子类型和显式命题来强制执行重要的不变性。
这种方法涉及许多显式证明，很少会调用定义相等性。
正如一个交互式定理证明器应该具备的，Lean 的设计是为了使显式证明变得方便。
总的来说，在大多数情况下，应该优先使用这种方法。

然而，了解索引类型族是很重要的。
递归函数（例如 `plusR_zero_left` 和 `plusR_succ_left`）实际上是通过数学归纳的证明。
递归的基本情况对应于归纳的基本情况，递归调用则代表了对归纳假设的引用。
更一般地，Lean 中的新命题通常被定义为证据的归纳类型，而这些归纳类型通常具有索引。
证明定理的过程实际上是在幕后构建具有这些类型的表达式，这个过程与本节中的证明类似。
此外，索引数据类型有时恰好是正确的工具。
熟练掌握它们的使用是知道何时使用它们的重要组成部分。

## 练习题

- 使用类似于 `plusR_succ_left` 的递归函数的风格，证明对于所有的 `Nat` 类型的 `n` 和 `k`，都有 `n.plusR k = n + k`。
- 为 `Vect` 写一个函数，其中 `plusR` 比 `plusL` 更自然，而 `plusL` 需要在定义中使用证明。