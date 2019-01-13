script "rev_b_Duplicate"
on mouseUp
   if notDirty() then
      repeat for each item i in the hilitedlines of fld "list strings"
         put cr & (line i of fld "list strings") after R
      end repeat
      if R is not empty then put R after fld "list strings"
      set the scroll of fld "list strings" to 999999
   else
      answer "Save or cancel current edit before saving strings." with "OK"
   end if
end mouseUp
