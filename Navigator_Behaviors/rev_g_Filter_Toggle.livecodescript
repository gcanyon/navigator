script "rev_g_Filter_Toggle"
on mouseUp
   set the byTest of me to not the byTest of me
   set the loc of grc "indicator" of me to (item 1 of the loc of me),(item 2 of the loc of me + iff(the byTest of me,3,-3))
   put the htmlText of fld "filter" into htmlTextTemp
   put the backgroundcolor of fld "filter" into bgcolorBack
   set the htmlText of fld "filter" to "<p><b><font color=" & quote & iff(the byTest of me,"#007700","#0000CC") & quote & ">" & iff(the byTest of me,"FILTER BY TEST","TEXT MATCH") & "</font></b></p>"
   set the backgroundcolor of fld "filter" to 220,220,220
   set the opaque of fld "filter" to true
   if the byTest of me 
   then set the toolTip of fld "filter" to "Filter controls by test" & cr & "tID will be replaced by the control's long ID" & cr & "e.g." && Q("the vis of tID is true") && "will show only visible controls"
   else set the toolTip of fld "filter" to "Match text to filter controls" & cr & "Text can match any part of the displayed string"
   wait 50 ticks
   set the htmlText of fld "filter" to htmlTextTemp
   set the opaque of fld "filter" to false
   set the backgroundcolor of fld "filter" to bgcolorBack
end mouseUp
