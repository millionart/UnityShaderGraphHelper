#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance, force
#InstallMouseHook
AutoTrim, Off
CoordMode, Mouse, Screen
DetectHiddenWindows, On
ListLines Off
SendMode, Input ; Recommended for new scripts due to its superior speed and reliability.
SetBatchLines -1
SetWorkingDir %A_ScriptDir% ; Ensures a consistent starting directory.
DetectHiddenText, On

ver:="0.2.0"
nodesPath=%A_ScriptDir%\Nodes

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
    Menu, Tray, Icon,%A_scriptdir%\tray.ico,, 1
}
return

UpdateScrit:
    Run, https://github.com/millionart/UnityShaderGraphHelper/releases
Return

#IfWinActive, ahk_class UnityContainerWndClass

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
        KeyWait, RButton ,
        HookRightMouse(perPosX,perPosY) 
    }
    Else
    {
        Send, {RButton Down}
        KeyWait, RButton
        Send, {RButton Up}
    }
Return

~0 & LButton::CreateNode("Integer")
Return

~1 & LButton::CreateNode("Float")
Return

~2 & LButton::CreateNode("Vector2")
Return

~3 & LButton::CreateNode("Vector3")
Return

~4 & LButton::CreateNode("Vector4")
Return

~5 & LButton::CreateNode("Color")
Return

~B & LButton::CreateNode("Split")
Return

~V & LButton::CreateNode("Combine")
Return

; https://github.com/Cyanilux/ShaderGraphVariables
~G & LButton::CreateNode("GetVariable")
Return

; https://github.com/Cyanilux/ShaderGraphVariables
~R & LButton::CreateNode("RegisterVariable")
Return

~K & LButton::CreateNode("ChannelMask")
Return

~X & LButton::CreateNode("Cross")
Return

~. & LButton::CreateNode("DotProduct")
Return

~L & LButton::CreateNode("Lerp")
Return

~N & LButton::CreateNode("Normalize")
Return

~O & LButton::CreateNode("OneMinus")
Return

~P & LButton::CreateNode("Power")
Return

~A & LButton::CreateNode("Add")
Return

~D & LButton::CreateNode("Divide")
Return

~M & LButton::CreateNode("Multiply")
Return

~S & LButton::CreateNode("Subtract")
Return

~T & LButton::CreateNode("SampleTexture2D")
Return

~U & LButton::CreateNode("TillingAndOffset")
Return

#IfWinActive

HookRightMouse(perPosX,perPosY)
{
    ; 获得鼠标当前坐标
    MouseGetPos, curPosX, curPosY

    ; 当前坐标剪去先前坐标
    moveX:=abs(curPosX-perPosX)
    moveY:=abs(curPosY-perPosY)

    ; 如果X大于10，Y大于10, 在当前坐标弹出界面
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
        If (A_Cursor!="IBeam")
        {
            Return
        }
        else
        {
            SendInput, %key%
        }
    }
    else
    {
        Send, {%key% Down}
        KeyWait, %key%
        Send, {%key% Up}
    }
}

ExitScrit:
ExitApp
Return

CreateNode(nodeName)
{
    global nodesPath
    clipSaved:=ClipBoardAll
    FileRead, nodeclip, %nodesPath%\%nodeName%.txt
    Clipboard:=nodeclip
    ClipWait 0.2, 1
    ; WinMenuSelectItem is lag, don't use it
    ;;;;; WinMenuSelectItem, A,, Edit, Paste
    Send, {CtrlDown}v
    Sleep, 10
    Send, {CtrlUp}
    Sleep, 10
    Clipboard:=clipSaved
    ClipWait 0.1, 1
    ; MsgBox, %nodesPath% | %fileName% | %nodeclip%
}
