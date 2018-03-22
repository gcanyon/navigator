script "rev_s_revNavigator"
//>GLOBALS
global gREVMessageDispatch, gSBCardOrBackground, gSBControlSets, gSBCustomCommands
global gSBLeadSpaces
global gSBShowAllStacks, gSBShowList, gSBshowTooltip
global gSBWhichBackground, gSBWhichCard, gSBWhichStack

//>LOCALS
local sDisableCount, sDoUpdateDisplayCount, sHilitedIDList, sHilitedLineList, sLines
local sSetupComplete, sStackFileVersion, sUpdatingRevSelection, sWindowLoc
local navIDArray,navLineArray,navUpdateSelection,navLastLinesSelected,navLastObjectCount,navLastFieldUpdate
local externalDrag        #SET TO TRUE WHEN A DRAG LEAVES THE LIST
local navigatorTarget -- THE THING BEING DISPLAYED BY THIS INSTANCE OF NAVIGATOR. CAN BE ONE OF:
   -- stack list
   -- this card of the topstack
   -- this card of stack "<stack name>"
   -- <card long id>
   -- <group long id>
   -- card list of stack "<stack name>"
   -- background list of stack "<stack name>"



on openStack
   if word 1 of the short name of this stack is not among the items of "Navigator,revNavigator" then exit openStack
   put false into sSetupComplete
   doSetup
end openStack


on doReport p
   put ticks() && p
end doReport

on debugBroken
   put the number of lines of the keys of navLineArray & cr & the keys of navLineArray;exit debugbroken
   put splice(cr,1,navLineArray[1],2,navLineArray[2],3,navLineArray[3],4,navLineArray[4])
end debugBroken

function addList SL,TL
   -- adds the items of SL to TL, repeating if necessary
   put 1 into i
   put the number of items of SL into C
   repeat for each item n in TL
      put (n + item i of SL) & comma after R
      add 1 to i
      if i > C then put 1 into i
   end repeat
   return char 1 to -2 of R
end addList

function subtractList SL,TL
   put 1 into i
   put the number of items of SL into C
   repeat for each item n in TL
      put (n - item i of SL) & comma after R
      add 1 to i
      if i > C then put 1 into i
   end repeat
   return char 1 to -2 of R
end subtractList

on doSetup
   if the short name of this stack is "revNavigator" then 
      setVisNavigator true
      dispatch "showMe" to group "about" with true
      set the autoUpdateList of this stack to true
   end if
   show this stack
   set the minHeight of this stack to 120
   set the minWidth of this stack to 170
   put the showToolTip of this stack into gSBshowTooltip
   put "     " into gSBLeadSpaces[the short name of this stack]
   put false into gSBShowList[the short name of this stack]
   put "the topStack" into gSBWhichStack[the short name of this stack]
   put "this card" into gSBWhichCard[the short name of this stack]
   put "card" into gSBCardOrBackground[the short name of this stack]
   
   set the customPropertySet of me to "gSBControlSetsProp"
   put the customProperties of me into gSBControlSets
   set the customPropertySet of me to empty
   buildCustomCommandList
   setSeparatorLine
   put true into sSetupComplete
   updateDisplay true
   if not (the short name of this stack is "revNavigator" and the hilite of btn "I Paid") then exit doSetup
   wait 1 second
   dispatch "hideMe" to group "about"
end doSetup


on closeStack
   if the filename of me is empty then exit closeStack
   if word 1 of the short name of this stack is not among the items of "Navigator,revNavigator" then exit closeStack
   put the navigatorStackFileVersion of me into sStackFileVersion
   --send "cleanMyControlSets" to btn "Actions"
   set the customPropertySet of me to "gSBControlSetsProp"
   set the customProperties of me to gSBControlSets
   put empty into fld "list"
   put empty into fld "filter"
   put empty into fld "command"
   dispatch "setVisNavigator" to this stack with true
   save me
end closeStack


on saveStackRequest
   setLCVersion sStackFileVersion
   put empty into sStackFileVersion --reset to use the preference unless we're closing
   pass saveStackRequest
end saveStackRequest


on setLCVersion pVersion
   if the short name of this stack is not "revNavigator" then exit setLCVersion
   if pVersion is not a number then put the navigatorStackFileVersion of me into pVersion
   --put the stackFileVersion into tOldStackFileVersion
   if pVersion is a number then
      set the stackFileVersion to pVersion
   end if
   --set the stackFileVersion to tOldStackFileVersion
end setLCVersion


on revPreOpenCard
   if word 1 of the short name of this stack is not among the items of "Navigator,revNavigator" then exit revPreOpenCard
   if sSetupComplete is not false then updateDisplay
end revPreOpenCard


on revPreOpenStack
   if word 1 of the short name of this stack is not among the items of "Navigator,revNavigator" then exit revPreOpenStack
   if sSetupComplete is not false then updateDisplay
end revPreOpenStack


on revResumeStack
   if word 1 of the short name of this stack is not among the items of "Navigator,revNavigator" then exit revResumeStack
   if sSetupComplete is not false then updateDisplay
end revResumeStack


on revSelectedObjectChanged
   --put "revSelectedObjectChanged" && the short name of this stack && ticks() & cr before fld 1 of stack "untitled 3"
   if word 1 of the short name of this stack is not among the items of "Navigator,revNavigator" then exit revSelectedObjectChanged
   
   if sSetupComplete is not false then updateListSelection
end revSelectedObjectChanged

local navUpdateListSelection
on updateListSelection
   cancel navUpdateListSelection
   send ("doUpdateListSelection") to me in 10 ticks
   put the result into navUpdateListSelection
end updateListSelection

local navUpdateDisplayMessage
--local navLastStackDisplayed, navLastCardDisplayed
on doUpdateListSelection
   local tLineList, tNumControls, tObjects
   
   if navUpdateSelection then
      put false into navUpdateSelection
      exit doUpdateListSelection
   end if
   if dontUpdate() then exit doUpdateListSelection
   put the number of controls of the topStack into tNumControls
   if tNumControls is not navLastObjectCount then
      cancel navUpdateDisplayMessage
      doUpdateDisplay true
      put tNumControls into navLastObjectCount
   end if
   put the selectedObjects into tObjects
   put lineListFromIDs(tObjects) into tLineList
   hiliteLines tLineList
   
end doUpdateListSelection


on putIt2 p
   put lineListFromIDs(p)
end putIt2


function lineListFromIDs pIDlist -- takes a line list of long IDs and returns a comma list of the line numbers
   local tLineList, tStart
   
   put empty into tLineList
   put the separatorLine of fld "list" into tStart
   repeat for each line tObject in pIDlist
      if word 1 of tObject is "stack" then
         put tStart+1 & "," after tLineList
      else if word 1 of tObject is "card" then
         put tStart + 2 & "," after tLineList
      else if navIDArray[tObject] is not empty then
         put (tStart + navIDArray[tObject]) & "," after tLineList
      end if
   end repeat
   delete char -1 of tLineList
   return tLineList
end lineListFromIDs

function dontUpdate
   if not (the autoUpdateSelection of this stack) then return true
   put the short name of this stack into tStack
   if gSBShowList[tStack] then return true
   return not (((gSBWhichStack[tStack] is "the topStack") \
         or (gSBWhichStack[tStack] is the short name of the topstack)) and \ 
         ((gSBWhichCard[tStack] is "this card") \
         or (gSBWhichCard[tStack] is the currentcard of the topstack)))
end dontUpdate


on updateRevSelectedObjects
   local tKey, tLineNumbers, tLinesToSelect, tScroll, tSeparatorLine
   if dontUpdate() then  exit updateRevSelectedObjects
   put the hilitedLines of fld "list" into tLineNumbers
   put the scroll of fld "list" into tScroll
   --put tLineNumbers
   put the separatorLine of fld "list" into tSeparatorLine
   put "select " into tLinesToSelect
   repeat for each item tItem in tLineNumbers
      if tItem < (tSeparatorLine + 3) then next repeat
      put tItem - tSeparatorLine into tKey
      put navLineArray[tKey] && "and " after tLinesToSelect
   end repeat
   if tLinesToSelect is not "select " then
      delete word -1 of tLinesToSelect
   else
      put "empty" after tLinesToSelect
   end if
   -- put tLinesToSelect
   if tLinesToSelect is navLastLinesSelected then exit updateRevSelectedObjects
   put tLinesToSelect into navLastLinesSelected
   put true into navUpdateSelection
   --if the number of items of tLineNumbers > 1 then lock screen
   lock screen
   put true into sUpdatingRevSelection
   do tLinesToSelect
   --if the result is not empty then answer warning the result with "OK"
   if the lastClickedLine of fld "list" is a number then
      --select line (the lastClickedLine of fld "list") of fld "list"
      select line (the uClickedLine of this card) of fld "list"
   end if
   set the hilitedLines of fld "list" to tLineNumbers
   set the scroll of fld "list" to tScroll
   --if the number of items of tLineNumbers > 1 then unlock screen
end updateRevSelectedObjects



on storeHilitedLines pLineList,pIDList
   if pLineList is empty then
      put hilitedBookmarkList() into pLineList
      put hilitedLineIDList() into pIDList
   end if
   put pLineList into sHilitedLineList
   put pIDList into sHilitedIDList
end storeHilitedLines


on restoreHilitedLines
   local tIDLineList
   
   put lineListFromIDs(sHilitedIDList) into tIDLineList
   if tIDLineList is not empty and sHilitedLineList is not empty then put "," after sHilitedLineList
   put tIDLineList after sHilitedLineList
   hiliteLines sHilitedLineList
end restoreHilitedLines


on hiliteLines pLineList -- takes a list of lines and hilites them
   if sUpdatingRevSelection then
      put false into sUpdatingRevSelection
      exit hiliteLines
   end if
   if the hilitedlines of fld "list" of this stack is pLineList then exit hiliteLines
   set the hilitedLines of fld "list" of this stack to pLineList
end hiliteLines


