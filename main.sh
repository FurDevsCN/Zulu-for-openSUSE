#!/usr/bin/env bash
set -x

# root image

container=$(buildah from opensuse/tumbleweed)

# init zypper software sources

buildah run $container zypper --non-interactive rr *
buildah run $container zypper --no-gpg-checks ar -cfg 'https://opentuna.cn/opensuse/tumbleweed/repo/oss/' opentuna-oss
buildah run $container zypper --no-gpg-checks ar -cfg 'https://opentuna.cn/opensuse/tumbleweed/repo/non-oss/' opentuna-non-oss
buildah run $container zypper --no-gpg-checks ar -cfg 'https://opentuna.cn/opensuse/update/tumbleweed/' opentuna-update
buildah run $container zypper --non-interactive --no-gpg-checks --auto-agree-with-licenses ref 

# get zulu latest version

buildah run $container zypper --non-interactive --no-gpg-checks --auto-agree-with-licenses in jq
buildah run $container zypper --non-interactive --no-gpg-checks --auto-agree-with-licenses in curl
Zulu8Url=`curl -sX GET "https://api.azul.com/metadata/v1/zulu/packages/?java_version=8&os=linux&arch=x64&archive_type=rpm&java_package_type=jre&support_term=lts&latest=true&availability_types=CA&certifications=tck&page=1&page_size=100" -H "accept: application/json" | jq '.[] | .download_url'`
Zulu11Url=`curl -sX GET "https://api.azul.com/metadata/v1/zulu/packages/?java_version=11&os=linux&arch=x64&archive_type=rpm&java_package_type=jre&support_term=lts&latest=true&availability_types=CA&certifications=tck&page=1&page_size=100" -H "accept: application/json" | jq '.[] | .download_url'`
Zulu17Url=`curl -sX GET "https://api.azul.com/metadata/v1/zulu/packages/?java_version=17&os=linux&arch=x64&archive_type=rpm&java_package_type=jre&support_term=lts&latest=true&availability_types=CA&certifications=tck&page=1&page_size=100&javafx_bundled=true" -H "accept: application/json" | jq '.[] | .download_url'`
# install zulu

buildah run $container zypper --non-interactive --auto-agree-with-licenses patch --with-update
buildah run $container zypper --non-interactive --no-gpg-checks --auto-agree-with-licenses in $Zulu8Url $Zulu11Url $Zulu17Url
buildah commit $container example
