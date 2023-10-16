# 更多不等式

Lean的内置证明自动化足以检查 `arrayMapHelper` 和 `findHelper` 的终止性。
只需要提供一个在每次递归调用时值都会减少的表达式。
然而，Lean的内置自动化并不是魔法，它经常需要一些帮助。

## 归并排序

一个终止性证明较复杂的函数的例子是 `List` 上的归并排序。
归并排序由两个阶段组成：首先，将一个列表分成两半。
每一半使用归并排序进行排序，然后使用一个将两个有序列表合并成一个更大有序列表的函数将结果合并。
基本情况是空列表和单元素列表，这两种情况都被认为是有序的。

要合并两个有序列表，有两种基本情况需要考虑：
 1. 如果其中一个输入列表为空，则结果是另一个列表。
 2. 如果两个列表都非空，则应该比较它们的头部。函数的结果是两个头部中较小的一个，后面跟着合并两个列表剩余条目的结果。

这个函数对任一列表都不进行结构递归。
递归的终止是因为一次递归调用中两个列表中的一个被移除，但可能是任一列表。
`termination_by` 子句使用两个列表长度之和作为一个递减值：

```lean
{{#example_decl Examples/ProgramsProofs/Inequalities.lean merge}}
```

除了使用列表的长度，还可以提供一个包含两个列表的元组：

```python
def length_mul(l1, l2):
    if l1 == [] or l2 == []:
        return 0
    elif type(l1) == list and type(l2) == list:
        return length_mul(l1[1:], l2) + length_mul(l1[0], l2)
    else:
        return l1 * length(l2)

def length(l):
    if l == []:
        return 0
    elif type(l) == list:
        return length(l[1:]) + length(l[0])
    else:
        return 1
```

然后，我们可以定义一个 `pair_mul` 函数来计算两个列表的乘积：
```
def pair_mul(pair):
    l1, l2 = pair
    return length_mul(l1, l2)
```

这样，我们就可以使用两个列表的长度或两个列表本身来计算它们的乘积。

```lean
{{#example_decl Examples/ProgramsProofs/Inequalities.lean mergePairTerm}}
```

这是因为 Lean 内置了一个叫做 `WellFoundedRelation` 的类型类，它通过数据的大小来表达。
对于二元组的实例自动将其视为更小的，如果二元组的第一个或第二个元素缩小。

一个简单的方法来拆分一个列表是将输入列表中的每个条目添加到两个交替的输出列表中：

```lean
{{#example_decl Examples/ProgramsProofs/Inequalities.lean splitList}}
```

归并排序检查是否达到了基本情况。如果是这样，它会返回输入的列表。如果不是，则将输入列表分割，并合并排序每一半的结果：

```lean
{{#example_in Examples/ProgramsProofs/Inequalities.lean mergeSortNoTerm}}
```

Lean的模式匹配编译器能够识别到假设`h`是由`if`引入的，这个`if`测试了`xs.length < 2`是否成立。因此，该假设排除了长度大于1的列表，所以不会出现"missing cases"错误。
然而，尽管这个程序总是终止，但它并不是结构递归的：

```output error
{{#example_out Examples/ProgramsProofs/Inequalities.lean mergeSortNoTerm}}
```

它终止的原因是 `splitList` 函数始终返回比其输入更短的列表。
因此，`halves.fst` 和 `halves.snd` 的长度小于 `xs` 的长度。
可以使用 `termination_by` 子句来表达这个性质：

```lean
{{#example_in Examples/ProgramsProofs/Inequalities.lean mergeSortGottaProveIt}}
```

这个条件的存在导致错误信息发生了变化。
与其抱怨函数没有结构递归，Lean更改为指出它无法自动证明`(splitList xs).fst.length < xs.length`。

```output error
{{#example_out Examples/ProgramsProofs/Inequalities.lean mergeSortGottaProveIt}}
```

## 拆分列表会使列表变短

