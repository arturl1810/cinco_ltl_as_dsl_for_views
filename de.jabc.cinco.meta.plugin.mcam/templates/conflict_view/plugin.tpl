<?xml version="1.0" encoding="UTF-8"?>
<?eclipse version="3.4"?>
<plugin>

   <extension
         point="org.eclipse.ui.views">
      <category
            name="Model-CaM Category"
            id="${ConflictViewPackage}">
      </category>
      <view
            name="Conflict View"
            category="${ConflictViewPackage}"
            class="${ConflictViewPackage}.views.ConflictView"
            id="${ConflictViewPackage}.views.ConflictView">
      </view>
   </extension>
   <extension
         point="org.eclipse.ui.perspectiveExtensions">
      <perspectiveExtension
            targetID="org.eclipse.jdt.ui.JavaPerspective">
         <view
               ratio="0.5"
               relative="org.eclipse.ui.views.ProblemView"
               relationship="right"
               id="${ConflictViewPackage}.views.ConflictView">
         </view>
      </perspectiveExtension>
   </extension>
   <extension
         point="org.eclipse.help.contexts">
      <contexts
            file="contexts.xml">
      </contexts>
   </extension>

</plugin>

