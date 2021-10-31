FROM node:16.3.0-buster-slim
ARG TOKEN
# setup enviroment
RUN npm install -g coffeescript@2.6.1
COPY ./ .
RUN npm install
CMD ["coffee", "index.coffee"]

