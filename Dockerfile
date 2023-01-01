FROM node:16.18.1-alpine

WORKDIR /opt/app

COPY . /opt/app

RUN npm install

EXPOSE 8080

CMD [ "npm", "start" ]