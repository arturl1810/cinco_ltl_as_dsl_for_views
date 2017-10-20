package de.jabc.cinco.meta.core.ge.style.generator.runtime.editor

import de.jabc.cinco.meta.core.ge.style.generator.runtime.layout.EdgeLayout
import de.jabc.cinco.meta.core.ui.editor.InnerStateAwareness
import de.jabc.cinco.meta.core.ui.editor.PageAwareness
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.gef.ContextMenuProvider
import org.eclipse.gef.editparts.ZoomManager
import org.eclipse.gef.ui.palette.PaletteViewerProvider
import org.eclipse.graphiti.dt.IDiagramTypeProvider
import org.eclipse.graphiti.mm.pictograms.Diagram
import org.eclipse.graphiti.ui.editor.DefaultPaletteBehavior
import org.eclipse.graphiti.ui.editor.DiagramBehavior
import org.eclipse.graphiti.ui.editor.IDiagramContainerUI
import org.eclipse.graphiti.ui.editor.IDiagramEditorInput
import org.eclipse.graphiti.ui.internal.config.IConfigurationProviderInternal
import org.eclipse.graphiti.ui.platform.IConfigurationProvider
import org.eclipse.ui.IEditorPart
import de.jabc.cinco.meta.core.ui.editor.PageAwareEditorInput

@SuppressWarnings("restriction")
class PageAwareDiagramBehavior extends DiagramBehavior implements InnerStateAwareness, PageAwareness {
	
	new(IDiagramContainerUI diagramContainer) {
		super(diagramContainer)
	}

	override initActionRegistry(ZoomManager zoomManager) {
		super.initActionRegistry(zoomManager)
		for (EdgeLayout value : EdgeLayout::values()) {
			registerAction(value.createAction(getParentPart()))
		}
	}

	override protected IConfigurationProvider createConfigurationProvider(IDiagramTypeProvider diagramTypeProvider) {
		return new CincoConfigurationProvider(this, diagramTypeProvider)
	}

	override protected ContextMenuProvider createContextMenuProvider() {
		return new CincoDiagramEditorContextMenuProvider(getDiagramContainer().getGraphicalViewer(),
			getDiagramContainer().getActionRegistry(), getConfigurationProvider())
	}

	override protected DefaultPaletteBehavior createPaletteBehaviour() {
		return new DefaultPaletteBehavior(this) {
			override protected PaletteViewerProvider createPaletteViewerProvider() {
				var IDiagramContainerUI editor = getDiagramContainer()
				if (editor instanceof CincoDiagramEditor)
					return new CincoPaletteViewerProvider((editor as CincoDiagramEditor))
				else return super.createPaletteViewerProvider()
			}
		}
	}

	override protected CincoPersistencyBehavior createPersistencyBehavior() {
		return new CincoPersistencyBehavior(this)
	}

	override protected CincoUpdateBehavior createUpdateBehavior() {
		return new CincoUpdateBehavior(this)
	}

	override protected void configureGraphicalViewer() {
		super.configureGraphicalViewer()
		var IConfigurationProviderInternal configurationProvider = (this.
			getConfigurationProvider() as IConfigurationProviderInternal)
		configurationProvider.setContextButtonManager(
			new CincoContextButtonManagerForPad(this, configurationProvider.getResourceRegistry()))
	}

	override protected CincoPersistencyBehavior getPersistencyBehavior() {
		return (super.getPersistencyBehavior() as CincoPersistencyBehavior)
	}

	override CincoUpdateBehavior getUpdateBehavior() {
		return (super.getUpdateBehavior() as CincoUpdateBehavior)
	}

	override Resource getInnerState() {
		var IDiagramEditorInput input = getInput()
		if(input instanceof PageAwareEditorInput) return ((getInput() as PageAwareEditorInput)).getInnerStateSupplier().
			get() else return null
	}

	override void handlePageActivated(IEditorPart prevEditor) {
		getUpdateBehavior().setResourceChanged(false)
		refreshContent()
	}

	override void handleInnerStateChanged() {
		if(getDiagramTypeProvider() !== null) refreshContent()
		getUpdateBehavior().setResourceChanged(false)
		getPersistencyBehavior().flushCommandStack()
	}

	override void handlePageDeactivated(IEditorPart nextEditor) {
		/* do nothing */
	}

	override void handleNewInnerState() {
		/* do nothing */
	}

	override void handleSaved() {
		getUpdateBehavior().setResourceChanged(false)
		getPersistencyBehavior().clearDirtyState()
	}

	override protected void setInput(IDiagramEditorInput input) {
		super.setInput(input)
		var Diagram diagram = getDiagramTypeProvider().getDiagram()
		if (diagram instanceof LazyDiagram) {
			((diagram as LazyDiagram)).setDiagramBehavior(this)
		}
	}
}
