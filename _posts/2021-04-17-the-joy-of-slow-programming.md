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

Were the code session with Python a wasted time? No, not really. Thanks to this session I learned that Telegram is the messaging app where it's extremely easy to send messages programmaticaly and how to create my own Telegram bot.