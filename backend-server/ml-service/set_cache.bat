@echo off
echo Setting ML cache to F drive...

mkdir F:\ml-cache\huggingface
mkdir F:\ml-cache\torch  
mkdir F:\ml-cache\transformers

set HF_HOME=F:\ml-cache\huggingface
set HUGGINGFACE_HUB_CACHE=F:\ml-cache\huggingface
set TORCH_HOME=F:\ml-cache\torch
set TRANSFORMERS_CACHE=F:\ml-cache\transformers

echo Cache directories set to F drive
echo HF_HOME=%HF_HOME%
echo TORCH_HOME=%TORCH_HOME%
echo TRANSFORMERS_CACHE=%TRANSFORMERS_CACHE%

echo Starting ML service with F drive cache...
python app.py