function hilitedBookmarkList -- returns a comma list of the hilited bookmark lines
   local tReturn, tSeparator
   
   put the separatorLine of fld "list" into tSeparator
   put empty into tReturn
   repeat for each item tLine in the hilitedlines of fld "list"
      if tLine > tSeparator then exit repeat
      put tLine & "," after tReturn
   end repeat
   delete the last character of tReturn
   return tReturn
end hilitedBookmarkList


function hilitedLineIDList
   local tLineList, tSeparator, x
   
   put the separatorLine of fld "list" into tSeparator
   put 1 into x
   put the hilitedlines of fld "list" into tLineList
   repeat for each item tLine in tLineList
      if tLine > tSeparator then exit repeat
      add 1 to x
   end repeat
   if x > the number of items of tLineList then return empty
   put item x to -1 of tLineList into tLineList
   return getID(tLineList)
end hilitedLineIDList


function whichColor tID
   local R
   put 1 into R
   if the behavior of tID is not empty then if exists(the behavior of tID) then add 2 to R else return 0
   --if the behavior of tID is not empty then add 2 to R
   if the script of tID is not empty then add 1 to R
   return R
end whichColor



on updateDisplay pForceUpdate,pRetainHilites
   cancel navUpdateDisplayMessage
   --   add 1 to sDoUpdateDisplayCount
   --   put sDoUpdateDisplayCount
   --put ticks() && "updateDisplay" & cr after message box  -- debug
   send ("doUpdateDisplay" && pForceUpdate & "," & pRetainHilites) to me in 30 ticks
   put the result into navUpdateDisplayMessage
end updateDisplay



on doUpdateDisplay pForceUpdate,pRetainHilites
   --put true into pRetainHilites
   --put "doUpdateDisplay" && pForceUpdate && pRetainHilites && the short name of this stack && ticks() & cr before fld 1 of stack "untitled 3"
   --put the short name of this stack && ticks() & cr &  the executionContexts & cr & cr & cr before fld 1 of stack "untitled 3"
   
   local tBookmarkLineList, tCardOrBGid, tCheckScripts, tColor, tControlCount
   local tControlList, tCurrentIndentLine, tCurrentLine, tDisplay, tFilter
   local tFilterString, tHilitedIDList, tID, tIDLineList, tIndent
   local tIndentString, tKeys, tName, tNamedObjectsOnly, tObjectLimit
   local tPrevDefaultStack, tRejectList, tScriptedObjectsOnly, tScroll, tStackID
   local tStackList, tStackName, tStackNameRef, tStart, tSubstackList
   local tSubstackName, tThisStack, whichColor
   put the short name of this stack into tThisStack
   if word 1 of tThisStack is not "revNavigator" then exit doUpdateDisplay
   if pRetainHilites then
      put hilitedBookmarkList() into tBookmarkLineList
      put hilitedLineIDList() into tHilitedIDList
   end if
   put the separatorLine of fld "list" of this stack into tStart
   
   
   put "<p><font color=" & quote & the pColorBehaviorMissing of this stack & quote & ">" into tColor[0]
   put "<p><font color=" & quote & the pColorDefault of this stack & quote & ">" into tColor[1]
   put "<p><font color=" & quote & the pColorScriptedObject of this stack & quote & ">" into tColor[2]
   put "<p><font color=" & quote & the pColorBehaviorScripted of this stack & quote & ">" into tColor[3]
   put "<p><font color=" & quote & the pColorScriptandBehavior of this stack & quote & ">" into tColor[4]
   put 1 into whichColor
   
   put the ColorScriptedObjects of this stack into tCheckScripts
   put the pIndentString of this stack into tIndentString
   
   
   
   if (gSBShowList[tThisStack] and gSBCardOrBackground[tThisStack] is "stack") then
      put "Nav: Stack List" into fld "Navigator Title"
      disable btn "whichCard" of this stack
      repeat with i = 1 to 4
         put "</font></p>" & cr before tColor[i]
      end repeat
      
      --gSBShowAllStacks
      put the mainStacks into tStackList
      sort lines of tStackList
      put the pObjectLimit of this stack into tObjectLimit
      put empty into tControlList
      put 0 into tCurrentLine
      put fld "filter" into tFilter
      
      repeat for each line tStack in tStackList
         put the name of stack tStack into tStackName
         
         if (not gSBShowAllStacks) and (filterStacksList(tStack) is empty) then next repeat
         put true into includeStack
         if tFilter is not empty and tFilter is not in tStackName then put false into includeStack
         if the filterString of stack tThisStack is not empty then
            put the filterString of stack tThisStack into tFilterString
            replace "tID" with tStackName in tFilterString
            try
               if not value(tFilterString) then put false into includeStack
            catch someErr
               put false into includeStack
            end try
         end if
         
         if includeStack then
            add 1 to tCurrentLine
            if tCurrentLine > tObjectLimit then exit repeat
            if tCheckScripts and (the password of tStackName is empty) \
                  then put tColor[whichColor(tStackName)] & tStackName after tControlList \
                  else put tColor[1] & tStackName after tControlList
            put tCurrentLine into newIDArray[tStackName]
            put tStackName into newLineArray[tCurrentLine]
            put tIndentString into tStackIndentString
         else
            put empty into tStackIndentString
         end if
         put the substacks of stack tStack into tSubstackList
         
         repeat for each line tSubstack in tSubstackList
            if tFilter is not empty and tFilter is not in tSubstack then next repeat
            add 1 to tCurrentLine
            if tCurrentLine > tObjectLimit then exit repeat
            put the name of stack tSubStack into tSubstackName
            if tCheckScripts and (the password of tSubstackName is empty) \
                  then put tColor[whichColor(tSubstackName)] & tStackIndentString & tSubstackName after tControlList \
                  else put tColor[1] & tStackIndentString & tSubstackName after tControlList
            put tCurrentLine into newIDArray[tSubstackName]
            put tSubstackName into newLineArray[tCurrentLine]
         end repeat
      end repeat
      delete line 1 of tControlList -- deletes the initial stack reference that is in all other displays
      --put ticks() && "doUpdateDisplay" && tControlList & cr after message box  -- debug
      
      
   else
      enable btn "whichCard" of this stack
      
      if gSBWhichStack[tThisStack] is empty then exit doUpdateDisplay
      if not ((the autoUpdateList of this stack) or pForceUpdate) then exit doUpdateDisplay
      
      if gSBWhichStack[tThisStack] is "the topStack" then
         put the short name of the topStack into tStackName
      else
         put gSBWhichStack[tThisStack] into tStackName
         if existenceWarning("stack" && Q(tStackName)) is empty then
            put "the topStack" into gSBWhichStack[tThisStack]
            put the short name of the topStack into tStackName
            put "this card" into gSBWhichCard[tThisStack]
         end if
      end if
      put the long id of stack tStackName into tStackID
      
      if not gSBShowList[tThisStack] then
         put getCardOrBGid(tStackID) into tCardOrBGid
         if tCardOrBGid is empty then exit doUpdateDisplay
      end if -- not gSBShowList[the short name of this stack]
      
      --  get the number of controls of the topstack
      --  exit doUpdateDisplay
      --answer the separatorLine of fld "list" of this stack
      put fld "filter" into tFilter
      put "button,check,label field,field,radio,tab menu,table field,Scrolling List Field,List Field,Option Menu,Pulldown Menu,ComboBox Menu,Popup Menu,Progress Scrollbar,Scrollbar,Image,Player,graphic 1,new scrollbar,new graphic,new image,card id,group id" into tRejectList
      replace comma with cr in tRejectList
      set the itemDelimiter to quote
      
      put the NamedObjectsOnly of this stack into tNamedObjectsOnly
      put the ScriptedObjectsOnly of this stack into tScriptedObjectsOnly
      put the uDisplay of this stack into tDisplay
      
      put the name of stack tStackName into tStackNameRef
      if tCheckScripts and (the password of tStackNameRef is empty) then 
         put whichColor(tStackNameRef) into tStackColor
         put tColor[tStackColor] & "<b>" & tStackNameRef & "</b></p>" into tControlList 
      else 
         put tColor[1] & "<b>" & tStackNameRef & "</b></p>" into tControlList
      end if
      put tStackID into newLineArray[1]
      
      repeat with i = 1 to 4
         put "</font></p>" & cr before tColor[i]
      end repeat
      
      if the password of tStackID is not empty then put false into tCheckScripts
      if gSBShowList[tThisStack] then
         put 1 into tCurrentLine
         put 1 into tCurrentIndentLine
         if gSBCardOrBackground[tThisStack] is "card" then
            put the number of cds of tStackID into tControlCount
            put "Nav: Cards of" && the name of tStackID into fld "Navigator Title"
         else
            put the number of bgs of tStackID into tControlCount
            put "Nav: Backgrounds of" && the name of tStackID into fld "Navigator Title"
         end if
      else
         if tCheckScripts
         then put tColor[whichColor(tCardOrBGid)] & "<b>" & the name of tCardOrBGid & "</b>"after tControlList
         else put tColor[1] & "<b>" & the name of tCardOrBGid & "</b>"after tControlList
         
         put tCardOrBGid into newLineArray[2]
         put the number of controls of tCardOrBGid into tControlCount
         
         if word -5 of tCardOrBGid is "stack" \
               then put word -5 to -4 of tCardOrBGid into stackNameForTitle \
               else put the name of stack (char 2 to -2 of word -1 of tCardOrBGid) into stackNameForTitle
         put "Nav:" && the name of tCardOrBGid && "of" && stackNameForTitle  into fld "Navigator Title"
         put 2 into tCurrentLine
         put 2 into tCurrentIndentLine
      end if
      
      
      put min(the pObjectLimit of this stack,tControlCount) into tControlCount
      if gSBWhichStack[tThisStack] is "the topStack" \
            and not (the ShowRevStacks of this stack) then
         put the short name of the topStack into tStackName
         if filterStacksList(tStackName) is empty then
            put 0 into tControlCount
         end if
      end if
      
      put the defaultStack into tPrevDefaultStack
      set the defaultStack to tStackName
      
      repeat with i = 1 to tControlCount
         add 1 to tCurrentIndentLine
         
         if gSBShowList[tThisStack] then
            if gSBCardOrBackground[tThisStack] is "card" then
               put the long id of cd i into tID --of tStackID into tID  --defaultStack test
            else
               put the long id of bg i into tID --of tStackID into tID  --defaultStack test
            end if
         else
            put the long id of control i of tCardOrBGid into tID
         end if
         put the name of tID into tName
         if the filterString of stack tThisStack is not empty then
            put the filterString of stack tThisStack into tFilterString
            replace "tID" with tID in tFilterString
            try
               if not value(tFilterString) then next repeat
            catch someErr
               next repeat
            end try
         end if
         --          if (tNamedObjectsOnly and (quote is not in tName or item 2 of tName is among the lines of tRejectList))  \
               --                or (tScriptedObjectsOnly and (the script of tID is empty)) \
               --                or (tFilter is not empty and tFilter is not in tName) then \
               --                next repeat
         if (tNamedObjectsOnly and (quote is not in tName or item 2 of tName is among the lines of tRejectList))  \
               or (tScriptedObjectsOnly and (the script of tID is empty)) then \
               next repeat
         
         switch tDisplay
            case "name"; break
            case "id"; put the abbreviated id of tID into tName; break
            case "Name and ID"; put " [" & the id of tID & "]" after tName; break
            case "Long Name"; put the long name of tID into tName; break
            case "Long ID"; put tID into tName; break
         end switch
         if tFilter is not empty and tFilter is not in tName then next repeat
         add 1 to tCurrentLine
         if word 1 of tName is "group" and (not gSBShowList[tThisStack]) then
            repeat with tWhichIndentCount = (tCurrentIndentLine +1) to (tCurrentIndentLine + (the number of controls of tID))
               put tIndentString before tIndent[tWhichIndentCount]
            end repeat
         end if
         put tIndent[tCurrentIndentLine] before tName
         if tCheckScripts then put tColor[whichColor(tID)] & tName after tControlList \
               else put tColor[1] & tName after tControlList
         put tCurrentLine into newIDArray[tID]
         put tID into newLineArray[tCurrentLine]
      end repeat
      
      set the defaultStack to tPrevDefaultStack
   end if
   put "</font></p>" after tControlList
   
   if gSBWhichStack[tThisStack] is "the topStack" \
         and not (the ShowRevStacks of this stack) \
         and char 1 to 3 of the short name of the topStack is "rev" then
      delete line tStart + 1 to -1 of fld "list" of this stack
      put empty into navLastFieldUpdate
   else
      if (not pForceUpdate) and tControlList is navLastFieldUpdate then exit doUpdateDisplay
      put the scroll of fld "list" into tScroll
      put cr & " " after fld "List" of this stack
      lock screen
      set the htmlText of line tStart + 1 to -1 of fld "list" of this stack to tControlList
      
      set the scroll of fld "list" to tScroll
      put tControlList into navLastFieldUpdate
      put newIDArray into navIDArray
      --if the number of lines of the keys of newLineArray is 0 then answer "we're doing a bad thing"
      put newLineArray into navLineArray
      
   end if
   if pRetainHilites then
      put lineListFromIDs(tHilitedIDList) into tIDLineList
      hiliteLines splice(comma,tBookmarkLineList,tIDLineList)
   else
      hiliteLines
   end if
