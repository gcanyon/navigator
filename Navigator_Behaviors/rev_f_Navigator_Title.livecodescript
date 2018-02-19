script "rev_f_Navigator_Title"
local sMoving -- boolean that indicates whether we are resizing or not
local sShowMessage -- the id of the message that will show Navigator
--local moveLog
local xOff -- the starting mouseX
local yOff -- the starting mouseY
local lastXDelta
local lastYDelta

on mouseDown
   put true into sMoving
   put item 1 of the mouseLoc into xOff
   put item 2 of the mouseLoc into yOff
  -- put sLoc & cr into moveLog
   put 0 into lastXDelta
   put 0 into lastYDelta
end mouseDown

on mouseUp
   put false into sMoving
 --  put moveLog
end mouseUp

on mouseRelease
   put false into sMoving
end mouseRelease

on mouseMove x,y
   if sMoving then
      put x - xOff into newXDelta
      put y - yOff into newYDelta
      --put newXDelta * lastXDelta && newYDelta * lastYDelta
      if newXDelta * lastXDelta > -1 and newYDelta * lastYDelta > -1 then
         put the loc of this stack into tLoc
         -- put x,y && tLoc after moveLog
         add newXDelta to item 1 of tLoc
         add newYDelta to item 2 of tLoc
         -- put " " & tLoc & cr after moveLog
         set the loc of this stack to tLoc
      end if
      put newXDelta into lastXDelta 
      put newYDelta into lastYDelta 
   end if
end mouseMove

on mouseDoubleUp
   if the shiftKey is "down" then 
      setVisNavigator true
      setNavWidths (the left of this stack),(the right of this stack)
      exit mouseDoubleUp
   end if
   setVisNavigator ,(the commandKey is "down")
end mouseDoubleUp
