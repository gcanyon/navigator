script "rev_b_Menu_Limit"
local pVal

on mouseDown
   put the label of me into pVal
end mouseDown
   
on menuPick pItemName
   if pItemName is "Other..." then
      ask the short name of me with pVal
      if the result is empty and it is a number and it <= the pLowerLimit of me and it >= the pUpperLimit of me then 
         put it into pVal
      end if
      set the label of me to pVal
   end if
end menuPick
