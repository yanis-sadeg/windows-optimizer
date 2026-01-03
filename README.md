# Windows 11 Optimization Script
This PowerShell script optimizes Windows 11 by disabling unnecessary features, improving performance, and enhancing privacy settings.
  
## 🚀 How to Use
1. Run as Administrator
   - This script must be executed with administrator privileges.
2. Allow Script Execution
	-  Before running the script, enable script execution by opening PowerShell as Administrator and running:
	```powershell
	Set-ExecutionPolicy Bypass -Scope Process -Force
	```
3. Execute the Script
	- Run the script in PowerShell:
	```powershell
	.\optimize_windows11.ps1
	```
  
## ⚡ Features & Optimizations
- Remove Default Windows Games (Solitaire, Xbox apps, etc.)
- Power Settings Optimization
- High-performance mode on AC power
- Balanced mode on battery
- Disable battery saver mode
- Disable USB Device Sleep Mode
- Enhance Privacy Settings
- Disable location access, telemetry, and background app activity
- Disable activity history and personalized ads
- Disable Cortana and feedback requests
- Disable OneDrive and Xbox Auto-Start
- Disable Windows Tips and Suggestions
- Disable Transparency Effects
- Enable Hardware-Accelerated GPU Scheduling
- Enable Variable Refresh Rate (VRR)
- Enable Game Mode for Better Performance
- Disable Pointer Precision Enhancement (for FPS Games)
- Set Cloudflare DNS (1.1.1.1, 1.0.0.1) for Wi-Fi & Ethernet
  
## 🛠️ Notes
This script is designed for Windows 11 and may not work correctly on other versions.
Some changes may require a system restart to take effect.