script "revNavigator_button_field_editProps_behavior_2429_Behavior"
local sProp -- stores the name of the property we're working on
local sWhichLine -- stores the number of the line we're working on

on mouseDown
   if the cCustomProperties of me is true then exit mouseDown
   
   put word 2 of the clickline into sWhichLine
   put line sWhichLine of me into tLineData
   set the itemDelimiter to tab
   put item 1 of tLineData into tProp
   put item 2 of tLineData into tVal
   put "u" & tProp into tCProp
   put "u" & word 1 of the cSourceID of me & tProp into tTypeCProp
   if the tCProp of me is empty and the tTypeCProp of me is empty then exit mouseDown
   put tProp into sProp
   if the tTypeCProp of me is empty then put the tCProp of me into btn "propListPopup" else put the tTypeCProp of me into btn "propListPopup"
         popup btn "propListPopup"
end mouseDown


on mouseUp
   --put ticks() && "mu"
   put word 2 of the clickline into sWhichLine
   put line sWhichLine of me into tLineData
   set the itemDelimiter to tab
   put item 1 of tLineData into tProp
   put item 2 of tLineData into tVal
   if the cCustomProperties of me is not true then
      put ticks()
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
      end if
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
