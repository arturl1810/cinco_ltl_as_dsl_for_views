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
	 org.eclipse.e4.core.di,
	 org.eclipse.emf,
	 org.eclipse.emf.edit.ui,
	 com.google.gson,
	 org.eclipse.ui.views.properties.tabbed,
	 org.eclipse.gef,
	 de.jabc.cinco.meta.util,
	 org.eclipse.graphiti.mm,
	 org.eclipse.graphiti,
	 «graphmodel.graphModel.package».plugin.esdsl
	Bundle-RequiredExecutionEnvironment: JavaSE-1.8
	Bundle-ActivationPolicy: lazy
	Import-Package: de.jabc.cinco.meta.core.referenceregistry,
	 de.jabc.cinco.meta.core.ui.highlight,
	 de.jabc.cinco.meta.core.utils,
	 de.jabc.cinco.meta.core.utils.job,
	 de.jabc.cinco.meta.runtime.xapi,
	 graphicalgraphmodel,
	 graphmodel,
	 «graphmodel.sourceCApiPackage»,
	 «graphmodel.sourceCApiPackage».util,
	 «graphmodel.graphModel.package».esdsl.api.c«graphmodel.graphModel.name.toLowerCase»es,
	 «graphmodel.graphModel.package».esdsl.«graphmodel.graphModel.name.toLowerCase»es,
	 «graphmodel.graphModel.package».«graphmodel.graphModel.name.toLowerCase»,
	 «graphmodel.graphModel.package».graphiti,
	 org.eclipse.emf.common.util,
	 org.eclipse.emf.ecore,
	 org.eclipse.emf.ecore.resource,
	 org.eclipse.emf.ecore.resource.impl,
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