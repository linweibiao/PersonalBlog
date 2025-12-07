<#
.SYNOPSIS
博客系统简化版启动脚本

.DESCRIPTION
此脚本用于快速启动博客系统的前端和后端服务，
保持简洁的同时提供基本的错误处理和状态反馈。

- 后端服务运行在 http://localhost:5000
- 前端服务运行在 http://localhost:8000

.NOTES
文件名: start_simple.ps1
作者: 博客系统开发团队
更新日期: 2025-12-07
版本: v1.0.0
#>

# 输出颜色配置
$SuccessColor = "Green"
$InfoColor = "Cyan"
$ErrorColor = "Red"

# 定义服务配置
Write-Host "[INFO] 正在加载服务配置..." -ForegroundColor $InfoColor

# 后端服务配置
$backendConfig = @{
    Name = "后端服务"
    Path = Join-Path $PSScriptRoot "blog-system\backend"
    Executable = "python.exe"
    Arguments = "run.py"
    Port = 5000
    URL = "http://localhost:5000"
}

# 前端服务配置
$frontendConfig = @{
    Name = "前端服务"
    Path = Join-Path $PSScriptRoot "blog-system\frontend\dist"
    Executable = "python.exe"
    Arguments = "run_server.py"
    Port = 8000
    URL = "http://localhost:8000"
}

# 检查Python是否可用
Write-Host "[INFO] 正在检查Python环境..." -ForegroundColor $InfoColor
try {
    $pythonVersion = python --version 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[ERROR] 未检测到Python，请先安装Python 3.8+" -ForegroundColor $ErrorColor
        Write-Host "[INFO] Python下载地址: https://www.python.org/downloads/" -ForegroundColor $InfoColor
        pause
        exit 1
    }
    Write-Host "[INFO] 检测到Python版本: $pythonVersion" -ForegroundColor $InfoColor
} catch {
    Write-Host "[ERROR] 检测Python环境失败: $_" -ForegroundColor $ErrorColor
    pause
    exit 1
}

# 启动后端服务
Write-Host "" -ForegroundColor $InfoColor
Write-Host "[INFO] 正在启动 $($backendConfig.Name)..." -ForegroundColor $InfoColor

try {
    # 检查后端目录是否存在
    if (-not (Test-Path $backendConfig.Path)) {
        Write-Host "[ERROR] $($backendConfig.Name) 目录不存在: $($backendConfig.Path)" -ForegroundColor $ErrorColor
        pause
        exit 1
    }
    
    # 启动后端服务
    Start-Process -FilePath $backendConfig.Executable -ArgumentList $backendConfig.Arguments -WorkingDirectory $backendConfig.Path -WindowStyle Normal
    Write-Host "[SUCCESS] $($backendConfig.Name) 已启动" -ForegroundColor $SuccessColor
    Write-Host "[INFO] $($backendConfig.Name) 地址: $($backendConfig.URL)" -ForegroundColor $InfoColor
} catch {
    Write-Host "[ERROR] 启动 $($backendConfig.Name) 失败: $_" -ForegroundColor $ErrorColor
    pause
    exit 1
}

# 等待后端服务初始化
Write-Host "[INFO] 等待 $($backendConfig.Name) 初始化..." -ForegroundColor $InfoColor
Start-Sleep -Seconds 2

# 启动前端服务
Write-Host "" -ForegroundColor $InfoColor
Write-Host "[INFO] 正在启动 $($frontendConfig.Name)..." -ForegroundColor $InfoColor

try {
    # 检查前端目录是否存在
    if (-not (Test-Path $frontendConfig.Path)) {
        Write-Host "[ERROR] $($frontendConfig.Name) 目录不存在: $($frontendConfig.Path)" -ForegroundColor $ErrorColor
        Write-Host "[INFO] 请先构建前端项目: cd blog-system\frontend && npm run build" -ForegroundColor $InfoColor
        pause
        exit 1
    }
    
    # 启动前端服务
    Start-Process -FilePath $frontendConfig.Executable -ArgumentList $frontendConfig.Arguments -WorkingDirectory $frontendConfig.Path -WindowStyle Normal
    Write-Host "[SUCCESS] $($frontendConfig.Name) 已启动" -ForegroundColor $SuccessColor
    Write-Host "[INFO] $($frontendConfig.Name) 地址: $($frontendConfig.URL)" -ForegroundColor $InfoColor
} catch {
    Write-Host "[ERROR] 启动 $($frontendConfig.Name) 失败: $_" -ForegroundColor $ErrorColor
    pause
    exit 1
}

# 等待前端服务初始化
Write-Host "[INFO] 等待 $($frontendConfig.Name) 初始化..." -ForegroundColor $InfoColor
Start-Sleep -Seconds 2

# 显示服务状态
Write-Host "" -ForegroundColor $InfoColor
Write-Host "========================================" -ForegroundColor $SuccessColor
Write-Host "[SUCCESS] 所有服务启动成功！" -ForegroundColor $SuccessColor
Write-Host "========================================" -ForegroundColor $SuccessColor
Write-Host "" -ForegroundColor $InfoColor
Write-Host "[INFO] $($backendConfig.Name): $($backendConfig.URL)" -ForegroundColor $InfoColor
Write-Host "[INFO] $($frontendConfig.Name): $($frontendConfig.URL)" -ForegroundColor $InfoColor
Write-Host "" -ForegroundColor $InfoColor
Write-Host "[INFO] 请在浏览器中访问: $($frontendConfig.URL)" -ForegroundColor $SuccessColor
Write-Host "[INFO] 使用 .\stop_all.ps1 停止所有服务" -ForegroundColor $InfoColor
Write-Host "" -ForegroundColor $InfoColor
Write-Host "========================================" -ForegroundColor $SuccessColor
Write-Host "[INFO] 脚本执行完成！" -ForegroundColor $InfoColor