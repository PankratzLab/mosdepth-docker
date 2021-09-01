FROM ubuntu:20.04

RUN apt-get -m update && apt-get install -y wget

https://github.com/brentp/mosdepth/releases/download/v0.3.2/mosdepth