script "rev_b_Tab_Menu"
on menuPick pWhich
   lock screen
   hide grp "Convert"
   hide grp "Restore"
   hide grp "Log"
   show grp pWhich
   unlock screen
end menuPick
