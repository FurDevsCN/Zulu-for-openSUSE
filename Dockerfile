FROM opensuse/tumbleweed:latest
LABEL Name=zulu-for-opensuse
LABEL Version=0.0.2
LABEL org.opencontainers.image.authors="x123456789fy@outlook.com"
SHELL [ "/bin/bash" , "-c"]
RUN zypper rr -a
RUN zypper ar -cfg 'https://opentuna.cn/opensuse/tumbleweed/repo/oss/' opentuna-oss
RUN zypper ar -cfg 'https://opentuna.cn/opensuse/tumbleweed/repo/non-oss/' opentuna-non-oss
RUN zypper ar -cfg 'https://opentuna.cn/opensuse/update/tumbleweed/' opentuna-update
RUN zypper --non-interactive ref 
RUN zypper --non-interactive in jq curl
RUN zypper --no-gpg-checks --non-interactive in `curl -sX GET "https://api.azul.com/metadata/v1/zulu/packages/?java_version=8&os=linux&arch=x64&archive_type=rpm&java_package_type=jre&support_term=lts&latest=true&availability_types=CA&certifications=tck&page=1&page_size=100" -H "accept: application/json" | jq '.[] | .download_url' |sed 's/\"//g'`
RUN zypper --no-gpg-checks --non-interactive in `curl -sX GET "https://api.azul.com/metadata/v1/zulu/packages/?java_version=11&os=linux&arch=x64&archive_type=rpm&java_package_type=jre&support_term=lts&latest=true&availability_types=CA&certifications=tck&page=1&page_size=100" -H "accept: application/json" | jq '.[] | .download_url' |sed 's/\"//g'`
RUN zypper --no-gpg-checks --non-interactive in `curl -sX GET "https://api.azul.com/metadata/v1/zulu/packages/?java_version=17&os=linux&arch=x64&archive_type=rpm&java_package_type=jre&support_term=lts&latest=true&availability_types=CA&certifications=tck&page=1&page_size=100&javafx_bundled=true" -H "accept: application/json" | jq '.[] | .download_url' |sed 's/\"//g'`
RUN zypper --non-interactive rm jq curl
RUN zypper patch
RUN zypper ve
RUN ln -s /usr/lib/zre-8/bin/java /usr/bin/java8
RUN ln -s /usr/lib/zre-11/bin/java /usr/bin/java11
RUN ln -s /usr/lib/zre-17/bin/java /usr/bin/java7
RUN mkdir /mnt/data
RUN mkdir /mnt/program