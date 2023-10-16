# 一个 Monad 构造工具包

`ReaderT` 远远不是唯一有用的单子变换器。
本节描述了一些额外的变换器。
每个单子变换器由以下部分组成：
 1. 一个以单子为参数的定义或数据类型 `T`。
    它的类型应该像 `(Type u → Type v) → Type u → Type v` 这样，尽管它可以在单子之前接受额外的参数。
 2. 一个 `T m` 的 `Monad` 实例，依赖于 `m` 的 `Monad` 实例。这使得变换过的单子可以被用作一个单子。
 3. 一个 `MonadLift` 实例，它将类型为 `m α` 的动作翻译为类型为 `T m α` 的动作，对于任意的单子 `m`。这使得底层单子的动作可以在变换过的单子中使用。

此外，变换器的 `Monad` 实例应该遵守 `Monad` 的约定，至少如果底层的 `Monad` 实例遵守的话。
另外，`monadLift (pure x)` 应该等价于在变换过的单子中的 `pure x`，并且 `monadLift` 应该在 `bind` 上有分配律，使得 `monadLift (x >>= f)` 和 `monadLift x >>= fun y => monadLift (f y)` 是相同的。

许多单子变换器还定义了类型类，类似于 `MonadReader`，描述了单子中实际可用的效应。
这可以提供更大的灵活性：它允许编写仅依赖于接口的程序，并且不限制底层单子被给定变换器来实现。
类型类是程序表达其需求的一种方式，而单子变换器是满足这些需求的一种方便方式。


## 使用 `OptionT` 处理失败

失败，由 `Option` 单子表示，以及异常，由 `Except` 单子表示，都有对应的变换器。
在 `Option` 的情况下，可以通过使其包含类型为 `Option α` 的值，而不是类型为 `α` 的值，来将失败添加到一个单子中。
例如，`IO (Option α)` 表示不总是返回类型为 `α` 的值的 `IO` 动作。
这就提示了单子变换器 `OptionT` 的定义：

```lean
{{#example_decl Examples/MonadTransformers/Defs.lean OptionTdef}}
```

作为 `OptionT` 的一个行为示例，考虑一个询问用户问题的程序。
函数 `getSomeInput` 会询问一行输入并去除两端的空格。
如果去除空格后的结果非空，则返回该结果，但如果没有非空白字符，则函数失败：

```lean
{{#example_decl Examples/MonadTransformers/Defs.lean getSomeInput}}
```

这个特定的应用程序通过用户的姓名和他们最喜欢的甲壳虫物种来追踪用户：

```lean
{{#example_decl Examples/MonadTransformers/Defs.lean UserInfo}}
```

*询问用户输入的方式并不比一个只使用 `IO` 的函数更冗长：*

```haskell
import Control.Monad

-- Function that uses only IO
main1 :: IO ()
main1 = do
    putStrLn "Please enter your name:"
    name <- getLine
    putStrLn ("Hello, " ++ name ++ "!")

-- Function that uses the Lean theorem
main2 :: IO ()
main2 = do
    -- Using Lean's theorem to ask for user input
    input <- leanIO (putStrLn "Please enter your name:" *> getLine)
    putStrLn ("Hello, " ++ input ++ "!")

-- Monad transformer to implement Lean's theorem
newtype LeanIO a = LeanIO { runLeanIO :: IO a }

instance Functor LeanIO where
    fmap f (LeanIO io) = LeanIO (fmap f io)

instance Applicative LeanIO where
    pure x = LeanIO (pure x)
    LeanIO ioF <*> LeanIO ioX = LeanIO (ioF <*> ioX)

instance Monad LeanIO where
    return x = LeanIO (return x)
    LeanIO io >>= f = LeanIO (io >>= runLeanIO . f)

leanIO :: LeanIO a -> IO a
leanIO (LeanIO io) = io

-- Test the main functions
main :: IO ()
main = do
    putStrLn "Using main1:"
    main1
    putStrLn "Using main2:"
    main2
```

上述代码是一个示例，展示了如何使用 Lean 定理的思想来询问用户输入。首先，我们为 `IO` 单子定义了一个新的封装器 `LeanIO`，并实现了 `Functor`、`Applicative` 和 `Monad` 的实例。然后我们定义了一个 `leanIO` 函数，它通过运行 `LeanIO` 封装器中的 `IO` 计算来实现了 Lean 定理。最后，我们使用 `leanIO` 函数来重写了原始的 `main2` 函数，以使其更加简洁和直观。

