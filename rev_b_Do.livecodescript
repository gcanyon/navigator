script "rev_b_Do"
on mouseUp
  set the commandCode of me to fld "command"
  doCode
end mouseUp

on doCode
   put the commandCode of me into tCommandCode
   put the commandScript of me into tScript
   replace "--tCommandCode" with tCommandCode in tScript
   set the script of group "commandControls" to tScript
   if the result is empty then doCommand
   else
      answer warning "Script Error -- putting script in the message box." with "OK"
      put tScript
   end if
end doCode
