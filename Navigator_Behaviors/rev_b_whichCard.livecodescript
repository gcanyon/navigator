script "rev_b_whichCard"
local nonTargetCount,tList,SBG

on mouseDown
   put the short name of this stack into thisStack
   put the showBackgrounds of me is true into SBG
   put "this card" & cr & "-" & cr & iff(SBG,"","!c") & "Card List" & cr & iff(SBG,"!c","") & "Background List" & cr & "-" into tDefault
   put the number of lines of tDefault into nonTargetCount
   put navTargetStack() into SN
   debug SN
   if SN is not empty then
      if SBG then put backgroundsOf((the long id of stack SN),"base","name and id","short") into tList
      else put cardsOf(the long id of stack SN) into tList
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
   put the short name of this stack into N
   
   put navTargetStack() into stackID
   put the menuHistory of me into MH
   if MH = 1 then 
      setNavigatorTarget ,"the topstack"
   else if MH is among the items of "3,4" then 
      set the showBackgrounds of me to (MH is 4)
      if stackID is not empty then 
         setNavigatorTarget ,(pWhich && "of" && stackID)
      end if
      
   else if MH <= nonTargetCount then 
      setRecentNavigatorTarget pWhich
   else if stackID is not empty then
      set the itemDel to tab
      put item 2 of line MH - nonTargetCount of tList into itemID
      put iff(SBG,"group","card") && "id" && itemID && "of" && stackID into itemLongID
      setNavigatorTarget ,itemLongID
   end if
end menuPick
