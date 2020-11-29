FROM ruby:2.7

RUN mkdir /app
WORKDIR /app

COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock

RUN bundle config mirror.https://rubygems.org https://gems.ruby-china.com
RUN bundle install

COPY . /app

EXPOSE 8233
CMD ["rake"]