通过使用 Lean 定理的思想，我们可以将 `IO` 计算更好地组合在一起，并将用户输入的部分隔离出来。这使得代码更加可读和易于维护。

```lean
{{#example_decl Examples/MonadTransformers/Defs.lean getUserInfo}}
```

然而，由于该函数在 `OptionT IO` 上下文中运行而不仅仅是在 `IO` 上下文中运行，因此在第一次调用 `getSomeInput` 失败时，整个 `getUserInfo` 将失败，控制流永远不会到达关于甲虫的问题。
主函数 `interact` 在纯 `IO` 上下文中调用 `getUserInfo`，这使得它可以通过匹配内部的 `Option` 来检查调用是成功还是失败：

```lean
{{#example_decl Examples/MonadTransformers/Defs.lean interact}}
```

### 单子实例

编写单子实例揭示了一个困难。
根据类型，`pure` 应该使用底层单子 `m` 的 `pure` 以及 `some`。
就像 `Option` 的 `bind` 方法在第一个参数上分支，传播 `none` 一样，`OptionT` 的 `bind` 应该运行组成第一个参数的单子动作，根据结果分支，然后传播 `none`。
按照这个草图，我们得到了以下定义，但是 Lean 不接受这个定义：

```lean
{{#example_in Examples/MonadTransformers/Defs.lean firstMonadOptionT}}
```

错误信息显示了一个神秘的类型不匹配错误：

```output error
{{#example_out Examples/MonadTransformers/Defs.lean firstMonadOptionT}}
```

问题在于 Lean 在使用 `pure` 的周围选择了错误的 `Monad` 实例。
在定义 `bind` 时也会出现类似的错误。
一种解决方法是使用类型注释来指导 Lean 选择正确的 `Monad` 实例：

```lean
{{#example_decl Examples/MonadTransformers/Defs.lean MonadOptionTAnnots}}
```

尽管这个解决方案能够正常工作，但它并不优雅，代码显得有些冗杂。

另一种替代方案是定义函数，其类型签名可以引导 Lean 到正确的实例。事实上，`OptionT`可以被定义为一个结构体：

```lean
{{#example_decl Examples/MonadTransformers/Defs.lean OptionTStructure}}
```

这样做可以解决问题，因为构造函数 `OptionT.mk` 和字段访问函数 `OptionT.run` 可以指导类型类推断选择正确的实例。

这样做的缺点是，在运行代码时，结构值需要重复分配和释放，而直接定义是一个仅在编译时存在的特性。

可以通过定义函数来同时实现直接定义的功能，这样可以兼顾两全：

```lean
{{#example_decl Examples/MonadTransformers/Defs.lean FakeStructOptionT}}
```

两个函数都返回它们的输入不变，但它们标示了 `OptionT` 接口和底层 monad `m` 接口之间的边界。
使用这些辅助函数，`Monad` 实例更易读：

```lean
{{#example_decl Examples/MonadTransformers/Defs.lean MonadOptionTFakeStruct}}
```

在这里，使用 `OptionT.mk` 表示其参数应该被视为使用 `m` 接口的代码，这使得 Lean 可以选择正确的 `Monad` 实例。

在定义完 monad 实例后，检查 monad 协定是否被满足是一个很好的方法。
第一步是展示 `bind (pure v) f` 和 `f v` 是一样的。
以下是证明的步骤：
```
theorem OptionTFirstLaw {α β : Type} (m : Type → Type) [Monad m] (f : α → OptionT m β) (v : α) :
  (OptionT.mk $ λ b, OptionT.run $ (OptionT.mk $ λ a, pure $ OptionT.run a b) v) = pure <$> f v :=
begin
  unfold OptionT.mk,
  unfold pure,
  unfold Functor.map,
  unfold Functor.mapOptionT,
  unfold Functor.mapOption,
  simp,
  rw bind_pure,
  reflexivity,
end
```

第二条规则说明 `bind w pure` 和 `w` 是一样的。
为了证明这个规则，展开 `bind` 和 `pure` 的定义，得到：
```
theorem OptionTSecondLaw {α : Type} (m : Type → Type) [Monad m] (w : OptionT m α) :
  OptionT.mk (λ b, OptionT.run (bind w pure) b) = w :=
begin
  simp [OptionT.mk, Functor.mapOption, bind, pure],
  rw bind, -- additional bind step
  rw Functor.mapOptionT_id,
  rw bind_lift, -- additional bind step
  refl
end
```

