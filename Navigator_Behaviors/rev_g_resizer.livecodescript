script "rev_g_resizer"
local sID -- the long id of the template object for resizing
local sIDList -- the list of long ids of objects to resize
local sResizeMode -- how we are resizing: 
local sMessage -- the resize message id
local sRect -- the rect to resize from for all but proportional
local sStartRect -- the rect of the template object to resize from for proportional
local sDim -- the array of the height and width to resize from: 1,width; 2,height; 3,width; 4,height
local sSRa -- the array of rects to resize from for proportional
local sNRa -- the array of new rects for the controls
local sW,sH -- the width and height to resize from for proportional

on showMe
  put getID() into tempList
  put getIDFirst(the uClickedLine of this card) into sID
  put empty into sIDList
  repeat for each line L in tempList
    if L is sID then next repeat
    put L & cr after sIDList
  end repeat
  setResizeMode
  showGroup the long id of me
  startResizing
end showMe

on setResizeMode
  put the hilitedButton of group "resizeStyle" into sResizeMode
  if sResizeMode <> 3 then exit setResizeMode
  put the rect of sID into sStartRect
  put the width of sID into tW
  put the height of sID into tH
  put tW into sDim[1]
  put tW into sDim[3]
  put tH into sDim[2]
  put tH into sDim[4]
  put 0 into i
  repeat for each line L in sIDList
    add 1 to i
    put the rect of L into sSRa[i]
    put the width of L into sW[i]
    put the height of L into sH[i]
  end repeat
end setResizeMode

on hideMe
  stopResizing
  hideGroup the long id of me
end hideMe

on startResizing
  put the rect of sID into sRect
  doResize
end startResizing

on stopResizing
  cancel sMessage
end stopResizing

on modifySIDrect deltaR
   if the number of items of deltaR is 2 then
      put (item 1 of the loc of sID + item 1 of deltaR),(item 2 of the loc of sID + item 2 of deltaR) into R
   else
      put the rect of sID into R
      repeat with i = 1 to 4
         add item i of deltaR to R
      end repeat
   end if
   cancel sMessage
   if the number of items of deltaR is 2 then doResize ,R else doResize R 
end modifySIDrect

on doResize newRect,newLoc
   if (newLoc is empty or newLoc is the loc of sID) and (newRect is empty or newRect is sRect) and (the rect of sID is sRect) then
      send "doResize" to me in 1 tick
      put the result into sMessage
      exit doResize
   end if
   put the loc of sID into oldVal
   if newLoc is not empty then
      set the loc of sID to newLoc
   else if newRect is not empty then
      put the width of sID into w
      put the height of sID into h
      set the rect of sID to newRect
      if the width of sID is w and the height of sID is h
      then put the loc of sID into newLoc
      else put empty into newLoc
   else  
      put the rect of sID into newRect
   end if
   
   lock screen
   if newLoc is empty then 
      put newRect into newVal 
      put sRect into oldVal
   else 
      put newLoc into newVal
   end if
   split newVal using comma
   split oldVal using comma
   put item 2 of the extents of newVal into pCount
   switch 
      case sResizeMode = 1 -- align -- new values for the ltrb or xy will be identical to the template
         repeat with i = 1 to pCount
            put (newVal[i] <> oldVal[i]) into tSet[i]
         end repeat
         repeat for each line tID in sIDList
            if pCount = 4 then put the rect of tID into tUpdate else put the loc of tID into tUpdate
            repeat with i = 1 to pCount
               if tSet[i] then put newVal[i] into item i of tUpdate
            end repeat
            if pCount = 4 then set the rect of tID to tUpdate else set the loc of tID to tUpdate
         end repeat
         break
      case sResizeMode = 2 and pCount = 4 -- match -- new values for width or height will be matched to the template
         repeat with i = 1 to pCount
            put (newVal[i] <> oldVal[i]) into tSet[i]
            put newVal[i] - newVal[((i+1) mod 4) + 1] into tDiff[i]
         end repeat
         repeat for each line tID in sIDList
            put the rect of tID into tRect
            repeat with i = 1 to pCount
               if tSet[i] then put item (((i+1) mod 4) + 1) of tRect + tDiff[i] into item i of tRect
            end repeat
            set the rect of tID to tRect
         end repeat
         break
      case sResizeMode = 3 -- proportional -- new values for ltrb or xy will be adjusted by the an amount proportional to the relative size of the object to the template
         repeat with i = 1 to 4
            put (newVal[i] - item i of sStartRect)/sDim[i] into tDiff[i]
         end repeat
         put 0 into t
         repeat for each line tID in sIDList
            add 1 to t
            if the rect of tID is not sNRa[t] then
               put the rect of tID into sSRa[t]
               put the width of tID into sw[t]
               put the height of tID into sh[t]
            end if
            put trunc(tDiff[1] * sw[t] + item 1 of sSRa[t]),\
            trunc(tDiff[2] * sh[t] + item 2 of sSRa[t]),\
            trunc(tDiff[3] * sw[t] + item 3 of sSRa[t]),\
            trunc(tDiff[4] * sh[t] + item 4 of sSRa[t]) into sNRa[t]
            set the rect of tID to sNRa[t]
         end repeat
         break
      case sResizeMode = 4 or (sResizeMode = 2 and pCount = 2) -- scale -- new values for ltrb or xy will be adjusted by the same amount as the template
         repeat with i = 1 to pCount
            put newVal[i] - oldVal[i] into tDiff[i]
         end repeat
         repeat for each line tID in sIDList
            if pCount = 4 then put the rect of tID into tUpdate else put the loc of tID into tUpdate
            repeat with x = 1 to pCount
               add tDiff[x] to item x of tUpdate
            end repeat
            if pCount = 4 then set the rect of tID to tUpdate else set the loc of tID to tUpdate
         end repeat
         break
      case 5 -- proportional group -- resize the whole group of controls as a unit -- tbd
         break
   end switch
   put the rect of sID into sRect
   unlock screen
   send "doResize" to me in 1 tick
   put the result into sMessage
end doResize
