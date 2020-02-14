---
layout:     post 
title:      "利用docker和docker-compose部署单机kafka"
subtitle:   ""
description: "Apache Kafka是一个分布式流处理平台，最初由LinkedIn开发并开源贡献给Apache"  
date:       2020-02-14
author:     "lan"
image: "https://res.cloudinary.com/lyp/image/upload/v1581649210/hugo/blog.github.io/blur-close-up-code-computer-546819.jpg"
published: true
tags: 
    - 消息队列
    - 中间件
categories: 
    - 中间件
---


# 前提

1. [docker](https://www.docker.com/get-started)  
2. [docker-compose](https://github.com/docker/compose)  

其中docker-compose不是必须的,单单使用docker也是可以的,这里主要介绍docker和docker-compose两种方式

## docker部署  

docker部署kafka非常简单，只需要两条命令即可完成kafka服务器的部署。

```
docker run -d --name zookeeper -p 2181:2181  wurstmeister/zookeeper
docker run -d --name kafka -p 9092:9092 -e KAFKA_BROKER_ID=0 -e KAFKA_ZOOKEEPER_CONNECT=zookeeper:2181 --link zookeeper -e KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://192.168.1.60(机器IP):9092 -e KAFKA_LISTENERS=PLAINTEXT://0.0.0.0:9092 -t wurstmeister/kafka
```  
由于kafka是需要和zookeeper共同工作的,所以需要部署一个zookeeper,但有了docker这对部署来说非常轻松.  
可以通过``docker ps``查看到两个容器的状态,这里不再展示.

接下来可以进行生产者和消费者的尝试  

### 通过kafka自带工具生产消费消息测试  

1. 首先,进入到kafka的docker容器中  
```
docker exec -it kafka sh
```  
2. 运行消费者,进行消息的监听
```
kafka-console-consumer.sh --bootstrap-server 192.168.1.60:9094 --topic kafeidou --from-beginning
```  

3. 打开一个新的ssh窗口,同样进入kafka的容器中,执行下面这条命令生产消息
```
kafka-console-producer.sh --broker-list 192.168.1.60(机器IP):9092 --topic kafeidou
```  
输入完这条命令后会进入到控制台，可以输入任何想发送的消息,这里发送一个``hello``
```
>>
>hello
>
>
>
```  
4. 可以看到,在生产者的控制台中输入消息后,消费者的控制台立刻看到了消息   

到目前为止,一个kafka完整的hello world就完成了.kafka的部署加上生产者消费者测试.  

### 通过java代码进行测试  

1. 新建一个maven项目并加入以下依赖  
```
<dependency>
      <groupId>org.apache.kafka</groupId>
      <artifactId>kafka-clients</artifactId>
      <version>2.1.1</version>
    </dependency>
    <dependency>
      <groupId>org.apache.kafka</groupId>
      <artifactId>kafka_2.11</artifactId>
      <version>0.11.0.2</version>
    </dependency>
```  
2. 生产者代码  
producer.java
```
import org.apache.kafka.clients.producer.*;

import java.util.Date;
import java.util.Properties;
import java.util.Random;

public class HelloWorldProducer {
  public static void main(String[] args) {
    long events = 30;
    Random rnd = new Random();

    Properties props = new Properties();
    props.put("bootstrap.servers", "192.168.1.60:9092");
    props.put("acks", "all");
    props.put("retries", 0);
    props.put("batch.size", 16384);
    props.put("linger.ms", 1);
    props.put("buffer.memory", 33554432);
    props.put("key.serializer", "org.apache.kafka.common.serialization.StringSerializer");
    props.put("value.serializer", "org.apache.kafka.common.serialization.StringSerializer");
    props.put("message.timeout.ms", "3000");

    Producer<String, String> producer = new KafkaProducer<>(props);

    String topic = "kafeidou";

    for (long nEvents = 0; nEvents < events; nEvents++) {
      long runtime = new Date().getTime();
      String ip = "192.168.2." + rnd.nextInt(255);
      String msg = runtime + ",www.example.com," + ip;
      System.out.println(msg);
      ProducerRecord<String, String> data = new ProducerRecord<String, String>(topic, ip, msg);
      producer.send(data,
          new Callback() {
            public void onCompletion(RecordMetadata metadata, Exception e) {
              if(e != null) {
                e.printStackTrace();
              } else {
                System.out.println("The offset of the record we just sent is: " + metadata.offset());
              }
            }
          });
    }
    System.out.println("send message done");
    producer.close();
    System.exit(-1);
  }
}

```  
3. 消费者代码  
consumer.java  
```
import java.util.Arrays;
import java.util.Properties;
import org.apache.kafka.clients.consumer.Consumer;
import org.apache.kafka.clients.consumer.ConsumerConfig;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.apache.kafka.clients.consumer.ConsumerRecords;
import org.apache.kafka.clients.consumer.KafkaConsumer;
import org.apache.kafka.common.serialization.StringDeserializer;

public class HelloWorldConsumer2 {

  public static void main(String[] args) {
    Properties props = new Properties();

    props.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, "192.168.1.60:9092");
    props.put(ConsumerConfig.GROUP_ID_CONFIG ,"kafeidou_group") ;
    props.put(ConsumerConfig.ENABLE_AUTO_COMMIT_CONFIG, "true");
    props.put(ConsumerConfig.AUTO_COMMIT_INTERVAL_MS_CONFIG, "1000");
    props.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class);
    props.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class);
    props.put("auto.offset.reset", "earliest");

    Consumer<String, String> consumer = new KafkaConsumer<>(props);
    consumer.subscribe(Arrays.asList("kafeidou"));

    while (true) {
      ConsumerRecords<String, String> records = consumer.poll(1000);
      for (ConsumerRecord<String, String> record : records) {
        System.out.printf("offset = %d, key = %s, value = %s%n", record.offset(), record.key(), record.value());
      }
    }
  }
}
```  
4. 分别运行生产者和消费者即可  
生产者打印消息  
```
1581651496176,www.example.com,192.168.2.219
1581651497299,www.example.com,192.168.2.112
1581651497299,www.example.com,192.168.2.20
```
消费者打印消息
```
offset = 0, key = 192.168.2.202, value = 1581645295298,www.example.com,192.168.2.202
offset = 1, key = 192.168.2.102, value = 1581645295848,www.example.com,192.168.2.102
offset = 2, key = 192.168.2.63, value = 1581645295848,www.example.com,192.168.2.63
```
源码地址:[FISHStack/kafka-demo](https://github.com/FISHStack/kafka-demo)  

## 通过docker-compose部署kafka  
首先创建一个docker-compose.yml文件
```
version: '3.7'
services:
  zookeeper:
    image: wurstmeister/zookeeper
    volumes:
      - ./data:/data
    ports:
      - 2182:2181
       
  kafka9094:
    image: wurstmeister/kafka
    ports:
      - 9092:9092
    environment:
      KAFKA_BROKER_ID: 0
      KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://192.168.1.60:9092
      KAFKA_CREATE_TOPICS: "kafeidou:2:0"   #kafka启动后初始化一个有2个partition(分区)0个副本名叫kafeidou的topic 
      KAFKA_ZOOKEEPER_CONNECT: zookeeper:2181
      KAFKA_LISTENERS: PLAINTEXT://0.0.0.0:9092
    volumes:
      - ./kafka-logs:/kafka
    depends_on:
      - zookeeper
```  

部署起来很简单,在``docker-compose.yml``文件的目录下执行``docker-compose up -d``就可以了,测试方式和上面的一样。  
这个docker-compose做的东西比上面docker方式部署的东西要多一些  
1. 数据持久化，在当前目录下挂在了两个目录分别存储zookeeper和kafka的数据,当然在``docker run ``命令中添加 ``-v 选项``也是可以做到这样的效果的  
2. kafka在启动后会初始化一个有分区的topic,同样的,``docker run``的时候添加`` -e KAFKA_CREATE_TOPICS=kafeidou:2:0 ``也是可以做到的。

## 总结:优先推荐docker-compose方式部署    
为什么呢?  

因为单纯使用docker方式部署的话，如果有改动(例如:修改对外开放的端口号)的情况下,docker需要把容器停止``docker stop 容器ID/容器NAME``,然后删除容器``docker rm 容器ID/容器NAME``,最后启动新效果的容器``docker run ...``  

而如果在docker-compose部署的情况下如果修改内容只需要修改docker-compose.yml文件对应的地方,例如``2181:2181改成2182:2182``,然后再次在docker-compose.yml文件对应的目录下执行``docker-compose up -d``就能达到更新后的效果。  