接下来需要证明 `(splitList xs).snd.length < xs.length`。因为 `splitList` 在两个列表中间交替添加元素，所以最好同时证明这两个陈述，因此证明的结构可以按照实现 `splitList` 的算法来进行。换句话说，最好证明 `∀(lst : List), (splitList lst).fst.length < lst.length ∧ (splitList lst).snd.length < lst.length`。

不幸的是，这个陈述是错误的。特别地，`{{#example_in Examples/ProgramsProofs/Inequalities.lean splitListEmpty}}` 等于 `{{#example_out Examples/ProgramsProofs/Inequalities.lean splitListEmpty}}`。两个输出列表的长度都是`0`，而不是小于输入列表的长度`0`。
类似地，`{{#example_in Examples/ProgramsProofs/Inequalities.lean splitListOne}}` 的计算结果是 `{{#example_out Examples/ProgramsProofs/Inequalities.lean splitListOne}}`，而 `["basalt"]` 并不比 `["basalt"]` 短。
然而，`{{#example_in Examples/ProgramsProofs/Inequalities.lean splitListTwo}}` 的计算结果是 `{{#example_out Examples/ProgramsProofs/Inequalities.lean splitListTwo}}`，这两个输出列表都比输入列表短。

事实证明，输出列表的长度始终小于或等于输入列表的长度，但只有在输入列表包含至少两个元素时才严格更短。
最好先证明前者陈述，然后将其扩展到后者陈述。开始一个定理陈述：

```leantac
{{#example_in Examples/ProgramsProofs/Inequalities.lean splitList_shorter_le0}}
```



```output error
{{#example_out Examples/ProgramsProofs/Inequalities.lean splitList_shorter_le0}}
```

由于`splitList`对列表进行了结构递归，所以证明应该使用归纳法。
`splitList`中的结构递归完美地适应了归纳法的证明：归纳的基础情况与递归的基础情况相匹配，归纳步骤与递归调用相匹配。
`induction`策略生成了两个目标：

```leantac
{{#example_in Examples/ProgramsProofs/Inequalities.lean splitList_shorter_le1a}}
```



```output error
{{#example_out Examples/ProgramsProofs/Inequalities.lean splitList_shorter_le1a}}
```



```output error
{{#example_out Examples/ProgramsProofs/Inequalities.lean splitList_shorter_le1b}}
```

对于 `nil` 的情况，我们可以通过调用简化器并指示其展开 `splitList` 的定义来证明目标，因为空列表的长度小于或等于空列表的长度。
类似地，使用 `splitList` 在 `cons` 的情况下，会将 `Nat.succ` 放置在目标中的长度周围：

```leantac
{{#example_in Examples/ProgramsProofs/Inequalities.lean splitList_shorter_le2}}
```



```output error
{{#example_out Examples/ProgramsProofs/Inequalities.lean splitList_shorter_le2}}
```

这是因为对 `List.length` 的调用消耗了列表 `x :: xs` 的头部，将其转换为 `Nat.succ`，同时影响了输入列表和第一个输出列表的长度。

在 Lean 中，`A ∧ B` 的写法是 `And A B` 的简写。
`And` 是 `Prop` 宇宙中的结构类型：

```lean
{{#example_decl Examples/ProgramsProofs/Inequalities.lean And}}
```

换句话说，`A ∧ B` 的证明由将 `And.intro` 构造器应用于在 `left` 字段中 A 的证明和在 `right` 字段中 B 的证明组成。

`tactic` 允许证明逐个考虑数据类型的每个构造器或命题的每个潜在证明。它对应于没有递归的 `match` 表达式。使用 `cases` 在结构上会将结构拆开，并为结构的每个字段添加一个假设，就像模式匹配表达式在程序中提取结构的字段一样。因为结构只有一个构造器，所以使用 `cases` 在结构上不会导致额外的目标。

因为 `ih` 是 `List.length (splitList xs).fst ≤ List.length xs ∧ List.length (splitList xs).snd ≤ List.length xs` 的证明，使用 `cases ih` 会得到一个假设，即 `List.length (splitList xs).fst ≤ List.length xs` 和一个假设，即 `List.length (splitList xs).snd ≤ List.length xs`：

