package de.jabc.cinco.meta.core.ge.style.generator.templates

import de.jabc.cinco.meta.core.ge.style.generator.templates.util.GeneratorUtils
import org.eclipse.graphiti.tb.IToolBehaviorProvider
import de.jabc.cinco.meta.core.ge.style.model.provider.CincoImageProvider
import de.jabc.cinco.meta.core.utils.CincoUtils
import de.jabc.cinco.meta.core.utils.MGLUtils
import java.util.Map.Entry
import org.eclipse.graphiti.dt.AbstractDiagramTypeProvider
import java.net.URL

class DiagramTypeProviderTmpl extends GeneratorUtils {
	
def generateDiagramTypeProvider(mgl.GraphModel gm)'''
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