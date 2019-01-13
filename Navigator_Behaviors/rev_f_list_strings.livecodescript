script "rev_f_list_strings"
on selectionChanged
   if notDirty() then
      if the number of items of the hilitedlines of me is 1 then 
         editLine (the hilitedlines of me) 
      end if 
   else
      set the hilitedlines of me to the editingLine of this card
   end if
end selectionChanged