```leantac
{{#example_in Examples/ProgramsProofs/Inequalities.lean splitList_shorter_le3}}
```



```output error
{{#example_out Examples/ProgramsProofs/Inequalities.lean splitList_shorter_le3}}
```

由于证明的目标也是一个 `And` ，可以使用 `constructor` 策略来应用 `And.intro` ，从而为每个参数得到一个目标：

```leantac
{{#example_in Examples/ProgramsProofs/Inequalities.lean splitList_shorter_le4}}
```



```output error
{{#example_out Examples/ProgramsProofs/Inequalities.lean splitList_shorter_le4}}
```

`left`目标的形式和`left✝`假设非常相似，只是在不等式的两边都加了 `Nat.succ`。
同样地，`right`目标类似于`right✝`假设，只是在输入列表的长度上加了一个 `Nat.succ`。
现在我们要证明，这种对`Nat.succ`的包裹会保持陈述的真实性。

### 两边都加一

对于`left`目标，要证明的陈述是 `Nat.succ_le_succ : n ≤ m → Nat.succ n ≤ Nat.succ m`。
换句话说，如果 `n ≤ m`，那么两侧加一不会改变这个事实。
为什么这是成立的呢？
证明 `n ≤ m` 是由 `Nat.le.refl` 构造器和 `m - n` 个 `Nat.le.step` 构造器包裹而成的。
两边都加一的意思就是 `refl` 应用到一个比原来大一的数字上，且包裹着相同数量的 `step` 构造器。

我们可以通过对 `n ≤ m` 的证据进行归纳来进行更严格的证明。
如果证据是 `refl`，那么 `n = m`，所以 `Nat.succ n = Nat.succ m`，而且 `refl` 可以再次被使用。
如果证据是 `step`，那么归纳假设提供了证据 `Nat.succ n ≤ Nat.succ m`，目标是要证明 `Nat.succ n ≤ Nat.succ (Nat.succ m)`。
这可以通过使用 `step` 和归纳假设来完成。

在 Lean 中，定理的陈述如下所示：

```leantac
{{#example_in Examples/ProgramsProofs/Inequalities.lean succ_le_succ0}}
```

错误信息重申了这个定理：

```output error
{{#example_out Examples/ProgramsProofs/Inequalities.lean succ_le_succ0}}
```

第一步是使用`tactic intro`，将`n ≤ m`的假设引入作用域，并为其命名：

```leantac
{{#example_in Examples/ProgramsProofs/Inequalities.lean succ_le_succ1}}
```



```output error
{{#example_out Examples/ProgramsProofs/Inequalities.lean succ_le_succ1}}
```

由于这个证明是基于 `n ≤ m` 的证据进行归纳的，下一个策略是使用 `induction h`：

```leantac
{{#example_in Examples/ProgramsProofs/Inequalities.lean succ_le_succ3}}
```

这导致了两个目标，每个 `Nat.le` 的构造函数一个：

```output error
{{#example_out Examples/ProgramsProofs/Inequalities.lean succ_le_succ3}}
```

`refl`可通过使用`refl`来解决，而`constructor`策略会选择它。
`step`的目标也需要使用`step`构造函数进行处理：

```leantac
{{#example_in Examples/ProgramsProofs/Inequalities.lean succ_le_succ4}}
```



```output error
{{#example_out Examples/ProgramsProofs/Inequalities.lean succ_le_succ4}}
```

`goal` 之前使用 `≤` 运算符来表示，但是它等价于归纳假设 `ih`。
`assumption` 策略会自动选择符合目标的假设，证明完成。

```leantac
{{#example_decl Examples/ProgramsProofs/Inequalities.lean succ_le_succ5}}
```

写成递归函数，证明如下：

