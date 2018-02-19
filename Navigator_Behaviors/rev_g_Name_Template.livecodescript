script "rev_g_Name_Template"
on evaluateName
   try
      put sosName(fld "SoS Name Template",the long id of fld "SoS Name Template",fld "space replacement") into fld "SoS Name Example"
      set the textColor of fld "SoS Name Example" to black
   catch someErr
      put "Error:" && someErr into fld "SoS Name Example"
      set the textColor of fld "SoS Name Example" to red
   end try
end evaluateName