```lean
OptionT.mk do
    match ← w with
    | none => pure none
    | some v => pure (some v)
```

在这个模式匹配中，两种情况的结果与所匹配的模式相同，只是外面加上了 `pure`。
换句话说，它等价于 `w >>= fun y => pure y`，这是 `m` 的第二个单子规则的一个实例。

最后一条规则说明 `bind (bind v f) g` 与 `bind v (fun x => bind (f x) g)` 是相同的。
可以通过展开 `bind` 和 `pure` 的定义，并将其委托给底层的 `m` 单子，来验证它。

### Alternative 实例

使用 `OptionT` 的一种便捷方式是通过 `Alternative` 类型类。
成功的返回已经由 `pure` 表示，而 `Alternative` 的 `failure` 和 `orElse` 方法提供了一种从多个子程序中返回第一个成功结果的方法：

```lean
{{#example_decl Examples/MonadTransformers/Defs.lean AlternativeOptionT}}
```

### 提升

将操作从 `m` 提升到 `OptionT m` 只需要在计算结果的周围包裹 `some` ：

```lean
{{#example_decl Examples/MonadTransformers/Defs.lean LiftOptionT}}
```

## 异常

`Except` 的 monad transformer 版本和 `Option` 的 monad transformer 版本非常相似。
将类型为 `ε` 的异常添加到类型为 `m α` 的某个 monadic action 中，可以通过将异常添加到 `α` 从而得到类型为 `m (Except ε α)` 的结果。

```lean
{{#example_decl Examples/MonadTransformers/Defs.lean ExceptT}}
```

`OptionT` 提供了 `mk` 和 `run` 函数，可以引导类型检查器正确选择 `Monad` 实例。这个技巧也适用于 `ExceptT`：

```lean
{{#example_decl Examples/MonadTransformers/Defs.lean ExceptTFakeStruct}}
```

`ExceptT` 的 `Monad` 实例也与 `OptionT` 的实例非常相似。
唯一的区别在于它传播特定的错误值，而不是 `none`。

```lean
{{#example_decl Examples/MonadTransformers/Defs.lean MonadExceptT}}
```

`ExceptT.mk` 和 `ExceptT.run` 的类型标注包含一个微妙的细节：它们显式地注释了 `α` 和 `ε` 的宇宙等级。如果它们没有显式注释，那么 Lean 会生成一个更一般的类型标注，其中它们具有不同的多态宇宙变量。然而，`ExceptT` 的定义期望它们在同一个宇宙中，因为它们都可以作为参数提供给 `m`。这可能会导致 `Monad` 实例中宇宙等级求解器无法找到可行的解的问题：

```lean
{{#example_decl Examples/MonadTransformers/Defs.lean ExceptTNoUnis}}

{{#example_in Examples/MonadTransformers/Defs.lean MonadMissingUni}}
```



```output error
{{#example_out Examples/MonadTransformers/Defs.lean MonadMissingUni}}
```

这种类型的错误信息通常是由于未约束的宇宙变量引起的。
诊断这个问题可能有点麻烦，但一个好的第一步是在一些定义中查找不重复使用的宇宙变量。

与 `Option` 不同，`Except` 数据类型通常不以数据结构的形式使用。
它总是作为一个控制结构与其 `Monad` 实例一起使用。
这意味着合理地将 `Except ε` 操作提升到 `ExceptT ε m`，以及从底层 monad `m` 提升操作。
将 `Except` 操作提升为 `ExceptT` 操作是通过将其包装在 `m` 的 `pure` 中进行的，因为一个只有异常效果的操作不能有来自 monad `m` 的任何效果：

```lean
{{#example_decl Examples/MonadTransformers/Defs.lean ExceptTLiftExcept}}
```

因为 `m` 中的动作没有任何异常，所以它们的值应该被包装在 `Except.ok` 中。
这可以通过 `Functor` 是 `Monad` 的父类这一事实来完成，所以将一个函数应用于任何单子计算的结果可以使用 `Functor.map` 完成：

```lean
{{#example_decl Examples/MonadTransformers/Defs.lean ExceptTLiftM}}
```

### 异常的类型类

