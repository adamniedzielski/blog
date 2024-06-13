---
layout: post
title: "Sidekiq and transactions"
---

Sidekiq uses Redis as the underlaying datastore for jobs. At the same time jobs often manipulate data in a database. This leads to issues when jobs access records that were not committed yet.

Sidekiq Wiki addresses this issue [here](https://github.com/sidekiq/sidekiq/wiki/Problems-and-Troubleshooting#cannot-find-modelname-with-id12345). However, the situation when the record doesn't exist yet outside of transaction, is not the worst what can happen to us.
More subtle errors happen when the record got modified in the transaction, but our job is still using the old version. Bugs resulting from this incorrect behavior are difficult to troubleshoot.

## Built-in solution

Luckily since version 6.5 Sidekiq ships with a built-in solution for this problem - transactional push. It's just not enabled by default. In order to use it include `after_commit_everywhere` in your `Gemfile`:

```ruby
# Gemfile
gem "after_commit_everywhere"
```

And place this in your Sidekiq initializer:

```ruby
# config/initializers/sidekiq.rb
Sidekiq.transactional_push!
```

That's it! If you want to enable it only for a specific type of job refer to [Sidekiq Wiki](https://github.com/sidekiq/sidekiq/wiki/Advanced-Options#transactional-push).


## Alternative as an extension

I created a gem that offers an alternative to transactional push - [sidekiq-staged_push](https://github.com/adamniedzielski/sidekiq-staged_push).

The staged push strategy involves storing jobs in an intermediary database table. Thanks to this we automatically benefit from database transactions. The gem implements the approach described in [Transactionally Staged Job Drains in Postgres](https://brandur.org/job-drain). Quoting the author:

> With this pattern, jobs aren’t immediately sent to the job queue. Instead, they’re staged in
> a table within the relational database itself, and the ACID properties of the running
> transaction keep them invisible until they’re ready to be worked. A secondary enqueuer
> process reads the table and sends any jobs it finds to the job queue before removing their
> rows.

This approach has one subtle advantage over the Sidekiq built-in solution:

> If you queue a job after a transaction is committed, you run the risk of your program crashing after the commit, but before the job makes it to the queue. Data is persisted, but the background work doesn’t get done. It’s a problem that’s less common than the one Sidekiq is addressing, but one that’s far more nefarious; you almost certainly won’t notice when it happens.


I created a [demo application](https://github.com/adamniedzielski/sidekiq-staged_push-demo) to demonstrate how the gem is working. The gem doesn't have much production usage yet, so I'd like to encourage you to try it in your application and [report back](https://github.com/adamniedzielski/sidekiq-staged_push/issues/14).
