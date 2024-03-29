# This Dockerfile is optimized for running in development. That means it trades
# build speed for size. If we were using this for production, we might instead
# optimize for a smaller size at the cost of a slower build.
FROM ruby:3.2.2-alpine

RUN apk add --update --no-cache  \
  build-base \
  tzdata

# Get bundler 2.0
RUN gem install bundler

RUN mkdir /app
WORKDIR /app

COPY Gemfile Gemfile.lock ./

RUN bundle install --without production

COPY . ./

CMD ["./docker/invoke.sh"]
