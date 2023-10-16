# 插曲：战术、归纳和证明

## 关于证明和用户界面的说明

本书将编写证明的过程呈现为一次性完成并提交给Lean，然后Lean将回复错误消息，描述剩下的工作。
实际与Lean的交互过程要愉快得多。
当光标在证明中移动时，Lean会提供有关证明的信息，并且有许多交互功能可以使证明更容易。
有关更多信息，请查询您的Lean开发环境的文档。

本书的方法侧重于逐步构建证明，并展示结果消息，展示了在编写证明时Lean提供的交互反馈类型，尽管它比专业人士使用的过程要慢得多。
与此同时，看到不完整的证明逐渐演化为完整的证明是一种有益的证明视角。
随着您编写证明的能力提高，Lean的反馈将不再感觉像错误，而更像是对您自己思维过程的支持。
学习这种交互式方法非常重要。

## 递归和归纳

前一章中的 `plusR_succ_left` 和 `plusR_zero_left` 函数可以从两个角度进行理解。
一方面，它们是递归函数，用于构建一个命题的证明，就像其他递归函数可能构建列表、字符串或任何其他数据结构一样。
另一方面，它们也对应于_数学归纳法_的证明。

数学归纳法是一种证明技巧，用于证明一个命题对_所有_自然数成立，分为两个步骤：
1. 证明该命题对 \\( 0 \\) 成立。这称为_基本情况_。
2. 在假设该命题对某个任意选择的数 \\( n \\) 成立的前提下，证明它对 \\( n + 1 \\) 也成立。这称为_归纳步骤_。假设该命题对 \\( n \\) 成立的前提被称为_归纳假设_。

因为不可能检查_每一个_自然数的命题，归纳提供了一种编写证明的方法，原则上可以扩展到任何特定的自然数。
例如，如果要为数字3创建一个具体的证明，可以先使用基本情况，然后使用归纳步骤三次，展示这个命题对于0、1、2和最后3成立。
因此，这证明了对于所有自然数的陈述是正确的。

## 归纳策略

使用递归函数以及诸如 `congrArg` 等辅助函数来实现归纳证明，并不能很好地表达出证明的意图。
虽然递归函数的确具有归纳的结构，但它们应该被视为证明的一个_编码_。
此外，Lean 的策略系统提供了许多机会来自动化构建证明，这在显式编写递归函数时是不可用的。
Lean 提供了一个归纳_策略_，可以通过单个策略块完成整个归纳证明。
在幕后，Lean 构造了与使用归纳相关的递归函数。

要使用归纳策略来证明 `plusR_zero_left`，首先编写其签名（使用 `theorem`，因为这实际上是一个证明）。
然后，使用 `by induction k` 作为定义的主体：

```leantac
{{#example_in Examples/Induction.lean plusR_ind_zero_left_1}}
```

**结果显示有两个目标：**

1. To prove that the program is correct.
2. To prove that the program terminates.

```output error
{{#example_out Examples/Induction.lean plusR_ind_zero_left_1}}
```

一个策略块是在 Lean 类型检查器处理文件时运行的程序，有点像一个更强大的 C 预处理器宏。
这些策略生成实际的程序。

在策略语言中，可以有多个目标。
每个目标由一个类型和一些假设组成。
它们类似于使用下划线作为占位符 - 目标中的类型表示需要证明的内容，假设表示在范围内并可以使用的内容。
在目标 `case zero` 中，没有假设，类型是 `Nat.zero = Nat.plusR 0 Nat.zero` - 这是定理陈述，只是 `k` 用 `0` 代替。
在目标 `case succ` 中，有两个假设，分别命名为 `n✝` 和 `n_ih✝`。
在幕后，`induction` 策略创建了一个依赖的模式匹配，细化了整体类型，而 `n✝` 表示模式中 `Nat.succ` 的参数。
假设 `n_ih✝` 表示在 `n✝` 上递归调用生成函数的结果。
它的类型是定理的整体类型，只是将 `k` 改为 `n✝`。
作为 `case succ` 一部分需要满足的类型是整体定理陈述，以 `Nat.succ n✝` 代替 `k`。

