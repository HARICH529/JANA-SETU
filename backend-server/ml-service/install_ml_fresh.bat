@echo off
echo Installing ML dependencies fresh (no cache)...

echo Clearing any cached models and pip cache...
rmdir /s /q "%USERPROFILE%\.cache\huggingface" 2>nul
rmdir /s /q "%USERPROFILE%\.cache\torch" 2>nul
rmdir /s /q "%USERPROFILE%\.cache\transformers" 2>nul
pip cache purge

echo Setting environment variables to force fresh downloads...
set HF_HUB_DISABLE_SYMLINKS_WARNING=1
set HF_HUB_DISABLE_PROGRESS_BARS=1
set TRANSFORMERS_OFFLINE=0
set HF_HUB_CACHE=%TEMP%\hf_cache_temp
set TORCH_HOME=%TEMP%\torch_cache_temp
set TRANSFORMERS_CACHE=%TEMP%\transformers_cache_temp

echo Installing Python dependencies without cache...
pip install --no-cache-dir --force-reinstall fastapi uvicorn
pip install --no-cache-dir --force-reinstall torch torchvision --index-url https://download.pytorch.org/whl/cpu
pip install --no-cache-dir --force-reinstall transformers
pip install --no-cache-dir --force-reinstall pillow requests pydantic pymongo librosa numpy python-multipart

echo ML dependencies installed fresh!
echo Models will be downloaded fresh on first run.
pause