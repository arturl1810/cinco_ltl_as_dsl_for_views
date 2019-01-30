package de.jabc.cinco.meta.core.ge.style.generator.api.templates

import de.jabc.cinco.meta.core.ge.style.generator.runtime.features.CincoRemoveFeature
import de.jabc.cinco.meta.core.ge.style.generator.runtime.provider.CincoFeatureProvider
import de.jabc.cinco.meta.core.ge.style.generator.templates.util.APIUtils
import graphmodel.internal.InternalModelElement
import mgl.ModelElement
import org.eclipse.graphiti.dt.IDiagramTypeProvider
import org.eclipse.graphiti.features.IFeatureProvider
import org.eclipse.graphiti.features.IUpdateFeature
import org.eclipse.graphiti.features.context.impl.RemoveContext
import org.eclipse.graphiti.features.context.impl.UpdateContext
import org.eclipse.graphiti.mm.pictograms.Diagram
import org.eclipse.graphiti.mm.pictograms.PictogramElement
import org.eclipse.graphiti.platform.IDiagramBehavior
import org.eclipse.graphiti.ui.editor.DiagramBehavior
import org.eclipse.graphiti.ui.services.GraphitiUi

import static extension de.jabc.cinco.meta.core.utils.MGLUtil.*

class CModelElementTmpl extends APIUtils {
	
	
def getUpdateContent(ModelElement me) '''
public void update() {
	if (getInternalElement() == null || getInternalElement().getRootElement() == null)
		return;
	«IFeatureProvider.name» fp = getFeatureProvider();
	«Diagram.name» diagram = getDiagram();
	if (fp != null && diagram != null) try {
		«PictogramElement.name» pe = getPictogramElement();
		if (pe != null) {
			«UpdateContext.name» uc = new «UpdateContext.name»(getPictogramElement());
			«IUpdateFeature.name» uf = fp.getUpdateFeature(uc);
			if (fp instanceof «CincoFeatureProvider.name») {
				((«CincoFeatureProvider.name») fp).executeFeature(uf, uc);
			}
		}
	} catch («NullPointerException.name» e) {
		e.printStackTrace();
		return;
	}
}
'''

def getDeleteContent(ModelElement me) '''
«IF !me.isIsAbstract»
@Override
public void delete(){
	«IFeatureProvider.name» fp = getFeatureProvider();
	«InternalModelElement.name» internal = getInternalElement();
	super.delete();
	«RemoveContext.name» rc = new «RemoveContext.name»(this.getPictogramElement());
	«CincoRemoveFeature.name» rf = new «CincoRemoveFeature.name»(fp);
«««	internal.eAdapters().remove(«me.packageNameEContentAdapter».«me.fuName»EContentAdapter.getInstance());
	if (rf.canRemove(rc)) {
		if (fp instanceof «CincoFeatureProvider.name»)
			((«CincoFeatureProvider.name») fp).executeFeature(rf,rc);
«««		rf.remove(rc);
	}
}
«ENDIF»
'''

def getHighlightContent(ModelElement me) '''
@Override
public void highlight() {
«««	«Diagram.name» d = («Diagram.name») this.getDiagram();
«««	«CincoFeatureProvider.name» provider = («CincoFeatureProvider.name») «GraphitiUi.name».getExtensionManager().createFeatureProvider(d);
	«IDiagramBehavior.name» idb = «me.packageName».«me.graphModel.fuName»GraphitiUtils.getInstance().getDTP().getDiagramBehavior();
	if (idb instanceof «DiagramBehavior.name») {
		«DiagramBehavior.name» db = («DiagramBehavior.name») idb;
		db.setPictogramElementForSelection(getPictogramElement());
		db.selectBufferedPictogramElements();
	}
}
'''

def doGenerateImpl(ModelElement me)'''
package «me.packageNameAPI»;

public «IF me.isIsAbstract»abstract «ENDIF»class «me.fuCName» extends «me.fqBeanImplName» 
	«IF !me.allSuperTypes.empty» implements «FOR st: me.allSuperTypes SEPARATOR ","» «st.fqBeanName» «ENDFOR» «ENDIF»{
	
	private «PictogramElement.name» pe;
	
	«me.constructor»
	
	public void setPictogramElement(«me.pictogramElementReturnType» pe) {
		this.pe = pe;
	}
	
	
	private «IFeatureProvider.name» getFeatureProvider() {
		«Diagram.name» diagram = getDiagram();
		if (diagram != null)
			return «GraphitiUi.name».getExtensionManager().createFeatureProvider(diagram);
		
		«IDiagramTypeProvider.name» dtp = «GraphitiUi.name».getExtensionManager().createDiagramTypeProvider("«me.dtpId»");
		return dtp.getFeatureProvider();
	}
	
}
'''
	
} 