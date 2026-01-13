## Hexo-blog

使用 Hexo 模板和 NexT 主题搭建的个人博客主页。

---

## 环境要求

* **Node.js**: v16.x（推荐使用 nvm 进行版本管理）
* **npm**: v7.x 或以上
* **Git**: 用于拉取子模块
* **macOS 特殊说明**: 本项目在 Apple Silicon（M 芯片）上已验证

---

## 快速开始

### 1. 环境配置（使用 nvm）

#### 安装 nvm

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
```

#### 配置 Node.js v16

```bash
# 安装 Node.js v16
nvm install 16

# 切换到 v16
nvm use 16

# 验证版本
node --version  # 应显示 v16.x.x
npm --version   # 应显示 v7.x 或以上
```

### 2. 初始化项目

```bash
# 克隆仓库（包含子模块）
git clone --recursive https://github.com/murphypei/hexo-blog.git
cd hexo-blog

# 或者分步操作
git clone https://github.com/murphypei/hexo-blog.git
cd hexo-blog
git submodule update --init --recursive

# 安装依赖
npm install
```

### 3. 本地测试运行

```bash
# 清理生成的文件、生成静态页面、启动本地服务器
hexo clean && hexo g && hexo s

# 访问：http://localhost:4000
```

### 4. 部署

```bash
hexo d
```

---

## Docker 部署（可选）

如果需要在 Docker 中运行，参考以下命令：

```bash
# 构建镜像
docker build -t hexo-blog .

# 运行容器
docker run -p 4000:4000 hexo-blog

# 调试模式
docker run -it -p 4000:4000 hexo-blog /bin/bash
```

---

## 常见问题排查

### 1. 生成错误

#### SyntaxError: ${project_dir}/node_modules/live2d-widget-model-haru/*/package.json

**问题描述**: live2d-widget-model-haru 包的 JSON 文件格式错误。

**解决方案**:
```bash
cp node_modules/live2d-widget-model-haru/package.json node_modules/live2d-widget-model-haru/01/
cp node_modules/live2d-widget-model-haru/package.json node_modules/live2d-widget-model-haru/02/
```

#### WARN: No layout: about/index.html

**问题描述**: NexT 主题子模块未正确拉取。

**解决方案**:
```bash
git submodule update --init --recursive
```

### 2. Node.js 版本问题

**推荐版本**: Node.js v16.x

**问题**: 使用过新或过旧的 Node.js 版本可能导致依赖安装失败。

**解决方案**:
```bash
nvm use 16
rm -rf node_modules package-lock.json
npm install
```

### 3. Git 相关错误

#### Error: spawn git ENOENT

**问题描述**: 找不到 git 命令或未配置 Git 凭证。

**解决方案**:
* 确保已安装 Git：`git --version`
* 配置 Git 用户名和邮箱：
  ```bash
  git config --global user.name "Your Name"
  git config --global user.email "your.email@example.com"
  ```

### 4. 数学公式和 Markdown 渲染问题

详见：[Hexo Render MathJax 配置指南](https://murphypei.github.io/blog/2019/03/hexo-render-mathjax.html)

---

## 项目结构

```
hexo-blog/
├── source/           # 源文件目录
│   └── _posts/       # Markdown 博客文章
├── themes/           # 主题目录
│   └── next/         # NexT 主题（子模块）
├── public/           # 生成的静态网站（hexo g 生成）
├── scaffolds/        # 模板文件
├── _config.yml       # Hexo 配置文件
├── Dockerfile        # Docker 配置文件
└── package.json      # npm 依赖配置
```

---

## 其他命令
```bash
# 生成静态文件
hexo generate (hexo g)

# 启动本地服务器
hexo server (hexo s)

# 清理生成的文件
hexo clean

# 部署到远程
hexo deploy (hexo d)

# 新建文章
hexo new post "文章标题"

# 新建页面
hexo new page "页面名称"
```

---

## 常用工具和资源

* [Hexo 官方文档](https://hexo.io/zh-cn/)
* [NexT 主题文档](https://theme-next.js.org/)
* [nvm GitHub](https://github.com/nvm-sh/nvm)

---

## 许可证

MIT