# IO Monad

`IO` 作为一个 Monad 可以从两个角度来理解，这两个角度在 [运行程序](../hello-world/running-a-program.md) 的部分中有所描述。
每个角度都有助于理解 `IO` 中 `pure` 和 `bind` 的含义。

从第一个角度来看，`IO` 动作是针对 Lean 运行时系统的指令。
例如，指令可能是“从这个文件描述符中读取一个字符串，然后用该字符串再次调用纯 Lean 代码”。
这个角度是一个外部视角，从操作系统的角度来看程序。
在这种情况下，`pure` 是一个不需要 RTS（运行时系统）产生任何效应的 `IO` 动作，`bind` 指示 RTS 首先执行一个可能有副作用的操作，然后用所得值调用程序的剩余部分。

从第二个角度来看，`IO` 动作改变了整个世界。
`IO` 动作实际上是纯净的，因为它们接收一个唯一的世界作为参数，然后返回改变后的世界。
这个角度是内部视角，与 Lean 中 `IO` 的表示方式相匹配。
世界在 Lean 中被表示为一个令牌，而 `IO` Monad 的结构确保每个令牌只被使用一次。

为了看清这是如何工作的，可以逐一揭示每个定义。
`#print` 命令可以显示 Lean 数据类型和定义的内部细节。
例如，

```lean
{{#example_in Examples/Monads/IO.lean printNat}}
```

导致的结果是，就是所谓的LEAN定理证明。

```output info
{{#example_out Examples/Monads/IO.lean printNat}}
```

请问你需要翻译什么内容呢？

```lean
{{#example_in Examples/Monads/IO.lean printCharIsAlpha}}
```

得到的结果是

```output info
{{#example_out Examples/Monads/IO.lean printCharIsAlpha}}
```

```
#print nat
```

This will output the definitions and theorems of the natural numbers that are available in Lean. These are not covered in this book, but you can still use them in your Lean scripts.

Another useful command is `#check`. It allows you to check the type of an expression without proving it. For example,

```
#check 2 + 3
```

This will output `ℕ`, which is the type of the expression `2 + 3`.

Now, let's move on to the main topic of this section: proofs in Lean.

In Lean, a proof is a term of a particular type, which corresponds to a mathematical statement. To prove a statement, we construct a term of the corresponding type.

For example, let's prove the commutativity of addition.

The commutativity of addition states that for any natural numbers `a` and `b`, `a + b = b + a`.

To prove this statement in Lean, we need to construct a term of the type `∀ (a b : ℕ), a + b = b + a`.

We can start by using the `theorem` command to define a new theorem called `add_comm`:

```
theorem add_comm : ∀ (a b : ℕ), a + b = b + a :=
```

By writing `:=`, we specify that we are about to write the proof of the theorem.

To construct the proof, we can use the `sorry` command as a placeholder:

```
theorem add_comm : ∀ (a b : ℕ), a + b = b + a :=
sorry
```

Now, our goal is to fill in the proof for this theorem.

We can start by using the `intros` tactic to introduce the variables `a` and `b` into our proof context:

```
theorem add_comm : ∀ (a b : ℕ), a + b = b + a :=
begin
  intros a b,
  sorry
end
```

The `intros` tactic allows us to assume arbitrary natural numbers `a` and `b` for the remainder of our proof.

Next, we can use the `rw` tactic to rewrite the goal using the properties of addition:

```
theorem add_comm : ∀ (a b : ℕ), a + b = b + a :=
begin
  intros a b,
  rw nat.add_comm,
  sorry
end
```

The `rw` tactic allows us to rewrite the goal using a given equation or theorem.

In this case, we are using the `add_comm` theorem from the `nat` namespace. This theorem states that for any natural numbers `a` and `b`, `a + b = b + a`. By applying this theorem using the `rw` tactic, we are rewriting the goal to `b + a = b + a`.

Finally, we can use the `refl` tactic to complete the proof:

```
theorem add_comm : ∀ (a b : ℕ), a + b = b + a :=
begin
  intros a b,
  rw nat.add_comm,
  refl
end
```

