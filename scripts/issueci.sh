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

echo "issue title:"$3
echo "type:"$5

if [ "$2" == "utterances-bot" ];then
  if [ "$5" == "opened" ];then
    labelIssue $1 "comments,utterances"
#    commentIssue $1
  fi
fi


issuetitletmp=$3
issuetitle=`echo $issuetitletmp | sed 's/ *$//'`

subTitle="liangyuanpeng's Blog"

length=${#issuetitle}

if [ $length -gt 20 ]; then  # 长度大于 10 小于 20
  title_last=${issuetitle: -20}
  if [ "$title_last" == "$subTitle" ]; then
      if [ "$2" != "liangyuanpeng" -a "$2" != "utterances-bot" ];then
        echo "valid title:"$issuetitle
        newtitle=$issuetitle"-valid title"
        echo $newtitle
        gh issue edit $1 --title "$newtitle" -R liangyuanpeng/liangyuanpeng.github.io
      fi
  fi
fi

