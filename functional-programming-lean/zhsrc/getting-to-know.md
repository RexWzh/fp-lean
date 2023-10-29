根据传统，引入一种编程语言应该通过编译和运行一个在控制台上显示 "Hello, world!" 的程序。这个简单的程序可以确保语言工具的安装正确，程序员能够运行编译后的代码。

然而，自上世纪70年代以来，编程已经发生了变化。如今，编译器通常集成在文本编辑器中，并且编程环境能够在编写程序时提供反馈。Lean也不例外：它实现了扩展版本的Language Server Protocol，使其能够与文本编辑器进行通信，并在用户输入时提供反馈。

Python、Haskell和JavaScript等各种语言都提供了一个读取-求值-打印循环（REPL），也称为交互式顶层或浏览器控制台，用户可以在其中输入表达式或语句。然后语言计算并显示用户输入的结果。而Lean则将这些功能集成到与编辑器的交互中，提供命令使得文本编辑器能够在程序文本本身中显示集成的反馈。本章简要介绍如何在编辑器中与Lean进行交互，而 [Hello, World!]() 描述了如何在传统的命令行批处理模式下使用Lean。

最好的方式是在编辑器中打开Lean，并跟随并输入每个示例。请尝试一下示例，看看会发生什么！