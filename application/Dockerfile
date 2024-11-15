# Use the official Python image from the Docker Hub
FROM python:3.9-slim

# Set the working directory
WORKDIR /app

# Copy the required files
COPY app.py .

# Install Flask
RUN pip install Flask

# Expose the port number
EXPOSE 8080

# Command to run the application
CMD ["python", "app.py"]