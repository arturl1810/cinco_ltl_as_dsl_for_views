package de.jabc.cinco.meta.plugin.executer.generator.model

import de.jabc.cinco.meta.plugin.executer.compounds.ExecutableGraphmodel
import java.io.File
import java.nio.file.Files
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.core.runtime.Path
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.core.resources.IProject

class StyleGeneratorTemplate {
	def create(ExecutableGraphmodel graphmodel,IProject p)
	'''
	//Imported style
	
	«getIncludeStyling(graphmodel,p)»
	
	//Additional styles
	
	nodeStyle metaElement(1) {
		rectangle {
			appearance {
				lineWidth 2
				lineStyle SOLID
				foreground (127,127,127)
				background (255,255,255)
				filled true
			}
			size (200,80)
			text {
				appearance {
					foreground (0,0,0)
					background (255,255,255)
					font ("Helvetica",12)
				}
				position (CENTER,TOP 2)
				value "%s"
			}
		}
	}
	
	nodeStyle stateContainer(1) {
		rectangle {
			appearance {
				lineWidth 2
				lineStyle DASH
				foreground (127,127,127)
				background (255,255,255)
				filled true
			}
			size (200,80)
			text {
				appearance {
					foreground (0,0,0)
					background (255,255,255)
					font ("Helvetica",12)
				}
				position (CENTER,TOP 2)
				value "%s"
			}
		}
	}
	
	nodeStyle connector(1) {
		rectangle {
			appearance {
				background (255,255,255)
				foreground (255,255,255)
				filled true
			}
			size(60,60)
			ellipse {
				appearance {
					background (255,255,255)
					foreground (0,0,0)
				}
				position (CENTER,TOP -15)
				size(15,15)
			}
			text {
				appearance {
					font ("Helvetica",10)
					foreground (0,0,0)
					background (255,255,255)
				}
				position (CENTER,BOTTOM -10)
				value "%s"
				}
		}
	}
	
	nodeStyle placeholderContainer {
		roundedRectangle {
			appearance {
				lineWidth 2
				lineStyle DASH
				foreground (127,127,127)
				background (255,255,255)
				filled true
			}
			size (100,50)
			corner (4,4)
			text {
				appearance {
					foreground (0,0,0)
					background (255,255,255)
					font ("Helvetica",12)
				}
				position (CENTER,MIDDLE)
				value "Placeholder"
			}
		}
	}
	
	nodeStyle defaultNode(1) {
		roundedRectangle {
			appearance {
				lineWidth 2
				lineStyle DASH
				foreground (127,127,127)
				background (255,255,255)
				filled true
			}
			size (100,50)
			corner (4,4)
			text {
				appearance {
					foreground (0,0,0)
					background (255,255,255)
					font ("Helvetica",12)
				}
				position (CENTER,MIDDLE)
				value "%s"
			}
		}
	}
	
	edgeStyle placeholderEdge {
		appearance {
		lineWidth 2
		lineStyle DOT
		foreground (0,0,0)
		background (0,0,0)
		}
		decorator {
			ARROW
			location (1.0)
		}
		decorator {
			text {
				appearance  {
					foreground (0,0,0)
					background (255,255,255)
					font ("Helvetica",12)
				}
				value "Placeholder"
			}
			location (0.5)
		}
	}
	
	edgeStyle defaultEdge(1) {
		appearance {
		lineWidth 2
		lineStyle DOT
		foreground (0,0,0)
		background (0,0,0)
		}
		decorator {
			ARROW
			location (1.0)
		}
		decorator {
			text {
				appearance  {
					foreground (0,0,0)
					background (255,255,255)
					font ("Helvetica",12)
				}
				value "%s"
			}
			location (0.5)
		}
	}
	'''
	
	def String getIncludeStyling(ExecutableGraphmodel graphmodel,IProject p)
	{
		for ( a : graphmodel.modelElement.getAnnotations()) {
			if ("style".equals(a.getName())) {
				var path = a.getValue().get(0);
				var file = p.getFile(new Path(path));
				try {
					return new String (Files.readAllBytes(new File(file.rawLocation.toOSString).toPath.toAbsolutePath));
					
					
				} catch (Exception e) {
					e.printStackTrace();
					return "";
				}
			}
		}
		return null;
	}
	
}