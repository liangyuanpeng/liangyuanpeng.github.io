---
layout:     post 
title:      "ChirpStack自定义JS codec函数"
subtitle:   "JS编解码函数的使用,减少程序解码数据工作量"
description: "轻快,简洁,功能强大,使用Spring Boot开发的博客系统/CMS系统,值得一试."
date:       2021-03-06
author:     "梁远鹏"
image: "https://res.cloudinary.com/lyp/image/upload/v1544363191/hugo/blog.github.io/743a4e9227e1f14cb24a1eb6db29e183.jpg"
published: true
tags:
    - ChirpStack
    - IOT
    - 物联网
    - LoraWan
categories: 
    - IOT
---  

# 前言  

ChirpStack作为Lorawan Server，可以同时接收不同客户的设备数据(通过Application或Org区分开),而如果这些客户都希望可以从ChirpStack拿到设备数据的话，他们各自都会拿到base64编码过的数据并且都需要各自实现一次逻辑将数据解码转换成数字。  

而ChirpStack可以做到在ChirpStack层将数据解码并且转换成人类能够看懂的json数据,下行数据也是一样的道理，下行数据时需要将数据base64编码，有了JS编解码函数后下行调用方可以直接使用json数据，编码的事情由JS编解码函数来做。  

# 开启JS解编码函数功能  

默认是不开启的，需要在ChirpStack的Dashboard页面上找到对应的`devicefile`开启`Custom JavaScript codec functions`这个功能。   

![](https://res.cloudinary.com/lyp/image/upload/v1614914576/hugo/blog.github.io/chirpstack/jsfordata/devicefile.png)


![](https://res.cloudinary.com/lyp/image/upload/v1614914576/hugo/blog.github.io/chirpstack/jsfordata/codec.png)

# 理解JS解编码函数功能  

可以看到默认情况下函数是什么都不做的。  

其中解码函数有两个传参：`fPort`和`bytes`,`fPort`是数据上传的端口号，`bytes`是上传的数据。  

我们可以只给特定端口的数据进行JS解码，通过JS解码后的数据会在原先json数据之上多一个`object`字段。  

假设`101`端口上传的数据是空气质量设备的数据，而数据的第十三字节是`TVOC`的数据,那么可以添加以下的代码，只对空气质量的设备数据解码`TVOC`的数据。  

```
  if(fPort==101){
   var data = {
    "tvoc": 22.5
  };
  data.tvoc= bytes[13];
  return data;
  }
```

设置JS解编码函数之前设备的数据格式：  
![](https://res.cloudinary.com/lyp/image/upload/v1614914576/hugo/blog.github.io/chirpstack/jsfordata/data.png)

设置JS解编码函数之后设备的数据格式：  

![](https://res.cloudinary.com/lyp/image/upload/v1614914575/hugo/blog.github.io/chirpstack/jsfordata/data2.png)


可以看到object字段下多了字段`tvoc`,而这个字段是我们在JS解码函数中返回的。  

# JS解码函数小结
这样的话当有多个客户希望拿到设备数据时就可以直接从Object字段中获取对应的数据，而不需要再写程序去解码`lorawan数据`以及`处理字节数据`了。


下行也是一样的，首先我们在dashboard尝试使用原生的下行数据功能。  

![](https://res.cloudinary.com/lyp/image/upload/v1614914577/hugo/blog.github.io/chirpstack/jsfordata/device1.png)

假设需要给设备发送一个`1`的下行数据，我们首先需要将`1`进行base64编码，然后将编码后的字符串在dashboard填写到对应的文本框中，点击下行按钮。  

![](https://res.cloudinary.com/lyp/image/upload/v1614914577/hugo/blog.github.io/chirpstack/jsfordata/downlink1.png)  

![](https://res.cloudinary.com/lyp/image/upload/v1614914576/hugo/blog.github.io/chirpstack/jsfordata/downlink2.png)

注意我们每次在下行数据时都需要将我们希望下行的数据进行base64编码，然后才能下行。而利用JS编码函数功能我们就可以将这个编码操作交给JS编码函数，不需要在每次发送数据前都去自行编码一次。  

回到刚才设置JS解编码函数的地方，在编码的代码框中添加编码的逻辑代码，这里以处理端口号为`123`的数据作为
演示。  

注意：编码函数返回的数据需要是字节数组，代码框中也有提示。

```
  if(fPort==123){
   var data = new Array();
   data[0] = (obj.command >> 8) & 0x00FF;
   data[1] = (obj.command ) & 0x00FF;
   return data;
  }
```  

当端口号是`123`时,将json格式的下行数据中的command转换成两个字节数据。  

回到刚才发送下行数据的地方，选择`JSON OBJECT`,填写我们需要的json格式数据：   

![](https://res.cloudinary.com/lyp/image/upload/v1614914577/hugo/blog.github.io/chirpstack/jsfordata/downlink3.png)

```
{
"command":369
}
```  



端口号填写为`123`,确认没问题后点击发送下行数据。在下方提示队列会得到一个下行的数据结果，按照本文步骤来的话会显示`AXE=`.  

![](https://res.cloudinary.com/lyp/image/upload/v1614914577/hugo/blog.github.io/chirpstack/jsfordata/downlink4.png)

# 验证下行结果
将字符串`AXE=`解码后得到的结果是`01和71`，将两个字节进行`01*256+71`计算后得到的是`369`,正是下行数据command字段的值。  

# JS编码函数小结
这样就省去了在发送下行数据时每次都需要自行将数据编码的过程,同理，如果多个客户都需要对各自的传感器进行下行数据的话，就省去了他们各自将下行数据编码的过程(前提是已经设置好对应的JS编码函数了)。  

https://blog.csdn.net/iotisan/article/details/104070445  