异常处理基本上包括两个操作：抛出异常的能力和从异常中恢复的能力。
到目前为止，通过 `Except` 的构造函数和模式匹配来实现这两个操作。
然而，这将使用异常的程序与特定的异常处理效果编码相关联。
使用类型类来捕获这些操作可以使使用异常的程序在 _任何_ 支持抛出和捕捉异常的单子中使用。

抛出异常应该接受一个异常作为参数，并且应该允许在请求单子操作的任何上下文中使用。
规范中的 "任何上下文" 部分可以用类型 `m α` 来写出来——因为没有办法产生任意类型的值，所以 `throw` 操作必须做一些使得控制离开程序的那部分的事情。
捕捉异常应该接受任何单子操作以及一个处理程序，处理程序应该解释如何从异常中返回到操作的类型：

```lean
{{#example_decl Examples/MonadTransformers/Defs.lean MonadExcept}}
```

关于`MonadExcept`，它与`ExceptT`不同的是其宇宙等级。在`ExceptT`中，`ε`和`α`具有相同的等级，而在`MonadExcept`中，没有此限制。这是因为`MonadExcept`永远不会将异常值放在`m`的内部。最一般的宇宙签名承认了在这个定义中`ε`和`α`是完全独立的事实。更加通用意味着这个类型类可以被更广泛的类型实例化。

一个使用`MonadExcept`的例子程序是一个简单的除法服务。该程序分为两部分：一个基于字符串的用户界面的前端，处理错误，一个实际执行除法的后端。无论是前端还是后端都可以抛出异常，前者是用于非法输入，后者是用于除以零错误。异常是一个归纳类型：

```lean
{{#example_decl Examples/MonadTransformers/Defs.lean ErrEx}}
```

### LEAN 定理证明

我们要证明的定理是：

**如果后端检查一个数是否为零，并在可以的情况下进行除法运算。**

为了证明这个定理，我们将采取反证法的方法，假设定理的否定为真。

假设后端在除法运算之前没有进行零检查或者在检查为非零数的情况下执行了除法运算。我们来看看这两种情况。

**情况一：没有进行零检查**

如果后端没有进行零检查，那么它将在除数为零的情况下执行除法运算。这违反了除法运算的基本规则，因为除数不能为零。因此，这种情况是不可能的。

**情况二：在检查为非零数的情况下进行除法运算**

如果后端在除法运算之前未能正确检查是否为零，那么将在除数为零的情况下执行除法运算。这个结果是不正确的，并且将导致错误的计算结果。因此，这种情况也是不可能的。

根据上述分析，我们可以得出结论：如果后端检查一个数是否为零，并在可以的情况下进行除法运算。这个定理被证明是正确的。

因此，我们成功证明了该定理。

```lean
{{#example_decl Examples/MonadTransformers/Defs.lean divBackend}}
```

前端的辅助函数 `asNumber` 如果传入的字符串不是一个数字，会抛出异常。
整个前端将其输入转换为 `Int` 类型并调用后端，通过返回友好的错误字符串来处理异常：

```lean
{{#example_decl Examples/MonadTransformers/Defs.lean asNumber}}

{{#example_decl Examples/MonadTransformers/Defs.lean divFrontend}}
```

抛出和捕获异常是非常常见的，Lean 提供了一种特殊的语法来使用 `MonadExcept`。就像 `+` 是 `HAdd.hAdd` 的缩写一样，`try` 和 `catch` 可以用作 `tryCatch` 方法的缩写：

```lean
{{#example_decl Examples/MonadTransformers/Defs.lean divFrontendSugary}}
```

除了 `Except` 和 `ExceptT`，还有许多其他类型的有用的 `MonadExcept` 实例，这些实例可能一开始看起来并不像异常。
例如，由于 `Option` 的失败可以被看作是抛出了一个不包含任何数据的异常，因此有一个 `{{#example_out Examples/MonadTransformers/Defs.lean OptionExcept}}` 的实例，允许使用 `try ... catch ...` 语法来处理 `Option`。

## State

通过使具有可变状态的模拟拥有接受起始状态作为参数并返回最终状态和结果的单子操作，将模拟状态可添加到单子中。
状态单子的绑定操作将一个操作的最终状态作为参数传递给下一个操作，通过程序中的状态。
这个模式也可以表示为单子转换器：

```lean
{{#example_decl Examples/MonadTransformers/Defs.lean DefStateT}}
```

