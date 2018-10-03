script "rev_g_editProps"
on setSize
   --put max(0,the width of this stack - 200) into zeroPoint
   put 0 into zeroPoint
   set the rect of field "Prop Title" to zeroPoint,17,(the width of this stack + 2),31
   set the rect of fld "editProps" to (zeroPoint-2),32,(the width of this stack + 2),(the height of this stack - 15)
   set the loc of btn "closeProps" to (zeroPoint + 30),(the height of this stack - 9)
   if there is a btn "Props Palette" then set the loc of btn "Props Palette" to (zeroPoint + 150),(the height of this stack - 9)
   set the loc of button "propListPopup" to -230,30
end setSize

on setup pID,pIDList,pPropList,pCustomProperties,pCustomPropertySet
   -- pID: source id for properties
   -- pIDList: objects to edit
   -- pPropList: list of properties to edit
   -- pCustomProperties (optional): if true, editing custom properties
   -- pCustomPropertySet (optional): the customPropertySet that the properties are in
   showProps pID,pIDList,pPropList,pCustomProperties,pCustomPropertySet
   showMe
end setup

on showProps pID,pIDList,pPropList,pCustomProperties,pCustomPropertySet
   --put pID && pIDList && pPropList && pCustomProperties,pCustomPropertySet after message; exit to top
   --if pIDList is empty then exit setup
   if pIDList is empty then put pID into pIDList
   if not exists(pID) or pID is not among the lines of pIDList then put line 1 of pIDList into pID
   if not exists(pID) then exit showProps
   --if pID is the cSourceID of fld "editProps" and pIDList is the cIDList of fld "editProps" then exit showProps
   hide fld "propEditor"
   
   if not pCustomProperties and pPropList is empty then
      put objectsAndPropertiesToEdit(pIDList) into OPA
      put OPA["propList"] into pPropList
   end if
   
   set the cIDList of fld "editProps" to pIDList
   set the cSourceID of fld "editProps" to pID
   --put word 1 of the long -- ???
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
      if P is "name" and pCustomProperties is not true then
         put the short name of pID into pIDP
         --put ticks() && pIDP into message
         repeat for each line tID in pIDList
            if the short name of tID is pIDP then next repeat
            put false into allSame
            exit repeat
         end repeat 
      else 
         put the P of pID into pIDP
         repeat for each line tID in pIDList
            if the P of tID is pIDP then next repeat
            put false into allSame
            exit repeat
         end repeat
      end if
      put pIDP is empty and pCustomProperties is not true into effectiveB
      if effectiveB
      then put line 1 of the effective P of pID into tProp
      else  put line 1 of pIDP into tProp
      if P is "htmlText" then put char 4 to -4 of tProp into tProp
      put tag[1] & P & tag[2][effectiveB][allSame] & tProp & tag[3][effectiveB][allSame] after tHTML
   end repeat
   -- if tHTML is empty then put empty into fld "editProps" of me else 
   set the htmlText of fld "editProps" of me to tHTML
end showProps

on showMe
   if (the optionKey is "down") is (the EditorsAsPalettes of stack "revNavigator") then
      setSize
      hide fld "propEditor"
      showGroup (the long id of me)
   else
      updatePalettes "property editor",true
   end if
end showMe

on hideMe
   if word 1 of the short name of this stack is "revNavigatorp"
   then close this stack
   else hideGroup the long id of me
end hideMe
