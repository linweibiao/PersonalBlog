<#
.SYNOPSIS
停止博客系统的前端和后端服务

.DESCRIPTION
此脚本用于停止博客系统的前端和后端服务，
支持自动识别并停止所有相关的Python进程，
包含完善的错误处理和日志记录功能。

.PARAMETER Force
强制停止所有相关进程，不提示用户确认

.EXAMPLE
.\stop_all.ps1
停止所有服务并显示详细信息

.EXAMPLE
.\stop_all.ps1 -Force
强制停止所有服务，不显示确认提示

.NOTES
文件名: stop_all.ps1
作者: 博客系统开发团队
更新日期: 2025-12-07
版本: v1.0.0
#>

# 定义参数
param(
    [switch]$Force  # 是否强制停止，不提示确认
)

# 配置日志输出颜色
$Colors = @{
    Info = "Cyan"
    Success = "Green"
    Warning = "Yellow"
    Error = "Red"
    Title = "White"
    Process = "Magenta"
}

# 输出日志函数
function Write-Log {
    <#
    .SYNOPSIS
    输出带颜色的日志信息
    .PARAMETER Level
    日志级别: Info, Success, Warning, Error, Title, Process
    .PARAMETER Message
    日志消息
    #>
    param(
        [ValidateSet("Info", "Success", "Warning", "Error", "Title", "Process")]
        [string]$Level = "Info",
        [string]$Message
    )
    
    $color = $Colors[$Level]
    Write-Host "[$Level] $Message" -ForegroundColor $color
}

# 检查进程是否为博客系统服务
function Test-ServiceProcess {
    <#
    .SYNOPSIS
    检查进程是否为博客系统服务进程
    .PARAMETER Process
    要检查的进程对象
    .RETURN
    如果是服务进程返回$true，否则返回$false
    #>
    param([System.Diagnostics.Process]$Process)
    
    try {
        # 获取进程的命令行参数
        $commandLine = (Get-CimInstance Win32_Process -Filter "ProcessId = $($Process.Id)").CommandLine
        
        # 检查是否包含服务特征
        if ($commandLine -match "run.py" -or $commandLine -match "run_server.py") {
            return $true
        }
        return $false
    } catch {
        Write-Log -Level Warning "获取进程 $($Process.Id) 命令行失败: $_"
        return $false
    }
}

# 获取服务进程信息
function Get-ServiceProcessInfo {
    <#
    .SYNOPSIS
    获取进程的详细信息
    .PARAMETER Process
    进程对象
    .RETURN
    包含进程详细信息的对象
    #>
    param([System.Diagnostics.Process]$Process)
    
    try {
        $commandLine = (Get-CimInstance Win32_Process -Filter "ProcessId = $($Process.Id)").CommandLine
        $startTime = $Process.StartTime
        $cpuTime = $Process.TotalProcessorTime
        
        return @{
            Id = $Process.Id
            Name = $Process.ProcessName
            CommandLine = $commandLine
            StartTime = $startTime
            CpuTime = $cpuTime
        }
    } catch {
        return @{
            Id = $Process.Id
            Name = $Process.ProcessName
            CommandLine = "获取失败"
            StartTime = "获取失败"
            CpuTime = "获取失败"
        }
    }
}

# 主程序开始
Write-Log -Level Title "========================================"
Write-Log -Level Title "      博客系统停止脚本      "
Write-Log -Level Title "========================================"

# 记录开始时间
$startTime = Get-Date
Write-Log -Level Info "开始停止博客系统服务..."
Write-Log -Level Info "脚本开始时间: $($startTime.ToString('yyyy-MM-dd HH:mm:ss'))"

# 获取所有Python进程
Write-Log -Level Info "正在扫描运行中的Python进程..."

$pythonProcesses = Get-Process -Name "python" -ErrorAction SilentlyContinue

if (-not $pythonProcesses) {
    Write-Log -Level Warning "未找到运行中的Python进程"
    Write-Log -Level Title "========================================"
    Write-Log -Level Info "没有需要停止的服务进程"
    Write-Log -Level Title "========================================"
    
    # 等待2秒后退出
    Start-Sleep -Seconds 2
    exit 0
}

Write-Log -Level Info "找到 $($pythonProcesses.Count) 个运行中的Python进程"

# 过滤出服务进程
$serviceProcesses = @()
foreach ($process in $pythonProcesses) {
    if (Test-ServiceProcess $process) {
        $serviceProcesses += $process
    }
}

