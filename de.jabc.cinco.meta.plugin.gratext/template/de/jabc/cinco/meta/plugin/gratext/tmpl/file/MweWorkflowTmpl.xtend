package de.jabc.cinco.meta.plugin.gratext.tmpl.file

import de.jabc.cinco.meta.plugin.template.FileTemplate
import java.util.Map
import java.util.Set
import mgl.GraphModel
import mgl.ModelElement
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EClassifier

class MweWorkflowTmpl extends FileTemplate {
	
	Map<String,String> genModelURIs = newHashMap
	Map<String,String> genPackages = newHashMap
	Set<String> referencedNsURIs = newHashSet
	
	String projectName
	String projectBasePackage
	
	new(String projectName, String projectBasePackage) {
		System.err.println("New MweWorkflowTmpl: " + projectName)
		this.projectName = projectName
		this.projectBasePackage = projectBasePackage
	}
	
	def targetName() '''«model.name»Gratext'''
	
	override getTargetFileName() '''«model.name»Gratext.mwe2'''
	
	override init() {
		model.importedGraphModels.forEach[
			val pkg = if (!package.nullOrEmpty) '''«package».''' else ""
			genPackages.put(nsURI,
				'''«pkg»«name.toLowerCase».«name.toLowerCase.toFirstUpper»Package''')
			genModelURIs.put(nsURI,
				'''platform:/resource/«model.projectName»/src-gen/model/«name».genmodel''')
		]
		
		model.importedGenModels.forEach[ genModel |
			genModel.genPackages.forEach[
				val pkg = if (!basePackage.nullOrEmpty) '''«basePackage».''' else ""
				genPackages.put(NSURI,
					'''«pkg»«getEcorePackage.name».«prefix»Package''')
				genModelURIs.put(NSURI,
					URI.createPlatformResourceURI(eResource.URI.toPlatformString(false), false).toString())
			]
		]
		
		referencedNsURIs += model.primeReferences.map[switch it:type {
			GraphModel: nsURI
			ModelElement: graphModel.nsURI
			EClassifier: EPackage.nsURI
		}].filter[it != model.nsURI].filterNull
	}
	
	def genPackageRule(String pkg) '''
		registerGeneratedEPackage = "«pkg»"
	'''

	def genURIRule(String uri) '''
		registerGenModelFile = "«uri»"
	'''
	
	def toPath(String pkg) {
		pkg?.replace('.', '/')
	}
	
	override template() '''	
		module «package»
		
		import org.eclipse.emf.mwe.utils.*
		import org.eclipse.xtext.generator.*
		import org.eclipse.xtext.ui.generator.*
		
		var grammarURI = "classpath:/«package.toPath»/«GrammarTmpl.getTargetFileName»"
		var projectName = "«projectBasePackage»"
		var runtimeProject = "../${projectName}"
		var generateXtendStub = true
		
		
		Workflow { 
			bean = StandaloneSetup {
				scanClassPath  = true
				platformUri = "${runtimeProject}/.."
				registerGeneratedEPackage = "«projectBasePackage».«targetName»Package"
				registerGenModelFile = "platform:/resource/«projectName»/model/«projectBasePackage.toPath»/«GenmodelTmpl.getTargetFileName»"
				«referencedNsURIs.map[genPackages.get(it)].filterNull.map[genPackageRule].join('\n')»
				«referencedNsURIs.map[genModelURIs.get(it)].filterNull.map[genURIRule].join('\n')»
			}
		
			component = DirectoryCleaner {
				directory = "${runtimeProject}/src-gen"
			}
		
			component = DirectoryCleaner {
				directory = "${runtimeProject}.ui/src-gen"
			}
		
			component = Generator {
				pathRtProject = runtimeProject
				pathUiProject = "${runtimeProject}.ui"
		«««		pathTestProject = "${runtimeProject}.tests"
				projectNameRt = projectName
				projectNameUi = "${projectName}.ui"
				language = auto-inject {
					uri = grammarURI
		
					// Java API to access grammar elements (required by several other fragments)
					fragment = grammarAccess.GrammarAccessFragment auto-inject {}
		
					// generates Java API for the generated EPackages
					// fragment = ecore.EcoreGeneratorFragment auto-inject {}
		
					// the Ecore2Xtext specific terminal converter
					fragment = ecore2xtext.Ecore2XtextValueConverterServiceFragment auto-inject {}
		
					// serializer 2.0
					fragment = serializer.SerializerFragment auto-inject {
						//generateStub = false
					}
		
					// the old serialization component
					// fragment = parseTreeConstructor.ParseTreeConstructorFragment auto-inject {}
		
					// a custom ResourceFactory for use with EMF 
					fragment = resourceFactory.ResourceFactoryFragment auto-inject {}
		
					// the Antlr parser
					fragment = parser.antlr.XtextAntlrGeneratorFragment auto-inject {
						options = {
							classSplitting = true
						}
					}
		
					// Xtend-based API for validation 
					fragment = validation.ValidatorFragment auto-inject {
					// composedCheck = "org.eclipse.xtext.validation.ImportUriValidator"
					// composedCheck = "org.eclipse.xtext.validation.NamesAreUniqueValidator"
					}
		
					// old scoping and exporting API 
					// fragment = scoping.ImportNamespacesScopingFragment auto-inject {}
					// fragment = exporting.QualifiedNamesFragment auto-inject {}
		
					// scoping and exporting API
					fragment = scoping.ImportURIScopingFragment auto-inject {}
					fragment = exporting.SimpleNamesFragment auto-inject {}
					fragment = builder.BuilderIntegrationFragment auto-inject {}		
		
					// generator API
					fragment = generator.GeneratorFragment auto-inject {}
		
					// formatter API 
					// fragment = formatting.FormatterFragment auto-inject {}
					fragment = ecore2xtext.FormatterFragment auto-inject {}
		
					// labeling API 
					fragment = labeling.LabelProviderFragment auto-inject {}
		
					// outline API 
		            fragment = outline.OutlineTreeProviderFragment auto-inject {}
		            fragment = outline.QuickOutlineFragment auto-inject {}
		
					// quickfix API
					fragment = quickfix.QuickfixProviderFragment auto-inject {}
		
					//content assist API 
					fragment = contentAssist.ContentAssistFragment auto-inject {}
		
					// antlr parser generator tailored for content assist 
					fragment = parser.antlr.XtextAntlrUiGeneratorFragment auto-inject {
						options = {
							classSplitting = true
						}
					}
					
					// generates junit test support classes into Generator#pathTestProject
					// fragment = junit.Junit4Fragment auto-inject {}
		
					// project wizard (optional) 
					// fragment = projectWizard.SimpleProjectWizardFragment auto-inject {
					//		generatorProjectName = "${projectName}.generator" 
					// }
		
					// rename refactoring
					fragment = refactoring.RefactorElementNameFragment auto-inject {}
		
					// provides the necessary bindings for java types integration
					fragment = types.TypesGeneratorFragment auto-inject {}
					
					// generates the required bindings only if the grammar inherits from Xbase
					fragment = xbase.XbaseGeneratorFragment auto-inject {}
					
					// generates the required bindings only if the grammar inherits from Xtype
					fragment = xbase.XtypeGeneratorFragment auto-inject {}
		
					// provides a preference page for template proposals
					fragment = templates.CodetemplatesGeneratorFragment auto-inject {}
		
					// provides a compare view
		            fragment = compare.CompareFragment auto-inject {}
				}
			}
		}
	'''
	
}