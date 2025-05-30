# Base builder image with platform support
FROM --platform=$BUILDPLATFORM quay.io/projectquay/golang:1.23 AS builder

# Platform arguments
ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG TARGETOS
ARG TARGETARCH

# Set environment variables for cross-compilation
ENV CGO_ENABLED=0
ENV GOOS=${TARGETOS}
ENV GOARCH=${TARGETARCH}

WORKDIR /app

# Install test tools first for better layer caching
RUN go install github.com/jstemmer/go-junit-report/v2@latest \
    && go install gotest.tools/gotestsum@latest \
    && go install github.com/axw/gocov/gocov@latest \
    && go install github.com/AlekSi/gocov-xml@latest

# Copy go.mod and go.sum first (if they exist)
COPY go.* ./
RUN if [ -f go.mod ]; then go mod download; fi

# Copy the rest of the code
COPY . .

# Create a test target
FROM builder AS tester
CMD ["sh", "-c", "gotestsum --junitfile=/app/test-results/unit-tests.xml -- -coverprofile=/app/test-results/coverage.out ./... && \
      gocov convert /app/test-results/coverage.out | gocov-xml > /app/test-results/coverage.xml && \
      mkdir -p /app/test-results && cat /app/test-results/unit-tests.xml && cat /app/test-results/coverage.xml"]

# Build target - can be used to create the final binary
FROM builder AS build
RUN go build -o /app/bin/app .

# Final image - minimal runtime
FROM cgr.dev/chainguard/go AS runtime
WORKDIR /app
COPY --from=build /app/bin/app /app/bin/app
ENTRYPOINT ["/app/bin/app"]