package de.jabc.cinco.meta.plugin.executer.generator.tracer

import de.jabc.cinco.meta.plugin.executer.generator.tracer.MainTemplate
import de.jabc.cinco.meta.plugin.executer.compounds.ExecutableGraphmodel

class ManifestTemplate extends MainTemplate {
	
	new(ExecutableGraphmodel graphmodel) {
		super(graphmodel)
	}
	
	override fileName() {
		return "MANIFEST.MF"
	}
	
	override create(ExecutableGraphmodel graphmodel)
	'''
	Manifest-Version: 1.0
	Bundle-ManifestVersion: 2
	Bundle-Name: Tracer
	Bundle-SymbolicName: «graphmodel.tracerPackage»;singleton:=true
	Bundle-Version: 1.0.0.qualifier
	Bundle-Activator: «graphmodel.tracerPackage».Activator
	Require-Bundle: org.eclipse.ui,
	 org.eclipse.core.runtime,
	 org.eclipse.core.resources,
	 org.eclipse.ui,
	 org.eclipse.core.runtime,
	 org.eclipse.ui.workbench,
	 org.eclipse.e4.core.di
	Bundle-RequiredExecutionEnvironment: JavaSE-1.8
	Bundle-ActivationPolicy: lazy
	Import-Package: de.jabc.cinco.meta.core.mgl.model,
	 de.jabc.cinco.meta.core.referenceregistry,
	 de.jabc.cinco.meta.core.ui.highlight,
	 de.jabc.cinco.meta.core.utils,
	 de.jabc.cinco.meta.core.utils.eapi,
	 de.jabc.cinco.meta.core.utils.job,
	 graphicalgraphmodel,
	 graphmodel,
	 «graphmodel.sourceCApiPackage»,
	 «graphmodel.sourceCApiPackage».util,
	 «graphmodel.CApiPackage»,
	 «graphmodel.graphModel.package».esdsl.graphiti,
	 «graphmodel.apiPackage»,
	 «graphmodel.graphModel.package».graphiti,
	 «graphmodel.graphModel.package».«graphmodel.graphModel.name.toLowerCase»,
	 org.eclipse.emf.common.util,
	 org.eclipse.emf.ecore,
	 org.eclipse.emf.ecore.resource,
	 org.eclipse.emf.ecore.resource.impl,
	 org.eclipse.graphiti.mm.pictograms;version="0.11.2",
	 org.eclipse.graphiti.util;version="0.12.2",
	 org.eclipse.pde.internal.ui.util,
	 org.eclipse.ui.model
	Export-Package: «graphmodel.tracerPackage»,
	 «graphmodel.tracerPackage».extension,
	 «graphmodel.tracerPackage».match.model,
	 «graphmodel.tracerPackage».runner.model,
	 «graphmodel.tracerPackage».stepper.model,
	 «graphmodel.tracerPackage».stepper.utils
	
	'''
	
}