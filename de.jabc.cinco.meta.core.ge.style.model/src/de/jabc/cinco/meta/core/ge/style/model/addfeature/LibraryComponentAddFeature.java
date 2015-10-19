package de.jabc.cinco.meta.core.ge.style.model.addfeature;

import java.util.ArrayList;
import java.util.List;

import org.eclipse.graphiti.features.IAddFeature;
import org.eclipse.graphiti.features.IFeatureProvider;
import org.eclipse.graphiti.features.context.IAddContext;
import org.eclipse.graphiti.features.impl.AbstractAddShapeFeature;
import org.eclipse.graphiti.mm.pictograms.PictogramElement;
import org.eclipse.swt.SWT;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Listener;
import org.eclipse.swt.widgets.Menu;
import org.eclipse.swt.widgets.MenuItem;
import org.eclipse.swt.widgets.Shell;

import de.jabc.cinco.meta.core.ge.style.model.featureprovider.CincoFeatureProvider;

public class LibraryComponentAddFeature extends AbstractAddShapeFeature {

	private IAddFeature selectedFeature;
	
	public LibraryComponentAddFeature(IFeatureProvider fp) {
		super(fp);
		// TODO Auto-generated constructor stub
	}

	@Override
	public boolean canAdd(IAddContext context) {
		if (possibleFeatureExists(context)) {
			return true;
		}
		return false;
	}

	@Override
	public PictogramElement add(IAddContext context) {
		List<IAddFeature> features = getPossibleFeatures(context);
		org.eclipse.swt.graphics.Point pos = Display.getCurrent().getCursorLocation();
		
		if (features.size() == 1) {
			IAddFeature iAddFeature = features.get(0);
			if (iAddFeature.canAdd(context))
				return iAddFeature.add(context);
		}
		
		final Shell shell = new Shell (Display.getCurrent().getActiveShell());
		
		Menu menu = new Menu (shell, SWT.POP_UP);
		MenuItem item = null; 
		for (IAddFeature af : features) {
			item = new MenuItem (menu, SWT.PUSH);
			item.setText (af.getClass().getSimpleName());
			item.setData(af);
			item.addListener (SWT.Selection, selectionListener);
		}
		
		menu.setLocation (pos.x, pos.y);
		menu.setVisible (true);
		while (!menu.isDisposed () && menu.isVisible ()) {
			if (!shell.getDisplay().readAndDispatch ()) 
				shell.getDisplay().sleep ();
		}
		menu.dispose();
		shell.dispose();
		
		System.out.println(selectedFeature);
		if (selectedFeature instanceof IAddFeature) {
			if (selectedFeature.canAdd(context))
				return selectedFeature.add(context);
		}
		
		return null;
	}

	private boolean possibleFeatureExists(IAddContext context) {
		for (IAddFeature f : ((CincoFeatureProvider) getFeatureProvider()).getAllAddFeatures()) {
			if (f.canAdd(context)) {
				return true;
			}
		}
		return false;
	}

	
	private List<IAddFeature> getPossibleFeatures(IAddContext context) {
		List<IAddFeature> features = new ArrayList<IAddFeature>();
		for (IAddFeature f : ((CincoFeatureProvider) getFeatureProvider()).getAllAddFeatures()) {
			if (f.canAdd(context)) {
				features.add(f);
			}
		}
		return features;
	}
	
	Listener selectionListener = new Listener() {
		
		@Override
		public void handleEvent(Event event) {
			Object data = event.widget.getData();
			if (data instanceof IAddFeature) {
				selectedFeature = (IAddFeature) data;
			}
		}
	};
	

}
