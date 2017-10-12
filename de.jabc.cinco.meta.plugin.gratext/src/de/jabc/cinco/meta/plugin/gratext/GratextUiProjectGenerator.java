package de.jabc.cinco.meta.plugin.gratext;

import java.util.HashSet;
import java.util.List;
import java.util.Set;

import de.jabc.cinco.meta.plugin.gratext.template.GratextEditorTemplate;
import de.jabc.cinco.meta.plugin.gratext.template.PageAwareDiagramEditorTemplate;
import de.jabc.cinco.meta.plugin.gratext.template.ProposalProviderTemplate;
import de.jabc.cinco.meta.plugin.gratext.template.UiPluginXmlTemplate;

public class GratextUiProjectGenerator extends EmptyProjectGenerator {

	@Override
	public String getProjectSuffix() {
		return "Gratext";
	}
	
	public String getProjectAcronym() {
		return "gratext.ui";
	}
	
	@Override protected List<String> getSourceFolders() {
		return list("src", "src-gen", "xtend-gen");
	};
	@Override protected Set<String> getRequiredBundles() {
		return new HashSet<>(list(
			getModelDescriptor().getBasePackage() + ".gratext",
			"de.jabc.cinco.meta.plugin.gratext.runtime",
//			getModelProject().getName() + ".editor.graphiti",
			getModelDescriptor().getBasePackage() + ".editor.graphiti",
			"org.eclipse.graphiti",
			"org.eclipse.graphiti.ui"
		));
	};
	@Override protected List<String> getNatures() {
		return list(
			"org.eclipse.pde.PluginNature",
			"org.eclipse.xtext.ui.shared.xtextNature"
		);
	}
	@Override protected java.util.List<String> getManifestExtensions() {
		return list("Bundle-ActivationPolicy: lazy\n"
				+ "Import-Package: org.apache.log4j,\n"
				+ " org.eclipse.emf.common.util,\n"
				+ " org.eclipse.emf.ecore.resource,\n"
				+ " org.eclipse.emf.edit.domain,\n"
				+ " org.eclipse.emf.transaction,\n"
				+ " org.eclipse.emf.transaction.impl,\n"
				+ " org.eclipse.emf.transaction.util,\n"
				+ " org.eclipse.gef,\n"
				+ " org.eclipse.graphiti.ui.editor,\n"
				+ " org.eclipse.ui.editors.text,\n"
				+ " org.eclipse.ui.ide,\n"
				+ " org.eclipse.ui.part,\n"
				+ " org.eclipse.ui.views.properties.tabbed,\n"
				+ " org.eclipse.xtext.ui.editor,\n"
				+ " de.jabc.cinco.meta.core.ui.highlight,\n"
				+ " de.jabc.cinco.meta.core.ui.editor"
		);
	}
	
	@Override protected List<String> getBuildPropertiesBinIncludes() {
		return list("plugin.xml");
	}
	
	@Override protected void createFiles() {
		inSrcFolder("src")
			.inPackage(getProjectDescriptor().getBasePackage())
			.createFile(getProjectDescriptor().getTargetName() + "Editor.java")
			.withContent(GratextEditorTemplate.class);

		inSrcFolder("src")
			.inPackage(getProjectDescriptor().getBasePackage())
			.createFile("PageAware" + getModelDescriptor().getName() + "DiagramEditor.java")
			.withContent(PageAwareDiagramEditorTemplate.class);

		inSrcFolder("src")
			.inPackage(getProjectDescriptor().getBasePackage() + ".contentassist")
			.createFile(getProjectDescriptor().getTargetName() + "ProposalProvider.xtend")
			.withContent(ProposalProviderTemplate.class);
		
		createFile("plugin.xml")
			.withContent(UiPluginXmlTemplate.class);
	}
	
}
