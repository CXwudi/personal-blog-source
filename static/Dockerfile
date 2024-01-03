# Use an official Node runtime as a parent image
FROM node:alpine

# Set the working directory in the container to /app
WORKDIR /app

# Install cli-real-favicon globally
RUN npm install -g cli-real-favicon

# Run cli-real-favicon when the container launches
CMD ["real-favicon"]