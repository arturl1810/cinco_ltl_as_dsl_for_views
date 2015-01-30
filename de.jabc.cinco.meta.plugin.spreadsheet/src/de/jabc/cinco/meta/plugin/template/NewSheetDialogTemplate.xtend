package de.jabc.cinco.meta.plugin.template

class NewSheetDialogTemplate {
	def create(String packageName)'''
package «packageName»;

import org.eclipse.jface.dialogs.IMessageProvider;
import org.eclipse.jface.dialogs.TitleAreaDialog;
import org.eclipse.swt.SWT;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Text;

public class NewSheetDialog extends TitleAreaDialog {

  private Text sheetNameText;

  private String sheetName;

  private String message;
  
  public NewSheetDialog(Shell parentShell,String message) {
    super(parentShell);
    this.message=message;
  }

  public void create() {
    super.create();
    setTitle("Create a new Spreadsheet");
    setMessage("Choose a name for your Spreadsheet\n", IMessageProvider.INFORMATION);
   
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
    
    Label lbtFirstName = new Label(container, SWT.NONE);
    lbtFirstName.setText(message);
    
    return area;
  }

  private void createSheetName(Composite container) {
    Label lbtFirstName = new Label(container, SWT.NONE);
    lbtFirstName.setText("Spreadsheetname");

    GridData dataFirstName = new GridData();
    dataFirstName.grabExcessHorizontalSpace = true;
    dataFirstName.horizontalAlignment = GridData.FILL;

    sheetNameText = new Text(container, SWT.BORDER);
    sheetNameText.setLayoutData(dataFirstName);
  }



  @Override
  protected boolean isResizable() {
    return true;
  }

  // save content of the Text fields because they get disposed
  // as soon as the Dialog closes
  private void saveInput() {
    sheetName = sheetNameText.getText();

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