script "rev_b_whichCard"
global gSBWhichStack,gSBWhichCard,gSBCardOrBackground,gSBWhichBackground
global gSBShowList

local nonTargetCount,tList,SBG

on mouseDown 
   put the short name of this stack into thisStack
   put the showBackgrounds of me is true into SBG
   put "this card" & cr & "-" & cr & iff(SBG,"","!c") & "Card List" & cr & iff(SBG,"!c","") & "Background List" & cr & "-" & cr & recentTargets() into tDefault 
   if char -1 of tDefault is not cr then put cr & "-" & cr after tDefault
   put the number of lines of tDefault into nonTargetCount
   if SBG then 
      put cr & backgroundsOf((the long id of stack getStackName()),"base","name and id","short") into tList
      replace cr & "group" with cr & "background" in tList
      delete char 1 of tList
   else put cardsOf(the long id of stack getStackName()) into tList
   set the itemDel to tab
   if the shiftKey is "down" then sort lines of tList by item 1 of each
   repeat for each line L in tList
      put item 1 of L & cr after tNameList
   end repeat
   delete char -1 of tNameList
   replace "/" with "//" in tList
   put tDefault & line 1 to (the pMenuLimit of this stack) - nonTargetCount of tNameList into me
end mouseDown

on menuPick pWhich
   put the short name of this stack into thisStack
   put the menuHistory of me into MH
   if MH is among the items of "3,4" then set the showBackgrounds of me to (MH is 4)
   if MH <= nonTargetCount then setNavigatorTarget ,pWhich
   else 
      put gSBWhichStack[thisStack] into sStack
      if sStack = "the topStack" then put the short name of the topStack into sStack
      set the itemDel to tab
      put item 2 of line MH - nonTargetCount of tList into itemID
      put iff(SBG,"group","card") && "id" && itemID && "of stack" && Q(sStack) into itemLongID
      --put itemLongID;exit to top
      --put itemLongID; exit to top -- & cr & (the long id of (pWhich && "of stack" && Q(sStack))) into message;exit to top
      setNavigatorTarget ,itemLongID
      --setNavigatorTarget ,(the long id of (pWhich && "of stack" && Q(sStack)))
   end if
   exit menuPick
   
   if true then  
   else if MH = 1 then setNavigatorTarget ,"this card"
   else if MH < nonTargetCount then setNavigatorTarget ,pWhich
   else
      setNavigatorTarget ,(iff(the showBackgrounds of me is true,"background","card") && Q(pWhich) && "of" && iff(gSBWhichStack[thisStack] = "the topstack","the topstack","stack" && Q(gSBWhichStack[thisStack])))
   end if
   
   exit menuPick
   put the short name of this stack into thisStack
   put pWhich into gSBWhichCard[thisStack]
   put the menuHistory of me into MH
   if MH is among the items of "3,4" then set the showBackgrounds of me to (MH is 4)
   put the showBackgrounds of me is true into SBG
   put iff(SBG and MH <> 1,"background","card") into gSBCardOrBackground[thisStack]
   put (MH is among the items of "3,4") into gSBShowList[thisStack]
   if the commandKey is "down" and MH > nonTargetCount and not SBG 
   then go cd pWhich of stack getStackName() 
   else updateDisplay true
end menuPick
