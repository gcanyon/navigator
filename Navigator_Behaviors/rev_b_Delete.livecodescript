script "rev_b_Delete"
on mouseUp
   if notDirty() then
      put the hilitedlines of fld "list strings" into hList
      put the number of items of hList into hCount
      if hCount = 0 then exit mouseUp
      answer "Delete the selected" && hCount && "string" & iff(hCount > 1,"s?","?") with "Cancel" or "Delete"
      if it is not "Delete" then exit mouseUp
      put 0 into i
      split hList by comma as set
      repeat for each line L in fld "list strings"
         add 1 to i
         if hList[i] then next repeat
         put L & cr after R
      end repeat
      put char 1 to -2 of R into fld "list strings"
      set the scroll of fld "list strings" to 999999
      clearEditingLine
   else
      answer "Save or cancel current edit before deleting strings." with "OK"
   end if
end mouseUp
