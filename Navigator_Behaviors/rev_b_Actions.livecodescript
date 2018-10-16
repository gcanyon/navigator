script "rev_b_Actions"
global gSBControlSets
global gSBshowTooltip -- if true, show tooltip
global gSBshowListLines -- if true, show list lines in fld "list"
global gSBWhichStack,gSBWhichCard,gSBCardOrBackground,gSBWhichBackground,gSBShowList,gSBLeadSpaces

local addPropertiesForType

global gRevDevelopment
on mouseDown
   if line -1 of the text of me contains "Debug IDE" then set the text of me to line 1 to -3 of the text of me
   if the optionKey is down then set the text of me to the text of me & cr & "-" & cr & iff(gRevDevelopment,"!c","") & "Debug IDE"
end mouseDown

on menuPick pWhich
   switch pWhich
      case "Debug IDE"
         debugNavigator; break
      case "Prefs..."
         set the pNavigatorName of stack "revNavigatorPrefs" to the short name of this stack
         palette stack "revNavigatorPrefs"
         break
      case "About Navigator..."
         send "showMe" to group "about"
         break
      case "New Navigator"
         put "revNavigator" && ticks() into sName
         clone this stack
         set the name of it to sName
         set the backgroundcolor of grc "navTitleBar" of stack sName to "180,180,180"
         repeat for each item V in "gSBWhichStack,gSBWhichCard,gSBCardOrBackground,gSBWhichBackground,gSBShowList,gSBLeadSpaces"
            do ("put" && V & "[" & quote & the short name of this stack & quote & "] into" && V & "[" & quote & sName & quote & "]")
         end repeat
         cleangREVMessageDispatch
         dispatch "updateDisplay" to stack sName with true
         break
      case "Find in Scripts..."
         bookMarkFoundInScriptControls "Find in scripts for all displayed controls",getID("all")
         break
      case "Find by Test..."
         bookmarkFoundByTestControls "Find by test for all displayed controls",getID("all")
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
         send ("doUpdateDisplay true") to me in 6 ticks
         break
      case "Bookmark|MouseControl..."
         getMouse the owner of the owner of me,"setBookmarksByMouse"
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
      default
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
