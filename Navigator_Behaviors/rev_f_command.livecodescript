script "rev_f_command"
on rawKeyUp
  checkMyScroll
  pass rawKeyUp
end rawKeyUp

on checkMyScroll
  set the hScrollbar of me to (the formattedWidth of me > the width of me + 10)
  set the vScrollbar of me to (the formattedHeight of me > the height of me + 10)
end checkMyScroll
