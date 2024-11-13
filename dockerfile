# Use the official Python image from the Docker Hub as the base image
FROM python:3.11-slim

# Set environment variables to avoid writing .pyc files and ensure unbuffered output
ENV PYTHONUNBUFFERED 1
ENV PYTHONDONTWRITEBYTECODE 1

# Set the working directory inside the container
WORKDIR /app

# Copy the requirements.txt first to optimize Docker layer caching
COPY requirements.txt /app/

# Install the dependencies from requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code into the container
COPY . /app/

# Expose the port that Django will run on
EXPOSE 8000

# Apply database migrations and start the Django server
# You can use `CMD` or `ENTRYPOINT` to run the Django development server
# in production, it is recommended to use a WSGI server like Gunicorn
CMD ["sh", "-c", "python manage.py migrate && python manage.py runserver 0.0.0.0:8000"]
