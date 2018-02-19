script "rev_c_DragRepresentation"
local sRectArray -- array by layer of container rects
local sCArray -- array by id of containers, with their sRectArrays within. base key is "windows"
local sTargetID -- the id of the current container
local sTargetCount
local sIDList -- a list of the controls being dragged
local sCallerID
local sObjectCount
local sTargetMessage -- the id of the message to focus in

function findContainer P
   -- takes a point P and finds the deepest container in sRectArrayArchive that contains it
end findContainer


function objectRect tID
   if tID is "screen" then return the working screenrect
   put the rect of stack stackNameFromID(tID) into SR

   if word 1 of tID is "card" then
      subtract 20 from item 2 of SR
      return SR
   end if
   put the rect of tID into R
   add item 1 of SR to item 1 of R;add item 1 of SR to item 3 of R
   add item 2 of SR to item 2 of R;add item 2 of SR to item 4 of R
   return R
end objectRect

on addContainer tID
   --put tID
   get containerInfo(tID)
   if it is "error" then
      answer "error"
      exit to top
   end if
   put it into sCArray[tID]
end addContainer

on targetContainer i,tID
   --put i,tID
  -- if i > 0 and word 1 of tID is not "stack" then dispatch "flashControl" to card "DragTargets" of stack "revDragTarget" with i
   put tID into sTargetID
   if sCArray[sTargetID]["opaque"] is empty then addContainer sTargetID
   --put sCArray[tID]["opaque"] & cr & sCArray[tID]["rect"][1] & cr & sCArray[tID]["rect"][2]
   if word 1 of sTargetID is "stack" then 
      lock messages;go sTargetID;unlock messages
   end if
   dispatch "doSetupA" to card "DragTargets" of stack "revDragTarget" with sCArray[sTargetID]["rect"],sCArray[sTargetID]["opaque"]
end targetContainer


