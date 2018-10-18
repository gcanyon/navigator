script "rev_b_popprop"
global gSBControlSets

local sProp -- the name of the property to be set
local OPA -- objects and properties to edit
local tClickedID -- the object clicked

on mouseDown
  prepareItems
end mouseDown

on prepareItems
   put objectsAndPropertiesToEdit() into OPA -- idList, propList
   put getClickedID() into tClickedID
   if OPA["idList"] is empty then
      put "(No Objects Selected" into me
      exit prepareItems
   end if
   repeat for each line L in OPA["propList"] 
      put empty into TFpropA[L]
   end repeat
   
   repeat for each line tID in OPA["idList"]
      put the properties of tID into tProps
      repeat for each key K in TFpropA
         if tProps[K] is not among the items of "true,false" then
            delete variable TFpropA[K]
            next repeat
         end if
         if tProps[K] is TFpropA[K] then next repeat
         if TFpropA[K] is empty then put tProps[K] into TFpropA[K] else put "Mixed" into TFpropA[K]
      end repeat
   end repeat
   
   put numToCodepoint(8863) & " " into tItem["Mixed"]
   put numToCodepoint(9745) & " " into tItem["True"]
   put numToCodepoint(9723) & " " into tItem["False"]
   
   
   repeat for each line tProp in "Property Editor..." & cr & \
         "Color Editor..." & cr & \
         "Size\/Location Editor..." & cr & \
         "Single Object Inspector" & cr & \
         "Individual Object Inspectors" & cr & \
         "-" & cr & OPA["propList"] 
   put tItem[TFpropA[tProp]] & tProp & cr after tMenuText
end repeat
put tMenuText into me
end prepareItems


on menuPick pWhich
   switch pWhich 
      case "Property Editor..."
         if OPA["idList"] is empty then exit menuPick
         dispatch "setup" to group "editProps" with tClickedID,OPA["idList"],OPA["propList"]
         exit menuPick
      case "Size/Location Editor..."
         dispatch "showMe" to group "resizer" with tClickedID,OPA["idList"] 
         exit menuPick
      case "Color Editor..."
         dispatch "setup" to group "setColors" with tClickedID,OPA["idList"] 
         exit menuPick
      case "Single Object Inspector"
         objectInspector1
         exit menuPick 
      case "Individual Object Inspectors"
         objectInspectorN
         exit menuPick
   end switch
   
   set the itemDelimiter to "|"
   put item 2 of pWhich into tVal
   put item 1 of pWhich into sProp
   if char 2 of sProp is space then 
      delete char 1 to 2 of sProp
      if char 1 of pWhich is numToCodepoint(9745) then resultMessage false 
      else 
         resultMessage true
      end if
   else if tVal is empty then
      if there is a tClickedID then
         if sProp is "name" then put the short name of tClickedID into tDefaultVal else put the sProp of tClickedID into tDefaultVal
         if the commandKey is "down" then
            resultMessage tDefaultVal
            exit menuPick
         end if
      else
         put "PropertyValue" into tDefaultVal
      end if
      set the uID of group "editContents" to the long id of me
      set the uDialogText of group "editContents" to tDefaultVal
      dispatch "showMe" to group "editContents" with true,(sProp is "htmlText"),(sProp is among the lines of the oneLiners of this stack)
   else
      resultMessage tVal
   end if
end menuPick

on resultMessage pText
   if pText is empty then put fld "setContents" into pText
   lock screen
   lock messages
   repeat for each line tID in OPA["idList"]
      try
         set the sProp of tID to pText
      catch someErr
         answer "Error:" && someErr with "Cancel" or "OK"
         if it is "Cancel" then exit repeat
      end try
      add 1 to typeList[word 1 of tID]
   end repeat
   setRecentProp (the keys of typeList),sProp 
end resultMessage
