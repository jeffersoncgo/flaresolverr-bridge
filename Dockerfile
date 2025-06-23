# Use a lightweight Node.js image
FROM node:20-alpine

# Set work directory
WORKDIR /app

# 👇 Install dependencies (including curl)
RUN apk add --no-cache curl

# Copy files
COPY package*.json ./
RUN npm install

COPY . .

# Set bridge port (if different, adjust)
EXPOSE 3000

CMD ["npm", "start"]
