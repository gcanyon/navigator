script "rev_g_List_Action_Buttons"
local cLDS

on mouseDown
   put the label of the target into cLDS
   put the menuItemList of me into the target
end mouseDown
   
on menuPick LDS
   if LDS is not "Other..." then
      set the label of the target to LDS
      exit menuPick
   end if
   
   ask "Action to take:" with cLDS
   if the result is empty then 
      put it into cLDS
      set the menuItemList of me to (line 1 to -2 of the menuItemList of me) & cr & cLDS & cr & "Other..."
   end if
   set the label of the target to cLDS
end menuPick

