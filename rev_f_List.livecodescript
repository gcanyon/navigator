script "rev_f_List"
global gLastLineClicked
global gSBWhichStack,gSBWhichCard,gSBlastHilitedLines,gSBshowTooltip
global gSBCustomCommands -- the menu of custom commands available
global gSBShowList -- if true, show a list of cards/backgrounds
global gSBCardOrBackground -- if card, display cards, if background, display backgrounds, if stack, display stacks
global gSBLastCopiedObjectList -- a list of the IDs of the last copied objects 
local tOriginalScroll,tClickLine
local tStartDragMessage
local sDropLines -- the items that actually need to be rearranged on dropping.

local sLocalDrag -- true if a drag originates from the list
local sClickTicks -- the ticks when the mouse was clicked


#############################################################################

local tDragging -- are we dragging within this list
local tStartHeight -- the y coordinate for the "0" position for dragging
local tRowHeight -- the height of each row
local tScrolledRows -- the number of rows we are scrolled down
local tHalfRowHeight -- half the height of a row
local tDragIndicatorX -- the x of the loc of the drag indicator
local tScrollUpLimit -- the point above which we should scroll the list field when dragging
local tScrollDownLimit -- the point below which we should scroll the list field when dragging
local tBaseStartHeight -- the start height without accounting for how the field is scrolled.
local tMaxScroll -- the maximum amount the list field can be scrolled
local sRowsDown -- the row the drag will hit
local tWhichLine -- the number of the line clicked


##########################
# new locals for dragging
local sSource
local sDragging, sMouseWasWithin
local sOriginalText, sOriginalScroll, sOriginalNum
local sDragHTMLText, sDragNum,sDropHTMLText
local sFldTop,sFldTextHeight, sFldScroll
local sDropZone, sScrollUpZone, sScrollDownZone
local sMaxScroll, sTextWithout, sLastLineNum
local sOriginalHTMLText -- the htmlText of the field before dragging started
local sUndoMessage -- a reference to the message that undoes the drag
local sHilitedLines -- a list of the currently hilited lines
local sMouseDragY -- the Y location of the mouse when the mouse went down
###################



on popit
   put iff(the optionKey is "down","popprop","popup") into bName
   send "prepareItems" to btn bName
   popup btn bName
   if bName is not "popup" then set the menumode of btn bName to "pulldown"
end popit

on mouseMove
   if not gSBshowTooltip then exit mouseMove
   put word 2 of the mouseLine into tKey
   put getID(tKey) into tID
   set the tooltip of the target to tID
end mouseMove


on mouseDoubleUp
   put the mouseLoc into XY
   if ticks() > sClickTicks + 60 or abs(item 1 of XY - item 1 of the clickloc) >= the dragdelta or abs(item 2 of XY - item 2 of the clickloc) >= the dragdelta then exit mouseDoubleUp
   try
      put word 2 of the clickLine into tLine
      put "Double-Click:" into tProperty
      if the commandKey is "down" then put "Command-" before tProperty
      if the optionKey is "down" then put "Option-" before tProperty
      put the tProperty of this stack into tCommand
      if tCommand is "EditScript" then
         editObjectScripts tLine
      else if tCommand is "EditBehaviorScript" then
         editObjectScripts tLine,true
      else if tCommand is "ObjectInspector" then
         objectInspectorN tLine
      else if tCommand is "Bookmark-Remove" then
         bookmarkRemove tLine
      else if tCommand is "PropertyEditor" then
         dispatch "setup" to group "editProps" with getID(firstNotEmpty(word 2 of the clickLine,the uClickedLine of this card))
      else if tCommand is "CopyID" then
         set the clipboardData["text"] to getID(tLine)
      end if
      put the hilitedLines of the target into sHilitedLines
   catch tErr
      put tErr
   end try
end mouseDoubleUp

on mouseUp
   lock screen
   put the scroll of me into S   
   put the hilitedLines of fld "list" into tHiliteList
   if tWhichLine is among the items of tHiliteList then
      select line tWhichLine of fld "list"
      set the hilitedlines of fld "list" to tHiliteList
   end if
   set the scroll of me to S
   unlock screen
end mouseUp


on mouseDown pWhichButton
   put ticks() into sClickTicks
   put word 2 of the clickLine into tWhichLine
   set the uClickedLine of this card to tWhichLine
   if pWhichButton is not 3 then exit MouseDown
   dontDrag
   if not (tWhichLine is among the items of the hilitedLines of the target) \
         then set the hilitedLines of the target to word 2 of the clickLine
   popit
end mouseDown


