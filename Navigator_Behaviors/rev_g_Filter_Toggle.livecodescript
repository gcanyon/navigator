script "rev_g_Filter_Toggle"
on mouseUp
   set the byTest of me to not the byTest of me
   set the loc of grc "indicator" of me to (item 1 of the loc of me),(item 2 of the loc of me + iff(the byTest of me,3,-3))
   put the htmlText of fld "filter" into htmlTextTemp
   put the backgroundcolor of fld "filter" into bgcolorBack
   set the htmlText of fld "filter" to "<p><b><font color=" & quote & iff(the byTest of me,"#007700","#0000CC") & quote & ">" & iff(the byTest of me,"FILTER BY TEST","TEXT MATCH") & "</font></b></p>"
   set the backgroundcolor of fld "filter" to 220,220,220
   set the opaque of fld "filter" to true
   wait 50 ticks
   set the htmlText of fld "filter" to htmlTextTemp
   set the opaque of fld "filter" to false
   set the backgroundcolor of fld "filter" to bgcolorBack
end mouseUp
