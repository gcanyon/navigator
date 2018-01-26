script "revNavigator_button_Jump_To:_behavior_2446_Behavior"
on mouseDown
   put fld "aboutBody" into AB
   filter AB with "-- * --"
   replace "-- " with empty in AB
   replace " --" with empty in AB  
   replace "/" with "//" in AB    
   put AB into me
end mouseDown
   
on menuPick pWhich
   find whole ("--" && pWhich && "--") in fld "aboutBody" of this stack
   find empty
end menuPick
