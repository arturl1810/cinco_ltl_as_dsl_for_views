package de.jabc.cinco.meta.plugin.executer.generator.tracer

import de.jabc.cinco.meta.plugin.executer.generator.tracer.MainTemplate
import de.jabc.cinco.meta.plugin.executer.compounds.ExecutableGraphmodel

class ViewTemplate extends MainTemplate {
	
	new(ExecutableGraphmodel graphmodel) {
		super(graphmodel)
	}
	
	override fileName() {
		return "View.java"
	}
	
	override create(ExecutableGraphmodel graphmodel)
	'''
	package «graphmodel.tracerPackage».views;
	
	
	import java.util.HashMap;
	import java.util.List;
	import java.util.LinkedList;
	import java.util.Map;
	import java.util.Map.Entry;
	
	import org.eclipse.core.resources.IFile;
	import org.eclipse.core.resources.ResourcesPlugin;
	import org.eclipse.core.runtime.Platform;
	import org.eclipse.graphiti.mm.pictograms.Diagram;
	import org.eclipse.jface.action.Action;
	import org.eclipse.jface.dialogs.MessageDialog;
	import org.eclipse.jface.viewers.DoubleClickEvent;
	import org.eclipse.jface.viewers.IDoubleClickListener;
	import org.eclipse.jface.viewers.ISelection;
	import org.eclipse.jface.viewers.IStructuredContentProvider;
	import org.eclipse.jface.viewers.IStructuredSelection;
	import org.eclipse.jface.viewers.ITableLabelProvider;
	import org.eclipse.jface.viewers.LabelProvider;
	import org.eclipse.jface.viewers.TableViewer;
	import org.eclipse.jface.viewers.Viewer;
	import org.eclipse.jface.viewers.ViewerSorter;
	import org.eclipse.jface.window.Window;
	import org.eclipse.pde.internal.ui.util.FileExtensionFilter;
	import org.eclipse.swt.SWT;
	import org.eclipse.swt.events.SelectionEvent;
	import org.eclipse.swt.events.SelectionListener;
	import org.eclipse.swt.graphics.Color;
	import org.eclipse.swt.graphics.Image;
	import org.eclipse.swt.layout.GridData;
	import org.eclipse.swt.layout.RowLayout;
	import org.eclipse.swt.widgets.Button;
	import org.eclipse.swt.widgets.Composite;
	import org.eclipse.swt.widgets.Control;
	import org.eclipse.swt.widgets.Display;
	import org.eclipse.swt.widgets.Group;
	import org.eclipse.swt.widgets.Shell;
	import org.eclipse.ui.ISharedImages;
	import org.eclipse.ui.PlatformUI;
	import org.eclipse.ui.dialogs.ElementListSelectionDialog;
	import org.eclipse.ui.dialogs.ElementTreeSelectionDialog;
	import org.eclipse.ui.model.BaseWorkbenchContentProvider;
	import org.eclipse.ui.model.WorkbenchLabelProvider;
	import org.eclipse.ui.part.ViewPart;
	
	import de.jabc.cinco.meta.core.utils.WorkspaceUtil;
	import de.jabc.cinco.meta.core.utils.WorkbenchUtil;
	import graphmodel.GraphModel;
	import «graphmodel.sourceCApiPackage».C«graphmodel.graphModel.name»;
	import «graphmodel.CApiPackage».C«graphmodel.graphModel.name»ES;
	import «graphmodel.package».graphiti.«graphmodel.graphModel.name»ESWrapper;
	import «graphmodel.apiPackage».«graphmodel.graphModel.name»ES;
	import «graphmodel.graphModel.package».graphiti.«graphmodel.graphModel.name»Wrapper;
	import «graphmodel.tracerPackage».extension.AbstractRunner;
	import «graphmodel.tracerPackage».handler.EvaluateContributionsHandler;
	import «graphmodel.tracerPackage».handler.ExecutionTupel;
	import «graphmodel.tracerPackage».match.model.LTSMatch;
	import «graphmodel.tracerPackage».match.simulation.GraphSimulator;
	import «graphmodel.tracerPackage».runner.model.RunCallback;
	import «graphmodel.tracerPackage».runner.model.RunResult;
	import «graphmodel.tracerPackage».stepper.model.Stepper;
	import «graphmodel.tracerPackage».stepper.model.Thread;
	import «graphmodel.tracerPackage».stepper.utils.ContentView;
	import «graphmodel.tracerPackage».stepper.utils.JointTracerException;
	import «graphmodel.tracerPackage».stepper.utils.TracerException;
	import «graphmodel.graphModel.package».«graphmodel.graphModel.name.toLowerCase».«graphmodel.graphModel.name»;
	
	
	/**
	 * This sample class demonstrates how to plug-in a new
	 * workbench view. The view shows data obtained from the
	 * model. The sample creates a dummy model on the fly,
	 * but a real implementation would connect to the model
	 * available either in this or another plug-in (e.g. the workspace).
	 * The view is connected to the model using a content provider.
	 * <p>
	 * The view uses a label provider to define how model
	 * objects should be presented in the view. Each
	 * view can present the same model objects using
	 * different labels and icons, if needed. Alternatively,
	 * a single label provider can be shared between views
	 * in order to ensure that objects of the same type are
	 * presented in the same way everywhere.
	 * <p>
	 */
	@SuppressWarnings("restriction")
	public class View extends ViewPart {
	
		/**
		 * The ID of the view as specified by the extension.
		 */
		public static final String ID = "«graphmodel.tracerPackage».views.SampleView";
		
		//Mode ids
		public static final int LEVEL_MODE = 1;
		public static final int HISTORY_MODE = 2;
		public static final int CURRENT_MODE = 3;
		
	
		private Map<Thread,ThreadView> viewerMap;
		private Composite mainContainer;
		private Composite threadContainer;
		
		private Color buttonBackGroundColor;
		
		// The model
		private «graphmodel.graphModel.name» «graphmodel.graphModel.name.toFirstLower»;
		private C«graphmodel.graphModel.name» c«graphmodel.graphModel.name»;
		
		// the pattern
		private «graphmodel.graphModel.name»ES «graphmodel.graphModel.name.toFirstLower»ES;
		private C«graphmodel.graphModel.name»ES c«graphmodel.graphModel.name»ES;
		
		// The Stepper
		private Stepper stepper;
		
		// The semantics
		private List<ExecutionTupel> tupel;
		private ExecutionTupel currentSemantic;
		
		// The Runners
		private List<AbstractRunner> runner;
		private AbstractRunner currentRunner;
		
		
		/*
		 * The content provider class is responsible for
		 * providing objects to the view. It can wrap
		 * existing objects in adapters or simply return
		 * objects as-is. These objects may be sensitive
		 * to the current input of the view, or ignore
		 * it and always show the same content 
		 * (like Task List, for example).
		 */
		 
		class ViewContentProvider implements IStructuredContentProvider {
			private Object[] levels;
			
			public ViewContentProvider()
			{
				levels = new Object[0];
			}
			
			public void inputChanged(Viewer v, Object oldInput, Object newInput) {
				
			}
			public void dispose() {
			}
			public Object[] getElements(Object parent) {
				return levels;
			}
			public Object[] getLevels() {
				return levels;
			}
			public void setLevels(Object[] levels) {
				this.levels = levels;
			}
			
			
			
		}
		class ViewLabelProvider extends LabelProvider implements ITableLabelProvider {
			public String getColumnText(Object obj, int index) {
				return getText(obj);
			}
			public Image getColumnImage(Object obj, int index) {
				return getImage(obj);
			}
			public Image getImage(Object obj) {
				return PlatformUI.getWorkbench().
						getSharedImages().getImage(ISharedImages.IMG_TOOL_FORWARD);
			}
		}
		class NameSorter extends ViewerSorter {
		}
	
		/**
		 * The constructor.
		 */
		public View() {
			
			EvaluateContributionsHandler ech =new EvaluateContributionsHandler();
			ech.execute(Platform.getExtensionRegistry());
			this.tupel = ech.getTupels();
			this.runner = ech.getRunner();
			this.viewerMap = new HashMap<Thread, ThreadView>();
			
			//Colors
			this.buttonBackGroundColor = new Color(Display.getCurrent(),171,171,171);
		}
	
		/**
		 * This is a callback that will allow us
		 * to create the viewer and initialize it.
		 */
		public void createPartControl(Composite parent) {
			
			//Main Container
			mainContainer = new Composite(parent, SWT.BORDER | SWT.V_SCROLL | SWT.H_SCROLL);
			mainContainer.setLayout(new org.eclipse.swt.layout.GridLayout(1,false));
			mainContainer.setLayoutData(new GridData(SWT.FILL, SWT.FILL, true, true));
			//Main Buttons
			Composite mainButtonContainer = new Composite(mainContainer, SWT.BORDER |SWT.WRAP);
			mainButtonContainer.setBackground(Display.getCurrent().getSystemColor(SWT.COLOR_WHITE));
			mainButtonContainer.setLayout(new org.eclipse.swt.layout.RowLayout());
			//Add main control Buttons
			
			//Load Graphmodel Button
			Button loadGraphButton = new Button(mainButtonContainer, SWT.PUSH);
			loadGraphButton.setText("Load");
			loadGraphButton.setBackground(buttonBackGroundColor);
			loadGraphButton.addSelectionListener(new SelectionListener() {
	
		      public void widgetSelected(SelectionEvent event) {
		    	  		resetTracer();
					prepare(parent.getShell());
		      }
	
		      public void widgetDefaultSelected(SelectionEvent event) {
		        //Nothing here
		      }
		    });
			
			//Reset tracer Button
			Button resetButton = new Button(mainButtonContainer, SWT.PUSH);
			resetButton.setText("Reset");
			resetButton.setBackground(buttonBackGroundColor);
			resetButton.addSelectionListener(new SelectionListener() {
	
		      public void widgetSelected(SelectionEvent event) {
				if(prepare(parent.getShell())){
					startNewTracer(parent.getShell());
				}
					
		      }
	
		      public void widgetDefaultSelected(SelectionEvent event) {
		        //Nothing here
		      }
		    });
			
			//Single Step Button
			Button stepButton = new Button(mainButtonContainer, SWT.PUSH);
			stepButton.setText("Step");
			stepButton.setBackground(buttonBackGroundColor);
			stepButton.addSelectionListener(new SelectionListener() {
	
		      public void widgetSelected(SelectionEvent event) {
		    	  	if(prepare(parent.getShell())){
					doStep(null);					
				}
					
		      }
	
		      public void widgetDefaultSelected(SelectionEvent event) {
		        //Nothing here
		      }
		    });
			
			//Show Context Button
			Button contextButton = new Button(mainButtonContainer, SWT.PUSH);
			contextButton.setText("Context");
			contextButton.setBackground(buttonBackGroundColor);
			contextButton.addSelectionListener(new SelectionListener() {
	
		      public void widgetSelected(SelectionEvent event) {
		    	  	showContext();
					
		      }
	
		      public void widgetDefaultSelected(SelectionEvent event) {
		        //Nothing here
		      }
		    });
			
			//Auto Execution Button
			Button autoButton = new Button(mainButtonContainer, SWT.PUSH);
			autoButton.setText("Auto");
			autoButton.setBackground(buttonBackGroundColor);
			autoButton.addSelectionListener(new SelectionListener() {
	
		      public void widgetSelected(SelectionEvent event) {
		    	  	if(prepare(parent.getShell())){
					while(doStep(null));					
				}
					
		      }
	
		      public void widgetDefaultSelected(SelectionEvent event) {
		        //Nothing here
		      }
		    });
			
			//Runner Execution Button
			Button runnerButton = new Button(mainButtonContainer, SWT.PUSH);
			runnerButton.setText("Runner");
			runnerButton.setBackground(buttonBackGroundColor);
			runnerButton.addSelectionListener(new SelectionListener() {
	
		      public void widgetSelected(SelectionEvent event) {
		    	  	if(prepareRunner(parent.getShell())){
					doRun(parent.getShell());				
				}
					
		      }
	
		      public void widgetDefaultSelected(SelectionEvent event) {
		        //Nothing here
		      }
		    });
			
			
			//Add Container Composite
			threadContainer = new Composite(mainContainer, SWT.BORDER|SWT.WRAP);
			
			threadContainer.setLayout(new RowLayout(SWT.HORIZONTAL));
			threadContainer.setBackground(Display.getCurrent().getSystemColor(SWT.COLOR_WHITE));
			threadContainer.setLayoutData(new GridData(SWT.FILL, SWT.FILL, true, true));
			
			
		}
		
		public ThreadView createThread(Thread thread)
		{
			ThreadView tv = new ThreadView();
	
			Color color = new org.eclipse.swt.graphics.Color(Display.getCurrent(),
		    		thread.getHighlighter().getBackColor().getRed(),
		    		thread.getHighlighter().getBackColor().getGreen(),
		    		thread.getHighlighter().getBackColor().getBlue()
	    		);
			
			//Add Goup
			Group group = new Group(threadContainer, SWT.SHADOW_OUT|SWT.WRAP);
		    group.setText("Thread "+this.viewerMap.size());
		    //group.setForeground(color);
		    
		    Composite innerThreadContainer = new Composite(group, SWT.NONE|SWT.WRAP);
		    innerThreadContainer.setBackground(color);
		    innerThreadContainer.setLayout(new RowLayout(SWT.VERTICAL));
		    GridData gridData = new GridData(SWT.FILL, SWT.FILL, true, true);
		    gridData.horizontalIndent=30;
		    innerThreadContainer.setLayoutData(gridData);
		    
		    //Add Thread Button Container
		    Composite threadButtonContainer = new Composite(innerThreadContainer, SWT.NONE|SWT.WRAP);
		    threadButtonContainer.setBackground(color);
		    threadButtonContainer.setLayout(new org.eclipse.swt.layout.RowLayout());
		    
		    Button levelButton = new Button(threadButtonContainer, SWT.TOGGLE);
		    levelButton.setText("Level");
		    levelButton.setBackground(buttonBackGroundColor);
		    levelButton.setEnabled(false);
		    
		    Button historyButton = new Button(threadButtonContainer, SWT.TOGGLE);
		    historyButton.setText("History");
		    historyButton.setBackground(buttonBackGroundColor);
		    historyButton.setEnabled(true);
		    
		    Button currentButton = new Button(threadButtonContainer, SWT.TOGGLE);
		    currentButton.setText("Current");
		    currentButton.setBackground(buttonBackGroundColor);
		    currentButton.setEnabled(true);
		    
		    Button stepButton = new Button(threadButtonContainer, SWT.PUSH);
		    stepButton.setText("Step");
		    stepButton.setBackground(buttonBackGroundColor);
		    
		    levelButton.addSelectionListener(new SelectionListener() {
	
			      public void widgetSelected(SelectionEvent event) {
			    	  		tv.setCurrentMode(LEVEL_MODE);
			    	  		levelButton.setEnabled(false);
			    	  		historyButton.setEnabled(true);
			    	  		currentButton.setEnabled(true);
						updateViewMode();
						
			      }
	
			      public void widgetDefaultSelected(SelectionEvent event) {
			        //Nothing here
			      }
			    });
		    
		    
		    historyButton.addSelectionListener(new SelectionListener() {
	
			      public void widgetSelected(SelectionEvent event) {
			    	  		tv.setCurrentMode(HISTORY_MODE);
			    	  		historyButton.setEnabled(false);
			    	  		levelButton.setEnabled(true);
			    	  		currentButton.setEnabled(true);
						updateViewMode();
						
			      }
	
			      public void widgetDefaultSelected(SelectionEvent event) {
			        //Nothing here
			      }
			    });
		    
		    currentButton.addSelectionListener(new SelectionListener() {
	
			      public void widgetSelected(SelectionEvent event) {
			    	  		tv.setCurrentMode(CURRENT_MODE);
			    	  		historyButton.setEnabled(true);
			    	  		levelButton.setEnabled(true);
			    	  		currentButton.setEnabled(false);
						updateViewMode();
						
			      }
	
			      public void widgetDefaultSelected(SelectionEvent event) {
			        //Nothing here
			      }
			    });
		    
		    stepButton.addSelectionListener(new SelectionListener() {
	
			      public void widgetSelected(SelectionEvent event) {
			    	  	doStep(thread);	
			      }
	
			      public void widgetDefaultSelected(SelectionEvent event) {
			        //Nothing here
			      }
			    });
		    
			//Add Table
			TableViewer tableViewer = new TableViewer(innerThreadContainer, SWT.MULTI | SWT.WRAP );
			ViewContentProvider vcp = new ViewContentProvider();
			tableViewer.setContentProvider(vcp);
			tableViewer.setLabelProvider(new ViewLabelProvider());
			//tableViewer.setSorter(new NameSorter());
			tableViewer.setInput(getViewSite());
			
			//Set ThreadView
			tv.setViewer(tableViewer);
			tv.setCurrentMode(LEVEL_MODE);
			
			//Make table Actions
			hookDoubleClickAction(tableViewer);
	
			// Create the help context id for the viewer's control
			PlatformUI.getWorkbench().getHelpSystem().setHelp(tableViewer.getControl(), "«graphmodel.tracerPackage».viewer");
			
			threadButtonContainer.pack();
			innerThreadContainer.pack();
			group.pack();
			
			
			mainContainer.update();
			mainContainer.layout();
			mainContainer.redraw();
			
			threadContainer.update();
			threadContainer.layout();
			threadContainer.redraw();
			return tv;
		}
	
	
		private void hookDoubleClickAction(TableViewer tv) {
			
			Action doubleClickAction = new Action() {
				public void run() {
					ISelection selection = tv.getSelection();
					ContentView obj = (ContentView) ((IStructuredSelection)selection).getFirstElement();
					obj.flashElement();
					
				}
			};
			
			tv.addDoubleClickListener(new IDoubleClickListener() {
				public void doubleClick(DoubleClickEvent event) {
					doubleClickAction.run();
				}
			});
		}
		private synchronized void showMessage(String message) {
			MessageDialog.openInformation(
				this.getSite().getShell(),
				"Tracer",
				message);
		}
	
		/**
		 * Passing the focus request to the viewer's control.
		 */
		public void setFocus() {
			this.getSite().getShell().setFocus();
			GraphModel g = WorkbenchUtil.getModel();
			if(g instanceof «graphmodel.graphModel.name»){
				this.«graphmodel.graphModel.name.toFirstLower» = («graphmodel.graphModel.name») g;
				c«graphmodel.graphModel.name» = «graphmodel.graphModel.name»Wrapper.wrapGraphModel( «graphmodel.graphModel.name.toFirstLower»,WorkbenchUtil.getDiagram());
			}
		}
		
		private void startNewTracer(Shell shell)
		{
			this.viewerMap.clear();
			clearHighlighting();
			for(Control c:this.threadContainer.getChildren()){
				c.dispose();
			}
			GraphSimulator gs = new GraphSimulator(c«graphmodel.graphModel.name», c«graphmodel.graphModel.name»ES);
			LTSMatch lstMatch = gs.simulate();
			try {
				stepper = new Stepper(lstMatch,shell,currentSemantic.getContext(),currentSemantic.getSemantic());
				for(Thread t:stepper.getActiveThreads()){
					this.viewerMap.put(t, createThread(t));	
				}
				updateViewMode();
				showMessage("Tracer ready for execution");		
			} catch (TracerException e) {
				showMessage(e.getText());
			}
		}
		
		/**
		 * Prepares the tracer. Checks if a graphmodel and an semantic extension are loaded and if they are not, loads them
		 * @return true if the tracer is prepared
		 */
		private boolean prepare(Shell shell)
		{
			boolean hasToBeReseted = false;
			//Check a graphmodel is selected
			if(«graphmodel.graphModel.name.toFirstLower» == null){  
				showMessage("No Graphmodel present");
			}
			//Inv: graphmodel is successfully loaded
		    if(currentSemantic == null){
			    	ElementListSelectionDialog selection = new ElementListSelectionDialog(
			    			shell,
			    			new LabelProvider() {
				            @Override
				            public String getText(Object element) {
				            		if (element instanceof ExecutionTupel) {
				                    	ExecutionTupel et = (ExecutionTupel) element;
		                            return et.getSemantic().getName();
			                    }
				            		return super.getText(element);
				            }
					    });
			    	selection.setTitle("Semantic Selection");
			    	selection.setMessage("Select a String (* = any string, ? = any char):");
			    	selection.setElements(tupel.toArray());
	
			    if(	selection.open() == Window.OK )
			    {
			    		ExecutionTupel et = (ExecutionTupel) selection.getFirstResult();
			    		if(et == null){
			    			showMessage("No semantics selected.");
			    			return false;
			    		}
			    		currentSemantic = et;
			    		hasToBeReseted = true;
			    }
			    else
			    {
			    		showMessage("No semantics selected.");
			    		return false;
			    }
	
					    
			}
		    
		    if(«graphmodel.graphModel.name.toFirstLower»ES == null)
		    {
		    		ElementTreeSelectionDialog selection = new ElementTreeSelectionDialog(
		    		    Display.getDefault().getActiveShell(), 
		    		    new WorkbenchLabelProvider(), 
		    		    new BaseWorkbenchContentProvider());
		    		selection.setTitle("Pattern Selection");
		    		selection.setAllowMultiple(false);
		    		selection.setInput(ResourcesPlugin.getWorkspace().getRoot());
		    		selection.addFilter(new FileExtensionFilter("«graphmodel.graphModel.name.toLowerCase»es"));
			    	selection.setMessage("Select a String (* = any string, ? = any char):");
			    	
			    	if(	selection.open() == Window.OK )
			    {
			    		Object et = selection.getFirstResult();
			    		if(et == null){
			    			showMessage("No pattern selected.");
			    			return false;
			    		}
			    		«graphmodel.graphModel.name.toFirstLower»ES = WorkspaceUtil.eapi((IFile) et).getGraphModel(«graphmodel.graphModel.name»ES.class);
			    		c«graphmodel.graphModel.name»ES = «graphmodel.graphModel.name»ESWrapper.wrapGraphModel(«graphmodel.graphModel.name.toFirstLower»ES, (Diagram) «graphmodel.graphModel.name.toFirstLower»ES.eResource().getContents().get(0));
			    		hasToBeReseted = true;
			    }
			    else
			    {
			    		showMessage("No pattern selected.");
			    		return false;
			    }
		    }
		    
		    if(hasToBeReseted){
		    		restartTracer(shell);
		    }
			return true;
			
		}
		
		private void doRun(Shell shell)
		{
			GraphSimulator gs = new GraphSimulator(c«graphmodel.graphModel.name», c«graphmodel.graphModel.name»ES);
			LTSMatch lstMatch = gs.simulate();
			currentRunner.startRunner(shell, lstMatch, new RunCallback() {
				@Override
				public void run() {
					RunResult rr = this.getResult();
					Display.getDefault().asyncExec(new Runnable(){
						public void run() {
						    // // Your code to run Asynchronously
							showMessage("Runner ended\n"+currentRunner.displayResults(rr.getActiveRunSteppers(), rr.getInactiveRunSteppers()));
						}
					});
				}
			});
		}
		
		private boolean prepareRunner(Shell shell)
		{
			//Check a graphmodel is selected
			if(«graphmodel.graphModel.name.toFirstLower» == null){
				showMessage("No Graphmodel present");
			}
			if(currentRunner == null){
				
				ElementListSelectionDialog selection = new ElementListSelectionDialog(
						shell,
						new LabelProvider() {
							@Override
							public String getText(Object element) {
								if (element instanceof AbstractRunner) {
									AbstractRunner ar = (AbstractRunner) element;
									return ar.getName();
								}
								return super.getText(element);
							}
						});
				selection.setTitle("Runner Selection");
				selection.setMessage("Select a String (* = any string, ? = any char):");
				selection.setElements(runner.toArray());
				
				if(	selection.open() == Window.OK )
				{
					AbstractRunner ar = (AbstractRunner) selection.getFirstResult();
					if(ar == null){
						showMessage("No runner selected.");
						return false;
					}
					currentRunner = ar;
				}
				else
				{
					showMessage("No runner selected.");
					return false;
				}
			}
			if(«graphmodel.graphModel.name.toFirstLower»ES == null)
		    {
		    		ElementTreeSelectionDialog selection = new ElementTreeSelectionDialog(
		    		    Display.getDefault().getActiveShell(), 
		    		    new WorkbenchLabelProvider(), 
		    		    new BaseWorkbenchContentProvider());
		    		selection.setTitle("Pattern Selection");
		    		selection.setAllowMultiple(false);
		    		selection.setInput(ResourcesPlugin.getWorkspace().getRoot());
		    		selection.addFilter(new FileExtensionFilter("«graphmodel.graphModel.name.toLowerCase»es"));
			    	selection.setMessage("Select a String (* = any string, ? = any char):");
			    	
			    	if(	selection.open() == Window.OK )
			    {
			    		Object et = selection.getFirstResult();
			    		if(et == null){
			    			showMessage("No pattern selected.");
			    			return false;
			    		}
			    		«graphmodel.graphModel.name.toFirstLower»ES = WorkspaceUtil.eapi((IFile) et).getGraphModel(«graphmodel.graphModel.name»ES.class);
			    		c«graphmodel.graphModel.name»ES = «graphmodel.graphModel.name»ESWrapper.wrapGraphModel(«graphmodel.graphModel.name.toFirstLower»ES, (Diagram) «graphmodel.graphModel.name.toFirstLower»ES.eResource().getContents().get(0));
			    }
			    else
			    {
			    		showMessage("No pattern selected.");
			    		return false;
			    }
		    }
			return true;
		}
		
		private void resetTracer()
		{
			//Deactivate all highlighter
			clearHighlighting();
			stepper = null;
			currentSemantic = null;
		}
		
		private void clearHighlighting()
		{
			if(stepper != null) {
				stepper.getActiveThreads().forEach(n->n.getHighlighter().clear());
			}
		}
		
		private void restartTracer(Shell shell)
		{
			startNewTracer(shell);
		}
		
		
		private boolean doStep(Thread thread)
		{
			try {
				if(!stepper.doStep(thread)) {
					showMessage("Execution terminated");
					updateViewMode();					
					return false;
				}
				else{
					updateViewMode();					
				}
			} catch (JointTracerException e) {
				showMessage("Unexpected Termination:\n"+String.join("\n", e.getMessages()));
				updateViewMode();
				return false;
			}
			return true;
		}
		
		private void showContext() {
			if(stepper!=null && currentSemantic != null){
				if(currentSemantic.getContext() != null){
					showMessage("Context\n"+currentSemantic.getContext().toString());				
				}
				else {
					showMessage("No Context present");
				}
			}
			else{
				showMessage("No active Execution");
			}
		}
		
		private void updateViewMode()
		{
			for(Thread thread:this.stepper.getActiveThreads()){
				if(!this.viewerMap.containsKey(thread)){
					this.viewerMap.put(thread, createThread(thread));	
				}
			}
			// check known threads
			List<Thread> removedThreads = new LinkedList<Thread>();
			for(Entry<Thread, ThreadView> entry:this.viewerMap.entrySet()){
				if(this.stepper.getActiveThreads().contains(entry.getKey())){
					if(entry.getValue().getCurrentMode() == LEVEL_MODE){			
						((ViewContentProvider) entry.getValue().getViewer().getContentProvider()).setLevels(entry.getKey().displayLevel());	
						//Highlight
						entry.getKey().highlightLevels();
					}
					if(entry.getValue().getCurrentMode() == HISTORY_MODE){
						((ViewContentProvider) entry.getValue().getViewer().getContentProvider()).setLevels(entry.getKey().displayHistory());
						//Highlight
						entry.getKey().highlightHistory();
					}
					if(entry.getValue().getCurrentMode() == CURRENT_MODE){
						((ViewContentProvider) entry.getValue().getViewer().getContentProvider()).setLevels(entry.getKey().displayHistory());
						//Highlight
						entry.getKey().highlightCurrent();
					}
					
					//Refresh the views
					entry.getValue().getViewer().refresh();		
					
					entry.getValue().getViewer().getControl().pack();
					entry.getValue().getViewer().getControl().getParent().pack();
					entry.getValue().getViewer().getControl().getParent().getParent().pack();
					
					mainContainer.update();
					mainContainer.layout();
					mainContainer.redraw();
					
					threadContainer.update();
					threadContainer.layout();
					threadContainer.redraw();
				}
				else{
					//Deactivated Thread
					//deactivate highlight
					entry.getKey().getHighlighter().clear();
					entry.getValue().getViewer().getControl().getParent().getParent().dispose();
					removedThreads.add(entry.getKey());
				}
			}
			//remove deactivated threads from view
			removedThreads.forEach(n->this.viewerMap.remove(n));
		}
	}
	'''
	
}