# syntax=docker/dockerfile:latest
FROM alpine as tools
ARG GOSU_VERSION=1.14
ARG GOCRON_VERSION=0.0.5
WORKDIR /app
RUN wget -qO gosu https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-amd64; \
  wget -qO - https://github.com/ivoronin/go-cron/releases/download/v${GOCRON_VERSION}/go-cron_${GOCRON_VERSION}_linux_amd64.tar.gz | tar -xvzf - go-cron; \
  chmod +x *


FROM node:17-alpine
ARG GIT_SHA
ARG VERSION
LABEL MAINTAINER pratikbin
LABEL org.opencontainers.image.title=restake
LABEL org.opencontainers.image.base.name=node:17-alpine
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.revision=${GIT_SHA}
LABEL org.opencontainers.image.description="REStake allows delegators to grant permission for a validator to compound their rewards, and provides a script validators can run to find their granted delegators and send the compounding transactions automatically."
LABEL org.opencontainers.image.source=https://github.com/eco-stake/restake
LABEL org.opencontainers.image.documentation=https://github.com/eco-stake/restake
COPY --from=tools /app/ /bin/
WORKDIR /usr/src/app
COPY package*.json ./
RUN --mount=type=cache,target=/root/.npm npm install
COPY . ./
ENV DIRECTORY_PROTOCOL=https
ENV DIRECTORY_DOMAIN=cosmos.directory
ENV NODE_ENV=development
ENV GID='0'
ENV UID='0'
ENV CRON='0/15 * * * *'
ENV MODE='dryrun'
ENTRYPOINT gosu "$UID:$GID" go-cron "$CRON" npm run $MODE $CHAINS
