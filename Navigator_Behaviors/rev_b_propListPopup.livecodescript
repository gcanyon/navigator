script "rev_b_propListPopup"
local valueMenu -- displaying plain values to set
local propertyName
local customPropertySetName
local idList
local customPropertyB

on menuPick pWhich
   -- put valueMenu,propertyName,idList,customPropertyB,customPropertySetName 
   if valueMenu then
      dispatch "setValue" to fld "editProps" with pWhich 
   else
      put line (the menuHistory of me) of idList into tID
      if customPropertyB is true then set the custompropertySet of tID to customPropertySetName
      dispatch "setValue" to fld "editProps" with the propertyName of tID 
   end if
end menuPick

on doSetup pvalueMenu,ppropertyName,pidList,pcustomPropertyB,pcustomPropertySetName
   put pvalueMenu into valueMenu
   put ppropertyName into propertyName
   put pidList into idList
   put pcustomPropertyB into customPropertyB
   put pcustomPropertySetName into customPropertySetName
end doSetup
