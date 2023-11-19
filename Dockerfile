# Use the official Node.js image based on Alpine Linux
FROM node:14-alpine

# Set the working directory in the container
WORKDIR /usr/src/app

# Copy package.json and package-lock.json to the working directory
COPY package*.json ./

# Install app dependencies
RUN npm install

# Copy the application code into the container
COPY . .

# Build the React app
RUN npm run build

# Expose the port the app runs on (you might need to adjust this based on your application)
EXPOSE 3000

# Define the command to run your app
CMD ["npm", "start"]
