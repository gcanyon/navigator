script "rev_g_barGroup"
on mouseUp
   put the textHeight of fld "list" into myTH
   put round((the mouseV + the scroll of fld "list" - the top of fld "list") / myTH + .55) into tClickLine
   put the hilitedLines of fld "list" into tHiliteList
   if tClickLine is among the items of tHiliteList then put tClickLine
   else set the hilitedLines of fld "list" to tClickLine
end mouseUp


function barClickLine
   return round((the mouseV + the scroll of fld "list" - the top of fld "list") / the textHeight of fld "list" + .35)
end barClickLine