end doUpdateDisplay

function testF
   return "F"
end testF

function Q S
   return quote & S & quote
end Q

function QQ S
   return quote && "& quote &" && quote & S & quote && "& quote &" && quote
end QQ

on reportStack
   put the short name of this stack into N
   answer gSBWhichStack[N] 
end reportStack


function getCardOrBGid tStackID
   local N, tReturnID
   put the short name of this stack into N
   if tStackID is empty then 
      if gSBWhichStack[N] is "the topStack" then
         put the topStack into tStackID
      else
         put "stack" && Q(gSBWhichStack[N]) into tStackID
      end if
   end if
   if existenceWarning(tStackID) is empty then
      put "the topStack" into gSBWhichStack[N]
      put the name of the topStack into tStackID
   end if
   if gSBCardOrBackground[N] is "card" then
      if gSBWhichCard[N] is "this card" then
         put the long id of this cd of tStackID into tReturnID
      else if word 1 to 2 of gSBWhichCard[N] is "card id" then
         put gSBWhichCard[N] && "of" && tStackID into tReturnID
      else
         put "card" && Q(gSBWhichCard[N]) && "of" && tStackID into tReturnID
      end if
   else if gSBCardOrBackground[N] is "background" then
      if word 1 to 2 of gSBWhichBackground[N] is "group id" then
         put gSBWhichBackground[N] && "of" && tStackID into tReturnID
      else
         put "background" && Q(gSBWhichBackground[N]) && "of" && tStackID into tReturnID
      end if
   end if
   if existenceWarning(tReturnID) is empty then
      put "card" into gSBCardOrBackground[N]
      put "this card" into gSBWhichCard[N]
      return the long id of this cd of stack tStackID
   else
      return tReturnID
   end if
end getCardOrBGid

function testFunction
   return "FML"
end testFunction


on setBookmarks pWhichLine,pIDList
   local tAddList, tCheckScripts, tColor, tEndString, tKey
   local tList, tLowerLimit, tObjectName
   --answer pWhichLine,pIDList,insertAt
   put the separatorLine of fld "list" into tLowerLimit
   if pIDList is empty then
      if pWhichLine is empty then put the hilitedLines of fld "list" into pWhichLine
      repeat for each item i in pWhichLine
         if i <= tLowerLimit then next repeat
         put i - tLowerLimit into tKey
         put navLineArray[tKey] & cr after pIDList
      end repeat
      delete char -1 of pIDList
   end if
   set the wholeMatches to true
   put empty into tAddList
   put the ColorScriptedObjects of this stack into tCheckScripts
   put "<p><font color=" & quote & the pColorDefault of this stack & quote & "><a name=" & quote into tColor[false]
   put "<p><font color=" & quote & the pColorScriptedObject of this stack & quote & "><a name=" & quote into tColor[true]
   put "</a></font></p>" & cr into tEndString
   
   put line 1 to tLowerLimit of fld "list" into tList
   repeat for each line tID in pIDList
      if tID is empty or (not (there is a tID)) then next repeat
      put gSBLeadSpaces[the short name of this stack] into tObjectName
      if the uDisplay of this stack contains "name" then
         put (the long name of tID) after tObjectName
         if the uDisplay of this stack contains "id" then
            put " [" & the short id of tID & "]" after word 2 of tObjectName
         end if
      else
         put (the long id of tID) after tObjectName
      end if
      
      if lineOffset(tObjectName,tList) > 0 then next repeat
      -- add the object
      put tColor[tCheckScripts and (the script of tID is not empty)] after tAddList
      replace quote with numtochar(1) in tID
      put tID & quote & ">" & tObjectName & tEndString after tAddList
   end repeat
   if tAddList is empty then exit setBookmarks
   put cr before fld "list"
   set the htmlText of line 1 of fld "list" to tAddList
   setSeparatorLine
end setBookmarks


function detailedName pID
   local tName, tStack
   
   put the long name of pID into tName
   put word -2 to -1 of tName into tStack
   put quote & the short name of tStack & quote into word -1 of tName
   return tName
end detailedName


function shortDetailedName pID
   return word 1 to -4 of the long name of pID
end shortDetailedName


function localDetailedName pID
   local tName
   
   put word 1 to -4 of the long name of pID into tName
   if word -3 of tName is "of" then return word 1 to -4 of tName
   return word 1 to -5 of tName
end localDetailedName


on removeBookmarks pListOfLines
   local tNewHTML, tSeparatorLine
   
   if pListOfLines is empty then put the hilitedLines of fld "list" into pListOfLines
   
   put the separatorLine of fld "list" into tSeparatorLine
   put removeLines(the htmlText of line 1 to tSeparatorLine of fld "list",pListOfLines) into tNewHTML
   set the htmlText of line 1 to tSeparatorLine of fld "list" to tNewHTML
   if tNewHTML is empty then delete line 1 of fld "list"
   set the hilitedLines of fld "list" to empty
   setSeparatorLine
end removeBookmarks


function removeLines pText,removeList
   local R, X
   
   put 0 into X
   split removeList by comma as set
   repeat for each line L in pText
      add 1 to X
      if not removeList[X] then put L & cr after R
   end repeat
   return char 1 to -2 of R
end removeLines


on bookmarkRemove pWhichLine
   if pWhichLine > the separatorLine of fld "list" then
      setBookmarks pWhichLine
   else
      removeBookmarks pWhichLine
   end if
end bookmarkRemove


on setSeparatorLine pOffset
   if pOffset is empty then
      put lineoffset(cr & "stack",fld "list" of this stack) into pOffset
      if pOffset is 0 and (char 1 to 5 of fld "list" of this stack is not "stack") then
         put the number of lines of fld "list" of this stack into pOffset
      end if
   end if
   set the separatorLine of fld "list" of this stack to pOffset
end setSeparatorLine


on buildCustomCommandList
   local tFiles, tHoldDirectory, tPath
   
   put the value of word -1 the long id of this stack into tPath
   set the itemDelimiter to "/"
   put "Navigator Commands" into item -1 of tPath
   --answer tPath
   --exit to top
   if not (there is a folder tPath) then
      --answer "creating"
      create folder tPath
   end if
   put the directory into tHoldDirectory
   set the directory to tPath
   put the files into tFiles
   set the directory to tHoldDirectory
   --answer tFiles
   if line 1 of tFiles is ".DS_Store" then delete line 1 of tFiles
   replace cr with cr & tab in tFiles
   put cr & "Command" & cr & tab & tFiles into gSBCustomCommands
   --answer gSBCustomCommands
end buildCustomCommandList


function filterStacksList pStacks
   return revFilterStacksList(pStacks)
end filterStacksList


function getLineList pWhichLine
   local tLineList
   
   if pWhichLine is empty then
      put the hilitedlines of fld "list" into tLineList
      replace "," with cr in tLineList
   else
      put pWhichLine into tLineList
   end if
   return tLineList