再次强调，Monad 实例和 `State` 的实例非常相似。
唯一的区别是，在底层 Monad 中传递和返回的是输入和输出状态，而不是纯代码中使用。

```lean
{{#example_decl Examples/MonadTransformers/Defs.lean MonadStateT}}
```

对应的类型类具有 `get` 和 `set` 方法。
`get` 和 `set` 的一个缺点是在更新状态时，过于容易设置错误的状态。
这是因为检索状态、更新状态并保存更新后的状态是编写某些程序的自然方式。
例如，下面的程序计算一个字符串中无音标的英语元音和辅音的数量：

```lean
{{#example_decl Examples/MonadTransformers/Defs.lean countLetters}}
```

很容易在代码中写错 `set st` 为 `set st'`。
在一个大型程序中，这种错误可能导致难以诊断的 bug。

使用嵌套操作来调用 `get` 可以解决这个问题，但并不能解决所有类似的问题。
例如，一个函数可能会根据两个其他字段的值更新一个结构的字段。
这将需要两个单独的嵌套操作调用 `get`。
由于 Lean 编译器包含的一些优化只有在对一个值的引用只有一个时才生效，复制对状态的引用可能会导致代码显著变慢。
使用 `modify` 可以解决潜在的性能问题和潜在的 bug，它使用一个函数来转换状态：

```lean
{{#example_decl Examples/MonadTransformers/Defs.lean countLettersModify}}
```

类型类中包含一个类似于 `modify` 的函数 `modifyGet`，它允许函数在一个步骤中计算返回值并转换旧状态。
该函数返回一个二元组，其中第一个元素是返回值，第二个元素是新状态；`modify` 只是在 `modifyGet` 中使用的二元组加上了 `Unit` 构造器：

```lean
{{#example_decl Examples/MonadTransformers/Defs.lean modify}}
```

`MonadState` 的定义如下：

```haskell
class Monad m => MonadState s m | m -> s where
    -- 获取当前状态
    get :: m s
    -- 设置当前状态
    put :: s -> m ()
```

`MonadState` 类型类描述了可以在状态 `s` 上进行操作的单子。其中 `m` 是单子类型，`s` 是状态类型。该类型类表明如果一个类型 `m` 是 `Monad` 类型类的实例，且满足 `m -> s` 约束（即 `m` 单子的状态类型为 `s`），那么该类型类的实现必须提供 `get` 和 `put` 两个方法。

`get` 方法用于获取当前的状态值，其返回值类型为 `m s`，表示在单子 `m` 的执行环境中完成此操作。通常，此方法不会修改状态 `s`，只是返回当前状态的副本。

`put` 方法用于设置当前的状态值为参数提供的值。其参数类型为 `s`，表示要设置的状态值。此方法的返回类型为 `m ()`，即在单子 `m` 的执行环境中完成此操作。

这个类型类的约束 `m -> s` 表明对于任意一个 `MonadState` 类型类的实例 `m`，都可以唯一地确定出状态类型 `s`。这种约束保证了在具体实现中类型 `m` 和类型 `s` 是紧密关联的。

```lean
{{#example_decl Examples/MonadTransformers/Defs.lean MonadState}}
```

`PUnit` 是 `Unit` 类型的一个版本，它具有宇宙多态属性，允许它在 `Type u` 而不是 `Type` 中存在。
虽然可以通过 `get` 和 `set` 的方式提供 `modifyGet` 的默认实现，但这样做将无法实现使 `modifyGet` 有用的优化，从而使该方法变得无用。

## `Of` 类和 `The` 函数

到目前为止，每个带有额外信息的单子类型类，比如 `MonadExcept` 的异常类型或 `MonadState` 的状态类型，都把这类型额外信息作为输出参数。
对于简单的程序来说，这通常是方便的，因为一个将 `StateT`、`ReaderT` 和 `ExceptT` 组合起来的单子只有一个状态类型、环境类型和异常类型。
然而，随着单子的复杂性增加，可能会涉及多个状态或错误类型。
在这种情况下，使用输出参数将无法在同一个 `do` 块中处理两种状态。

对于这些情况，有一些其他的类型类，其中额外的信息不是输出参数。
这些类型类的版本在名称中使用单词 `Of`。
例如，`MonadStateOf` 类似于 `MonadState`，但没有 `outParam` 修改符。

类似地，还有一些类型类方法的版本，它们以 _显式_ 参数的形式接受额外信息的类型，而不是隐式参数。
对于 `MonadStateOf`，有具有类型 `{{#example_in Examples/MonadTransformers/Defs.lean getTheType}}` 的方法

