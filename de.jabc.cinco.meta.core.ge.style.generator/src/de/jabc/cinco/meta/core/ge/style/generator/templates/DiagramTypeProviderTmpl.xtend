package de.jabc.cinco.meta.core.ge.style.generator.templates

import de.jabc.cinco.meta.core.utils.generator.GeneratorUtils
import mgl.GraphModel
import org.eclipse.graphiti.dt.AbstractDiagramTypeProvider
import org.eclipse.graphiti.dt.IDiagramTypeProvider
import org.eclipse.graphiti.tb.IToolBehaviorProvider

class DiagramTypeProviderTmpl extends GeneratorUtils {
	
/**
 * Generates the template for the {@link IDiagramTypeProvider}
 * 
 * @param gm The Graphmodel for information retrieval
 */
def generateDiagramTypeProvider(GraphModel gm)'''
package «gm.packageName»;
	
public class «gm.fuName»DiagramTypeProvider extends «AbstractDiagramTypeProvider.name»{
	
	private «IToolBehaviorProvider.name»[] tbProviders;
	
	public «gm.fuName»DiagramTypeProvider() {
		super();
		setFeatureProvider(new «gm.fuName»FeatureProvider(this));
		«gm.fuName»GraphitiUtils.getInstance().loadImages();
		«gm.fuName»GraphitiUtils.getInstance().setDTP(this);
		«gm.fqPropertyView».initEStructuralFeatureInformation();
«««		//registerImages();
	}

	@Override
	public «IToolBehaviorProvider.name»[] getAvailableToolBehaviorProviders() {
		if (tbProviders == null) {
			tbProviders = 
				new «IToolBehaviorProvider.name»[] {new «gm.fuName»ToolBehaviorProvider(this)};
		}
		return tbProviders;
	}
	
«««	private void registerImages() {
«««		«CincoImageProvider.name» ip = «CincoImageProvider.name».getImageProvider();
«««		«FOR Entry<String, URL> e : MGLUtils.getAllImages(gm).entrySet»
«««		ip.registerImage("«e.key»","«e.value»");
«««		«ENDFOR»
«««	}
}
'''
	
	
}