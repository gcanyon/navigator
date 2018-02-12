script "rev_g_commandGroup"
on setSize
   put the highlight of btn "help" of group "commandControls" of me and the height of this stack > 300 into H
   put the height of this stack - iff(H,217,43) into T
   if H then set the rect of fld "commandHelp" to 0,T+30,the width of this stack,the height of this stack - 13
   set the vis of fld "commandHelp" to H
   set the rect of grp "commandControls" to 0,T,the width of this stack,T + 30
   set the rect of fld "command" to 0,13,the width of this stack,T+2
   send "checkMyScroll" to fld "command"
end setSize

on showMe pForce
   put the hilitedLines of fld "list" into tList
   if not pForce then
      if tList is empty then exit showMe
      else set the pWorkingLines of group "commandGroup" to getID()
   end if
   setSize
   disableList
   show me with visual effect scroll down very fast
   select text of fld "command"
end showMe

on hideMe
  hide me with visual effect reveal up very fast
  enableList
end hideMe
