import win32gui
import win32con
import sys
import time

def find_window_by_title(title):
    """查找第一个匹配标题的窗口句柄"""
    def callback(hwnd, titles):
        if win32gui.IsWindowVisible(hwnd):
            window_title = win32gui.GetWindowText(hwnd)
            if title in window_title:  # 模糊匹配
                titles.append(hwnd)
        return True
    
    titles = []
    win32gui.EnumWindows(callback, titles)
    return titles[0] if titles else None

def hide_taskbar_icon(hwnd):
    """隐藏指定窗口的任务栏图标"""
    if not hwnd:
        return False
    
    try:
        # 获取当前扩展样式
        style = win32gui.GetWindowLong(hwnd, win32con.GWL_EXSTYLE)
        
        # 必须隐藏窗口才能修改样式
        win32gui.ShowWindow(hwnd, win32con.SW_HIDE)
        time.sleep(0.05)  # 短暂延迟确保隐藏生效
        
        # 添加 TOOLWINDOW 样式（不在任务栏显示）
        win32gui.SetWindowLong(hwnd, win32con.GWL_EXSTYLE, 
                              style | win32con.WS_EX_TOOLWINDOW)
        
        # 重新显示窗口
        win32gui.ShowWindow(hwnd, win32con.SW_SHOW)
        
        print(f"✅ 已隐藏 Lynx 窗口的任务栏图标 (句柄: {hwnd})")
        return True
        
    except Exception as e:
        print(f"❌ 操作失败: {e}")
        return False

if __name__ == "__main__":
    # 查找标题包含 "Lynx" 的窗口
    hwnd = find_window_by_title("钉钉")
    
    if hwnd:
        print(f"找到 Lynx 窗口，句柄: {hwnd}")
        hide_taskbar_icon(hwnd)
    else:
        print("❌ 未找到标题为 'Lynx' 的窗口")
        print("请确保窗口已启动且标题可见")
        sys.exit(1)