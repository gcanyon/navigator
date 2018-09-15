script "rev_g_setColors"
local sIDList -- list of ids of objects to set
local sClickedID -- id of the object that was clicked to display
local sUndoArray -- a list of the original colors to undo


on setup pID
   editColors pID,getID()
end setup

on editCurrentHighlights
   editColors getClickedID(),theHilitedIDs()
end editCurrentHighlights

on editColors pID,pIDList
   if char 1 of pClickedID is quote then put char 2 to -2 of pClickedID into pClickedID
   put pIDList into sIDList
   delete variable sUndoArray
   repeat for each line tID in sIDList
      repeat for each word tColor in "foregroundcolor backgroundcolor hilitecolor bordercolor topcolor bottomcolor shadowcolor focuscolor"
         put the tColor of tID into sUndoArray[tID][tColor]
      end repeat
   end repeat
   if pID is empty 
   then put line 1 of sIDList into sClickedID
   else put pID into sClickedID
   clearColorCheckboxes
   showMe
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
   --put sClickedID into message
   put the effective pColorName of sClickedID into tColor
   lock messages
   repeat with i = 1 to 3
      set the thumbPosition of scrollbar (item i of "red,green,blue") to (item i of tColor)
   end repeat
end changeSettings

on showMe
  disableList
  show me with visual effect scroll right very fast
end showMe

on hideMe
   hide me with visual effect reveal left very fast
   enableList
end hideMe

on mouseDown
   if not (word 1 of the name of the target is "scrollbar") then exit mouseDown
   repeat for each item C in "red,green,blue"
      set the startScroll of scrollbar C to the thumbposition of scrollbar C
   end repeat
   set the lastScroll of the target to the thumbposition of the target
end mouseDown


on scrollbarDrag x
   put the short name of the target into tName
   put x - the lastScroll of the target into dx
   lock messages
   repeat for each item C in "red,green,blue"
      if C is not tName then
         if the optionKey is "down" or the colorMethod of group "color method" is "identical" then
            set the thumbposition of scrollbar C to x
         else if the shiftKey is down or the colorMethod of group "color method" is "synchronous" then
            set the thumbPosition of scrollbar C to max(min(((the thumbposition of scrollbar C) + dx),255),0)
         else if the colorMethod of group "color method" is "proportional" then
            set the thumbPosition of scrollbar C to round(x * (the startScroll of scrollbar C) / (the startScroll of scrollbar tName))
         else
            --put the colorOption of btn "color options"
         end if
      end if
      put the thumbposition of scrollbar C into fld (C && "number")
   end repeat
   unlock messages
   set the lastScroll of the target to x
   setColors
end scrollbarDrag

on setColors pColor
   lock screen
   if pColor is empty then
      put trunc(the thumbPosition of scrollbar "red"),trunc(the thumbPosition of scrollbar "green"),trunc(the thumbPosition of scrollbar "blue") into pColor
   else if pColor is true then
      put empty into pColor
   else
      repeat with i = 1 to 3
         set the thumbposition of scrollbar (item i of "red,green,blue") to (item i of pColor)
      end repeat
   end if
   if pColor is not empty then set the backgroundcolor of fld "color swatch" to pColor
   repeat for each word tColor in "foreground background hilite border top bottom shadow focus"
      if not the hilite of btn tColor of group "colorChoice" then next repeat
      put tColor & "color" into tColorName
      repeat for each line tID in sIDList
         set the tColorName of tID to pColor
      end repeat
   end repeat
   unlock screen
end setColors
