# 函子，可应用函子和单子

`Functor` 和 `Monad` 都描述了等待类型参数的类型的操作。对它们的一种理解方式是，`Functor` 描述了可以对其中包含的数据进行转换的容器，而 `Monad` 描述了具有副作用的程序的编码。然而，这种理解是不完整的。毕竟，`Option` 同时为 `Functor` 和 `Monad` 提供实例，并同时表示可选值和可能无法返回值的计算。

从数据结构的角度来看，`Option` 有点像可空类型或只能包含最多一个条目的列表。从控制结构的角度来看，`Option` 表示可能在没有结果的情况下提前终止的计算。通常，使用 `Functor` 实例的程序最容易将 `Option` 视为数据结构，而使用 `Monad` 实例的程序最容易将 `Option` 视为允许提前失败的计算，但流利地使用这两种观点是成为熟练的函数式编程者的重要组成部分。

函子和单子之间有一个更深层次的关系。事实证明，_每个单子都是函子_。另一种说法是，单子抽象比函子抽象更强大，因为并非每个函子都是单子。此外，还有一种名为 _可应用函子_ 的附加中间抽象，它具有足够的能力来编写许多有趣的程序，但允许无法使用 `Monad` 接口的库。类型类 `Applicative` 提供了可应用函子的可重载操作。每个单子都是可应用函子，每个可应用函子都是函子，但反之则不成立。