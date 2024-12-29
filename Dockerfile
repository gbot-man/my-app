# syntax=docker/dockerfile:1

# Specify the Python version
ARG PYTHON_VERSION=3.12.8
FROM python:${PYTHON_VERSION}-slim as base

# Prevent Python from writing .pyc files and enable unbuffered output for better logging
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# Create a non-privileged user to run the application
ARG UID=10001
RUN adduser --disabled-password --gecos "" --home "/nonexistent" --shell "/sbin/nologin" --no-create-home --uid "${UID}" appuser

# Install dependencies with cache optimization
# The --mount=type=bind will bind mount the local requirements.txt into the container.
# Ensure the `requirements.txt` exists in the context where the build command is executed.
RUN --mount=type=cache,target=/root/.cache/pip \
    --mount=type=bind,source=requirements.txt,target=/app/requirements.txt \
    python -m pip install -r /app/requirements.txt

# Switch to the non-privileged user for better security
USER appuser

# Copy the application code into the container
COPY . /app

# Expose the port the application listens on
EXPOSE 3000

# Define the command to run the app (replace with actual app command)
CMD ["python", "app.py"]
