FROM ruby:2.3.6-alpine
RUN apk update && \
    apk upgrade && \
    apk add --update \
    mysql-dev yaml-dev libxml2-dev \
    ruby-dev bash curl-dev ruby-json yaml \
    libxslt-dev build-base linux-headers glib-dev

RUN mkdir /usr/src/app
WORKDIR /usr/src/app
COPY Gemfile /usr/src/app/Gemfile
COPY Gemfile.lock /usr/src/app/Gemfile.lock
RUN bundle install

COPY . /myapp

CMD ["rails", "server", "-b", "0.0.0.0"]
