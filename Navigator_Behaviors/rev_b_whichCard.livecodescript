script "rev_b_whichCard"
global gSBWhichStack,gSBWhichCard,gSBCardOrBackground,gSBWhichBackground
global gSBShowList

on mouseDown 
   put the short name of this stack into thisStack
   put the showBackgrounds of me is true into SBG
   put "this card" & cr & "-" & cr & iff(SBG,"","!c") & "Card List" & cr & iff(SBG,"!c","") & "Background List" & cr & "-" & cr into tDefault 
   if SBG 
   then put backgroundsOf((the long id of stack getStackName()),"base","name","short") into tList
   else put the cardnames of stack getStackName() into tList
   if the shiftKey is "down" then sort lines of tList
   replace "/" with "//" in tList
   put tDefault & line 1 to (the pMenuLimit of this stack) - 5 of tList into me
end mouseDown

on menuPick pWhich
   put the short name of this stack into thisStack
   put pWhich into gSBWhichCard[thisStack]
   put the menuHistory of me into MH
   if MH is among the items of "3,4" then set the showBackgrounds of me to (MH is 4)
   put the showBackgrounds of me is true into SBG
   put iff(SBG and MH <> 1,"background","card") into gSBCardOrBackground[thisStack]
   put (MH is among the items of "3,4") into gSBShowList[thisStack]
   if the commandKey is "down" and MH > 5 and not SBG 
   then go cd pWhich of stack getStackName() 
   else updateDisplay true
end menuPick
