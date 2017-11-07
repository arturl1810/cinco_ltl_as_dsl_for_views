package de.jabc.cinco.meta.core.ui.editor

import org.eclipse.ui.IEditorActionBarContributor
import org.eclipse.ui.IEditorInput
import org.eclipse.ui.IEditorPart

interface PageAwareEditor extends IEditorPart, InnerStateAwareness, PageAwareness {
	
	/**
	 * @return The name of the page that is used as label for the tab indicator
	 *   in a multi-page editor.
	 */
	def String getPageName()
	
	/**
	 * Maps the editor input on an input of required type. Specifically useful,
	 * if the editor requires the input to be of specific type while at the same
	 * implementing the interface {@link PageAwareEditorInput}.
	 * 
	 * @return The page-aware editor input.
	 */
	def PageAwareEditorInput mapEditorInput(IEditorInput input)
	
	/**
     * Create the contributor, which is expected to add contributions as required
     * to action bars and global action handlers. Typically called in an multi-page
     * editor when this page is activated.
     * <p>
     * The contributor still needs to be initialized by passing bars and page to the
     * {@link IEditorActionBarContributor#init init} method in order to support the
     * use of {@code RetargetAction} by the contributor. In this case the init method
     * implementors should:
     * </p>
     * <p><ul>
     * <li>1) set retarget actions as global action handlers</li>
     * <li>2) add the retarget actions as part listeners</li>
     * <li>3) get the active part and if not <code>null</code>
     * call partActivated on the retarget actions</li>
     * </ul></p>
     * <p>
     * And in the {@link IEditorActionBarContributor#dispose dispose} method the
     * retarget actions should be removed as part listeners.
     * </p>
     *
     * @param bars the action bars
     * @param page the workbench page for this contributor
     * @return the initialized contributor.
     */
	def IEditorActionBarContributor getActionBarContributor()
	
	/**
	 * Retrieves the resource contributor that contributes content to the resource that
	 * represents the inner state of a multi-page editor.
	 * 
	 * @return The contributor, or {@code null} if no contribution is desired.
	 */
	def ResourceContributor getResourceContributor()
}