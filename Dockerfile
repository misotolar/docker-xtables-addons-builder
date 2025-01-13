FROM debian:bookworm-slim AS build

ENV XTABLES_VERSION=3.27
ARG XTABLES_RELEASE=3
ARG XTABLES_SHA256=e47ea8febe73c12ecab09d2c93578c5dc72d76f17fdf673397758f519cce6828
ARG XTABLES_URL=https://inai.de/files/xtables-addons/xtables-addons-$XTABLES_VERSION.tar.xz

ENV XTABLES_DEBIAN_VERSION=3.23-1
ARG XTABLES_DEBIAN_SHA256=39510359008cb4e38f695bad4f14a0b571ee23e50eb538226d41ce5aa6351315
ARG XTABLES_DEBIAN_URL=http://deb.debian.org/debian/pool/main/x/xtables-addons/xtables-addons_$XTABLES_DEBIAN_VERSION.debian.tar.xz

ENV XTABLES_DEBIAN_TESTING_VERSION=$XTABLES_VERSION-$XTABLES_RELEASE
ARG XTABLES_DEBIAN_TESTING_SHA256=087df456cd1076b083f34a9739ae3212c7b7a7e7cd24f06eda56aa27c1bb1a63
ARG XTABLES_DEBIAN_TESTING_URL=http://deb.debian.org/debian/pool/main/x/xtables-addons/xtables-addons_$XTABLES_DEBIAN_TESTING_VERSION.debian.tar.xz

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
        ca-certificates \
        curl \
        devscripts; \
    curl -fsSL -o /tmp/xtables.tar.xz $XTABLES_URL; \
    echo "$XTABLES_SHA256 */tmp/xtables.tar.xz" | sha256sum -c -; \
    curl -fsSL -o /tmp/xtables-debian.tar.xz $XTABLES_DEBIAN_URL; \
    echo "$XTABLES_DEBIAN_SHA256 */tmp/xtables-debian.tar.xz" | sha256sum -c -; \
    curl -fsSL -o /tmp/xtables-debian-testing.tar.xz $XTABLES_DEBIAN_TESTING_URL; \
    echo "$XTABLES_DEBIAN_TESTING_SHA256 */tmp/xtables-debian-testing.tar.xz" | sha256sum -c -; \
    tar xf /tmp/xtables.tar.xz --strip-components=1; \
    tar xf /tmp/xtables-debian.tar.xz; \
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
