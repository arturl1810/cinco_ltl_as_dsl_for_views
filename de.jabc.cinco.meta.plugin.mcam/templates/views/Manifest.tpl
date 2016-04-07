Manifest-Version: 1.0
Bundle-ManifestVersion: 2
Bundle-Name: ConflictView
Bundle-SymbolicName: ${McamViewBasePackage};singleton:=true
Bundle-Version: 1.0.0
Bundle-Activator: ${McamViewBasePackage}.Activator
Require-Bundle: org.eclipse.ui,
 org.eclipse.core.runtime,
 ${GraphModelProject},
 de.jabc.cinco.meta.plugin.mcam.runtime,
 org.eclipse.ui.workbench,
 org.eclipse.core.resources
Bundle-ActivationPolicy: lazy
Import-Package: info.scce.mcam.framework.adapter,
 info.scce.mcam.framework.modules,
 info.scce.mcam.framework.processes,
 info.scce.mcam.framework.registry,
 info.scce.mcam.framework.registry.change,
 info.scce.mcam.framework.registry.check,
 info.scce.mcam.framework.strategies.merge,
 info.scce.mcam.framework.util,
 org.apache.commons.collections.keyvalue,
 org.eclipse.emf.common.util,
 org.eclipse.emf.ecore.resource,
 org.eclipse.emf.edit.domain,
 org.eclipse.emf.transaction,
 org.eclipse.gef.ui.parts,
 org.eclipse.graphiti.ui.editor;version="0.10.2",
 org.eclipse.ui.views.properties.tabbed


