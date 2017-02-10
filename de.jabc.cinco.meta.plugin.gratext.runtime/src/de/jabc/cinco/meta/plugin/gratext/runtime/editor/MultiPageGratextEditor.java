package de.jabc.cinco.meta.plugin.gratext.runtime.editor;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.concurrent.LinkedTransferQueue;

import org.eclipse.core.resources.IMarker;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.emf.common.notify.Notifier;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.util.EcoreUtil;
import org.eclipse.emf.edit.domain.EditingDomain;
import org.eclipse.emf.edit.domain.IEditingDomainProvider;
import org.eclipse.emf.transaction.TransactionalEditingDomain;
import org.eclipse.emf.transaction.impl.InternalTransactionalEditingDomain;
import org.eclipse.emf.transaction.impl.TransactionChangeRecorder;
import org.eclipse.emf.transaction.util.TransactionUtil;
import org.eclipse.emf.workspace.WorkspaceEditingDomainFactory;
import org.eclipse.jface.dialogs.ErrorDialog;
import org.eclipse.jface.dialogs.MessageDialog;
import org.eclipse.ui.IEditorInput;
import org.eclipse.ui.IEditorPart;
import org.eclipse.ui.IFileEditorInput;
import org.eclipse.ui.PartInitException;
import org.eclipse.ui.PlatformUI;
import org.eclipse.ui.ide.IDE;
import org.eclipse.ui.ide.IGotoMarker;
import org.eclipse.ui.part.EditorPart;
import org.eclipse.ui.part.MultiPageEditorPart;
import org.eclipse.xtext.resource.XtextResource;
import org.eclipse.xtext.ui.editor.XtextEditor;
import org.eclipse.xtext.ui.editor.model.XtextDocument;
import org.eclipse.xtext.util.concurrent.IUnitOfWork;

import de.jabc.cinco.meta.plugin.gratext.runtime.resource.GratextResource;
import de.jabc.cinco.meta.runtime.xapi.WorkbenchExtension;



public abstract class MultiPageGratextEditor extends MultiPageEditorPart implements IEditingDomainProvider, IGotoMarker {

	private static WorkbenchExtension workbench = new WorkbenchExtension();
	
	private XtextEditor sourceEditor;
    private ArrayList<PageAwareEditorPart> pawEditors = new ArrayList<>();
    private HashMap<PageAwareEditorPart, PageAwareEditorDescriptor> pawEditorDescriptors = new HashMap<>();
	
    private GratextResource innerState;
    private int currentPage = -1;
    private boolean awaitingResourceUpdate;
    
    public MultiPageGratextEditor() {
        super();
    }
    
    protected abstract Iterable<PageAwareEditorDescriptor> getEditorDescriptors();
    
    protected abstract XtextEditor getSourceEditor();
    
    /**
     * Generates Gratext source code to be used for updating the inner state of the
     * Xtext editor according to the changes made by the specified editor.
     * 
     * @param editor The editor that changed the inner state.
     * @param innerState The resource representing the shared inner state of the editor pages.
     * @return The Gratext source code reflecting the current state.
     */
    protected String generateSourceCode(IEditorPart editor) {
    		try {
    			return pawEditorDescriptors.get(editor).getSourceCodeGenerator().apply(getInnerState());
    		} catch(NullPointerException e) {
    			e.printStackTrace();
    			return null;
    		}
    }
    
    /**
     * Creates the pages of the multi-page editor.
     */
    protected void createPages() {
		createSourceEditorPage();
		/*
		 * The XtextEditor does not use an EditingDomain. However, at this point
		 * a XtextResource has been created and a default EditingDomain has been
		 * registered that unfortunately is incompatible with the diagram editor.
		 * To solve this, unregister the EditingDomain and let the diagram editor
		 * create one itself.
		 */
		unregisterEditingDomain();
		getEditorDescriptors().forEach(editor -> createEditorPage(editor));
		setTitle();
    }
    
