script "rev_b_Convert"
on mouseUp
   try
      get sosName(fld "SoS Name Template",the long id of fld "SoS Name Template",fld "space replacement")
   catch someErr
      answer warning "You need to enter a valid script-only stack name template first." with "OK"
      exit mouseUp
   end try
   if not there is a folder (fld "behavior folder") then
      answer warning "You need to select a folder to contain script-only stack files first." with "OK"
      exit mouseUp
   end if
   get convertToScriptOnlyStackBehaviors(fld "id List Convert",fld "behavior folder",fld "SoS name template",\
   the highlight of button "Convert unscripted objects to script-only stack behaviors",\
   the highlight of button "Create script-only stack behaviors for existing script-only stacks",\
   field "space replacement")
   if it is not "cancel" then showLog it
end mouseUp
