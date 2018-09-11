script "rev_f_Navigator_Title"
local draggingMessage -- message if we are dragging
local sLoc -- the starting loc of the mouse

on mouseDown
   put the mouseLoc into sLoc
   dragMe
end mouseDown

on mouseUp
   cancel draggingMessage
end mouseUp

on mouseRelease
   cancel draggingMessage
end mouseRelease

on dragMe
   set the loc of this stack to addList(the loc of this stack,subtractList(sLoc,the mouseLoc))
   send "dragMe" to me in 6 ticks
   put the result into draggingMessage
end dragMe

on mouseDoubleUp
   if the shiftKey is "down" then 
      setVisNavigator true
      setNavWidths (the left of this stack),(the right of this stack)
      exit mouseDoubleUp
   end if
   setVisNavigator ,(the commandKey is "down")
end mouseDoubleUp
