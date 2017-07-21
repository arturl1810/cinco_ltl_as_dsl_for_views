package de.jabc.cinco.meta.plugin.pyro.canvas

import de.jabc.cinco.meta.core.utils.CincoUtils
import de.jabc.cinco.meta.plugin.pyro.util.FileGenerator
import de.jabc.cinco.meta.plugin.pyro.util.GeneratorCompound
import org.eclipse.core.resources.IProject

class Generator extends FileGenerator {
	
	new(String base) {
		super(base)
	}
	
	def generator(GeneratorCompound gc,IProject iProject) {
		
		//create shapes
		{
			gc.graphMopdels.forEach[g|{
				//web.asset.js.graphmodel
				val path = "web/assets/js/"+g.name
				val gen = new Shapes(gc,g)
				val styles = CincoUtils.getStyles(g, iProject)
				generateFile(path,
					gen.fileNameShapes(g),
					gen.contentShapes(styles)
				)
			}]
		}
		//create controller
		{
			gc.graphMopdels.forEach[g|{
				//web.asset.js.graphmodel.controller
				val path = "web/assets/js/"+g.name
				val gen = new Controller(gc)
				val styles = CincoUtils.getStyles(g, iProject)
				generateFile(path,
					gen.fileNameController,
					gen.contentController(g,styles)
				)
			}]
		}
	}
}