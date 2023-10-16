# Applicative契约

和`Functor`、`Monad`以及实现了`BEq`和`Hashable`的类型一样，`Applicative`也有一组规则，所有实例都应该遵循。

Applicative Functor应该遵循四个规则：
1. 它应该保持identity，所以 `pure id <*> v = v`
2. 它应该保持函数组合，所以 `pure (· ∘ ·) <*> u <*> v <*> w = u <*> (v <*> w)`
3. 应用纯操作应该是一个无操作，所以 `pure f <*> pure x = pure (f x)`
4. 纯操作的顺序不重要，所以 `u <*> pure x = pure (fun f => f x) <*> u`

为了检查`Applicative Option`实例是否满足这些规则，首先将`pure`扩展为`some`。

第一条规则说明 `some id <*> v = v`。
`Option`的`seq`定义说明这与`id <$> v = v`相同，而这是已经检查过的`Functor`规则之一。

第二条规则说明 `some (· ∘ ·) <*> u <*> v <*> w = u <*> (v <*> w)`。
如果 `u`、`v` 或 `w` 中有任何一个为`none`，那么两边都是`none`，所以属性成立。
假设 `u` 是 `some f`，`v` 是 `some g`，`w` 是 `some x`，那么这相当于说 `some (· ∘ ·) <*> some f <*> some g <*> some x = some f <*> (some g <*> some x)`。
计算这两边得到的结果是相同的：

```lean
{{#example_eval Examples/FunctorApplicativeMonad.lean OptionHomomorphism1}}

{{#example_eval Examples/FunctorApplicativeMonad.lean OptionHomomorphism2}}
```

第三条规则直接从 `seq` 的定义中得出：

```lean
{{#example_eval Examples/FunctorApplicativeMonad.lean OptionPureSeq}}
```

第四种情况中，假设 `u` 是 `some f`，因为如果是 `none`，方程的两边都是 `none`。
`some f <*> some x` 直接求值为 `some (f x)`，同样的，`some (fun g => g x) <*> some f` 也是如此。

## 所有的 Applicative 都是 Functors

`Applicative` 的两个操作符足以定义 `map`：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean ApplicativeMap}}
```

只有当 `Applicative` 契约保证了 `Functor` 契约的前提下，才可以使用这一证明来实现 `Functor`。`Functor` 的第一个规则是 `id <$> x = x`，这直接遵循自 `Applicative` 的第一条规则。`Functor` 的第二个规则是 `map (f ∘ g) x = map f (map g x)`。展开这里的 `map` 的定义会得到 `pure (f ∘ g) <*> x = pure f <*> (pure g <*> x)`。使用纯操作顺序不起作用的规则，左侧可以重写为 `pure (· ∘ ·) <*> pure f <*> pure g <*> x`。这是一种适用于 Applicative Functor 的函数组合规则的实例。

这个证明支持了通过 `pure` 和 `seq` 给出 `map` 的默认定义，从而将 `Applicative` 扩展到了 `Functor`。

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean ApplicativeExtendsFunctorOne}}
```

## 所有的 Monads 都是 Applicative Functors

`Monad` 类型类的一个实例已经要求实现 `pure` 函数。
和 `bind` 函数一起，这已经足够定义 `seq` 函数了：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean MonadSeq}}
```

再次检查一下 `Monad` 契约蕴含着 `Applicative` 契约，这样如果 `Monad` 继承了 `Applicative`，就可以将这个定义用作 `seq` 的默认实现。

本节的其余部分是关于基于 `bind` 实现的 `seq` 是否符合 `Applicative` 契约的论证。
函数式编程的美妙之处之一就是这种论证可以在纸上用铅笔完成，使用 [在 [评估表达式](../getting-to-know/evaluating.md) 这一节中介绍的评估规则。
在阅读这些论证时想一想操作的含义有时可以帮助理解。

用显式使用 `>>=` 替换 `do` 记法使得应用 `Monad` 规则变得更容易：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean MonadSeqDesugar}}
```

为了检查这个定义是否满足恒等性，我们要检查 `seq (pure id) (fun () => v) = v`。

左边等式等价于 `pure id >>= fun g => (fun () => v) () >>= fun y => pure (g y)`。

去掉中间的 `unit` 函数，得到 `pure id >>= fun g => v >>= fun y => pure (g y)`。

利用 `pure` 是 `>>=` 的左单位元的事实，可以将等式变为 `v >>= fun y => pure (id y)`，也就是 `v >>= fun y => pure y`。

