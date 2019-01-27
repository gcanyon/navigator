script "rev_c_card_id_1002"
on preOpenStack
   getPrefs
   buildActionsList
end preOpenStack

on buildActionsList
   buildCustomCommandList
   put the customCommandList of stack "revNavigator" into ccList
   put the baseMenuItemList of group "list action buttons" into BMIL
   if ccList is not empty then put cr & "-" & cr & ccList after BMIL
   set the menuItemList of group "list action buttons" to BMIL
end buildActionsList

on buildColorSetMenu
   put the label of button "ColorSet" of group "Colors" into tChosenItem
   put the customproperties of group "Colors" into colorSets
   repeat for each key K in colorSets 
      if K is empty or colorSets[K] is empty 
      then delete variable colorSets[K]
      else put (char 2 to -1 of K) & cr after T2
   end repeat 
   set the customproperties of group "Colors" to colorSets
   put "Save Current..." into T
   if T2 is not empty then put cr & "-" & cr & char 1 to -2 of T2 after T
   put T into button "ColorSet" of group "Colors"
   set the label of button "ColorSet" of group "Colors" to tChosenItem
end buildColorSetMenu

on getPrefs
   put the long id of stack (the pNavigatorName of this stack) into navID
   put the long id of stack navStack() into mainNavID
   set the customPropertySet of navID to empty
   repeat for each line CS in the customKeys of group "colors"
      put char 2 to -1 of CS & cr after BT
   end repeat
   set the text of button "colorset" to BT & "Save Current..."
   
   -- Display Options
   repeat for each item P in "ColorScriptedObjects,AutoUpdateList,AutoUpdateSelection,namedObjectsOnly,scriptedObjectsOnly,showListLines,EditorsAsPalettes,FoldDataGrids"
      set the highlight of btn P to the P of navID
   end repeat
   put the fontNames into FN
   replace "(" with "\(" in FN
   sort lines of FN
   put FN into btn "List Font"
   set the label of btn "Default Fold" to the pDefaultFold of navID 
   
   set the label of btn "List Font" to the textFont of fld "list" of navID
   set the label of btn "List Font Size" to the textSize of fld "list" of navID
   set the label of btn "List Object Limit" to the pObjectLimit of navID
   set the label of btn "Menu Limit" to the pMenuLimit of navID
   
   -- Object Properties
   put the customProperties["gSBAddPropsProp"] of mainNavID into addPropArray
   set the customProperties of fld "AddPropertiesSelect" to addPropArray
   put the keys of addPropArray into fld "AddPropertiesSelect"
   if the last char of fld "AddPropertiesSelect" is cr then delete the last char of fld "AddPropertiesSelect" 
   sort fld "AddPropertiesSelect" 
   if line 1 of fld "AddPropertiesSelect" is empty then delete line 1 of fld "AddPropertiesSelect"
   send "clearLastSelection" to fld "AddPropertiesSelect"
   send "selectionChanged" to fld "AddPropertiesSelect" in 5 ticks
   
   
   -- List Colors
   repeat for each item C in "Default,ScriptedObject,BehaviorScripted,ScriptandBehavior,ObjectMissing,FilterText,HighLight,ListLines,Background"
      put "pColor" & C into U
      set the backgroundColor of graphic C to the U of navID
   end repeat
   
   -- List Actions
   
   repeat for each line uID in the childcontrolids of group "list action buttons"
      put the short name of control id uID into U
      set the label of control id uID to the U of navID --titleSpace(the U of navID)
   end repeat
   set the label of btn "Command Bar Count" to the pCommandBarCount of mainNavID
   
   
   -- List Display Strings
   put the pIndentString of navID into fld "Indent String"
   --answer "set the label of btn 'List Display String' to" && the uDisplay of navID
   set the label of btn "List Display String" to the uDisplay of navID
   
   
   -- Other
   set the label of btn "stackFileVersion" to the navigatorStackFileVersion of mainNavID
   
   buildColorSetMenu
   
end getPrefs

on setPrefs
   put the long id of stack navStack() into mainNavID
   
   updateAddProperties
   set the pCommandBarCount of mainNavID to the label of btn "Command Bar Count"
   
   if true or the hilitedText of btn "localGlobal" is "global" then
      repeat for each line S in the openStacks
         if word 1 of S is "revNavigator" then put (the long id of stack S) & cr after navIDList
      end repeat
   else
      put the long id of stack (the pNavigatorName of this stack) into navIDList
   end if
   
   
   repeat for each line navID in navIDList
      
      -- Display Options
      repeat for each item P in "ColorScriptedObjects,AutoUpdateList,AutoUpdateSelection,namedObjectsOnly,scriptedObjectsOnly,showListLines,EditorsAsPalettes,FoldDataGrids"
         set the P of navID to the highlight of btn P
      end repeat
      set the hGrid of fld "list" of navID to the highlight of btn "showListLines"
      set the pDefaultFold of navID to the label of btn "Default Fold"
      --set the fixedLineHeight of fld "list" of navID to false
      set the textFont of fld "list" of navID to the label of btn "List Font"
      set the textSize of fld "list" of navID to the label of btn "List Font Size"
      --if fld "list" of navID is empty then put cr into fld "list" of navID
      --put trunc((the textheightsum of fld "list" of navID)/(the number of lines of fld "list" of navID)) into myTH
      --set the fixedLineHeight of fld "list" of navID to true
      set the textHeight of fld "list" of navID to 1 + round(4 * the textSize of fld "list" of navID / 3) -- myTH
      
      
      set the pObjectLimit of navID to the label of btn "List Object Limit"
      set the pMenuLimit of navID to the label of btn "Menu Limit"
      
      
      -- List Colors
      repeat for each item C in "Default,ScriptedObject,BehaviorScripted,ScriptandBehavior,ObjectMissing,FilterText,HighLight,ListLines,Background"
         put "pColor" & C into U
         dispatch "setColor" to navID with U,(the backgroundColor of graphic C)
      end repeat
      
      -- List Actions
      
      repeat for each line uID in the childcontrolids of group "list action buttons"
         put the short name of control id uID into U
         put the label of control id uID into tCMD
         --if tCMD is among the items of "Copy ID,Edit Script,Edit Behavior Script,Property Editor,Single Object Inspector,Individual Object Inspectors,Bookmark-Remove,Size/Location Editor,Color Editor" then replace space with empty in tCMD
         set the U of navID to tCMD
      end repeat
      
      dispatch "updateCommandBars" to navID
      
      -- List Display Strings
      set the pIndentString of navID to fld "Indent String"
      set the uDisplay of navID to the label of btn "List Display String"
      
      send "updateDisplay true,true" to navID in 6 ticks
      
   end repeat
   
   -- Object Properties
   put the customProperties of fld "AddPropertiesSelect" into addPropArray
   set the customProperties["gSBAddPropsProp"] of stack mainNavID to addPropArray
   
   
   -- Other
   set the navigatorStackFileVersion of stack mainNavID to the label of btn "stackFileVersion"
   
   prefsSave
end setPrefs

on updateAddProperties cProp,cValue
   if cProp is empty then put the hilitedText of field "AddPropertiesSelect" into cProp
   if cValue is empty then put the text of fld "addPropertiesEntry" into cValue
   set the cProp of field "AddPropertiesSelect" to cValue
  -- put cProp & cr & cr & cValue
end updateAddProperties
