Manifest-Version: 1.0
Bundle-ManifestVersion: 2
Bundle-Name: ConflictView
Bundle-SymbolicName: ${ConflictViewPackage};singleton:=true
Bundle-Version: 1.0.0.qualifier
Bundle-Activator: ${ConflictViewPackage}.Activator
Require-Bundle: org.eclipse.ui,
 org.eclipse.core.runtime,
 info.scce.cinco.product.flowgraph.mcam,
 org.eclipse.ui.workbench,
 org.eclipse.core.resources
Bundle-RequiredExecutionEnvironment: JavaSE-1.7
Bundle-ActivationPolicy: lazy
Import-Package: info.scce.mcam.framework.adapter,
 info.scce.mcam.framework.modules,
 info.scce.mcam.framework.processes,
 info.scce.mcam.framework.registry,
 info.scce.mcam.framework.registry.change,
 info.scce.mcam.framework.registry.check,
 info.scce.mcam.framework.strategies.merge,
 info.scce.mcam.framework.util

