package de.jabc.cinco.meta.plugin.pyro.frontend

import de.jabc.cinco.meta.core.utils.CincoUtil
import de.jabc.cinco.meta.plugin.pyro.frontend.deserializer.Deserializer
import de.jabc.cinco.meta.plugin.pyro.frontend.model.Model
import de.jabc.cinco.meta.plugin.pyro.frontend.pages.editor.EditorComponent
import de.jabc.cinco.meta.plugin.pyro.frontend.pages.editor.canvas.CanvasComponent
import de.jabc.cinco.meta.plugin.pyro.frontend.pages.editor.canvas.graphs.graphmodel.GraphmodelComponent
import de.jabc.cinco.meta.plugin.pyro.frontend.pages.editor.explorer.graphentry.create.CreateFileComponent
import de.jabc.cinco.meta.plugin.pyro.frontend.pages.editor.map.MapComponent
import de.jabc.cinco.meta.plugin.pyro.frontend.pages.editor.palette.PaletteComponent
import de.jabc.cinco.meta.plugin.pyro.frontend.pages.editor.palette.graphs.graphmodel.PaletteBuilder
import de.jabc.cinco.meta.plugin.pyro.frontend.pages.editor.palette.list.ListComponent
import de.jabc.cinco.meta.plugin.pyro.frontend.pages.editor.properties.graphs.graphmodel.GraphmodelTree
import de.jabc.cinco.meta.plugin.pyro.frontend.pages.editor.properties.graphs.graphmodel.IdentifiableElementPropertyComponent
import de.jabc.cinco.meta.plugin.pyro.frontend.pages.editor.properties.graphs.graphmodel.PropertyComponent
import de.jabc.cinco.meta.plugin.pyro.frontend.pages.editor.properties.tree.TreeComponet
import de.jabc.cinco.meta.plugin.pyro.frontend.pages.editor.properties.tree.node.TreeNodeComponent
import de.jabc.cinco.meta.plugin.pyro.frontend.service.GraphService
import de.jabc.cinco.meta.plugin.pyro.util.FileGenerator
import de.jabc.cinco.meta.plugin.pyro.util.FileHandler
import de.jabc.cinco.meta.plugin.pyro.util.GeneratorCompound
import de.jabc.cinco.meta.plugin.pyro.util.MGLExtension
import mgl.UserDefinedType
import org.eclipse.core.resources.IProject
import de.jabc.cinco.meta.plugin.pyro.frontend.pages.editor.explorer.graphentry.GraphEntryComponent

class Generator extends FileGenerator{
	
	protected extension MGLExtension = new MGLExtension
	
	new(String base) {
		super(base)
	}
	
