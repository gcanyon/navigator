script "rev_g_navresizer"
local sResizing -- boolean that indicates whether we are resizing or not
local sLoc -- the starting loc of the mouse

on mouseDown
  put true into sResizing
  put the mouseLoc into sLoc
  send "cleanUp" to fld "list"
end mouseDown

on mouseUp
  put false into sResizing
end mouseUp

on mouseRelease
  put false into sResizing
end mouseRelease

on mouseMove x,y
  if not sResizing then exit mouseMove
  put the rect of this stack into S
  split S by comma
  put max(the minWidth of this stack,min(the maxWidth of this stack,x - item 1 of sLoc + S[3]-S[1])) + S[1] into S[3]
  put max(the minHeight of this stack,min(the maxHeight of this stack,y - item 2 of sLoc + S[4]-S[2])) + S[2] into S[4]
  put x,y into sLoc
  setNavRect S[1],S[2],S[3],S[4]
end mouseMove