    private void unregisterEditingDomain() {
		EditingDomain domain = getEditingDomain();
		if (domain == null) return;
		if (domain instanceof TransactionalEditingDomain) {
			WorkspaceEditingDomainFactory.INSTANCE.unmapResourceSet(
					(TransactionalEditingDomain) domain);
		}
		// disconnect change recorder if existent
		if (domain instanceof InternalTransactionalEditingDomain) {
			TransactionChangeRecorder recorder = ((InternalTransactionalEditingDomain) domain).getChangeRecorder();
			if (recorder != null) {
				domain.getResourceSet().getResources().forEach(res -> 
					EcoreUtil.getAllProperContents(Collections.singleton(res), false).forEachRemaining(it ->
						((Notifier) it).eAdapters().remove(recorder)));
			}
		}
	}
    
    protected void createSourceEditorPage() {
    	sourceEditor = getSourceEditor();
		IEditorInput input = getEditorInput();
		workbench.sync(() -> {
			try {
				int index = addPage(sourceEditor, input);
				setPageText(index, "Source");
			} catch (PartInitException e) {
				ErrorDialog.openError(getSite().getShell(),
						"Error creating nested editor", null, e.getStatus());
			}
		});
	}
    
	protected void createEditorPage(PageAwareEditorDescriptor desc) {
		PageAwareEditorPart editor = desc.newEditor();
		pawEditors.add(editor);
		pawEditorDescriptors.put(editor, desc);
		
		PageAwareEditorInput input = desc.getInputMapper().apply(getEditorInput());
		input.setInnerStateSupplier(() -> getInnerState());
		
		int index = Math.max(0, getPageCount() - 1);
		String name = desc.getName() != null ? desc.getName() : editor.getClass().getSimpleName();
		
		workbench.sync(() -> {
			try {
				addPage(index, editor , input);
				setPageText(index, name);
			} catch (PartInitException e) {
				ErrorDialog.openError(getSite().getShell(),
						"Error creating nested editor", null, e.getStatus());
			}
		});
	}
    
	protected void setTitle() {
		try {
			setPartName(((IFileEditorInput) getEditorInput())
					.getFile()
					.getProjectRelativePath()
					.removeFileExtension()
					.lastSegment());
		} catch (Exception e) {
			try {
				setPartName(getEditorInput().getName());
			} catch (Exception e1) {/* ignore */}
		}
	}
	    
    @Override
    public boolean isSaveAsAllowed() {
        return false;
    }
	
    public void doSaveAs() {
    	throw new UnsupportedOperationException();
    }
    
    @Override
    public void doSave(IProgressMonitor monitor) {
    	if (awaitingResourceUpdate || !UpdatingEditorsRegistry.INSTANCE.isEmpty()) {
    		showSaveInProgress();
    		return;
    	}
    	IEditorPart editor = getActiveEditor();
		if (isDirty()) try {
			if (editor != sourceEditor
					&& innerState != null
					&& innerState instanceof GratextResource) {
				((GratextResource) innerState).skipInternalStateUpdate();
				((GratextResource) innerState).onNewParseResult(() -> {
					awaitingResourceUpdate = false;
				});
				awaitingResourceUpdate = true;
			}
			if (editor == sourceEditor) try {
				Thread.sleep(500);
			} catch(InterruptedException e) {
				e.printStackTrace();
			}
			updateInnerState(editor);
			sourceEditor.doSave(monitor);
			pawEditors.forEach(pawEditor -> pawEditor.handleSaved());
		} catch(Exception e) {
			handleSaveError(editor, e);
		}
	}
    
    protected void handleSaveError(IEditorPart editor, Exception e) {
		e.printStackTrace();
		if (sourceEditor == getActiveEditor() && showSourceEditorOnSaveError()) {
			setActiveEditor(sourceEditor);
		}
    }

    protected boolean activatePage(IEditorPart editor, IEditorPart prevEditor) {
		if (editor instanceof PageAwareEditorPart) try {
			((PageAwareEditorPart) editor).handlePageActivated(prevEditor);
		} catch(Exception e) {
			handlePageActivationError(editor, e);
			return false;
		}
		return true;
    }
    
    protected void handlePageActivationError(IEditorPart pageEditor, Exception e) {
		e.printStackTrace();
		if (getActiveEditor() == sourceEditor && showSourceEditorOnActivationError()) {
			switchToEditor(sourceEditor);
		}
    }

