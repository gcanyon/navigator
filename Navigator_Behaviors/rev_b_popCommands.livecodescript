script "rev_b_popCommands"
local sCallerName

on doPopup callerName
   put callerName into sCallerName
   put the baseItems of me into BI
   if the customCommandList of stack "revNavigator" is not empty then put cr & "-" & cr & the customCommandList of stack "revNavigator" after BI
   put lineOffset(the clickAction of grc sCallerName,BI) into LO
   if LO > 0 then put "!c" before line LO of BI
   put BI into me
   popup me
end doPopup

on menuPick pWhich
   --replace space with empty in pWhich
   if the menuHistory of me is 1 then
      dispatch "showMe" to group "commandGroup" with getID(),"popup","command",(the long id of me),"setCommandID"
      --doCommandCode "Command",getID()
   else
      setCommandID pWhich
   end if
end menuPick

on setCommandID C
   repeat for each line N in navigatorList()
      set the clickAction of grc sCallerName of stack N to C
      set the toolTip of grc sCallerName of stack N to C
   end repeat
end setCommandID
