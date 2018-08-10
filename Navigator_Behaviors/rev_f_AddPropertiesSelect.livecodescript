script "rev_f_AddPropertiesSelect"
local lastSelection

on selectionChanged
   if lastSelection is not empty then updateAddProperties lastSelection,(the text of fld "AddPropertiesEntry")
   put the hilitedText of me into K
   put the K of me into fld "AddPropertiesEntry"
   put K into lastSelection
end selectionChanged

on clearLastSelection
   put empty into lastSelection
end clearLastSelection
