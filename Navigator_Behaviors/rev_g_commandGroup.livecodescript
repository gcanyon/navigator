script "rev_g_commandGroup"
local callbackID,callbackMessage

on setSize
   lock screen
   put the width of this stack into W
   put the height of this stack into H
   if H < 300 then set the highlight of btn "help" of group "commandControls" of me to false
   put the highlight of btn "help" of group "commandControls" of me into SH
   put H - iff(SH,217,43) into T
   if SH then set the rect of fld "commandHelp" to 0,T+30,W,H - 13
   set the vis of fld "commandHelp" to SH
   set the rect of grc "commandScreen" to 0,15,W,H - 13
   set the rect of grp "commandControls" to 0,T,W,T + 30
   set the rect of btn "CommandTab" to 0,30,W,T
   set the rect of fld "command" to -1,50,W + 1,T+2
   set the rect of fld "command title" to 0,15,W,29
   dispatch "checkMyScroll" to fld "command"
   unlock screen
end setSize

on showMe tIDList,forceStyle,forceTab,saveCallBackID,saveCallbackMessage
   if tIDList is empty then put getID() into tIDList
   if ((the optionKey is "down") is (the EditorsAsPalettes of stack "revNavigator") or forceStyle is "popup") and forceStyle is not "palette" then
      doSetup forceTab,saveCallBackID,saveCallbackMessage
      setSize
      setCommandIDList ,tIDList
      showGroup (the long id of me)
   else
      updatePalettesWithID "command palette",true,empty,tIDList
      dispatch "doSetup" to group "commandGroup" of stack "revNavigatorp Command Palette" with forceTab,saveCallBackID,saveCallbackMessage
   end if
end showMe

on doSetup forceTab,saveCallBackID,saveCallbackMessage
   select text of fld "command"
   if forceTab is not empty then 
      put offset(forceTab,button "commandTab") into OT
      if OT > 0 then set the menuHistory of button "commandTab" to OT
      --set the label of button "commandTab" to forceTab
      --dispatch "menuPick" to button "commandTab" with forceTab
   end if
   put saveCallbackID into callbackID
   put iff(saveCallbackMessage = empty,"saveResult",saveCallbackMessage) into callbackMessage
end doSetup

on doCallBack C
   if callbackID is not empty then dispatch callbackMessage to callbackID with C
end doCallBack


on setCommandIDList pID,pIDList
   set the pWorkingLines of me to pIDList
   put line 1 of pIDList into pID
   if there is a pID then
      put the number of lines of pIDList into objectCount   
      if objectCount > 1 then put " and" && objectCount - 1 && "others" into commandTitle
      put the name of pID && "[" & the short id of pID & "]" before commandTitle
   else put "Object not found/no object selected" into commandTitle
   put commandTitle into fld "command title"
end setCommandIDList

on hideMe
   if word 1 of the short name of this stack is "revNavigatorp"
   then close this stack
   else hideGroup the long id of me
end hideMe
