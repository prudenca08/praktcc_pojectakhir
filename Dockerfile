FROM        node:14.17.0-alpine as builder

COPY        package.json /srv/node-posts/
WORKDIR     /srv/node-posts/

RUN         yarn install --production
RUN         yarn add @babel/plugin-transform-runtime

COPY        .babelrc /srv/node-posts/
COPY        .eslintrc.json /srv/node-posts/
COPY        app.js /srv/node-posts/
COPY        adapters /srv/node-posts/adapters/
COPY        application /srv/node-posts/application/
COPY        config /srv/node-posts/config/
COPY        frameworks /srv/node-posts/frameworks/
COPY        src /srv/node-posts/src/

RUN         yarn run build

FROM         node:14.17.0-alpine


ENV         HTTP_MODE http
ARG         NODE_PROCESSES=2
ENV         NODE_PROCESSES=$NODE_PROCESSES

# Install pm2
RUN         npm install -g pm2

# Copy over code
WORKDIR     /srv/api/
COPY        --from=builder /srv/node-posts/build /srv/api/build
COPY        --from=builder /srv/node-posts/package.json /srv/api/package.json

RUN         deluser --remove-home node \
            && addgroup -S node -g 9999 \
            && adduser -S -G node -u 9999 node

CMD         ["npm", "start"]

USER        node