```
func proveLEAN(theorem: Theorem):
    if isEmpty(theorem.axioms):
        return theorem.proof
    else:
        let axiom = theorem.axioms.first()
        let rest = theorem.axioms.rest()
        
        let subtheorem = Theorem(axioms: rest, proof: theorem.proof)
        
        let proofAxiom = proveAxiom(axiom)
        
        let newProof = substitute(subtheorem.proof, axiom.variable, proofAxiom)
        
        let newTheorem = Theorem(axioms: rest, proof: newProof)
        
        return proveLEAN(newTheorem)
```

其中 `proveLEAN` 函数用来证明 LEAN 定理，它接收一个 Theorem 类型的参数。如果定理的公理列表为空，即没有剩余的公理需要证明，那么直接返回定理的证明。否则，取出公理列表中的第一个公理，并将剩余的公理列表赋值给变量 `rest`。然后，创建一个子定理 `subtheorem`，其公理列表为剩余的公理列表，证明为原始定理的证明。接下来，使用函数 `proveAxiom` 证明当前公理，得到 `proofAxiom`。使用函数 `substitute` 将 `subtheorem` 的证明中的变量 `axiom.variable` 替换为 `proofAxiom` 的证明，得到 `newProof`。然后，创建一个新的定理 `newTheorem`，其公理列表为剩余的公理列表，证明为 `newProof`。最后，使用递归的方式，将新的定理传递给 `proveLEAN` 函数，继续证明剩余的公理。

```lean
{{#example_decl Examples/ProgramsProofs/Inequalities.lean succ_le_succ_recursive}}
```

将 Lean 定理中的递归函数与基于策略的归纳法证明进行比较，是有教育意义的。
哪些证明步骤对应于定义的哪些部分呢？

### 将较大一边加一

证明 `splitList_shorter_le` 需要的第二个不等式是 `∀(n m : Nat), n ≤ m → n ≤ Nat.succ m`。
这个证明与 `Nat.succ_le_succ` 几乎完全相同。
再次地，传入的假设 `n ≤ m` 实际上追踪了 `n` 和 `m` 之间 `Nat.le.step` 构造函数的差异。
因此，证明在基本情况下应该再增加一个 `Nat.le.step`。
证明可以写成：

```leantac
{{#example_decl Examples/ProgramsProofs/Inequalities.lean le_succ_of_le}}
```

为了揭示背后发生的事情，可以使用`apply`和`exact`策略来精确指示使用了哪个构造函数。
`apply`策略通过应用与当前目标匹配的函数或构造函数来解决当前目标，对于未提供的每个参数创建新的目标，而`exact`策略则在需要新的目标时失败：

```leantac
{{#example_decl Examples/ProgramsProofs/Inequalities.lean le_succ_of_le_apply}}
```

这个证明可以被压缩成更简短的形式：

```leantac
{{#example_decl Examples/ProgramsProofs/Inequalities.lean le_succ_of_le_golf}}
```

在这个简短的策略脚本中，“引入的两个目标”通过使用 `repeat (first | constructor | assumption)` 来处理。
`tactic` 表示尝试按顺序使用 `T1` 至 `Tn` 中的策略，并使用第一个成功的策略。
换句话说，`repeat (first | constructor | assumption)` 会应用构造函数直到无法继续，然后尝试使用假设来解决目标。

最后，证明可以写为一个递归函数：

```lean
{{#example_decl Examples/ProgramsProofs/Inequalities.lean le_succ_of_le_recursive}}
```

每种证明方法都适用于不同的情况。

详细的证明脚本在初学者阅读代码时或者证明的步骤提供某种洞察力时非常有用。

短小而高度自动化的证明脚本通常更容易维护，因为自动化经常能够灵活且强大地应对定义和数据类型的微小变化。

递归函数通常对于从数学证明的角度更难理解，也更难维护，但对于刚开始使用交互式定理证明的程序员来说，它可以作为一个有用的过渡。

### 完成证明

现在，已经证明了两个辅助定理，接下来将快速完成 `splitList_shorter_le` 的剩余部分。

当前的证明状态有两个目标，分别是 `And` 的左边和右边：

