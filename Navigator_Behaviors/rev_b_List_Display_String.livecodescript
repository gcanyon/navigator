script "rev_b_List_Display_String"
local cLDS

on mouseDown
   put the label of me into cLDS
end mouseDown
   
on menuPick LDS
   if LDS is "Other..." then go next
   else put LDS into cLDS
   set the label of me to cLDS
end menuPick