end getLineList


on removeAllBookmarks
   local tSeparatorLine
   
   put the separatorLine of fld "list" into tSeparatorLine
   if tSeparatorLine is 0 then exit removeAllBookmarks
   set the htmlText of fld "list" to the htmlText of line (tSeparatorLine + 1) to -1 of fld "list"
   setSeparatorLine 0
end removeAllBookmarks


function getID pWhichLines
   return getList(false,pWhichLines)
end getID


function getClickedID
   return getList(false,the uClickedLine of this card)
end getClickedID


function getLineIDList pWhichLines -- returns line list of ids
   return getList(true,pWhichLines)
end getLineIDList


function listFrom X,Y
   local R
   
   repeat with i = X to Y
      put i & comma after R
   end repeat
   return char 1 to -2 of R
end listFrom


function getList pIncludeLines,pWhichLines
   local R, tColorObjectMissing, tID, tReturnArray, tSeparator
   put the long id of fld "list" of me into fList
   put empty into tReturnArray
   put the pColorObjectMissing of me into tColorObjectMissing
   put the separatorLine of fList into tSeparator
   if pWhichLines is empty then put the hilitedlines of fList into pWhichLines
   if pWhichLines is "all" then put listFrom(1,the number of lines of fld "list") into pWhichLines
   repeat for each item tLine in pWhichLines
      if tLine <= tSeparator then
         put the linkText of line tLine of fList into tID
         replace numtochar(1) with quote in tID
      else
         put navLineArray[(tLine - tSeparator)] into tID
      end if
      --put the short name of this stack,(tLine - tSeparator)
      if (there is a tID) then
         if pIncludeLines then put tLine & " " before tID
         if tReturnArray[tID] is empty then put tID & cr after R
         add 1 to tReturnArray[tID]
      else
         set the textColor of line tLine of fList to tColorObjectMissing
      end if
   end repeat
   return char 1 to -2 of R
end getList


on objectInspectorN pWhichLine
   local idList
   put getList(false,pWhichLine) into idList
   put the propertyPaletteLoc of fld "list" of this stack into sWindowLoc
   put the number of lines of idList into tLineCount
   if tLineCount > 10 and \
         proceedWarning(("You want to open" && it && "object inspectors?"),"Open","Cancel") is not "Open" 
   then exit objectInspectorN
   lock screen
   repeat for each line tID in idList
      revIDEInspectObjects tID
      positionWindow
   end repeat
   if tLIneCount = 1 then set the cLocked of stack (line 1 of the windows) to true
   unlock screen
end objectInspectorN


function proceedWarning messageText,btn1,btn2
   answer warning messageText with btn1 or btn2
   return it
end proceedWarning


on renameObjects pWhichLine
   local idList, tName
   
   put getList(false,pWhichLine) into idList
   get the number of lines of idList
   if it > 10 and proceedWarning(("You want to rename" && it && "objects?"),"Rename","Cancel") is not "Rename" then exit renameObjects
   repeat for each line tID in idList
      if not(there is a tID) then next repeat
      put the short name of tID into tName
      ask "Set the name to:" with tName
      if the result is not empty then next repeat
      set the name of tID to it
   end repeat
   send ("doUpdateDisplay true") to me in 6 ticks
end renameObjects


on deleteObjects pWhichLine
   local idList, tCount, tString
   
   put getList(false,pWhichLine) into idList
   if the optionKey is not "down" then
      put the number of lines of idList into tCount
      if tCount is 1 then
         put "this 1 object?" into tString
      else
         put "these" && tCount && "objects?" into tString
      end if
      if proceedWarning(("Are you certain you want to delete" && tString),"Delete","Cancel") is not "Delete" then exit deleteObjects
   end if
   repeat for each line tID in idList
      if there is a tID then delete tID
   end repeat
   send ("doUpdateDisplay") to me in 6 ticks
end deleteObjects


on cloneObjects pWhichLine
   local idList
   
   put getList(false,pWhichLine) into idList
   repeat for each line tID in idList
      clone tID
   end repeat
   send ("doUpdateDisplay") to me in 6 ticks
end cloneObjects


on resizeObjects
   
end resizeObjects


function iff B,T,F
   if B then return T else return F
end iff


on navResizeStack tWidth,tHeight
   local tLines, tRect
   
   put the hilitedLines of fld "list" into tLines
   --put the rect of me
   put the rect of fld "filter" into tRect
   put tWidth - 1 into item 3 of tRect
   set the rect of fld "filter" to tRect
   put the rect of grc "fieldtop" into tRect
   put tWidth + 5 into item 3 of tRect
   set the rect of grc "fieldtop" to tRect
   
   put the rect of grc "navTitleBar" into tRect
   put tWidth into item 3 of tRect
   set the rect of grc "navTitleBar" to tRect
   set the topright of btn "CloseNav" to (item 3 of tRect - 2),(item 2 of tRect + 2)
   set the topright of btn "CloseNavAll" to (item 3 of tRect - 17),(item 2 of tRect + 2)
   subtract 34 from item 3 of tRect
   set the rect of fld "Navigator Title" to tRect
   
   set the rect of fld "list" to -2,35,(tWidth+1),(tHeight+1)
   
   repeat for each item G in "about,commandGroup,editContents,editProps"
      if the vis of group G then dispatch "setSize" to group G
   end repeat
   set the rect of grc "navBorder" to 0,0,(the width of this stack),(the height of this stack)
end navResizeStack


on setNavRect l,t,r,b
   lock screen
   set the rect of this stack to l,t,r,b
   set the bottomRight of grp "navResizer" to (4 + r - l),(4 + b - t)
   navResizeStack (r-l),(b-t)
   unlock screen
end setNavRect


on mouseLeave
end mouseLeave


-- on mouseMove
--    if externalDrag then 
--       if the mouse is "down" then 
--          dispatch "trackMovement" to this cd of stack "revDragRep"
--       else
--          dispatch "cleanUpExternalDrag" to fld "List"
--          stackCleanUpExternalDrag
--       end if
--    end if
-- end mouseMove

-- on mouseRelease
--    --put "mouseRelease stack" && ticks() && the mouse
--    if the mouse is "down" then exit mouseRelease
--    dispatch "cleanUpExternalDrag" to fld "List"
--    stackCleanUpExternalDrag
-- end mouseRelease

-- on stackCleanUpExternalDrag
--    put false into externalDrag
-- end stackCleanUpExternalDrag

-- on stackStartExternalDrag
--    put true into externalDrag
-- end stackStartExternalDrag



function theHilitedIDs
   return getID(the hilitedLines of fld "list")
end theHilitedIDs

function answerF M,I,T
   put "answer" into C
   if the optionkey is "down" then put C
   if I is not empty then put " " & I after C
   put " " & replaceF(cr,Q("&cr&"),Q(M)) after C
   if paramCount() > 3 then put " with" && Q(param(4)) after C
   repeat with x = 5 to paramCount()
      put " or" && Q(param(x)) after C
   end repeat
   if T is not empty then put " titled" && Q(T) after C
   if the optionkey is "down" then put C
   do C
   return it
end answerF

function restoreFromBehaviors idList,restoreDuplicateScripts,restoreScriptedObjects,followChainBehaviors
   if answerf("This function makes major changes to your project." & cr & cr & "You have backups?","warning",,"Cancel","Yes, Proceed") is not "Yes, Proceed" then return "Cancel"
   put answerf("You should test the command first, which will generate a log file but not change anything.","warning",,"Just Do It","Test and Report") is "Just Do It" into justDoIt
   put convertToUniqueLongIDs(idList) into idList
   
   -- build a list of the stacks containing the controls
   put uniqueStacksFromIDs(idList) into parentStackList
   put "Restoring scripts from behaviors to controls for objects in the following stacks:" & cr & parentStackList & cr & cr into logData
   
   repeat for each line tID in idList
      if the behavior of tID is empty then next repeat
      put the long id of the behavior of tID into tBID      
      if  behaviorMap[tBID] is not empty and not restoreDuplicateScripts then put "skip" into behaviorMap[tBID]
      if behaviorMap[tBID] is "skip" then next repeat
      if  the script of tID is not empty and not restoreScriptedObjects then next repeat
      put tID & cr after behaviorMap[tBID]
   end repeat
   
   put empty into scriptForScriptRestores
   repeat until the keys of behaviorMap is empty
      repeat for each key tBID in behaviorMap
         if behaviorMap[tBID] is "skip" then 
            put empty into behaviorMap[tBID]
            put "Skipping restore for" && the name of tBID & cr after logData
         else
            put "Restoring from behavior:" && the name of tBID & cr after logData
            add 1 to restoreBehaviorCount
         end if
         repeat for each line tID in behaviorMap[tBID]
            
            try
               if justDoIt then set the script of tID to splice(cr & cr,(the script of tID),(the script of tBID))
               put "Copying script from" && the name of tBID  && "to" && the name of tID & cr after logData
               add 1 to restoreControlCount
            catch someErr
               put "Failed to restore the script of:" & cr & "    " & tID & cr after logData
               put "set the script of" && tID && "to the script of" && tBID & cr after scriptForScriptRestores
               --put "set the behavior of" && tID && "to empty" & cr after scriptForScriptRestores
            end try
            if the behavior of tBID is empty then 
               if justDoIt then 
                  set the behavior of tID to empty 
               end if
            else if not followChainBehaviors or behaviorMap[the long id of the behavior of tBID] is "skip" then 
               if justDoIt then 
                  set the behavior of tID to the long id of the behavior of tBID
               end if
            else 
               put tID & cr after behaviorMap[the long id of the behavior of tBID]
            end if
         end repeat
         delete variable behaviorMap[tBID]
      end repeat
   end repeat
   put restoreBehaviorCount && "behaviors were restored to" && restoreControlCount && "controls." & cr & "No errors were detected." into logMessage
   if scriptForScriptRestores is not empty then put  cr & cr & "Use this script to restore scripts that failed to restore:" & cr & cr & scriptForScriptRestores after logData
   return logMessage  & cr & cr & logData