```output error
{{#example_out Examples/ProgramsProofs/Inequalities.lean splitList_shorter_le4}}
```

这些目标以 `And` 结构的字段命名。这意味着 `case` 策略（注意不要与 `cases` 混淆）可以用来依次关注每个目标：

```leantac
{{#example_in Examples/ProgramsProofs/Inequalities.lean splitList_shorter_le5a}}
```

与列出两个未解决目标的单个错误不同，现在有两个信息，分别在每个 `skip` 上。
对于 `left` 目标，可以使用 `Nat.succ_le_succ`：

```output error
{{#example_out Examples/ProgramsProofs/Inequalities.lean splitList_shorter_le5a}}
```

在正确的目标下，`Nat.le_suc_of_le` 得到契合：

```coq
Theorem le_suc_of_le : forall n m : nat, n <= m -> n <= S m.
Proof.
  intros n m H.
  induction H as [|m H' IH].
  - apply le_n.
  - apply le_S.
    apply IH.
Qed.
```

这个定理证明了若 `n <= m`，则 `n <= S m`。它使用了归纳法证明，对于基本情况 `n = 0`，我们可以直接应用构造子 `le_n` 得到 `0 <= S m` 的证明。对于归纳情况，假设 `n <= m` 成立，我们可以应用构造子 `le_S` 得到 `n <= S m` 的证明，同时使用归纳假设 `IH` 证明 `n <= m`。最后我们得到 `n <= S m`。

```output error
{{#example_out Examples/ProgramsProofs/Inequalities.lean splitList_shorter_le5b}}
```

这两个定理都包含了前提条件 `n ≤ m`。
这些前提条件可以在`left✝`和`right✝`的假设中找到，这意味着`assumption`策略可以处理最终的目标：

```leantac
{{#example_decl Examples/ProgramsProofs/Inequalities.lean splitList_shorter_le}}
```

下一步是回到实际的定理，证明归并排序一定会终止：只要一个列表至少有两个元素，将其分割的结果都会严格地比原列表短。

```leantac
{{#example_in Examples/ProgramsProofs/Inequalities.lean splitList_shorter_start}}
```



```output error
{{#example_out Examples/ProgramsProofs/Inequalities.lean splitList_shorter_start}}
```

模式匹配在战术脚本中和程序中一样有效。
因为 `lst` 至少有两个项，它们可以通过 `match` 暴露出来，这也通过依赖模式匹配来细化类型：

```leantac
{{#example_in Examples/ProgramsProofs/Inequalities.lean splitList_shorter_1}}
```



```output error
{{#example_out Examples/ProgramsProofs/Inequalities.lean splitList_shorter_1}}
```

使用 `splitList` 进行化简，会移除 `x` 和 `y`，从而导致计算的列表长度都会增加 `Nat.succ` ：

```leantac
{{#example_in Examples/ProgramsProofs/Inequalities.lean splitList_shorter_2}}
```



```output error
{{#example_out Examples/ProgramsProofs/Inequalities.lean splitList_shorter_2}}
```

将 `simp` 替换为 `simp_arith` 会移除这些 `Nat.succ` 构造函数，因为 `simp_arith` 使用了这样一个事实，即 `n + 1 < m + 1` 意味着 `n < m`：

```leantac
{{#example_in Examples/ProgramsProofs/Inequalities.lean splitList_shorter_2b}}
```



```output error
{{#example_out Examples/ProgramsProofs/Inequalities.lean splitList_shorter_2b}}
```

这个目标现在符合`splitList_shorter_le`的条件，可以用来证明该定理：

```leantac
{{#example_decl Examples/ProgramsProofs/Inequalities.lean splitList_shorter}}
```

证明 `mergeSort` 终止所需的事实可以从结果的 `And` 中提取出来：

```leantac
{{#example_decl Examples/ProgramsProofs/Inequalities.lean splitList_shorter_sides}}
```

## 归并排序终止

