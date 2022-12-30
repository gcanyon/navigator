script "rev_b_Actions"
local addPropertiesForType

global gRevDevelopment
on mouseDown
   put the uBaseText of me into IL
   put the customProperties["controlSets"] of stack navStack() into CS
   put the keys of CS into setList
   if setList is empty then put "ControlSets" after IL else put setList after IL
   if the optionKey is down then put cr & "-" & cr & iff(gRevDevelopment,"!c","") & "Debug IDE" after IL
   set the text of me to IL
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
         setNavigatorTarget sName,checkCurrentNavTarget()
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
         updateDisplay true
         break
      case "Command..."
         send "showMe" to group "commandGroup"
         break
      case "Update List Now"
         updateDisplay true
         --send ("updateDisplay true") to me in 6 ticks
         break
      case "Bookmark|MouseControl..."
         getMouse the owner of the owner of me,"setBookmarksByMouse"
         break
      case "Bookmark|Selected Objects"
         setBookmarks ,(the selectedObjects)
      case "Bookmark|Selected Lines"
         setBookmarks
         break
      case "Bookmark|Nav Targets"
         setBookmarks ,navTargetList(),true
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
         put the customProperties["controlSets"] of stack navStack() into CS
         if CS[tSetName] is not empty then
            answer warning ("Overwrite existing set:" && tSetName) with "Cancel" or "Overwrite"
            if it is not "Overwrite" then break
         end if
         put tHTMLText into CS[tSetName]
         set the customProperties["controlSets"] of stack navStack() to CS
         updateDisplay true
         break
      default
         set the itemDelimiter to "-"
         if pWhich is "ControlSets" or pWhich is not among the lines of item -1 of me then break
         put the customProperties["controlSets"] of stack navStack() into CS
         if the optionKey is "down" then
            answer "Delete control set" && quote & pWhich & quote & "?" with "Cancel" or "Delete"
            if it is not "Delete" then break
            delete variable CS[pWhich]
            set the customProperties["controlSets"] of stack navStack() to CS
            break
         end if
         put the separatorLine of fld "list" into tSeparatorLine
         if tSeparatorLine is 0 or the commandKey is "down" then
            put " " & cr before fld "list"
            put 1 into tSeparatorLine
         end if
         set the htmlText of line 1 to tSeparatorLine of fld "list" to CS[pWhich]
         setSeparatorLine (the number of lines of CS[pWhich])
         updateDisplay true
         break
   end switch
end menuPick


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
