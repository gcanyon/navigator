﻿script "rev_b_popup"
local gSBLastCopiedObjectList -- a list of the IDs of the last copied objects 


local tClickedLine -- the line the user clicked on
local tClickedID -- the id of the object the user clicked on
local sSearchString -- the search string for finding in enclosed scripts
local sCondition -- the condition for finding enclosed by test

local sClickedID -- new local to store universally within this script the id that was clicked
local sHighlightedList -- new local to store universally within this script the ids highlighted when click occurred

on menuPick pWhich
   --global gRevDevelopment;put true into gRevDevelopment
   --breakpoint
   put false into tGo
   put false into tSave
   put false into tBrowseControls
   put false into tOpenInNewNavigator
   put word 2 of the clickLine into tClickedLine
   if tClickedLine is empty then put the uClickedLine of this card into tClickedLine
   put getIDFirst(tClickedLine) into tClickedID
   switch pWhich
      case "Export to Behaviors"
         get convertToScriptOnlyStackBehaviorsAutomatic(sHighlightedList)
         break
      case "Edit Behavior Script"
      case "Edit Behavior Scripts"
         editObjectScripts ,true
         break
      case "Copy|IDs"
         set the clipboardData["text"] to theHilitedIDs()
         break
      case "Select Objects"
         put "select" && getID() into tCMD
         replace cr with " and " in tCMD
         do tCMD
         break
      case "Copy|Objects"
         put "copy " into tCMD
         put theHilitedIDs() into tList
         repeat for each line tID in tList
            if word 1 of tID is not "stack" then put tID && "and " after tCMD
         end repeat
         if length(tCMD) > 5 then do char 1 to -6 of tCMD
         put tList into gSBLastCopiedObjectList
         break
      case "Paste Objects"
         repeat for each line L in gSBLastCopiedObjectList
            copy L to tClickedID
         end repeat
         break
      case "Place Background"
      case "Place Backgrounds"
         put theHilitedIDs() into tIDTargetList
         repeat for each line tID in gSBLastCopiedObjectList
            if word 1 of tID is not "group" then next repeat
            put "background id" && word 3 of tID && word -3 to -1 of tID into tBackgroundID
            put word -1 of tBackgroundID into tCopiedToList
            repeat for each line tTargetID in tIDTargetList
               if word 1 of tTargetID is not "card" then next repeat
               if word -1 of tTargetID is among the lines of tCopiedToList then
                  put tBackgroundID into tPlaceID
               else
                  put cr & word -1 of tTargetID after tCopiedToList
                  put word -2 to -1 of line 1 of tTargetID into tStackRef
                  copy tBackgroundID to tStackRef
                  put it into tPlaceID
               end if
               try
                  place tPlaceID onto tTargetID
               catch tSomeErr
               end try
            end repeat
         end repeat
         send ("updateDisplay") to me in 6 ticks
         break
      case "Remove Group"
      case "Remove Groups"
         repeat for each line tID in theHilitedIDs()
            if word 1 of tID is not "group" then next repeat
            set the wholeMatches to true
            put wordoffset("card",tID) into tS
            put "remove" && tID && "from" && word tS to -1 of tID into tCMD
            try
               do tCMD
            catch tErr
            end try
         end repeat
         send ("updateDisplay") to me in 6 ticks
         break
      case "Make Copied Stack a SubStack"
      case "Make Copied Stacks into SubStacks"
         repeat for each line stackID in gSBLastCopiedObjectList
            set the mainstack of stackID to the short name of tClickedID
         end repeat
         break
      case "Copy|Text"
         set the clipboardData["text"] to the selectedText of fld "list"
         break
      case "Copy|Names"
      case "Put"
         put empty into tRefs
         repeat for each line tID in theHilitedIDs()
            if the useNames of this stack or pWhich is "copy|names" then
               put (the abbreviated name of tID) & cr after tRefs
            else
               put (the abbreviated id of tID) & cr after tRefs
            end if
         end repeat
         if pWhich is "copy|names" then
            set the clipboardData["text"] to char 1 to -2 of tRefs
         else
            put char 1 to -2 of tRefs
         end if
         break
      case "Edit Button Contents..."
         send "editButton" to group "editContents"
         break
      case "Edit Field Contents..."
         send "editField" to group "editContents"
         break
      case "Rename..."
         renameObjects
         break
      case "Delete"
         deleteObjects
         break
      case "Clone"
         cloneObjects
         break
      case "Group"
         lock screen
         put getID() into tIDList
         put word 5 to -1 of line 1 of tIDList into tOwner
         repeat for each line L in tIDList
            if word 5 to -1 of L is not tOwner then 
               answer warning "You can only group controls that share a container." with "OK"
               break
            end if 
         end repeat
         put simpleID(tOwner) into tOwner
         put simpleID(tIDList) into tIDList
         if word 1 of tOwner is "group" then 
            try
               set the defaultstack to value(word -1 of tOwner)
               start editing tOwner
            catch pError
               put tOwner && pError
               exit to top
            end try
         end if
         replace cr with " and " in tIDList
         put "group " before tIDList
         --set the relayerGroupedControls to true
         try
            do tIDList
         catch pError
            answer ("Group failed:" && pError)
            debug pError,tIDList
         end try
         if word 1 of tOwner is  "group" then 
            put "background" into word 1 of tOwner
            if word -5 of tOwner is "stack" then
               delete word 4 to -7 of tOwner
               delete word -3 to -1 of tOwner
            else
               delete word 4 to -4 of tOwner
            end if
            stop editing tOwner
         end if
         unlock screen
         updateDisplay true
         break
      case "Find|In Scripts..."
      case "Find|In Scripts and Behaviors..."
      case "Find|In Enclosed Scripts..."
      case "Find|In Enclosed Scripts and Behaviors..."
      case "Find|By Test..."
      case "Find|By Test with Behaviors..."
      case "Find|In Enclosed By Test..."
      case "Find|In Enclosed with Behaviors By Test..."
      case "Scripts|Count"
      case "Scripts|Count with Behaviors"
      case "Scripts|Count Enclosed"
      case "Scripts|Count Enclosed with Behaviors"
      case "Scripts|Copy"
      case "Scripts|Copy with Behaviors"
      case "Scripts|Copy Enclosed"
      case "Scripts|Copy Enclosed with Behaviors"
         put getID() into tIDList
         if pWhich contains "Enclosed" then put allUniqueIDsOf(tIDList) into tIDList
         if pWhich contains "Behaviors" then put addBehaviorChains(tIDList) into tIDList
         
         if char 1 to 4 of pWhich is "Find" then
            if pWhich contains "By Test"
            then bookmarkFoundByTestControls ,tIDList
            else bookMarkFoundInScriptControls ,tIDList
         else      
            if pWhich contains "Count"
            then reportScripts tIDList
            else copyScripts tIDList
         end if
         break    
      case "Set Copied Img as WindowShape"
         put word 3 of gSBLastCopiedObjectList into tShortID
         repeat for each line tID in theHilitedIDs()
            if word 1 of tID is not "stack" then next repeat
            set the windowShape of tID to tShortID
         end repeat
         break
      case "Set Copied Img as Icon"
         put word 3 of gSBLastCopiedObjectList into tShortID
         repeat for each line tID in theHilitedIDs()
            if word 1 of tID is not "button" then next repeat
            set the icon of tID to tShortID
         end repeat
         break
      case "Set As WindowShape"
         put getIDFirst(tClickedLine) into tID
         put word -2 to -1 of tID into tStack
         put the short name of tStack into tStack
         set the windowShape of stack tStack to (word 3 of tID)
         break
      case "Export As..."
         put getIDFirst(tClickedLine) into tID
         ask file "Export As:"
         if it is empty then break
         put it into FP
         set the itemdel to "."
         put item -1 of FP into X
         if X is "JPG" then put "JPEG" into X
         switch X
            case "JPG"
            case "JPEG"
               export tID to file FP as JPEG
               break
            case "GIF"
               export tID to file FP as GIF
               break
            case "BMP"
               export tID to file FP as BMP
               break
            case "PNG"
               export tID to file FP as PNG
               break
            default
               export tID to FP
         end switch
         break
      case "Set Image As Icon"
         put word 3 of getIDFirst(tClickedLine) into tIconID
         repeat for each line tID in getID()
            if word 1 of tID is not "button" then next repeat
            set the icon of tID to tIconID
         end repeat
         break
      case "Set Copied Btn as Behavior"
         doCodeN1 "set the behavior of xID to the long id of yID",getID(),(line 1 of gSBLastCopiedObjectList); break
      case "Resize..."
         dispatch "showMe" to group "resizer" with tClickedID,getID(); break
      case "Property Editor..."
         put objectsAndPropertiesToEdit() into P
         dispatch "setup" to group "editProps" with tClickedID,P["idList"],P["propList"]; break
      case "Single Object Inspector"
         objectInspector1; break
      case "Individual Object Inspectors"
         objectInspectorN; break     
      case "Edit Colors..."
         dispatch "setup" to group "setColors" with tClickedID
         --put "setup" && quote & tClickedID & quote into tMSG
         --send tMSG to group "setColors"
         break
      case "Align Objects..."
         revIDEInspectObjects
         send "InspectorSectionChanged" && quote & "Align Controls" & quote to stack (line 1 of the openstacks)
         break
      case "Edit Scripts"
         editObjectScripts; break      
      case "Bookmark"
         setBookmarks;break
      case "Remove"
         removeBookmarks; break
      case "Open in New Navigator"
         repeat for each line tID in getID()
            if not (word 1 of tID is among the items of "group,card,stack") then next repeat
            if word 1 of tID is "stack" then put "this card of " after newNavContainerList
            put tID & cr after newNavContainerList
         end repeat
         if newNavContainerList is not empty then get newNavigator(newNavContainerList)
         break
      case "Browse Controls"
         setNavigatorTarget ,getID(,true),(the shiftkey is "down");break
      case "Browse Cards"
      case "Browse Backgrounds"
         put char 1 to -2 of word 2 of pWhich into tType
         put tType && "list of" && getID() into idList
         replace cr with cr & tType && "list of " in idList
         --put idList;break
         setNavigatorTarget ,idList,(the shiftkey is "down");break
      case "Stop Browsing"
         repeat for each line lineNo in the hilitedlines of field "list"
            put getList(false,lineNo) into tID
            if word 1 of tID is "stack" then put getList(false,lineNo + 1) into tID 
            put tID & cr after tIDList
         end repeat
         removeNavigatorTarget ,(char 1 to -2 of tIDList);break
      case "Save All"
         if pWhich is "Save All" then put true into tSaveAll
      case "Save"
         if pWhich is "Save" then put true into tSave
      case "Save StackFiles"
         if pWhich is "Save StackFiles" then put true into tSaveStackFiles
      case "Reload Script-only Stacks"
         if pWhich is "Reload Script-only Stacks" then put true into tReloadScriptonlyStacks
      case "Go|LM Go"
         put true into tLockMessages
      case "Go|Go"
         put true into tGo
      case "Go|LM TopLevel"
         if pWhich is "Go|LM TopLevel" then put true into tLockMessages -- have to check because could be dropping through
      case "Go|TopLevel"
         put true into tTopLevel
      case "Go|Show"
         put empty into reloadConfirmed
         put getID() into tIDList
         
         repeat for each line tID in tIDList
            if not (word 1 of tID is among the items of "bkgnd,group,card,stack") then next repeat
            try
               if word 1 of tID is among the items of "group,bkgnd" then
                  -- no point in continuing, can't save or go
               else if tSaveAll and word 1 of tID is "stack" then
                  saveAll tID
               else if tSave and word 1 of tID is "stack" then save tID
               else if tSaveStackFiles and word 1 of tID is "stack" then
                  repeat for each line tStackIDLine in the stackFiles of tID
                     -- put item 1 of tStackIDLine
                     save stack (item 1 of tStackIDLine)
                  end repeat
               else if tReloadScriptonlyStacks and word 1 of tID is "stack" then
                  if reloadConfirmed is empty then put answerf("Reload script-only stacks from file?" & cr & "Any changes made will be lost.","warning",,"Cancel","Reload") into reloadConfirmed
                  if reloadConfirmed is "Cancel" then exit menuPick
                  repeat for each line tStackIDLine in the stackFiles of tID
                     put item 1 of tStackIDLine into tStackFileStack
                     if there is a stack tStackFileStack and the scriptonly of stack tStackFileStack then delete stack tStackFileStack
                  end repeat
               else if tGo then
                  if tLockMessages is "true" or the optionKey is "down" then lock messages
                  go tID
                  --put "lm go" && the lockMessages && ticks()
               else if tTopLevel then
                  if tLockMessages is "true" or the optionKey is "down" then lock messages
                  topLevel tID
               else -- show by default
                  go tID
                  if word 1 of tID is "card" then delete word 1 to 4 of tID
                  set the loc of tID to the screenloc
                  show tID
               end if
            catch someErr
               --set the textColor of line tItem of fld "list" of this stack to the pColorObjectMissing of this stack
            end try
         end repeat
         break
      case "Purge Stack..."
         put the hilitedLines of fld "list" into tLines
         repeat for each line tID in getID()
            if word 1 of tID is not "stack" then next repeat
            put the effective fileName of tID into tStackPath
            if tStackPath is empty then put the mainStack of tID into tStackpath
            put the mainStack of stack tStackPath into tStacks
            put the subStacks of stack tStackPath & cr before tStacks
            answer warning "Really remove the stack file" && tStackPath && "from memory?" & cr & "Any changes made since saving will be lost from the following stacks:" & cr & cr & tStacks with "Cancel" or "Remove"
            if it is "Cancel" then exit menuPick
            repeat for each line l in tStacks
               if there is a stack l then delete stack l
            end repeat
         end repeat
         get checkCurrentNavTarget(,,true)
         break
      case "Remove All"
         removeAllBookmarks; break
      case "Color..."
         put the textColor of the clickLine into tColor
         ask "Set color to:" with tColor
         if the result is not empty then break
         put it into tColor
         put the separatorLine of fld "list" into tSeparator
         put the hilitedLines of fld "list" into tLineList
         repeat for each item tLine in tLineList
            if tLine > tSeparator then exit repeat
            set the textColor of line tLine of fld "list" to tColor
         end repeat
         break
      case "Bookmark Text..."
         put the separatorLine of fld "list" into tSeparator
         put the hilitedLines of fld "list" into tLineList
         repeat for each item tLine in tLineList
            if tLine > tSeparator then exit repeat
            ask "Set the bookmark text to:" with word 1 to -1 of line tLine of fld "list"
            if the result is not empty then exit repeat
            put (the leadSpaces of stack "revNavigator") & word 1 to -1 of it into line tLine of fld "list"
         end repeat
         set the hilitedLines of fld "list" to tLineList; break
      case "Command..."
         send "showMe" to group "commandGroup"; break
      default
         set the itemDelimiter to "|"
         if item 1 of pWhich is "Fold Depth" then
            put getIDFirst(tClickedLine) into tID
            if item 2 of pWhich is "Show All" then put 999999 into tFoldDepth else put item 2 of pWhich into tFoldDepth
            setFoldDepth tID,tFoldDepth
            updateDisplay true,true
         else if item 1 of pWhich is among the items of "substacks|mainstack" then
            put item 2 of pWhich into tStackName
            if tStackName is "New Substack..." then
               repeat
                  ask "New substack name:"
                  if the result is cancel then exit repeat
                  put it into newSubstackName
                  try
                     create stack newSubstackName
                     set the mainstack of stack newSubstackName to (the short name of tClickedID)
                     put newSubstackName into tStackName
                     exit repeat
                  catch someErr
                     answer warning someErr with "OK"
                  end try
               end repeat
            end if
            if there is a stack tStackName then setNavigatorTarget ,(the name of stack tStackName),(the shiftkey is "down")
         end if
         if item 1 of pWhich is "Command" then doCommandCode commandRead(item 2 of pWhich)
   end switch
