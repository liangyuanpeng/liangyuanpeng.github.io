build:
	hugo
	sh build.sh

push:
	git push origin source

pull:
	git pull origin sourcesa
