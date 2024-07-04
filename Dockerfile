FROM node:20 AS builder

WORKDIR /app

COPY . .

WORKDIR /app/boltz-web-app
RUN npm ci

ENV NETWORK=mainnet

RUN npm run $NETWORK
RUN npm run build

FROM nginx:alpine AS final

COPY --from=builder /app/boltz-web-app/dist /usr/share/nginx/html

#COPY nginx.conf /etc/nginx/conf.d/default.conf

ADD ./docker_entrypoint.sh /usr/local/bin/docker_entrypoint.sh
RUN chmod a+x /usr/local/bin/docker_entrypoint.sh

EXPOSE 80

