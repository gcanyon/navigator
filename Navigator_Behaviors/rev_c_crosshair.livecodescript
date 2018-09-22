script "rev_c_crosshair"
local sTracking,sGetType,sCallbackID,sCallbackMessage

on mouseUp
   send "wrapUp" to me in 6 ticks
   cleanUp
end mouseUp

on wrapUp
   if sGetType is "color" then put the mouseColor into V
   else if sGetType is "stack" then put the mouseStack into V
   else if sGetType is "control" then put the long id of the mouseControl into V
   dispatch sCallbackMessage to sCallbackID with V
end wrapUp

on cleanUp
   put false into sTracking
   unlock cursor
   set the vis of stack "revNavigatorCrosshair" to false
   close stack "revNavigatorCrosshair"
end cleanUp


on getMouse getType,callbackID,callbackMessage
   put true into sTracking
   put getType into sGetType
   put callbackID into sCallbackID
   put callbackMessage into sCallbackMessage
   palette this stack
   set the vis of this stack to true
   set the cursor to empty
   lock cursor
   trackPointer
end getMouse

on trackPointer
   if not sTracking then exit trackPointer
   if the shiftkey is "down" then cleanUp
   put the screenmouseLoc into XY
   add -1 to item 1 of XY
   add -1 to item 2 of XY
   set the loc of this stack to the screenmouseLoc
   send "trackPointer" to me in 3 ticks
end trackPointer