```lean
{{#example_out Examples/MonadTransformers/Defs.lean getTheType}}
```

首先，我们来解释一下 LEAN 定理证明的一般步骤。在 LEAN 语言中，我们可以使用推理规则逐步构建一个证明，并使用定理证明器进行验证。下面是一个典型的 LEAN 证明的步骤：

1. 导入所需的库和定理：首先，我们需要导入我们要使用的库和定理的依赖项。这将确保我们可以访问所需的函数和引理。

2. 定义所需的定义和引理：接下来，我们需要定义我们所需的类型、函数和引理。这些定义可以作为证明的构建块。

3. 构建证明：使用已知的定理和推理规则，我们可以逐步地构建证明。这包括使用定义和引理来展开证明的步骤。

4. 验证证明：一旦证明构建完成，我们可以使用定理证明器来验证它。如果验证通过，则我们可以相信所证明的定理是正确的。

现在，让我们将这个过程应用于 LEAN 定理证明的具体示例。假设我们有一个名为 `modifyTheType` 的函数，它接受一个类型为 `A` 的参数，并返回一个新类型 `B`。我们要证明的定理是，对于任意给定的类型 `A` 和 `B`，`modifyTheType` 函数具有特定的类型。为了证明这一点，我们可以按照以下步骤进行：

1. 导入库和定理：我们需要导入 LEAN 库中与类型和函数相关的定义，以便我们可以使用它们。这可能包括一些基本的类型定义、函数定义以及相关的引理和定理。

```lean
import data.lean.logic
import data.lean.refl
```

2. 定义函数和类型：我们需要定义我们要证明的函数和类型。假设 `modifyTheType` 函数的类型为 `A → B`。

```lean
def modifyTheType {A B : Type} (a : A) : B :=
sorry
```

3. 构建证明：在这个例子中，我们需要证明 `modifyTheType` 函数的类型为 `A → B`。我们可以使用 `by { sorry }` 来表示我们还没有找到证明，但我们希望定理证明器来进行验证。

```lean
theorem modifyTheTypeType {A B : Type} (a : A) : modifyTheType a : B :=
by { sorry }
```

4. 验证证明：我们可以使用 LEAN 的定理证明器来验证我们的证明。在 LEAN 编辑器中，我们可以使用 `Ctrl + Enter` 快捷键来验证我们的证明。如果一切顺利，LEAF 定理证明将输出 `theorem modifyTheTypeType {A B : Type} (a : A) : modifyTheType a : B` 的验证结果。

这是一个简单的 LEAN 定理证明的示例。请注意，在实际的证明中，我们可能需要使用更复杂的推理规则和引理。这些步骤只是一个概览，将基本概念应用到实际的证明中可能需要更多的细节和技巧。希望这个示例能帮助你更好地了解 LEAN 定理证明的过程。

```lean
{{#example_out Examples/MonadTransformers/Defs.lean modifyTheType}}
```

在这里没有 `setThe` ，因为新状态的类型足以决定使用哪个周围状态的单子变换器。

在 Lean 标准库中，存在根据带有 `Of` 版本的实例定义的非 `Of` 版本的类的实例。
换句话说，实现 `Of` 版本会得到同时实现两个版本的结果。
通常情况下，先实现 `Of` 版本，然后使用非 `Of` 版本的类编写程序，并在输出参数变得不方便时过渡到 `Of` 版本是一个好主意。

## 变换器和 `Id`

Identity 单子变换器 `Id` 是一个没有任何效应的单子，用于在某些情况下期望一个单子的上下文中使用，但实际上不需要任何单子的情况。
`Id` 的另一个用途是作为单子变换器堆栈的底部。
例如，`StateT σ Id` 的工作方式与 `State σ` 完全相同。

## 练习

### 单子合约

使用纸和笔，检查此部分中的每个单子变换器是否满足单子变换器合约的规则。

### 日志变换器

定义 `WithLog` 的单子变换器版本。
并且定义相应的类型类 `MonadWithLog` ，并编写一个将日志与异常结合起来的程序。

### 文件计数

修改 `doug` 的带有 `StateT` 的单子，使其计算出所见目录和文件的数量。
在执行结束时，它应该显示一个报告，例如：

```
  Viewed 38 files in 5 directories.
```

