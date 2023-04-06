# liangyuanpeng.github.io
<!-- [![Build Status](https://travis-ci.com/liangyuanpeng/liangyuanpeng.github.io.svg?branch=source)](https://travis-ci.com/liangyuanpeng/liangyuanpeng.github.io) -->
Hi, I'm lanLiang, 梁远鹏的博客.    

https://liangyuanpeng.com


博客使用Hugo搭建,托管于Cloudflare Pages.

# git 子模块命令相关  

git clone <repository> --recursive #递归的方式克隆整个项目
git submodule add <repository> <path> #添加子模块
#示例：git submodule add https://github.com/c-ares/c-ares.git  third_party/cares/cares -b cares-1_12_0
 
git submodule init #初始化子模块
git submodule update --init --recursive #初始化并更新子模块
git submodule foreach git pull      #拉取所有子模块
git pull --recurse-submodules  #拉取所有子模块中的依赖项
git submodule sync  #将新的URL同步更新，该步骤适用于git submodule add或修改.gitmodules文件之后
git submodule status third_party/ModuleA    #查看子模块状态，即该子模块切入的提交节点位置，即某HASH值
 
# 删除子模块,然后删除对应资源库所有文件  

git rm --cached ModuleA
rm -rf moduleA
 
git submodule set-url third_party/ModuleA https://XXX.git #，更新子模块URL，该功能在1.8.3.1以上版本
git submodule set-branch --branch dev third_party/ModuleA   #设置子模块项目采用的分支，该功能在1.8.3.1以上版本
