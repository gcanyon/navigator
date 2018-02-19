script "rev_f_editProps"
local sProp -- stores the name of the property we're working on
local sWhichLine -- stores the number of the line we're working on

function truncateString S,L
   if L < 6 then return char 1 to L of S
   if length(S) > L then return (char 1 to L - 3 of S) & "..."
   return S
end truncateString

on mouseDown
   put word 2 of the clickline into sWhichLine
   if sWhichLine is empty or the text of me is empty then exit mouseDown
   put line sWhichLine of me into tLineData
   set the itemDelimiter to tab
   put item 1 of tLineData into sProp
   put item 2 of tLineData into tVal
   set the itemDelimiter to comma
   --cSourceID
   if item 1 of the mouseLoc < 125 and the cObjectCount of me > 1 then
      -- do values popup here
      put the cSourceID of me into tSourceID
      put the cCustomProperties of me into customPropertyB
      put the sProp of tSourceID into tIDVal
      if not customPropertyB and tIDVal is empty then put the effective sProp of tSourceID into tIDVal
      put tSourceID into valToID[tIDVal]
      put truncateString(tIDVal,30) into tIDtoVal[tSourceID]
      put -1 into tIDAddCount[tSourceID]
      repeat for each line tID in the cIDList of me
         put the sProp of tID into tIDVal
         if not customPropertyB and tIDVal is empty then put the effective sProp of tID into tIDVal
         if valToID[tIDVal] is empty then 
            put tID into valToID[tIDVal]
            put truncateString(tIDVal,30) into tIDtoVal[tID]
            put 0 into tIDAddCount[tID]
         else
            add 1 to tIDAddCount[valToID[tIDVal]]
         end if
      end repeat
      put the name of tSourceID & iff(tIDAddCount[tSourceID] > 0," +" & tIDAddCount[tSourceID],"") && tIDtoVal[tSourceID] into tMenu
      delete variable tIDtoVal[tSourceID]
      put the keys of tIDtoVal into keyList
      sort lines of keyList
      
      repeat for each line K in keyList
         put cr & the name of K & iff(tIDAddCount[K] > 0," +" & tIDAddCount[K],"") && tIDtoVal[K] after tMenu
      end repeat
      dispatch "doSetup" to btn "propListPopup" with false,sProp,(tSourceID & cr & keyList),customPropertyB,(the cCustomPropertySet of me)
      put tMenu into btn "propListPopup"
      popup btn "propListPopup"
   else if the cCustomProperties of me is true then 
      exit mouseDown
   else
      
      put "u" & sProp into tCProp
      put "u" & word 1 of the cSourceID of me & sProp into tTypeCProp
      if the tCProp of me is empty and the tTypeCProp of me is empty then exit mouseDown
      if the tTypeCProp of me is empty then put the tCProp of me into btn "propListPopup" else put the tTypeCProp of me into btn "propListPopup"
      dispatch "doSetup" to btn "propListPopup" with true
      popup btn "propListPopup"
   end if
end mouseDown


on mouseUp
   --put ticks() && "mu"
   put word 2 of the clickline into sWhichLine
   if sWhichLine is empty or the text of me is empty then exit mouseUp
   put line sWhichLine of me into tLineData
   set the itemDelimiter to tab
   put item 1 of tLineData into tProp
   put item 2 of tLineData into tVal
   if the cCustomProperties of me is not true then
      if tProp is "colors" then
         send "editColors" && quote & the cSourceID of me & quote & comma & the cIDList of me to group "setColors"
      else if char -5 to -1 of tProp is "color" then
         answer color with item 2 of tLineData
         if the result is empty then
            put it into tColor
            put empty into tCMD
            repeat for each line tID in the cIDList of me
               put "set the" && tProp && "of" && tID && "to" && tColor & cr after tCMD
            end repeat
            do tCMD
            put tColor into item 2 of line sWhichLine of me 
         end if
      else if tVal is among the words of "true false" then
         put not tVal into tBoolean
         repeat for each line tID in the cIDList of me
            set the tProp of tID to tBoolean
         end repeat
         put tBoolean into item 2 of line sWhichLine of me
      else 
         put true into showEditor
      end if
      if not showEditor then exit mouseUp
   end if
   
   set the uID of group "editContents" to the long id of me
   put the cSourceID of me into tID
   
   if the cCustomProperties of me is true then
      set the customPropertySet of tID to (the cCustomPropertySet of me)
   else
      set the oneLiner of group "editContents" to (tProp is among the lines of the oneLiners of this stack)
   end if
   
   put tProp into sProp
   put the sProp of tID into tDefaultVal
   set the uDialogText of group "editContents" to tDefaultVal
   send "showMe true" to group "editContents"
   --put value(the clickline)
end mouseUp

on resultMessage pText
  if pText is empty then put fld "setContents" into pText
  setValue pText
end resultMessage

on setValue pText
   repeat for each line tID in the cIDList of me
      if the cCustomProperties of me is true 
      then set the customPropertySet of tID to (the cCustomPropertySet of me)
      
      set the sProp of tID to pText
   end repeat
   set the itemDelimiter to tab
   put line 1 of pText into item 2 of line sWhichLine of me
end setValue
