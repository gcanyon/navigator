script "rev_b_whichCard"
local nonTargetCount,tList,SBG,stackName

on mouseDown
   put the short name of this stack into thisStack
   put the showBackgrounds of me is true into SBG
   put "this card" & cr & "-" & cr & iff(SBG,"","!c") & "Card List" & cr & iff(SBG,"!c","") & "Background List" & cr & "-" into tDefault
   put the number of lines of tDefault into nonTargetCount
   put navTargetStack(-1) into stackName
   --debug stackName
   if stackName is not empty then
      if SBG then put backgroundsOf((the long id of stackName),"base","name and id","short") into tList
      else put cardsOf(the long id of stackName) into tList
      set the itemDel to tab
      if the shiftKey is "down" then sort lines of tList by item 1 of each
      repeat for each line L in tList
         put item 1 of L & cr after tNameList
      end repeat
      delete char -1 of tNameList
      replace "/" with "//" in tNameList
      put cr & line 1 to (the pMenuLimit of this stack) - nonTargetCount of tNameList after tDefault
   end if
   put tDefault into me
end mouseDown

on menuPick pWhich
   put the menuHistory of me into MH
   if MH = 1 then 
      setNavigatorTarget ,"the topstack",(the shiftkey is "down")
   else if MH is among the items of "3,4" then 
      set the showBackgrounds of me to (MH is 4)
      if stackName is not empty then 
         setNavigatorTarget ,(pWhich && "of" && stackName),(the shiftkey is "down")
      end if
      
   else if MH <= nonTargetCount then 
      setRecentNavigatorTarget pWhich
   else if stackName is not empty then
      set the itemDel to tab
      put item 2 of line MH - nonTargetCount of tList into itemID
      put iff(SBG,"group","card") && "id" && itemID && "of" && stackName into itemLongID
      setNavigatorTarget ,itemLongID,(the shiftkey is "down")
   end if
end menuPick
