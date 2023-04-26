#!/bin/bash

# cd content/files
# tar -czf k8s-admissionregistration-with-cel.tar.gz k8s-admissionregistration-with-cel
# cd bin 
# wget https://github.worker.liangyuanpeng.com/oras-project/oras/releases/download/v0.16.0/oras_0.16.0_windows_amd64.zip
# wget https://github.worker.liangyuanpeng.com/oras-project/oras/releases/download/v0.16.0/oras_0.16.0_darwin_amd64.tar.gz
# wget https://github.worker.liangyuanpeng.com/oras-project/oras/releases/download/v0.16.0/oras_0.16.0_linux_amd64.tar.gz
# wget https://github.worker.liangyuanpeng.com/oras-project/oras/releases/download/v0.16.0/oras_0.16.0_linux_arm64.tar.gz
# wget --no-check-certificate https://github.worker.liangyuanpeng.com/oras-project/oras/releases/download/v0.16.0/oras_0.16.0_linux_amd64.tar.gz
# ls
# tar -xf oras_0.16.0_linux_amd64.tar.gz
# rm LICENSE

# wget https://github.com/kubernetes-sigs/kind/releases/download/v0.17.0/kind-linux-amd64
# mv kind-linux-amd64 kind-0.17
# chmod +x kind-0.17

# wget https://github.com/oras-project/oras/releases/download/v0.16.0/oras_0.16.0_linux_amd64.tar.gz
# tar -xf oras_0.16.0_linux_amd64.tar.gz
# rm -f oras_0.16.0_linux_amd64.tar.gz
# rm -f LICENSE
# ./oras

# https://github.com/kubernetes-sigs/krew/releases/download/v0.4.3/krew-linux_amd64.tar.gz
# https://github.com/kubernetes-sigs/krew/releases/download/v0.4.3/krew-darwin_arm64.tar.gz
# ls


if [ $BASEURL ];then
    echo "==============begin update baseurl=============="
	echo "BASEURL = $BASEURL"
    sed "s/#{baseurl}/$BASEURL/g" config.toml -i
    sed 's/#baseurl/baseurl/g' config.toml -i
     echo "==============end update baseurl=============="
else
	echo "BASEURL IS NOT EXISTS"
fi

if [ $ORASDOWNLOAD ];then
	echo "ORASURL = $ORASDOWNLOAD"
    wget https://github.com/oras-project/oras/releases/download/v1.0.0/oras_1.0.0_linux_amd64.tar.gz
    tar -xf oras_1.0.0_linux_amd64.tar.gz
    mv ./oras static/ && cd static
    pwd
    nohup ./oras pull ghcr.io/liangyuanpeng/files:kind &
    nohup ./oras pull ghcr.io/liangyuanpeng/files:pack &
    ./oras pull ghcr.io/liangyuanpeng/files:krew
    cd ..
fi

cat config.toml
hugo

echo "======================read env begin======================="
env
echo "======================read env end======================="