end restoreFromBehaviors

function convertToUniqueLongIDs idList
   --also filters for bad ids, missing controls, etc.
   repeat for each line tID in idList
      try
         put 1 into R[the long id of tID]
      catch someErr
      end try
   end repeat
   return the keys of R
end convertToUniqueLongIDs

function convertToScriptOnlyStackBehaviorsAutomatic idList
   put convertToUniqueLongIDs(idList) into idList
   put stackMapFromIDs(idList) into SM
   if answerf("This function makes major changes to your project." & cr & cr & "You have backups?","warning",,"Cancel","Yes, Proceed") is not "Yes, Proceed" then return "cancel"
   repeat for each key stackName in SM
      put the customProperties["navSoStackSettings"] of stack stackName into CP
      if CP["template"] is empty then next repeat
      get convertToScriptOnlyStackBehaviors(SM[stackName],CP["behaviorFolder"],CP["template"],true,true,CP["space"],true)
   end repeat
   return empty
end convertToScriptOnlyStackBehaviorsAutomatic


function convertToScriptOnlyStackBehaviors idList,targetFolder,sosNameTemplate,stackifyScriptlessObjects,stackifySoSStacks,spaceSubstitute,withoutWarning
   if withoutWarning then
      put true into justDoIt
   else
      if answerf("This function makes major changes to your project." & cr & cr & "You have backups?","warning",,"Cancel","Yes, Proceed") is not "Yes, Proceed" then return "cancel"
      put answerf("You should test the command first, which will generate a log file but not change anything.","warning",,"Just Do It","Test and Report") is "Just Do It" into justDoIt
   end if
   put convertToUniqueLongIDs(idList) into idList
   
   
   -- build a list of the stacks containing the controls
   put uniqueStacksFromIDs(idList) into parentStackList
   put "Creating script-only behavior stacks for objects in the following stacks:" & cr & parentStackList & cr & cr into logData
   
   -- get a list of the existing file names in that folder & other excluded stack names
   put scriptOnlyStackNamesFromFolderList(targetFolder) into stackNameList
   put cr & parentStackList & cr & the openstacks & cr & the mainstacks after stackNameList
   
   -- calculate the relative path to that folder for each of the stacks
   repeat for each line S in parentStackList
      set the itemDelimiter to "/"
      put item 1 to -2 of the filename of stack S into stackFolder
      if stackFolder is empty and answerf("All stacks need to be saved to files to convert to script-only stack behaviors.","warning",,"Cancel") is "Cancel" then return S & cr & stackFolder & cr & cr & parentStackList
      set the itemDelimiter to comma
      put relativePath(stackFolder,targetFolder) into stackRelativePath[S]
      if stackRelativePath[S] is not empty then put "/" after stackRelativePath[S]
   end repeat
   
   
   repeat for each line tID in idList
      if (stackifyScriptlessObjects or the script of tID is not empty) and (stackifySoSStacks or word 1 of the name of tID is not "stack" or the scriptonly of tID is false) then
         put safeNameSerial(stackNameList,sosName(sosNameTemplate,tID,spaceSubstitute)) into soStackName[tID]
         put cr & soStackName[tID] after stackNameList
      else
         put "skipped" into soStackName[tID]
      end if
   end repeat
   
   put empty into scriptForSoSBehaviors
   put empty into scriptForScriptDeletions
   
   local tURLScheme
   if the platform is "Win32" then
      -- Windows users expect CRLF endings
      put "file:/" into tURLScheme
   else
      -- Everyone else can deal with LF endings
      put "binfile:/" into tURLScheme
   end if
   
   put 0 into skippedControlCount
   put 0 into soStackCreatedCount
   repeat for each key tID in soStackName
      if soStackName[tID] is "skipped" then
         add 1 to skippedControlCount
         next repeat
      end if
      add 1 to soStackCreatedCount
      -- -- -- generate the appropriate header  and get the script of the control
      put "script" && q(soStackName[tID]) & cr & the script of tID into sosScript
      
      -- -- -- write everything to the file
      put targetFolder & "/" & soStackName[tID] & ".livecodescript" into sosFilePath
      if there is a file sosFilePath then return answerf("Something went wrong. There has been a file name duplication:" && soStackName[tID] & ".livecodescript" & cr & "Conversion is incomplete.","warning",,"Cancel")
      if justDoIt then put sosScript into url (tURLScheme & sosFilePath)
      put cr & "Wrote the script of:" & cr & "    " & tID & cr & "to script-only stack:" & cr & "    " & sosFilePath & cr after logData
      try
         if justDoIt then set the script of tID to empty
         put "Deleted the script of:" & cr & "    " & tID & cr after logData
      catch someErr
         put "Failed to delete the script of:" & cr & "    " & tID & cr after logData
         put "set the script of" && tID && "to empty" & cr after scriptForScriptDeletions
      end try
      -- -- if the stack name is not in the stackFiles for the control's stack
      put the short name of (word -2 to -1 of tID) into stackName
      -- -- -- add the stack name to the control's stack's stackFiles
      put stackRelativePath[stackName] & soStackName[tID] & ".livecodescript" into stackFilePath
      if justDoIt then set the stackFiles of stack stackName to (the stackFiles of stack stackName) & cr & soStackName[tID],stackFilePath
      put "Added to the stackFiles of stack" && Q(stackName) & ":" & cr & "    " & soStackName[tID],stackFilePath & cr after logData
      -- end if
      --put the long id of stack soStackName[tID] into behaviorMap[tID]
   end repeat
   put cr after logData
   
   put 0 into behaviorSetCount
   put 0 into sosBehaviorCount
   repeat for each key tID in soStackName
      -- -- set the control's behavior to the stack name
      put the behavior of tID into tNewBehavior
      if tNewBehavior is not empty and soStackName[the long id of tNewBehavior] is not among the items of ",skipped" 
      then put "stack" && Q(soStackName[the long id of tNewBehavior]) into tNewBehavior
      if soStackName[tID] is not "skipped" then
         if tNewBehavior is not empty then
            if justDoIt then set the behavior of stack soStackName[tID] to the long id of tNewBehavior
            put "Set the behavior of stack" && Q(soStackName[tID]) && "to:" & cr & "    " & tNewBehavior & cr after logData
            add 1 to sosBehaviorCount
            put format("set the behavior of stack \"%s\" to the long id of %s\n",soStackName[tID],tNewBehavior) after scriptForSoSStackBehaviors
         end if
         if justDoIt 
         then put the long id of stack soStackName[tID] into tNewBehavior
         else put "stack" && Q(soStackName[tID]) into tNewBehavior
      end if
      if tNewBehavior is not the behavior of tID then
         if justDoIt then set the behavior of tID to the long id of tNewBehavior
         put "Set the behavior of" && tID && "to:" & cr & "    " & tNewBehavior & cr after logData
         
         add 1 to behaviorSetCount
      end if
   end repeat
   
   
   put soStackCreatedCount && "script-only stacks were created." & cr & \
         "Set" && behaviorSetCount && "behaviors for controls and script-only stacks." & cr & \
         iff(not stackifyScriptlessObjects,skippedControlCount && "controls skipped because of no script." & cr) & \
         iff(sosBehaviorCount > 0,"Set" && sosBehaviorCount && "behaviors for script-only stacks." & cr) & \
         "No errors were detected." into logMessage
   put logMessage & cr & cr & logData into returnData
   if scriptForSoSStackBehaviors is not empty then put cr & cr & "Use this script to set behaviors for script-only stacks:" & cr & cr & scriptForSoSStackBehaviors after returnData
   if scriptForScriptDeletions is not empty then put cr & cr & "Use this script to delete scripts that failed to delete:" & cr & cr & scriptForScriptDeletions after returnData
   if not justDoIt then put "THIS IS A TEST REPORT. NOTHING WAS ACTUALLY CHANGED." & cr & cr before returnData
   return returnData
   
end convertToScriptOnlyStackBehaviors

on showScriptConversion tIDList
   put tIDList into fld "id list convert" of stack "revBehavior Conversion"
   set the menuhistory of btn "tab menu" of stack "revBehavior Conversion" to 1
   set the minWidth of stack "revBehavior Conversion" to 520
   set the minHeight of stack "revBehavior Conversion" to 370
   palette stack "revBehavior Conversion"
end showScriptConversion

on showRestoreBehaviors tIDList
   put tIDList into fld "id list restore" of stack "revBehavior Conversion"
   set the menuhistory of btn "tab menu" of stack "revBehavior Conversion" to 2
   set the minWidth of stack "revBehavior Conversion" to 520
   set the minHeight of stack "revBehavior Conversion" to 370
   palette stack "revBehavior Conversion"
end showRestoreBehaviors

function relativePath P1,P2
   -- returns the relative path from P1 to P2
   if P1 is P2 then return empty
   set the itemdelimiter to "/"
   repeat until item 1 of P1 is not item 1 of P2
      delete item 1 of P1
      delete item 1 of P2
   end repeat
   repeat (the number of items of P1)
      put "../" after R
   end repeat
   return R & P2
end relativePath

function scriptOnlyStackNamesFromFolderList targetFolder
   -- only works on script-only stacks
   -- returns file names and stack names
   repeat for each line F in files(targetFolder)
      if char -15 to -1 of F is not ".livecodescript" then next repeat
      put (char 1 to -16 of F) & cr after R
      put "file:/" & targetFolder & "/" &  F into P
      put (char 2 to -2 of word -1 of line 1 of url P) into SN
      if SN is not char 1 to -16 of F then put SN & cr after R
   end repeat
   return char 1 to -2 of R
end scriptOnlyStackNamesFromFolderList

function uniqueStacksFromIDs idList
   repeat for each line tID in idList
      add 1 to stackList[the short name of stackNameFromID(tID)]
   end repeat
   return the keys of stackList
end uniqueStacksFromIDs

function stackNameFromID tID
   if word -5 of tID is "stack" then return word -5 to -4 of tID
   return the name of stack (word -2 to -1 of tID)
