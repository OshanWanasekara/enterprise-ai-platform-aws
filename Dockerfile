# 1. Base image
FROM python:3.12-slim

# 2. Set working directory
WORKDIR /app

# 3. Copy requirements
COPY requirements.txt .

# 4. Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# 5. Copy application source code
COPY app/ ./app/

# 6. Create non-root application user
RUN useradd --create-home --uid 10001 appuser \
    && chown -R appuser:appuser /app

# 7. Run application as non-root
USER appuser

# 8. Application port
EXPOSE 8000

# 9. Start FastAPI
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
