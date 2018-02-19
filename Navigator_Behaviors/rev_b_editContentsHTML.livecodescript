script "rev_b_editContentsHTML"
on mouseUp
  if the hilite of me then
    switchToHTML
  else
    switchToText
  end if
end mouseUp
