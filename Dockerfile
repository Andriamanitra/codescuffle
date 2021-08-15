FROM crystallang/crystal:1.1.1-alpine

RUN mkdir /app
WORKDIR /app

COPY shard.* /app/
RUN shards install

COPY src/*.cr /app/
RUN crystal build --release --static codescuffle.cr
