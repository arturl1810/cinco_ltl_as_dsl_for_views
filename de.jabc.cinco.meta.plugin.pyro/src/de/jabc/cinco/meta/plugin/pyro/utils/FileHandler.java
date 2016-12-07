package de.jabc.cinco.meta.plugin.pyro.utils;

import java.awt.Image;
import java.io.File;
import java.io.IOException;
import java.util.Scanner;

import mgl.GraphModel;

import org.apache.commons.io.FileUtils;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.IWorkspaceRoot;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.FileLocator;
import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.Path;
import org.eclipse.core.runtime.Platform;
import org.eclipse.core.runtime.URIUtil;
import org.eclipse.emf.common.util.URI;
import org.eclipse.graphiti.mm.pictograms.ConnectionDecorator;
import org.osgi.framework.Bundle;

import style.AbstractShape;
import style.ContainerShape;
import style.EdgeStyle;
import style.GraphicsAlgorithm;
import style.NodeStyle;
import style.Style;
import style.Styles;
import de.jabc.cinco.meta.core.utils.CincoUtils;
import de.jabc.cinco.meta.core.utils.PathValidator;
import de.jabc.cinco.meta.plugin.pyro.CreatePyroPlugin;


public class FileHandler {
	public static void copyResources(String bundleId, String target) {
		Bundle b = Platform.getBundle(bundleId);
		try {
			File source = FileLocator.getBundleFile(b);
			FileUtils.copyDirectoryToDirectory(new File(source.getAbsolutePath()+"/resourcedywa/app-business"), new File(target));
			FileUtils.copyDirectoryToDirectory(new File(source.getAbsolutePath()+"/resourcedywa/app-presentation"), new File(target));
			FileUtils.copyDirectoryToDirectory(new File(source.getAbsolutePath()+"/resourcedywa/app-preconfig"), new File(target));
			FileUtils.copyDirectoryToDirectory(new File(source.getAbsolutePath()+"/resourcedywa/app-persistence"), new File(target));
			FileUtils.copyFileToDirectory(new File(source.getAbsolutePath()+"/resourcedywa/pom.xml"), new File(target));
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
	
	public static void copyImages(GraphModel graphModel,String resourcePath,IProject iProject) {
		try {
			String path = resourcePath + "/img/pyro/"+ CreatePyroPlugin.toFirstLower(graphModel.getName())+"/";
			Styles styles = CincoUtils.getStyles(graphModel,iProject);
			for(Style style:styles.getStyles()){
				if(style instanceof NodeStyle){
					copyImage(((NodeStyle)style).getMainShape(),path);
				}
				else if(style instanceof EdgeStyle) {
					for(style.ConnectionDecorator connectionDecorator:((EdgeStyle)style).getDecorator()){
						copyImage(connectionDecorator.getDecoratorShape(),path);					
					}
				}
			}
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
	
	private static void copyImage(AbstractShape shape,String target) throws IOException{
		if(shape instanceof style.Image){
			copyImageFile((style.Image)shape, target);		
		}
		else if(shape instanceof ContainerShape){
			for(AbstractShape abstractShape:((ContainerShape)shape).getChildren()){
				if(abstractShape instanceof style.Image) {
					copyImageFile((style.Image)abstractShape, target);					
				}
			}
		}
	}
	
	private static void copyImage(GraphicsAlgorithm shape,String target) throws IOException{
		if(shape instanceof style.Image){
			copyImageFile((style.Image)shape, target);		
		}
	}
	
	private static void copyImageFile(style.Image image, String target) throws IOException {
//		IWorkspaceRoot root = ResourcesPlugin.getWorkspace().getRoot();
//		IResource resourceInRuntimeWorkspace = root.findMember(image.getPath());
//		File file = new File(resourceInRuntimeWorkspace.getLocationURI());
		URI uriForString = PathValidator.getURIForString(image, image.getPath());
		IFile ir = (IFile) ResourcesPlugin.getWorkspace().getRoot().findMember(uriForString.toPlatformString(true));
		File targetFile = new File(target);
		FileUtils.copyFileToDirectory(new File(ir.getRawLocation().toOSString()),targetFile);	
	}
}