end stackNameFromID


function stackMapFromIDs idList
   repeat for each line tID in idList
      put the short name of stackNameFromID(tID) into SN
      if R[SN] is empty then put tID into R[SN] else put cr & tID after R[SN]
   end repeat
   return R
end stackMapFromIDs

function sosName patternString,controlLongID,spaceSubstitute
   return char -90 to -1 of replaceF(space,spaceSubstitute,replaceF(comma,empty,replaceF("/",empty,replaceF(":",empty,replaceF(quote,empty,value(patternString,controlLongID))))))
end sosName


function safeNameSerial currentNameList,candidateName
   -- takes a list of existing names and a new name
   -- returns the new name, optionally with a serial number if the name is already in the list
   if candidateName is not among the lines of currentNameList then return candidateName
   put 2 into serialNumber
   sort lines of currentNameList by word -1 of each
   repeat for each line L in currentNameList
      if word 1 to -2 of L is not candidateName then next repeat
      if word -1 of L > serialNumber then exit repeat
      put word -1 of L + 1 into serialNumber
   end repeat
   return candidateName && serialNumber
end safeNameSerial


on editObjectScripts pWhichLine,B
   local idList
   put getList(false,pWhichLine) into idList
   try
      repeat for each line tID in idList
         if B and the behavior of tID is not empty then put the behavior of tID into xID else put tID into xID
         repeat until not B or the script of xID is not empty  or the behavior of xID is empty
            put the behavior of xID into xID
         end repeat
         edit the script of xID
         repeat for each line W in the windows
            if word 1 of W is not "revNewScriptEditor" then next repeat
            go stack W
            exit repeat
         end repeat
      end repeat
   catch someErr
   end try
end editObjectScripts


on positionWindow
  if sWindowLoc is empty then
    put the loc of window (line 1 of the windows) into sWindowLoc
  else
    add 20 to item 1 of sWindowLoc
    add 20 to item 2 of sWindowLoc
    set the loc of window (line 1 of the windows) to sWindowLoc
  end if
end positionWindow


on enterAddPropValues
  local tAddProps, tPropCommand, tPropList
  
  put featuredPropertyArray() into tAddProps
  put the keys of tAddProps into tPropList
  put empty into tPropCommand
  repeat for each line tProp in tPropList
    put tProp & "=" & (tAddProps[tProp]) & cr after tPropCommand
  end repeat
  put tPropCommand into fld "command"
  set the pWorkingLines of group "commandGroup" to the long id of this stack
  dispatch "showMe" to group "commandGroup"
end enterAddPropValues


function allNavigators
  local R
  
  put the openStacks into R
  filter R with "revNavigator*"
  if there is a stack "Navigator" then return R & cr & "Navigator" else return R
end allNavigators


on setNavWidths L,R
  repeat for each line S in allNavigators()
    set the width of stack S to R-L
    set the left of stack S to L
    dispatch "setNavRect" to stack S with L,(the top of stack S),R,(the bottom of stack S)
  end repeat
end setNavWidths


on setVisNavigator pVis,doAll
   local tBottomTarget, tRect, tTopTarget
   
   if (not the cIAmHidden of this stack) is pVis then exit setVisNavigator
   if pVis is empty then put the cIAmHidden of this stack into pVis
   if doAll then
      repeat for each line S in allNavigators()
         dispatch "setVisNavigator" to stack S with pVis
      end repeat
      exit setVisNavigator
   end if
   if pVis then
      put item 2 of the cPreviousRect of this stack into tTopTarget
      put item 4 of the cPreviousRect of this stack into tBottomTarget
   else
      put the rect of this stack into tRect
      set the cPreviousRect of this stack to tRect
      put iff(the platform is "MacOS",22,1) into tTopTarget
      repeat for each line S in allNavigators() & cr & "revMenubar"
         if (the height of stack S is 15 or S is "revMenubar") and \
               item 1 of tRect < the right of stack S and \
               item 3 of tRect > the left of stack S then \
               put max(tTopTarget,the bottom of stack S) into tTopTarget
      end repeat
      put tTopTarget + 15 into tBottomTarget
   end if
   moveNavigator tTopTarget,tBottomTarget
   set the cIAmHidden of this stack to (not the cIAmHidden of this stack)
   set the icon of button "CloseNav" to iff(the cIAmHidden of this stack,2619,2621)
   set the icon of button "CloseNavAll" to iff(the cIAmHidden of this stack,2625,2624)
end setVisNavigator


on moveNavigator pTopTarget,pBottomTarget
  local tBottomDist, tBottomStep, tList, tRect, tTopDist
  local tTopStep
  
  put the rect of this stack into tRect
  put pTopTarget - item 2 of tRect into tTopDist
  put pBottomTarget - item 4 of tRect into tBottomDist
  if abs(tTopDist) > 300 then
    put tTopDist div 12 into tTopStep
    put tBottomDist div 12 into tBottomStep
    put "1,2,3,3,2,1" into tList
  else
    put tTopDist div 4 into tTopStep
    put tBottomDist div 4 into tBottomStep
    put "1,2,1" into tList
  end if
  repeat with i = 1 to the number of items of tList
    add (item i of tList) * tTopStep to item 2 of tRect
    add (item i of tList) * tBottomStep to item 4 of tRect
    set the rect of this stack to tRect
    set the rect of grc "navBorder" to 0,0,(the width of this stack),(the height of this stack)
    wait 0 ticks
  end repeat
  put pTopTarget into item 2 of tRect
  put pBottomTarget into item 4 of tRect
  set the rect of this stack to tRect
  set the rect of grc "navBorder" to 0,0,(the width of this stack),(the height of this stack)
end moveNavigator


on enableList
  if the enabled of fld "list" then exit enableList
  subtract 1 from sDisableCount
  if sDisableCount > 0 then exit enableList
  enable fld "list"
  set the hilitedLines of fld "list" to sLines
end enableList


on disableList
  if the enabled of fld "list" then put 0 into sDisableCount
  add 1 to sDisableCount
  if sDisableCount > 1 then exit disableList
  put the hilitedlines of fld "list" into sLines
  disable fld "list"
end disableList


on showGroup pID
  local tRate
  
  disableList
  put the effectRate into tRate
  set the effectRate to 500
  show pID with visual effect "scroll right"
  set the effectRate to tRate
end showGroup


on hideGroup pID
  local tRate
  
  put the effectRate into tRate
  set the effectRate to 500
  hide pID with visual effect "reveal left"
  set the effectRate to tRate
  enableList
end hideGroup


function allUniqueIDsOf pControlList,separateFields
  local tReturn, tWorking, X
  
  -- returns all the controls within
  put format("group,1\ncard,2\nstack,3") into X
  split X using cr and comma
  put canonicalIDsOf(pControlList) into pControlList
  sort lines of pControlList descending by X[word 1 of each]
  --answer pControlList
  repeat for each line cID in pControlList
    --put the long id of cID into cID
    if tReturn[cID] is not empty then next repeat
    --put true into tReturn[cID]
    put canonicalIDsOf(allControlIDsOf(cID),true,separateFields) into tWorking
    --answer tWorking
    --split tWorking by cr as set
    union tReturn with tWorking
  end repeat
  --answer the number of lines of the keys of tReturn
  return the keys of tReturn
end allUniqueIDsOf


function canonicalIDsOf cIDList, returnArray, fieldException
  local cID, cIDend, R
  
  repeat for each line cIDx in cIDList
    put the long id of cIDx into cID
    if word 5 of cID is "group" then
      if word -6 of cID is "card" then put -7 into cIDend else put -10 into cIDend
      put 1 into R[word 1 to cIDend of cID && word cIDend + 5 to -1 of cID]
    else
      put 1 into R[cID]
    end if
  end repeat
  if returnArray is true then return R else return (the keys of R) & cr
end canonicalIDsOf


function backgroundIDsOf stackID
  local backgroundIDList, bgID
  
  put empty into backgroundIDList
  repeat with i = 1 to 999999999
    if not (there is a background i of stackID) then return backgroundIDList
    put (the long id of background i of stackID) into bgID
    if word 5 of bgID is not "group" then put bgID & cr after backgroundIDList
  end repeat
end backgroundIDsOf

function backgroundsOf stackID,bFilter,returnType,typeModifier
   if returnType = "short name" and bFilter = "backgroundNames" then return the backgroundNames of stackID
   put empty into R
   repeat with i = 1 to 999999999
      if not (there is a background i of stackID) then return char 1 to -2 of R
      if not (bFilter = "all" \
            or bFilter = "backgroundNames" and the backgroundBehavior of background i of stackID \
            or bFilter = "base" and word 5 of the long id of background i of stackID is not "group") then next repeat
      if returnType = "id" then
         switch typeModifier
            case empty; put (the id of background i of stackID) & cr after R; break
            case "short"; put (the short id of background i of stackID) & cr after R; break
            case "long"; put (the long id of background i of stackID) & cr after R; break
         end switch
      else
         switch typeModifier
            case empty; put (the name of background i of stackID) & cr after R; break
            case "short"; put (the short name of background i of stackID) & cr after R; break
            case "long"; put (the long name of background i of stackID) & cr after R; break
         end switch
      end if
   end repeat
end backgroundsOf



function backgroundIDsOf stackID
     local backgroundIDList, bgID

   try
      repeat with i = 1 to 999999999
         put (the long id of background i of stackID) into bgID
         if word 5 of bgID is not "group" then put bgID & cr after backgroundIDList
      end repeat
   catch someErr
   end try
   return backgroundIDList
end backgroundIDsOf


function cardIDsOf stackID
  local cardIDList
  
  put "card id" && the cardIDs of stackID into cardIDList
  replace cr with " of" && the name of stackID & cr & "card id " in cardIDList
  return cardIDList && "of" && the name of stackID & cr
end cardIDsOf


