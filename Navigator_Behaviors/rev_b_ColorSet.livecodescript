script "rev_b_ColorSet"
local pSet

on mouseDown
   put the label of me into pSet
end mouseDown
   
on menuPick pItemName
   if pItemName is "Save Current..." then
      ask "Save current colors as:" with "Set Name" 
      if the result is "Cancel" then 
         set the label of me to pSet
         exit menuPick
      else
         put it into CSname
         repeat for each line CGid in the childcontrolids of the owner of me
            if word 1 of the name of control id CGid of the owner of me is not "graphic" then next repeat
            put the short name of control id CGid of the owner of me into CN
            put CN,(the backgroundcolor of control id CGid of the owner of me) & cr after colorList
         end repeat
         put "u" before CSname
         set the CSname of the owner of me to colorList
         buildColorSetMenu
         set the label of me to CSname
      end if
   else
      put "u" before pItemName
      put the long id of the owner of me into oID
      put the pItemName of oID into propList
      repeat for each line CS in propList
         set the backgroundColor of grc (item 1 of CS) to item 2 to -1 of CS
      end repeat
   end if
end menuPick
