script "rev_g_setColors"
local sIDList -- list of ids of objects to set
local sClickedID -- id of the object that was clicked to display
local sUndoArray -- a list of the original colors to undo


on setup pID
   if pID is empty then put getClickedID() into pID
   clearColorCheckboxes
   editColors pID,getID()
   showMe
end setup

on editCurrentHighlights
   editColors getClickedID(),theHilitedIDs()
end editCurrentHighlights

on editColors pID,pIDList
   put pIDList into sIDList
   if pID is empty 
   then put line 1 of sIDList into sClickedID
   else put pID into sClickedID   
   delete variable sUndoArray
   repeat for each line tID in sIDList
      repeat for each word tColor in "foregroundcolor backgroundcolor hilitecolor bordercolor topcolor bottomcolor shadowcolor focuscolor"
         put the tColor of tID into sUndoArray[tID][tColor]
      end repeat
   end repeat
   repeat for each word tColor in "foreground background hilite border top bottom shadow focus"
      if not the hilite of button tColor then next repeat
      put "color" after tColor
      changeSettings(tColor)
      exit repeat
   end repeat
   
   put (the name of sClickedID) && "[" & the id of sClickedID & "]" into tTitle
   if the number of lines of sIDList > 1 then put cr & "and" && (-1 + the number of lines of sIDList) && "others" after tTitle
   put tTitle into fld "edit colors title"
end editColors

on resetColors
   repeat for each key tID in sUndoArray
      repeat for each word tColor in "foregroundcolor backgroundcolor hilitecolor bordercolor topcolor bottomcolor shadowcolor focuscolor"
         set the tColor of tID to sUndoArray[tID][tColor]
      end repeat
   end repeat
end resetColors

on clearColorCheckboxes
   repeat for each word tColor in "foreground background hilite border top bottom shadow focus"
      set the hilite of button tColor to false
   end repeat
end clearColorCheckboxes

on changeSettings pColorName
   setScrollbars (the effective pColorName of sClickedID)
end changeSettings

on setScrollbars pColor
   lock messages
   repeat with i = 1 to 3
      set the thumbPosition of scrollbar (item i of "red,green,blue") to (item i of pColor)
      put (item i of pColor) into fld ((item i of "red,green,blue") && "number")
   end repeat
   set the backgroundcolor of fld "color swatch" to pColor
   unlock messages
end setScrollbars

on showMe
   if (the optionKey is "down") is (the EditorsAsPalettes of stack "revNavigator") then
      showGroup (the long id of me)
   else
      updatePalettes "color editor",true
   end if
end showMe

on hideMe
   if word 1 of the short name of this stack is "revNavigatorp"
   then close this stack
   else hideGroup the long id of me
end hideMe

on mouseDown
   if not (word 1 of the name of the target is "scrollbar") then exit mouseDown
   repeat for each item C in "red,green,blue"
      set the startScroll of scrollbar C to the thumbposition of scrollbar C
   end repeat
   set the lastScroll of the target to the thumbposition of the target
end mouseDown


on scrollbarDrag x
   local newColor
   put the short name of the target into tName
   put x - the lastScroll of the target into dx
   set the lastScroll of the target to x
   if the optionKey is "down" or the colorMethod of group "color method" is "identical" then put x,x,x into newColor
   else
      repeat for each item C in "red,green,blue"
         if newColor is not empty then put "," after newColor
         if C is tName then put round(x) after newColor
         else if the shiftKey is down or the colorMethod of group "color method" is "synchronous" then
            put max(min(round((the thumbposition of scrollbar C) + dx),255),0) after newColor
         else if the colorMethod of group "color method" is "proportional" then
            put round(x * (the startScroll of scrollbar C) / (the startScroll of scrollbar tName)) after newColor
         else put round(the thumbposition of scrollbar C) after newColor
      end repeat
   end if
   setColors newColor
end scrollbarDrag

function scrollbarColor
   return trunc(the thumbPosition of scrollbar "red"),trunc(the thumbPosition of scrollbar "green"),trunc(the thumbPosition of scrollbar "blue")
end scrollbarColor

on setColors pColor
   if pColor is empty then put scrollbarColor() into pColor
   else if pColor is true then put empty into pColor
   else setScrollbars pColor
   repeat for each word tColor in "foreground background hilite border top bottom shadow focus"
      if not the hilite of btn tColor of group "colorChoice" then next repeat
      put tColor & "color" into tColorName
      repeat for each line tID in sIDList
         set the tColorName of tID to pColor
      end repeat
   end repeat
end setColors
