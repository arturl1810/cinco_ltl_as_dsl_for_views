package de.jabc.cinco.meta.plugin.pyro.util

import java.io.File
import java.io.IOException
import org.apache.commons.io.FileUtils
import org.eclipse.core.resources.IFile
import org.eclipse.core.resources.IProject
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.core.runtime.FileLocator
import org.eclipse.core.runtime.Platform
import org.eclipse.emf.common.util.URI
import org.osgi.framework.Bundle
import de.jabc.cinco.meta.core.utils.CincoUtils
import de.jabc.cinco.meta.core.utils.PathValidator
import mgl.GraphModel
import style.AbstractShape
import style.ContainerShape
import style.EdgeStyle
import style.GraphicsAlgorithm
import style.NodeStyle
import style.Style
import style.Styles
import org.eclipse.emf.ecore.EObject

class FileHandler {
	def static void copyResources(String bundleId, String target) {
		var Bundle b = Platform.getBundle(bundleId)
		try {
			var File source = FileLocator.getBundleFile(b)
			FileUtils.copyDirectoryToDirectory(new File('''«source.getAbsolutePath()»/resourcedywa/app-business'''),
				new File(target))
			FileUtils.copyDirectoryToDirectory(new File('''«source.getAbsolutePath()»/resourcedywa/app-presentation'''),
				new File(target))
			FileUtils.copyDirectoryToDirectory(new File('''«source.getAbsolutePath()»/resourcedywa/app-preconfig'''),
				new File(target))
			FileUtils.copyDirectoryToDirectory(new File('''«source.getAbsolutePath()»/resourcedywa/app-persistence'''),
				new File(target))
			FileUtils.copyFileToDirectory(new File('''«source.getAbsolutePath()»/resourcedywa/pom.xml'''),
				new File(target))
		} catch (IOException e) {
			e.printStackTrace()
		}

	}

	def static void copyImages(GraphModel graphModel, String resourcePath, IProject iProject, String imgBasePath) {
		try {
			var String path = '''«resourcePath»«imgBasePath»«graphModel.getName().toLowerCase()»/'''
			var Styles styles = CincoUtils.getStyles(graphModel, iProject)
			for (Style style : styles.getStyles()) {
				if (style instanceof NodeStyle) {
					copyImage(((style as NodeStyle)).getMainShape(), path)
				} else if (style instanceof EdgeStyle) {
					for (style.ConnectionDecorator connectionDecorator : ((style as EdgeStyle)).getDecorator()) {
						copyImage(connectionDecorator.getDecoratorShape(), path)
					}
				}
			}
		} catch (IOException e) {
			e.printStackTrace()
		}

	}

	def private static void copyImage(AbstractShape shape, String target) throws IOException {
		if (shape instanceof style.Image) {
			copyImageFile((shape as style.Image), target)
		} else if (shape instanceof ContainerShape) {
			for (AbstractShape abstractShape : ((shape as ContainerShape)).getChildren()) {
				if (abstractShape instanceof style.Image) {
					copyImageFile((abstractShape as style.Image), target)
				}
			}
		}
	}

	def private static void copyImage(GraphicsAlgorithm shape, String target) throws IOException {
		if (shape instanceof style.Image) {
			copyImageFile((shape as style.Image), target)
		}
	}

	def private static void copyImageFile(style.Image image, String target) throws IOException {
		copyFile(image,image.path,target)
	}
	
	def static void copyFile(EObject res,String path, String target) throws IOException {
		// IWorkspaceRoot root = ResourcesPlugin.getWorkspace().getRoot();
		// IResource resourceInRuntimeWorkspace = root.findMember(image.getPath());
		// File file = new File(resourceInRuntimeWorkspace.getLocationURI());
		var URI uriForString = PathValidator.getURIForString(res, path)
		var IFile ir = (ResourcesPlugin.getWorkspace().getRoot().findMember(
			uriForString.toPlatformString(true)) as IFile)
		var File targetFile = new File(target)
		FileUtils.copyFileToDirectory(new File(ir.getRawLocation().toOSString()), targetFile)
	}
}
