FROM ruby:2.7.6-bullseye

WORKDIR /app

COPY Gemfile Gemfile.lock register_ingester_oc.gemspec /app/
COPY lib/register_ingester_oc/version.rb /app/lib/register_ingester_oc/

# Download public key for github.com
RUN mkdir -p -m 0700 ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts

RUN --mount=type=ssh bundle install

COPY . /app/

CMD ["bundle", "exec", "rspec"]
