script "rev_g_setColors"
local sIDList -- list of ids of objects to set
local sClickedID -- id of the object that was clicked to display

on setup pID
editColors pID,getID()
end setup

on editColors pID,pIDList
  if char 1 of pClickedID is quote then put char 2 to -2 of pClickedID into pClickedID
  put pIDList into sIDList
  if pID is empty then
    put line 1 of sIDList into sClickedID
  else
    put char 2 to -2 of pID into sClickedID
  end if
  clearColorCheckboxes
  showMe
end editColors

on clearColorCheckboxes
  repeat for each word tColor in "foreground background hilite border top bottom shadow focus"
    set the hilite of button tColor to false
  end repeat
end clearColorCheckboxes

on changeSettings pColorName

  put the effective pColorName of sClickedID into tColor
  lock messages
  repeat with i = 1 to 3
    set the thumbPosition of scrollbar (item i of "red,green,blue") to 255 - (item i of tColor)
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


on scrollbarDrag x
  --put "sbd" && ticks()
  put the short name of the target into tName
  if the optionKey is "down" then
    lock messages
    repeat for each item I in "red,green,blue"
      if I is tName then next repeat
      set the thumbposition of scrollbar I to x
    end repeat
  else if the shiftKey is down then
    put x - the lastScroll of the target into dx
    lock messages
    repeat for each item I in "red,green,blue"
      if I is tName then next repeat
      set the thumbPosition of scrollbar I to max(min(((the thumbposition of scrollbar I) + dx),255),0)
    end repeat
  end if
  set the lastScroll of the target to x
  setColors
end scrollbarDrag

on setColors pClear
  if pClear then
    put empty into tColorValue
  else
    put trunc(255 - the thumbPosition of scrollbar "red"),trunc(255 - the thumbPosition of scrollbar "green"),trunc(255 - the thumbPosition of scrollbar "blue") into tColorValue
  end if
  repeat for each word tColor in "foreground background hilite border top bottom shadow focus"
    if not the hilite of btn tColor of group "colorChoice" then next repeat
    put tColor & "color" into tColorName
    
    repeat for each line tID in sIDList
      set the tColorName of tID to tColorValue
    end repeat
  end repeat
end setColors
