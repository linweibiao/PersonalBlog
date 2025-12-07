@echo off
REM 设置控制台编码为UTF-8
chcp 65001 >nul

REM 定义颜色代码
set "COLOR_SUCCESS=0A"  REM 绿色
set "COLOR_INFO=0B"     REM 淡蓝色
set "COLOR_WARNING=0E"  REM 黄色
set "COLOR_ERROR=0C"    REM 红色
set "COLOR_TITLE=0F"    REM 亮白色

REM 输出带颜色的文本
:ECHO_COLOR
set "color=%1"
set "text=%~2"
setlocal enabledelayedexpansion
color %color%
echo %text%
color 07
goto :EOF

REM 检查Python是否安装
:CHECK_PYTHON
set "PYTHON_PATH="
for %%i in (python.exe python3.exe) do (
    where %%i >nul 2>nul
    if !ERRORLEVEL! equ 0 (
        set "PYTHON_PATH=%%i"
        goto :PYTHON_FOUND
    )
)

:PYTHON_NOT_FOUND
call :ECHO_COLOR %COLOR_ERROR% "======================================="
call :ECHO_COLOR %COLOR_ERROR% "       错误：未检测到Python        "
call :ECHO_COLOR %COLOR_ERROR% "======================================="
echo.
call :ECHO_COLOR %COLOR_INFO% "请先安装Python 3.8或更高版本"
call :ECHO_COLOR %COLOR_INFO% "Python下载地址: https://www.python.org/downloads/"
echo.
pause
exit /b 1

:PYTHON_FOUND
call :ECHO_COLOR %COLOR_INFO% "检测到Python: %PYTHON_PATH%"
goto :EOF

REM 检查目录是否存在
:CHECK_DIR
set "DIR_PATH=%~1"
set "DIR_NAME=%~2"

if not exist "%DIR_PATH%" (
    call :ECHO_COLOR %COLOR_ERROR% "======================================="
    call :ECHO_COLOR %COLOR_ERROR% "       错误：%DIR_NAME%目录不存在        "
    call :ECHO_COLOR %COLOR_ERROR% "======================================="
echo.
    call :ECHO_COLOR %COLOR_ERROR% "目录路径: %DIR_PATH%"
echo.
    pause
exit /b 1
)
goto :EOF

REM 主程序开始
call :ECHO_COLOR %COLOR_TITLE% "======================================="
call :ECHO_COLOR %COLOR_TITLE% "      个人博客系统启动脚本      "
call :ECHO_COLOR %COLOR_TITLE% "======================================="
echo.

REM 检查Python是否安装
call :ECHO_COLOR %COLOR_INFO% "正在检查Python环境..."
echo.
call :CHECK_PYTHON

REM 定义服务配置
set "BACKEND_DIR=blog-system\backend"
set "FRONTEND_DIR=blog-system\frontend\dist"
set "BACKEND_TITLE=后端服务"
set "FRONTEND_TITLE=前端服务"
set "BACKEND_URL=http://localhost:5000"
set "FRONTEND_URL=http://localhost:8000"

REM 启动后端服务
echo.
call :ECHO_COLOR %COLOR_TITLE% "======================================="
call :ECHO_COLOR %COLOR_INFO% "正在启动后端服务..."
call :ECHO_COLOR %COLOR_TITLE% "======================================="

REM 检查后端目录是否存在
call :CHECK_DIR "%BACKEND_DIR%" "后端服务"

REM 启动后端服务
start "%BACKEND_TITLE%" cmd /k "cd "%BACKEND_DIR%" && python run.py"
call :ECHO_COLOR %COLOR_SUCCESS% "后端服务已启动，窗口标题: %BACKEND_TITLE%"
call :ECHO_COLOR %COLOR_INFO% "后端服务地址: %BACKEND_URL%"

REM 等待后端服务初始化
call :ECHO_COLOR %COLOR_INFO% "等待后端服务初始化..."
timeout /t 3 /nobreak >nul

REM 启动前端服务
echo.
call :ECHO_COLOR %COLOR_TITLE% "======================================="
call :ECHO_COLOR %COLOR_INFO% "正在启动前端服务..."
call :ECHO_COLOR %COLOR_TITLE% "======================================="

REM 检查前端目录是否存在
call :CHECK_DIR "%FRONTEND_DIR%" "前端服务"

REM 启动前端服务
start "%FRONTEND_TITLE%" cmd /k "cd "%FRONTEND_DIR%" && python run_server.py"
call :ECHO_COLOR %COLOR_SUCCESS% "前端服务已启动，窗口标题: %FRONTEND_TITLE%"
call :ECHO_COLOR %COLOR_INFO% "前端服务地址: %FRONTEND_URL%"

REM 等待前端服务初始化
call :ECHO_COLOR %COLOR_INFO% "等待前端服务初始化..."
timeout /t 3 /nobreak >nul

REM 显示服务状态
echo.
call :ECHO_COLOR %COLOR_TITLE% "======================================="
call :ECHO_COLOR %COLOR_SUCCESS% "          服务启动完成！          "
call :ECHO_COLOR %COLOR_TITLE% "======================================="
echo.
call :ECHO_COLOR %COLOR_INFO% "后端服务地址: %BACKEND_URL%"
call :ECHO_COLOR %COLOR_INFO% "前端服务地址: %FRONTEND_URL%"
echo.
call :ECHO_COLOR %COLOR_SUCCESS% "请在浏览器中访问: %FRONTEND_URL%"
echo.
call :ECHO_COLOR %COLOR_INFO% "管理员账号: admin / admin123"
call :ECHO_COLOR %COLOR_INFO% "测试账号: testuser / newpassword123"
echo.
call :ECHO_COLOR %COLOR_TITLE% "======================================="
call :ECHO_COLOR %COLOR_INFO% "按任意键停止所有服务..."
call :ECHO_COLOR %COLOR_TITLE% "======================================="

REM 等待用户输入
pause >nul

REM 停止所有服务
echo.
call :ECHO_COLOR %COLOR_TITLE% "======================================="
call :ECHO_COLOR %COLOR_INFO% "正在停止所有服务..."
call :ECHO_COLOR %COLOR_TITLE% "======================================="

REM 停止后端服务
call :ECHO_COLOR %COLOR_INFO% "正在停止后端服务..."
taskkill /fi "WINDOWTITLE eq %BACKEND_TITLE%" /f >nul 2>&1
if !ERRORLEVEL! equ 0 (
    call :ECHO_COLOR %COLOR_SUCCESS% "后端服务已成功停止"
) else (
    call :ECHO_COLOR %COLOR_WARNING% "后端服务停止失败或未运行"
)

REM 停止前端服务
call :ECHO_COLOR %COLOR_INFO% "正在停止前端服务..."
taskkill /fi "WINDOWTITLE eq %FRONTEND_TITLE%" /f >nul 2>&1
if !ERRORLEVEL! equ 0 (
    call :ECHO_COLOR %COLOR_SUCCESS% "前端服务已成功停止"
) else (
    call :ECHO_COLOR %COLOR_WARNING% "前端服务停止失败或未运行"
)

REM 显示停止完成信息
echo.
call :ECHO_COLOR %COLOR_TITLE% "======================================="
call :ECHO_COLOR %COLOR_SUCCESS% "          所有服务已停止！          "
call :ECHO_COLOR %COLOR_TITLE% "======================================="

REM 等待2秒后退出
timeout /t 2 /nobreak >nul
