#!/bin/bash

mkdir -p cni
sudo chmod -R 777 cni
if [ ! -f cni/vlan ]; then
  if [ ! -f cni-plugins-linux-amd64-v1.2.0.tgz ];then
    curl -O -L https://github.com/containernetworking/plugins/releases/download/v1.2.0/cni-plugins-linux-amd64-v1.2.0.tgz
  fi
  tar -C cni -xzf cni-plugins-linux-amd64-v1.2.0.tgz
fi