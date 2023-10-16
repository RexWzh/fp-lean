# 正数

在某些应用中，只有正数才有意义。
例如，编译器和解释器通常使用从一开始的行和列号来表示源代码位置，而只表示非空列表的数据类型将永远不会报告长度为零。
与依赖于自然数，并且在代码中充斥着断言数字不为零的做法相比，设计一个仅表示正数的数据类型可能更有用。

一种表示正数的方法与 `Nat` 非常相似，只是基本情况下使用的是 `one` 而不是 `zero`：

```lean
{{#example_decl Examples/Classes.lean Pos}}
```

这种数据类型确切地表示了预期的值集，但使用起来并不方便。
例如，不允许使用数字文字：

```lean
{{#example_in Examples/Classes.lean sevenOops}}
```



```output error
{{#example_out Examples/Classes.lean sevenOops}}
```

相反，必须直接使用构造函数：

```lean
{{#example_decl Examples/Classes.lean seven}}
```

类似地，加法和乘法也不易使用：

```lean
{{#example_in Examples/Classes.lean fourteenOops}}
```



```output error
{{#example_out Examples/Classes.lean fourteenOops}}
```



```lean
{{#example_in Examples/Classes.lean fortyNineOops}}
```



```output error
{{#example_out Examples/Classes.lean fortyNineOops}}
```

每一个错误信息以 `failed to synthesize instance` 开头。
这表示错误是由于未实现的重载运算导致的，并描述了必须实现的类型类。

## 类和实例

类型类由名称、一些参数和一组 _方法_ 组成。
参数描述了正在定义重载操作的类型，方法则是重载操作的名称和类型签名。
再次，在面向对象的语言中，术语上存在一个冲突。
在面向对象编程中，方法本质上是连接到内存中特定对象的函数，具有访问对象私有状态的特殊权限。
通过它们的方法与对象交互。
在 Lean 中，“方法”一词指的是已被声明为可重载的操作，而没有与对象、值或私有字段的特殊关联。

一种重载加法的方式是定义一个名为 `Plus` 的类型类，其中包含一个名为 `plus` 的加法方法。
一旦为 `Nat` 定义了 `Plus` 的一个实例，就可以使用 `Plus.plus` 来将两个 `Nat` 相加：

```lean
{{#example_in Examples/Classes.lean plusNatFiveThree}}
```



```output info
{{#example_out Examples/Classes.lean plusNatFiveThree}}
```

添加更多的实例可以使得 `Plus.plus` 接受更多类型的参数。

在下面的类型类声明中，`Plus` 是类的名称，`α : Type` 是唯一的参数，`plus : α → α → α` 是唯一的方法：

```lean
class Plus (α : Type) :=
  (plus : α → α → α)
```

```lean
{{#example_decl Examples/Classes.lean Plus}}
```

这个声明表示有一个类型类 `Plus` ，它根据类型 `α` 重载了操作。
特别地，有一个被重载的操作叫做 `plus`，它接受两个 `α` 类型的参数并返回一个 `α` 类型的结果。

类型类是一等公民，就像类型一样也是一等公民。
特别地，类型类是另一种类型。
`{{#example_in Examples/Classes.lean PlusType}}` 的类型是 `{{#example_out Examples/Classes.lean PlusType}}`，因为它接受一个类型作为参数（`α`），并返回一个新的类型，描述了对 `α` 进行 `Plus` 操作的重载。

要为特定类型重载 `plus`，可以写一个实例：

```lean
{{#example_decl Examples/Classes.lean PlusNat}}
```

`instance` 之后的冒号表示 `Plus Nat` 确实是一个类型。
类 `Plus` 的每个方法都应该使用 `:=` 赋值一个值。
在这种情况下，只有一个方法：`plus`。

默认情况下，类型类方法在与类型类名称相同的命名空间中定义。
打开命名空间可以方便用户，因为他们不需要首先输入类名称。
`open` 命令中的括号表示只有命名空间中指定的名称可访问：

```lean
{{#example_decl Examples/Classes.lean openPlus}}

{{#example_in Examples/Classes.lean plusNatFiveThreeAgain}}
```



```output info
{{#example_out Examples/Classes.lean plusNatFiveThreeAgain}}
```

为 `Pos` 定义一个加法函数以及 `Plus Pos` 的一个实例使得 `plus` 可以用于添加 `Pos` 和 `Nat` 值：

```lean
{{#example_decl Examples/Classes.lean PlusPos}}
```

因为还没有一个 `Plus Float` 的实例，所以尝试用 `plus` 将两个浮点数相加会失败，并显示一个熟悉的错误消息：

```lean
{{#example_in Examples/Classes.lean plusFloatFail}}
```



```output error
{{#example_out Examples/Classes.lean plusFloatFail}}
```

这些错误意味着 Lean 无法找到给定类型类的实例。

## 过载的加法