	def generate(GeneratorCompound gc,IProject iProject)
	{
		
		val graphModels = gc.graphMopdels
		
		{
			//web
			val path = "web"
			val gen = new Main(gc)
			generateFile(path,
				gen.fileNameMain,
				gen.contentMain
			)
		}
		{
			//web
			val path = "web"
			val gen = new Index(gc)
			generateFile(path,
				gen.fileNameIndex,
				gen.contentIndex
			)
		}

		{
			//lib.deserialzer
			val path = "lib/deserializer"
			val gen = new Deserializer(gc)
			graphModels.forEach[g|{
				generateFile(path,
					gen.fileNameGraphmodelPropertyDeserializer(g.name),
					gen.contentGraphmodelPropertyDeserializer(g)
				)
			}]
			generateFile(path,
				gen.fileNamePropertyDeserializer(),
				gen.contentPropertyDeserializer()
			)
		}
		{
			//lib.model
			val path = "lib/model"
			val gen = new Model(gc)
			generateFile(path,
				gen.fileNameDispatcher,
				gen.contentDispatcher
			)
			graphModels.forEach[g|{
				val styles =CincoUtil.getStyles(g, iProject)
				generateFile(path,
					gen.fileNameGraphModel(g.name),
					gen.contentGraphmodel(g,styles)
				)
			}]
		}
		{
			//lib.editor
			val path = "lib/pages/editor"
			val gen = new EditorComponent(gc)
			generateFile(path,
				gen.fileNameEditorComponent,
				gen.contentEditorComponent
			)		
		}
		{
			//lib.pages.editor.canvas.graphs.graphmodel
			graphModels.forEach[g|{
				val path = "lib/pages/editor/canvas/graphs/"+g.name
				val gen = new GraphmodelComponent(gc)
				generateFile(path,
					gen.fileNameGraphModelCommandGraph(g.name),
					gen.contentGraphModelCommandGraph(g)
				)
				generateFile(path,
					gen.fileNameGraphModelComponent(g.name),
					gen.contentGraphModelComponent(g)
				)
				generateFile(path,
					gen.fileNameGraphModelComponentTemplate(g.name),
					gen.contentGraphModelComponentTemplate(g)
				)
				
			}]
		}

		{
			//lib.editor.canvas
			val path = "lib/pages/editor/canvas"
			val gen = new CanvasComponent(gc)
			generateFile(path,
				gen.fileNameCanvasComponent,
				gen.contentCanvasComponent
			)
			generateFile(path,
				gen.fileNameCanvasComponentTemplate,
				gen.contentCanvasComponentTemplate
			)	
		}

		{
			//lib.editor.explorer.graph_entry
			val path = "lib/pages/editor/explorer/graph_entry"
			val gen = new GraphEntryComponent(gc)
			generateFile(path,
				gen.fileNameGraphEntryComponent,
				gen.contentGraphEntryComponent
			)		
		}
		{
			//lib.editor.explorer.graph_entry.create
			val path = "lib/pages/editor/explorer/graph_entry/create"
			val gen = new CreateFileComponent(gc)
			generateFile(path,
				gen.fileNameCreateFileComponent,
				gen.contentCreateFileComponent
			)
			generateFile(path,
				gen.fileNameCreateFileComponentTemplate,
				gen.contentCreateFileComponentTemplate
			)		
		}
		{
			//lib.editor.map
			val path = "lib/pages/editor/map"
			val gen = new MapComponent(gc)
			generateFile(path,
				gen.fileNameMapComponent,
				gen.contentMapComponent
			)
			generateFile(path,
				gen.fileNameMapComponentTemplate,
				gen.contentMapComponentTemplate
			)		
		}
		{
			//lib.editor.palette
			val path = "lib/pages/editor/palette"
			val gen = new PaletteComponent(gc)
			generateFile(path,
				gen.fileNamePaletteComponent,
				gen.contentPaletteComponent
			)
		}
		{
			//lib.editor.palette.graphs.graphmodel
			graphModels.forEach[g|{
				val path = "lib/pages/editor/palette/graphs/"+g.name
				val gen = new PaletteBuilder(gc)
				generateFile(path,
					gen.fileNamePaletteBuilder,
					gen.contentPaletteBuilder(g)
				)
			}]
		}
		{
			//lib.editor.palette.list
			val path = "lib/pages/editor/palette/list"
			val gen = new ListComponent(gc)
			generateFile(path,
				gen.fileNameListComponent,
				gen.contentListComponent
			)
		}
		
		{
			//lib.editor.properties.graphs.graphmodel
			graphModels.forEach[g|{
				val path = "lib/pages/editor/properties/graphs/"+g.name
				val treeGen = new GraphmodelTree(gc)
				generateFile(path,
					treeGen.fileNameGraphmodelTree(g.name),
					treeGen.contentGraphmodelTree(g)
				)
				val propGen = new PropertyComponent(gc)
				generateFile(path,
					propGen.fileNamePropertyComponent,
					propGen.contentPropertyComponent(g)
				)
				generateFile(path,
					propGen.fileNamePropertyComponentTemplate,
					propGen.contentPropertyComponentTemplate(g)
				)
				val proertyTypes = g.nodes + g.edges + g.types.filter(UserDefinedType) + #[g]
				proertyTypes.forEach[t|{
					val gen = new IdentifiableElementPropertyComponent(gc)
					generateFile(path,
						gen.fileNameIdentifiableElementPropertyComponent(t.name),
						gen.contentIdentifiableElementPropertyComponent(g,t)
					)
					generateFile(path,
						gen.fileNameIdentifiableElementPropertyComponentTemplate(t.name),
						gen.contentIdentifiableElementPropertyComponentTemplate(g,t)
					)
				}]
				
			}]
		}
		{
			//lib.editor.properties.property
			val path = "lib/pages/editor/properties/property"
			val gen = new de.jabc.cinco.meta.plugin.pyro.frontend.pages.editor.properties.property.PropertyComponent(gc)
			generateFile(path,
				gen.fileNamePropertyComponent,
				gen.contentPropertyComponent
			)
			generateFile(path,
				gen.fileNamePropertyComponentTemplate,
				gen.contentPropertyComponentTemplate
			)
		}
		{
			//lib.editor.properties.tree
			val path = "lib/pages/editor/properties/tree"
			val gen = new TreeComponet(gc)
			generateFile(path,
				gen.fileNameTreeComponent,
				gen.contentTreeComponent
			)
		}
		{
			//lib.editor.properties.tree.node
			val path = "lib/pages/editor/properties/tree/node"
			val gen = new TreeNodeComponent(gc)
			generateFile(path,
				gen.fileNameTreeNodeComponent,
				gen.contentTreeNodeComponent
			)
		}
		
		
		{
			//lib.service
			val path = "lib/service"
			val gen = new GraphService(gc)
			generateFile(path,
				gen.fileNameGraphServcie,
				gen.contentGraphService
			)
		}
		{
			//.
			val path = ""
			val gen = new Pubspec(gc)
			generateFile(path,
				gen.fileNamePubspec,
				gen.contentPubspec
			)
		}
		
		//copy icons
		gc.graphMopdels.forEach[g|{
			if(!g.iconPath.nullOrEmpty){
				FileHandler.copyFile(g,g.iconPath,basePath+"/web/"+g.iconPath(g.name,false).toString.toLowerCase)
			}
			g.elements.filter[hasIcon].forEach[e|FileHandler.copyFile(e,e.eclipseIconPath,basePath+"/web/"+e.iconPath(g.name,false).toString.toLowerCase)]			
		}
		]

	}
}