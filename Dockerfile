# 使用opensuse/tumbleweed:latest作为基础镜像
FROM opensuse/tumbleweed:latest
# 设置镜像的元数据，包括名称、版本和作者
LABEL Name=zulu-for-opensuse
LABEL Version=0.0.2
LABEL org.opencontainers.image.authors="x123456789fy@outlook.com"
# 设置默认的shell为/bin/bash，并使用-c选项执行命令
SHELL [ "/bin/bash" , "-c"]
# 设置工作目录为/tmp
WORKDIR /tmp
# 移除所有已有的软件源
RUN zypper rr -a
# 添加opentuna.cn提供的软件源，分别为oss（开源软件）、non-oss（非开源软件）和update（更新）
RUN zypper ar -cfg 'https://opentuna.cn/opensuse/tumbleweed/repo/oss/' opentuna-oss
RUN zypper ar -cfg 'https://opentuna.cn/opensuse/tumbleweed/repo/non-oss/' opentuna-non-oss
RUN zypper ar -cfg 'https://opentuna.cn/opensuse/update/tumbleweed/' opentuna-update
# 刷新软件源缓存
RUN zypper --non-interactive ref 
# 安装jq、curl和wget工具，用于处理json数据和下载文件
RUN zypper --non-interactive in jq curl wget
# 安装附加工具
RUN zypper --non-interactive in gzip bzip2 coreutils findutils
# 使用curl访问azul.com提供的api接口，获取zulu jre 8版本的rpm下载链接，并使用jq解析json数据，然后使用wget下载文件到本地。sed命令用于去除双引号。
RUN wget `curl -sX GET "https://api.azul.com/metadata/v1/zulu/packages/?java_version=8&os=linux&arch=x64&archive_type=rpm&java_package_type=jre&support_term=lts&latest=true&availability_types=CA&certifications=tck&page=1&page_size=100" -H "accept: application/json" | jq '.[] | .download_url' |sed 's/\"//g'`
# 同上，获取zulu jre 11版本的rpm下载链接，并下载文件到本地。
RUN wget `curl -sX GET "https://api.azul.com/metadata/v1/zulu/packages/?java_version=11&os=linux&arch=x64&archive_type=rpm&java_package_type=jre&support_term=lts&latest=true&availability_types=CA&certifications=tck&page=1&page_size=100" -H "accept: application/json" | jq '.[] | .download_url' |sed 's/\"//g'`
# 同上，获取zulu jre 17版本的rpm下载链接，并下载文件到本地。注意这里多了一个javafx_bundled=true参数，表示jre中包含了javafx组件。
RUN wget `curl -sX GET "https://api.azul.com/metadata/v1/zulu/packages/?java_version=17&os=linux&arch=x64&archive_type=rpm&java_package_type=jre&support_term=lts&latest=true&availability_types=CA&certifications=tck&page=1&page_size=100 &javafx_bundled=true" -H "accept: application/json" | jq '.[] | .download_url' |sed 's/\"//g'`
# 使用zypper安装本地目录下所有以.rpm结尾的文件，并忽略gpg签名检查。
RUN zypper --no-gpg-checks --non-interactive in *.rpm
# 删除本地目录下所有以.rpm结尾的文件。
RUN rm *.rpm
# 卸载之前安装的jq、curl和wget工具。
RUN zypper --non-interactive rm jq curl wget 
# 应用系统更新补丁。
RUN zypper patch
# 验证系统完整性。
RUN zypper ve
# 为每个版本的java创建一个软链接，方便使用。
RUN ln -s /usr/lib/zre-8/bin/java /usr/bin/java8
RUN ln -s /usr/lib/zre-11/bin/java /usr/bin/java11
RUN ln -s /usr/lib/zre-17/bin/java /usr/bin/java7
# 创建两个目录，分别用于存放数据和程序。
RUN mkdir /mnt/data
RUN mkdir /mnt/program