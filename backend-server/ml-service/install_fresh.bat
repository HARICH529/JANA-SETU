@echo off
echo Installing ML dependencies fresh (no cache)...

echo Clearing pip cache...
pip cache purge

echo Installing Python dependencies without cache...
pip install --no-cache-dir -r requirements.txt

echo Setting environment variables to disable model caching...
set HF_HUB_DISABLE_SYMLINKS_WARNING=1
set HF_HUB_DISABLE_PROGRESS_BARS=1
set TRANSFORMERS_OFFLINE=0

echo ML dependencies installed fresh!
echo Models will be downloaded fresh on first run.
pause