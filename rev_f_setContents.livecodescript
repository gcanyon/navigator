script "rev_f_setContents"
on rawKeyUp tkey
  checkMyScroll
  pass rawKeyUp tkey
end rawKeyUp

on checkMyScroll
  set the hScrollbar of me to (the formattedWidth of me > the width of me + 10)
  set the vScrollbar of me to (the formattedHeight of me > the height of me + 10)
end checkMyScroll

on enterInField
  send "mouseUp" to btn "EditContentsOK"
end enterInField

on returnInField
   if the oneLiner of grp "editContents" or the optionkey is "down" then send "mouseUp" to btn "EditContentsOK" else pass returnInField
end returnInField
