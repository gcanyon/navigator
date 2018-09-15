script "rev_i_mouseColor"
on mouseUp
   if the optionKey is not "down"
   then answer "Please hold down the Option/Alt key and click OK." & cr & "Then place the pointer over the color you want and release the Option/Alt key." with "OK"
   if the optionKey is not "down" then break
   set the cursor to hand
   set the lockCursor to true
   waitForKeys ,,"up",,"setColorToMouseColor",(the long id of me)
end mouseUp

on setColorToMouseColor
   set the lockCursor to false
   setColors (the mouseColor)
end setColorToMouseColor
