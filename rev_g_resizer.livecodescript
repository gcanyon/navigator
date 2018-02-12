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
  put getID(the uClickedLine of this card) into sID
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

on doResize
  put the rect of sID into tPatternRect
  if tPatternRect is sRect then 
    send "doResize" to me in 1 tick
    put the result into sMessage
    exit doResize
  end if
  lock screen
  switch sResizeMode
  case 1 -- align
    repeat with i = 1 to 4
      put (item i of tPatternRect <> item i of sRect) into tSet[i]
      put item i of tPatternRect into tPatternRectArray[i]
    end repeat
    repeat for each line tID in sIDList
      put the rect of tID into tRect
      repeat with i = 1 to 4
        if tSet[i] then put tPatternRectArray[i] into item i of tRect
      end repeat
      set the rect of tID to tRect
    end repeat
    break
  case 2 -- match
    repeat with i = 1 to 4
      put (item i of tPatternRect <> item i of sRect) into tSet[i]
      put (item i of tPatternRect - item (((i+1) mod 4) + 1) of tPatternRect) into tDiff[i]
    end repeat
    repeat for each line tID in sIDList
      put the rect of tID into tRect
      repeat with i = 1 to 4
        if tSet[i] then put item (((i+1) mod 4) + 1) of tRect + tDiff[i] into item i of tRect
      end repeat
      set the rect of tID to tRect
    end repeat
    break
  case 3 -- proportional
    repeat with i = 1 to 4
      put (item i of tPatternRect - item i of sStartRect)/sDim[i] into tDiff[i]
    end repeat
    put 0 into t
    repeat for each line tID in sIDList
      add 1 to t
      if the rect of tID is not sNRa[t] then
        put the rect of tID into sSRa[t]
        put the width of tID into sw[t]
        put the height of tID into sh[t]
        --put sw[t] && sh[t] && sSRa[t] && sNRa[t] && ticks() & cr after fld 1 of stack "bob"
      end if
      put trunc(tDiff[1] * sw[t] + item 1 of sSRa[t]),\
          trunc(tDiff[2] * sh[t] + item 2 of sSRa[t]),\
          trunc(tDiff[3] * sw[t] + item 3 of sSRa[t]),\
          trunc(tDiff[4] * sh[t] + item 4 of sSRa[t]) into sNRa[t]
      set the rect of tID to sNRa[t]
    end repeat
    break
  case 4 -- scale
    repeat with i = 1 to 4
      put item i of tPatternRect - item i of sRect into tDiff[i]
    end repeat
    repeat for each line tID in sIDList
      put the rect of tID into tRect
      repeat with x = 1 to 4
        add tDiff[x] to item x of tRect
      end repeat
      set the rect of tID to tRect
    end repeat
    break
  end switch
  put tPatternRect into sRect
  unlock screen
  send "doResize" to me in 1 tick
  put the result into sMessage
end doResize
