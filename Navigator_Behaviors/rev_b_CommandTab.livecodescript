script "rev_b_CommandTab"
on menuPick pWhich
   put pWhich is "command" into C
   set the vis of button "Do" of group "commandControls" to C
   set the vis of button "Save" of group "commandControls" to C
   set the vis of button "Set" of group "commandControls" to not C
end menuPick