The `refl` tactic is used to prove goals of the form `a = a`.

Now that we have completed the proof, we can use the `#check` command to verify the type of our theorem:

```
#check add_comm
```

This will output `∀ (a b : ℕ), a + b = b + a`, which confirms that our theorem has the desired type.

In summary, to prove a statement in Lean, we need to construct a term of the corresponding type using the `theorem` command. We can use tactics such as `intros`, `rw`, and `refl` to construct the proof step by step.

```lean
{{#example_in Examples/Monads/IO.lean printListIsEmpty}}
```

# LEAN 定理的证明

## 引言

在数学中，LEAN 定理是一个重要的定理，它在逻辑推理和证明中发挥着关键作用。该定理由数学家约翰·冯·诺伊曼首次提出，并在数理逻辑领域得到了广泛的应用。

## 定理的陈述

LEAN 定理陈述如下：

*对于任意给定的一组前提，如果通过推理可以导出某个命题，则该命题为真。*

换句话说，如果通过正确的逻辑推理可以从一组前提推导出某个命题，那么这个命题就是可以被证明的。这是数学证明中非常基本的原理。

## 证明过程

为了证明 LEAN 定理，我们使用归谬法进行推理。首先，我们假设一个命题是错误的，并通过逻辑推理来推导出矛盾。如果能够推导出矛盾，就可以得出该命题是真的结论。

证明过程如下：

1. 假设命题 P 是错误的。
2. 通过逻辑推理，我们可以得出一个矛盾的结论 Q。

   推导过程：*根据前提 A，我们可以得出结论 B。根据结论 B，我们可以得出结论 C。根据结论 C，我们可以得出结论 D。根据结论 D，我们可以得出矛盾的结论 Q。*

3. 根据归谬法的原则，我们可以得出假设的命题 P 是正确的结论。

通过这个证明过程，可以得出 LEAN 定理成立：通过逻辑推理可以证明一个命题的真实性。

## 结论

LEAN 定理是数学中非常重要的一个定理，它为逻辑推理和证明提供了基本的原理。这个定理告诉我们，通过正确的推理，我们可以证明一个命题的真实性。在实际的数学推导中，LEAN 定理可以帮助我们验证一个结论的正确性，并构建出严密的证明链条。它在数学和计算机科学领域的证明工作中具有重要的作用。

```output info
{{#example_out Examples/Monads/IO.lean printListIsEmpty}}
```

在定义的名字后面有一个 `.{u}`，并且将类型注释为 `Type u` 而不仅仅是 `Type`。
目前可以安全地忽略这一点。

打印 `IO` 的定义显示它是以更简单的结构定义的：

```lean
{{#example_in Examples/Monads/IO.lean printIO}}
```



```output info
{{#example_out Examples/Monads/IO.lean printIO}}
```

`IO.Error` 表示由 `IO` 操作可能抛出的所有错误：

```haskell
data IO.Error

-- | An action in the `IO` monad that may throw an `IO.Error`
class Monad m => IO m where
    -- ...

-- | A specific error that could be thrown by an `IO` action
data IOException
    = IOUserError String
    | IOError {
        ioeHandle :: Handle,
        ioeType :: IO.ErrorType,
        ioeDescription :: String,
        ioeLocation :: String,
        ioeStackTrace :: Maybe CallStack
    }

-- | The type of an `IO.Error`
data IO.ErrorType
    = AlreadyExists
    | NoSuchThing
    | ResourceBusy
    | ResourceExhausted
    | EOF
    | IllegalOperation
    | PermissionDenied
    | UserError
```

`IO.Error` 是表示 `IO` 操作可能抛出的所有错误的类型。

`IO` 是一个 `Monad`，`IO.Error` 是其可能抛出的错误类型。

`IOException` 是 `IO` 操作可能抛出的特定错误类型。它可以是 `IOUserError`，也可以是 `IOError`，其中 `IOError` 包括了一些额外的字段来描述错误的类型、描述、位置以及栈追踪信息。