# 显示找到的服务进程
if ($serviceProcesses.Count -gt 0) {
    Write-Log -Level Title ""
    Write-Log -Level Title "========================================"
    Write-Log -Level Info "找到 $($serviceProcesses.Count) 个服务进程:"
    Write-Log -Level Title "========================================"
    
    foreach ($process in $serviceProcesses) {
        $processInfo = Get-ServiceProcessInfo $process
        Write-Log -Level Process "进程ID: $($processInfo.Id)"
        Write-Log -Level Process "命令行: $($processInfo.CommandLine)"
        Write-Log -Level Process "启动时间: $($processInfo.StartTime)"
        Write-Log -Level Process "CPU时间: $($processInfo.CpuTime)"
        Write-Log -Level Process ""
    }
    
    # 确认停止（除非使用-Force参数）
    if (-not $Force) {
        Write-Log -Level Warning "准备停止 $($serviceProcesses.Count) 个服务进程，是否继续？"
        $response = Read-Host "输入 'Y' 继续，其他键取消"
        if ($response -ne "Y" -and $response -ne "y") {
            Write-Log -Level Info "用户取消了停止操作"
            Write-Log -Level Title "========================================"
            Write-Log -Level Info "脚本已取消"
            Write-Log -Level Title "========================================"
            exit 0
        }
    }
    
    # 停止进程
    Write-Log -Level Title ""
    Write-Log -Level Title "========================================"
    Write-Log -Level Info "正在停止服务进程..."
    Write-Log -Level Title "========================================"
    
    $stoppedCount = 0
    $failedCount = 0
    $failedProcesses = @()
    
    foreach ($process in $serviceProcesses) {
        try {
            Write-Log -Level Info "正在停止进程: $($process.Id)"
            Stop-Process -Id $process.Id -Force -ErrorAction Stop
            Write-Log -Level Success "进程 $($process.Id) 已成功停止"
            $stoppedCount++
        } catch {
            Write-Log -Level Error "停止进程 $($process.Id) 失败: $_"
            $failedCount++
            $failedProcesses += $process
        }
    }
    
    # 检查是否有进程仍在运行
    Write-Log -Level Title ""
    Write-Log -Level Title "========================================"
    Write-Log -Level Info "正在验证停止结果..."
    Write-Log -Level Title "========================================"
    
    $stillRunning = @()
    foreach ($process in $serviceProcesses) {
        if (Get-Process -Id $process.Id -ErrorAction SilentlyContinue) {
            $stillRunning += $process
            Write-Log -Level Warning "进程 $($process.Id) 仍在运行"
        }
    }
    
    # 显示停止结果
    Write-Log -Level Title ""
    Write-Log -Level Title "========================================"
    Write-Log -Level Title "      停止结果汇总      "
    Write-Log -Level Title "========================================"
    Write-Log -Level Info "找到的服务进程: $($serviceProcesses.Count)"
    Write-Log -Level Success "成功停止: $stoppedCount"
    Write-Log -Level Error "停止失败: $failedCount"
    Write-Log -Level Warning "仍在运行: $($stillRunning.Count)"
    
    if ($stillRunning.Count -gt 0) {
        Write-Log -Level Info "仍在运行的进程ID: $($stillRunning.Id -join ', ')"
        Write-Log -Level Info "建议手动检查这些进程"
    }
    
    # 记录结束时间和执行时间
    $endTime = Get-Date
    $executionTime = $endTime - $startTime
    
    Write-Log -Level Info "脚本结束时间: $($endTime.ToString('yyyy-MM-dd HH:mm:ss'))"
    Write-Log -Level Info "脚本执行时间: $($executionTime.TotalSeconds.ToString('F2')) 秒"
    
    Write-Log -Level Title "========================================"
    Write-Log -Level Success "服务停止操作完成！"
    Write-Log -Level Title "========================================"
    
} else {
    Write-Log -Level Info "未找到博客系统服务进程"
    Write-Log -Level Info "所有服务可能已经停止"
    
    # 记录结束时间
    $endTime = Get-Date
    $executionTime = $endTime - $startTime
    
    Write-Log -Level Info "脚本结束时间: $($endTime.ToString('yyyy-MM-dd HH:mm:ss'))"
    Write-Log -Level Info "脚本执行时间: $($executionTime.TotalSeconds.ToString('F2')) 秒"
    
    Write-Log -Level Title "========================================"
    Write-Log -Level Info "没有需要停止的服务进程"
    Write-Log -Level Title "========================================"
}

# 等待2秒后退出
Write-Log -Level Info "脚本将在2秒后退出..."
Start-Sleep -Seconds 2
