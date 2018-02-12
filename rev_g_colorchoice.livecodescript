script "rev_g_colorchoice"
on mouseUp
  put the hilite of the target into tHilite
  if the optionKey is "down" then
    lock messages
    repeat for each word tColor in "foreground background hilite border top bottom shadow focus"
      set the hilite of btn tColor of me to tHilite
    end repeat
  end if
  if tHilite is false then exit mouseUp
  put (the short name of the target) & "color" into tColor
  changeSettings(tColor)
end mouseUp
