<#
.SYNOPSIS
启动博客系统的前端和后端服务

.DESCRIPTION
此脚本用于同时启动博客系统的前端和后端服务，
- 后端服务运行在 http://localhost:5000
- 前端服务运行在 http://localhost:8000
- 支持后台启动模式
- 包含完善的错误处理和日志记录

.PARAMETER NoWait
如果指定此参数，则脚本不会等待用户输入，直接返回

.EXAMPLE
.\start_all.ps1
启动所有服务并等待用户输入停止

.EXAMPLE
.\start_all.ps1 -NoWait
启动所有服务并立即返回

.NOTES
文件名: start_all.ps1
作者: 博客系统开发团队
更新日期: 2025-12-07
版本: v1.0.0
#>

# 定义参数
param(
    [switch]$NoWait  # 是否在后台运行，不等待用户输入
)

# 配置日志输出颜色
$Colors = @{
    Info = "Cyan"
    Success = "Green"
    Warning = "Yellow"
    Error = "Red"
    Title = "White"
}

# 输出日志函数
function Write-Log {
    <#
    .SYNOPSIS
    输出带颜色的日志信息
    .PARAMETER Level
    日志级别: Info, Success, Warning, Error, Title
    .PARAMETER Message
    日志消息
    #>
    param(
        [ValidateSet("Info", "Success", "Warning", "Error", "Title")]
        [string]$Level = "Info",
        [string]$Message
    )
    
    $color = $Colors[$Level]
    Write-Host "[$Level] $Message" -ForegroundColor $color
}

# 检查端口是否被占用
function Test-Port {
    <#
    .SYNOPSIS
    检查指定端口是否被占用
    .PARAMETER Port
    要检查的端口号
    .RETURN
    如果端口被占用返回$true，否则返回$false
    #>
    param([int]$Port)
    
    try {
        $listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Loopback, $Port)
        $listener.Start()
        $listener.Stop()
        return $false
    } catch {
        return $true
    }
}

# 检查Python是否安装
function Test-Python {
    <#
    .SYNOPSIS
    检查Python是否安装
    .RETURN
    如果Python已安装返回$true，否则返回$false
    #>
    try {
        $pythonVersion = python --version 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Log -Level Info "检测到Python版本: $pythonVersion"
            return $true
        } else {
            return $false
        }
    } catch {
        return $false
    }
}

# 主程序开始
Write-Log -Level Title "========================================"
Write-Log -Level Title "      博客系统启动脚本      "
Write-Log -Level Title "========================================"
Write-Log -Level Info "开始启动博客系统服务..."

# 环境检查
Write-Log -Level Info "正在检查运行环境..."

# 检查Python是否安装
if (-not (Test-Python)) {
    Write-Log -Level Error "未检测到Python，请先安装Python 3.8+"
    Write-Log -Level Info "Python下载地址: https://www.python.org/downloads/"
    pause
    exit 1
}

# 定义服务配置
$backendConfig = @{
    Name = "后端服务"
    Path = Join-Path $PSScriptRoot "blog-system\backend"
    Executable = "python.exe"
    Arguments = "run.py"
    Port = 5000
    URL = "http://localhost:5000"
}

$frontendConfig = @{
    Name = "前端服务"
    Path = Join-Path $PSScriptRoot "blog-system\frontend\dist"
    Executable = "python.exe"
    Arguments = "run_server.py"
    Port = 8000
    URL = "http://localhost:8000"
}

# 检查服务目录是否存在
Write-Log -Level Info "正在检查服务目录..."

if (-not (Test-Path $backendConfig.Path)) {
    Write-Log -Level Error "后端服务目录不存在: $($backendConfig.Path)"
    pause
    exit 1
}

if (-not (Test-Path $frontendConfig.Path)) {
    Write-Log -Level Error "前端服务目录不存在: $($frontendConfig.Path)"
    Write-Log -Level Info "请先构建前端项目: cd blog-system\frontend && npm run build"
    pause
    exit 1
}

# 检查端口是否被占用
Write-Log -Level Info "正在检查端口占用情况..."

if (Test-Port $backendConfig.Port) {
    Write-Log -Level Warning "后端服务端口 $($backendConfig.Port) 已被占用，可能影响服务启动"
    Write-Log -Level Info "建议使用 .\stop_all.ps1 停止现有服务，或手动释放端口"
}

if (Test-Port $frontendConfig.Port) {
    Write-Log -Level Warning "前端服务端口 $($frontendConfig.Port) 已被占用，可能影响服务启动"
    Write-Log -Level Info "建议使用 .\stop_all.ps1 停止现有服务，或手动释放端口"
}

# 启动后端服务
Write-Log -Level Info "正在启动 $($backendConfig.Name)..."
try {
    $backendProcess = Start-Process -FilePath $backendConfig.Executable -ArgumentList $backendConfig.Arguments -WorkingDirectory $backendConfig.Path -WindowStyle Normal -PassThru
    
    if (-not $backendProcess) {
        Write-Log -Level Error "启动 $($backendConfig.Name) 失败，无法获取进程信息"
        pause
        exit 1
    }
    
    Write-Log -Level Success "已启动 $($backendConfig.Name)，进程ID: $($backendProcess.Id)"
} catch {
    Write-Log -Level Error "启动 $($backendConfig.Name) 失败: $_"
    pause
    exit 1
}

# 等待后端服务启动
Write-Log -Level Info "等待 $($backendConfig.Name) 初始化..."
Start-Sleep -Seconds 3