归并排序有两个递归调用，一个用于 `splitList` 返回的每个子列表。
每个递归调用都需要证明传递给它的列表的长度小于输入列表的长度。
通常情况下，将终止性证明分为两步：首先，写下能够让 Lean 验证终止性的命题，然后进行证明。
否则，可能会花费很多精力证明命题，只发现它们并不完全符合建立递归调用针对较小输入的要求。

`tactic` 提供了一个 `sorry` 的策略，可以证明任何目标，甚至包括错误的目标。
虽然 `sorry` 策略不适用于生产代码和最终证明，但它是一种方便的方法，可以提前"草拟"证明或程序。
使用 `sorry` 的任何定义或定理都会带有警告。

使用 `sorry` 的 `mergeSort` 终止性证明的初始草稿可以通过将 Lean 无法证明的目标复制到 `have` 表达式中来编写。
在 Lean 中，`have` 类似于 `let`。
使用 `have` 时，名称是可选的。
通常情况下， `let` 用于定义引用有趣值的名称，而 `have` 用于局部地证明可以在 Lean 搜索证据时找到的命题，这些证据可以证明数组查找是越界的还是函数终止的。

```leantac
{{#example_in Examples/ProgramsProofs/Inequalities.lean mergeSortSorry}}
```

警告位于`mergeSort`函数的名字上：

```output warning
{{#example_out Examples/ProgramsProofs/Inequalities.lean mergeSortSorry}}
```

因为没有错误，所以所提出的命题足以证明终止性。

证明开始时应用辅助定理：

```leantac
{{#example_in Examples/ProgramsProofs/Inequalities.lean mergeSortNeedsGte}}
```

两个证明都失败了，因为 `splitList_shorter_fst` 和 `splitList_shorter_snd` 都需要证明 `xs.length ≥ 2`：

```output error
{{#example_out Examples/ProgramsProofs/Inequalities.lean mergeSortNeedsGte}}
```

为了检查这是否足够完成证明，可以使用 `sorry` 添加它并检查是否有错误: 

```lean
theorem proof : statement :=
begin
  sorry, -- TODO: complete the proof
end
```

```leantac
{{#example_in Examples/ProgramsProofs/Inequalities.lean mergeSortGteStarted}}
```

再一次，只有一个警告。

```output warning
{{#example_out Examples/ProgramsProofs/Inequalities.lean mergeSortGteStarted}}
```

有一个有希望的假设可用：`h: ¬List.length xs < 2`，它来自于 `if` 语句。
显然，如果不是 `xs.length < 2` 的情况，那么 `xs.length ≥ 2`。
Lean 库提供了这个定理，命名为 `Nat.ge_of_not_lt`。
现在程序已经完成了：

```leantac
{{#example_decl Examples/ProgramsProofs/Inequalities.lean mergeSort}}
```

该函数可以用示例进行测试：

```lean
{{#example_in Examples/ProgramsProofs/Inequalities.lean mergeSortRocks}}
```



```output info
{{#example_out Examples/ProgramsProofs/Inequalities.lean mergeSortRocks}}
```



```lean
{{#example_in Examples/ProgramsProofs/Inequalities.lean mergeSortNumbers}}
```



```output info
{{#example_out Examples/ProgramsProofs/Inequalities.lean mergeSortNumbers}}
```

## 递归除法

