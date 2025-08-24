#!/bin/bash
set -euo pipefail

# 帮助信息
show_help() {
    echo "用法: $0 -p <进程名> | -i <进程ID> -c <命令>"
    echo "监控指定进程（名称或PID），进程结束后执行给定命令"
    echo "示例:"
    echo "  通过进程名监控: $0 -p 'my_app' -c 'echo \"进程结束\"'"
    echo "  通过进程ID监控: $0 -i 12345 -c 'notify-send \"进程结束\"'"
    echo "  组合监控:       $0 -p 'my_app' -i 12345 -c 'reboot'"
    echo "选项:"
    echo "  -p  要监控的进程名"
    echo "  -i  要监控的进程ID"
    echo "  -c  进程结束后执行的命令（必需）"
    exit 1
}

# 声明变量
PROCESS_NAME=""
PROCESS_ID=""
COMMAND_TO_RUN=""

# 解析参数
while getopts ":p:i:c:" opt; do
    case $opt in
        p) PROCESS_NAME="$OPTARG";;
        i) PROCESS_ID="$OPTARG";;
        c) COMMAND_TO_RUN="$OPTARG";;
        \?) show_help;;
    esac
done

# 验证参数
if [[ -z "$COMMAND_TO_RUN" ]]; then
    echo "错误：必须指定要执行的命令！"
    show_help
fi

if [[ -z "$PROCESS_NAME" && -z "$PROCESS_ID" ]]; then
    echo "错误：必须指定进程名或进程ID！"
    show_help
fi

# 检查进程状态
check_process_exists() {
    # 检查进程ID是否存在
    if [[ -n "$PROCESS_ID" ]]; then
        if ps -p "$PROCESS_ID" > /dev/null; then
            local process_name
            # 如果同时指定了进程名，则验证进程名匹配
            if [[ -n "$PROCESS_NAME" ]]; then
                process_name=$(ps -p "$PROCESS_ID" -o comm=)
                if [[ "$process_name" != "$PROCESS_NAME" ]]; then
                    echo "进程ID $PROCESS_ID 存在，但进程名不匹配（实际为 $process_name）"
                    return 1
                fi
            fi
            return 0
        fi
        return 1
    fi
    
    # 只通过进程名检查
    if [[ -n "$PROCESS_NAME" ]]; then
        pgrep -x "$PROCESS_NAME" > /dev/null
        return $?
    fi
    
    return 1
}

# 获取当前进程列表（用于显示）
get_process_info() {
    local info=""
    
    if [[ -n "$PROCESS_ID" ]]; then
        info+="PID: $PROCESS_ID"
        if [[ -n "$PROCESS_NAME" ]]; then
            info+=" ($PROCESS_NAME)"
        fi
    else
        pids=$(pgrep -x "$PROCESS_NAME" | tr '\n' ',' | sed 's/,$//')
        info+="进程: $PROCESS_NAME PIDs: ${pids:-无}"
    fi
    
    echo "$info"
}

echo "开始监控进程..."
echo "当前脚本的进程ID (PID): $$"
if [[ -n "$PROCESS_ID" ]]; then
    echo "指定进程ID: $PROCESS_ID"
    if [[ -n "$PROCESS_NAME" ]]; then
        echo "同时验证进程名: $PROCESS_NAME"
    fi
else
    echo "指定进程名: $PROCESS_NAME"
fi

# 主监控循环
while check_process_exists; do
    # 显示监控状态
    info=$(get_process_info)
    echo -ne "[\033[92m运行中\033[0m] $info $(date +'%H:%M:%S')\r"
    sleep 2
done

echo -e "\n进程已结束"
echo "执行命令: $COMMAND_TO_RUN"
eval "$COMMAND_TO_RUN"

exit 0
