script "rev_c_DragTargets"
local controlCount -- the number of controls displayed

on mimicContainer pID
   repeat for each line cID in the childControlIDs of pID
      put "control id" && cID && "of" && pID & cr after idList
   end repeat
   put the rect of pID into pRect
   put the topLeft of stack (word -2 to -1 of the long id of pID) into TL
   add item 1 of TL to item 1 of pRect;add item 1 of TL to item 3 of pRect
   add item 2 of TL to item 2 of pRect;add item 2 of TL to item 4 of pRect
   mimicIDList idList,pRect
end mimicContainer

on mimicIDList idList,pRect
  -- put pRect & cr & cr & idList
   lock screen
   put the number of lines of idList into controlCount
   forceNControls (the long id of me),controlCount
   put 0 into i
   repeat for each line cID in idList
      add 1 to i
      set the rect of control i of me to the rect of cID
      set the targetID of control i of me to cID
   end repeat
   set the rect of the owner of me to pRect
   set the vis of the owner of me to true
   go me
   unlock screen
end mimicIDList

on doSetupA rectA,pRect
   lock screen
   put item 2 of the extents of rectA into controlCount
   if controlCount is empty then put 0 into controlCount
   forceNControls (the long id of me),controlCount
   repeat with i = 1 to controlCount
      set the rect of control i of me to rectA[i]
      put rectA[i] & cr after rectList
   end repeat
  -- put pRect & cr & cr & rectList
   set the rect of the owner of me to pRect
   set the vis of the owner of me to true
   go me
   unlock screen
end doSetupA


on doSetup C,rectList,pRect
   --put C & cr & pRect & cr & rectList
   lock screen
   forceNControls (the long id of me),C
   put 0 into i
   repeat for each line R in rectList
      add 1 to i
      set the rect of control i of me to R
   end repeat
   set the rect of the owner of me to pRect
   set the vis of the owner of me to true
   go me
   unlock screen
end doSetup

on cleanUp
   hide the owner of me
end cleanUp

on flashControl i
   if not there is a control i of me then exit flashControl
   go me
   set the layer of control i of me to controlCount 
   repeat with x = 1 to 2
      set the backcolor of control controlCount of me to 0,0,0
      wait 3 ticks
      set the backcolor of control controlCount of me to 255,255,255
      if x < 2 then wait 5 ticks
   end repeat
   set the layer of control controlCount of me to i
end flashControl
