FROM node:16.3.0-alpine
ARG TOKEN
# setup enviroment
RUN npm install -g coffeescript@2.6.1
RUN apk add --no-cache ffmpeg
COPY ./ .
RUN npm install
CMD ["coffee", "index.coffee"]

