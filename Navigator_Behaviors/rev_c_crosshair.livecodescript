script "rev_c_crosshair"
local sTracking,sCallbackID,sCallbackMessage

on mouseUp
   send "wrapUp" to me in 6 ticks
   cleanUp
end mouseUp

on wrapUp
   put the mouseStack into R["stack"]
   if R["stack"] is empty then put empty into R["control"]
   else if the mouseControl is empty then put (the name of this card of the mouseStack) && "of" && the mouseStack into R["control"]
   else put the long id of the mouseControl into R["control"]
   put the mouseColor into R["color"]
   --debug R["stack"],sCallbackMessage,sCallbackID
   dispatch sCallbackMessage to sCallbackID with R
end wrapUp

on cleanUp
   put false into sTracking
   unlock cursor
   set the vis of stack "revNavigatorCrosshair" to false
   close stack "revNavigatorCrosshair"
end cleanUp


on getMouse callbackID,callbackMessage
   --put callbackID,callbackMessage into message
   put true into sTracking
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
   if the controlkey is "down" then cleanUp
   set the loc of this stack to the screenmouseLoc
   send "trackPointer" to me in 3 ticks
end trackPointer