on relayerControlList pTargetLine,pLinesToRelayerList
   put pLinesToRelayerList into pLinesToRelayerListA
   split pLinesToRelayerListA with comma as set
   repeat with beforeLine = pTargetLine - 1 down to 0
      if not pLinesToRelayerListA[beforeLine] then exit repeat
   end repeat
   repeat with afterLine = pTargetLine to 999999999
      if not pLinesToRelayerListA[afterLine] then exit repeat
   end repeat
   
   repeat for each item i in pLinesToRelayerList
      if i < beforeLine then
         put getID(i) & cr after beforeList
      else if i > afterLine then
         put getID(i) & cr before afterList
      end if
   end repeat
   
   put beforeLine - (the separatorLine of the target) - 2 into tBeforeLayer
   put afterLine - (the separatorLine of the target) - 2 into tAfterLayer
   
   if (line 1 of beforeList is not empty) or (line 1 of afterList is not empty) then 
      if line 1 of beforeList is not empty then put line 1 of beforeList into sID else put line 1 of afterList into sID
      if word -5 of sID is "stack" then put -5 into stackWord else put -2 into stackWord
      put char 2 to -2 of word stackWord + 1 of sID into sName
      put word stackWord - 2 of sID into cardID
      
      lock messages
      lock screen   
      put the short name of the topstack into tStackName
      put the id of this cd of stack sName into tCardID
      if tCardID is cardID then put empty into returnMSG 
         else put format("go card id %s of stack \"%s\"\N",tCardID,sName) into returnMSG
      
      if sName is not tStackName then put format("go stack \"%s\"",tStackName) after returnMSG
      if returnMSG is not empty then go cd id cardID of stack sName
      
      set the relayergroupedcontrols to the optionkey is "up"
      repeat for each line pID in beforeList
         set the layer of pID to tBeforeLayer
      end repeat
      repeat for each line pID in afterList
         set the layer of pID to tAfterLayer
      end repeat
      if returnMSG is not empty then send returnMSG to me in 1 tick
      unlock messages
      unlock screen
   end if
   
   doUpdateDisplay true
end relayerControlList

on relayerBookmarkList pTargetLine,pLinesToRelayerList
   if pLinesToRelayerList is empty then exit relayerBookmarkList
   put the separatorLine of fld "list" into tSeparatorLine
   put the htmlText of line 1 to tSeparatorLine of fld "list" into tLineList
   put empty into tBeforeLines
   put empty into tDraggedLines
   put empty into tAfterLines
   put 0 into tCurrentLine
   repeat for each line tLine in tLineList
      add 1 to tCurrentLine
      if tCurrentLine is among the items of pLinesToRelayerList then
         if tCurrentLine < pTargetLine then add 1 to pTargetLine
         put tLine & cr after tDraggedLines
      else if tCurrentLine < pTargetLine then
         put tLine & cr after tBeforeLines
      else
         put tLine & cr after tAfterLines
      end if
   end repeat
   put tBeforeLines & tDraggedLines & tAfterLines into tNewLines
   set the htmlText of line 1 to tSeparatorLine of fld "list" to tNewLines
end relayerBookmarkList

on addBookmarkedControls pLineList,pTargetLine
  put getID(pLineList) into tLineIDList
  put the separatorLine of the target into tSeparatorLine
  put pTargetLine - (tSeparatorLine + 2) into tTargetLayer
  put getID(tSeparatorLine+1) into tStackRef
  put the value of word -1 of tStackRef into tStackName
  put the long id of tStackRef into tStackID
  if gSBShowList[the short name of this stack] then
    put getID(pTargetLine) into tCardBGRef
  else
    put getID(tSeparatorLine+2) into tCardBGRef
  end if
  repeat for each line tID in tLineIDList
    put word 1 of tID into tType
    switch tType
    case "stack"
      set the mainStack of tID to tStackName
      break
    case "card"
      if word -1 of tID is not word -1 of tStackID then
        copy tID to tStackRef
        put it into tNewID
      else
        put tID into tNewID
      end if
      if gSBShowList[the short name of this stack] and gSBCardOrBackground[the short name of this stack] is "card" then
        try
          set the layer of tNewID to tTargetLayer
        catch pSomeErr
          set the relayerGroupedControls to true
          set the layer of tNewID to tTargetLayer
        end try
        add 1 to tTargetLayer
      end if
      break
    case "group"
      --do group here
      put "background id" && word 3 of tID && word -3 to -1 of tID into tBGID
      if word -1 of tID is word -1 of tStackID then
        try
          place tBGID onto tCardBGRef
          put tBGID into tNewID
          put "group" into word 1 of tNewID
        catch tSomeErr
        end try
      else
        copy tID to tCardBGRef
        put it into tNewID
      end if
      if not gSBShowList[the short name of this stack] then
        try
          set the layer of tNewID to tTargetLayer
        catch pSomeErr
          set the relayerGroupedControls to true
          set the layer of tNewID to tTargetLayer
        end try
        add ((the number of controls of tNewID)+1) to tTargetLayer
      end if
      break
    default
      copy tID to tCardBGRef
      if not gSBShowList[the short name of this stack] then
        try
          set the layer of it to tTargetLayer
        catch pSomeErr
          set the relayerGroupedControls to true
          set the layer of it to tTargetLayer
        end try
        add 1 to tTargetLayer
      end if
    end switch
  end repeat
