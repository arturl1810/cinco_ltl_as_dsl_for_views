package de.jabc.cinco.meta.core.ge.style.generator.action;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.URISyntaxException;
import java.net.URL;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map.Entry;
import java.util.Set;
import java.util.stream.Collectors;

import org.eclipse.core.commands.AbstractHandler;
import org.eclipse.core.commands.ExecutionEvent;
import org.eclipse.core.commands.ExecutionException;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IFolder;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.FileLocator;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.NullProgressMonitor;
import org.eclipse.core.runtime.Path;
import org.eclipse.core.runtime.Platform;
import org.osgi.framework.Bundle;

import de.jabc.cinco.meta.core.ge.style.generator.api.main.CincoApiGeneratorMain;
import de.jabc.cinco.meta.core.ge.style.generator.main.GraphitiGeneratorMain;
import de.jabc.cinco.meta.core.utils.generator.GeneratorUtils;
import de.jabc.cinco.meta.core.ui.listener.MGLSelectionListener;
import de.jabc.cinco.meta.core.utils.CincoUtils;
import de.jabc.cinco.meta.core.utils.MGLUtils;
import de.jabc.cinco.meta.core.utils.projects.ProjectCreator;
import de.jabc.cinco.meta.util.xapi.FileExtension;
import de.jabc.cinco.meta.util.xapi.ResourceExtension;
import mgl.GraphModel;
import mgl.GraphicalModelElement;
import mgl.IncomingEdgeElementConnection;
import mgl.OutgoingEdgeElementConnection;

public class NewGraphitiCodeGenerator extends AbstractHandler{

	@Override
	public Object execute(ExecutionEvent event) throws ExecutionException {
		
		IFile file = MGLSelectionListener.INSTANCE.getCurrentMGLFile();
		IFile cpdFile = MGLSelectionListener.INSTANCE.getSelectedCPDFile();
		
		if (file == null) throw new RuntimeException("No current mgl file in MGLSelectionListener...");
		if (cpdFile == null) throw new RuntimeException("No current cpd file in MGLSelectionListener...");
		
		NullProgressMonitor monitor = new NullProgressMonitor();
		
		String name_editorProject = file.getProject().getName().concat(".editor.graphiti");
		GraphModel graphModel = new FileExtension().getContent(file,mgl.GraphModel.class);
		
		if (graphModel == null) throw new RuntimeException("Could not load graphmodel from file: " + file);
		graphModel = prepareGraphModel(graphModel);
		IProject project = ProjectCreator.createDefaultPluginProject(name_editorProject, addReqBundles(graphModel, monitor), addExpPackages(graphModel));
		copyImages(graphModel, project);

		GraphitiGeneratorMain editorGenerator = new GraphitiGeneratorMain(graphModel,cpdFile, CincoUtils.getStyles(graphModel));
		editorGenerator.doGenerate(project);
		
		CincoApiGeneratorMain apiGenerator = new CincoApiGeneratorMain(graphModel);
		apiGenerator.doGenerate(project);
		
		return null;
	}
	
	private GraphModel prepareGraphModel(GraphModel graphModel){
		List<GraphicalModelElement> connectableElements = new ArrayList<>();
		
		connectableElements.addAll(graphModel.getNodes());
		for(GraphicalModelElement elem : connectableElements) {
			for(IncomingEdgeElementConnection connect : elem.getIncomingEdgeConnections()){
				if(connect.getConnectingEdges() == null || connect.getConnectingEdges().isEmpty()){
					connect.getConnectingEdges().addAll(graphModel.getEdges());
				}
			}
			for(OutgoingEdgeElementConnection connect : elem.getOutgoingEdgeConnections()){
				if(connect.getConnectingEdges() == null || connect.getConnectingEdges().isEmpty()){
					connect.getConnectingEdges().addAll(graphModel.getEdges());
				}
			}
		}
		
		return graphModel;
	}

