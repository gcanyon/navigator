script "rev_b_whichCard"
global gSBWhichStack,gSBWhichCard,gSBCardOrBackground,gSBWhichBackground
global gSBShowList
local tMustUpdate
on mouseDown
   put the short name of this stack into thisStack
   put the pMenuLimit of this stack into tMenuLimit
   put iff(the optionKey is "down","background","card") into oType
   put iff(oType is "card","this card" & cr & "Card List","Background List") & cr into tDefault
   put gSBCardOrBackground[thisStack] is not oType into tMustUpdate
   put oType into gSBCardOrBackground[thisStack]
   
   put iff(gSBWhichStack[thisStack] is "the topStack",the short name of the topStack,gSBWhichStack[thisStack]) into sName
   
   if oType is "card" then put the cardnames of stack sName into tList
   else put backgroundsOf((the long id of stack sName),"base","name","short") into tList
   
   if the shiftKey is "down" then sort lines of tList
   put (tDefault & "-" & cr) before tList
   if the number of lines of tList > tMenuLimit then put line 1 to tMenuLimit of tList into tList
   replace "/" with "//" in tList
   put tList into me
end mouseDown

on menuPick pWhich
   put the short name of this stack into thisStack
   if gSBCardOrBackground[thisStack] is "background" then
      --set the autoUpdateList of this stack to false
      put (the menuHistory of me is 1) into gSBShowList[thisStack]
      if tMustUpdate or pWhich is not gSBWhichBackground[thisStack] then
         put pWhich into gSBWhichBackground[thisStack]
         if pWhich is empty then
            put "card" into gSBCardOrBackground[thisStack]
            put "this card" into gSBWhichCard[thisStack]
         end if
         updateDisplay true
      end if
   else if the commandKey is "down" and (the menuHistory of me > 2) then
      if gSBWhichStack[thisStack] is "the topStack" then
         put the short name of the topStack into tStack
         go cd pWhich of stack tStack
      else
         go cd pWhich of stack gSBWhichStack[thisStack]
      end if
   else
      put (the menuHistory of me is 2) into gSBShowList[thisStack]
      if tMustUpdate or pWhich is not gSBWhichCard[thisStack] then
         if pWhich is empty then
            put "this card" into gSBWhichCard[thisStack]
         else
            put pWhich into gSBWhichCard[thisStack]
         end if
         --set the autoUpdateList of this stack to gSBWhichStack[thisStack] is "the topstack" and gSBWhichCard[thisStack] is "this card"
         updateDisplay true
      end if
   end if
   put false into tMustUpdate
end menuPick