使用 `induction` 策略产生的两个目标对应于描述数学归纳法的基本情况和归纳步骤。
基本情况是 `case zero`。
在 `case succ` 中，`n_ih✝` 对应于归纳假设，而整个 `case succ` 是归纳步骤。

证明的下一步是依次关注这两个目标。
就像在 `do` 块中使用 `pure ()` 表示“什么都不做”一样，策略语言中有一个名为 `skip` 的语句也什么都不做。
当 Lean 的语法要求使用策略，但尚不清楚应该使用哪个时，可以使用它。
在 `induction` 语句的末尾添加 `with` 提供了一种类似模式匹配的语法：

```leantac
{{#example_in Examples/Induction.lean plusR_ind_zero_left_2a}}
```

每个 `skip` 语句都与一个消息相关联。
第一个语句展示了基本情况：

```output error
{{#example_out Examples/Induction.lean plusR_ind_zero_left_2a}}
```

第二个部分是归纳步骤的证明：

```output error
{{#example_out Examples/Induction.lean plusR_ind_zero_left_2b}}
```

在归纳步骤中，带有 "†" 标记的不可访问的名称已经被 `succ` 后面提供的名称 `n` 和 `ih` 替换掉了。

在 `induction ... with` 之后的情况不是模式：它们由一个目标的名称后面跟着零个或多个名称组成。
这些名称用于引入目标中的假设；如果提供的名称多于目标引入的假设，则会出错：

```leantac
{{#example_in Examples/Induction.lean plusR_ind_zero_left_3}}
```



```output error
{{#example_out Examples/Induction.lean plusR_ind_zero_left_3}}
```

聚焦于基础案例，`rfl` 策略在`induction` 策略中的效果和递归函数中一样好用：

```leantac
{{#example_in Examples/Induction.lean plusR_ind_zero_left_4}}
```

在递归函数版本的证明中，类型注释使预期的类型更易理解。在策略语言中，有许多特定的方法可以转换一个目标，使其更容易解决。 `unfold` 策略用定义替换已定义名称的定义：

```leantac
{{#example_in Examples/Induction.lean plusR_ind_zero_left_5}}
```

现在，目标中等式右边的表达式变成了 `Nat.plusR 0 n + 1` 而不是 `Nat.plusR 0 (Nat.succ n)`：

```output error
{{#example_out Examples/Induction.lean plusR_ind_zero_left_5}}
```

在 Lean 中，可以使用 `congrArg` 函数和 `▸` 运算符来转换证明目标中的等式证明。然而，还有一些策略可以利用等式证明来转换证明目标，其中最重要的一种是 `rw` 策略。`rw` 策略接受一个等式证明列表，并将目标中的左侧替换为右侧。在 `plusR_zero_left` 中，使用 `rw` 策略可以实现几乎正确的效果：

```leantac
{{#example_in Examples/Induction.lean plusR_ind_zero_left_6}}
```

然而，重写的方向是错误的。
将 `n` 替换为 `Nat.plusR 0 n` 使得目标变得更加复杂，而不是更简单：

```output error
{{#example_out Examples/Induction.lean plusR_ind_zero_left_6}}
```

可以通过在对 `rewrite` 的调用中，在 `ih` 之前放置一个左箭头来解决这个问题，这告诉它用等式的左边替换等式的右边：

```leantac
{{#example_decl Examples/Induction.lean plusR_zero_left_done}}
```

这个改写使得等式的两边完全相同，并且 Lean 自己处理了 `rfl`。
证明完成。

## 战术高尔夫

到目前为止，战术语言还没有展示出其真正的价值。
上面的证明跟递归函数的长度相等，只是用了一种特定的领域语言代替了完整的 Lean 语言。
但是使用战术的证明可以更短、更容易理解和更易于维护。
就像高尔夫游戏中得分越低越好一样，战术证明越短越好。

`plusR_zero_left` 的归纳步骤可以使用简化战术 `simp` 来证明。
仅仅使用 `simp` 是无助的，目标仍然没有改变：

```leantac
{{#example_in Examples/Induction.lean plusR_zero_left_golf_1}}
```



```output error
{{#example_out Examples/Induction.lean plusR_zero_left_golf_1}}
```

