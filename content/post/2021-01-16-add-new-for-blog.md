---
layout:     post 
title:      "给hugo博客添加字数统计和阅读需要xx分钟的功能"
subtitle:   ""
description: "给hugo博客添加字数统计和阅读需要xx分钟的功能"
date:       2021-02-16
author:     "lyp"
image: "https://res.cloudinary.com/lyp/image/upload/v1544363191/hugo/blog.github.io/743a4e9227e1f14cb24a1eb6db29e183.jpg"
published: false
tags:
    - Blog
categories: 
    - Tech
---  

```
<h2 class="subheading">{{ .Params.subtitle }}</h2>
                    <span  class="meta">Posted by {{ if .Params.author }}{{ .Params.author }}{{ else }}{{ .Site.Title }}{{ end }} on {{ .Date.Format "Monday, January 2, 2006" }}
                        {{ if .Site.Params.page_view_conter }}
                        {{ partial "page_view_counter.html" . }}
                        {{ end }}
                    </span>
```

```
<span id="busuanzi_container_page_pv">|<span id="busuanzi_value_page_pv"></span><span>
                            {{ partial "page_view_counter.html" .  }}
                            阅读 </span></span>|<span class="post-date">共{{ .WordCount  }}字</span>，阅读约<span class="more-meta"> {{ .ReadingTime  }} 分钟</span>
```