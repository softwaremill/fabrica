FROM node:14-alpine

# Yeoman needs the use of a home directory for caching and certain config storage.
ENV HOME /home/yeoman

RUN apk add --no-cache sudo
# Add a yeoman user because Yeoman freaks out and runs setuid(501).
# This was because less technical people would run Yeoman as root and cause problems.
# Setting uid to 501 here since it's already a random number being thrown around.
# @see https://github.com/yeoman/yeoman.github.io/issues/282
# @see https://github.com/cthulhu666/docker-yeoman/blob/master/Dockerfile
# @see https://github.com/phase2/docker-yeoman/blob/master/Dockerfile
RUN adduser -D -u 501 yeoman && \
  echo "yeoman ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

COPY generators /fabrikka/generators
COPY docs /fabrikka/docs
COPY package.json /fabrikka/
COPY package-lock.json /fabrikka/
COPY samples /fabrikka/samples

#RUN sudo apt-get update
RUN apk add --no-cache curl
#&& apt-get install curl

# Install docker binary
ARG DOCKER_CHANNEL=stable
ARG DOCKER_VERSION=18.06.3-ce
RUN curl -fsSL "https://download.docker.com/linux/static/${DOCKER_CHANNEL}/x86_64/docker-${DOCKER_VERSION}.tgz" \
  | tar -xzC /usr/local/bin --strip=1 docker/docker

# Install docker-compose
ARG DOCKER_COMPOSE_VERSION=1.26.2
RUN curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" \
    -o /usr/local/bin/docker-compose && chmod +x /usr/local/bin/docker-compose

RUN npm install --global --silent yo

RUN sudo chown -R yeoman:yeoman /fabrikka
RUN sudo chown -R yeoman:yeoman /home/yeoman
RUN sudo chown -R yeoman:yeoman /usr/local/lib/node_modules
USER yeoman

WORKDIR /fabrikka

RUN npm install
RUN npm link

WORKDIR /fabrikka/samples

RUN yo --no-insight fabrikka:setup-compose fabrikkaConfig-1org-1channel-1chaincode.json

USER root

RUN chmod +x *.sh

CMD ["sh"]
