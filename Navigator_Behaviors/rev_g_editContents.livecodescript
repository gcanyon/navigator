script "rev_g_editContents"
local sIDList -- list of ids of objects to set
local sClickedID -- id of the object that was clicked to display
local sIsField -- true if we are dealing with a field
local sCallingObjectID -- the ID of the object that called for an ask dialog
local sAsAskDialog -- whether displaying as an ask dialog

on setSize
  put the width of this stack into tWidth
  put the height of this stack into tHeight
  set the rect of fld "setContents" to -2,15,(tWidth+2),max(tHeight - 25,100)
  set the rect of group "setContentsControls" to -2,max(tHeight - 25,100),tWidth+2,tHeight+2
  send "checkMyScroll" to fld "setContents"
end setSize

on editField
  setupHTMLText
  set the hilite of btn "don't wrap" to false
  set the dontwrap of fld "setContents" to false
  put true into sIsField
  showMe
end editField

on editButton
  set the hilite of btn "editContentsHTML" to false
  set the dontwrap of fld "setContents" to true
  hide grp "setContentsHTMLText"
  put false into sIsField
  showMe
end editButton

on showMe pAsAskDialog
   put pAsAskDialog into sAsAskDialog
   if sAsAskDialog then
      put the uDialogText of me into fld "setContents"
      put the uID of me into sCallingObjectID
      set the uID of me to empty
   else
      put empty into sCallingObjectID
      put getID() into sIDList
      put getID(the uClickedLine of this card) into sClickedID
      set the textFont of fld "setContents" to the effective textFont of sClickedID
      if sIsField then
         set the htmlText of fld "setContents" to the htmlText of sClickedID
      else
         put value(sClickedID) into fld "setContents"
      end if
   end if
   
   setSize
   set the hilite of btn "editContentsHTML" to false
   showGroup the long id of me
   select after text of fld "setContents"
end showMe

on hideMe
  hideGroup the long id of me
end hideMe

on setContents
  closeDown
  if sAsAskDialog then
    send "resultMessage" to sCallingObjectID
    exit setContents
  end if
  put fld "setContents" into tPlainText
  replace cr with "\n" in tPlainText
  replace quote with "\" & quote in tPlainText
  if sIsField then
    put the HTMLText of fld "setContents" into tHTMLText
  end if
  repeat for each line tID in sIDList
    if sIsField and word 1 of tID is "field" then
      set the HTMLText of tID to tHTMLText
    else
      put format("put format(\"%s\") into %s",tPlainText,tID) into tCMD
      --put tCMD
      do tCMD
    end if
  end repeat
end setContents

on setupHTMLText
  set the hilite of btn "editContentsHTML" to false
  show group "setContentsHTMLText"
end setupHTMLText

on closeDown
   if the vis of btn "editContentsHTML" and the hilite of btn "editContentsHTML" then switchToText
   set the oneLiner of me to false
end closeDown

on switchToHTML
  put the HTMLText of fld "setContents" into fld "setContents"
end switchToHTML

on switchToText
  set the HTMLText of fld "setContents" to fld "setContents"
end switchToText
