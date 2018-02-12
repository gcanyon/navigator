script "rev_b_popprop"
global gSBControlSets

local tIDList
local sProp -- the name of the property to be set
local OPA -- objects and properties to edit

on mouseDown
  prepareItems
end mouseDown

on prepareItems
   put objectsAndPropertiesToEdit() into OPA -- idList, propList
   put OPA["idList"] into tIDList
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
   
   put format("\tTrue\n\tFalse\n") into tItem["Mixed"]
   put format("!c\tTrue\n\tFalse\n") into tItem["True"]
   put format("\tTrue\n!c\tFalse\n") into tItem["False"]
   
   repeat for each line tProp in "Property Editor..." & cr & \
         "Object Inspector \(1\)" & cr & \
         "Object Inspector \(N\)" & cr & \
         "-" & cr & OPA["propList"]
      put tProp & cr & tItem[TFpropA[tProp]] after tMenuText
   end repeat
   put tMenuText into me
end prepareItems


on menuPick pWhich
   switch pWhich 
      case "Property Editor..."
         if OPA["idList"] is empty then exit menuPick
         dispatch "setup" to group "editProps" with getClickedID(),OPA["idList"],OPA["propList"]
         exit menuPick
      case "Object Inspector (1)"
         objectInspector1
         exit menuPick 
      case "Object Inspector (N)"
         objectInspectorN
         exit menuPick
   end switch
   
   set the itemDelimiter to "|"
   put item 1 of pWhich into sProp
   put item 2 of pWhich into tVal
   if tVal is empty then
      put getID(the uClickedLine of this card) into tClickedID
      if there is a tClickedID then
         put the sProp of tClickedID into tDefaultVal
      else
         put "PropertyValue" into tDefaultVal
      end if
      set the uID of group "editContents" to the long id of me
      set the oneLiner of group "editContents" to (sProp is among the lines of the oneLiners of this stack)
      set the uDialogText of group "editContents" to tDefaultVal
      dispatch "showMe" to group "editContents" with true
   else
      resultMessage tVal
   end if
end menuPick

on resultMessage pText
   if pText is empty then put fld "setContents" into pText
   lock screen
   lock messages
   repeat for each line tID in tIDList
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