function nonGroupChildControlIDsOf pContainerID
  local controlIDList, tReturnIDList
  
  put empty into tReturnIDList
  put the long id of pContainerID into pContainerID
  put the childControlIDs of pContainerID into controlIDList
  if controlIDList is empty then return pContainerID & cr
  put "control id " before controlIDList
  replace cr with " of" && pContainerID & cr & "control id " in controlIDList
  repeat for each line controlID in (controlIDList && "of" && pContainerID)
    if word 1 of the name of controlID is not "group" then put controlID & cr after tReturnIDList
  end repeat
  return pContainerID & cr & tReturnIDList
end nonGroupChildControlIDsOf

function addBehaviorChains tIDList
   repeat for each line tID in tIDList
      repeat
         put tID & cr after R
         if the behavior of tID is empty then exit repeat else put the behavior of tID into tID
      end repeat
   end repeat
   return R
end addBehaviorChains


function allControlIDsOf pContainerID
  local cIDend, cIDendString, controlIDList, controlList
  if not exists(pContainerID) then return empty
  put the long id of pContainerID into pContainerID
  --breakpoint
  switch word 1 of the name of pContainerID
    case "stack"
      return allIDsOfMainstack(pContainerID)
    case "card"
      put the controlIDs of pContainerID into controlList
      if controlList is empty then return pContainerID & cr
      repeat for each line cID in controlList
        put (the long id of control id cID of pContainerID) & cr after controlIDList
      end repeat
      return pContainerID & cr & controlIDList
    case "group"
      if word -6 of pContainerID is "card" then put -7 into cIDend else put -10 into cIDend
      put (word cIDend + 5 to -1 of pContainerID) & cr into cIDendString
      put the controlIDs of pContainerID into controlList
      if controlList is empty then return pContainerID & cr
      repeat for each line cID in controlList
        put "control" && (word 2 to cIDend of the long id of control id cID of pContainerID) && cIDendString after controlIDList
      end repeat
      return pContainerID & cr & controlIDList
    default
      --return "control" && word 2 to -1 of pContainerID
      return pContainerID
  end switch
end allControlIDsOf


function allIDsOfMainstack stackID
  local tReturn
  
  --answer "|" & the short name of stackID & cr & the substacks of stackID & "|"
  repeat for each line sName in the short name of stackID & cr & the substacks of stackID
    -- if the password of stack sName is empty then \
        put allIDsOfStack(the long id of stack sName) after tReturn
  end repeat
  return tReturn
end allIDsOfMainstack


function allIDsOfStack stackID
  local tReturnIDList
  
  put empty into tReturnIDList
  repeat for each line bgID in backgroundIDsOf(stackID)
    put allControlIDsOf(bgID) after tReturnIDList
  end repeat
  repeat for each line cdID in cardIDsOf(stackID)
    put nonGroupChildControlIDsOf(cdID) after tReturnIDList
  end repeat
  return (the long id of stackID) & cr & tReturnIDList
end allIDsOfStack


on waitForKeys commandState,controlState,optionState,shiftState,callbackHandler,targetID
  if char 1 of targetID is "'" then delete char 1 of targetID
  if (commandState is empty or the commandKey is commandState) \
        and (controlState is empty or the controlKey is controlState) \
        and (optionState is empty or the optionKey is optionState) \
        and (shiftState is empty or the shiftKey is shiftState) then
    send callbackHandler to targetID
  else
    send "waitForKeys" && commandState,controlState,optionState,shiftState,callbackHandler,("'" & targetID) to me in 15 ticks
  end if
end waitForKeys


function numberItems F,T
  local R
  
  repeat with i = F to T
    put i & comma after R
  end repeat
  return char 1 to -2 of R
end numberItems


function splitList S,tList
  local C, R
  
  sort items of tList numeric
  put 0 into C
  repeat for each item i in tList
    if i > S then exit repeat
    add 1 to C
  end repeat
  put item 1 to C of tList into R[1]
  put item (C + 1) to -1 of tList into R[2]
  return R
end splitList

on setColor pProp,pColor
   if pProp is "pColorFilterText" then set the textColor of fld "filter" to pColor
   if pProp is "pColorHighlight" then 
      set the hiliteColor of fld "list" to pColor
      set the hiliteColor of fld "filter" to pColor
   end if
   if pProp is "pColorListLines" then set the borderColor of fld "list" to pColor
   if pProp is "pColorBackground" then set the backgroundColor of this cd to pColor
   set the pProp of this stack to pColor
end setColor


function replaceF F,R,S
  replace F with R in S
  return S
end replaceF


function appendWithoutDupes L1,L2,D
  local L, LA, R
  
  if D is not empty then set the itemDel to D
  repeat for each item L in L1 & D & L2
    if LA[L] = 1 or L is empty then next repeat
    put L & D after R
    add 1 to LA[L]
  end repeat
  return char 1 to -2 of R
end appendWithoutDupes


function navStack
  return "revNavigator"
end navStack

function navWindowRects includeCollapsed,includeHidden
   repeat for each line W in the windows
      if word 1 of W is not among the items of "revNavigator,Navigator" then next repeat
      if not (the vis of stack W or includeHidden) then next repeat
      if not (not the cIAmHidden of stack W or includeCollapsed) then next repeat
      put (the rect of stack W) && W & cr after R
   end repeat
   return char 1 to -2 of R
end navWindowRects


function deDupe L,D
  split L using D as set
  delete variable L[D]
  return the keys of L
end deDupe


on setRecentProp typeList,P
  set the customPropertySet of stack navStack() to "gSBRecentPropsProp"
  repeat for each line aType in typeList
    set the aType of stack navStack() to line 1 to 5 of deDupe(splice(cr,P,the aType of stack navStack()),cr)
  end repeat
  set the customPropertySet of stack navStack() to empty
end setRecentProp


function splice D
  local R
  
  repeat with i = 2 to paramCount()
    if param(i) is not empty then put param(i) & D after R
  end repeat
  return char 1 to (-1 - len(D)) of R
end splice


function firstNotEmpty
  repeat with i = 1 to paramCount()
    if param(i) is not empty then return param(i)
  end repeat
end firstNotEmpty


function featuredPropertyArray pTypeList
  local R1, R2, R3
  
  set the customPropertySet of stack navStack() to "gSBRecentPropsProp"
  put the customProperties of stack navStack() into R1
  set the customPropertySet of stack navStack() to "gSBAddPropsProp"
  put the customProperties of stack navStack() into R2
  set the customPropertySet of stack navStack() to empty
  if pTypeList is empty then put deDupe(the keys of R1 & cr & the keys of R2,cr) into pTypeList
  repeat for each line T in pTypeList
    put splice(cr,R1[T],R2[T]) into R3[T]
  end repeat
  return R3
end featuredPropertyArray


function objectsAndPropertiesToEdit
   local addProps, R, tIDList
   
   -- returns an array of the valid selected ids and the properties that apply to them
   put getList() into tIDList
   put tIDList into tTypeSampleList
   split tTypeSampleList using cr and space
   combine tTypeSampleList using cr and space
   put propertiesInCommon(tIDList) into R
   put tIDList into R["idList"]
   put featuredPropertyArray(R["typeList"]) into addProps
   delete variable R["typeList"]
   combine addProps using cr
   put deDupe(addProps,cr) into addProps
   repeat for each line P in addProps
      put true into commonProp
      repeat for each line tID in tTypeSampleList
         try
            get the P of tID
         catch someErr
            put false into commonProp
            exit repeat
         end try
      end repeat
      if commonProp then put P & cr after commonAddProps
   end repeat
   sort lines of commonAddProps
   sort lines of R["propList"]
   if commonAddProps is not empty then put commonAddProps & "-" & cr before R["propList"]
   return R
end objectsAndPropertiesToEdit


function customPropertiesOfAll tIDList,uSet
   local R, tID, U
   
   -- returns an array
   -- "setList" is a list of all the customPropertySets the objects have
   -- "customPropList" is a list of all the custom properties the objects have within uSet customPropertySet
   put line 1 of tIDList into tID
   put the customPropertySets of tID into R["setList"]
   split R["setList"] using cr as set
   set the customPropertySet of tID to uSet
   put the customProperties of tID into R["customPropList"]
   repeat for each line tID in tIDList
      put the customPropertySets of tID into RSL
      split RSL using cr as set
      union R["setList"] with RSL
      set the customPropertySet of tID to uSet
      put the customProperties of tID into U
      union R["customPropList"] with U
   end repeat
   delete variable R["setList"]["cRevGeneral"]
   put the keys of R["setList"] into R["setList"]
   filter R["setList"] without empty
   sort lines of R["setList"]
   put the keys of R["customPropList"] into R["customPropList"]
   filter R["customPropList"] without empty
   sort lines of R["customPropList"]
   return R
end customPropertiesOfAll


function propertiesInCommon tIDList
  local R
  
  -- returns an array:
  -- "typeList" is a list of the types of objects
  -- "propList" is a list of the properties that apply to all of the objects
  put the properties of (line 1 of tIDList) into R["propList"]
  repeat for each line tID in tIDList
    if R["typeList"][word 1 of tID] = 1 or there is not a tID then next repeat
    put 1 into R["typeList"][word 1 of tID]
    intersect R["propList"] with (the properties of tID)
  end repeat
  put the keys of R["typeList"] into R["typeList"]
  put the keys of R["propList"] into R["propList"]
  return R
end propertiesInCommon

function newNavigator targetContainerList,navNameList
   lock screen
   put ticks() into navIndex
   put the loc of this stack into navLoc
   repeat with i = 1 to the number of lines of targetContainerList
      put line i of targetContainerList into targetContainer
      put line i of navNameList into navName
      if navName is empty then 
         put iff(the optionKey is "up","rev","") & "Navigator" && navIndex into navName
         add 1 to navIndex
      end if
      clone stack "revNavigator"
      set the name of it to navName
      --put navName,targetContainer & cr & there is a stack navName & cr & ticks() into fld 1 of stack "behavior demo"
      
      if item 1 of navLoc < item 3 of the screenRect then add 20 to item 1 of navLoc
      if item 2 of navLoc < item 4 of the screenRect then add 20 to item 2 of navLoc
      set the loc of stack navName to navLoc
      set the backgroundcolor of grc "navTitleBar" of stack navName to "180,180,180"
      setNavigatorTarget navName,targetContainer
   end repeat
   cleangREVMessageDispatch
   unloack screen
   return navName
