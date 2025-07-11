# 使用 Ubuntu 20.04 作为基础镜像
FROM ubuntu:20.04

# 设置环境变量，防止交互提示
ENV DEBIAN_FRONTEND=noninteractive

# 更新包列表并安装必要的工具
RUN apt-get update && \
    apt-get install -y curl gnupg2 ca-certificates lsb-release git

# 添加 NodeSource 的官方 PPA，并安装 Node.js 和 npm
WORKDIR /tmp
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - && apt-get install -y nodejs

# 复制所有文件到容器中
COPY . /app/

WORKDIR /app

# 更新子模块（解决 NexT 主题没有拉下来的问题）
RUN git submodule update --init --recursive

# 安装项目依赖
RUN npm install -g hexo-cli@3.1.0
RUN npm install .

# 解决 live2d-widget-model-haru 的 package.json 问题
RUN if [ -d "./node_modules/live2d-widget-model-haru" ]; then \
        cp ./node_modules/live2d-widget-model-haru/package.json ./node_modules/live2d-widget-model-haru/01/ && \
        cp ./node_modules/live2d-widget-model-haru/package.json ./node_modules/live2d-widget-model-haru/02/; \
    fi

# 解决 MathJax 下划线冲突问题
RUN npm uninstall hexo-renderer-marked --save
RUN npm install hexo-renderer-kramed --save

# 修改 kramed 配置文件解决下划线冲突
RUN cp ./fix_files/node_modules/kramed/lib/rules/inline.js ./node_modules/kramed/lib/rules/inline.js

# 配置 git（避免 spawn git ENOENT 错误）
RUN git config --global user.name "murphypei" && \
    git config --global user.email "murphypei47@gmail.com"

RUN hexo clean && hexo generate

EXPOSE 4001

# 设置默认命令为启动 hexo 服务器
CMD ["hexo", "server", "-p", "4001", "-i", "0.0.0.0"]
