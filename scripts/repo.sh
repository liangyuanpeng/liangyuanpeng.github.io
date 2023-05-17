#!/bin/bash
echo "github events"

COMMENT=${COMMENT:-""}
COMMENT_URL=${COMMENT_URL:-""}
GH_EVENT=${GH_EVENT:-""}
SLACK_WEBHOOK=${SLACK_WEBHOOK:-""}

#echo "GH_EVENT:\n"$GH_EVENT

echo "======================"


if [ -z "$COMMENT" ];then
    echo "Have not COMMENT,exit..."
    exit -1
fi

if [ -z "$COMMENT_URL" ];then
    echo "Have not COMMENT_URL ,exit..."
    exit -1
fi

if [ -z "$SLACK_WEBHOOK" ];then
    echo "Have not SLACK_WEBHOOK ,exit..."
    exit -1
fi

# Find command of "/orasbins" from issue comment
while read -r line; do
  line=$(echo $line | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

  if [[ -z "$line" || "${line:0:1}" == "#" ]]; then
    continue
  fi

  if [[ "$line" == "/orasbins" ]]; then
    echo "Matching /orasbins ..."
    break
  fi
done <<< "$COMMENT"

function sendMessageToSlackWebhook(){

  DISCUSSION_TITLE=$(echo $GH_EVENT | jq .discussion.title | sed 's/\"//g' )
  DISCUSSION_URL=$(echo $GH_EVENT | jq .discussion.html_url | sed 's/\"//g' )
  DISCUSSION_BODY=$(echo $GH_EVENT | jq .discussion.body  | sed 's/\"//g')
  COMMENT_USER=$(echo $GH_EVENT | jq .comment.user.login  | sed 's/\"//g')

  TEXT="{\"text\":\"Have a new blog comment:\nDISCUSSION_TITLE:  $DISCUSSION_TITLE\n COMMENT_USER:  https://github.com/$COMMENT_USER\nCOMMENT_URL:  $COMMENT_URL \n \"}"
  # 太复杂的目前会失败 https://github.com/liangyuanpeng/liangyuanpeng.github.io/discussions/367#discussioncomment-5923444
#  TEXT="{\"text\":\"Have a new blog comment:\nDISCUSSION_TITLE:  $DISCUSSION_TITLE\n COMMENT_USER:  $COMMENT_USER\nCOMMENT_URL:  $COMMENT_URL \n---\nCOMMENT:\n$COMMENT \"}"
  # 使用 curl 命令向 Slack 发布消息
#  echo $TEXT
  curl -X POST -H 'Content-type: application/json' --data "${TEXT}" $SLACK_WEBHOOK
}

sendMessageToSlackWebhook
