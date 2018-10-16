script "rev_g_commandBars"
on mouseUp pButton
   if pButton = 3 then dispatch "doPopup" to button "popCommands" with the short name of the target
   else
      put (the clickAction of the target) into tCommand
      put barClickLine() into tClickLine
      put the hilitedLines of fld "list" into tHiliteList
      if tClickLine is not among the items of tHiliteList then 
         hiliteLines tClickLine
         put tClickLine into tHiliteList
      end if
      try
         if tCommand is among the items of "Edit Script,Edit Scripts,Edit Behavior Script,Edit Behavior Scripts,Single Object Inspector,Individual Object Inspectors,Individual Object Inspector,Bookmark-Remove"
         then doCommandCode tCommand,tHiliteList
         else
            put getID(tHiliteList) into tIDList
            if tCommand is "Property Editor" then
               put getIDFirst(tClickLine) into leadID
               set wholeMatches to true
               put lineOffset(leadID,tIDList) into tLeadLine
               if tLeadLine > 0 then
                  delete line tLeadLine of tIDList
                  put leadID & cr before tIDList
               end if
            end if
            if not (tCommand is among the items of "Property Editor,Color Editor,Command,Copy ID,Size/Location Editor") then put commandRead(tCommand) into tCommand
            doCommandCode tCommand,tIDList
         end if
      catch someErr
      end try
   end if
end mouseUp
