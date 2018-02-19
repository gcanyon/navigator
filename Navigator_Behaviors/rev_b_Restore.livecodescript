script "rev_b_Restore"
on mouseUp
   get restoreFromBehaviors(fld "id List Restore",\
   the highlight of button "Restore behaviors to multiple objects, duplicating the scripts",\
   the highlight of button "Restore behaviors to scripted objects, appending the scripts",\
   the highlight of button "Restore from all chain behaviors")
   if it is not "cancel" then showLog it
end mouseUp
