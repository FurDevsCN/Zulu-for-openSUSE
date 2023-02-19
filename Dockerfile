FROM opensuse/tumbleweed:latest
LABEL Name=zulu-for-opensuse Version=0.0.1
RUN zypper ar -cfg 'https://opentuna.cn/opensuse/tumbleweed/repo/oss/' opentuna-oss
RUN zypper ar -cfg 'https://opentuna.cn/opensuse/tumbleweed/repo/non-oss/' opentuna-non-oss
RUN zypper ar -cfg 'https://opentuna.cn/opensuse/update/tumbleweed/' opentuna-update
RUN zypper ref 
CMD ["sh", "-c", "/usr/games/fortune -a | cowsay"]