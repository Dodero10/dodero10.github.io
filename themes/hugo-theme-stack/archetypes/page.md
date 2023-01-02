---
# Page Description
title: "{{ replace .Name "-" " " | title }}"
description: #Your description here
date: {{ .Date }}

image: 

# Layout of the page, which can be extract from theme/layouts/_default or layouts/_default
layout:

# The path of the page, e.g, "example.com/:slug/"
slug: "{{ .Name | lower }}"

# Latex included?
math: 

# License
license: 

# Hide page from pulish 
hidden: false

# Allow comments?
comments: false

---