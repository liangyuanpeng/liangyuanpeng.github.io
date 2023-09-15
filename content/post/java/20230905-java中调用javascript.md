---
layout:     post 
slug:      "run-javascript-on-the-java"
title:      "java中调用javascript"
subtitle:   ""
description: "在java中调用javascript,本文主要讲述的是 graal.js"
#do not show it on the top
date:       2023-09-05
#date:       2023-05-04
author:     "梁远鹏"
image: "/img/banner-pexels.jpg"
published: false
tags:
    - java
    - javascript
categories: 
    - cloudnative
---


# 说明

```java
    @Test
    public void testInvoke() throws ScriptException, NoSuchMethodException {
        ScriptEngine engine = getEngine();
        String jsResult = "hello ";
        String param = "world";
        String jsFunc = "function hello(param){return '"+jsResult+"' + '"+param+"' };";
        engine.eval(jsFunc);
        Invocable in =  (Invocable)engine;
        String result = (String) in.invokeFunction("hello",param);
        Assertions.assertEquals(jsResult+param,result);
    }


    public ScriptEngine getEngine(){
        ScriptEngine engine = new ScriptEngineManager().getEngineByName("graal.js");
        Assertions.assertNotNull(engine);
        return engine;
    }
```

对应的关键依赖是:

```xml
      <properties>
              <graalvm-js.version>23.0.1</graalvm-js.version>
      </properties>

        <dependency>
            <groupId>org.graalvm.js</groupId>
            <artifactId>js</artifactId>
            <version>${graalvm-js.version}</version>
        </dependency>
        <dependency>
            <groupId>org.graalvm.js</groupId>
            <artifactId>js-scriptengine</artifactId>
            <version>${graalvm-js.version}</version>
        </dependency>
```

上述是一个在 java 中调用 javascript 的简单示例,其中 javascript 的 function 接受一个参数并且将参数与另一个字符串拼接,然后作为结果返回.