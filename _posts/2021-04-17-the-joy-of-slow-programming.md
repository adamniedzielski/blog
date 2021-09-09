---
layout: post
title: "The joy of slow programming"
---

I had a difficult relationship with side projects in the past. Basically I
could never get anywhere with them. Thanks to a set of techniques that I called "slow programming" I managed to develop side projects in a way that brings me joy. And this is the story that I'd like to share with you.

In the past when I was starting a new side project I'd try to fulfill these three goals:
1. build something meaningful that people can benefit from
2. use a cool new technology that I wanted to learn
3. make each commit perfect

As you may suspect, these three goals are really hard to fulfill at once. I'd usually give up at the stage of learning the new technology or setting up
the test environment. I didn't have any visible results at the beginning so I was not motivated to continue with the project. And a similar pattern would repeat for many different ideas.

This changed when a good friend of mine came to me with an idea for an application that he needed. He was searching for a new flat in Berlin and noticed that for a certain kind of companies (state-owned companies, landeseigene Wohnungsbaugesellschaften) the offers were disappearing very quickly after being published on the website. Often it was a matter of 30-60 minutes. My friend would receive an email notification about 2-3 hours afterwards, but at this point most of the offers were already gone. His idea was to develop an application that continuously checks the websites of these companies and sends a notification as soon as a new offer is available. And he needed my help.

We made an appointment for a "hacking evening". I was hoping that we can get something up and running within a few hours. All in all, the functionality was simple web scraping. I wanted to use some ready solution as much as possible. I didn't want to reinvent the wheel and I didn't have that much motivation.

After a quick research I picked [Scrapy](https://scrapy.org/) - a scraping framework in Python, supported by a commercial platform where the code can
run. I started putting up some code together as fast as possible. Soon I realised that the persistence is an important topic, because we want to somehow know which flat offers are new and which are not, the avoid sending the same notifications over and over again. I tried to get the code running on the provided infrastructure, with each passing minute getting more frustrated that it doesn't work yet and more disconnected from the reality. While I was getting deeper and deeper into the programming zone, my friend was sitting next to me, getting more and more bored, because at some point I stopped explaining what I'm currently doing. Not exactly the "hacking evening" anyone would wish for. After my frustration reached a certain level and my energy level dropped to zero I did `rm -rf the-project` and told my friend: "Well, I guess that I need to think about it more in the next days".

The result of this thinking were a few guiding ideas that I decided on:
1. use the "boring" technologies that I already know - Ruby, Nokogiri, Rails, and Heroku.
2. no more than one hour of work on the project per day
3. focus on delivering the smallest possible thing that actually provides some value to my friend
4. strive for simplicity from the technical perspective and not perfection

And this is how Neue Wohnung was born - https://github.com/adamniedzielski/neue_wohnung. If you look at the commits in the reverse order you can see that I started with the implementation, added tests soon, but not immediately, and configured CI after I had a running version in production.

I was working at a slow, steady pace, trying to enjoy the every moment of it. As I removed the pressure of time from myself, I could actually enjoy the little details like a new Rubocop rule that I didn't know or read up on libraries in general.

After a few days of working I had the first version and could actually start sending messages to my friend. This meant that I started receiving feedback early and could adjust the application based on it, without making too many false assumptions.

Were the code session with Python a wasted time? No, not really. Thanks to this session I learned that Telegram is the messaging app where it's extremely easy to send messages programmaticaly and how to create my own Telegram bot. From the time perspective I think about it as prototyping session, although during the actual session I didn't feel like prototyping.

The scraper was working in production (quickly set up Heroku) and my friend was receiving new flat offers every day. The next step was very boring - add support for more companies. It was a tedious activity to write this code, but I was never doing it for more than an hour per day and at the same time immediately getting the business value out of it - more and more apartment offers were reaching my friends and this kept me motivated.

I always started by copy pasting the previous scraper and the tests for it. The code was repetitive but I avoided reaching for any premature abstractions. The classes were simple and could fit in a single screen. The actual business logic - getting information from the HTML using Nokogiri and regular expressions - was unique to each company website with very few common elements.

This approach paid off as soon as I found the first website loading data dynamically from an unsecured JSON API :) Because of the lack on any authentication it was just easier to access the JSON API directly. My abstraction was lightweight so I didn't have to modify it. I just wrote this one particular scraper differently.

At some point I introduced the Apartment model to the application. At this stage I wasn't yet sure what data I can actually get in a consistent way. The only thing that I knew for sure was that I need to store a unique identifier for each apartment to avoid saving duplicated notifications after each subsequent check. That's why I added a mandatory `external_id` field. Everything else ended up in a JSONB `properties` field. This was simple and allowed me to move fast with delivering business value while moving slow with technical assumptions. Later it can always be improved and properties extracted to separate fields.

### Starting to use the app myself

A month or two have passed and guess what? I found myself in a need for a new apartment. Yes, I had to move out from my flat share and find a new apartment for myself. The application that I originally developed for my friends became my own hope on the cruel Berlin flat market. I was particularly interested in scoring an apartment in one of the housing associations (Wohnungsgenossenschaften), because they provide stable and secure renting possibilities and I believe in this organisational form.

The situation here was different. The offers didn't appear often, sometimes you could wait for the whole month for one housing association to publish something. However, there were about 30-40 housing associations that I was interested in. I started with a long list of links and every day was going through all of them, mostly to find out that no new offers appeared. This was a tedious and frustrating process.

So I started migrating the sources to be automatically handled by my app, one by one. From the technical point of view they were no different than the previous sources, so I didn't have to change anything in my assumptions. Again, I was working step by step, no more than one hour per day. Each migrated source meant one link less to click every morning, the list was shrinking and the progress was visible to me. This kept me motivated.

One day I received a notification from a housing cooperative that was particularly important to me. The apartment was in the neighbourhood close to my old apartment and a really good deal for the money. I immediately applied for it and from that moment on the things moved fast. Next day I had a viewing and within a week I signed the contract. The application that I developed as a side project scored me a new apartment! That's my most successful side project so far.

I attribute this success to the philosophy of "slow programming" that I followed:
1. put a hard limit on the time per day that you invest into the side project
2. move in small steps, don't rush and appreciate the little learnings that come every day
3. each step should make a little visible improvement so you stay motivated
