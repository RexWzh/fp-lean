# 有序的单子变换器

当从一堆单子变换器中组合一个单子时，了解单子变换器的层次顺序非常重要。
相同一组变换器的不同顺序会产生不同的单子。

这个 `countLetters` 的版本与之前的版本类似，只是它使用类型类来描述可用效果的集合，而不是提供一个具体的单子：

```lean
{{#example_decl Examples/MonadTransformers/Defs.lean countLettersClassy}}
```

状态和异常 monad 转换器可以以两种不同的顺序组合在一起，每种结果都会有同时具有类型类实例的 monad：

```haskell
newtype StateT s (ExceptT e m) a = StateExceptT { runStateExceptT :: s -> m (Either e (a, s)) }
newtype ExceptT e (StateT s m) a = ExceptStateT { runExceptStateT :: s -> m (Either e (a, s)) }
```

第一个组合的结果是 `StateT s (ExceptT e m) a`，其实例可以同时满足 `MonadState` 和 `MonadError` 类型类，在这个 monad 中，可以进行状态管理和处理异常。

第二个组合的结果是 `ExceptT e (StateT s m) a`，其实例也可以同时满足 `MonadState` 和 `MonadError` 类型类，在这个 monad 中，同样可以进行状态管理和处理异常。

```lean
{{#example_decl Examples/MonadTransformers/Defs.lean SomeMonads}}
```

当输入使得程序不抛出异常时，两种单子都产生类似的结果：

```lean
{{#example_in Examples/MonadTransformers/Defs.lean countLettersM1Ok}}
```



```output info
{{#example_out Examples/MonadTransformers/Defs.lean countLettersM1Ok}}
```



```lean
{{#example_in Examples/MonadTransformers/Defs.lean countLettersM2Ok}}
```



```output info
{{#example_out Examples/MonadTransformers/Defs.lean countLettersM2Ok}}
```

然而，这些返回值之间存在微妙的差别。
在`M1`的情况下，最外层的构造器是`Except.ok`，它包含了一个对组构造器与最终状态的组合。
而在`M2`的情况下，最外层的构造器是对组，其中包含`Except.ok`仅应用于对组构造器。
最终状态在`Except.ok`之外。
无论哪种情况，程序都返回元音和辅音的计数。

另一方面，只有一个monad在字符串引发异常时会返回元音和辅音的计数。
使用`M1`，只会返回一个异常值：

```lean
{{#example_in Examples/MonadTransformers/Defs.lean countLettersM1Error}}
```



```output info
{{#example_out Examples/MonadTransformers/Defs.lean countLettersM1Error}}
```

使用 `M2`，异常值与抛出异常时的状态配对：

```lean
{{#example_in Examples/MonadTransformers/Defs.lean countLettersM2Error}}
```



```output info
{{#example_out Examples/MonadTransformers/Defs.lean countLettersM2Error}}
```

也许会让人误以为 `M2` 优于 `M1` ，因为它提供了更多在调试时可能有用的信息。
同一个程序在 `M1` 和 `M2` 中可能会计算出 **不同** 的答案，而且没有任何理论依据来说其中一个答案必然比另一个更好。
这可以通过在程序中添加一个处理异常的步骤来观察到：

```lean
{{#example_decl Examples/MonadTransformers/Defs.lean countWithFallback}}
```

这个程序总是成功的，但可能会在不同的结果下成功。
如果没有抛出异常，则结果与 `countLetters` 相同：

```lean
{{#example_in Examples/MonadTransformers/Defs.lean countWithFallbackM1Ok}}
```



```output info
{{#example_out Examples/MonadTransformers/Defs.lean countWithFallbackM1Ok}}
```



```lean
{{#example_in Examples/MonadTransformers/Defs.lean countWithFallbackM2Ok}}
```



```output info
{{#example_out Examples/MonadTransformers/Defs.lean countWithFallbackM2Ok}}
```

然而，如果异常被抛出并捕获，最终的状态会有很大的不同。
对于 `M1`，最终状态仅包含从 `"Fallback"` 中计算得到的字母计数：

