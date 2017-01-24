package de.jabc.cinco.meta.core.jabcproject.handlers;

import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.jar.Manifest;

import mgl.GraphModel;

import org.eclipse.core.commands.AbstractHandler;
import org.eclipse.core.commands.ExecutionEvent;
import org.eclipse.core.commands.ExecutionException;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.NullProgressMonitor;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;
import org.eclipse.ui.IWorkbenchWindow;
import org.eclipse.ui.handlers.HandlerUtil;
import org.eclipse.ui.progress.IProgressService;

import de.jabc.cinco.meta.core.jabcproject.Activator;
import de.jabc.cinco.meta.core.jabcproject.TransEM4SIBGenerator;

/**
 * Our sample handler extends AbstractHandler, an IHandler base class.
 * 
 * @see org.eclipse.core.commands.IHandler
 * @see org.eclipse.core.commands.AbstractHandler
 */
public class CincoSIBGenerationHandler extends AbstractHandler {

	/**
	 * The constructor.
	 */
	public CincoSIBGenerationHandler() {

	}

	/**
	 * the command has been executed, so extract extract the needed information
	 * from the application context.
	 */
	public Object execute(ExecutionEvent event) throws ExecutionException {
		IWorkbenchWindow window = HandlerUtil
				.getActiveWorkbenchWindowChecked(event);
		
		IFile file = Activator.getDefault().getSelectionListener().getCurrentMGLFile();
		
		
		if (file != null && file.getFileExtension().equals("mgl")) {
			try {
				IPath modelPath = file.getLocation();

				IProgressService ps = window.getWorkbench()
						.getProgressService();
				prepareProject(file.getProject());
				ResourceSet resourceSet = new ResourceSetImpl();
				Resource mglResource = resourceSet.createResource(URI
						.createFileURI(modelPath.toFile().getAbsolutePath()));
				mglResource.load(null);

				GraphModel mglModel = (GraphModel) mglResource.getContents()
						.get(0);
				new TransEM4SIBGenerator(file.getProject(),
						mglModel).run(new NullProgressMonitor());

			} catch (Exception e) {
				e.printStackTrace();
			}

		}
		return null;
	}

	private void prepareProject(IProject project) {
		Manifest mani = new Manifest();
		try {
			mani.read(new FileInputStream(project.getLocation()
					.append("META-INF/MANIFEST.MF").toFile()));
			//System.out.println("*** Manifest Attributes ***");
			String oldValue = mani.getMainAttributes().getValue(
					"Require-Bundle");
			if (!oldValue.contains("de.jabc.cinco.meta.libraries")) {
				oldValue = oldValue.concat(",de.jabc.cinco.meta.libraries");
				mani.getMainAttributes().putValue("Require-Bundle", oldValue);
			}
			if (!oldValue.contains("org.eclipse.xtend.typesystem.emf")) {
				oldValue = oldValue.concat(",org.eclipse.xtend.typesystem.emf");
				mani.getMainAttributes().putValue("Require-Bundle", oldValue);
			}
			if (!oldValue.contains("org.eclipse.emf.ecore.xmi")) {
				oldValue = oldValue.concat(",org.eclipse.emf.ecore.xmi");
				mani.getMainAttributes().putValue("Require-Bundle", oldValue);
			}
			if(!oldValue.contains("de.jabc.cinco.meta.core.sibgenerator")){
				oldValue.concat("de.jabc.cinco.meta.core.sibgenerator");
				mani.getMainAttributes().putValue("Require-Bundle", oldValue);
			}
			mani.write(new FileOutputStream(project.getLocation()
					.append("META-INF/MANIFEST.MF").toFile()));
		} catch (IOException e) {
			e.printStackTrace();
		}

	}
}
