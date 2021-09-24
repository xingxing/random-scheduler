# build stage
FROM golang:1.16-alpine as backend
RUN apk add --update --no-cache bash ca-certificates curl git make tzdata

WORKDIR /random-scheduler

COPY go.mod .
COPY go.sum .
RUN go mod download
COPY . .
RUN make build

FROM alpine:3.7
COPY --from=backend /usr/share/zoneinfo/ /usr/share/zoneinfo/
COPY --from=backend /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=backend /random-scheduler/build/scheduler /bin

ENTRYPOINT ["/bin/scheduler"]
