﻿#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
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

ver:="0.1.0"

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
Menu, Tray, Icon,%A_scriptdir%\tray.ico,, 1
return

UpdateScrit:
    Run, https://github.com/millionart/UnityShaderGraphHelper/releases
Return

#IfWinActive, ahk_class UnityContainerWndClass

    $RButton::
        if WinExist("A")
            ControlGetFocus, curCtrl

        ControlGetText, ctrlTxt, %curCtrl%
        if ctrlTxt=UnityEditor.ShaderGraph.Drawing.MaterialGraphEditWindow
        {
            MouseGetPos, perPosX, perPosY
            Send, {MButton Down}
            KeyWait, RButton ,
            HookRightMouse(perPosX,perPosY,preTime) 
        }
        Else
        {
            Send, {RButton Down}
            KeyWait, RButton
            Send, {RButton Up}
        }
    Return

#IfWinActive

HookRightMouse(perPosX,perPosY,preTime)
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

ExitScrit:
^#p::
ExitApp
Return
