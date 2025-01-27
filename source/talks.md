---
layout: page
title: Talks
---

{% assign talks = site.talks | sort_natural: "talk_date" | reverse %}

{% for talk in talks %}
## {{ talk.title | link: talk.url }}

{% assign highlight = talk.presentations | where: "highlight", true | first %}
{% if talk.repo %}* Repository: {{ talk.repo | link: talk.repo }}{% endif %}
{% if highlight and highlight.video %}* Video: {{ highlight.conference | link: highlight.video }}{% endif %}

{% endfor %}
