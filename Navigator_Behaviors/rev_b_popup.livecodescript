script "rev_b_popup"
global gLastLineClicked
global gSBlastHilitedLines,gSBshowTooltip

global gSBLeadSpaces,gSBControlSets

global gSBCardOrBackground -- are we displaying card controls or group controls
global gSBWhichCard -- which card are we displaying
global gSBWhichStack -- which stack are we displaying
global gSBWhichBackground -- which background/group are we displaying
global gSBShowList -- true: show list of cards or bgs | false: show controls
global gSBLastCopiedObjectList -- a list of the IDs of the last copied objects 
global gSBCustomCommands

local tDoneStackList -- a list of the stacks that have already been done when counting scripts

local tIDArray -- an array of IDs -- used to store line counts of scripts
local tSizeArray -- an array of the size of the scripts being counted in characters
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
   put getID(tClickedLine) into tClickedID
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
         send ("doUpdateDisplay") to me in 6 ticks
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
         send ("doUpdateDisplay") to me in 6 ticks
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
         put line 1 of tIDList into tOwner
         delete word 1 to 4 of tOwner
         repeat for each line L in tIDList
            if word 5 to -1 of L is not tOwner then break
         end repeat
         if word 1 of tOwner is "group" then 
            start editing tOwner
            put empty into tIDNewList
            repeat for each line L in tIDList
               put (word 1 to 4 of L && word 9 to -1 of L) & cr after tIDNewList
            end repeat
            put char 1 to -2 of tIDNewList into tIDList
         end if
         replace cr with " and " in tIDList
         put "group " before tIDList
         set the relayerGroupedControls to true
         try
            do tIDList
         catch pError
            answer ("Group failed:" && pError)
            put pError & cr & cr & cr & tIDList
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
         put getID() into tIDList
      case "Find|In Enclosed Scripts..."
         if pWhich is "Find|In Enclosed Scripts..." then put allUniqueIDsOf(getID()) into tIDList
         ask "Find:" with "search string" titled replaceF("...",":",replaceF("|",space,pWhich))
         if it is empty or the result is not empty then break
         repeat for each line tID in tIDList
            if it is in the script of tID then put tID & cr after tFoundIDList
         end repeat
         if tFoundIDList is not empty then setBookmarks ,tFoundIDList
         break
      case "Find|By Test..."
         put getID() into tIDList
      case "Find|In Enclosed By Test..."
         ask "Test -- tID is the object reference:" with "search string" titled replaceF("...",":",replaceF("|",space,pWhich))
         if it is empty or the result is not empty then break else put it into tCondition
         if pWhich is "Find|In Enclosed By Test..." then 
            --            answer "Treat a field on multiple cards separately?" with "As One Field" or "Separately"
            --            put allUniqueIDsOf(getID(),(it is "Separately")) into tIDList
            put allUniqueIDsOf(getID()) into tIDList
         end if
         put false into ignoreErrors
         repeat for each line tID in tIDList
            put tCondition into tTest
            replace "tID" with tID in tTest
            try
               if value(tTest) then put tID & cr after tIDMatchList
            catch tErr
               if ignoreErrors then next repeat
               answer "There was a problem evaluating:" & cr & tTest & cr & cr & "Error:" & cr & tErr with "Cancel" or "Ignore Errors" or "OK"
               if it is "Cancel" then break
               put (it is "Ignore Errors") into ignoreErrors 
            end try
         end repeat
         if tIDMatchList is not empty then setBookmarks ,tIDMatchList
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
         put getID(tClickedLine) into tID
         put word -2 to -1 of tID into tStack
         put the short name of tStack into tStack
         set the windowShape of stack tStack to (word 3 of tID)
         break
      case "Export As..."
         put getID(tClickedLine) into tID
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
         put word 3 of getID(tClickedLine) into tIconID
         repeat for each line tID in getID()
            if word 1 of tID is not "button" then next repeat
            set the icon of tID to tIconID
         end repeat
         break
      case "Set Copied Btn as Behavior"
         doCodeN1 "set the behavior of xID to the long id of yID",getID(),(line 1 of gSBLastCopiedObjectList); break
      case "Resize..."
         send "showMe" to group "resizer"; break
      case "Property Editor..."
         dispatch "setup" to group "editProps" with tClickedID; break
      case "Object Inspector (1)"
         objectInspector1; break
      case "Object Inspector (N)"
         objectInspectorN; break     
      case "Edit Colors..."
         put "setup" && quote & tClickedID & quote into tMSG
         send tMSG to group "setColors"
         break
      case "Align Objects..."
         revIDEInspectObjects
         send "InspectorSectionChanged" && quote & "Align Controls" & quote to stack (line 1 of the openstacks)
         break
      case "Edit Scripts"
         editObjectScripts; break
      case "Scripts|Count"
         put getID() into tIDList
      case "Scripts|Count Enclosed"
         if pWhich is "Scripts|Count Enclosed" then put allUniqueIDsOf(getID()) into tIDList
         repeat for each line cID in tIDList
            add 1 to tObjectCount
            get length(the script of cID)
            if it = 0 then next repeat
            add it to tCharSize
            add the number of lines of the script of cID to tLineCount
            add 1 to tScriptCount
         end repeat
         reportScripts tCharSize,tLineCount,tScriptCount,tObjectCount
         break
      case "Scripts|Copy"
         put getID() into tIDList
      case "Scripts|Copy Enclosed"
         if pWhich is "Scripts|Copy Enclosed" then put allUniqueIDsOf(getID()) into tIDList
         repeat for each line cID in tIDList
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
         break
      case "Bookmark"
         setBookmarks
         break
      case "Remove"
         removeBookmarks; break
      case "Open in New Navigator"
         --break
         put the hilitedLines of fld "list" into tLines
         repeat for each item tItem in tLines
            put getID(tItem) into tID
            if not (word 1 of tID is among the items of "group,card,stack") then next repeat
            if word 1 of tID is "stack" then put "this card of " after newNavContainerList
            put tID & cr after newNavContainerList
         end repeat
         if newNavContainerList is not empty then get newNavigator(newNavContainerList)
         break
      case "Browse Controls"
         put true into tBrowseControls
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
         put the hilitedLines of fld "list" into tLines
         put empty into reloadConfirmed
         repeat for each item tItem in tLines
            put getID(tItem) into tID
            if not (word 1 of tID is among the items of "group,card,stack") then next repeat
            try
               if tBrowseControls then
                  put false into gSBShowList[the short name of this stack]
                  if word 1 of tID is "stack" then
                     put "card" into gSBCardOrBackground[the short name of this stack]
                     put "this card" into gSBWhichCard[the short name of this stack]
                  else if word 1 of tID is "group" then
                     put "background" into gSBCardOrBackground[the short name of this stack]
                     put word 1 to -4 of tID into gSBWhichBackground[the short name of this stack]
                  else if word 1 of tID is "card" then
                     put "card" into gSBCardOrBackground[the short name of this stack]
                     put word 1 to -4 of tID into gSBWhichCard[the short name of this stack]
                  end if
                  set the wholematches to true
                  put wordOffset("stack",tID) into tS
                  put word tS to -1 of tID into tStackID
                  put the short name of stack tStackID into gSBWhichStack[the short name of this stack]
                  updateDisplay true
               else if word 1 of tID is "group" then
                  -- no point in continuing, can't save or go
               else if tSaveAll and word 1 of tID is "stack" then
                  save tID
                  repeat for each line tStackIDLine in the stackFiles of tID
                     save stack (item 1 of tStackIDLine)
                  end repeat
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
                  if false then
                     put the filename of tID into tStackPath
                     set the itemdel to "/"
                     delete item -1 of tStackPath
                     set the itemDel to comma
                     repeat for each line tStackIDLine in the stackFiles of tID
                        put item 1 of tStackIDLine into tStackFileStack
                        if the scriptonly of stack tStackFileStack is false then next repeat
                        put "file:" & stitchPaths(tStackPath,item 2 to -1 of tStackIDLine) into tURL
                        put tURL
                        put url tURL into tScriptData
                        put tScriptData
                        set the script of stack tStackFileStack to line 2 to -1 of tScriptData
                        put "script set"
                     end repeat
                  end if
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
               set the textColor of line tItem of fld "list" of this stack to the pColorObjectMissing of this stack
            end try
         end repeat
         break
      case "Purge Stack..."
         put the hilitedLines of fld "list" into tLines
         repeat for each item tLine in tLines
            put getID(tLine) into tID
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
         
         put gSBWhichStack[the short name of this stack] into tS
         if tS is not empty and tS is not "the topStack" and (not (there is a stack tS)) then
            put "this card" into gSBWhichCard[the short name of this stack]
            put "card" into gSBCardOrBackground[the short name of this stack]
            put "the topStack" into gSBWhichStack[the short name of this stack]
         end if
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
            put gSBLeadSpaces[the short name of this stack] & word 1 to -1 of it into line tLine of fld "list"
         end repeat
         set the hilitedLines of fld "list" to tLineList; break
      case "Command..."
         send "showMe" to group "commandGroup"; break
      default
         set the itemDelimiter to "|"
         if item 1 of pWhich is among the items of "substacks|mainstack" then
            put item 2 of pWhich into tStackName
            if there is a stack tStackName then
               put false into gSBShowList[the short name of this stack]
               put "card" into gSBCardOrBackground[the short name of this stack]
               put "this card" into gSBWhichCard[the short name of this stack]
               put tStackName into gSBWhichStack[the short name of this stack]
               updateDisplay true
            end if
         end if
         if item 1 of pWhich is "Command" then
            put item 2 of pWhich into tCommandFile
            put the value of word -1 the long id of this stack into tPath
            set the itemDelimiter to "/"
            put "Navigator Commands" into item -1 of tPath
            put "/" & tCommandFile after tPath
            if not (there is a file tPath) then
               answer warning ("Command Missing:" && tPath) with "OK"
               break
            end if
            put ("file:" & tPath) into tURL
            put url tURL into tCommand
            set the commandCode of button "do" of group "commandcontrols" to tCommand
            put the hilitedLines of fld "list" into tList
            if tList is empty then break
            put empty into tIDList
            set the itemDelimiter to ","
            repeat for each item tLine in tList
               put getID(tLine) into tID
               put tID & cr after tIDList
            end repeat
            set the pWorkingLines of group "commandGroup" to tIDList
            send "doCode" to button "do" of group "commandcontrols"
         end if
   end switch
