FROM alpine:3 AS build

RUN apk add \
        ninja \
        g++ \
        git \
        cmake \
        go \
        perl \
        linux-headers

COPY . .

WORKDIR /build

RUN cmake -GNinja .. && \
    ninja && \
    strip -s curl/installed/bin/curl -o /curl

FROM scratch
COPY --from=build /curl /curl 
ENTRYPOINT ["/curl"]