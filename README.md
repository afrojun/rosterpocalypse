# Rosterpocalypse

![](app/assets/images/logo.svg)

## Background

This is the Ruby on Rails application that powered the Heroes of the Storm fantasy esports league website during the 2017 HGC season.

It is fairly old now, but I'm releasing it here for reference and as a part of HGC history. For a while there it really was amazing to be a part of that scene! We were so hopeful and naïve...

Unfortunately, all good things come to an end, and the costs ended up being prohibitive to continue to operate the website and we were not able to come up with a sustainable revenue model that didn't involve some form of gambling. To make matters worse, I forgot to renew the domain registration, so rosterpocalypse dot com is now owned by some squatter who has a lot of horrible ads on there, so please don't visit it!

## Setup

Ensure you are using Ruby 2.6.7 and have a PostgreSQL database running locally, then run:

```
bundle install
npm install

bundle exec rails db:setup
```

To run the test suite, run:

```
bundle exec rspec
```

To run the app locally, first install the [Heroku CLI](https://devcenter.heroku.com/articles/heroku-cli), then run:

```
heroku local -f Procfile.dev
```

## Contact

[Rosterpocalypse on Twitter](https://twitter.com/rosterpocalypse)
