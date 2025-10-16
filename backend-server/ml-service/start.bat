@echo off
echo Starting ML Classification Microservice...

echo Setting cache directories to F drive...
mkdir F:\ml-cache\huggingface 2>nul
mkdir F:\ml-cache\torch 2>nul
mkdir F:\ml-cache\transformers 2>nul

set HF_HOME=F:\ml-cache\huggingface
set HUGGINGFACE_HUB_CACHE=F:\ml-cache\huggingface
set TORCH_HOME=F:\ml-cache\torch
set TRANSFORMERS_CACHE=F:\ml-cache\transformers

echo Cache directories set to F drive

echo Installing Python dependencies...
pip install -r requirements.txt

echo Starting FastAPI ML Service...
start "ML Service" python app.py

echo Starting Worker...
start "ML Worker" python worker.py

echo ML Microservice started!
echo ML Service: http://localhost:8000
echo Worker: Processing jobs from Redis queue
echo Cache location: F:\ml-cache
pause