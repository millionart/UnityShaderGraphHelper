#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance, force
#InstallKeybdHook
#InstallMouseHook
#EscapeChar \
AutoTrim, Off
CoordMode, Mouse, Screen
DetectHiddenWindows, On
ListLines Off
SendMode, Input ; Recommended for new scripts due to its superior speed and reliability.
SetBatchLines -1
SetWorkingDir %A_ScriptDir% ; Ensures a consistent starting directory.
DetectHiddenText, On


ver:="0.3.0"
nodesPath=%A_ScriptDir%\\Nodes

; 托盘菜单
If A_IsCompiled=1
{
    Menu, tray, NoStandard
    Menu, tray, Tip, Shader Graph Helper
}
; Menu, tray, add
Menu, tray, add, 更新 | Ver %ver%, UpdateScrit

If A_IsCompiled=1
{
    Menu, tray, add, 退出 | Exit, ExitScrit
}
else
{
    Menu, Tray, Icon,%A_scriptdir%\\tray.ico,, 1
}
return

#IfWinActive, ahk_class UnityContainerWndClass

    LButton::
        TryGetAnyKey()
    Return

    ; Block GraphView stupid Shourtcuts

    $a::BlockSend("a")
    Return

    $o::BlockSend("o")
    Return

    $f::BlockSend("f")
    Return

    RButton::
        if WinExist("A")
            ControlGetFocus, curCtrl

        ControlGetText, ctrlTxt, %curCtrl%
        if ctrlTxt=UnityEditor.ShaderGraph.Drawing.MaterialGraphEditWindow
        {
            MouseGetPos, perPosX, perPosY
            Send, {MButton Down}
            KeyWait, RButton
            HookRightMouse(perPosX,perPosY) 
        }
        Else
        {
            Send, {RButton Down}
            KeyWait, RButton
            Send, {RButton Up}
        }
    Return

    $!LButton::
        if WinExist("A")
            ControlGetFocus, curCtrl

        ControlGetText, ctrlTxt, %curCtrl%
        if ctrlTxt=UnityEditor.ShaderGraph.Drawing.MaterialGraphEditWindow
        {
            MouseGetPos, perPosX, perPosY
            Send, {LButton Down}
            MouseMove, perPosX, perPosY+40,0
            MouseMove, perPosX, perPosY,0
            Send, {LButton Up}
            Sleep, 100
            Send, {Escape}
        }
        Else
        {
            Send, !{LButton Down}
            KeyWait, LButton
            Send, !{LButton Up}
        }
    Return

#IfWinActive

ExitScrit:
ExitApp
Return

UpdateScrit:
    Run, https://github.com/millionart/UnityShaderGraphHelper/releases
Return

RemoveToolTip:
    ToolTip
return

HookRightMouse(perPosX,perPosY)
{
    ; 获得鼠标当前坐标
    MouseGetPos, curPosX, curPosY

    ; 当前坐标剪去先前坐标
    moveX:=abs(curPosX-perPosX)
    moveY:=abs(curPosY-perPosY)

    ; 如果X大于10，Y大于10, 则认为是右键移动
    If (moveX>10) || (moveY>10)
    {
        Send, {MButton Up}
    }
    else
    {
        Send, {MButton}
        Send, {RButton}
    }
}

BlockSend(key)
{
    if WinExist("A")
        ControlGetFocus, curCtrl

    ControlGetText, ctrlTxt, %curCtrl%
    if ctrlTxt=UnityEditor.ShaderGraph.Drawing.MaterialGraphEditWindow
    {
        MouseGetPos, MouseX, MouseY
        PixelGetColor, color, %MouseX%, %MouseY%

        If (A_Cursor="IBeam" || (color!="0x202020" && color!="0x1F1F1F" && color!="0x393939" && color!="0xAEAEAE" && color!="0x4B92F3" && color!="0xCB3022" && color!="0xF6FF9A"))
        {
            while GetKeyState(key, "P")
            {
                Send, {%key%}
                sleep, Max(400 - A_Index*100, 50)
            }
        }
        else
        {
            global blockedKeyInput:=key
            KeyWait, %key%
            global blockedKeyInput:=""
            Return
        }
    }
    else if ctrlTxt=UnityEditor.GameView
    {
        Send, {%key% Down}
        KeyWait, %key%
        Send, {%key% Up}
    }
    else
    {
        while GetKeyState(key, "P")
        {
            Send, {%key%}
            sleep, Max(400 - A_Index*100, 50)
        }
    }
}

TryGetAnyKey()
{
    if WinExist("A")
        ControlGetFocus, curCtrl
    ControlGetText, ctrlTxt, %curCtrl%
    if ctrlTxt=UnityEditor.ShaderGraph.Drawing.MaterialGraphEditWindow
    {
        global blockedKeyInput

        InputHook :=A_PriorKey
        ; InputHook := Format(Upper , %InputHook)
        StringUpper, InputHook, InputHook
        ; ToolTip, %InputHook%
        If GetKeyState(A_PriorKey) || blockedKeyInput!=""
        {
            Switch blockedKeyInput
            {
                Case "a": InputHook:="A"
                Case "o": InputHook:="O"
                Case "f": InputHook:="F"
            }

            Switch InputHook
            {
                Case "`": CreateNode("Slider")
                Case "0": CreateNode("Integer")
                Case "1": CreateNode("Float")
                Case "2": CreateNode("Vector2")
                Case "3": CreateNode("Vector3")
                Case "4": CreateNode("Vector4")
                Case "5": CreateNode("Color")
                Case "B": CreateNode("Split")
                Case "V": CreateNode("Combine")
                Case "G": CreateNode("GetVariable") ;  https://github.com/Cyanilux/ShaderGraphVariables
                Case "R": CreateNode("RegisterVariable") ; https://github.com/Cyanilux/ShaderGraphVariables
                Case "K": CreateNode("ChannelMask")
                Case "X": CreateNode("Cross")
                Case ".": CreateNode("DotProduct")
                Case "L": CreateNode("Lerp")
                Case "N": CreateNode("Normalize")
                Case "O": CreateNode("OneMinus")
                Case "E": CreateNode("Power")
                Case "A": CreateNode("Add")
                Case "D": CreateNode("Divide")
                Case "M": CreateNode("Multiply")
                Case "S": CreateNode("Subtract")
                Case "T": CreateNode("SampleTexture2D")
                Case "U": CreateNode("TillingAndOffset")
                ; Default:
                ;     ToolTip, %A_Time%
                ;     SetTimer, RemoveToolTip, 1000
            }
        }
    }
    Send, {LButton Down}
    KeyWait, LButton
    Send, {LButton Up}
}

CreateNode(nodeName)
{
    global nodesPath
    clipSaved:=ClipBoardAll
    FileRead, nodeclip, %nodesPath%\\%nodeName%.txt
    Clipboard:=nodeclip
    ClipWait 0.1, 1
    ; WinMenuSelectItem is lag, don't use it
    ; WinMenuSelectItem, A,, Edit, Paste
    ; https://www.the-automator.com/pasting-with-sendmessage-in-autohotkey/
    ; Not work
    ; ControlGetFocus, vCtlClassNN, A
    ; ControlGet, hCtl, Hwnd,, % vCtlClassNN, A
    ; SendMessage, 0x0302,,,, % “ahk_id ” hCtl ;WM_PASTE := 0x302

    Send, {%key% Up}^{v}
    Sleep, 10
    Send, {Ctrl Up}
    ; BlockInput Off
    Sleep, 10
    Clipboard:=clipSaved
    ClipWait 0.1, 1
    ; MsgBox, %nodesPath% | %fileName% | %nodeclip%
}
