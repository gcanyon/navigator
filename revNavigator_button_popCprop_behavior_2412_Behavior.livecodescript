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
      put it into tIDList
      put false into setExists
      repeat for each line tID in tIDList
         if  sCustomPropertySet is not among the lines of the custompropertysets of tID then next repeat
         put true into setExists
         exit repeat
      end repeat
      if not setExists then put empty into sCustomPropertySet
   end if
   if tIDList is empty then
      put "(No Objects Selected" into me
      exit prepareItems
   end if
   put customPropertiesOfAll(tIDList,sCustomPropertySet) into CPa
   put splice(cr,"<Empty>",CPa["setList"]) into cPropSetList
   -- if CPa["setList"] is empty then put "Empty" into cPropSetList else put "Empty" & cr & CPa["setList"] into 
   -- put deDupe(splice(cr,CPa["setList"],sCustomPropertySet),cr) into CPa["setList"]
   set the wholematches to true
   get lineoffset(sCustomPropertySet,cPropSetList)
   if it is 0 then add 1 to it
   put "!c" before line it of cPropSetList
   put 4 + the number of lines of cPropSetList into sSetMax
   put sSetMax
   put splice(cr,"Custom Property Editor...","-","New Custom Property Set...","(Option//Alt to Delete",cPropSetList,"-","New Custom Property...","(Option//Alt to Delete",CPa["customPropList"]) into me
end prepareItems

on menuPick pWhich
   switch
      case the menuhistory of me = 1 
         put getID(the uClickedLine of this card) into tClickedID
         if not (there is a tClickedID) then put line 1 of tIDList into tClickedID
         if not there is a tClickedID then break
         --on setup pID,pIDList,pPropList,pCustomProperties,pCustomPropertySet
         set the custompropertyset of tClickedID to sCustomPropertySet
         put the customkeys of tClickedID into cPropList
         sort lines of cPropList
         
         dispatch "setup" to group "editProps" with tClickedID,tIDList,cPropList,true,sCustomPropertySet
         break
      case the menuhistory of me = 3
         ask ("New Custom Property Set:")
         if the result is empty then put it into pWhich
      case the menuhistory of me <= sSetMax 
         if the menuhistory of me = 5 then put empty into pWhich
         if the menuhistory of me > 5 and the optionkey is "down" then
            answer warning "Delete custom property set" && Q(pWhich) & "?" with "Cancel" or "Delete"
            if it is "Delete" then 
               repeat for each line tID in tIDList
                  put the custompropertysets of tID into setList
                  filter setList without pWhich
                  set the custompropertysets of tID to setList
               end repeat
            end if
            exit menuPick
         else
            put pWhich into sCustomPropertySet
            repeat for each line tID in tIDList
               set the custompropertyset of tID to sCustomPropertySet
            end repeat
         end if
         break
      default
         if the menuhistory of me = sSetMax + 2 then
            ask ("New Custom Property Name:")
            if the result is not empty then break
            put it into sProp
         else if the optionkey is "up" then
            put pWhich into sProp
         else
            answer warning "Delete custom property" && Q(pWhich) & "?" with "Cancel" or "Delete"
            if it is not "Delete" then exit menuPick
            repeat for each line tID in tIDList
               set the customPropertySet of tID to sCustomPropertySet
               put the customproperties of tID into tempArray
               delete variable tempArray[pWhich]
               set the customproperties of tID to tempArray
            end repeat
            put empty into sProp
            exit menuPick
         end if
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
   end switch
   
end menuPick

on resultMessage
   put fld "setContents" into tText
   repeat for each line tID in tIDList
      --answer splice(cr,sCustomPropertySet,sProp,tID,tText) with "OK"
      set the customPropertySet of tID to sCustomPropertySet
      set the sProp of tID to tText
   end repeat
end resultMessage
