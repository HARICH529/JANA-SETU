@echo off
echo ========================================
echo Clearing ML Model Cache (Force Fresh Downloads)
echo ========================================

echo Clearing Hugging Face cache...
rmdir /s /q "%USERPROFILE%\.cache\huggingface" 2>nul
rmdir /s /q "%USERPROFILE%\.cache\transformers" 2>nul
rmdir /s /q "%USERPROFILE%\.cache\torch" 2>nul

echo Clearing pip cache...
pip cache purge

echo Clearing temporary ML cache directories...
rmdir /s /q "%TEMP%\hf_cache*" 2>nul
rmdir /s /q "%TEMP%\torch_cache*" 2>nul
rmdir /s /q "%TEMP%\transformers_cache*" 2>nul

echo Clearing F drive cache (if exists)...
rmdir /s /q "F:\ml-cache" 2>nul

echo ========================================
echo ML Cache cleared successfully!
echo Models will be downloaded fresh on next run
echo ========================================
pause