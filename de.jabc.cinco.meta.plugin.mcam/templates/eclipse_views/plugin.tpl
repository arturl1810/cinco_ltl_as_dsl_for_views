<?xml version="1.0" encoding="UTF-8"?>
<?eclipse version="3.4"?>
<plugin>

   <extension
         point="org.eclipse.ui.views">
      <category
            name="Model-CaM Category"
            id="${McamViewBasePackage}">
      </category>
      <view
            name="Conflict View"
            category="${McamViewBasePackage}"
            class="${McamViewBasePackage}.ConflictView"
            id="${McamViewBasePackage}.ConflictView">
      </view>
      <view
            name="Check View"
            category="${McamViewBasePackage}"
            class="${McamViewBasePackage}.CheckView"
            id="${McamViewBasePackage}.CheckView">
      </view>
   </extension>
<!--
   <extension
         point="org.eclipse.ui.perspectiveExtensions">
      <perspectiveExtension
            targetID="org.eclipse.jdt.ui.JavaPerspective">
         <view
               ratio="0.5"
               relative="org.eclipse.ui.views.ProblemView"
               relationship="right"
               id="${McamViewBasePackage}.ConflictView">
         </view>
      </perspectiveExtension>
   </extension>
   <extension
         point="org.eclipse.help.contexts">
      <contexts
            file="contexts.xml">
      </contexts>
   </extension>
-->
</plugin>

