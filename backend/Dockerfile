FROM node:20

WORKDIR /app

COPY . .

RUN npm install

EXPOSE 8000

CMD ["bash", "-c", "cd src && npx drizzle-kit push && cd .. && npm run dev"]
