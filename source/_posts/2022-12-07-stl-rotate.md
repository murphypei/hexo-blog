---
title: STL 旋转序列算法 rotate
date: 2022-12-07 11:35:51
update: 2022-12-07 11:35:51
categories: C/C++
tags: [C++, stl, rotate, STL]
---

最近开发需要不管刷新缓冲区，发现了一个有用的 STL 算法。

<!-- more -->

先说明应用场景：我有一块缓冲区 vector，不断接收数据和消费数据（生产消费模型），接收数据就放在末尾，消费头部数据，消费完删除。之前用 realloc 和 memmove 来操作，改为 vector 之后如果每次搬移数据就很麻烦了，查了一下发现 [rotate](https://en.cppreference.com/w/cpp/algorithm/rotate) 配合 resize 可以搞定。

std::rotate() 的第一个参数是这个序列的开始迭代器；第二个参数是指向新的第一个元素的迭代器，**它必定在序列之内**。第三个参数是这个序列的结束迭代器。意思是将第二个参数的元素旋转到第一个参数的位置，旋转的序列是第一个参数到第三个参数的范围。

你可以想象第一个参数 ~ 第三个参数之间的元素序列组成一个圆盘，左转就是逆时针旋转，直到第二个参数转到第一个参数的位置，旋转结束。

可以参数[图解](http://c.biancheng.net/view/609.html)

旋转完成后，头部就变到 vector 末尾了，用 resize 可以标记删除掉这些元素。