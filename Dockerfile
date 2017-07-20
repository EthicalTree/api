FROM ruby:2.3.3

RUN apt-get update && apt-get install -y build-essential

WORKDIR /app