然而，`simp` 可以配置为使用一组定义。就像 `rw` 一样，这些参数是以列表的形式提供的。要求 `simp` 考虑 `Nat.plusR` 的定义会得到一个更简单的目标：

```leantac
{{#example_in Examples/Induction.lean plusR_zero_left_golf_2}}
```



```output error
{{#example_out Examples/Induction.lean plusR_zero_left_golf_2}}
```

特别是，现在的目标与归纳假设相同。
除了自动证明简单的相等陈述外，简化器还会自动将类似 `Nat.succ A = Nat.succ B` 的目标替换为 `A = B`。
由于归纳假设 `ih` 正好具有正确的类型，因此 `exact` 策略可以指示它被使用：

```leantac
{{#example_decl Examples/Induction.lean plusR_zero_left_golf_3}}
```

然而，`exact`策略的使用有一些脆弱性。
在"修剪"证明时修改归纳假设的名称会导致该证明停止工作。
如果当前目标与其中的任何假设匹配，`assumption`策略将解决当前目标：

```leantac
{{#example_decl Examples/Induction.lean plusR_zero_left_golf_4}}
```

这个证明和之前使用展开和显式重写的证明一样不短。
然而，一系列的转换可以使它变得更短，利用了 `simp` 可以解决很多类型的目标的事实。
第一步是在 `induction` 结束时去掉 `with`。
对于结构化、易读的证明，`with` 语法很方便。
它会报错，如果有任何遗漏的情况，并且清晰地显示归纳的结构。
但是缩短证明通常需要更加开放的方法。

使用没有 `with` 的 `induction` 只会得到两个目标的证明状态。
`case` 策略可以用来选择其中一个目标，就像 `induction ... with` 策略的分支一样。
换句话说，下面的证明与之前的证明是等价的：

```leantac
{{#example_decl Examples/Induction.lean plusR_zero_left_golf_5}}
```

在一个单一目标的上下文中（即`k = Nat.plusR 0 k`），`induction k` 策略将得到两个目标。
通常，一个策略要么会出错，要么需要把目标转换为零个或多个新的目标。
每个新的目标表示仍需证明的部分。
如果最终得到的目标数为零，则策略执行成功，该证明部分完成。

`<;>` 运算符接受两个策略作为参数，返回一个新的策略。
`T1 <;> T2` 先应用 `T1` 到当前目标，然后在 `T1` 生成的所有新目标上应用 `T2`。
换句话说，`<;>` 允许一个可以解决多种目标的通用策略同时应用到多个新目标上。
一个这样的通用策略是 `simp`。

由于 `simp` 可以完成基本情况的证明，并在归纳步骤中取得进展，使用 `induction` 和 `<;>` 可以缩短证明的步骤：

```leantac
{{#example_in Examples/Induction.lean plusR_zero_left_golf_6a}}
```

这将导致仅有一个目标，即变换后的归纳步骤：

```output error
{{#example_out Examples/Induction.lean plusR_zero_left_golf_6a}}
```

在这个证明中，运行 `assumption` 命令就可以完成证明：

```leantac
{{#example_decl Examples/Induction.lean plusR_zero_left_golf_6}}
```

这里，`exact`可能是不可能的，因为 `ih` 从未被明确命名。

对于初学者来说，这个证明并不容易阅读。
然而，对于有经验的用户来说，一种常见的模式是使用强大的策略如 `simp` 处理一些简单的情况，从而使他们能够将证明的文本集中在有趣的情况上。
此外，这些证明在函数和数据类型的细微变化面前往往更具鲁棒性。
"策略高尔夫" 是开发良好的证明写作风格和品味的一个有用部分。

## 对其他数据类型进行归纳

通过给自然数提供`Nat.zero`的基本情况和提供`Nat.succ`的归纳步骤，数学归纳法可以证明一个陈述对自然数成立。
归纳原理也适用于其他数据类型。
没有递归参数的构造函数构成基本情况，而具有递归参数的构造函数构成归纳步骤。
能够通过归纳进行证明的能力正是它们被称为“归纳”数据类型的原因之一。

