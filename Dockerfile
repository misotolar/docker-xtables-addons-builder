FROM debian:trixie-slim AS build

ENV XTABLES_VERSION=3.28
ARG XTABLES_RELEASE=1
ARG XTABLES_SHA256=379ceecfc977adade406dd9350fea0686329052849cf9823ba767c0d07a2b361
ADD https://salsa.debian.org/pkg-netfilter-team/pkg-xtables-addons/-/archive/debian/$XTABLES_VERSION-$XTABLES_RELEASE/pkg-xtables-addons-debian-$XTABLES_VERSION-$XTABLES_RELEASE.tar.gz /tmp/xtables-addons.tar.gz

ARG DEBFULLNAME="Michal Sotolar"
ARG DEBEMAIL="michal@sotolar.com"
ARG DEBIAN_FRONTEND=noninteractive
ARG APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn

WORKDIR /build/xtables-addons

RUN set -ex; \
    sed -i 's/^Types: deb/Types: deb deb-src/' /etc/apt/sources.list.d/debian.sources; \
    apt-get update -y; \
    apt-get upgrade -y; \
    apt-get build-dep -y \
        xtables-addons; \
    apt-get install --no-install-recommends -y \
        devscripts; \
    echo "$XTABLES_SHA256 */tmp/xtables-addons.tar.gz" | sha256sum -c -; \
    tar xf /tmp/xtables-addons.tar.gz --strip-components=1; \
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
