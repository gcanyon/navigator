script "rev_g_editProps"
on setSize
  set the rect of field "Prop Title" to 0,17,(the width of this stack + 2),31
  set the rect of fld "editProps" to -2,32,(the width of this stack + 2),(the height of this stack - 15)
  set the loc of btn "closeProps" to 30,(the height of this stack - 9)
  set the loc of button "propListPopup" to -230,30
end setSize

on setup pID,pIDList,pPropList,pCustomProperties,pCustomPropertySet
   -- pID: source id for properties
   -- pIDList: objects to edit
   -- pPropList: list of properties to edit
   -- pCustomProperties (optional): if true, editing custom properties
   -- pCustomPropertySet (optional): the customPropertySet that the properties are in
   
   if pIDList is empty then exit setup
   set the cIDList of fld "editProps" to pIDList
   if not exists(pID) or pID is not among the lines of pIDList then put line 1 of pIDList into pID
   set the cSourceID of fld "editProps" to pID
   set the cCustomProperties of fld "editProps" to pCustomProperties is true
   set the cCustomPropertySet of fld "editProps" to pCustomPropertySet
   put the name of pID && "[" & the short id of pID & "]" into propTitle
   put the number of lines of pIDList into objectCount
   --put pID & cr & cr & OPA["idList"] & cr & cr & OPA["propList"] ;exit to top
   set the cObjectCount of fld "editProps" to objectCount
   
   if objectCount > 1 then put " and" && objectCount - 1 && "others" after propTitle
   if pCustomProperties is true then put " |" && iff(pCustomPropertySet is empty,"<empty>",pCustomPropertySet) after propTitle
   put propTitle into fld "Prop Title"
   put "<p>" into tag[1]
   put tab & "<font color=" & quote & "#AAAAAA" & quote & ">" into tag[2][true][true]
   put tab into tag[2][false][true]
   put tab & "<b><font color=" & quote & "#AAAAAA" & quote & ">" into tag[2][true][false]
   put tab & "<b>" into tag[2][false][false]
   put "</font></p>" into tag[3][true][true]
   put "</p>" & cr into tag[3][false][true]
   put "</font></b></p>" into tag[3][true][false]
   put "</b></p>" & cr into tag[3][false][false]
   
   if pCustomProperties is not true then 
      put "<b>" after tag[1]
      put "</b>" before tag[2][true][true]
      put "</b>" before tag[2][false][true]
      put "</b>" before tag[2][true][false]
      put "</b>" before tag[2][false][false]
   end if   
   put empty into tHTML
   
   repeat for each line P in pPropList
      if P is "-" and pCustomProperties is not true then 
         delete char -3 to -1 of tag[1]
         delete char 1 to 4 of tag[2][true][true]
         delete char 1 to 4 of tag[2][false][true]
         delete char 1 to 4 of tag[2][true][false]
         delete char 1 to 4 of tag[2][false][false]
         next repeat
      end if
      put true into allSame
      put the P of pID into pIDP
      repeat for each line tID in pIDList
         if the P of tID is pIDP then next repeat
         put false into allSame
         exit repeat
      end repeat
      put the P of pID is empty and pCustomProperties is not true into effectiveB
      if effectiveB
      then put line 1 of the effective P of pID into tProp
      else  put line 1 of the P of pID into tProp
      put tag[1] & P & tag[2][effectiveB][allSame] & tProp & tag[3][effectiveB][allSame] after tHTML
   end repeat
   -- if tHTML is empty then put empty into fld "editProps" of me else 
   set the htmlText of fld "editProps" of me to tHTML
   showMe
end setup

on showMe
   setSize
   
   disableList
   
   show me with visual effect scroll right very fast
end showMe

on hideMe
  hide me with visual effect reveal left very fast
  enableList
end hideMe
