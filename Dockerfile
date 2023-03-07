# 使用opensuse/tumbleweed:latest作为基础镜像。
FROM opensuse/tumbleweed:latest
# 设置镜像的元数据，包括名称、版本和作者。
LABEL Name=zulu-for-opensuse
LABEL Version=0.0.2
LABEL org.opencontainers.image.authors="x123456789fy@outlook.com"
# 设置默认的shell为/bin/bash，并使用-c选项执行命令。
SHELL [ "/bin/bash" , "-c"]
# 设置工作目录为/tmp。
WORKDIR /tmp
# 移除所有已有的软件源。
RUN zypper rr -a
# 添加 opentuna.cn 提供的软件源，分别为 oss（开源软件）、non-oss（非开源软件）和 update（更新）。
RUN zypper ar -cfg 'https://opentuna.cn/opensuse/tumbleweed/repo/oss/' opentuna-oss
RUN zypper ar -cfg 'https://opentuna.cn/opensuse/tumbleweed/repo/non-oss/' opentuna-non-oss
RUN zypper ar -cfg 'https://opentuna.cn/opensuse/update/tumbleweed/' opentuna-update
# 导入zulu的公钥。
RUN rpm --import https://www.azul.com/wp-content/uploads/2021/05/0xB1998361219BD9C9.txt
# 刷新软件源缓存。
RUN zypper --non-interactive ref
# 安装 jq、curl 和 wget 工具，用于处理 json 数据和下载文件，安装原镜像裁剪掉的 zypper online rpm 解析。
RUN zypper --non-interactive in jq curl wget gzip bzip2 coreutils findutils
# 使用curl访问azul.com提供的api接口，获取zulu jre 8版本的 rpm 下载链接，并使用 jq 解析 json 数据，然后下载；sed 命令用于去除双引号。
RUN wget `curl -sX GET "https://api.azul.com/metadata/v1/zulu/packages/?java_version=8&os=linux&arch=amd64&archive_type=rpm&java_package_type=jre&support_term=lts&latest=true&availability_types=CA&include_fields=&page=1&page_size=2" | jq '.[] | .download_url' |sed 's/\"//g'`
# 同上，获取zulu jre 11版本的rpm下载链接，并下载。
RUN wget `curl -sX GET "https://api.azul.com/metadata/v1/zulu/packages/?java_version=11&os=linux&arch=amd64&archive_type=rpm&java_package_type=jre&support_term=lts&latest=true&availability_types=CA&include_fields=&page=1&page_size=2" -H "accept: application/json" | jq '.[] | .download_url' |sed 's/\"//g'`
# 同上，获取zulu jre 17版本的rpm下载链接，并下载。注意这里多了一个javafx_bundled=true参数，表示jre中包含了javafx组件。
RUN wget `curl -sX GET "https://api.azul.com/metadata/v1/zulu/packages/?java_version=17&os=linux&arch=amd64&archive_type=rpm&java_package_type=jre&javafx_bundled=true&support_term=lts&latest=true&distro_version=17&java_package_features=headfull&release_status=ga&availability_types=CA&include_fields=&page=1&page_size=2" -H "accept: application/json" | jq '.[] | .download_url' |sed 's/\"//g'`
# 安装所有下载的rpm，卸载之前安装的工具。
RUN zypper --non-interactive in *.rpm -jq -curl -wget -gzip -bzip2 -coreutils -findutils
# 应用系统更新补丁。
RUN zypper patch
# 验证系统完整性。
RUN zypper ve
# 为每个版本的java创建一个软链接，方便使用。
RUN ln -s /usr/lib/zre-8/bin/java /usr/bin/java8
RUN ln -s /usr/lib/zre-11/bin/java /usr/bin/java11
RUN ln -s /usr/lib/zre-17/bin/java /usr/bin/java17
# 创建两个目录，分别用于存放数据和程序。
RUN mkdir /mnt/data
RUN mkdir /mnt/program
