script "rev_b_List_Font"
local cLDS

on mouseDown
   put the label of me into cLDS
end mouseDown
   
on menuPick LDS
   if LDS is not "Other..." then
      set the label of me to LDS
      exit menuPick
   end if
   
   ask "List Display String:" with cLDS
   if the result is empty then 
      put it into cLDS
      set the text of me to (line 1 to -2 of the text of me) & cr & cLDS & cr & (line -1 of the text of me)
      set the label of me to LDS
   end if
   set the label of me to cLDS
end menuPick
