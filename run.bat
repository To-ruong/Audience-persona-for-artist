@echo off
chcp 65001 > nul
setlocal EnableDelayedExpansion

:: 0. KIỂM TRA VÀ CÀI ĐẶT MÔI TRƯỜNG PYTHON
if not exist "venv\Scripts\python.exe" (
    :: Kiểm tra Python hệ thống, nếu chưa có thì cài đặt ẩn qua winget
    python --version >nul 2>&1
    if !errorlevel! neq 0 (
        winget install -e --id Python.Python.3.11 --accept-package-agreements --accept-source-agreements --silent >nul 2>&1
        set "PATH=%PATH%;%~dp0python\;%~dp0python\Scripts\"
    )
    
    :: Tạo môi trường ảo tên là "venv"
    python -m venv venv >nul 2>&1
    
    :: Kích hoạt, nâng cấp pip và cài đặt thư viện
    call "venv\Scripts\activate.bat" >nul 2>&1
    python -m pip install --upgrade pip >nul 2>&1
    pip install pandas requests >nul 2>&1
    
    :: Thoát kích hoạt để không ảnh hưởng luồng bên dưới
    call "venv\Scripts\deactivate.bat" >nul 2>&1
)

:: 1. Lấy tháng hiện tại
for /f %%i in ('powershell -NoProfile -Command "(Get-Date).ToString('MM')"') do set "current_month=%%i"

set "history_file=last_run.txt"

:: 2. Kiểm tra file lịch sử
if exist "%history_file%" (
    set /p last_month=<"%history_file%"
) else (
    set "last_month=00"
)

:: Khử khoảng trắng
set "current_month=%current_month: =%"
set "last_month=%last_month: =%"

echo Current Month: %current_month%
echo Last Month   : %last_month%

:: 3. So sánh tháng
if /I "!current_month!"=="!last_month!" (
    goto open_powerbi
)

echo new cycle

:: 4. Chạy các file Python tuần tự sử dụng môi trường ảo venv
echo running file 01...
venv\Scripts\python.exe 01_top2000.py
if errorlevel 1 (
    echo error: 01_top2000.py
    pause
    exit /b 1
)

echo running file 02...
venv\Scripts\python.exe 02_lastfm.py
if errorlevel 1 (
    echo error: 02_lastfm.py
    pause
    exit /b 1
)

echo running file 03...
venv\Scripts\python.exe 03_merge.py
if errorlevel 1 (
    echo error: 03_merge.py
    pause
    exit /b 1
)

:: Cập nhật tháng mới
echo %current_month%>"%history_file%"

:open_powerbi
echo running Power BI and Refresh...
start "" wscript.exe "refresh_powerbi.vbs"

pause