script "rev_g_navresizer"
local resizingMessage -- message if we are resizing
local sLoc -- the starting loc of the mouse

on mouseDown
   put the mouseLoc into sLoc
   dispatch "cleanUp" to fld "list"
   resizeMe
end mouseDown

on mouseUp
   cancel resizingMessage
end mouseUp

on mouseRelease
   cancel resizingMessage
end mouseRelease

on resizeMe
   put the mouseLoc into mLoc
   put item 1 of mLoc into x
   put item 2 of mLoc into y
   put the rect of this stack into S
   split S by comma
   put max(the minWidth of this stack,min(the maxWidth of this stack,x - item 1 of sLoc + S[3]-S[1])) + S[1] into S[3]
   put max(the minHeight of this stack,min(the maxHeight of this stack,y - item 2 of sLoc + S[4]-S[2])) + S[2] into S[4]
   put x,y into sLoc
   setNavRect S[1],S[2],S[3],S[4]
   send "resizeMe" to me in 6 ticks
   put the result into resizingMessage
end resizeMe