end newNavigator

on setNavigatorTarget navName,targetContainer
   if navName is not empty and navName is not the short name of me then 
      dispatch "setNavigatorTarget" to stack navName with empty,targetContainer
      exit setNavigatorTarget
   end if
   if navName is empty then put the short name of me into navName
   put targetContainer into navigatorTarget
   setGlobalsFromTarget navigatorTarget
   doUpdateDisplay true
end setNavigatorTarget

function reportGlobals
   repeat for each item V in "gSBWhichStack,gSBWhichCard,gSBCardOrBackground,gSBWhichBackground,gSBShowList"
      do "put" && V &  "[the short name of this stack] into R[" & Q(V) & "]"
   end repeat
   return R
end reportGlobals

on setGlobalsFromTarget targetContainer
   put the short name of me into navName
   put globalsFromTarget(targetContainer) into V
   --    put targetContainer into fld 1 of stack "untitled 1"
   --    exit setGlobalsFromTarget
   put V["WhichStack"] into gSBWhichStack[navName]
   put V["WhichCard"] into gSBWhichCard[navName]
   put V["CardOrBackground"] into gSBCardOrBackground[navName]
   put V["WhichBackground"] into gSBWhichBackground[navName]
   put V["ShowList"] into gSBShowList[navName]
   
   --    repeat for each item G in "WhichStack,WhichCard,CardOrBackground,WhichBackground,ShowList"
   --       put "put V[" & Q(G) & "] into gSB" & G & "[navName]" & cr after T
   --    end repeat
   --    put T into fld 1 of stack "untitled 1"
   --    lock messages
   --    do T
   --    unlock messages
   --set the loc of stack navName to 300,300
end setGlobalsFromTarget


function targetFromNavigatorGlobals navName
   if navName is empty then put the short name of me into navName
   if navName is the short name of me then return targetFromGlobals(gSBWhichStack[navName],gSBShowList[navName],gSBCardOrBackground[navName],gSBWhichCard[navName],gSBWhichBackground[navName])
   dispatch function "targetFromGlobals" to stack navName with navName
   return the result
end targetFromNavigatorGlobals

function targetFromGlobals whichStack,showList,cardOrBackground,whichCard,whichBackground
   put whichStack into SN
   if SN is not "the topStack" and SN is not empty then put the long id of stack SN into SN
   if showList is "true" then 
      if cardOrBackground = "stack" then return "stack list"
      return cardOrBackground && "list of" && SN
   end if
   if cardOrBackground is "background" then return the long id of group (whichBackground && "of" && SN)
   return whichCard && "of" && SN 
end targetFromGlobals

function globalsFromTarget navTarget
   -- returns an array with whichStack,showList,cardOrBackground,whichCard,whichBackground
   put (word 2 of navTarget is "list") into R["showList"]
   put word iff(word 1 of navTarget is "this",2,1) of navTarget into R["cardOrBackground"]
   if R["cardOrBackground"] is "group" then put "background" into R["cardOrBackground"]
   
   if R["showList"] then
      if R["cardOrBackground"] is not "stack" then put R["cardOrBackground"] && "list" into R["which" & R["cardOrBackground"]]
      return R
   end if
   
   if word -5 of navTarget is "stack" then 
      put the value of word -4 of navTarget into R["whichStack"]
      put word 1 to -7 of navTarget into R["which" & R["cardOrBackground"]]
   else if word -2 to -1 of navTarget is "the topstack" then 
      put "the topstack" into R["whichStack"]
      put word 1 to -4 of navTarget into R["which" & R["cardOrBackground"]]
   else if navTarget is not "stack list" then 
      put the short name of stack (word -2 to -1 of navTarget) into R["whichStack"]
      put word 1 to -4 of navTarget into R["which" & R["cardOrBackground"]]
   end if
   
   return R
   
   
   
   if word 1 to 2 of navTarget is "this card" then 
      put "this card" into R["whichCard"]
   else if R["whichStack"] is "the topStack" then 
      put word 1 to -4 of navTarget into R["whichCard"]
   else if R["cardOrBackground"] is not "stack" then
      put the long id of navTarget into R["which" & R["cardOrBackground"]]
   end if
   return R
end globalsFromTarget


function navigatorTarget navName
   -- returns one of the following:

   -- <card id> of the topstack
   -- this card of the topstack
   -- this card of stack "<stack name>"
   
   -- stack list
   -- card list of the topstack
   -- card list of stack "<stack name>"
   -- background list of the topstack
   -- background list of stack "<stack name>"
   
   -- <card long id>
   -- <group long id>
   
   if navName is empty or navName is the short name of me then return navigatorTarget
   dispatch function "navigatorTarget" to stack navName
   return the result
end navigatorTarget




function existenceWarning pID
  if (there is a pID) then return pID
  answer warning (pID && "not found.") with "OK"
  if the optionkey is "down" then put the executioncontexts
  return empty
end existenceWarning


on objectInspector1
  local tCMD, TS
  put "select " into tCMD
  repeat for each line L in getList()
    put L && "and " after tCMD
  end repeat
  delete word -1 of tCMD
  if word -5 of tCMD is "stack" then put word -4 of tCMD into TS else put word -1 of tCMD into TS
  go stack (char 2 to -2 of TS)
  --put the result
  do (tCMD)
  dispatch "menuPick" to button "Object" of group "revMenuBar" of stack "revMenuBar" with "Object Inspector"
end objectInspector1

function sortF S,D
   if D is not empty then set the itemdel to D
   sort items of S
   return S
end sortF

function scriptHandlers S
   local R, LC
   put 0 into LC
   repeat for each line L in S
      add 1 to LC
      if not (word 1 of L is among the items of "on,function,getprop,setprop,before,after,command" or (word 1 of L is "private" and word 2 of L is among the items of "on,command,function"))  then next repeat
      put word 1 to 3 of L into handlerName
      if word 1 of L is "private" 
      then put word 1 to 3 of L into handlerName
      else put word 1 to 2 of L into handlerName
      put LC into R["name"][handlerName]
      put word 1 to -1 of L into R["template"][handlerName]
   end repeat
   return R
end scriptHandlers


on cleangREVMessageDispatch
  local tOpenList
  --put  ticks() & cr & gREVMessageDispatch["revSelectedObjectChanged"]
  put the openStacks into tOpenList
  filter tOpenList with "rev*"
  delete variable gREVMessageDispatch
  repeat for each line S in tOpenList
    repeat for each line P in (the keys of (the customProperties["cREVLoadInfo"] of stack S))
      put S & cr after gREVMessageDispatch[P]
    end repeat
  end repeat
  repeat for each key K in gREVMessageDispatch
    delete char -1 of gREVMessageDispatch[K]
  end repeat
end cleangREVMessageDispatch

on doCodeNN S,xIDList,yIDList
   repeat for each line xID in xIDList
      repeat for each line yID in yIDList
         put S into sCMD
         replace "xID" with xID in sCMD
         replace "yID" with yID in sCMD
         try
            do sCMD
         catch someErr
            answer warning "Error:" && someErr & cr & "Continue?" with "Cancel" and "Okay"
            if it is "Cancel" then exit doCodeNN
         end try
      end repeat
   end repeat
end doCodeNN

on doCodeN1 S,xIDList,yID
   replace "yID" with yID in S
   repeat for each line xID in xIDList
      put S into sCMD
      replace "xID" with xID in sCMD
      try
         do sCMD
      catch someErr
         answer warning "Error:" && someErr & cr & "Continue?" with "Cancel" and "Okay"
         if it is "Cancel" then exit doCodeN1
      end try
   end repeat
end doCodeN1


function stitchPaths P1,P2
   set the itemdelimiter to "/"
   repeat until item 1 of P2 is not ".."
      delete item 1 of P2
      delete item -1 of P1
   end repeat
   if char -1 of P1 is "/" then delete char -1 of P1
   if char 1 of P2 is "/" then delete char 1 of P2
   return P1 & "/" & P2
end stitchPaths

on forceNControls pID,N
   if N is not a number then exit forceNControls
   if N < 1 then put 2 into S else put N + 1 into S
   repeat the number of controls of pID - S + 1
      delete control S of pID
   end repeat
   repeat N - the number of controls of pID
      clone control 1 of pID
   end repeat 
   if N = 0 then hide control 1 of pID else show control 1 of pID
end forceNControls

on debugNavigator B
   global gRevDevelopment
   put B into gRevDevelopment
end debugNavigator


-- MAYBE UNNEEDED?

on setRevNavigatorStackName pStackname
  local QS, tID2, tIDList
  
  if pStackname is empty then put "revNavigator" into pStackname
  set the itemdel to quote
  put allIDsOfMainstack(the long id of stack "Navigator") into tIDList
  --   put tIDList
  --   exit setNavigatorStackName
  
  set the name of stack "Navigator" to pStackname
  put Q(pStackname) into QS
  save this stack
  repeat for each line tID in tIDList
    put (word 1 to -2 of tID) && QS into tID2
    if the behavior of tID2 is not empty then \
          set the behavior of tID2 to \
          the long id of ((item 1 of the behavior of tID2) & QS)
  end repeat
end setRevNavigatorStackName



on setNavigatorStackName pStackname
  local QS, tID2, tIDList
  
  if pStackname is empty then put "Navigator" into pStackname
  set the itemdel to quote
  put allIDsOfMainstack(the long id of stack "revNavigator") into tIDList
  --   put tIDList
  --   exit setNavigatorStackName
  
  set the name of stack "revNavigator" to pStackname
  put Q(pStackname) into QS
  save this stack
  repeat for each line tID in tIDList
    put (word 1 to -2 of tID) && QS into tID2
    if the behavior of tID2 is not empty then \
          set the behavior of tID2 to \
          the long id of ((item 1 of the behavior of tID2) & QS)
  end repeat
end setNavigatorStackName

