FROM openresty/openresty:alpine-fat

WORKDIR /app

COPY . .

RUN apk add --no-cache openssl openssl-dev lua-sec

RUN /usr/local/openresty/luajit/bin/luarocks install lapis
RUN /usr/local/openresty/luajit/bin/luarocks install lua-resty-http
RUN /usr/local/openresty/luajit/bin/luarocks install lua-cjson
RUN /usr/local/openresty/luajit/bin/luarocks install htmlparser
RUN /usr/local/openresty/luajit/bin/luarocks install lua-resty-openssl

EXPOSE 80

CMD ["lapis", "serve", "production"]