function containerInfo tID
   -- takes an ID and returns an array with five elements:
   -- 1. The rect to opaque "opaque"
   -- 2. The rect to escape "escape"
   -- 3. The rect(s) to highlight "rect"
   -- 4. The global rect(s) from (3) to target with the mouse "gRect"
   -- 5. The matching IDs to focus on from 3 "id"
   
   put 0 into i
   put 22 into windowTitleHeight
   --  For the screen that is:
   -- 1. the screen rect
   -- 2. the screen rect
   -- 3,4,5. the stack rects, the stack rects again, and ids
   if tID is "windows" then
      put the working screenrect into R["opaque"]
      put R["opaque"] into R["escape"]
      repeat for each line stackID in the windows
         if the mode of stack stackID <> 1 then next repeat
         add 1 to i
         put "stack" && Q(stackID) into R["id"][i]
         put the rect of R["id"][i] into R["rect"][i]
         subtract windowTitleHeight from item 2 of R["rect"][i]
         put R["rect"][i] into R["gRect"][i]
         subtract item 2 of R["opaque"] from item 2 of R["rect"][i]
         subtract item 2 of R["opaque"] from item 4 of R["rect"][i]
      end repeat
      return R
   end if
   
   
   -- For a stack with no groups that is:
   -- 1. The screen rect
   -- 2. The stack rect
   -- 3. The stack rect
   
   -- For a stack with groups that is:
   -- 1. The stack rect
   -- 2. The stack rect
   -- 3,4,5. The group rect(s) within 2, global rects and ids
   
   if word 1 of tID is "stack" then
      put the long id of this cd of tID into cID
      put the topLeft of tID into TL
      put the rect of tID into R["escape"]
      subtract windowTitleHeight from item 2 of R["escape"]
      repeat for each line xID in the childcontrolids of cID
         if word 1 of the name of control id xID of cID is not "group" then next repeat
         add 1 to i
         put "group id" && xID && "of" && cID into R["id"][i]
         put the rect of R["id"][i] into R["rect"][i]
         put R["rect"][i] into R["gRect"][i]
         add windowTitleHeight to item 2 of R["rect"][i]; add windowTitleHeight to item 4 of R["rect"][i]
         add item 1 of TL to item 1 of R["gRect"][i]; add item 1 of TL to item 3 of R["gRect"][i]
         add item 2 of TL to item 2 of R["gRect"][i]; add item 2 of TL to item 4 of R["gRect"][i]
      end repeat
      if i = 0 then
         put the working screenrect into R["opaque"] 
         put R["escape"] into R["rect"][1]
         subtract item 2 of R["opaque"]  from item 2 of R["rect"][1]
         subtract item 2 of R["opaque"]  from item 4 of R["rect"][1]
      else
         put R["escape"] into R["opaque"] 
      end if
      return R
   end if
   
   
   -- For a group with no groups that is:
   -- 1. The stack rect
   -- 2. The group rect
   -- 3. The group rect
   
   -- For a group with groups that is:
   
   -- 1. The group rect
   -- 2. The group rect
   -- 3,4. The group rect(s) within and ids
   
   if word 1 of tID is "group" then
      put "stack" && word -1 of tID into SN
      put the rect of SN into SR
      put the rect of tID into R["escape"]
      add item 1 of SR to item 1 of R["escape"]; add item 1 of SR to item 3 of R["escape"]
      add item 2 of SR to item 2 of R["escape"]; add item 2 of SR to item 4 of R["escape"]
      put the topleft of tID into TL
      repeat for each line xID in the childcontrolids of tID
         if word 1 of the name of control id xID of tID is not "group" then next repeat
         add 1 to i
         put "group id" && xID && "of" && tID into R["id"][i]
         put the rect of R["id"][i] into R["rect"][i]
         put R["rect"][i] into R["gRect"][i]
         subtract item 1 of TL from item 1 of R["rect"][i]; subtract item 1 of TL from item 3 of R["rect"][i]
         subtract item 2 of TL from item 2 of R["rect"][i]; subtract item 2 of TL from item 4 of R["rect"][i]
         --add windowTitleHeight - item 2 of TL to item 2 of R["rect"][i]; add windowTitleHeight - item 2 of TL to item 4 of R["rect"][i]
         add item 1 of SR to item 1 of R["gRect"][i]; add item 1 of SR to item 3 of R["gRect"][i]
         add item 2 of SR to item 2 of R["gRect"][i]; add item 2 of SR to item 4 of R["gRect"][i]
      end repeat
      if false and i = 0 then
         put SR into R["opaque"] 
         subtract windowTitleHeight from item 2 of R["opaque"] 
         put the rect of tID into r["rect"][1]
         add windowTitleHeight to item 2 of r["rect"][1]; add windowTitleHeight to item 4 of r["rect"][1]
      else
         put R["escape"] into R["opaque"] 
      end if
      return R
   end if
   return "error"
end containerInfo