end addBookmarkedControls

on placeGroupOntoCards pWhichLine,tObjectList
   put getID(pWhichLine) into tID
   if word 1 of tID is not "group" then exit placeGroupOntoCards
   put "background id" && word 3 of tID && word -3 to -1 of tID into tBackgroundID
   put getID(tObjectList) into tCardList
   if word -1 of tBackgroundID is not word -1 of line 1 of tCardList then
      put word -2 to -1 of line 1 of tCardList into tStackRef
      copy tBackgroundID to tStackRef
      put it into tBackgroundID
   end if
   repeat for each line tCard in tCardList
      if word 1 of tCard is not "card" then next repeat
      try
         place tBackgroundID onto tCard
      catch tSomeErr
      end try
   end repeat
end placeGroupOntoCards

on dragLines pDragList,pTargetLine
   put the separatorLine of me into tSeparatorLine
   put splitList(tSeparatorLine,pDragList) into dragA
   switch
      case pTargetLine <= tSeparatorLine + 1 -- drag into bookmarks
         if dragA[1] is not empty then relayerBookmarkList pTargetLine,dragA[1]         
         if dragA[2] is empty then break
         setBookmarks dragA[2]
         put the separatorLine of me - tSeparatorLine into tNewBookmarkCount
         if tNewBookmarkCount <= 0 then break
         put splitList(pTargetLine,dragA[1]) into bookmarkA
         add the number of items of bookmarkA[2] to pTargetLine
         relayerBookmarkList pTargetLine,numberItems(1,tNewBookmarkCount)
         break
      default -- drag into control list
         if gSBShowList[the short name of this stack] then
            if gSBCardOrBackground[the short name of this stack] is not "card" then
               put empty into dragA[2] -- we don't rearrange stacks or groups
            else if word 1 of getID(tWhichLine) is "group" then
               placeGroupOntoCards tWhichLine,dragA[2]
               put empty into dragA[1]
               put empty into dragA[2]
            end if
         end if
         if dragA[2] is not empty then relayerControlList pTargetLine,dragA[2]
         if dragA[1] is not empty then
            addBookmarkedControls dragA[1],pTargetLine
            doUpdateDisplay true
         end if
   end switch
   set the hilitedLines of me to numberItems(pTargetLine,(pTargetLine + sDragNum - 1))
end dragLines

local storeHilitedLines,storeClickLine,mouseXY


on selectionChanged 
   updateRevSelectedObjects
end selectionChanged



--------------------
-- Drag Drop routines
--------------------

local tDragList             #THE LIST OF LINES TO DRAG
local tDragArray            #THE ARRAY OF LINES TO DRAG
local dragStarted           #SET TO TRUE WHEN DRAGGING IS IN PROGRESS
local noFlyRect             #IF THE MOUSE MOVES OUTSIDE THIS RECT, CANCEL DRAG DROP
local targetLine            #THE LINE ABOVE WHICH THE DRAG WILL BE
local myHTMLtext            #THE HTMLTEXT OF THE FIELD
local myLineCount           #THE NUMBER OF LINES IN THE FIELD
local fieldClickLine        #THE NUMBER OF THE LINE THAT WAS CLICKED, WITHIN THE FIELD
local tDragListClickLine    #THE NUMBER OF THE LINE THAT WAS CLICKED, WITHIN THE HILITEDLINES
local myTH                  #THE EFFECTIVE TEXT HEIGHT OF THE FIELD
local vDraggerOffset        #THE VERTICAL OFFSET FOR POSITIONING _DRAGGER
local thePointerID          #THE ID OF THE POINTER GRAPHIC
local theDraggerID          #THE ID OF THE DRAGGER IMAGE
local startDraggingCount
local externalDrag        #SET TO TRUE WHEN A DRAG LEAVES THE LIST
--local mouseMoveCounter

