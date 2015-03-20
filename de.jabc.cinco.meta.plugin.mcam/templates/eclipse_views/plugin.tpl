<?xml version="1.0" encoding="UTF-8"?>
<?eclipse version="3.4"?>
<plugin>

   <extension
         point="org.eclipse.ui.views">
      <category
            name="Model-CaM Category"
            id="${ViewPackage}">
      </category>
      <view
            name="Conflict View"
            category="${ViewPackage}"
            class="${ViewPackage}.views.ConflictView"
            id="${ViewPackage}.views.ConflictView">
      </view>
      <view
            name="Check View"
            category="${ViewPackage}"
            class="${ViewPackage}.views.CheckView"
            id="${ViewPackage}.views.CheckView">
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
               id="${ViewPackage}.views.ConflictView">
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

