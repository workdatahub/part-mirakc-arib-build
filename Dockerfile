# mirakc-aribのビルド
# mirakc-aribコマンドを作り出して他のDckerfileの中で利用する
FROM  workdatahub/alpine-build-env AS Mirakc-arib-build

RUN apk --update add --no-cache samurai dos2unix libtool libc-dev linux-headers patch 
RUN mkdir -p /build/mirakc-arib
WORKDIR /build/mirakc-arib
RUN curl -fsSL https://github.com/masnagam/mirakc-arib/tarball/d79515e4818bb2f0a1eb810789d83e76f5e8f2c7 \
    | tar -xz --strip-components=1
COPY tsUDPSocket.patch patches/
COPY CMakeLists.patch ../
RUN patch CMakeLists.txt < ../CMakeLists.patch
RUN cmake -S . -B . -G Ninja -D CMAKE_BUILD_TYPE=Release
RUN ninja vendor
RUN ninja
RUN cp bin/mirakc-arib /usr/local/bin/

RUN mkdir -p /build/librarycopy
WORKDIR /build/librarycopy
COPY exliblist.sh exliblist.sh
COPY lcopy.sh lcopy.sh

RUN echo /usr/local/bin/mirakc-arib >> binlist
RUN ./exliblist.sh binlist copylist

RUN echo /usr/local/bin/mirakc-arib >> copylist
# RUN ./lcopy.sh copylist /copydir

# dockerhubでビルド後必要な部分のみ利用出来るようにする
# FROM scratch

# COPY --from=Mirakc-arib-build /copydir /copydir

SHELL ["/bin/sh","-l","-c"]