end menuPick

on reportScripts tCharSize,tLineCount,tScriptCount,tObjectCount
   answer "The size of the scripts is:" & cr & tCharSize && "characters in" & cr & tLineCount && "lines in" & cr & tScriptCount && "scripts in" & cr & tObjectCount && "objects." with "Make Copyable" or "OK"
   if it is "OK" then exit reportScripts
   ask "The size of the scripts is:" with tCharSize && "characters in" && tLineCount && "lines in" && tScriptCount && "scripts in" && tObjectCount && "objects."
end reportScripts


on prepareItems
   put the hilitedLines of fld "list" into tLines
   put getID(tLines) into tIDList
   put tIDList into sHighlightedList -- local to store universally within this script the ids highlighted when click occurred
   put word 2 of the clickLine into tClickedLine
   if tClickedLine is empty then put the uClickedLine of this card into tClickedLine
   put getID(tClickedLine) into sClickedID --  local to store universally within this script the id that was clicked
   
   
   
   put the basicItems of btn "popup" into tItems
   put gSBCustomCommands after tItems
   put true into allBehaviors
   put true into tContainer
   put word 1 of tIDList into tObjectType
   put true into noCardStack
   put true into exportToBehaviors
   repeat for each line tID in tIDList
      if tObjectType is not "mixed" and word 1 of tID is not tObjectType then put "mixed" into tObjectType
      if allBehaviors and the behavior of tID is empty then put false into allBehaviors
      if exportToBehaviors and the behavior of tID is not empty then put false into exportToBehaviors
      if tContainer and word 1 of tID is not among the items of "card,stack,group" then put false into tContainer
      if noCardStack and word 1 of tID is among the items of "card,stack" then put false into noCardStack
      if tObjectType is "mixed" and not allBehaviors and not tContainer and not noCardStack  and  not exportToBehaviors then exit repeat
   end repeat
   if exportToBehaviors then
      put uniqueStacksFromIDs(tIDList) into parentStackList
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
         if tSubstacks is empty then
            put "(SubStacks (None)" & cr before tItems
         else
            replace cr with cr & tab in tSubstacks
            put "SubStacks" & cr & tab & tSubstacks & cr before tItems
         end if
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
   -- put uProp1
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
