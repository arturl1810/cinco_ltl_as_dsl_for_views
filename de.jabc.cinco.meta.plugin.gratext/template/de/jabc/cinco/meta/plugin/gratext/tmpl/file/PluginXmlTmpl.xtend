package de.jabc.cinco.meta.plugin.gratext.tmpl.file

import de.jabc.cinco.meta.plugin.template.FileTemplate

class PluginXmlTmpl extends FileTemplate {
	
	String gratextProjectBasePackage
	
	new(String gratextProjectBasePackage) {
		this.gratextProjectBasePackage = gratextProjectBasePackage
	}
	
	override getTargetFileName() '''plugin.xml'''
	
	def targetName() '''«model.name»Gratext'''

	def extensionFactory() '''«basePackage».«model.name»GratextExecutableExtensionFactory'''

	def idPrefix() '''«gratextProjectBasePackage».«targetName»'''
	
	override template() '''	
		<?xml version="1.0" encoding="UTF-8"?>
		<?eclipse version="3.0"?>
		
		<plugin>
		    <extension point="org.eclipse.ui.editors">
		        <editor
		            class="«basePackage».«targetName»Editor"
		            contributorClass="de.jabc.cinco.meta.plugin.gratext.runtime.editor.ActionBarContributor"
		            default="true"
		            «if (!model.iconPath.nullOrEmpty) '''icon="platform:/plugin/«model.projectName»/«model.iconPath»"'''»
		            extensions="«model.fileExtension»"
		            id="«model.package».«model.name»MultiPageEditor"
		            name="«model.name» Multi-Page Editor">
		        </editor>
		    </extension>
		    
		    <extension point="org.eclipse.ui.handlers">
		        <handler
		            class="«extensionFactory»:org.eclipse.xtext.ui.editor.hyperlinking.OpenDeclarationHandler"
		            commandId="org.eclipse.xtext.ui.editor.hyperlinking.OpenDeclaration">
		            <activeWhen>
		                <reference
		                    definitionId="«idPrefix».Editor.opened">
		                </reference>
		            </activeWhen>
		        </handler>
		        <handler
		            class="«extensionFactory»:org.eclipse.xtext.ui.editor.handler.ValidateActionHandler"
		            commandId="«idPrefix».validate">
		         <activeWhen>
		            <reference
		                    definitionId="«idPrefix».Editor.opened">
		            </reference>
		         </activeWhen>
		      	</handler>
		      	<!-- copy qualified name -->
		        <handler
		            class="«extensionFactory»:org.eclipse.xtext.ui.editor.copyqualifiedname.EditorCopyQualifiedNameHandler"
		            commandId="org.eclipse.xtext.ui.editor.copyqualifiedname.EditorCopyQualifiedName">
		            <activeWhen>
						<reference definitionId="«idPrefix».Editor.opened" />
		            </activeWhen>
		        </handler>
		        <handler
		            class="«extensionFactory»:org.eclipse.xtext.ui.editor.copyqualifiedname.OutlineCopyQualifiedNameHandler"
		            commandId="org.eclipse.xtext.ui.editor.copyqualifiedname.OutlineCopyQualifiedName">
		            <activeWhen>
		            	<and>
		            		<reference definitionId="«idPrefix».XtextEditor.opened" />
			                <iterate>
								<adapt type="org.eclipse.xtext.ui.editor.outline.IOutlineNode" />
							</iterate>
						</and>
		            </activeWhen>
		        </handler>
		    </extension>
		    <extension point="org.eclipse.core.expressions.definitions">
		        <definition id="«idPrefix».Editor.opened">
		            <and>
		                <reference definitionId="isActiveEditorAnInstanceOfXtextEditor"/>
		                <with variable="activeEditor">
		                    <test property="org.eclipse.xtext.ui.editor.XtextEditor.languageName" 
		                        value="«idPrefix»" 
		                        forcePluginActivation="true"/>
		                </with>        
		            </and>
		        </definition>
		        <definition id="«idPrefix».XtextEditor.opened">
		            <and>
		                <reference definitionId="isXtextEditorActive"/>
		                <with variable="activeEditor">
		                    <test property="org.eclipse.xtext.ui.editor.XtextEditor.languageName" 
		                        value="«idPrefix»" 
		                        forcePluginActivation="true"/>
		                </with>        
		            </and>
		        </definition>
		    </extension>
		    <extension
		            point="org.eclipse.ui.preferencePages">
		        <page
		            class="«extensionFactory»:org.eclipse.xtext.ui.editor.preferences.LanguageRootPreferencePage"
		            id="«idPrefix»"
		            name="«targetName»">
		            <keywordReference id="«basePackage».keyword_«targetName»"/>
		        </page>
		        <page
		            category="«idPrefix»"
		            class="«extensionFactory»:org.eclipse.xtext.ui.editor.syntaxcoloring.SyntaxColoringPreferencePage"
		            id="«idPrefix».coloring"
		            name="Syntax Coloring">
		            <keywordReference id="«basePackage».keyword_«targetName»"/>
		        </page>
		        <page
		            category="«idPrefix»"
		            class="«extensionFactory»:org.eclipse.xtext.ui.editor.templates.XtextTemplatePreferencePage"
		            id="«idPrefix».templates"
		            name="Templates">
		            <keywordReference id="«basePackage».keyword_«targetName»"/>
		        </page>
		    </extension>
		    <extension
		            point="org.eclipse.ui.propertyPages">
		        <page
		            class="«extensionFactory»:org.eclipse.xtext.ui.editor.preferences.LanguageRootPreferencePage"
		            id="«idPrefix»"
		            name="«targetName»">
		            <keywordReference id="«basePackage».keyword_«targetName»"/>
		            <enabledWhen>
			            <adapt type="org.eclipse.core.resources.IProject"/>
					</enabledWhen>
			        <filter name="projectNature" value="org.eclipse.xtext.ui.shared.xtextNature"/>
		        </page>
		    </extension>
		    <extension
		        point="org.eclipse.ui.keywords">
		        <keyword
		            id="«basePackage».keyword_«targetName»"
		            label="«targetName»"/>
		    </extension>
		    <extension
		         point="org.eclipse.ui.commands">
		      <command
		            description="Trigger expensive validation"
		            id="«idPrefix».validate"
		            name="Validate">
		      </command>
		      <!-- copy qualified name -->
		      <command
		            id="org.eclipse.xtext.ui.editor.copyqualifiedname.EditorCopyQualifiedName"
		            categoryId="org.eclipse.ui.category.edit"
		            description="Copy the qualified name for the selected element"
		            name="Copy Qualified Name">
		      </command>
		      <command
		            id="org.eclipse.xtext.ui.editor.copyqualifiedname.OutlineCopyQualifiedName"
		            categoryId="org.eclipse.ui.category.edit"
		            description="Copy the qualified name for the selected element"
		            name="Copy Qualified Name">
		      </command>
		    </extension>
		    <extension point="org.eclipse.ui.menus">
		        <menuContribution
		            locationURI="popup:#TextEditorContext?after=group.edit">
		             <command
		                 commandId="«idPrefix».validate"
		                 style="push"
		                 tooltip="Trigger expensive validation">
		            <visibleWhen checkEnabled="false">
		                <reference
		                    definitionId="«idPrefix».Editor.opened">
		                </reference>
		            </visibleWhen>
		         </command>  
		         </menuContribution>
		         <!-- copy qualified name -->
		         <menuContribution locationURI="popup:#TextEditorContext?after=copy">
		         	<command commandId="org.eclipse.xtext.ui.editor.copyqualifiedname.EditorCopyQualifiedName" 
		         		style="push" tooltip="Copy Qualified Name">
		            	<visibleWhen checkEnabled="false">
		                	<reference definitionId="«idPrefix».Editor.opened" />
		            	</visibleWhen>
		         	</command>  
		         </menuContribution>
		         <menuContribution locationURI="menu:edit?after=copy">
		         	<command commandId="org.eclipse.xtext.ui.editor.copyqualifiedname.EditorCopyQualifiedName"
		            	style="push" tooltip="Copy Qualified Name">
		            	<visibleWhen checkEnabled="false">
		                	<reference definitionId="«idPrefix».Editor.opened" />
		            	</visibleWhen>
		         	</command>  
		         </menuContribution>
		         <menuContribution locationURI="popup:org.eclipse.xtext.ui.outline?after=additions">
					<command commandId="org.eclipse.xtext.ui.editor.copyqualifiedname.OutlineCopyQualifiedName" 
						style="push" tooltip="Copy Qualified Name">
		         		<visibleWhen checkEnabled="false">
			            	<and>
			            		<reference definitionId="«idPrefix».XtextEditor.opened" />
								<iterate>
									<adapt type="org.eclipse.xtext.ui.editor.outline.IOutlineNode" />
								</iterate>
							</and>
						</visibleWhen>
					</command>
		         </menuContribution>
		    </extension>
		    <extension point="org.eclipse.ui.menus">
				<menuContribution locationURI="popup:#TextEditorContext?endof=group.find">
					<command commandId="org.eclipse.xtext.ui.editor.FindReferences">
						<visibleWhen checkEnabled="false">
		                	<reference definitionId="«idPrefix».Editor.opened">
		                	</reference>
		            	</visibleWhen>
					</command>
				</menuContribution>
			</extension>
			<extension point="org.eclipse.ui.handlers">
			    <handler
		            class="«extensionFactory»:org.eclipse.xtext.ui.editor.findrefs.FindReferencesHandler"
		            commandId="org.eclipse.xtext.ui.editor.FindReferences">
		            <activeWhen>
		                <reference
		                    definitionId="«idPrefix».Editor.opened">
		                </reference>
		            </activeWhen>
		        </handler>
		    </extension>   
		
		<!-- adding resource factories -->
		
			<extension
				point="org.eclipse.emf.ecore.extension_parser">
				<parser
					class="«extensionFactory»:org.eclipse.xtext.resource.IResourceFactory"
					type="«model.fileExtension»DL">
				</parser>
			</extension>
			<extension point="org.eclipse.xtext.extension_resourceServiceProvider">
		        <resourceServiceProvider
		            class="«extensionFactory»:org.eclipse.xtext.ui.resource.IResourceUIServiceProvider"
		            uriExtension="«model.fileExtension»DL">
		        </resourceServiceProvider>
		    </extension>
		    <extension
				point="org.eclipse.emf.ecore.extension_parser">
				<parser
					class="«extensionFactory»:org.eclipse.xtext.resource.IResourceFactory"
					type="«model.fileExtension»">
				</parser>
			</extension>
			<extension point="org.eclipse.xtext.extension_resourceServiceProvider">
		        <resourceServiceProvider
		            class="«extensionFactory»:org.eclipse.xtext.ui.resource.IResourceUIServiceProvider"
		            uriExtension="«model.fileExtension»">
		        </resourceServiceProvider>
		    </extension>
		
		
			<!-- marker definitions for «idPrefix» -->
			<extension
			        id="«model.name.toLowerCase»gratext.check.fast"
			        name="«targetName» Problem"
			        point="org.eclipse.core.resources.markers">
			    <super type="org.eclipse.xtext.ui.check.fast"/>
			    <persistent value="true"/>
			</extension>
			<extension
			        id="«model.name.toLowerCase»gratext.check.normal"
			        name="«targetName» Problem"
			        point="org.eclipse.core.resources.markers">
			    <super type="org.eclipse.xtext.ui.check.normal"/>
			    <persistent value="true"/>
			</extension>
			<extension
			        id="«model.name.toLowerCase»gratext.check.expensive"
			        name="«targetName» Problem"
			        point="org.eclipse.core.resources.markers">
			    <super type="org.eclipse.xtext.ui.check.expensive"/>
			    <persistent value="true"/>
			</extension>
		   <extension
		            point="org.eclipse.ui.preferencePages">
		        <page
		            category="«idPrefix»"
		            class="«extensionFactory»:org.eclipse.xtext.builder.preferences.BuilderPreferencePage"
		            id="«idPrefix».compiler.preferencePage"
		            name="Compiler">
		            <keywordReference id="«basePackage».keyword_«targetName»"/>
		        </page>
		    </extension>
		    <extension
		            point="org.eclipse.ui.propertyPages">
		        <page
		            category="«idPrefix»"
		            class="«extensionFactory»:org.eclipse.xtext.builder.preferences.BuilderPreferencePage"
		            id="«idPrefix».compiler.propertyPage"
		            name="Compiler">
		            <keywordReference id="«basePackage».keyword_«targetName»"/>
		            <enabledWhen>
			            <adapt type="org.eclipse.core.resources.IProject"/>
					</enabledWhen>
			        <filter name="projectNature" value="org.eclipse.xtext.ui.shared.xtextNature"/>
		        </page>
		    </extension>
		
			<!-- Quick Outline -->
			<extension
				point="org.eclipse.ui.handlers">
				<handler 
					class="«extensionFactory»:org.eclipse.xtext.ui.editor.outline.quickoutline.ShowQuickOutlineActionHandler"
					commandId="org.eclipse.xtext.ui.editor.outline.QuickOutline">
					<activeWhen>
						<reference
							definitionId="«idPrefix».Editor.opened">
						</reference>
					</activeWhen>
				</handler>
			</extension>
			<extension
				point="org.eclipse.ui.commands">
				<command
					description="Open the quick outline."
					id="org.eclipse.xtext.ui.editor.outline.QuickOutline"
					name="Quick Outline">
				</command>
			</extension>
			<extension point="org.eclipse.ui.menus">
				<menuContribution
					locationURI="popup:#TextEditorContext?after=group.open">
					<command commandId="org.eclipse.xtext.ui.editor.outline.QuickOutline"
						style="push"
						tooltip="Open Quick Outline">
						<visibleWhen checkEnabled="false">
							<reference definitionId="«idPrefix».Editor.opened"/>
						</visibleWhen>
					</command>
				</menuContribution>
			</extension>
		    <!-- quickfix marker resolution generator for «idPrefix» -->
		    <extension
		            point="org.eclipse.ui.ide.markerResolution">
		        <markerResolutionGenerator
		            class="«extensionFactory»:org.eclipse.xtext.ui.editor.quickfix.MarkerResolutionGenerator"
		            markerType="«basePackage».«model.name.toLowerCase»gratext.check.fast">
		            <attribute
		                name="FIXABLE_KEY"
		                value="true">
		            </attribute>
		        </markerResolutionGenerator>
		        <markerResolutionGenerator
		            class="«extensionFactory»:org.eclipse.xtext.ui.editor.quickfix.MarkerResolutionGenerator"
		            markerType="«basePackage».«model.name.toLowerCase»gratext.check.normal">
		            <attribute
		                name="FIXABLE_KEY"
		                value="true">
		            </attribute>
		        </markerResolutionGenerator>
		        <markerResolutionGenerator
		            class="«extensionFactory»:org.eclipse.xtext.ui.editor.quickfix.MarkerResolutionGenerator"
		            markerType="«basePackage».«model.name.toLowerCase»gratext.check.expensive">
		            <attribute
		                name="FIXABLE_KEY"
		                value="true">
		            </attribute>
		        </markerResolutionGenerator>
		    </extension>
		   	<!-- Rename Refactoring -->
			<extension point="org.eclipse.ui.handlers">
				<handler 
					class="«extensionFactory»:org.eclipse.xtext.ui.refactoring.ui.DefaultRenameElementHandler"
					commandId="org.eclipse.xtext.ui.refactoring.RenameElement">
					<activeWhen>
						<reference
							definitionId="«idPrefix».Editor.opened">
						</reference>
					</activeWhen>
				</handler>
			</extension>
		    <extension point="org.eclipse.ui.menus">
		         <menuContribution
		            locationURI="popup:#TextEditorContext?after=group.edit">
		         <command commandId="org.eclipse.xtext.ui.refactoring.RenameElement"
		               style="push">
		            <visibleWhen checkEnabled="false">
		               <reference
		                     definitionId="«idPrefix».Editor.opened">
		               </reference>
		            </visibleWhen>
		         </command>
		      </menuContribution>
		   </extension>
		   <extension point="org.eclipse.ui.preferencePages">
			    <page
			        category="«idPrefix»"
			        class="«extensionFactory»:org.eclipse.xtext.ui.refactoring.ui.RefactoringPreferencePage"
			        id="«idPrefix».refactoring"
			        name="Refactoring">
			        <keywordReference id="«basePackage».keyword_«targetName»"/>
			    </page>
			</extension>
		</plugin>
	'''
	
	
}