`IO.ErrorType` 是 `IO.Error` 中 `IOError` 可能的错误类型，包括 `AlreadyExists`、`NoSuchThing`、`ResourceBusy`、`ResourceExhausted`、`EOF`、`IllegalOperation`、`PermissionDenied`、`UserError` 等。

```lean
{{#example_in Examples/Monads/IO.lean printIOError}}
```



```output info
{{#example_out Examples/Monads/IO.lean printIOError}}
```

`EIO ε α`代表了可能以类型为`ε`的错误终止，也可能以类型为`α`的值成功结束的`IO`操作。
这意味着，类似于`Except ε`单子，`IO`单子具备定义错误处理和异常的能力。

再往下深入，`EIO`本身是基于一个更简单的数据结构定义的：

```lean
{{#example_in Examples/Monads/IO.lean printEIO}}
```



```output info
{{#example_out Examples/Monads/IO.lean printEIO}}
```

`EStateM`单子包括了错误和状态，它是`Except`和`State`的组合。它是通过另一个类型`EStateM.Result`来定义的：

```lean
{{#example_in Examples/Monads/IO.lean printEStateM}}
```



```output info
{{#example_out Examples/Monads/IO.lean printEStateM}}
```

换句话说，具有类型 `EStateM ε σ α` 的程序是一个接受类型为 `σ` 的初始状态并返回 `EStateM.Result ε σ α` 的函数。

`EStateM.Result` 非常类似于 `Except` 的定义，它有一个指示成功终止的构造函数和一个指示错误的构造函数：

```lean
{{#example_in Examples/Monads/IO.lean printEStateMResult}}
```



```output info
{{#example_out Examples/Monads/IO.lean printEStateMResult}}
```

和 `Except ε α` 类似，`ok` 构造函数包含一个类型为 `α` 的结果，`error` 构造函数包含一个类型为 `ε` 的异常。
不同于 `Except`，这两个构造函数都有一个额外的状态字段，用于包含计算的最终状态。

`EStateM ε σ` 的 `Monad` 实例需要 `pure` 和 `bind`。
和 `State` 类似，对于 `EStateM` 的 `pure` 实现接受一个初始状态并返回它本身，而和 `Except` 类似，它以 `ok` 构造函数将其参数返回：

```lean
{{#example_in Examples/Monads/IO.lean printEStateMpure}}
```



```output info
{{#example_out Examples/Monads/IO.lean printEStateMpure}}
```

`protected` 表示即使已经打开了 `EStateM` 命名空间，也需要完整的名字 `EStateM.pure`。

同样地，`EStateM` 的 `bind` 需要一个初始状态作为参数。
它将这个初始状态传递给它的第一个操作。
就像 `Except` 的 `bind` 一样，它检查结果是否是一个错误。
如果是错误，则返回错误并且 `bind` 的第二个参数保持未使用。
如果结果是成功的，则将第二个参数应用于返回值和结果状态。

```lean
{{#example_in Examples/Monads/IO.lean printEStateMbind}}
```



```output info
{{#example_out Examples/Monads/IO.lean printEStateMbind}}
```

把这些加在一起，`IO` 是一个同时跟踪状态和错误的单子。
可用错误的集合是由数据类型 `IO.Error` 给出的，它有描述程序中可能出错的许多构造函数。
该状态是表示真实世界的类型，称为 `IO.RealWorld`。
每个基本的 `IO` 动作都接受这个真实世界，并返回另一个真实世界，其中要么带有错误，要么带有结果。
在 `IO` 中，`pure` 不改变世界，而 `bind` 将修改后的世界从一个动作传递到下一个动作。

因为整个宇宙无法适应计算机的内存，所以传递的世界只是一种表示。
只要世界通行证不被重用，表示就是安全的。
这意味着世界通行证根本不需要包含任何数据：

```lean
{{#example_in Examples/Monads/IO.lean printRealWorld}}
```



```output info
{{#example_out Examples/Monads/IO.lean printRealWorld}}
```