end menuPick

on reportScripts tIDList
   put 0 into tObjectCount
   put 0 into tCharSize
   put 0 into tLineCount
   put 0 into tScriptCount
   put cr into detailedScriptReport
   repeat for each line cID in tIDList
      if not exists(cID) then next repeat
      add 1 to tObjectCount
      put length(the script of cID) into scriptCharCount
      if scriptCharCount = 0 then next repeat
      add scriptCharCount to tCharSize
      put the number of lines of the script of cID into scriptLineCount
      add scriptLineCount to tLineCount
      put cr & cr & (the long name of cID) & cr & cID & cr & "Script Line Count:" && scriptLineCount && "Script Length:" && scriptCharCount after detailedScriptReport 
      add 1 to tScriptCount
   end repeat
   put "The size of the scripts is:" & cr & tCharSize && "characters in" & cr & tLineCount && "lines in" & cr & tScriptCount && "scripts in" & cr & tObjectCount && "objects." into tScriptReport
   if tScriptCount = 0
   then answer "No scripts found." with "OK"
   else answer tScriptReport with "Copy Detailed Script Report" or "OK"
   if it is "Copy Detailed Script Report" then 
      set clipboardData["text"] to tScriptReport & detailedScriptReport
      answer "Detailed script report copied." with "OK"
   end if
   
