---
layout: page
title: Talks
---

{% assign talks = site.talks | sort: "talk_date" | reverse %}

{% for talk in talks %}
## {{ talk.title | link: talk.url }}

{% assign highlight = talk.presentations | where: "highlight", true | first %}
{% if talk.repo %}* Repository: {{ talk.repo | link: talk.repo }}{% endif %}
{% if highlight %}* Video: {{ highlight.conference | link: highlight.video }}{% endif %}

{% endfor %}

## Once More, With Types

* [Do iOS, Dec 2016]() - [video](https://youtu.be/_S6UOrwS-Tg)

## To be! Or not? Optionals in Practice

* [iOS Conf SG, Nov 2017](http://iosconf.sg/) - [video](https://youtu.be/Q1Tayh4unMw)

## Lambda: There and Back Again

* [try! Swift NYC, 2016]() - [video](https://youtu.be/pgwM-LvMiDU)

## Animating Custom Layer Properties

* CocoaHeads RTP, Jun 2012 - [video](https://vimeo.com/44986916)

## Rich Text, Core Text

* CocoaHeads RTP, Dec 2012 - [video](https://vimeo.com/56670254)
* CocoaConf DC, 2013
* CocoaConf Raleigh, 2012

## AppCode Lightning Talk

* CocoaHeads RTP, Jul 2013 - [video](https://vimeo.com/74539769)

## Array to Zipper

* CocoaConf Seattle, 2016
* CocoaConf DC, 2015

## Llama Calculus

* CocoaConf DC, 2015
* CocoaConf Atlanta, 2014

## Get Security and Privacy Right

* Renaissance, 2014 - [video](https://youtu.be/Kk6sdM9_6ZI)

## Almost Physics: UIKit Dynamics

* CocoaConf Raleigh, 2014

## Avoiding Security Blunders

* CocoaConf Raleigh, 2012
