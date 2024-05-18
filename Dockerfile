FROM node:14

WORKDIR /app

COPY package*.json ./

RUN npm install

RUN npm i sequelize-cli

COPY . .

RUN npx sequelize db:migrate

EXPOSE 5000

CMD [ "npm", "start" ]