# 检查后端进程是否仍在运行
if (-not (Get-Process -Id $backendProcess.Id -ErrorAction SilentlyContinue)) {
    Write-Log -Level Error "$($backendConfig.Name) 启动失败，进程已退出"
    Write-Log -Level Info "请检查 $($backendConfig.Path)\run.py 文件或日志获取详细信息"
    pause
    exit 1
}

# 启动前端服务
Write-Log -Level Info "正在启动 $($frontendConfig.Name)..."
try {
    $frontendProcess = Start-Process -FilePath $frontendConfig.Executable -ArgumentList $frontendConfig.Arguments -WorkingDirectory $frontendConfig.Path -WindowStyle Normal -PassThru
    
    if (-not $frontendProcess) {
        Write-Log -Level Error "启动 $($frontendConfig.Name) 失败，无法获取进程信息"
        # 尝试停止后端服务
        try {
            Stop-Process -Id $backendProcess.Id -Force -ErrorAction SilentlyContinue
            Write-Log -Level Info "已停止 $($backendConfig.Name)"
        } catch {
            Write-Log -Level Warning "停止 $($backendConfig.Name) 失败: $_"
        }
        pause
        exit 1
    }
    
    Write-Log -Level Success "已启动 $($frontendConfig.Name)，进程ID: $($frontendProcess.Id)"
} catch {
    Write-Log -Level Error "启动 $($frontendConfig.Name) 失败: $_"
    # 尝试停止后端服务
    try {
        Stop-Process -Id $backendProcess.Id -Force -ErrorAction SilentlyContinue
        Write-Log -Level Info "已停止 $($backendConfig.Name)"
    } catch {
        Write-Log -Level Warning "停止 $($backendConfig.Name) 失败: $_"
    }
    pause
    exit 1
}

# 等待前端服务启动
Write-Log -Level Info "等待 $($frontendConfig.Name) 初始化..."
Start-Sleep -Seconds 3

# 检查前端进程是否仍在运行
if (-not (Get-Process -Id $frontendProcess.Id -ErrorAction SilentlyContinue)) {
    Write-Log -Level Error "$($frontendConfig.Name) 启动失败，进程已退出"
    Write-Log -Level Info "请检查 $($frontendConfig.Path)\run_server.py 文件或日志获取详细信息"
    # 尝试停止后端服务
    try {
        Stop-Process -Id $backendProcess.Id -Force -ErrorAction SilentlyContinue
        Write-Log -Level Info "已停止 $($backendConfig.Name)"
    } catch {
        Write-Log -Level Warning "停止 $($backendConfig.Name) 失败: $_"
    }
    pause
    exit 1
}

# 显示服务状态
Write-Log -Level Title ""
Write-Log -Level Title "========================================"
Write-Log -Level Title "      服务启动成功！      "
Write-Log -Level Title "========================================"
Write-Log -Level Title ""
Write-Log -Level Info "$($backendConfig.Name): $($backendConfig.URL)"
Write-Log -Level Info "$($frontendConfig.Name): $($frontendConfig.URL)"
Write-Log -Level Title ""
Write-Log -Level Title "========================================"
Write-Log -Level Info "请在浏览器中访问: $($frontendConfig.URL)"
Write-Log -Level Info "管理员账号: admin / admin123"
Write-Log -Level Info "测试账号: testuser / newpassword123"
Write-Log -Level Title "========================================"

# 如果指定了NoWait参数，则直接返回
if ($NoWait) {
    Write-Log -Level Info "服务已在后台启动，进程ID:"
    Write-Log -Level Info "- $($backendConfig.Name): $($backendProcess.Id)"
    Write-Log -Level Info "- $($frontendConfig.Name): $($frontendProcess.Id)"
    Write-Log -Level Info "使用 .\stop_all.ps1 来停止所有服务"
    Write-Log -Level Title "========================================"
    exit 0
}

# 等待用户输入停止服务
Write-Log -Level Info "按任意键停止所有服务..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# 停止所有服务
Write-Log -Level Title ""
Write-Log -Level Title "========================================"
Write-Log -Level Info "正在停止所有服务..."

# 停止前端服务
Write-Log -Level Info "正在停止 $($frontendConfig.Name)..."
try {
    Stop-Process -Id $frontendProcess.Id -Force -ErrorAction SilentlyContinue
    
    # 检查是否成功停止
    if (-not (Get-Process -Id $frontendProcess.Id -ErrorAction SilentlyContinue)) {
        Write-Log -Level Success "已成功停止 $($frontendConfig.Name)"
    } else {
        Write-Log -Level Warning "停止 $($frontendConfig.Name) 失败，进程仍在运行"
    }
} catch {
    Write-Log -Level Warning "停止 $($frontendConfig.Name) 时发生错误: $_"
}

# 停止后端服务
Write-Log -Level Info "正在停止 $($backendConfig.Name)..."
try {
    Stop-Process -Id $backendProcess.Id -Force -ErrorAction SilentlyContinue
    
    # 检查是否成功停止
    if (-not (Get-Process -Id $backendProcess.Id -ErrorAction SilentlyContinue)) {
        Write-Log -Level Success "已成功停止 $($backendConfig.Name)"
    } else {
        Write-Log -Level Warning "停止 $($backendConfig.Name) 失败，进程仍在运行"
    }
} catch {
    Write-Log -Level Warning "停止 $($backendConfig.Name) 时发生错误: $_"
}

Write-Log -Level Title ""
Write-Log -Level Title "========================================"
Write-Log -Level Title "      所有服务已停止！      "
Write-Log -Level Title "========================================"

# 等待2秒后退出
Start-Sleep -Seconds 2
Write-Log -Level Info "脚本执行完成，即将退出..."