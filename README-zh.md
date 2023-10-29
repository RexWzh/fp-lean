# Lean 中的函数式编程
这个仓库包含 David Thrane Christiansen 编写的《Lean 函数式编程》书的源代码。

所有内容版权归 Microsoft Corporation 所有。作为 Microsoft 的开源发布，该项目受到 Microsoft 开源行为准则的约束，详情见 https://opensource.microsoft.com/codeofconduct/ 。该项目可能包含项目、产品或服务的商标或徽标。使用 Microsoft 商标或徽标必须遵守 Microsoft 的商标和品牌指南。对于此项目修改版本中的 Microsoft 商标或标志的使用不得引起混淆或暗示 Microsoft 赞助。任何第三方商标或徽标的使用都应符合那些第三方的政策。

该书的构建已经通过以下测试：

1. Lean 4 (请参阅 examples/ 中的 lean-toolchain 版本)
2. mdbook 版本 0.4.17
3. Python 3.10.4
4. expect（测试过 v5.45.4，但过去十年的任何版本都应该可以工作）

要检查代码示例，请转到 "examples" 目录并运行 "lake build"。

要构建书籍，请转到 "functional-programming-lean" 目录并运行 "mdbook build"。之后，"book/html/index.html" 包含一个多页面网页版的书籍。

仓库的结构如下：
* `examples/` 包含书中使用的示例代码，以及用 Lean 编写的支持代码。
* `functional-programming-lean/` 包含书籍文本的源代码。分为两部分：
  * `scripts/` 包含用于实现与 mdbook 一起使用的自定义预处理器的 Python 脚本，用于包含代码样本
  * `src/` 包含 Markdown 源

为了在定义程序之前运行它们，包括由书籍的 CI 检查的错误消息，并允许同一定义的多个版本，模块 Examples.Support 包含了许多元程序。这些元程序与故意冗长的语法关联，该语法很容易使用正则表达式从示例文件中提取。每个示例都有一个名字，并且书籍的文本含有对这些名字的引用，这是对 Markdown 的自定义语法扩展。书籍的预处理器提取这些示例，在生成 HTML 之前将它们插入到文本中。

需要编译和运行的示例使用不同的系统包含。文件 `projects.py` 实现了预处理器，用于基于 `examples/` 的某个子目录设置新的临时目录，然后在这些临时目录中运行一系列命令，将输出与一些预期字符串进行比较。这确保了对 Lean 的更改会在书籍的 CI 中捕获，影响程序的运行行为，并能尽早捕获编辑过程中引入的错误。很多需要编译的代码使用 mdbook 的内置支持来包含文件的部分，因为它非常适合此目的。


# 文档部署方法

```bash
export LEAN_REMOTE_FP_LEAN="<git repo url>"
bash deploy.sh
```

其中 `<git repo url>` 为部署的远程仓库地址，默认部署到 `gh-pages` 分支。

也可以用 Git 钩子部署到个人服务器，比如在服务器创建裸仓库：

```bash
cd /var
mkdir -p repo repo/fp-lean
cd repo/fp-lean
git init --bare
touch hooks/post-receive
chmod +x hooks/post-receive
```

然后在 `hooks/post-receive` 中写入

```bash
#!/bin/bash

export GIT_WORK_TREE=/var/www/fp-lean
export GIT_DIR=.
git checkout -f gh-pages
```

其中 `/var/www/fp-lean` 为网页部署的位置。