Lean 内置的加法运算符是一个名为 `HAdd` 的类型类的语法糖，它灵活地允许加法的参数具有不同的类型。
`HAdd` 的全称是 _heterogeneous addition_（异类加法）。
例如，一个 `HAdd` 实例可以被写成允许将一个 `Nat` 加到一个 `Float` 上，得到一个新的 `Float`。
当程序员写下 `{{#example_eval Examples/Classes.lean plusDesugar 0}}` 时，它会被解释为意味着 `{{#example_eval Examples/Classes.lean plusDesugar 1}}`。

尽管对 `HAdd` 的完全泛化理解依赖于在[本章的另一节](out-params.md)中讨论的功能，但有一个更简单的类型类称为 `Add`，它不允许参数的类型混合。
Lean 库被设置为在搜索 `HAdd` 的实例时，如果两个参数具有相同的类型，则会找到 `Add` 的实例。

定义一个 `Add Pos` 的实例允许 `Pos` 值使用普通的加法语法：

```lean
{{#example_decl Examples/Classes.lean AddPos}}

{{#example_decl Examples/Classes.lean betterFourteen}}
```

## 转换为字符串

另一个有用的内置类被称为 `ToString`。
`ToString` 的实例提供了一种将给定类型的值转换为字符串的标准方式。
例如，当一个值出现在一个插值字符串中时，就会使用 `ToString` 实例，并且它决定了[IO 类的描述](../hello-world/running-a-program.html#running-a-program)中使用的 `IO.println` 函数如何显示一个值。

例如，将 `Pos` 转换为 `String` 的一种方式就是显示其内部结构。
函数 `posToString` 接收一个 `Bool` ，用于确定是否将 `Pos.succ` 的使用括在括号中。在函数的初始调用中，应将其设为 `true` ，在所有递归调用中设为 `false` 。

```lean
{{#example_decl Examples/Classes.lean posToStringStructure}}
```

使用这个函数来进行ToString实例的操作：

```lean
{{#example_decl Examples/Classes.lean UglyToStringPos}}
```

结果产生了丰富而又令人难以承受的输出：

```lean
{{#example_in Examples/Classes.lean sevenLong}}
```



```output info
{{#example_out Examples/Classes.lean sevenLong}}
```

另一方面，每一个正数都有一个对应的 `Nat`。将它转换为 `Nat`，然后使用 `ToString Nat` 实例（即 `Nat` 的 `toString` 的重载）是一种快速生成较短输出的方法：

```lean
{{#example_decl Examples/Classes.lean posToNat}}

{{#example_decl Examples/Classes.lean PosToStringNat}}

{{#example_in Examples/Classes.lean sevenShort}}
```



```output info
{{#example_out Examples/Classes.lean sevenShort}}
```

当定义了多个实例时，最近定义的优先。
此外，如果类型有 `ToString` 实例，那么即使该类型没有用 `deriving Repr` 定义也可以用它来显示 `#eval` 的结果，因此 `{{#example_in Examples/Classes.lean sevenEvalStr}}` 输出 `{{#example_out Examples/Classes.lean sevenEvalStr}}`。

## 重载的乘法

对于乘法，有一个叫做 `HMul` 的类型类，允许混合的参数类型，就像 `HAdd` 一样。
就像 `{{#example_eval Examples/Classes.lean plusDesugar 0}}` 被解释为 `{{#example_eval Examples/Classes.lean plusDesugar 1}}` 一样， `{{#example_eval Examples/Classes.lean timesDesugar 0}}` 被解释为 `{{#example_eval Examples/Classes.lean timesDesugar 1}}`。
对于两个相同类型的参数相乘的常见情况，`Mul` 实例就足够了。

`Mul` 的一个实例允许使用普通的乘法语法与 `Pos` 一起使用：

```lean
{{#example_decl Examples/Classes.lean PosMul}}
```

使用这个例子，乘法按预期工作：

```lean
{{#example_in Examples/Classes.lean muls}}
```



```output info
{{#example_out Examples/Classes.lean muls}}
```

## 字面数值

写出正整数的构造器序列相当麻烦。
解决这个问题的一种方法是提供一个函数将 `Nat` 转换为 `Pos`。
然而，这种方法也有其不足之处。
首先，因为 `Pos` 不能表示 `0`，所以结果函数要么将 `Nat` 转换为一个更大的数，要么返回 `Option Nat`。
对用户来说，两者都不是特别方便。
其次，需要显式调用函数会使得使用正整数的程序比使用 `Nat` 的程序要不方便得多。
在精确类型和便捷 API 之间存在权衡意味着精确类型变得不太有用。

在 Lean 中，自然数字面值是通过一个类型类 `OfNat` 进行解释的：

```lean
{{#example_decl Examples/Classes.lean OfNat}}
```

这个类型类有两个参数：`α`是一种类型，它是对自然数进行重载的类型，并且未命名的 `Nat` 参数是在程序中遇到的实际字面数值。
然后，方法 `ofNat` 用作数字字面量的值。
因为类包含 `Nat` 参数，所以只有在数字有意义的值上才能定义实例。

`OfNat` 表明类型类的参数不一定是类型。
因为在 Lean 中，类型是语言中的一类一等公民，可以作为参数传递给函数，并使用 `def` 和 `abbrev` 给它们定义，因此在不太灵活的语言中无法允许的位置使用非类型参数也没有障碍。
这种灵活性允许为特定的值以及特定的类型提供重载的操作。

例如，可以定义一个表示小于四的自然数的和类型如下所示：

```lean
{{#example_decl Examples/Classes.lean LT4}}
```

虽然允许使用_任意_的字面数字对此类型并没有意义，但小于4的数字显然是有意义的：

```lean
{{#example_decl Examples/Classes.lean LT4ofNat}}
```

根据这些实例，以下示例可以工作：

```lean
{{#example_in Examples/Classes.lean LT4three}}
```



```output info
{{#example_out Examples/Classes.lean LT4three}}
```



```lean
{{#example_in Examples/Classes.lean LT4zero}}
```



```output info
{{#example_out Examples/Classes.lean LT4zero}}
```

另一方面，仍然不允许使用超出界限的字面值：

```lean
{{#example_in Examples/Classes.lean LT4four}}
```



```output error
{{#example_out Examples/Classes.lean LT4four}}
```

对于 `Pos`，`OfNat` 的实例应当对除了 `Nat.zero` 之外的 _任何_ `Nat` 均适用。
换种说法，对于所有自然数 `n`，该实例应当对 `n + 1` 适用。
就像 `α` 这样的名称会自动成为 Lean 自动填充的函数的隐式参数一样，实例也可以接受隐式参数。
在这个实例中，参数 `n` 代表任意的 `Nat`，而实例定义的是增加了 1 的 `Nat`。

```lean
{{#example_decl Examples/Classes.lean OfNatPos}}
```

因为 `n` 代表的是用户输入的数字减去 1，辅助函数 `natPlusOne` 返回的是参数加 1 后的结果。
这样就可以使用自然数字面量表示正数，但不能表示零：

```lean
{{#example_decl Examples/Classes.lean eight}}

{{#example_in Examples/Classes.lean zeroBad}}
```



```output error
{{#example_out Examples/Classes.lean zeroBad}}
```

## 练习

### 另一种表示方法

表示一个正数的另一种方法是将其表示为某个`Nat`的后继。将`Pos`的定义替换为一个名为`succ`且包含一个`Nat`的结构体：

```lean
{{#example_decl Examples/Classes.lean AltPos}}
```

### 偶数

定义一个表示偶数的数据类型。定义 `Add`、`Mul` 和 `ToString` 的实例，使其能够方便地使用。`OfNat` 需要使用 Polymorphism 特性，这在[下一节](polymorphism.md)中会介绍到。

```haskell
data Even = Zero | AddTwo Even

instance Add Even where
    add Zero n = n
    add (AddTwo m) n = AddTwo (AddTwo (add m n))
    
instance Mul Even where
    mul Zero _ = Zero
    mul (AddTwo m) n = add n (mul m n)
    
instance ToString Even where
    toString Zero = "0"
    toString (AddTwo n) = "2 + " ++ toString n
    
instance OfNat Even where
    ofNat 0 = Zero
    ofNat n = AddTwo (ofNat (n - 2))
```

### HTTP 请求

一个 HTTP 请求需要包含一个 HTTP 方法（如 `GET` 或 `POST`）、一个 URI 和一个 HTTP 版本。定义一个表示 HTTP 方法的归纳类型，以及一个表示 HTTP 响应的结构体。HTTP 响应应该有一个 `ToString` 的实例，以便进行调试。使用类型类为每个 HTTP 方法关联不同的 `IO` 操作，并编写一个测试框架作为 `IO` 操作，调用每个方法并打印结果。

```haskell
data HttpMethod = GET | POST | PUT | DELETE

data HttpResponse = HttpResponse
    { status :: Int
    , body :: String
    }

instance ToString HttpResponse where
    toString response = "Status: " ++ show (status response) ++ ", Body: " ++ body response

class HttpMethodClass a where
    makeRequest :: a -> IO HttpResponse

instance HttpMethodClass HttpMethod where
    makeRequest GET = -- perform GET request and return the response
    makeRequest POST = -- perform POST request and return the response
    makeRequest PUT = -- perform PUT request and return the response
    makeRequest DELETE = -- perform DELETE request and return the response

testHarness :: IO ()
testHarness = do
    let requests = [GET, POST, PUT, DELETE]
    responses <- mapM makeRequest requests
    mapM_ (putStrLn . toString) responses
```
