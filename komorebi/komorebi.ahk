#Requires AutoHotkey v2.0
#SingleInstance Force
#NoTrayIcon

; komorebi.ahk - AutoHotkey v2 mapping for komorebi
; Replaces whkd (whkd drops/leaks win-key combos: https://github.com/LGUG2Z/whkd/issues/76)
; Run this script on startup INSTEAD of whkd; no komorebic --ahk/--whkd integration needed.

Komorebic(cmd) {
    RunWait("komorebic.exe " cmd, , "Hide")
}

; Reload this configuration (equivalent to restarting whkd)
#o::Reload()

; Reload komorebi configuration
#+o::Komorebic("reload-configuration")

; Launch apps
#c::Run("C:\Users\Rdepa29\AppData\Local\Programs\Zed\bin\Zed.exe")
#a::Run("C:\Users\Rdepa29\zen\zen.exe")
#e::Run("C:\Users\Rdepa29\AppData\Local\Programs\Git\usr\bin\fish.exe")

; Focus windows
#Left::Komorebic("focus left")
#Down::Komorebic("focus down")
#Up::Komorebic("focus up")
#Right::Komorebic("focus right")
#+[::Komorebic("cycle-focus previous")
#+]::Komorebic("cycle-focus next")

; Move windows
#+Left::Komorebic("move left")
#+Down::Komorebic("move down")
#+Up::Komorebic("move up")
#+Right::Komorebic("move right")
#+Enter::Komorebic("promote")
#+q::Komorebic("close")
#+m::Komorebic("minimize")

; Resize (oem_plus is = , oem_minus is -)
#=::Komorebic("resize-axis horizontal increase")
#-::Komorebic("resize-axis horizontal decrease")
#+=::Komorebic("resize-axis vertical increase")
#+-::Komorebic("resize-axis vertical decrease")

; Manipulate windows
#f::Komorebic("toggle-float")
#+f::Komorebic("toggle-monocle")

; Window manager options
#q::Komorebic("close")
#p::Komorebic("toggle-pause")
#x::Komorebic("flip-layout horizontal")
#y::Komorebic("flip-layout vertical")

; Focus workspaces
#1::Komorebic("focus-workspace 0")
#2::Komorebic("focus-workspace 1")
#3::Komorebic("focus-workspace 2")
#4::Komorebic("focus-workspace 3")
#5::Komorebic("focus-workspace 4")
#6::Komorebic("focus-workspace 5")
#7::Komorebic("focus-workspace 6")
#8::Komorebic("focus-workspace 7")

; Move windows across workspaces
#+1::Komorebic("move-to-workspace 0")
#+2::Komorebic("move-to-workspace 1")
#+3::Komorebic("move-to-workspace 2")
#+4::Komorebic("move-to-workspace 3")
#+5::Komorebic("move-to-workspace 4")
#+6::Komorebic("move-to-workspace 5")
#+7::Komorebic("move-to-workspace 6")
#+8::Komorebic("move-to-workspace 7")
