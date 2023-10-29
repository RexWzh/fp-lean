# 重载和类型类

许多语言中，内置数据类型受到特殊对待。
例如，在 C 和 Java 中，`+` 可以用于将 `float` 和 `int` 相加，但不能用于第三方库的任意精度数字。
类似地，数字字面量可以直接用于内置类型，但不能用于自定义数字类型。
其他语言提供了一种 _重载_ 机制，用于给操作符赋予新类型的含义。
在这些语言中，比如 C++ 和 C#，可以重载各种内置操作符，并且编译器使用类型检查器来选择特定的实现。

除了数字字面量和操作符，许多语言还允许函数或方法的重载。
在 C++、Java、C# 和 Kotlin 中，允许有多个方法的实现，参数的数量和类型可以不同。
编译器使用参数的数量和类型来确定所需的重载。

函数和操作符的重载有一个关键限制：多态函数不能限制其类型参数仅适用于存在给定重载的类型。
也就是说，无法编写一个适用于任何具有加法定义的类型的函数。
相反，必须针对具有加法的每个类型进行重载，这导致了许多样板定义，而不是单个多态定义。
由于此限制，一些操作符（例如 Java 中的等号）最终被定义为 _所有_ 参数组合的操作符，即使在某些情况下并不一定合理。
如果程序员不够小心，这可能导致在运行时崩溃或无声地计算出错误的结果。

Lean 使用一种称为 _类型类_ 的机制来实现重载，这种机制在 Haskell 中得到了先驱，它可以很好地与多态一起使用，允许以合理的方式对操作符、函数和字面量进行重载。
类型类描述了一组可重载的操作。
要为新类型重载这些操作，需要创建一个包含每个操作在新类型上实现的 _实例_ 。
例如，一个名为 `Add` 的类型类描述了允许加法的类型，而 `Nat` 的 `Add` 实例则提供了 `Nat` 上加法的实现。

对于习惯于面向对象语言的人来说，术语 _类_ 和 _实例_ 可能会让人感到困惑，因为它们与面向对象语言中的类和实例并没有密切关联。
然而，它们确实有共同的起源：在日常语言中，“类”一词是指一组共享某些共同属性的群体。
在面向对象编程中，类确实描述了具有共同属性的对象组。此外，这个术语还指的是一种编程语言中描述这样一个组的特定机制。
类型类也是一种描述具有共同属性的类型的方法（即实现某些操作），但它们与面向对象编程中的类并没有其他共同点。

在 Lean 中，类型类更类似于 Java 或 C# 中的 _接口_。
类型类和接口都描述了为类型或一组类型实现的一组概念上相关的操作。
类似地，类型类的实例类似于由实现的接口规定的 Java 或 C# 类中的代码，而不是 Java 或 C# 类的实例。
与 Java 或 C# 的接口不同，给定类型可以为类型类提供实例，而类型的作者无法访问这些类型类。
在这方面，它们与 Rust 的特性非常相似。