before mouseDown
   put 0 into startDraggingCount
   put word 2 of the clickLine into fieldClickLine
   set the wholeMatches to true
   put itemOffset(fieldClickline,tDragList) into tDragListClickLine
   --    put fieldClickline && tDragList && tDragListClickLine into tTattle
   --    send "tattle" && tTattle to me in 2 seconds
   
   if tDragListClickLine > 0 then restoreHilites tDragList
end mouseDown

on tattle T
   put T & cr after message
end tattle

on dontDrag
   put 0 into tDragListClickLine
end dontDrag

on isDragStarted
   put dragStarted
end isDragStarted

after mouseMove X,Y
   --put "list" && dragStarted && externalDrag && ticks()
   if dragStarted then 
      --put ticks()
      trackReorder X,Y 
   else if externalDrag then
      -- if the mouse is "down" then 
      dispatch "trackMovement" to this cd of stack "revDragRep"
      -- else
     -- cleanUpExternalDrag
      --stackCleanUpExternalDrag
      --end if
   else if tDragListClickLine > 0 then 
      startDragging X,Y
   end if
   -- send "tattle" && dragStarted && tDragListClickLine to me in 2 seconds
end mouseMove

after mouseUp
   --put "mouseUp" && ticks() && the mouse
   if dragStarted then finishReorder else if tDragListClickLine > 0 then cleanUp fieldClickLine
   if externalDrag then cleanUpExternalDrag
end mouseUp

after mouseRelease
   --put "mouseRelease" && ticks() && the mouse
   --if the mouse is "down" then exit mouseRelease
   if dragStarted then 
      finishReorder 
      set the hScrollbar of me to true
      cleanUp
   end if
   if externalDrag then cleanUpExternalDrag true
   --stackCleanUpExternalDrag
end mouseRelease

after selectionChanged
   storeHilites
end selectionChanged


after mouseEnter
   storeHilites
end mouseEnter

on storeHilites
   put the hilitedLines of me into tDragList
   put tDragList into tDragArray
   split tDragArray using comma as set
end storeHilites

on cleanUp restoreLine
   if restoreLine is not empty then restoreHilites restoreLine
   put 0 into tDragListClickLine
   put false into dragStarted
   
   if there is a thePointerID then delete thePointerID
   if there is a theDraggerID then delete theDraggerID
   --put ticks()
end cleanUp

on cleanUpExternalDrag notifyRevDragRep
   if notifyRevDragRep and the vis of stack "revDragRep" then dispatch "finishDrag" to this cd of stack "revDragRep"
   set the hScrollbar of me to true
   put false into externalDrag
end cleanUpExternalDrag

on restoreHilites H
   put the scroll of me into S
   set the hilitedLines of me to H
   storeHilites
   set the scroll of me to S
end restoreHilites

on dTattle M
   send "tattle" & M to me in 2 seconds
end dTattle

on startDragging X,Y
   add 1 to startDraggingCount
   --put startDraggingCount && ticks()
   if abs(X - item 1 of the clickLoc)  < the dragDelta and abs(Y - item 2 of the clickLoc) < the dragDelta then exit startDragging
   put true into dragStarted
   set the hScrollbar of me to false
   --put ticks()
   put (the left of me - 5),(the top of me - 20),(the right of me + 5),(the bottom of me + 20) into noFlyRect
   put the htmlText of me into myHTMLtext
   put the number of lines of myHTMLtext into myLineCount
   put the effective textHeight of me into myTH
   put max(1,min(item 2 of the clickLoc - the top of me,tDragListClickLine * myTH + item 2 of the clickLoc - item 4 of the formattedrect of line fieldClickLine of me)) into vDraggerOffset
   lock screen
   --put "made it! 1" && startDraggingCount && ticks()
   put newPointer() into thePointerID
   put newDragger() into theDraggerID
   trackReorder X,Y
end startDragging

on trackReorder X,Y
   if not (X,Y is within noFlyRect) then 
      cleanUp
      dispatch "startDragging" to this cd of stack "revDragRep" with (the long id of me),getID(tDragList)
      put true into externalDrag
      exit trackReorder
   end if
   set the topLeft of theDraggerID to (X - item 1 of the clickLoc + the left of me),(Y - vDraggerOffset)
   
   autoScrollTheField
   put max(1,min(1 + myLineCount,round((Y + the scroll of me - the top of me) / myTH + .5))) into targetLine
   put -4 + item (item (1 + 1 div targetLine) of "4,2") of the formattedRect of line max(1,targetLine - 1) of me into pointerTop
   set the top of thePointerID to pointerTop
   set the points of thePointerID to the points of thePointerID
   --if the optionkey is down then set the topLeft of thePointerID to X,(Y+20)
   
   --put X,Y && noFlyRect && the vis of thePointerID && pointerTop & cr & the top of thePointerID & cr & the points of thePointerID