就像乘法是反复相加，指数是反复乘法一样，除法可以理解为反复做减法。
[这本书中关于递归函数的第一个描述](../getting-to-know/datatypes-and-patterns.md#recursive-functions)介绍了一个在除数不为零时终止的除法版本，但 Lean 不接受。
证明除法是终止的需要使用到关于不等式的一个事实。

第一步是细化除法的定义，使其要求有证据表明除数不为零：

```lean
{{#example_in Examples/ProgramsProofs/Div.lean divTermination}}
```

错误消息有点长，因为有额外的参数，但它包含基本相同的信息：

```output error
{{#example_out Examples/ProgramsProofs/Div.lean divTermination}}
```

这个 `div` 函数的定义是可终止的，因为在每次递归调用中，第一个参数 `n` 的值都会减小。

可以使用 `termination_by` 子句来表示这一点：

```lean
{{#example_in Examples/ProgramsProofs/Div.lean divRecursiveNeedsProof}}
```

现在，错误仅限于递归调用部分：

```output error
{{#example_out Examples/ProgramsProofs/Div.lean divRecursiveNeedsProof}}
```

可以使用标准库中的定理 `Nat.sub_lt` 来证明这一点。
该定理声明 `{{#example_out Examples/ProgramsProofs/Div.lean NatSubLt}}` （花括号表示 `n` 和 `k` 是隐式参数）。
使用该定理要求证明 `n` 和 `k` 都大于零。
因为 `k > 0` 是 `0 < k` 的语法糖，所以唯一需要的目标是证明 `0 < n`。
有两种可能性：要么 `n` 是 `0`，要么它是另一个 `Nat` 类型的 `n' + 1`。
但是 `n` 不能是 `0`。
`if` 选择第二个分支意味着 `¬ n < k`，但是如果 `n = 0` 且 `k > 0`，那么 `n` 必须小于 `k`，这将导致矛盾。
因此，`n = Nat.succ n'`，而 `Nat.succ n'` 显然大于 `0`。

`div` 的完整定义，包括终止证明，是：

```leantac
{{#example_decl Examples/ProgramsProofs/Div.lean div}}
```

## 证明

* 对于所有自然数 \\( n \\)，有 \\( 0 < n + 1 \\)。
  
  证明：根据自然数的定义，自然数是从0开始的整数。因此，对于任意自然数 \\( n \\)，都存在一个自然数 \\( n + 1 \\)，且 \\( n + 1 \\) 大于0。所以，\\( 0 < n + 1 \\) 成立。

* 对于所有自然数 \\( n \\)，有 \\( 0 \leq n \\)。
  
  证明：根据自然数的定义，自然数是从0开始的整数。因此，自然数 \\( n \\) 大于等于0。所以，\\( 0 \leq n \\) 成立。
  
* 对于所有自然数 \\( n \\) 和 \\( k \\)，有 \\( (n + 1) - (k + 1) = n - k \\)。

  证明：左边的表达式可以展开为 \\( n + 1 - k - 1 \\)。由于减法的结合律，可以重新排列为 \\( n - k + 1 - 1 \\)。根据减法的定义，\\( n - k \\) 表示从 \\( n \\) 中去掉 \\( k \\)，而 \\( (n - k) + 1 \\) 表示在 \\( n - k \\) 的基础上加上1。所以， \\( (n + 1) - (k + 1) = n - k \\) 成立。

* 对于所有自然数 \\( n \\) 和 \\( k \\)，如果 \\( k < n \\)，则 \\( n \neq 0 \\)。

  证明：首先，假设 \\( n = 0 \\)，那么 \\( k < n \\) 不成立，因为对于任何自然数 \\( k \\)，都有 \\( k \geq 0 \\)。所以，假设 \\( k < n \\) 成立，则可以推出 \\( n \neq 0 \\)。

* 对于所有自然数 \\( n \\)，有 \\( n - n = 0 \\)。

  证明：根据减法的定义，\\( n - n \\) 表示从 \\( n \\) 中去掉 \\( n \\) 个自然数。由于任何自然数减去自身等于0，所以 \\( n - n = 0 \\) 成立。
  
* 对于所有自然数 \\( n \\) 和 \\( k \\)，如果 \\( n + 1 < k \\)，则 \\( n < k \\)。

  证明：根据自然数的定义，自然数是从0开始的整数。假设 \\( n + 1 < k \\) 不成立，那么必然有 \\( n + 1 \geq k \\)。根据自然数的性质，如果一个自然数大于等于另一个自然数，则它们之差也大于等于0，即 \\( n + 1 - k \geq 0 \\)。但是，根据题目的假设条件，\\( n + 1 - k < 0 \\)，与前面的结论相矛盾。所以，假设 \\( n + 1 < k \\) 成立，则可以推出 \\( n < k \\)。