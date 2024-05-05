---
layout: page
title: Talks
---

{% for talk in site.talks %}
## {{ talk.title | link: talk.url }}

### Presentations

| Date | Conference | Video | Notes |
|------|------------|-------|-------|
{% for pres in talk.presentations -%}
| {{ pres.date }} | {{ pres.conference | link: pres.conference_link }} | {% if pres.video %}[link]({{ pres.video }}){% endif -%} | {{ pres.notes }} |
{% endfor %}
{% endfor %}

## Kids Today

* [PhillyETE, May 2019](https://2019.phillyemergingtech.com) - [video](https://youtu.be/TPDoiZZxRrg)
* [CocoaConf Chicago, 2017]()
* [CocoaConf Yosemite, 2017]()

## Learning From Our Elders

* [CocoaConf Chicago, 2017]()
* [CocoaConf SJ, Jun 2017]()
* [UIKonf, May 2017]() - [video](https://youtu.be/c3Kg3c8vqsc)
* [AppsConf, May 2019](https://appsconf.ru/spb/2019) - [video](https://youtu.be/CUwYDP_JhrA)
* [360 iDev, Nov 2017]() - [video](https://youtu.be/bD1ucQ5UfN0)
* [Mobile Developer's Summit (MODS), 2017]()
* CocoaHeads RTP 2017 - [video](https://vimeo.com/204897590)

## Practical Security

* [DevFest Triangle, Sep 2019](https://devfest.gdgtriangle.com/home)
* [Istanbul Tech Talks, Sep 2017]() - [video](https://youtu.be/c-77CxUKCZo)
* [360iDev, Dev 2017]() - [video](https://youtu.be/8YkaC7yfUrQ)
* CocoaConf DC, 2016
* CocoaConf Seattle, 2016
* CocoaConf DC, 2013

## Secrets and Lies

* [MobileOptimized, Oct 2018]() - [video](https://youtu.be/Jv-qEr0j4AM)
* [360iDev, Mar 2018]() - [video](https://youtu.be/ziwm8bMKxsw)
* [SwiftFest, Jun 2018](https://2018.swiftfest.io/schedule/#session-018)

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
