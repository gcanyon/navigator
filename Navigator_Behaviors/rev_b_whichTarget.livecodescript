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
   if ticks() - popTicks > 30 then dispatch "popMe" to button "whichStack" -- popup button "whichStack"
end mouseStillDown

on setTargetToMouse pMouseData
   if pMouseData["stack"] is empty then exit setTargetToMouse
   setNavigatorTarget ,("stack" && Q(pMouseData["stack"]))
   put lineListFromIDs(pMouseData["control"]) into tLine
   --if tLine is a number then hiliteLines tLine
   dispatch "setHilites" to fld "list" of this stack with tLine
   updatePalettesWithID ,,pMouseData["control"]
end setTargetToMouse
