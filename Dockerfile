FROM debian:bookworm-slim AS build

ENV XTABLES_VERSION=3.27
ARG XTABLES_RELEASE=4
ARG XTABLES_SHA256=e47ea8febe73c12ecab09d2c93578c5dc72d76f17fdf673397758f519cce6828
ADD https://inai.de/files/xtables-addons/xtables-addons-$XTABLES_VERSION.tar.xz /tmp/xtables.tar.xz

ENV XTABLES_DEBIAN_VERSION=3.23-1
ARG XTABLES_DEBIAN_SHA256=39510359008cb4e38f695bad4f14a0b571ee23e50eb538226d41ce5aa6351315
ADD http://deb.debian.org/debian/pool/main/x/xtables-addons/xtables-addons_$XTABLES_DEBIAN_VERSION.debian.tar.xz /tmp/xtables-debian.tar.xz

ENV XTABLES_DEBIAN_TESTING_VERSION=$XTABLES_VERSION-$XTABLES_RELEASE
ARG XTABLES_DEBIAN_TESTING_SHA256=29d30328c7036a88298b5c28a00e1645822e4679e4476d8c02a1e0deb3c4c480
ADD http://deb.debian.org/debian/pool/main/x/xtables-addons/xtables-addons_$XTABLES_DEBIAN_TESTING_VERSION.debian.tar.xz /tmp/xtables-debian-testing.tar.xz

ARG DEBFULLNAME="Michal Sotolar"
ARG DEBEMAIL="michal@sotolar.com"
ARG DEBIAN_FRONTEND=noninteractive
ARG APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn

WORKDIR /build/xtables

RUN set -ex; \
    sed -i 's/^Types: deb/Types: deb deb-src/' /etc/apt/sources.list.d/debian.sources; \
    apt-get update -y; \
    apt-get upgrade -y; \
    apt-get build-dep -y \
        xtables-addons; \
    apt-get install --no-install-recommends -y \
        devscripts; \
    echo "$XTABLES_SHA256 */tmp/xtables.tar.xz" | sha256sum -c -; \
    tar xf /tmp/xtables.tar.xz --strip-components=1; \
    echo "$XTABLES_DEBIAN_SHA256 */tmp/xtables-debian.tar.xz" | sha256sum -c -; \
    tar xf /tmp/xtables-debian.tar.xz; \
    echo "$XTABLES_DEBIAN_TESTING_SHA256 */tmp/xtables-debian-testing.tar.xz" | sha256sum -c -; \
    tar xf /tmp/xtables-debian-testing.tar.xz debian/docs; \
    tar xf /tmp/xtables-debian-testing.tar.xz debian/patches; \
    dch -v $XTABLES_VERSION-$XTABLES_RELEASE+misotolar "Backport {$XTABLES_VERSION}-{$XTABLES_RELEASE} release"; \
    rm -rf \
        /var/lib/apt/lists/* \
        /var/tmp/* \
        /tmp/*

COPY resources/builder.sh /usr/local/bin/builder.sh
COPY resources/upgrade.sh /usr/local/bin/upgrade.sh

VOLUME /dest

ENTRYPOINT ["builder.sh"]
CMD ["/dest"]
