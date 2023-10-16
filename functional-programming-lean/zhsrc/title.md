# Lean中的函数式编程

*作者：David Thrane Christiansen*

*版权所有：Microsoft Corporation 2023*



本书介绍如何使用Lean 4作为编程语言。所有代码示例均使用Lean 4版本 `{{#lean_version}}` 进行测试。

## 发行历史

### 2023年5月

本书已经完成！相比于四月的预发布版，对许多细节进行了改进，并修正了一些小错误。

### 2023年4月

此版本增加了一个关于使用策略进行证明的插曲，以及一个最后的章节，该章节将性能和成本模型的讨论与终止性和程序等价性的证明相结合。
这是最终版本之前的最后一个版本。

### 2023年3月

此版本增加了一个关于编程与依赖类型和索引族的章节。

### 2023年1月

此版本增加了一个关于包含了`do`-notation可用的命令式特性的monad transformer章节。

### 2022年12月

此版本增加了一个关于applicative functors的章节，此外还更详细地描述了结构和类型类。
同时对monads的描述进行了改进。
由于冬假的原因，2022年12月的发布推迟到了2023年1月。

### 2022年11月
此版本增加了一个关于使用monads进行编程的章节。此外，更新了在转换部分使用JSON的示例以包括完整的代码。

### 2022年10月

此版本完成了关于类型类的章节。此外，在类型类章节之前增加了一个简短的插曲，介绍了命题、证明和策略，因为对这些概念有一定的了解有助于理解标准库的一些类型类。

### 2022年9月

此版本增加了类型类章节的上半部分，类型类是Lean中重载运算符的机制，也是组织代码和构建库的重要手段。此外，第二章已经更新，以适应Lean流API的变化。

### 2022年8月

这个第三个公开发布版增加了第二章，描述了编译和运行程序的过程以及Lean处理副作用的模型。

### 2022年7月

第二次公开发布完成了第一章。

### 2022年6月

这是第一个公开发布版，包括了一个介绍和第一章的一部分。

## 关于作者

David Thrane Christiansen使用函数式语言已有二十年的经验，并且使用依赖类型已有十年之久。
他与 Daniel P. Friedman 合著了《[The Little Typer](https://thelittletyper.com/)》一书，介绍了依赖类型理论的关键思想。
他拥有哥本哈根IT大学的博士学位。
在攻读博士期间，他是 Idris 语言的首个版本的重要贡献者。
离开学术界后，他曾在美国俄勒冈州波特兰的Galois公司和丹麦哥本哈根的Deon Digital公司工作。
目前，他担任Haskell Foundation的执行董事。

## 许可证

<a rel="license" href="http://creativecommons.org/licenses/by/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by/4.0/88x31.png" /></a><br />本作品采用 <a rel="license" href="http://creativecommons.org/licenses/by/4.0/">知识共享署名 4.0 国际许可协议</a> 进行许可。