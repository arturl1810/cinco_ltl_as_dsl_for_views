package de.jabc.cinco.meta.plugin.pyro.backend

import de.jabc.cinco.meta.core.utils.CincoUtils
import de.jabc.cinco.meta.plugin.pyro.backend.connector.DataConnector
import de.jabc.cinco.meta.plugin.pyro.backend.graphmodel.command.GraphModelCommandExecuter
import de.jabc.cinco.meta.plugin.pyro.backend.graphmodel.command.GraphModelControllerBundle
import de.jabc.cinco.meta.plugin.pyro.backend.graphmodel.controller.GraphModelController
import de.jabc.cinco.meta.plugin.pyro.backend.graphmodel.rest.GraphModelRestTO
import de.jabc.cinco.meta.plugin.pyro.util.FileGenerator
import de.jabc.cinco.meta.plugin.pyro.util.GeneratorCompound
import de.jabc.cinco.meta.plugin.pyro.util.MGLExtension
import org.eclipse.core.resources.IProject

class Generator extends FileGenerator {
	
	protected extension MGLExtension = new MGLExtension
	
	new(String base) {
		super(base)
	}
	
	def generator(GeneratorCompound gc,IProject iProject) {
		
		//create data connector
		{
			//dywa-app.app-connector.target.generated-sources.info.scce.pyro.data
			val path = "dywa-app/app-connector/target/generated-sources/info/scce/pyro/data"
			val gen = new DataConnector(gc)
			generateJavaFile(path,
				gen.fileNameDataConnector,
				gen.contentDataConnector
			)
		}
		//create graphmodel rest TOs
		{
			//dywa-app.app-connector.target.generated-sources.info.scce.pyro.data
			val path = "dywa-app/app-business/target/generated-sources/info/scce/pyro/"
			val gen = new GraphModelRestTO(gc)
			gc.graphMopdels.forEach[g|{
				val graphPath = path + g.name+"/rest"
				generateJavaFile(graphPath,
						gen.filename(g),
						gen.content(g,g)
					)
				g.elementsAndTypes.forEach[t|{
					generateJavaFile(graphPath,
						gen.filename(t),
						gen.content(t,g)
					)
				}]
				
			}]
		}
		
		//create graphmodel rest controller
		{
			//dywa-app.app-connector.target.generated-sources.info.scce.pyro.core
			val path = "dywa-app/app-business/target/generated-sources/info/scce/pyro/core"
			gc.graphMopdels.forEach[g|{
				val gen = new GraphModelController(gc)
				generateJavaFile(path,
					gen.filename(g),
					gen.content(g)
				)
			}]
		}
		//create executer
		{
			//dywa-app.app-connector.target.generated-sources.info.scce.pyro.core.command
			val path = "dywa-app/app-business/target/generated-sources/info/scce/pyro/core/command"
			gc.graphMopdels.forEach[g|{
				val styles = CincoUtils.getStyles(g, iProject)
				val gen = new GraphModelCommandExecuter(gc)
				generateJavaFile(path,
					gen.filename(g),
					gen.content(g,styles)
				)
				val gen2 = new GraphModelControllerBundle(gc)
				generateJavaFile(path,
					gen2.filename(g),
					gen2.content(g)
				)
			}]
		}

	}
	
}