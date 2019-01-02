script "rev_b_whichTarget"
local popTicks

on mouseDown
   put ticks() into popTicks
end mouseDown

on mouseUp
   if ticks() - popTicks < 10 then getMouse the long id of me,"setTargetToMouse"
   else dispatch "popMe" to button "whichStack"
end mouseUp

on mouseStillDown
   if ticks() - popTicks < 31 then exit mouseStillDown
   dispatch "popMe" to button "whichStack" -- popup button "whichStack"
   put ticks() + 999999 into popTicks
end mouseStillDown

on setTargetToMouse pMouseData
   if pMouseData["stack"] is empty then exit setTargetToMouse
   setNavigatorTarget ,("card id" && (the id of this cd of stack pMouseData["stack"]) && "of stack" && Q(pMouseData["stack"])),(the shiftkey is "down")
   put lineListFromIDs(pMouseData["control"]) into tLine
   --if tLine is a number then hiliteLines tLine
   dispatch "setHilites" to fld "list" of this stack with tLine
   updatePalettesWithID ,,pMouseData["control"]
end setTargetToMouse
