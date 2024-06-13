---
layout: post
title: "Modern setup for GitHub Pages"
---

In this blog post I'd like to share how I upgraded my Jekyll setup to Jekyll 4 and a dockerized development environment.

If you have been running a Jekyll site for a while you probably have code like this in your `Gemfile`:

```ruby
# If you want to use GitHub Pages, remove the "gem "jekyll"" above and
# uncomment the line below. To upgrade, run `bundle update github-pages`.
# gem "github-pages", group: :jekyll_plugins
```

It's there as an attempt to keep in sync versions of libraries that are used in development and in production.

However, there are two important gotchas here:
1. The version of `github-pages` that you specify here is not going to influence the version used when deploying.
2. [`github-pages` is stuck on Jekyll 3, with little chances to be upgraded](https://github.com/github/pages-gem/issues/651)


## Solution

In order to fix that we're going to switch to a new way of deploying GitHub Pages, which uses GitHub Actions.

Let's start by dockerizing the development environment:

```Dockerfile
# Dockerfile

FROM ruby:3.2.2-alpine AS dev
RUN apk add build-base git bash
WORKDIR /app
ENV BUNDLE_PATH=/bundle \
    BUNDLE_BIN=/bundle/bin \
    GEM_HOME=/bundle
ENV PATH="${BUNDLE_BIN}:${PATH}"
```

```yaml
# docker-compose.yml

version: "3.9"
services:
  web:
    platform: linux/x86_64
    build:
      context: .
      target: dev
    stdin_open: true
    tty: true
    command: bundle exec jekyll serve --host 0.0.0.0
    volumes:
      - ".:/app"
      - bundle:/bundle
    ports:
      - "4000:4000"
volumes:
  bundle:
```

```Makefile
# Makefile

build:
	docker-compose build

bundle:
	docker-compose run --rm web bundle install

server:
	docker-compose run --rm --service-ports web

bash:
	docker-compose run --rm web bash
```

This setup is my standard Docker for development setup. More about it [here](https://dev.to/adamniedzielski/docker-for-skeptics-3eod).

Now we need to run:

```
make build
make bundle
make server
```

and the application should be up and running on `localhost:4000`.

It's using the version of Jekyll that you specified in the `Gemfile`.

#### GitHub Actions

Time to configure GitHub Pages to use GitHub Actions.

![](/images/modern_setup_github_pages/configuration.png)

We're going to use the suggested workflow with some minor modifications:

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      - name: Setup Pages
        id: pages
        uses: actions/configure-pages@v4
      - name: Build Docker image
        run: docker build --target=ci --tag=jekyll-image .
      - name: Build site with Jekyll inside Docker container
        run: |
          docker run -v ./_site:/app/_site jekyll-image bundle exec jekyll build --baseurl "${{ steps.pages.outputs.base_path }}"
      - name: Upload artifact
        # Automatically uploads an artifact from the './_site' directory by default
        uses: actions/upload-pages-artifact@v3
```

And we need to extend our Dockerfile:

```Dockerfile
# [...]

FROM dev AS ci
ENV JEKYLL_ENV=production
COPY Gemfile Gemfile.lock ./
RUN bundle install
COPY . ./
```

That's it! When you investigate logs of the GitHub Actions runs you should see that it's using exactly the same version of Jekyll. If you haven't done it yet, you can bump it to Jekyll 4 in development, test your site, and enjoy exactly the same configuration in production.

[Here](https://github.com/adamniedzielski/blog/commit/bbc9e80f12d577acfd774db0319c98a1d77055c2) and [here](https://github.com/adamniedzielski/blog/commit/bda1906311cd884a5402e96f4878b6393f117a74) you can see how I migrated this blog.