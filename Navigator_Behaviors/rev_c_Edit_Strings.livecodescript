﻿script "rev_c_Edit_Strings"
on openCard
   put line 6 to -2 of the text of btn "list display string" of card 1 into fld "list Strings"
   clearEditingLine
end openCard

on clearEditingLine
   set the editingLine of me to empty
   put empty into fld "edit list string"
   updateSample
end clearEditingLine

on updateSample
   put fld "edit list string" into S
   put fld "indent string" of cd 1 into tIS
   repeat with i = 2 to 21
      repeat i - 1
         put tIS after tISa[i]
      end repeat
   end repeat
   if the hilite of btn "Merge"
   then set the htmlText of fld "sample" to evaluateListStringMerge(S,tISa)
   else set the htmlText of fld "sample" to evaluateListString(S)
end updateSample

on speedTestEval
   put fld "edit list string" into S
   put fld "indent string" of cd 1 into tIS
   repeat with i = 8 to 84 step 4
      repeat i div 4 - 1
         put tIS after tISa[i]
      end repeat
   end repeat
   put the long seconds into T
   repeat 100
      get evaluateListStringMerge(S,tISa)
   end repeat
   put the long seconds - T
end speedTestEval

function evaluateListString S,tISa
   if S is empty then put fld "edit list string" into S
   if S is empty then return empty
   put fld "indent string" of cd 1 into tIS
   put S contains "tIS" into hasTis
   try
      repeat with i = 1 to the number of controls of this cd
         put the long id of control i of this cd into tID
         if word 1 of tID is "group" then
            repeat with j = i + 1 to i + the number of controls of tID
               put tIS after tISa[j]
            end repeat
         end if
         put S into sTemp
         if hasTis then replace "tIS" with Q(tISa[i]) in sTemp else put Q(tISa[i]) && "& " before sTemp
         replace "tID" with tID in sTemp
         put "<p>" & value(sTemp) & "</p>" & cr after R
      end repeat
   catch someErr
      return someErr
   end try
   return char 1 to -2 of R
end evaluateListString


function evaluateListStringMerge S,tISa
   put "<p>" & S & "</p>" & cr into S
   try
      repeat with i = 1 to the number of controls of this cd
         put the long id of control i of this cd into tID
         put tISa[wordoffset("stack",tID)] into tIS
         put merge(S) after R
      end repeat
   catch someErr
      return someErr
   end try
   return char 1 to -2 of R
end evaluateListStringMerge

function notDirty
   return the editingLine of me is empty or line (the editingLine of me) of fld "list strings" is fld "edit list string"
end notDirty

on editLine L
   put line L of fld "list strings" into fld "edit list string"
   set the editingLine of me to L
   updateSample
end editLine

on saveLine
   if not notDirty() then put fld "edit list string" into line (the editingLine of me) of fld "list strings" 
end saveLine

on saveStrings
   if notDirty() then
      put the long id of btn "list display string" of card 1 into bID
      set the text of bID to (line 1 to 5 of the text of bID) & cr & fld "list strings" & cr & "Other..."
      go cd 1
   else
      answer "Save or cancel current edit before saving strings." with "OK"
   end if
end saveStrings

on cancelEdit
   if the editingLine of me is not empty then editLine (the editingLine of me)
end cancelEdit

on finishUp 
   if not notDirty() then 
      answer "Discard changes?" with "Cancel" or "Discard"
      if not (it is "Discard") then exit finishUp
   end if
   go cd 1
end finishUp
