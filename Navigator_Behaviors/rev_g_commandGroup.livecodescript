script "rev_g_commandGroup"
on setSize
   lock screen
   put the highlight of btn "help" of group "commandControls" of me and the height of this stack > 300 into H
   put the height of this stack - iff(H,217,43) into T
   if H then set the rect of fld "commandHelp" to 0,T+30,the width of this stack,the height of this stack - 13
   set the vis of fld "commandHelp" to H
   set the rect of grp "commandControls" to 0,T,the width of this stack,T + 30
   set the rect of fld "command" to -1,27,the width of this stack + 1,T+2
   set the rect of fld "command title" to 0,15,the width of this stack,29
   dispatch "checkMyScroll" to fld "command"
   unlock screen
end setSize

on showMe
   put getID() into tIDList
   if tIDList is empty then exit showMe
   setCommandIDList ,tIDList
   if (the optionKey is "down") is (the EditorsAsPalettes of stack "revNavigator") then
      setSize
      showGroup (the long id of me)
      select text of fld "command"
   else
      updatePalettes "command palette",true
      select text of fld "command" of stack "revNavigatorp Command Palette"
   end if
end showMe


on setCommandIDList pID,pIDList
   set the pWorkingLines of me to pIDList
   put line 1 of pIDList into pID
   if there is a pID then
      put the number of lines of pIDList into objectCount   
      if objectCount > 1 then put " and" && objectCount - 1 && "others" into commandTitle
      put the name of pID && "[" & the short id of pID & "]" before commandTitle
   else put "Object not found" into commandTitle
   put commandTitle into fld "command title"
end setCommandIDList

on hideMe
   if word 1 of the short name of this stack is "revNavigatorp"
   then close this stack
   else hideGroup the long id of me
end hideMe
