[README.md](https://github.com/user-attachments/files/28293985/README.md)
# DOS 16-bit 4-in-1 Game Collection

<div align="center">

![Assembly](https://img.shields.io/badge/Assembly-x86%2016--bit-FF6600?style=for-the-badge&logo=gnu)
![MASM](https://img.shields.io/badge/MASM-Microsoft%20Macro%20Assembler-0078D4?style=for-the-badge)
![DOS](https://img.shields.io/badge/Platform-DOS%2FDOSBox-000000?style=for-the-badge)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge)](LICENSE)

**一个基于 x86 16位汇编语言的经典DOS游戏合集**

</div>

---

## 项目概述

这是一个用 **MASM/TASM 汇编语言** 编写的纯DOS游戏合集，包含四个经典小游戏。所有游戏都直接运行在x86实模式架构上，展示了底层系统编程的强大能力。

### 游戏列表

| # | 游戏名称 | 英文名 | 核心机制 |
|---|---------|--------|---------|
| 1 | 🃏 记忆翻牌 | Memory Match | 翻牌配对记忆游戏 |
| 2 | 🐍 贪吃蛇 | Snake | 经典贪吃蛇游戏 |
| 3 | ⌨️ 打字测试 | Typing Speed Test | 打字速度与准确率测试 |
| 4 | 🏰 迷宫探索 | Maze | 键盘控制迷宫逃生 |

---

## 技术亮点

### 🔧 系统级编程技术

```asm
; 键盘中断处理 - 使用BIOS中断向量表
INT 16h          ; BIOS键盘服务
INT 09h          ; 硬件键盘中断（贪吃蛇使用）

; 定时器与随机数
INT 1Ah          ; BIOS时钟服务（打字测试计时）
RDTSC            ; 随机数生成（翻牌游戏洗牌算法）

; 显示输出
INT 10h          ; BIOS显示服务
直接写屏 (B800h)  ; 贪吃蛇游戏高速渲染
```

### 📊 数据结构设计

| 模块 | 数据结构 | 说明 |
|------|----------|------|
| 贪吃蛇 | 链表结构 | 环形链表管理蛇身节点 |
| 记忆翻牌 | 状态机 | 3态卡片系统（隐藏/翻开/配对） |
| 迷宫 | 2D数组 | 10x10字符地图 |
| 打字测试 | 字符池 | 36字符随机选择算法 |

### 🎮 高级游戏特性

- **贪吃蛇**：键盘中断HOOK、方向防反转、双缓冲渲染
- **记忆翻牌**：Fisher-Yates洗牌算法、状态机流程控制
- **打字测试**：精确计时系统、实时统计计算
- **迷宫游戏**：碰撞检测、路径寻优

---

## 编译与运行

### 环境要求

- MASM 6.15+ 或 TASM 5.0+
- DOSBox 模拟器 或 真实DOS环境
- 键盘输入设备

### 编译步骤

```bash
# 使用 MASM
masm 4in1_game.asm;
link 4in1_game.obj;
4in1_game.exe

# 或使用 TASM + TLINK
tasm 4in1_game.asm
tlink 4in1_game.obj
```

### 运行

```bash
# 在DOSBox中运行
mount C D:\dosbox_work
C:
4in1_game.exe
```

---

## 代码架构

```
CODE SEGMENT
├── 主程序入口 (START)
│   ├── 主菜单系统
│   └── 游戏选择逻辑
│
├── 游戏1: 记忆翻牌 (RC_*)
│   ├── RC_INIT_RANDOM      - 随机数初始化
│   ├── RC_SHUFFLE_CARDS    - Fisher-Yates洗牌
│   ├── RC_DRAW_GRID        - 游戏界面渲染
│   └── RC_GET_INPUT        - 输入处理
│
├── 游戏2: 贪吃蛇 (SN_*)
│   ├── SN_new_int9         - 键盘中断HOOK
│   ├── SN_isMove*          - 移动方向处理
│   ├── SN_draw_new_snake   - 蛇身更新
│   └── SN_eat_food         - 食物碰撞检测
│
├── 游戏3: 打字测试 (TY_*)
│   ├── TY_GET_RANDOM_CHAR  - 字符生成
│   ├── TY_PRINT_NUM        - 数字显示
│   └── 计时统计系统
│
└── 游戏4: 迷宫 (Maze_*)
    ├── draw_maze           - 地图渲染
    ├── check_wall          - 碰撞检测
    └── 键盘WASD控制
```

---

## 中断与系统调用

| 中断号 | 功能 | 用途 |
|--------|------|------|
| INT 10h | 显示服务 | 屏幕清空、光标定位、字符输出 |
| INT 16h | 键盘服务 | 按键读取（主菜单/翻牌/迷宫） |
| INT 09h | 键盘中断 | 贪吃蛇方向控制（HOOK） |
| INT 1Ah | 时钟服务 | 计时、随机数种子 |
| INT 21h | DOS服务 | 字符串显示、程序退出 |

---

## 寄存器使用规范

```
┌─────────────────────────────────────────────────────────┐
│                    寄存器约定                            │
├──────────────┬──────────────────────────────────────────┤
│ AX/CX/DX     │ 通用数据寄存器，函数返回值                │
│ BX           │ 基址寄存器，内存寻址                       │
│ SI/DI        │ 源/目标索引，用于字符串操作               │
│ SP/BP        │ 栈指针，用于函数调用和局部变量            │
│ CS/DS/SS     │ 段寄存器，代码/数据/栈段                 │
└──────────────┴──────────────────────────────────────────┘
```

---

## 性能特性

| 游戏 | 帧率 | 渲染方式 | 代码量 |
|------|------|----------|--------|
| 贪吃蛇 | 实时 | 直接写屏B800h | ~200行 |
| 记忆翻牌 | 事件驱动 | BIOS中断 | ~150行 |
| 打字测试 | 等待输入 | BIOS中断 | ~80行 |
| 迷宫 | 事件驱动 | DOS输出 | ~100行 |

---

## 学习资源

- [Intel 8086/8088指令集参考](https://faydoc.tripod.com/cpu/index.htm)
- [MASM编程指南](https://docs.microsoft.com/en-us/cpp/assembler/masm/microsoft-macro-assembler-reference)
- [DOSBox模拟器](https://www.dosbox.com/)

---

## 扩展方向

- [ ] 添加更多游戏（俄罗斯方块、打砖块）
- [ ] 音效系统（PC Speaker编程）
- [ ] 存档功能
- [ ] 图形界面（VGA 13h模式）
- [ ] 多玩家支持

---

## 关于作者

**技术栈**: x86 Assembly | DOS Programming | System Programming

**项目环境**: MASM 6.15 | DOSBox | Windows

---

## License

MIT License - 欢迎学习和交流

---

<div align="center">

**Made with pure x86 Assembly 💾**

</div>
