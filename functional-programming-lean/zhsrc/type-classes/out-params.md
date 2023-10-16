# 控制实例搜索

一个 `Add` 类的实例足以让两个类型为 `Pos` 的表达式方便地相加，产生另一个 `Pos`。
然而，在许多情况下，更灵活的做法是允许*异构*操作符重载，其中参数可以有不同的类型。
例如，将 `Nat` 加到 `Pos` 或将 `Pos` 加到 `Nat`，总是得到一个 `Pos`：

```lean
{{#example_decl Examples/Classes.lean addNatPos}}
```

这些函数允许将自然数加到正数上，但它们不能与 `Add` 类型类一起使用，该类型类要求 `add` 的两个参数具有相同的类型。

## 异构重载

如 [重载加法](pos.md#重载加法) 部分所述，Lean 提供了一个名为 `HAdd` 的类型类，用于异构地进行重载加法。
`HAdd` 类有三个类型参数：两个参数类型和返回类型。
`HAdd Nat Pos Pos` 和 `HAdd Pos Nat Pos` 的实例允许使用普通的加法符号混合类型：

```lean
{{#example_decl Examples/Classes.lean haddInsts}}
```

鉴于上述两个实例，下面的例子可以工作：

```lean
{{#example_in Examples/Classes.lean posNatEx}}
```



```output info
{{#example_out Examples/Classes.lean posNatEx}}
```



```lean
{{#example_in Examples/Classes.lean natPosEx}}
```



```output info
{{#example_out Examples/Classes.lean natPosEx}}
```

`HAdd` 类型类的定义非常像下面的 `HPlus` 定义，并伴随有对应的实例：

```haskell
class HAdd a where
  hplus :: a -> a -> a

instance HAdd Int where
  hplus a b = a + b

instance HAdd [a] where
  hplus xs ys = xs ++ ys

instance (HAdd a, HAdd b) => HAdd (a, b) where
  hplus (x1, y1) (x2, y2) = (hplus x1 x2, hplus y1 y2)

instance HAdd () where
  hplus _ _ = ()
```

除此之外，还可以根据需要为其他类型定义 `HAdd` 类型类的实例。

```lean
{{#example_decl Examples/Classes.lean HPlus}}

{{#example_decl Examples/Classes.lean HPlusInstances}}
```

然而，`HPlus`的实例远不如`HAdd`的实例有用。
当尝试将这些实例与`#eval`一起使用时，会出现错误：

```lean
{{#example_in Examples/Classes.lean hPlusOops}}
```



```output error
{{#example_out Examples/Classes.lean hPlusOops}}
```

这是因为类型中存在一个元变量，Lean 无法解决它。

如 [多态性的初始描述](../getting-to-know/polymorphism.md) 中所讨论的那样，元变量表示程序中无法推断出的未知部分。
当使用 `#eval` 后跟一个表达式时，Lean 尝试自动确定其类型。
在这种情况下，它无法确定类型。
因为 `HPlus` 的第三个类型参数是未知的，Lean 无法进行类型类实例搜索，但是实例搜索是 Lean 确定表达式类型的唯一方式。
也就是说，只有当表达式应具有类型 `Pos` 时，才能应用 `HPlus Pos Nat Pos` 实例，但程序中除了实例本身之外没有任何其他信息表明它应具有这种类型。

解决问题的一种方法是通过为整个表达式添加类型注释来确保这三种类型都可用：

```lean
{{#example_in Examples/Classes.lean hPlusLotsaTypes}}
```



```output info
{{#example_out Examples/Classes.lean hPlusLotsaTypes}}
```

然而，这种解决方案对于正数库的用户来说并不是很方便。

## 输出参数

这个问题也可以通过将 `γ` 声明为一个*输出参数*来解决。
大多数类型类参数是搜索算法的输入：它们用于选择一个实例。
例如，在 `OfNat` 实例中，类型和自然数都被用来选择自然数字面量的特定解释。
然而，在某些情况下，当一些类型参数尚未知道时，开始搜索过程并使用在搜索中发现的实例来确定元变量的值可能会很方便。
不需要启动实例搜索的参数是该过程的输出，使用 `outParam` 修饰符进行声明：

```lean
{{#example_decl Examples/Classes.lean HPlusOut}}
```

有了这个输出参数，类型类实例搜索能够在不事先知道 `γ` 的情况下选择一个实例。
例如：

```lean
{{#example_in Examples/Classes.lean hPlusWorks}}
```



```output info
{{#example_out Examples/Classes.lean hPlusWorks}}
```

将输出参数视为定义了一种函数可能会有所帮助。
任何一个具有一个或多个输出参数的类型类的实例都会为 Lean 提供确定输出从输入的指令。
搜索实例的过程可能会递归执行，这比简单地重载函数更强大。
输出参数可以确定程序中的其他类型，并且实例搜索可以将一组基础实例组合成具有此类型的程序。

## 默认实例

确定参数是输入还是输出可以控制 Lean 在何时启动类型类搜索的情况。
特别是，类型类搜索直到所有输入都已知时才会发生。
然而，在某些情况下，输出参数是不够的，而且在某些输入未知的情况下，实例搜索也应该发生。
这有点像 Python 或 Kotlin 中的可选函数参数的默认值，只不过这里选择的是默认类型。

_默认实例_ 是在实例搜索中可用的实例，即使未知其所有输入也是如此。
当可以使用这些实例之一时，它将被使用。
这可以使程序成功通过类型检查，而不是由于未知类型和元变量而失败并出现错误。
另一方面，默认实例可以使实例选择变得不太可预测。
特别是，如果选择了一个不希望的默认实例，那么表达式的类型可能与预期不同，这可能导致程序中其他位置出现混乱的类型错误。
对于使用默认实例的位置要慎重选择！

一个使用默认实例可能很有用的例子是可以从 `Add` 实例推导出的 `HPlus` 的实例。
换句话说，普通加法是异构加法的一种特殊情况，其中所有三个类型恰好相同。
可以使用以下实例来实现这一点：

```lean
{{#example_decl Examples/Classes.lean notDefaultAdd}}
```

使用这个例子，`hPlus` 可以用于任何可相加的类型，例如 `Nat`：

```lean
{{#example_in Examples/Classes.lean hPlusNatNat}}
```



```output info
{{#example_out Examples/Classes.lean hPlusNatNat}}
```

然而，这个实例仅会用于已知两个参数类型的情况下。例如，

```lean
{{#example_in Examples/Classes.lean plusFiveThree}}
```

得到这个类型。

```output info
{{#example_out Examples/Classes.lean plusFiveThree}}
```

# Markdown 翻译

```
如预期，但是...
```

# 原文

## As expected, but

Let's assume you see a tortoise in Vermont today and I insist, as I have been insisting for many years, that when I last measured its speed half an hour ago, it was moving at 1 mile per hour. Suppose you say that it must have been moving faster than that half an hour ago. How might I reply?

A good suggestion might be this: I might suggest that the present state of the tortoise is a consequence of its past states, and that these past states fully determine the present. If so, then given exactly how the tortoise was half an hour ago, the tortoise couldn't possibly be moving any faster than it currently is.

This suggestion has widest possible generality and simplicity. It would apply to everything and it requires nothing except the rule of cause and effect. And it is fairly easy to check: if you know exactly what the tortoise's past states were, and you also know exactly what the laws of physics are, then, if you are at all bright, you can deduce from these with certainty exactly how rapidly the tortoise will be going half an hour later on. And so, if I say that when I last measured half an hour ago to say how fast it was moving then, there is a certain fact of the matter about that, even if, for whatever reason, I am not aware of that fact.

Let's suppose that, indeed, its going faster than that half an hour ago is made impossible by the differential equation of motion, with appropriate initial conditions, together perhaps with other fundamental principles. Then, given my suggestion that these laws and initial conditions together determine the present, it follows that its going faster then is indeed made impossible by the present. If I claim the tortoise couldn't possibly have been going faster than it is now, then the laws of physics must somehow or other make this true.

Of course, it is logically possible that the tortoise speeded up from then until now. But if its doing so is made impossible by the laws and initial conditions, then there is a sense in which its doing so is impossible or excluded by all the evidence there is, despite the fact that it might have happened. According to my claim, it follows that its speeding up is impossible in an absolute sense. That, in essence, is what I mean by the statement that the laws of physics, as we know them now, make it impossible for the tortoise to have been going any faster than it currently is.


```lean
{{#example_in Examples/Classes.lean plusFiveMeta}}
```

得到的类型包含两个元变量，一个用于剩余的参数，一个用于返回类型：

```output info
{{#example_out Examples/Classes.lean plusFiveMeta}}
```

在绝大多数情况下，当有人提供一个参数给加法时，另一个参数将具有相同的类型。

要将此实例变为默认实例，请添加 `default_instance` 属性：

```lean
{{#example_decl Examples/Classes.lean defaultAdd}}
```

通过这个默认实例，示例的类型更加有用：

```lean
{{#example_in Examples/Classes.lean plusFive}}
```

# Lean定理证明

## 引言
LEARN是一种交互式证明辅助工具，使用λProlog表示逻辑和定理以及构造证明。本文将介绍LEAN的一些基本概念和在其中进行证明的一般过程。

## 概述
在LEAN中，我们可以定义一些基本类型和命题。类型是一种分类，而命题是对现实世界的断言。通过类型和命题的定义，我们可以建立一个逻辑系统。在逻辑系统中，我们可以使用一些基本规则来构建证明。

## Lean中的定理
在LEAN中，定理是一种表示命题成立的方法。在进行证明之前，我们需要先定义一些类型和命题，然后通过一系列推理步骤来构造证明。证明可以包括一系列引理和定理的应用。

定理的一般形式如下所示：
```lean
theorem <定理名称> : <命题表达式> :=
begin
  -- 证明的步骤
  ...
end
```

## 证明步骤
在证明过程中，我们可以使用一些基本规则和策略来进行推理。以下是一些常用的证明策略：

- `assume`：假设一个命题成立。
- `have`：引入一个新的命题并为其命名。
- `show`：展示一个命题的证明。
- `by`：通过引用先前的引理或定理来证明一个命题。
- `apply`：将一个命题应用到另一个命题上。
- `exact`：直接证明一个命题。

在证明过程中，我们可以使用这些策略来逐步推理和证明定理。

## 示例
让我们用一个简单的例子来说明LEAN中的证明过程。假设我们要证明以下定理：“对于任意整数a和b，如果a是偶数且b是偶数，则a + b是偶数”。

```lean
theorem even_plus_even_is_even : ∀ (a b : ℤ), even a → even b → even (a + b) :=
begin
  assume a b,
  assume h1 h2,
  cases h1 with n hn,
  cases h2 with m hm,
  have h3 : a + b = 2 * (n + m),
  calc
    a + b = 2 * n + 2 * m : by rw [←mul_add]
    ...   = 2 * (n + m)   : by simp,
  show even (a + b), 
  exact exists.intro (n + m) h3,
end
```

在这个例子中，我们首先假设a和b是任意的整数，并假设a是偶数，b也是偶数。然后，我们使用`cases`策略来引入一个新的整数n和m，并分别证明a = 2n和b = 2m。接下来，我们使用`have`策略来引入一个新的命题h3，并通过简化推导得到a + b = 2 * (n + m)。最后，我们使用`show`策略展示a + b是偶数，并使用`exact`策略直接证明该命题。

## 结论
在LEAN中，我们可以使用一系列基本规则和策略来构建和证明定理。通过这些工具，我们可以在交互式环境中进行证明过程，并逐步推理和证明命题。

希望本文对理解LEAN定理证明过程有所帮助！

```output info
{{#example_out Examples/Classes.lean plusFive}}
```

每个可多态和同态版本的运算符遵循一个默认实例的模式，该模式允许在期望异态版本的上下文中使用同态版本。
中缀运算符被替换为对异态版本的调用，并且在可能的情况下选择同态默认实例。

类似地，只需写 `{{#example_in Examples/Classes.lean fiveType}}` 就会得到 `{{#example_out Examples/Classes.lean fiveType}}` 而不是等待更多信息以选择 `OfNat` 实例的含有元变量的类型。
这是因为 `Nat` 类型的 `OfNat` 实例是一个默认实例。

默认实例也可以分配 _优先级_，这将影响到在多个实例可应用时将选择哪个实例。
有关默认实例优先级的更多信息，请参阅 Lean 手册。


## 练习

定义一个 `HMul (PPoint α) α (PPoint α)` 实例，将两个投影都乘以该标量。
它应该适用于任何具有 `Mul α` 实例的类型。
例如，

```lean
{{#example_in Examples/Classes.lean HMulPPoint}}
```

应该产出

```output info
{{#example_out Examples/Classes.lean HMulPPoint}}
```

