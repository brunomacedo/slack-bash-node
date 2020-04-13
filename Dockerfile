FROM node:alpine

WORKDIR /app

COPY . .

RUN apk update; \
    apk add --no-cache \
      bash \
      tcpdump \
      jq \
      vim \
      curl \
      tzdata \
    ;

ENV TZ Brazil/East

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN npm install

EXPOSE 8080

CMD sh request.sh; npm start
