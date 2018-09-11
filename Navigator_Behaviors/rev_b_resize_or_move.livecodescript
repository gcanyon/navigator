script "rev_b_resize_or_move"
local sLoc

on mouseUp
   --if the short name of me is "drag" then exit mouseUp
   put the uClickParam of me into AP
   if the shiftkey is "down" then put multiplyList(10,AP) into AP
   dispatch "modifySIDrect" to group "resizer" with AP
end mouseUp

on mouseDown
   put the mouseLoc into sLoc
end mouseDown

on mouseStillDown
   put the uDragParam of me into MP
   --    put the uAdjustParam of me into MP
   --    put abs(item 1 of MP) into item 1 of MP
   --    put abs(item 2 of MP) into item 2 of MP
   if the shiftkey is "down" then put multiplyList(10,MP) into MP 
   put multiplyList(subtractList(sLoc,the mouseLoc),MP) into MP
   
   dispatch "modifySIDrect" to group "resizer" with MP
   --put MP
   put the mouseLoc into sLoc
end mouseStillDown
