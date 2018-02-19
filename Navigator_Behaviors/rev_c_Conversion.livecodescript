script "rev_c_Conversion"
on resizeStack pNewWidth, pNewHeight
   set the rect of fld "id list convert" to 0,300,pNewWidth,pNewHeight
   set the right of button "Set as template for this/these stack(s)" to pNewWidth - 10
   set the rect of fld "id list restore" to 0,195,pNewWidth,pNewHeight
   set the rect of fld "log" to 0,70,pNewWidth,pNewHeight
   set the rect of fld "Behavior Folder" to 1,(the top of fld "Behavior Folder"),pNewWidth - 1,(the bottom of fld "Behavior Folder")
   set the rect of fld "SoS Name Template" to 1,(the top of fld "SoS Name Template"),pNewWidth - 1,(the bottom of fld "SoS Name Template")
   set the rect of fld "SoS Name Example" to 70,(the top of fld "SoS Name Example"),pNewWidth - 1,(the bottom of fld "SoS Name Example")
   set the right of grp "space replacement" to pNewWidth - 10
   set the rect of btn "tab menu" to 0,0,pNewWidth, pNewHeight
   set the rect of graphic "Behavior Folder Background" to 0,210,pNewWidth,270
   set the rect of graphic "Name Template Background" to 0,60,pNewWidth,140
end resizeStack

on showLog D
   put D into fld "log"
   set the menuhistory of btn "tab menu" of stack "revBehavior Conversion" to 3
end showLog

on closeStack
   cleanUp
end closeStack

on cleanUp
   put empty into fld "id list convert"
   put empty into fld "id list restore"
   put "the name of me && the id of me" into fld "SoS Name Template"
   put empty into fld "Behavior Folder"
   put "_" into fld "space replacement"
   put empty into fld "log"
   set the menuhistory of btn "tab menu" of stack "revBehavior Conversion" to 1
   set the itemDelimiter to "|"
   repeat for each item N in "Convert unscripted objects to script-only stack behaviors|Create script-only stack behaviors for existing script-only stacks|Restore behaviors to multiple objects, duplicating the scripts|Restore behaviors to scripted objects, appending the scripts|Restore from all chain behaviors"
      set the highlight of btn N to false
   end repeat
end cleanUp