```lean
{{#example_in Examples/MonadTransformers/Defs.lean countWithFallbackM1Error}}
```



```output info
{{#example_out Examples/MonadTransformers/Defs.lean countWithFallbackM1Error}}
```

通过 `M2`，最终状态包含了来自 `"hello"` 和 `"Fallback"` 的字符计数，正如在命令式语言中所预期的那样：

```lean
{{#example_in Examples/MonadTransformers/Defs.lean countWithFallbackM2Error}}
```



```output info
{{#example_out Examples/MonadTransformers/Defs.lean countWithFallbackM2Error}}
```

在 `M1` 中，抛出异常会将状态“回滚”到捕获异常的位置。
在 `M2` 中，对状态的修改会在抛出和捕获异常之间持续存在。
通过展开 `M1` 和 `M2` 的定义，可以看到这个区别。
`{{#example_in Examples/MonadTransformers/Defs.lean M1eval}}` 展开为 `{{#example_out Examples/MonadTransformers/Defs.lean M1eval}}`，`{{#example_in Examples/MonadTransformers/Defs.lean M2eval}}` 展开为 `{{#example_out Examples/MonadTransformers/Defs.lean M2eval}}`。
也就是说，`M1 α` 描述了接受初始字母计数的函数，返回错误或一个与更新的计数关联的 `α`。
当在 `M1` 中抛出异常时，没有最终状态。
`M2 α` 描述了接受初始字母计数的函数，并返回新的字母计数与错误或 `α` 关联。
当在 `M2` 中抛出异常时，它会伴随一个状态。

## 交换的 Monad

在函数式编程的术语中，如果两个单子变换可以重新排序而不改变程序的含义，则称它们_交换_。
当 `StateT` 和 `ExceptT` 重新排序时，程序的结果可能不同，这意味着状态和异常不能交换。
通常情况下，不应该期望单子变换会交换。

尽管并非所有单子变换都可以交换，但有些可以。
例如，可以重新排序两个 `StateT` 的使用。
展开 `{{#example_in Examples/MonadTransformers/Defs.lean StateTDoubleA}}` 的定义，得到类型 `{{#example_out Examples/MonadTransformers/Defs.lean StateTDoubleA}}`，展开 `{{#example_in Examples/MonadTransformers/Defs.lean StateTDoubleB}}` 的定义，得到 `{{#example_out Examples/MonadTransformers/Defs.lean StateTDoubleB}}`。
换句话说，它们之间的区别仅在于返回类型中 `σ` 和 `σ'` 类型的嵌套位置不同，并且它们以不同的顺序接受参数。
任何客户代码仍然需要提供相同的输入，并且将接收相同的输出。
大多数既具有可变状态又具有异常处理功能的编程语言都类似于 `M2`。
在这些语言中，当抛出异常时应该回滚的状态很难表达，通常需要以类似于 `M1` 中显式传递状态值的方式进行模拟。
Monad 变换器赋予了选择适用于当前问题的效果顺序解释的自由，这两种选择编程都同样简单。
然而，在选择变换器的顺序时，也需要谨慎。
强大的表达能力要求我们检查所要表达的内容是否符合意图，而 `countWithFallback` 的类型签名可能比应该更多态。


## 练习

* 通过扩展它们的定义并推理结果类型，验证`ReaderT`和`StateT`是否满足交换律。
* `ReaderT`和`ExceptT`是否满足交换律？通过扩展它们的定义并推理结果类型来验证你的答案。
* 根据`Many`的定义构建一个基于`Many`的monad变换器`ManyT`，并提供一个合适的`Alternative`实例。验证它是否满足`Monad`的约定。
* `ManyT`和`StateT`是否满足交换律？如果是，请通过扩展定义并推理结果类型来验证你的答案。如果不是，请编写一个`ManyT (StateT σ Id)`和一个`StateT σ (ManyT Id)`的程序，每个程序应针对给定的monad变换器顺序做更多的意义。