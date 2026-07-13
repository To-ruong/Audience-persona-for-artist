@echo off
chcp 65001 > nul
setlocal EnableDelayedExpansion

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

echo [Thông báo] Phát hiện THÁNG MỚI (%current_month%)! Bắt đầu chạy dữ liệu...

:: 4. Chạy các file Python tuần tự
echo Đang chạy file 01...
python\Scripts\python.exe 01_top2000.py
if errorlevel 1 (
    echo Lỗi ở 01_top2000.py
    pause
    exit /b 1
)

echo Đang chạy file 02...
python\Scripts\python.exe 02_lastfm.py
if errorlevel 1 (
    echo Lỗi ở 02_lastfm.py
    pause
    exit /b 1
)

echo Đang chạy file 03...
python\Scripts\python.exe 03_merge.py
if errorlevel 1 (
    echo Lỗi ở 03_merge.py
    pause
    exit /b 1
)

:: Cập nhật tháng mới
echo %current_month%>"%history_file%"

:open_powerbi
echo Đang kích hoạt Power BI và tự động Refresh...
start "" wscript.exe "refresh_powerbi.vbs"

pause