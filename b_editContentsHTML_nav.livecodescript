script "b_editContentsHTML_nav"
on mouseUp
  if the hilite of me then
    switchToHTML
  else
    switchToText
  end if
end mouseUp
