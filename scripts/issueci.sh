#!/bin/bash

#echo "==========================="
#env
#echo "==========================="

# issuenumber author title body type(opened|edited)


function labelIssue(){
  # params:
  # issuenumber labels
  # "comments,utterances"
  gh issue edit $1 -R liangyuanpeng/liangyuanpeng.github.io --add-label $2
}

function commentIssue(){
  gh issue comment $1 --body "如果本文对你很有用欢迎对本文评论,
  ---
  如果你有不一样的使用场景也欢迎投稿更新到本文当中来.
  ---
  如果你不方便评论也可以对本评论:+1:+1
  ---"
}

json=`cat event.json`
#echo "json:" "$json"

number=$(jq .issue.number <<< "$json")
title=$(jq .issue.title <<< "$json")
author=$(jq .issue.user.login <<< "$json")
body=$(jq .issue.user.body <<< "$json")
eventtype=$(jq .action <<< "$json")

echo "number: $number"
echo "title: $title"
echo "login: $author"
echo "body: $body"
echo "eventtype:"$eventtype

if [ "$author" == "utterances-bot" ];then
  if [ "$eventtype" == "opened" ];then
    labelIssue $number "comments,utterances"
#    commentIssue $1
  fi
fi

issuetitle=`echo $title | sed 's/ *$//'`

subTitle="liangyuanpeng's Blog"

length=${#issuetitle}

if [ $length -gt 20 ]; then  # 长度大于 10 小于 20
  title_last=${issuetitle: -20}
  if [ "$title_last" == "$subTitle" ]; then
      if [ "$author" != "liangyuanpeng" -a "$author" != "utterances-bot" ];then
        echo "valid title:"$issuetitle
        newtitle=$issuetitle"-valid title"
        echo $newtitle
        gh issue edit $1 --title "$newtitle" -R liangyuanpeng/liangyuanpeng.github.io
      fi
  fi
fi