    protected boolean deactivatePage(IEditorPart editor, IEditorPart nextEditor) {
		if (editor instanceof PageAwareEditorPart) try {
    		((PageAwareEditorPart) editor).handlePageDeactivated(nextEditor);
		} catch(Exception e) {
			handlePageDeactivationError(editor, e);
			return false;
		}
    	return true;
    }
    
    protected void handlePageDeactivationError(IEditorPart pageEditor, Exception e) {
		e.printStackTrace();
		if (leavePageOnDeactivationError()) {
			switchToEditor(sourceEditor);
		}
    }
    
//    protected void interceptDocumentChanges() {
//    	IXtextDocument doc = sourceEditor.getDocument();
//    	System.out.println("[MPGE] listen to " + doc);
//    	if (documentListener == null) {
//    		documentListener = new IDocumentListener() {
//				
//				boolean undoNextAction = false;
//				boolean undoInProgress = false;
//				
//				@Override
//				public void documentChanged(DocumentEvent event) {
//					System.out.println("[DocListener-" + hashCode() + "] doc " + doc.hashCode() + " changed: " + event);
//					if (undoNextAction && !undoInProgress) {
//						System.out.println("[DocListener-" + hashCode() + "] undo! ");
//						undoInProgress = true;
//						async(() -> {
//							if (proceedAndLooseUndoHistory()) {
//								doc.removeDocumentListener(this);
//							} else try {
//								revertInnerState();
////								pawEditors.forEach(editor -> editor.handleInnerStateChanged(sourceEditor));
//							} catch(Exception e) {
//								e.printStackTrace();
//							} finally {
//								undoInProgress = false;
//								undoNextAction = false;
//							}
//						});
//					}
//				}
//				
//				@Override
//				public void documentAboutToBeChanged(DocumentEvent event) {
//	//					System.out.println("[Gratext] doc " + doc.hashCode() + " about to be changed: " + event);
//					if (!undoInProgress) undoNextAction = true;
//				}
//			};
//    	}
//    	doc.addDocumentListener(documentListener);
//    }
    
    protected void updateInnerState(IEditorPart triggerEditor) {
		if (triggerEditor != null
				&& triggerEditor != sourceEditor
				&& triggerEditor.isDirty()) {
			XtextDocument doc = (XtextDocument) sourceEditor.getDocument();
			String text = generateSourceCode(triggerEditor);
    		if (text != null) {
    			doc.stopListenerNotification();
    			doc.set(text);
    			doc.resumeListenerNotification();
    		} else System.err.println(
				"[GratextEditor] WARN: Failed to reconcile inner state. "
				+ "Generated source code is null for " + triggerEditor);
		}
    }
    
//    protected void revertInnerState() {
//    	XtextDocument doc = (XtextDocument) sourceEditor.getDocument();
//		if (textOnLastUpdate != null) {
//			TextViewer viewer = (TextViewer) sourceEditor.getInternalSourceViewer();
//			viewer.setRedraw(false);
//			doc.stopListenerNotification();
//			doc.set(textOnLastUpdate);
//			doc.resumeListenerNotification();
//			viewer.setRedraw(true);
//		} else System.err.println(
//			"[GratextEditor] WARN: Failed to revert inner state. "
//			+ "Generated source code is null.");
//    }
    
	@Override
	protected void pageChange(int newPageIndex) {
		IEditorPart newEditor = getActiveEditor();
		if (currentPage != newPageIndex) {
			if (newPageIndex != getSourceEditorIndex()
					&& getInnerState().getParseResult().hasSyntaxErrors()) {

				setActiveEditor(sourceEditor);
				showEditorContainsSyntaxErrors();
				return;
			}
			IEditorPart prevEditor = currentPage > -1 ? getEditor(currentPage) : null;
			if (prevEditor != null
					&& prevEditor != sourceEditor
					&& prevEditor.isDirty()
					&& !proceedAndLooseUndoHistory()) {
				setActiveEditor(prevEditor);
				return;
			}
			if (prevEditor != null) {
				deactivatePage(prevEditor, newEditor);
				updateInnerState(prevEditor);
			}
			activatePage(newEditor, prevEditor);
			super.pageChange(newPageIndex);
			currentPage = newPageIndex;
		}
	}
    
