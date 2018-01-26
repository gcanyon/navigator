script "revNavigator_button_editContentsHTML_behavior_2442_Behavior"
on mouseUp
  if the hilite of me then
    switchToHTML
  else
    switchToText
  end if
end mouseUp
