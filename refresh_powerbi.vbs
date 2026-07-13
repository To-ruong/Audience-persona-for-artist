Set objShell = CreateObject("WScript.Shell")
objShell.Run """file.pbix""", 1, False
WScript.Sleep 15000
objShell.SendKeys "%h"
WScript.Sleep 500
objShell.SendKeys "r"