end trackReorder

on finishReorder
   cleanUp
   if not the reportDragAndDropOnly of me then 
      put the scroll of me into S
      set the wholeMatches to true 
      repeat for each line L in myHTMLtext  --the HTMLtext of me
         add 1 to LC
         if tDragArray[LC] is not empty then put L & cr after H[0]
         else if LC < targetLine then put L & cr after H[1]
         else put L & cr after H[2]
      end repeat
      repeat with i = the number of lines of H[1] + 1 to myLineCount - the number of lines of H[2]
         put i & comma after newHilite
      end repeat
      delete char -1 of newHilite
      set the HTMLtext of me to H[1] & H[0] & H[2]
      set the hilitedLines of me to newHilite
      set the scroll of me to S
   end if
   dispatch "dragLines" to me with tDragList,targetLine
   --dispatch "dragLines" to me with tDragList,newHilite
   put the hilitedLines of me into tDragList
end finishReorder

on dragLines pDragList,pTargetLine
   -- put pDragList & cr & pTargetLine
end dragLines

function newPointer
   put left of me + 2 into L
   put right of me - 16 - 2 into R  # ASSUME SCROLLBAR WIDTH IS 16
   put format("%s,0\n%s,3\n%s,3\n%s,0\n%s,7\n%s,4\n%s,4\n%s,7\n%s,0",L,L+3,R-3,R,R,R-3,L+3,L,L) into tPoints
   --put tPoints into fld 1 of stack "bob"
   put newGraphic("filled=true|backColor=black|style=polygon|name=_dragpointer|points=" & tPoints) into R
   return R
end newPointer

function newDragger   
   put the scroll of me into S
   put the HTMLtext of me into H
   put tDragList into tDragArray
   split tDragArray using comma as set
   put (the height of me div myTH) into draggerCount
   put 0 into LC
   repeat for each line L in H
      add 1 to LC
      if tDragArray[LC] is empty then next repeat
      subtract 1 from draggerCount
      if draggerCount = 0 then 
         put "<P>...</P>" after H2
         exit repeat
      end if
      put L & cr after H2
   end repeat
   set the HTMLtext of me to H2
   put the formattedRect of line 1 to -1 of me into tRect
   put (left of me + borderWidth of me),(item 2 of tRect),(right of me - 16 - borderWidth of me),(item 4 of tRect) into tRect  # ASSUME SCROLLBAR WIDTH IS 16
   set listBehavior of me to false # DISABLE LIST BEHAVIOR SO TEXT STAYS VISIBLE IN FIELD
   put newImage("threeD=false|showBorder=true|borderWidth=1|blendLevel=25|name=_dragger",tRect,the long id of me) into R
   set the HTMLtext of me to H
   set listBehavior of me to true
   set hilitedLines of me to tDragList
   set the scroll of me to S
   return R
end newDragger

on autoScrollTheField
   put (mouseV() - item 2 of the loc of me) div (the height of me div 2) * myTH into scrollInc 
   if "autoScrollTheField" is in pendingMessages() or scrollInc = 0 then exit autoScrollTheField
   put the scroll of me into S
   set the scroll of me to S + scrollInc
   if the scroll of me = S then exit autoScrollTheField
   send "autoScrollTheField" to me in 80 millisecs
end autoScrollTheField

## THESE ARE UTILITY ROUTINES ##
## YOU MIGHT CONSIDER MOVING THEM TO A STACK SCRIPT OR A LIBRARY ##

function newGraphic P
   reset the templateGraphic
   split P using "|" and "="
   repeat for each key K in P
      --put "made it to oz" & cr & K & cr & ticks()
      set the K of the templateGraphic to P[K]
   end repeat
   --put "made it to oz" & cr & "create" & cr & ticks()
   try
      create graphic
   catch error someErr
      put someErr
   end try
   --put "made it to oz" & cr & "long id" & cr & ticks()
   
   put the long id of it into R
   --put "made it to oz" & cr & "reset" & cr & ticks()
   
   reset the templateGraphic
   return R
end newGraphic

function newImage P,pRect,pID
   reset the templateImage
   split P using "|" and "="
   repeat for each key K in P
      set the K of the templateImage to P[K]
   end repeat   
   import snapshot from rect pRect of pID
   reset the templateImage
   return the long id of the last image
end newImage

