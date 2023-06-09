FROM golang:1.20.1

ARG DOCKER_ARG_VERSION
ARG DOCKER_ARG_REV
ARG DOCKER_ARG_BRANCH
ARG DOCKER_ARG_BUILD_USER

COPY . /opt/data
WORKDIR /opt/data

RUN make linux-from-docker DOCKER_ARG_VERSION="$DOCKER_ARG_VERSION" DOCKER_ARG_REV="$DOCKER_ARG_REV" DOCKER_ARG_BRANCH="$DOCKER_ARG_BRANCH" DOCKER_ARG_BUILD_USER="$DOCKER_ARG_BUILD_USER"

#########################################################################################

FROM gcr.io/distroless/base
COPY --from=0 /opt/data/build/linux/gokv /usr/bin/gokv 

ENV ENVIRONMENT "development"
# development | production

WORKDIR /usr/bin

EXPOSE 8080

CMD ["gokv"]
