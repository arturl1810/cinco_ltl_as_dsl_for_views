package de.jabc.cinco.meta.plugin.template

class SelectSheetDialogTemplate {
	def create(String packageName)'''
package «packageName»;

import java.util.ArrayList;

import «packageName».UserInteraction;

import org.eclipse.jface.dialogs.IMessageProvider;
import org.eclipse.jface.dialogs.TitleAreaDialog;
import org.eclipse.swt.SWT;
import org.eclipse.jface.dialogs.MessageDialog;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.events.SelectionListener;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Combo;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.Shell;

public class SelectSheetDialog extends TitleAreaDialog {

  private String sheetName = null;

  private String resultNodeId;
  private String[] sheets;
  private SelectSheetDialog myself;
  private Combo c;
  private boolean creationEnabled;
  
  
  public SelectSheetDialog(Shell parentShell,String resultNodeId,ArrayList<String> sheets,boolean creationEnabled) {
    super(parentShell);
    this.resultNodeId=resultNodeId;
    this.myself=this;
    this.creationEnabled=creationEnabled;
    this.sheets=new String[sheets.size()];
    int index=0;
    for(String sheet : sheets) {
    	this.sheets[index]=sheet;
    	index++;
    }
  }
  @Override
  public void create() {
    super.create();
    setTitle("Select a Spreadsheet");
    setMessage("Choose a Spreadsheet from the list or create a new one", IMessageProvider.INFORMATION);
  }

  @Override
  protected Control createDialogArea(Composite parent) {
    Composite area = (Composite) super.createDialogArea(parent);
    Composite container = new Composite(area, SWT.NONE);
    container.setLayoutData(new GridData(GridData.FILL_BOTH));
    GridLayout layout = new GridLayout(2, false);
    container.setLayoutData(new GridData(SWT.FILL, SWT.FILL, true, true));
    container.setLayout(layout);

    createSheetName(container);

    return area;
  }

  private void createSheetName(Composite container) {
	Label lbtFirstName = new Label(container, SWT.NONE);
	GridData dataFirstName = new GridData();
	if(creationEnabled) {
	    
	    lbtFirstName.setText("Create a new Spreadsheet");
	
	    
	    dataFirstName.grabExcessHorizontalSpace = true;
	    dataFirstName.horizontalAlignment = GridData.FILL;
	    
	    Button button = new Button(container, SWT.PUSH);
	    button.setText("New");
	    button.addSelectionListener(new SelectionListener() {
	
	        public void widgetSelected(SelectionEvent event) {
	        	sheetName = UserInteraction.getNewSheetName(resultNodeId);
	        	if(sheetName!=null)
	        	{
	        		myself.okPressed();
	        	}
	        	else
	        	{
	        		myself.cancelPressed();
	        	}
	        	
	        }
	
			@Override
			public void widgetDefaultSelected(SelectionEvent arg0) {
				// TODO Auto-generated method stub
				
			}
	
	      });
	}
    // create a new label which is used as a separator
    lbtFirstName = new Label(container, SWT.SEPARATOR | SWT.HORIZONTAL);
    
    // create new layout data
    dataFirstName = new GridData(SWT.FILL, SWT.TOP, true, false);
    dataFirstName.horizontalSpan = 2;
    lbtFirstName.setLayoutData(dataFirstName);
    
    //Create the sheet-name chooser
    GridData gridData = new GridData(SWT.FILL, SWT.FILL, true, false);
    gridData.widthHint = SWT.DEFAULT;
    gridData.heightHint = SWT.DEFAULT;
    gridData.horizontalSpan = 2;
    
    c = new Combo(container, SWT.READ_ONLY);
    //c.setBounds(50, 50, 150, 65);
    c.setLayoutData(gridData);
    c.setItems(sheets);
    c.select(0);
  }



  @Override
  protected boolean isResizable() {
    return true;
  }

  // save content of the Text fields because they get disposed
  // as soon as the Dialog closes
  private void saveInput() {
	  if(sheetName==null)
	  {
		  if(creationEnabled)
		  {
			  boolean result =  MessageDialog.openConfirm(this.getShell(), "Confirm", "The existing sheet will be overwritten.");
			  if(!result)
			  {
				  return;
			  }
		  }
		  sheetName = c.getItem(c.getSelectionIndex());
	  }
  }

  @Override
  protected void okPressed() {
    saveInput();
    super.okPressed();
  }

  public String getSheetName() {
    return sheetName;
  }
}
'''
}