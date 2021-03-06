---
title: Socket 读写就绪条件
date: 2019-08-27 15:07:38
update: 2019-08-27 15:07:38
categories: Linux
tags: [Linux, socket, read, write, unix]
---

关于 Socket 的读写就绪条件。

<!-- more -->

我们知道 Socket 读写都是有缓冲区，而且读写时阻塞的，因此通常用 I/O 多路复用来监听多个 Socket 的就绪。这个就绪是十分有意思的，内核是如何得知某个 Socket 就绪了呢？引用《Unix网络编程》中的解释：

当满足下列条件之一时，一个套接字准备好读：

- 该套接字接收缓冲区中的数据字节数大于等于套接字接收缓冲区低水位标记的当前大小。对这样的套接字执行读操作不会阻塞并将返回一个大于 0 的值（也就是返回准备好读入的数据）。我们可以使用 `SO_RCVLOWAT` 套接字选项设置该套接字的低水位标记。对于 TCP 和 UDP 套接字而言，其默认值为 1。
- 该连接的读半部关闭（也就是接收了 FIN 的 TCP 连接）。对这样的套接字的读操作将不阻塞并返回 0 （也就是返回 EOF）。
- 该套接字是一个监听套接字且已完成的连接数不为 0。对这样的套接字的 accept 通常不会阻塞。
- 其上有一个套接字错误待处理。对这样的套接字的读操作将不阻塞并返回 -1（也就是返回一个错误），同时把 `errno` 设置成确切的错误条件。这些待处理错误也可以通过指定 `SO_ERROR` 套接字选项调用 `getsockopt` 获取并清除。

当满足下列条件之一时，一个套接字准备好写：

- 该套接字发送缓冲区中的可用空间字节数大于等于套接字发送缓冲区低水位标记的当前大小，并且要求该套接字已连接（TCP）或者不需要连接（UDP）。这意味着如果我们把这样的套接字设置为非阻塞，写操作将不阻塞并返回一个正值（例如由传输层接收的字节数）。我们可以使用 `SO_SNDLOWAT` 套接字选项来设置该套接字的低水位标记。对于 TCP 和 UDP 套接字而言，其默认值通常为 2048。
- 该连接的写半部关闭，对这样的套接字的写操作将产生 `SIGPIPE` 信号。
- 使用非阻塞式 `connect` 的套接字已建立连接，或者已经以失败告终。
- 其上有一个套接字错误待处理。对这样的套接字的写操作将不阻塞并返回 -1（也就是返回一个错误），同时把 `errno` 设置成确切的错误条件。这些待处理的错误也可以通过指定 `SO_ERROR` 套接字选项调用 `getsockopt` 获取并清除。

另外，如果一个套接字存在带外数据或者仍处于带外标记，那么它有异常条件待处理。从上面可以看出，如果一个套接字发生错误，那么它是可读可写条件。

可以看出，读写就绪条件一般情况（非异常）都是内核通过判断缓冲区中是否有数据。因为网络上数据的到来是随时的，因此当缓冲区中有网络的数据（大于 1），说明可读。而写数据则将数据积攒起来，大于低水位或者发送方主动关闭了连接，才会通过网络发送出去。

除了上述条件，缓冲区的读写在满和空的时候也会引起阻塞，下面以管理为例说明。

假设有一个管道，进程 A 为管道的写入方，B 为管道的读出方。

假设一开始内核缓冲区是空的，B 作为读出方，被阻塞着。然后首先 A 往管道写入，这时候内核缓冲区由空的状态变到非空状态，内核就会产生一个事件告诉 B 该醒来了（也就是我们上面说的套接字准备好读），这个事件姑且称之为“缓冲区非空”。

但是“缓冲区非空”事件通知 B 后，B 却还没有读出数据；且内核许诺了不能把写入管道中的数据丢掉这个时候，A 写入的数据会滞留在内核缓冲区中，如果内核也缓冲区满了，B 仍未开始读数据，最终内核缓冲区会被填满，这个时候会产生一个 I/O 事件，告诉进程 A，你该等等（阻塞）了，我们把这个事件定义为“缓冲区满”。可见，缓冲区满也会引起阻塞。

假设后来 B 终于开始读数据了，于是内核的缓冲区空了出来，这时候内核会告诉 A，内核缓冲区有空位了，你可以从长眠中醒来了，继续写数据了，我们把这个事件叫做“缓冲区非满”。也许事件 Y1 已经通知了 A，但是 A 也没有数据写入了，而 B 继续读出数据，知道内核缓冲区空了。这个时候内核就告诉 B，你需要阻塞了！我们把这个时间定为“缓冲区空”。因此，缓冲区空也会引起阻塞。

以上四个情形涵盖了四个 I/O 事件，缓冲区满，缓冲区空，缓冲区非空，缓冲区非满（说的内核缓冲区）。这四个 I/O 事件是进行阻塞同步的根本。