on addContainer cID
   -- takes "windows" or a container long id and calculates the sRectArray for it, storing the result in sRectArrayArchive
   put 0 into i
   if cID is "windows" then
      put the working screenrect into sCArray[cID]["cRect"]
      repeat for each line stackID in the windows
         if the mode of stack stackID <> 1 then next repeat
         add 1 to i
         put "stack" && Q(stackID) into SN
         put the long id of this cd of SN into sCArray["windows"]["id"][i]
         put the rect of SN into sCArray["windows"]["rect"][i]
         if item 2 of sCArray[cID]["cRect"] > 0 then
            subtract item 2 of sCArray[cID]["cRect"] from item 2 of sCArray["windows"]["rect"][i]
            subtract item 2 of sCArray[cID]["cRect"] from item 4 of sCArray["windows"]["rect"][i]
         end if
         put sCArray["windows"]["rect"][i] & cr after sCArray[cID]["rectList"]
         put SN & cr after sCArray["windows"]["list"]
      end repeat
   else if word 1 of cID is "stack" then
      put the left of cID into xOff
      put the top of cID into yOff
      repeat for each line tID in the childcontrolids of cID
         if word 1 of the name of control id tID of cID is not "group" then next repeat
         add 1 to i
         put "group id" && tID && "of" && cID into sCArray[cID]["id"][i]
         put the rect of sCArray[cID]["id"][i] into sCArray[cID]["rect"][i]
         put sCArray[cID]["id"][i] & cr after sCArray[cID]["list"]
         put sCArray[cID]["rect"][i] & cr after sCArray[cID]["rectList"]
         add xOff to item 1 of sCArray[cID]["rect"][i]; add xOff to item 3 of sCArray[cID]["rect"][i]
         add yOff to item 2 of sCArray[cID]["rect"][i]; add yOff to item 4 of sCArray[cID]["rect"][i]
      end repeat
      if i = 0 then
         put the working screenrect into sCArray[cID]["cRect"]
         put the rect of cID into sCArray[cID]["rectList"]
         add xOff to item 1 of sCArray[cID]["rectList"]; add xOff to item 3 of sCArray[cID]["rectList"]
         add yOff to item 2 of sCArray[cID]["rectList"]; add yOff to item 4 of sCArray[cID]["rectList"]
         --add yOff - item 2 of sCArray[cID]["cRect"] to item 2 of sCArray[cID]["rectList"]; add yOff - item 2 of sCArray[cID]["cRect"] to item 4 of sCArray[cID]["rectList"]
      else
         put the rect of cID into sCArray[cID]["cRect"]
         add xOff to item 1 of sCArray[cID]["cRect"]; add xOff to item 3 of sCArray[cID]["cRect"]
         add yOff to item 2 of sCArray[cID]["cRect"]; add yOff to item 4 of sCArray[cID]["cRect"]
      end if
   else
      put word -2 to -1 of cID into SN
      put the left of SN into xOff
      put the top of SN into yOff
      repeat for each line tID in the childcontrolids of cID
         if word 1 of the name of control id tID of cID is not "group" then next repeat
         add 1 to i
         put "group id" && tID && "of" && cID into sCArray[cID]["id"][i]
         put the rect of sCArray[cID]["id"][i] into sCArray[cID]["rect"][i]
         put sCArray[cID]["id"][i] & cr after sCArray[cID]["list"]
         put sCArray[cID]["rect"][i] & cr after sCArray[cID]["rectList"]
         add xOff to item 1 of sCArray[cID]["rect"][i]; add xOff to item 3 of sCArray[cID]["rect"][i]
         add yOff to item 2 of sCArray[cID]["rect"][i]; add yOff to item 4 of sCArray[cID]["rect"][i]
      end repeat
      if i = 0 then
         put the working screenrect into sCArray[cID]["cRect"]
         put the rect of cID into sCArray[cID]["rectList"]
         add xOff to item 1 of sCArray[cID]["rectList"]; add xOff to item 3 of sCArray[cID]["rectList"]
         add yOff - item 2 of sCArray[cID]["cRect"] to item 2 of sCArray[cID]["rectList"]; add yOff - item 2 of sCArray[cID]["cRect"] to item 4 of sCArray[cID]["rectList"]
      else
         put the rect of cID into sCArray[cID]["cRect"]
         add xOff to item 1 of sCArray[cID]["cRect"]; add xOff to item 3 of sCArray[cID]["cRect"]
         add yOff to item 2 of sCArray[cID]["cRect"]; add yOff to item 4 of sCArray[cID]["cRect"]
      end if
   end if
   if i > 0 
   then put sCArray[cID]["cRect"] into sCArray[cID]["cGlobalRect"]
   else put sCArray[cID]["rectList"] into sCArray[cID]["cGlobalRect"]
   if word 1 of cID is "group" then
      add xOff to item 1 of sCArray[cID]["cGlobalRect"]; add xOff to item 3 of sCArray[cID]["cGlobalRect"]
      add yOff to item 2 of sCArray[cID]["cGlobalRect"]; add yOff to item 4 of sCArray[cID]["cGlobalRect"]
   end if
   put cID
   if word 1 of cID is "card" then
      
      put item 2 of the working screenrect into yScreenOff
      add yScreenOff to item 4 of sCArray[cID]["cGlobalRect"]
   end if
   
   put max(i,1) into sCArray[cID]["count"]
   put iff(sCArray[cID]["list"] is empty,"end","true") into sCArray[cID]["done"]
end addContainer

