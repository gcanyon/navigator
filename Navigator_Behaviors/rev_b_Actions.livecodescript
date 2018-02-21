script "rev_b_Actions"
global gSBControlSets
global gSBshowTooltip -- if true, show tooltip
global gSBshowListLines -- if true, show list lines in fld "list"
global gSBWhichStack,gSBWhichCard,gSBCardOrBackground,gSBWhichBackground,gSBShowList

local addPropertiesForType

on menuPick pWhich
   switch pWhich
      case "About Navigator..."
         --          repeat for each item V in "gSBWhichStack,gSBWhichCard,gSBCardOrBackground,gSBWhichBackground,gSBShowList"
         --             do "put" && V & "[the short name of this stack] & cr after R"
         --          end repeat
         --put R into line 9 to 99 of fld "aboutHead"
         
         send "showMe" to group "about"
         break
      case "New Navigator"
         clone this stack
         --put "Navigator Clone" into fld "Navigator Title" of it
         set the backgroundcolor of grc "navTitleBar" of it to "180,180,180"
         if the optionKey is "down"
         then put "Navigator" && ticks() into sName
         else put "revNavigator" && ticks() into sName
         set the name of it to sName
         repeat for each item V in "gSBWhichStack,gSBWhichCard,gSBCardOrBackground,gSBWhichBackground,gSBShowList"
            do "put" && V & "[the short name of this stack] into" && V & "[sName]"
         end repeat
         cleangREVMessageDispatch
         break
      case "Find in Scripts..."
         put the separatorLine of fld "list" into tSeparator
         put getLineIDList("all") into tList
         ask "Find:" with "search string" titled "Find in Scripts"
         if it is empty or the result is not empty then break
         put it into tSearchString
         put empty into tIDList
         repeat for each line tLine in tList
            put word 2 to -1 of tLine into tID
            if tSearchString is not in the script of tID then next repeat
            if word 1 of tLine <= tSeparator then bookmarkRemove (word 1 of tLine)
            put tID & cr after tIDList
         end repeat
         if tIDList is not empty then setBookmarks ,tIDList
         break
      case "Find by Test..."
         put the separatorLine of fld "list" into tSeparator
         put getLineIDList("all") into tList
         ask "Test:" with "search string" titled "Find by Test"
         if it is empty or the result is not empty then break
         put it into tCondition
         put empty into tIDList
         repeat for each line tLine in tList
            put tCondition into tTest
            put word 2 to -1 of tLine into tID
            replace "tID" with tID in tTest
            try
               if not value(tTest) then next repeat
               if word 1 of tLine <= tSeparator then bookmarkRemove (word 1 of tLine)
               put tID & cr after tIDList
            catch tErr
               answer "There was a problem evaluating:" & cr & tTest & cr & cr & "Error:" & cr & tErr
               if it is "Cancel" then break
            end try
         end repeat
         if tIDList is not empty then setBookmarks ,tIDList
         break
      case "Rename"
         renameObjects
         break
      case "Delete"
         deleteObjects
         break
      case "Clone Objects"
         cloneObjects
         break
      case "Edit Scripts"
         editObjectScripts
         break
      case "Filter..."
         ask "Filter Controls (tID is control reference):" with the filterString of this stack
         if the result is not empty then break
         set the filterString of this stack to it
         doUpdateDisplay true
         break
      case "Command..."
         send "showMe" to group "commandGroup"
         break
      case "Update List Now"
         send ("doUpdateDisplay") to me in 6 ticks
         break
      case "Bookmark|MouseControl..."
         if the optionKey is not "down" then
            answer "Please hold down the option/alt key while selecting this menu item. Release the option/alt key with the mouse pointer over the control you wish to bookmark." with "OK"
            break
         end if
         set the lockCursor to true
         set the cursor to plus
         send "bookmarkMouseControl" to me in 5 ticks
         break
      case "Bookmark|Selected Objects"
         setBookmarks ,(the selectedObjects)
      case "Bookmark|Selected Lines"
         setBookmarks
         break
      case "Remove"
         removeBookmarks
         break
      case "Remove All"
         removeAllBookmarks
         break
      case "Save Control Set..."
         put the separatorLine of fld "list" into tSeparatorLine
         if tSeparatorLine is 0 then break
         put the htmlText of line 1 to tSeparatorLine of fld "list" into tHTMLText
         ask "Bookmark Name:" with "Bookmarked Set"
         if the result is not empty then break
         put it into tSetName
         replace space with empty in tSetName
         replace "-" with empty in tSetName
         put tHTMLText into gSBControlSets[tSetName]
         updateMyControlSets
         updateDisplay true
         break
      case "Prefs|Indent String..."
         put the pIndentString of this stack into tIndentString
         ask "Enter the string to use to indent group objects:" with tIndentString
         if the result is not empty then break
         set the pIndentString of this stack to it
         updateDisplay
         break
         --      case "Prefs|Add Properties..."
         --         --beep
         --         enterAddPropValues
         --         break
      case "Prefs|Add Properties|Stack"
      case "Prefs|Add Properties|Card"
      case "Prefs|Add Properties|Group"
      case "Prefs|Add Properties|Field"
      case "Prefs|Add Properties|Button"
      case "Prefs|Add Properties|Scrollbar"
      case "Prefs|Add Properties|Graphic"
      case "Prefs|Add Properties|Image"
      case "Prefs|Add Properties|Player"
         set the customPropertySet of stack navStack() to "gSBAddPropsProp"
         put the customProperties of stack navStack() into R2
         set the customPropertySet of stack navStack() to empty
         set the uID of group "editContents" to the long id of me
         set the itemDelimiter to "|"
         put item 3 of pWhich into addPropertiesForType
         set the uDialogText of group "editContents" to R2[addPropertiesForType]
         dispatch "showMe" to group "editContents" with true
         break         
      case "Prefs|Colors|Default..."
      case "Prefs|Colors|Scripted Object..."
      case "Prefs|Colors|Behavior Scripted..."
      case "Prefs|Colors|Script and Behavior..."
      case "Prefs|Colors|Object Missing..."
      case "Prefs|Colors|Filter Text..."
      case "Prefs|Colors|HighLight..."
      case "Prefs|Colors|List Lines..."
      case "Prefs|Colors|Background..."
         set the itemDelimiter to "|"
         put "pColor" & replaceF(space,empty,char 1 to -4 of item 3 of pWhich) into tPropName
         answer color with the tPropName of this stack
         if the result is empty then setColor tPropName,it
         break
      default
         if char 1 to 13 of pWhich is "Prefs|Colors|" then
            put replaceF(space,empty,(char 14 to -1 of pWhich)) into cProp
            repeat for each line P in the cProp of this stack
               setColor (item 1 of P),(item 2 to -1 of P)
            end repeat
            send ("doUpdateDisplay") to me in 6 ticks
            break
         end if
         set the itemDelimiter to "-"
         if pWhich is among the lines of item -1 of me then
            
            --put pWhich
            if pWhich is "ControlSets" then break
            if the optionKey is "down" then
               answer "Delete control set" && quote & pWhich & quote & "?" with "Cancel" or "OK"
               if it is "ok" then
                  delete variable gSBControlSets[pWhich]
                  updateMyControlSets
               end if
               break
            end if
            put the separatorLine of fld "list" into tSeparatorLine
            if tSeparatorLine is 0 or the commandKey is "down" then
               put " " & cr before fld "list"
               put 1 into tSeparatorLine
            end if
            --put gSBControlSets[pWhich]
            set the htmlText of line 1 to tSeparatorLine of fld "list" to gSBControlSets[pWhich]
            setSeparatorLine
            updateDisplay true
            break
         end if
         
         --Next, if it's not prefs, then bail:
         
         set the itemDelimiter to "|"
         if item 1 of pWhich is "Show" then
            if item 2 of pWhich is among the items of "Named Objects Only|Scripted Objects Only" then
               put "Prefs" into item 1 of pWhich
            else if item 2 of pWhich is "tooltips" then
               put "Prefs|Show Tooltip" into pWhich
            else if item 2 of pWhich is "List Lines" then
               put "Prefs|Show List Lines" into pWhich
            else
               
               put item 2 of pWhich into tSetting
               set the uDisplay of this stack to tSetting
               put me into tContents
               set the wholematches to true
               put lineOffset("show",tContents) into tStart
               put line tStart + 1 to tStart + 5 of tContents into tChoices
               set the wholematches to false
               put lineOffset(tSetting,tChoices) into tWhich
               repeat with i = 1 to 5
                  if i is tWhich then
                     put "!c" into tMark
                     put "!n" into tUnmark
                  else
                     put "!n" into tMark
                     put "!c" into tUnmark
                  end if
                  if char 1 to 2 of line tStart + i of tContents is tMark then next repeat
                  if char 1 to 2 of line tStart + i of tContents is tUnmark then
                     put tMark into char 1 to 2 of line tStart + i of tContents
                  else
                     put tMark before line tStart + i of tContents
                  end if
               end repeat
               put tContents into me
               updateDisplay true,true
            end if
         end if
         
         if item 1 of pWhich is not "Prefs" then break
         
         
         put item 2 to -1 of pWhich into tProperty
         put tProperty into tPropertyChoice
         if tPropertyChoice is "Show ToolTip" then put "tooltips" into tPropertyChoice
         if tPropertyChoice is "Show List Lines" then put "List Lines" into tPropertyChoice
         put me into tContents
         replace space with "" in tProperty
         put item 1 of tProperty into tPropName
         put item 2 of tProperty into tPropValue
         
         if tProperty contains "|" then
            
            
            put item 1 of tPropertyChoice into tMenuItem
            put item 2 of tPropertyChoice into tSubMenuItem
            if tMenuItem is among the items of "Menu Limit:|Object Limit:" then
               put "p" & (char 1 to -2 of tPropName) into tPropName
               set the tPropName of this stack to tSubMenuItem
               --put tPropName && tSubMenuItem
               put lineOffset(tMenuItem,tContents) into tWhichItem
               repeat
                  add 1 to tWhichItem
                  if not (line tWhichItem of tContents contains tab&tab) then exit repeat
                  if word -1 of line tWhichItem of tContents is tSubMenuItem then
                     put "!c" into char 1 to 2 of line tWhichItem of tContents
                  else
                     put "!n" into char 1 to 2 of line tWhichItem of tContents
                  end if
               end repeat
               put tContents into me
               break
            end if
            --answer tPropName && tPropValue;exit to top
            set the tPropName of this stack to tPropValue
            if tPropName is "listFontSize" then set the textSize of fld "list" to tPropValue
            put lineOffset(tMenuItem,tContents) into tWhichItem
            repeat
               add 1 to tWhichItem
               if line tWhichItem of tContents contains tSubMenuItem then exit repeat
            end repeat
            --answer tWhichItem;exit to top
            put 0 into tLineToUncheck
            repeat for each line L in tContents
               add 1 to tLineToUncheck
               if tab&tab is not in L then put L into tPropertyToClear
               if tLineToUncheck is tWhichItem or \
                     tSubMenuItem is not in L or \
                     char 1 to 2 of L is not "!c" \
                     then next repeat
               put "!n" into char 1 to 2 of line tLineToUncheck of tContents
               replace " " with empty in tPropertyToClear
               set the tPropertyToClear of this stack to empty
            end repeat
            
            if char 1 to 2 of line tWhichItem of tContents is "!n" then
               put "!c" into char 1 to 2 of line tWhichItem of tContents
            else if char 1 to 2 of line tWhichItem of tContents is not "!c" then
               put "!c" before line tWhichItem of tContents
            end if
            put tWhichItem into tClearItem
            repeat
               subtract 1 from tClearItem
               if tab&tab is not in line tClearItem of tContents then exit repeat
               if char 1 to 2 of line tClearItem of tContents is "!c" then
                  put "!n" into char 1 to 2 of line tClearItem of tContents
               else if char 1 to 2 of line tClearItem of tContents is not "!n" then
                  put "!n" before line tClearItem of tContents
               end if
            end repeat
            put tWhichItem into tClearItem
            repeat
               add 1 to tClearItem
               if tab&tab is not in line tClearItem of tContents then exit repeat
               if char 1 to 2 of line tClearItem of tContents is "!c" then
                  put "!n" into char 1 to 2 of line tClearItem of tContents
               else if char 1 to 2 of line tClearItem of tContents is not "!n" then
                  put "!n" before line tClearItem of tContents
               end if
            end repeat
         else            
            put lineOffset(tPropertyChoice,tContents) into tWhichItem
            if char 1 to 2 of line tWhichItem of tContents is "!n" then
               put "!c" into char 1 to 2 of line tWhichItem of tContents
               set the tProperty of this stack to true
               if tProperty is "showTooltip" then
                  put true into gSBshowTooltip
               else if tProperty is "showListLines" then
                  set the hGrid of fld "list" to true
                  put true into gSBshowListLines
               end if
            else
               if char 1 to 2 of line tWhichItem of tContents is "!c" then
                  put "!n" into char 1 to 2 of line tWhichItem of tContents
               else
                  put "!n" before line tWhichItem of tContents
               end if
               set the tProperty of this stack to false
               if tProperty is "showTooltip" then
                  set the tooltip of fld "list" to empty
                  put false into gSBshowTooltip
               else if tProperty is "showListLines" then
                  set the hGrid of fld "list" to false
                  put false into gSBshowListLines
               end if
            end if
         end if
         
         
         put tContents into me
         
         updateDisplay true,true
         --answer "restoring"
         --restoreHilitedLines
   end switch
end menuPick

on updateMyControlSets
  put the keys of gSBControlSets into tList
  if tList is empty then
    put "ControlSets" into tList
  else
    sort lines of tList
  end if
  set the itemDelimiter to "-"
  put cr & tList into item -1 of me
end updateMyControlSets

on cleanMyControlSets
  set the itemDelimiter to "-"
  put  cr & "ControlSets" into item -1 of me
  put me into tText
end cleanMyControlSets

on bookmarkMouseControl
  if the lockCursor is false then set the lockCursor to true
  set the cursor to hand
  if the optionKey is "down" then
    send "bookmarkMouseControl" to me in 10 ticks
    exit bookmarkMouseControl
  end if
  set the lockCursor to false
  setBookmarks ,(the long id of the mouseControl)
end bookmarkMouseControl

on resultMessage
   set the customPropertySet of stack navStack() to "gSBAddPropsProp"
   set the addPropertiesForType of stack navStack() to fld "setContents"
   set the customPropertySet of stack navStack() to empty
end resultMessage
