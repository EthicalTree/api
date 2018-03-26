FROM ruby:2.5.0-alpine

ENV HOME /app
ADD Gemfile /app/
ADD Gemfile.lock /app/

RUN mkdir -p /app/tmp/pids && \
  apk --update add --virtual build-dependencies build-base linux-headers tzdata \
  libxml2-dev libxslt-dev mariadb-client-libs mariadb-dev libbsd-dev && \
  cd /app ; bundle install --without development test

WORKDIR /app
ADD . /app

CMD ["bundle", "exec", "unicorn", "-p", "80", "-c", "./config/unicorn/production.rb"]
