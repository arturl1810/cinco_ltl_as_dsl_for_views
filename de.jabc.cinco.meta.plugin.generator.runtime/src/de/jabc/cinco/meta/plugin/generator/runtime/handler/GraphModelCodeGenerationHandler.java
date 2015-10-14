package de.jabc.cinco.meta.plugin.generator.runtime.handler;
import graphmodel.GraphModel;

import java.lang.reflect.InvocationTargetException;
import java.util.List;

import org.eclipse.core.commands.AbstractHandler;
import org.eclipse.core.commands.ExecutionEvent;
import org.eclipse.core.commands.ExecutionException;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Status;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;
import org.eclipse.graphiti.ui.editor.DiagramEditorInput;
import org.eclipse.jface.dialogs.ErrorDialog;
import org.eclipse.jface.dialogs.MessageDialog;
import org.eclipse.jface.operation.IRunnableWithProgress;
import org.eclipse.swt.widgets.Display;
import org.eclipse.ui.IEditorPart;
import org.eclipse.ui.IWorkbenchWindow;
import org.eclipse.ui.handlers.HandlerUtil;
import org.eclipse.ui.progress.IProgressService;

import de.jabc.cinco.meta.plugin.generator.runtime.IGenerator;
import de.jabc.cinco.meta.plugin.generator.runtime.registry.GeneratorDiscription;
import de.jabc.cinco.meta.plugin.generator.runtime.registry.GraphModelGeneratorRegistry;
/**
 * Our sample handler extends AbstractHandler, an IHandler base class.
 * @see org.eclipse.core.commands.IHandler
 * @see org.eclipse.core.commands.AbstractHandler
 */
public class GraphModelCodeGenerationHandler extends AbstractHandler {
	/**
	 * The constructor.
	 */
	public GraphModelCodeGenerationHandler() {
		
	}

	/**
	 * the command has been executed, so extract extract the needed information
	 * from the application context.
	 */
	public Object execute(final ExecutionEvent event) throws ExecutionException {
				IWorkbenchWindow window = HandlerUtil.getActiveWorkbenchWindowChecked(event);
		
		try {
			IEditorPart activeEditor =  window.getActivePage().getActiveEditor();
			DiagramEditorInput input = (DiagramEditorInput)activeEditor.getEditorInput();
			final URI uri = input.getUri();
    			IProgressService ps = window.getWorkbench().getProgressService();
			ps.run(true, true, new IRunnableWithProgress() {
				
			@Override
			public void run(IProgressMonitor monitor) throws InvocationTargetException, InterruptedException {
			
			try{
				ResourceSet set = new ResourceSetImpl();
				Resource res = set.createResource(uri);
				GraphModel graphModel =null;
				res.load(null);
				for(EObject obj: res.getContents()){
					if(obj instanceof GraphModel){
						graphModel = (GraphModel)obj;
						break;
					}
				
				}
				if(graphModel!=null){
					String graphModelClassName = graphModel.getClass().getName().replace("Impl","").replace(".impl", "");
					List<GeneratorDiscription<GraphModel>> generatorDiscriptions = GraphModelGeneratorRegistry.INSTANCE.getAllGenerators(graphModelClassName);
					if(generatorDiscriptions!=null){
					for(GeneratorDiscription<GraphModel> generatorDiscription:generatorDiscriptions){
					IGenerator<GraphModel> generator = generatorDiscription.getGenerator();
					IProject project = null;
					if (uri.isPlatformResource()) {
						String platformString = uri.toPlatformString(true);
						IResource s = ResourcesPlugin.getWorkspace().getRoot().findMember(platformString);
						project = s.getProject();
					}
					final org.eclipse.core.runtime.IPath outlet = project.getLocation().append(generatorDiscription.getOutlet());
					if(!outlet.toFile().exists()){
						outlet.toFile().mkdirs();
					}
					else if (!outlet.toFile().isDirectory()){
						throw new RuntimeException("Outlet /src-gen/ already exists, but is no directory.");
					}
					generator.generate(graphModel,outlet,monitor);
					project.refreshLocal(IProject.DEPTH_INFINITE, monitor);
					
					}
					new Thread(new Runnable() {
						public void run() {
							Display.getDefault().asyncExec(new Runnable() {
								public void run() {
									MessageDialog.openInformation(HandlerUtil.getActiveShell(event), "Code generation succeeded",
											"The code for model\n\"" + uri.lastSegment() + "\"\nwas succesfully generated.");					               }
								});
						}
						}).start();
				}
				}
			
			}catch(Exception e){
				final Status status = new Status(IStatus.ERROR, uri.toString(), e.getMessage(), e);
				new Thread(new Runnable() {
				public void run() {
					Display.getDefault().asyncExec(new Runnable() {
						public void run() {
							ErrorDialog.openError(HandlerUtil.getActiveShell(event), "Error during code generation", "An error occured during generation", status);						               }
						});
				}
			}).start();e.printStackTrace();
		}
		}	
				
			});
		} catch (InvocationTargetException | InterruptedException e) {
			e.printStackTrace();
		}catch (ClassCastException e){
			
		}
    return null;
	}
}