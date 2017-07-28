package de.jabc.cinco.meta.core.ge.style.generator.api.templates

import de.jabc.cinco.meta.core.ge.style.generator.runtime.provider.CincoFeatureProvider
import de.jabc.cinco.meta.core.ge.style.generator.templates.util.APIUtils
import mgl.ModelElement
import org.eclipse.graphiti.features.IFeatureProvider
import org.eclipse.graphiti.features.IRemoveFeature
import org.eclipse.graphiti.features.IUpdateFeature
import org.eclipse.graphiti.features.context.impl.RemoveContext
import org.eclipse.graphiti.features.context.impl.UpdateContext
import org.eclipse.graphiti.features.impl.DefaultRemoveFeature
import org.eclipse.graphiti.mm.pictograms.PictogramElement
import org.eclipse.graphiti.mm.pictograms.Shape
import org.eclipse.graphiti.ui.services.GraphitiUi

class CModelElementTmpl extends APIUtils {
	
	
def getUpdateContent(ModelElement me) '''
public void update() {
	try {
		«IFeatureProvider.name» fp = getFeatureProvider();
		«UpdateContext.name» uc = new «UpdateContext.name»(getPictogramElement());
		«IUpdateFeature.name» uf = fp.getUpdateFeature(uc);
		if (fp instanceof «CincoFeatureProvider.name») {
			((«CincoFeatureProvider.name») fp).executeFeature(uf, uc);
		}
	} catch («NullPointerException.name» e) {
		e.printStackTrace();
		return;
	}
}
'''

def getDeleteContent(ModelElement me) '''
@Override
public void delete(){
	«RemoveContext.name» rc = new «RemoveContext.name»(this.pe);
	
	«IFeatureProvider.name» fp = getFeatureProvider();
	«IRemoveFeature.name» rf = new «DefaultRemoveFeature.name»(fp);
	getInternalElement().eAdapters().remove(«me.packageNameEContentAdapter».«me.fuName»EContentAdapter.getInstance());
	if (rf.canRemove(rc)) {
		rf.remove(rc);
		super.delete();
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
		return «GraphitiUi.name».getExtensionManager().createFeatureProvider(getDiagram());
	}
	
}
'''
	
} 