    protected boolean showSourceEditorOnSaveError() {
		return MessageDialog.openQuestion(PlatformUI.getWorkbench().getActiveWorkbenchWindow().getShell(),
			"Saving failed", "Failed to save editor page.\n"
					+ "Would you like to open the source page to fix errors?");
	}
    
	protected boolean showSourceEditorOnActivationError() {
		return MessageDialog.openQuestion(PlatformUI.getWorkbench().getActiveWorkbenchWindow().getShell(),
			"Switching editor page failed", "Failed to activate editor page.\n"
					+ "Would you like to open the source page to fix errors?");
	}
	
	protected boolean leavePageOnDeactivationError() {
		return MessageDialog.openQuestion(PlatformUI.getWorkbench().getActiveWorkbenchWindow().getShell(),
			"Switching editor page failed", "Failed to deactivate editor page.\n"
					+ "Leaving the current page might result in the loss of changes.\n"
					+ "Would you still like to leave this page?");
	}
	
	protected boolean proceedAndLooseUndoHistory() {
		return MessageDialog.openQuestion(PlatformUI.getWorkbench().getActiveWorkbenchWindow().getShell(),
			"Pending model changes",
				"There are unsaved changes.\n"
				+ "If you switch editor pages you wont be able to come back and undo any of these changes.\n\n"
				+ "Do you want to proceed?");
	}
	
	protected void showEditorContainsSyntaxErrors() {
		MessageDialog.openError(PlatformUI.getWorkbench().getActiveWorkbenchWindow().getShell(),
			"Switching editor page failed", "The source code contains errors.\n"
					+ "Please resolve them before switching to another editor page.");
	}
	
	protected void showSaveInProgress() {
		MessageDialog.openInformation(PlatformUI.getWorkbench().getActiveWorkbenchWindow().getShell(),
			"Saving editor state canceled", "The preceding saving process has not finished, yet.\n"
					+ "Please try again later.");
	}
	
	protected void switchToEditor(EditorPart editor) {
		setActiveEditor(editor);
	}

    /* (non-Javadoc)
     * @see org.eclipse.ui.ide.IGotoMarker
     */
    public void gotoMarker(IMarker marker) {
        setActivePage(getSourceEditorIndex());
        IDE.gotoMarker(sourceEditor, marker);
    }

	@Override
	public EditingDomain getEditingDomain() {
		Resource state = getInnerState();
		if (state != null) {
			return TransactionUtil.getEditingDomain(state);
		}
		return null;
	}
	
	protected GratextResource getInnerState() {
		int hash = (innerState != null) ? innerState.hashCode() : 0;
		if (sourceEditor != null) {
			/*
			 * this is a rather tricky way to find the resource that holds
			 * the inner state that the Xtext Editor works with.
			 */
    		XtextDocument doc = (XtextDocument) sourceEditor.getDocument();
    		if (doc != null) {
	    		doc.internalModify(new IUnitOfWork.Void<XtextResource>() {
					@Override
					public void process(XtextResource state) throws Exception {
						innerState = (GratextResource) state;
					}
				});
    		}
		}
		if (innerState != null) {
			if (hash != 0 && innerState.hashCode() != hash) {
				// the inner state is NOT supposed to change during editor lifetime
				System.err.println("[" + getClass().getSimpleName() + "] "
						+ "WARN: inner state changed: hash " + hash + " => " + innerState.hashCode());
				pawEditors.forEach(PageAwareEditorPart::handleNewInnerState);
			}
			if (innerState instanceof GratextResource) {
				((GratextResource) innerState).onInternalStateChanged(() -> {
					pawEditors.forEach(editor -> workbench.async(() -> {
						UpdatingEditorsRegistry.INSTANCE.put(editor);
						editor.handleInnerStateChanged();
						UpdatingEditorsRegistry.INSTANCE.poll();
					}));
				});
			} else {
				// this editor is NOT supposed to work with incompatible resources
				System.err.println("[" + getClass().getSimpleName() + "] "
						+ "WARN: inner state should be GratextResource: " + innerState.getClass());
			}
		}
		return innerState;
	}
	
	protected int getSourceEditorIndex() {
		return getPageCount() - 1;
	}
	
	private static class UpdatingEditorsRegistry {
		public static LinkedTransferQueue<IEditorPart> INSTANCE = new LinkedTransferQueue<>();
	}
}