因为 `fun x => f x` 和 `f` 是等价的，所以这与 `v >>= pure` 是等价的，我们可以利用 `pure` 是 `>>=` 的右单位元的事实，得到 `v`。

这种非正式的推理可以通过一些重新格式化来使阅读更加轻松。
在下面的表格中，将 "EXPR1 ={ REASON }= EXPR2" 读作 "EXPR1 等于 EXPR2，因为 REASON"：
```lean
lemma m_seq_resp_id {α : Type u} {v : m α} : pure id >>= (λ g, (λ _, v) >>= (λ y, pure (g y))) = v :=
begin
  simp [m_seq, pure, bind],
  -- more steps...
end
```

为了检查它是否满足函数组合性，我们要检查 `pure (· ∘ ·) <*> u <*> v <*> w = u <*> (v <*> w)`。

第一步是用 `seq` 的这个定义替换 `<*>`。

之后，通过使用 `Monad` 合约中的恒等性和结合性规则，可以得到一个（有点长）的步骤序列，从一个等式推导到另一个等式：
```lean
lemma m_seq_resp_comp {α β γ : Type u} {u : m (β → γ)} {v : m (α → β)} {w : m α} : pure comp <*> u <*> v <*> w = u <*> (v <*> w) :=
begin
  simp [m_seq, m_map],
  -- more steps...
end
```

为了检查将纯操作进行序列化是一个空操作：
```lean
lemma m_seq_pure_no_op {α : Type u} {v : α} : pure v >>= (λ x, pure x) = pure v :=
begin
  simp [m_seq, pure, bind],
  -- more steps...
end
```

最后，为了检查纯操作的顺序不重要：
```lean
lemma m_seq_pure_no_order {α β : Type u} {f : α → β} {v : α} : pure f <*> pure v = pure (f v) :=
begin
  simp [m_seq, pure, bind],
  -- more steps...
end
```

这就证明了一个扩展了 `Applicative` 的 `Monad` 定义，其中 `seq` 有一个默认定义。

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean MonadExtends}}
```

# LEAN 定理证明（Monad 中的 Applicative 特性）

## 附加条件

除了遵守每个类型类关联的单独契约外，`Functor`、`Applicative` 和 `Monad` 的组合实现应该与这些默认实现相等。
换句话说，一个同时提供 `Applicative` 和 `Monad` 实例的类型不应该有一个与 `Monad` 实例生成的默认实现不同的 `seq` 实现。
这很重要，因为多态函数可能会经过重构，将对 `>>=` 的使用替换为等价的 `<*>` 使用，或者将对 `<*>` 的使用替换为等价的 `>>=` 使用。
这种重构不应该改变使用此代码的程序的含义。

这个规则解释了为什么在 `Monad` 实例中不应该使用 `Validate.andThen` 来实现 `bind`。
单独使用时，它遵守了 monad 契约。
然而，当它用于实现 `seq` 时，行为与 `seq` 本身不等价。
为了看出它们的区别，考虑两个返回错误的计算的例子。
首先，假设有一个情况，其中应返回两个错误，一个来自验证一个函数（这也可以是之前的参数导致的），一个来自验证一个参数：

```lean
{{#example_decl Examples/FunctorApplicativeMonad.lean counterexample}}
```

将它们与`Validate`的`Applicative`实例中的`<*>`版本结合起来，会将两个错误都报告给用户：

```lean
{{#example_eval Examples/FunctorApplicativeMonad.lean realSeq}}
```

使用用 `>>=` 实现的 `seq` 版本，这里重新改写为 `andThen`，只能获取到第一个错误：

```haskell
seq :: (Monad m) => [m a] -> m [a]
seq [] = return []
seq (ma:mas) = do
    a <- ma
    as <- seq mas
    return (a:as)

andThen :: (Monad m) => m a -> m b -> m a
andThen ma mb = ma >>= \a -> mb >> return a
```

This is because the `andThen` function always passes the result of the first computation, `ma`, to the second computation, `mb`, and then returns the result of the first computation. Therefore, any errors that occur during the second computation are not propagated or available. This differs from the original implementation of `seq` where all errors were collected and returned in a list.

这是因为 `andThen` 函数总是将第一个计算的结果 `ma` 传递给第二个计算 `mb`，然后返回第一个计算的结果。因此，第二个计算过程中发生的任何错误都不会被传播或者获取到。这与 `seq` 的原始实现不同，原始实现会将所有的错误收集并以列表的形式返回。

```lean
{{#example_eval Examples/FunctorApplicativeMonad.lean fakeSeq}}
```

