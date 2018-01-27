script "revNavigator_button_popCprop_behavior_2412_Behavior"
local tIDList,tClickedID
local sCustomPropertySet
local sProp -- the name of the property to be set
local sSetMax -- the line number of the last custompropertyset

on mouseDown
   prepareItems
end mouseDown


on prepareItems
   get theHilitedIDs() 
   if it is not tIDList then 
      put empty into sCustomPropertySet
      put it into tIDList
   end if
   if tIDList is empty then
      put "(No Objects Selected" into me
      exit prepareItems
   end if
   put customPropertiesOfAll(tIDList,sCustomPropertySet) into CPa
   put "Empty" & cr before CPa["setList"]
   -- put deDupe(splice(cr,CPa["setList"],sCustomPropertySet),cr) into CPa["setList"]
   set the wholematches to true
   get lineoffset(sCustomPropertySet,CPa["setList"])
   if it is 0 then add 1 to it
   put "!c" before line it of CPa["setList"]
   put 3 + the number of lines of CPa["setList"] into sSetMax
   put sSetMax
   put splice(cr,"Custom Property Editor...","-","New Custom Property Set...",CPa["setList"],"-","New Custom Property...",CPa["customPropList"]) into me
end prepareItems

on menuPick pWhich
   switch
      case the menuhistory of me = 1 
         -- open property editor with custom props here
         break
      case the menuhistory of me = 3
         ask ("New Custom Property Set:")
         if the result is empty then put it into pWhich
      case the menuhistory of me <= sSetMax 
         if the menuhistory of me = 4 then put empty into pWhich
         put pWhich into sCustomPropertySet
         repeat for each line tID in tIDList
            set the custompropertyset of tID to sCustomPropertySet
         end repeat
         break
      case the menuhistory of me = sSetMax + 2
         ask ("New Custom Property Name:")
         if the result is not empty then break
         put it into tProp
         ask ("Set" && sProp && "to:")
         if the result is not empty then break
         put tProp into sProp
         repeat for each line tID in tIDList
            set the sProp of tID to it
         end repeat
         break
      default
         break
         
   end switch
   
   
   
   switch pWhich 
      case "New Custom Property Set..."
         ask ("New Custom Property Set:")
         if the result is empty then put it into sCustomPropertySet
         exit menuPick
      case "New Custom Property..."
         ask ("New Custom Property Name:")
         if the result is not empty then exit menuPick
         put it into sProp
         break
      default
         if the menuhistory of me = 2 then
            put empty into sCustomPropertySet
            exit menuPick
         else if the menuhistory of me <= sSetMax then
            put pWhich into sCustomPropertySet
            exit menuPick
         end if
         put pWhich into sProp
   end switch
   
   put getID(the uClickedLine of this card) into tClickedID
   if not (there is a tClickedID) then put line 1 of tIDList into tClickedID
   if there is a tClickedID then 
      set the customPropertySet of tClickedID to sCustomPropertySet
      put the sProp of tClickedID into tDefaultVal 
   else 
      put "PropertyValue" into tDefaultVal
   end if
   set the uID of group "editContents" to the long id of me
   set the uDialogText of group "editContents" to tDefaultVal
   dispatch "showMe" to group "editContents" with true
end menuPick

on resultMessage
   put fld "setContents" into tText
   repeat for each line tID in tIDList
      --answer splice(cr,sCustomPropertySet,sProp,tID,tText) with "OK"
      set the customPropertySet of tID to sCustomPropertySet
      set the sProp of tID to tText
   end repeat
end resultMessage
