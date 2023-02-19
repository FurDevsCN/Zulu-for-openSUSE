FROM opensuse/tumbleweed:latest
LABEL Name=zulu-for-opensuse
LABEL Version=0.0.1
LABEL org.opencontainers.image.authors="x123456789fy@outlook.com"
RUN zypper --quiet rr -a
RUN zypper --quiet ar -cfg 'https://opentuna.cn/opensuse/tumbleweed/repo/oss/' opentuna-oss
RUN zypper --quiet ar -cfg 'https://opentuna.cn/opensuse/tumbleweed/repo/non-oss/' opentuna-non-oss
RUN zypper --quiet ar -cfg 'https://opentuna.cn/opensuse/update/tumbleweed/' opentuna-update
RUN zypper --quiet --non-interactive ref 
RUN zypper --quiet --non-interactive in jq curl aria2
RUN aria2c -x8 --dir /tmp/ `curl -sX GET "https://api.azul.com/metadata/v1/zulu/packages/?java_version=8&os=linux&arch=x64&archive_type=rpm&java_package_type=jre&support_term=lts&latest=true&availability_types=CA&certifications=tck&page=1&page_size=100" -H "accept: application/json" | jq '.[] | .download_url'`
RUN aria2c -x8 --dir /tmp/ `curl -sX GET "https://api.azul.com/metadata/v1/zulu/packages/?java_version=11&os=linux&arch=x64&archive_type=rpm&java_package_type=jre&support_term=lts&latest=true&availability_types=CA&certifications=tck&page=1&page_size=100" -H "accept: application/json" | jq '.[] | .download_url'`
RUN aria2c -x8 --dir /tmp/ `curl -sX GET "https://api.azul.com/metadata/v1/zulu/packages/?java_version=17&os=linux&arch=x64&archive_type=rpm&java_package_type=jre&support_term=lts&latest=true&availability_types=CA&certifications=tck&page=1&page_size=100&javafx_bundled=true" -H "accept: application/json" | jq '.[] | .download_url'`
RUN zypper --quiet --non-interactive in /tmp/'*.rpm'
RUN rm /tmp/*.rpm
RUN zypper --quiet --non-interactive rm curl jq
RUN zypper --quiet patch
RUN zypper --quiet ve
RUN ln -s /usr/lib/zre-8/bin/java /usr/bin/java8
RUN ln -s /usr/lib/zre-11/bin/java /usr/bin/java11
RUN ln -s /usr/lib/zre-17/bin/java /usr/bin/java7
RUN mkdir /mnt/data
RUN mkdir /mnt/program