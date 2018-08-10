script "rev_b_AutoUpdateSelection"
on mouseUp
   if the hilite of me then
      set the hilite of button "autoupdatelist" to true
      disable button "autoupdatelist"
   else
      enable button "autoupdatelist"
   end if
end mouseUp