on targetContainer i,pID
   if i > 0 then dispatch "flashControl" to card "DragTargets" of stack "revDragTarget" with i
   if sCArray[pID]["done"] is empty then addContainer pID
   --if sCArray[pID]["done"] is "end" and pID is not "windows" then exit targetContainer
   put sCArray[pID]["rect"] into sRectArray
   put pID into sTargetID
   if word 1 of pID is "card" then 
      lock messages;go pID;unlock messages
      put pID
   end if
   dispatch doSetup to card "DragTargets" of stack "revDragTarget" with sCArray[pID]["count"],sCArray[pID]["rectList"],sCArray[pID]["cRect"]
   --dispatch mimicIDList to card "DragTargets" of stack "revDragTarget" with sCArray[pID]["list"],sCArray[pID]["cRect"]
end targetContainer




on startDragging tCallerID,tIDList
   lock screen
   put tCallerID into sCallerID
   put tIDList into sIDList
   put the number of lines of tIDList into sObjectCount
   delete variable sCArray
   targetContainer 0,"windows"
   
   forceNControls (the long id of grp "rects"),sObjectCount
   put 0 into i
   repeat for each line tID in tIDList
      add 1 to i
      set the rect of control i of grp "rects" to the rect of tID
   end repeat
   set the width of this stack to the width of grp "rects"
   set the height of this stack to the height of grp "rects"
   set the topLeft of grp "rects" to 0,0
   put the screenmouseLoc into SML
   set the loc of this stack to SML
   palette this stack
   set the vis of this stack to true
   go this stack
   unlock screen
end startDragging

function trackMovement
   cancel sTargetMessage
   put empty into targetID
   put the screenmouseLoc into SML
   set the loc of this stack to SML
   --put sTargetCount & ticks()
   repeat with i = 1 to item 2 of the extents of sCArray[sTargetID]["gRect"]
      -- put SML & cr & sRectArray[i]
      if sCArray[sTargetID]["gRect"][i] is empty or SML is not within sCArray[sTargetID]["gRect"][i] then next repeat
      put sCArray[sTargetID]["id"][i] into targetID
      exit repeat
   end repeat
   if targetID is not empty then 
      --put "targetContainer" && i,targetID && ticks()
      if the controlkey is "up" then
         
         if word 1 of targetID is "stack" then
            targetContainer i,targetID
         else
            send "targetContainer" && i,targetID to me in 40 ticks
            put the result into sTargetMessage
         end if
      end if
   else
      put empty into sTargetMessage
      put sTargetID into pID
      if the controlkey is "up" then
         repeat until word 1 of pID is empty or SML is within sCArray[pID]["escape"]
            delete word 1 to 4 of pID
            if word 1 of pID is "card" then put the name of stack (word -2 to -1 of pID) into pID
         end repeat
      end if
      if pID is not sTargetID then 
         if word 1 of pID is empty then targetContainer 0,"windows" else targetContainer 0,pID
      end if
   end if
   return sTargetID
end trackMovement


function testtestF
   return testF()
end testtestF

on finishDrag tTargetID
   cancel sTargetMessage
   if tTargetID is not empty then put tTargetID into sTargetID
   lock screen
   set the vis of this stack to false
   dispatch "cleanUp" to this cd of stack "revDragTarget"
   --put sTargetID & cr & cr & sIDList
   if sTargetID is "windows" then exit finishDrag
   put stackNameFromID(sTargetID) into targetStack
   put the topleft of targetStack into TLt
   
   put subtractList(TLt,addList(the margins of group "rects",the topleft of stack "revDragRep")) into tOffset
   put subtractList(TLt,the topleft of stack "revDragRep") into tOffset
   --put addList(the margins of group "rects",the topleft of me) into tOffset
   --answer the name of me & cr & the topleft of me
   
   --put the topleft of me into tOffset
   
   
   put 0 into i
   repeat for each line tID in sIDList
      add 1 to i
      if word 1 of tID is "stack" then 
         if word 1 of sTargetID is "stack" and ((the mainstack of sTargetID is the short name of sTargetID) or (the short name of sTargetID is the short name of tID))
         then set the mainstack of tID to sTargetID
         next repeat
      end if
      if word 1 of sTargetID is "stack" or word 1 of tID is not "card" then copy tID to sTargetID
      if word 1 of tID is "card" then next repeat
      put it into copyID
      set the rect of copyID to addList(tOffset,the rect of control i of grp "rects")
   end repeat 
   unlock screen
end finishDrag
