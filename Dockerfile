FROM docker.io/openresty/openresty:alpine-fat AS builder

RUN apk add --no-cache openssl-dev

RUN /usr/local/openresty/luajit/bin/luarocks install lapis && \
    /usr/local/openresty/luajit/bin/luarocks install lua-resty-http && \
    /usr/local/openresty/luajit/bin/luarocks install lua-cjson && \
    /usr/local/openresty/luajit/bin/luarocks install htmlparser && \
    /usr/local/openresty/luajit/bin/luarocks install lua-resty-openssl


FROM docker.io/openresty/openresty:alpine

WORKDIR /app

RUN apk add --no-cache openssl

COPY --from=builder /usr/local/openresty/luajit/share/lua/ /usr/local/openresty/luajit/share/lua/
COPY --from=builder /usr/local/openresty/luajit/lib/ /usr/local/openresty/luajit/lib/
COPY --from=builder /usr/local/openresty/luajit/bin/lapis /usr/local/openresty/luajit/bin/lapis

COPY . .

RUN /usr/local/openresty/luajit/bin/lapis migrate
RUN chown -R nobody:nobody /app

EXPOSE 80

CMD ["/usr/local/openresty/luajit/bin/lapis", "serve", "production"]