二叉树上的归纳是一种证明技巧，在这种技巧中，一个陈述被证明对于_所有_二叉树成立，分为两个步骤：
 1. 证明该陈述对于 `BinTree.leaf` 成立。这被称为基本情况。
 2. 在假设该陈述对于一些任意选择的树 `l` 和 `r` 成立的情况下，证明它对于 `BinTree.branch l x r` 成立，其中 `x` 是一个任意选择的新数据点。这被称为_归纳步骤_。假设该陈述对于 `l` 和 `r` 成立的假设被称为_归纳假设_。

`BinTree.count` 用于计算树中分支的数量：

```lean
{{#example_decl Examples/Induction.lean BinTree_count}}
```

根据 LEAN 定理证明的方法，可以证明“镜像一个树不会改变它的分支数目”。这可以通过对树进行归纳来证明。

第一步是陈述定理并应用`induction`：

```lean
theorem mirror_branches {α : Type} : ∀ t : tree α, branches (mirror t) = branches t :=
begin
  induction t,
  ...
end
```

其中 `tree` 是树的类型，`branches` 是一个函数，用于计算树的分支数。

我们使用归纳法对树进行归纳证明，在归纳的基础上进行推理证明。

```leantac
{{#example_in Examples/Induction.lean mirror_count_0a}}
```

基本情况指出，对于计算叶子的镜像与计算叶子本身是相同的：

```
The base case states that counting the mirror of a leaf is the same as counting the leaf.
基本情况指出，对于计算叶子的镜像与计算叶子本身是相同的。
```

```output error
{{#example_out Examples/Induction.lean mirror_count_0a}}
```

归纳步骤假设左右子树的镜像不会影响它们的分支计数，并要求证明将带有这些子树的分支进行镜像操作也会保持总的分支计数。

```output error
{{#example_out Examples/Induction.lean mirror_count_0b}}
```

基本情况是正确的，因为将 `leaf` 镜像得到的还是 `leaf`，所以左侧和右侧在定义上是相等的。可以通过使用 `simp` 并使用展开 `BinTree.mirror` 的指令来表示这一点：

```leantac
{{#example_in Examples/Induction.lean mirror_count_1}}
```

在归纳步骤中，目标中没有立即与归纳假设匹配的内容。
通过使用 `BinTree.count` 和 `BinTree.mirror` 的定义进行简化可以得到如下关系：

```leantac
{{#example_in Examples/Induction.lean mirror_count_2}}
```



```output error
{{#example_out Examples/Induction.lean mirror_count_2}}
```

两个归纳假设可以用来将目标的左侧重写为与右侧几乎相似的形式：

```leantac
{{#example_in Examples/Induction.lean mirror_count_3}}
```



```output error
{{#example_out Examples/Induction.lean mirror_count_3}}
```

`simp_arith`策略是 `simp` 的一个版本，它可以使用额外的算术恒等式来证明这个目标，得到：

```leantac
{{#example_decl Examples/Induction.lean mirror_count_4}}
```

除了要展开的定义之外，简化器还可以接受等式证明的名称，用于在简化证明目标时进行重写。
`BinTree.mirror_count` 也可以这样写：

```leantac
{{#example_decl Examples/Induction.lean mirror_count_5}}
```

随着证明变得越来越复杂，手动列出假设会变得繁琐。
而且，手动写假设名字可能会使得在多个子目标中重复使用证明步骤变得更加困难。
`simp` 或者 `simp_arith` 的参数 `*` 告诉它们在简化或者解决目标时使用 _所有_ 假设。
换句话说，该证明也可以写成：

```leantac
{{#example_decl Examples/Induction.lean mirror_count_6}}
```

由于两个分支都在使用简化器，证明可以简化为：

```leantac
{{#example_decl Examples/Induction.lean mirror_count_7}}
```

## 练习

* 使用 `induction ... with` 策略证明 `plusR_succ_left`。
* 将 `plus_succ_left` 的证明重写为一行代码使用 `<;>`。
* 使用对列表进行归纳来证明列表的拼接满足结合律：`theorem List.append_assoc (xs ys zs : List α) : xs ++ (ys ++ zs) = (xs ++ ys) ++ zs`。