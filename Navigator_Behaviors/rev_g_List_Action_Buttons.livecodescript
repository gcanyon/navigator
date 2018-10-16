script "rev_g_List_Action_Buttons"
local cLDS,targetID

on mouseDown
   put the long id of the target into targetID
   put the label of targetID into cLDS
   put the menuItemList of me into the target
end mouseDown
   
on menuPick LDS
   if the menuHistory of the target > 1 then
      set the label of the target to LDS
   else
      dispatch "showMe" to group "commandGroup" of stack "revNavigator" with empty,"palette","command",(the long id of me),"setCommandID"
      set the label of the target to cLDS
      buildActionsList
   end if
   
   
   --    ask "Action to take:" with cLDS
   --    if the result is empty then 
   --       put it into cLDS
   --       set the menuItemList of me to (line 1 to -2 of the menuItemList of me) & cr & cLDS & cr & "Other..."
   --    end if
   --    set the label of the target to cLDS
end menuPick

on setCommandID  tCommand
   set the label of targetID to tCommand
end setCommandID