	private Set<String> addReqBundles(GraphModel graphModel, IProgressMonitor monitor) {
		Set<Bundle> bundles = new HashSet<Bundle>();
		
		bundles.add(Platform.getBundle("org.eclipse.emf.transaction"));
		bundles.add(Platform.getBundle("org.eclipse.graphiti"));
		bundles.add(Platform.getBundle("org.eclipse.graphiti.ui"));
		bundles.add(Platform.getBundle("org.eclipse.core.resources"));
		bundles.add(Platform.getBundle("org.eclipse.ui"));
		bundles.add(Platform.getBundle("org.eclipse.ui.ide"));
		bundles.add(Platform.getBundle("org.eclipse.ui.navigator"));
		bundles.add(Platform.getBundle("org.eclipse.ui.views.properties.tabbed"));
		bundles.add(Platform.getBundle("org.eclipse.gef"));
		bundles.add(Platform.getBundle("de.jabc.cinco.meta.core.ge.style.model"));
		bundles.add(Platform.getBundle("de.jabc.cinco.meta.core.ge.style.generator"));
		bundles.add(Platform.getBundle("de.jabc.cinco.meta.core.referenceregistry"));
		bundles.add(Platform.getBundle("de.jabc.cinco.meta.core.ui"));
		bundles.add(Platform.getBundle("de.jabc.cinco.meta.util"));
		bundles.add(Platform.getBundle("de.jabc.cinco.meta.runtime"));
		bundles.add(Platform.getBundle("de.jabc.cinco.meta.core.utils"));
		bundles.add(Platform.getBundle("de.jabc.cinco.meta.core.capi"));
		bundles.add(Platform.getBundle("de.jabc.cinco.meta.core.wizards"));
		bundles.add(Platform.getBundle("javax.el"));
		bundles.add(Platform.getBundle("com.sun.el"));
		bundles.add(Platform.getBundle("de.jabc.cinco.meta.core.ge.style.generator.runtime"));
		Set<String> retval = bundles.stream().filter(b -> b != null).map(b -> b.getSymbolicName()).collect(Collectors.toSet());
		retval.add(graphModel.getPackage());
		return retval;
	}
	
	private List<String> addExpPackages(GraphModel gm) {
		ArrayList<String> packs = new ArrayList<String>();
		packs.add(new GeneratorUtils().packageName(gm).toString());
		
		return packs;
	}
	
	private void copyImages(GraphModel graphModel, IProject project) {
		HashMap<String, URL> allImages = MGLUtils.getAllImages(graphModel);
		File f;
		try {
			IFolder iconsFolder = project.getFolder("icons");
			IFolder resGen = project.getFolder(new Path("resources-gen"));
			IFolder icoGen = project.getFolder(new Path("resources-gen/icons"));
			if (!iconsFolder.exists()) iconsFolder.create(true, true, null);
			if (!resGen.exists()) resGen.create(true, true, null);
			if (!icoGen.exists()) icoGen.create(true, true, null);
			
			Bundle b = Platform.getBundle("de.jabc.cinco.meta.core.ge.style.generator.runtime");
			InputStream fileis = null;
			try {
				fileis = FileLocator.openStream(b, new Path("/icons/_Connection.gif"), false);
				File trgFile = project.getFolder("resources-gen/icons").getFile("_Connection.gif").getLocation().toFile();
				trgFile.createNewFile();
				OutputStream os = new FileOutputStream(trgFile);
				int bt;
				while ((bt = fileis.read()) != -1) {
					os.write(bt);
				}
				fileis.close();
				os.flush();
				os.close();
				CincoUtils.refreshFiles(null, project.getFolder("resources-gen/icons").getFile("_Connection.gif"));
			} catch (IOException e) {
				e.printStackTrace();
			}
			
			for (Entry<String, URL> e : allImages.entrySet()) {
				IFile imgFile = project.getFile(e.getKey());
				f = new File(e.getValue().toURI());
				if (!imgFile.exists()) {
					FileInputStream fis = new FileInputStream(f);
					imgFile.create(fis, true, null);
					fis.close();
				}
			}
		} catch (URISyntaxException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		} catch (CoreException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		} catch (FileNotFoundException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		} catch (IOException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}
	}
	
}
