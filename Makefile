EXECUTABLE=kbot
APP=$(shell basename $(shell git remote get-url origin) | awk '{print $1}')
REGESTRY=hosterzzz
VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)
#VERSION=v1.0.7
WINDOWS=$(EXECUTABLE)_windows_amd64.exe
LINUX=$(EXECUTABLE)_linux_amd64
DARWIN=$(EXECUTABLE)_darwin_amd64
ARM=$(EXECUTABLE)_linux_arm64
#defaults
TARGETOS ?= linux
TARGETARCH ?= amd64

format:
	gofmt -s -w ./

lint:
	golint

test:
	go test -v

get:
	go get

windows: TARGETOS=windows
windows: TARGETARCH=amd64
windows: $(WINDOWS)

linux: TARGETOS=linux
linux: TARGETARCH=amd64
linux: $(LINUX)

darwin: TARGETOS=darwin
darwin: TARGETARCH=arm64
darwin: $(DARWIN)

arm: TARGETOS=linux
arm: TARGETARCH=arm64
arm: $(ARM)

build: format get
	CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -v -ldflags "-X="github.com/hosterzzz/demo1/kbot/cmd.appVersion=${VERSION}

$(WINDOWS): format get
	env CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -v -o $(WINDOWS) -ldflags "-X="github.com/hosterzzz/demo1/kbot/cmd.appVersion=${VERSION}
	docker build --build-arg name=${TARGETOS} -t ${REGESTRY}/${APP}:${VERSION}-${TARGETOS}-${TARGETARCH} .

$(LINUX): format get
	env CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -v -o $(LINUX) -ldflags "-X="github.com/hosterzzz/demo1/kbot/cmd.appVersion=${VERSION}
	docker build --build-arg name=${TARGETOS} -t ${REGESTRY}/${APP}:${VERSION}-${TARGETOS}-${TARGETARCH} .

$(DARWIN): format get
	env CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -v -o $(DARWIN) -ldflags "-X="github.com/hosterzzz/demo1/kbot/cmd.appVersion=${VERSION}
	docker build --build-arg name=${TARGETOS} -t ${REGESTRY}/${APP}:${VERSION}-${TARGETOS}-${TARGETARCH} .

$(ARM): format get
	env CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -v -o $(ARM) -ldflags "-X="github.com/hosterzzz/demo1/kbot/cmd.appVersion=${VERSION}
	docker build --build-arg name=${TARGETOS} -t ${REGESTRY}/${APP}:${VERSION}-${TARGETOS}-${TARGETARCH} .

image:
	docker build . -t ${REGESTRY}/${APP}:${VERSION}-${TARGETOS}-${TARGETARCH} --build-arg TARGETOS=${TARGETOS} --build-arg TARGETARCH=${TARGETARCH}

push:
	docker push ${REGESTRY}/${APP}:${VERSION}-${TARGETOS}-${TARGETARCH}

clean:
	rm -f kbot_*;
	docker rmi ${REGESTRY}/${APP}:${VERSION}-${TARGETOS}-${TARGETARCH}