end reportScripts

on copyScripts tIDList
   repeat for each line cID in tIDList
      if not exists(cID) then next repeat
      add 1 to tObjectCount
      get length(the script of cID)
      if it = 0 then next repeat
      add 1 to tScriptCount
      put "------------------------------------------------------------" & \
            cr & "------------------------------------------------------------" & \
            cr & "--" && the long name of cID & \
            cr & "--" && cID & \
            cr & "------------------------------------------------------------" & \
            cr & "------------------------------------------------------------" & \
            cr & cr & the script of cID & cr & cr & cr & cr after scriptsToCopy
   end repeat
   set clipboardData["text"] to scriptsToCopy
   answer "Copied" && tScriptCount && "scripts from" && tObjectCount && "objects." with "OK"
end copyScripts


on prepareItems
   put the hilitedlines of field "list" into tLines
   put getID() into tIDList
   put tIDList into sHighlightedList -- local to store universally within this script the ids highlighted when click occurred
   put word 2 of the clickLine into tClickedLine
   if tClickedLine is empty then put the uClickedLine of this card into tClickedLine
   put getID(tClickedLine) into sClickedID --  local to store universally within this script the id that was clicked
      
   put the basicItems of btn "popup" into tItems
   put the customCommandSubmenu of stack "revNavigator" after tItems
   put true into allBehaviors
   put true into tContainer
   if word 1 of tIDList is "bkgnd" then put "group" into tObjectType else put word 1 of tIDList into tObjectType
   put true into noCardStack
   put true into exportToBehaviors
   
   repeat for each line tID in tIDList
      if word 1 of tID is "bkgnd" then put "group" into tIDType else put word 1 of tID into tIDType
      if tObjectType is not "mixed" and tIDType is not tObjectType then put "mixed" into tObjectType
      if allBehaviors and the behavior of tID is empty then put false into allBehaviors
      if exportToBehaviors and the behavior of tID is not empty then put false into exportToBehaviors
      if tContainer and tIDType is not among the items of "card,stack,group" then put false into tContainer
      if noCardStack and tIDType is among the items of "card,stack" then put false into noCardStack
      if tObjectType is "mixed" and not allBehaviors and not tContainer and not noCardStack and not exportToBehaviors then exit repeat
   end repeat
   
   --put tObjectType into message
   
   if exportToBehaviors then
      put uniqueStacksFromIDs(tIDList,true) into parentStackList
      repeat for each line stackName in parentStackList
         put the customPropertySet of stack stackName into prevSet
         set the customPropertySet of stack stackName to "navSoStackSettings"
         put the customproperties of stack stackName into templateArray[stackName]
         set the customPropertySet of stack stackName to prevSet
         if templateArray[stackName]["template"] is not empty then next repeat
         put false into exportToBehaviors
         exit repeat
      end repeat
   end if
   
   
   if tContainer and tObjectType is "mixed" then put "container" into tObjectType
   if the number of items of tLines > 1 then put "multi" before tObjectType
   put true into noStacks
   put true into noCards
   put word 1 of gSBLastCopiedObjectList into tCopiedType
   repeat for each line tID in gSBLastCopiedObjectList
      if noStacks and word 1 of tID is "stack" then put false into noStacks
      if noCards and word 1 of tID is "card" then put false into noCards
      if tCopiedType is not "mixed" and word 1 of tID is not tCopiedType then put "mixed" into tCopiedType
      if tCopiedType is "mixed" and not noStacks and not noCards then exit repeat
   end repeat
   if tCopiedType is "mixed" and noStacks and noCards then put "object" into tCopiedType
   if the number of lines of tCopiedType > 1 then put "multi" before tCopiedType
   if noCardStack then put "Align Objects..." & cr before tItems
   if tObjectType = "stack" then
      if the mainstack of tIDList is the short name of tIDList then
         put the substacks of tIDList into tSubstacks
         if tSubstacks is not empty then
            replace cr with cr & tab in tSubstacks
            put tab & tSubstacks & cr before tItems
         end if
         put "SubStacks" & cr & tab & "New Substack..." & cr before tItems
      else
         put "MainStack" & cr & tab & the mainstack of tIDList & cr before tItems
      end if
   end if
   if item 1 of tLines > the separatorLine of fld "list" then
      put the liveItems of me before tItems
   else if item -1 of tLines <= the separatorLine of fld "list" then
      put the bookmarkItems of me before tItems
   end if
   if exportToBehaviors then put "Export to Behaviors" & cr before tItems
   if tCopiedType is "button" then put "Set Copied Btn as Behavior" & cr before tItems
   -- put tObjectType && tCopiedType
   put tObjectType & "Items" into uProp1
    --put uProp1 into message
   if tCopiedType is not empty then put tObjectType & tCopiedType & "Items" into uProp2
   put the uProp1 of me & the uProp2 of me before tItems
   
   --    maybe?
   if noStacks and tCopiedType is not empty and \
         ((tContainer and noCards) or (char -5 to -1 of tObjectType is "stack" and char -4 to -1 of tCopiedType is "card"))\
   then put "Paste Objects" & cr before tItems
   --/maybe?
   set the wholeMatches to true
   
   if tContainer then put "Open in New Navigator" & cr before line lineOffset("-",tItems) of tItems
   
   
   if allBehaviors then put "Edit Behavior Scripts" & cr before tItems
   put tItems into me
end prepareItems

