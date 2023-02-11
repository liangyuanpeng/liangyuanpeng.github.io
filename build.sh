#/bin/sh

cd content/files
tar -czf k8s-admissionregistration-with-cel.tar.gz k8s-admissionregistration-with-cel
ls
pwd
cd bin 
wget https://github.worker.liangyuanpeng.com/oras-project/oras/releases/download/v0.16.0/oras_0.16.0_windows_amd64.zip
wget https://github.worker.liangyuanpeng.com/oras-project/oras/releases/download/v0.16.0/oras_0.16.0_darwin_amd64.tar.gz
wget https://github.worker.liangyuanpeng.com/oras-project/oras/releases/download/v0.16.0/oras_0.16.0_linux_amd64.tar.gz
wget https://github.worker.liangyuanpeng.com/oras-project/oras/releases/download/v0.16.0/oras_0.16.0_linux_arm64.tar.gz
ls