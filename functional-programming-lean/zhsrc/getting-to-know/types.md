# 类型

类型是根据它们可以计算的值对程序进行分类的。类型在程序中有许多角色：

1. 它们允许编译器根据值在内存中的表示方式做出决策。
2. 它们帮助程序员向其他人传达他们的意图，作为函数输入和输出的轻量级规范，编译器可以确保程序符合这些规范。
3. 它们防止各种潜在的错误，比如将数字加到一个字符串上，并因此减少了测试程序所需的数量。
4. 它们帮助 Lean 编译器自动化生成可以节省模板代码的辅助代码。

Lean 的类型系统非常有表现力。
类型可以编码强大的规范，比如“这个排序函数返回其输入的排列”，也可以编码灵活的规范，比如“这个函数根据其参数的值具有不同的返回类型”。
类型系统甚至可以用作证明数学定理的完整逻辑。
然而，这种前沿的表现力并不排除对简单类型的需求，而理解这些简单类型是使用更高级特性的先决条件。

Lean中的每个程序都必须有一个类型。特别是，在表达式被计算之前必须有一个类型。迄今为止的例子中，Lean能够自己发现一个类型，但有时需要提供一个类型。这是使用冒号运算符来完成的：

```lean
#eval {{#example_in Examples/Intro.lean onePlusTwoType}}
```

这里，`Nat` 是 _自然数_ 的类型，它是任意精度的无符号整数。
在 Lean 中，`Nat` 是非负整数文字的默认类型。
这个默认类型并不总是最好的选择。
在 C 中，无符号整数在减法会产生小于零的结果时会溢出为最大可表示的数。
然而，`Nat` 可以表示任意大的无符号数，所以没有最大的数可用于溢出。
因此，在 `Nat` 上进行减法时，如果答案本来会是负数，返回的是 `0`。
例如，

```lean
#eval {{#example_in Examples/Intro.lean oneMinusTwo}}
```

计算结果为 `{{#example_out Examples/Intro.lean oneMinusTwo}}` 而不是 `-1`。要使用能够表示负整数的类型，请直接提供它：

```lean
#eval {{#example_in Examples/Intro.lean oneMinusTwoInt}}
```

使用这种类型，结果是 `{{#example_out Examples/Intro.lean oneMinusTwoInt}}` ，与预期一样。

如果想检查表达式的类型而不对其进行评估，请使用 `#check` ，而不是 `#eval` 。例如：

```lean
{{#example_in Examples/Intro.lean oneMinusTwoIntType}}
```

在执行减法操作之前，请报告 `{{#example_out Examples/Intro.lean oneMinusTwoIntType}}` 的结果。

当一个程序无法给出类型时，`#check` 和 `#eval` 都会返回错误。例如：

```lean
{{#example_in Examples/Intro.lean stringAppendList}}
```

输出

```output error
{{#example_out Examples/Intro.lean stringAppendList}}
```

因为 ``String.append`` 函数的第二个参数需要是一个字符串，而你提供了一个字符串列表。