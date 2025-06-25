FROM --platform=$BUILDPLATFORM quay.io/projectquay/golang:1.23 AS builder
#ARG TARGETPLATFORM
#ARG BUILDPLATFORM
#ARG TARGETOS
#ARG TARGETARCH

#ENV CGO_ENABLED=0
#ENV GOOS=${TARGETOS}
#ENV GOARCH=${TARGETARCH}


WORKDIR /app

COPY . .

ARG TARGETARCH
RUN make build TARGETARCH=$TARGETARCH

#RUN go install github.com/jstemmer/go-junit-report/v2@latest \
#    && go install gotest.tools/gotestsum@latest \
#    && go install github.com/axw/gocov/gocov@latest \
#    && go install github.com/AlekSi/gocov-xml@latest

FROM cgr.dev/chainguard/go
WORKDIR /app

COPY --from=builder /app /app

ENTRYPOINT ["ash"]
