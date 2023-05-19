# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2021-present Kaleidos Ventures SL

FROM node:18 AS taiga-compiler
WORKDIR /npm-files
COPY package.json /npm-files
COPY package-lock.json /npm-files
RUN npm install
RUN npm install gulp

WORKDIR /build
RUN mv /npm-files/node_modules /npm-files/package.json .

# Apparently copying every part of the app separately improves caching
# And also apparently you can't copy folders in a multi-copy command
COPY .babelrc .stylelintrc.js coffeelint.json csslintrc.json \
     gulpfile.js gulp-utils.js locales.js elements.js /build/
COPY app-loader /build/app-loader
COPY conf /build/conf
COPY extras /build/extras
COPY emojis /build/emojis
COPY app /build/app

RUN npm run start deploy

FROM nginx:1.23-alpine
LABEL maintainer="support@taiga.io"

COPY docker/default.conf /etc/nginx/conf.d/default.conf
COPY docker/config_env_subst.sh /docker-entrypoint.d/30_config_env_subst.sh

RUN set -eux; \
    apk update; \
    apk add --no-cache --virtual .build-deps subversion; \
    apk add bash ; \
    chmod +x /docker-entrypoint.d/30_config_env_subst.sh; \
    # Install taiga-front contribs
    mkdir -p /usr/share/nginx/html/plugins; \
    cd /usr/share/nginx/html/plugins; \
    svn export "https://github.com/kaleidos-ventures/taiga-contrib-slack/tags/6.6.0/front/dist" "slack"; \
    svn export "https://github.com/kaleidos-ventures/taiga-contrib-github-auth/tags/6.6.0/front/dist" "github-auth"; \
    svn export "https://github.com/kaleidos-ventures/taiga-contrib-gitlab-auth/tags/6.6.0/front/dist" "gitlab-auth"; \
    cd /; \
    apk del --no-cache .build-deps

COPY --from=taiga-compiler /build/dist/ /usr/share/nginx/html/
COPY docker/conf.json.template /usr/share/nginx/html
