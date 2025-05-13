EXECUTABLE=kbot
APP=$(shell basename $(shell git remote get-url origin))
REGISTRY=hosterzzz
#VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)
VERSION=v1.0.7
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

macos: TARGETOS=darwin
macos: TARGETARCH=arm64
macos: $(DARWIN)

arm: TARGETOS=linux
arm: TARGETARCH=arm64
arm: $(ARM)

$(WINDOWS): format get
	env CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -v -o $(WINDOWS) -ldflags "-X="github.com/dev/vasyliev/kbot/cmd.appVersion=${VERSION}

$(LINUX): format get
	env CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -v -o $(LINUX) -ldflags "-X="github.com/dev/vasyliev/kbot/cmd.appVersion=${VERSION}

$(DARWIN): format get
	env CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -v -o $(DARWIN) -ldflags "-X="github.com/dev/vasyliev/kbot/cmd.appVersion=${VERSION}

$(ARM): format get
	env CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -v -o $(ARM) -ldflags "-X="github.com/dev/vasyliev/kbot/cmd.appVersion=${VERSION}

image:
	docker build . -t ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH} --build-arg TARGETOS=${TARGETOS} --build-arg TARGETARCH=${TARGETARCH}

push:
	docker push ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH}

clean:
	rm -f $(WINDOWS) $(LINUX) $(DARWIN) $(ARM)