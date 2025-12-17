# Kittygram

Kittygram is an anonymous, privacy-friendly, lightweight, and open-source Instagram frontend inspired by [nitter](https://github.com/zedeus/nitter)
.
It offers a clean, fast way to browse Instagram without the usual clutter or tracking.

## Why

The official Instagram web interface is heavy on JavaScript, slow to load, and filled with pop-ups.
Kittygram avoids all of that by serving fully prerendered pages, making it faster and easier to use.  

Kittygram also helps you avoid the heavy tracking instagram does, as all requests are handled by kittygram.   

### Limitations
- As of now, only the first ~20 comments on a post can be fetched.
- Instagram aggresively rate-limits requests coming from servers, which can make running a public instance difficult.  


## Instances

|URL |Description|
|-----|-----------|
|https://kittygram.fsky.io | An instance of kittygram operated by [FSKY](https://fsky.io) |
|https://kittygram.irelephant.net | An instance of kittygram run by its creator |



## Installation

> [!NOTE]
> I highly recommend you install kittygram using docker. Luarocks can be finicky a lot of the time.  

### Method 1: Docker

1. Install [docker](https://docs.docker.com/engine/install/).  
2. Clone the project:
```shell
git clone https://codeberg.org/irelephant/kittygram.git
```
3. Build the kittygram image:
```Shell
sudo docker build . -t "kittygram"
```
4. Run the built image:
```shell
sudo docker run -p 80:80 kittygram
```  

# Method 2: Running from scratch
1. Clone the project:
```shell
git clone https://codeberg.org/irelephant/kittygram.git
```
2. Install [openresty](https://openresty.org/en/installation.html)
3. Install [luarocks](https://luarocks.org/) (likely in your distro's package manager), and install the project's dependencies:
```shell
# Try running CC="gcc -std=gnu99" if you get some compilation errors. 
sudo luarocks install lapis
sudo luarocks install lua-resty-http
sudo luarocks install htmlparser
sudo luarocks install cjson
sudo luarocks install lua-resty-openssl
```
4. Run `lapis serve production` to run the project.

> [!NOTE]  
> You may have more luck installing modules locally. That is detailed here: https://github.com/leafo/lapis/issues/777#issuecomment-1900359264     


--------
Kittygram is licensed under the AGPL-3.0.  

Icon made by [nulla](https://codeberg.org/nulla).

