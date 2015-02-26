package de.jabc.cinco.meta.plugin.spreadsheet;

import java.util.ArrayList;
import java.util.List;

import mgl.Annotation;

import org.eclipse.xtext.ui.editor.contentassist.ConfigurableCompletionProposal.IReplacementTextApplier;

import de.jabc.cinco.meta.core.pluginregistry.proposalprovider.IMetaPluginAcceptor;
import de.jabc.cinco.meta.core.utils.xtext.ChooseFileTextApplier;

public class SpreadsheetAcceptor implements IMetaPluginAcceptor {
	
	public SpreadsheetAcceptor() {
	}

	@Override
	public List<String> getAcceptedStrings(Annotation annotation) {
		ArrayList<String> aList = new ArrayList<>();
		if(annotation.getName().equals("spreadsheet")){
			if(annotation.getValue().size()==1) {
				aList.add("\"single\"");
				aList.add("\"multiple\"");				
			}
		}
		if(annotation.getName().equals("resulting")){
			if(annotation.getValue().size()==1) {
				aList.add("Choose file...");
			}
		}
		
		return aList;
		
	}

	@Override
	public IReplacementTextApplier getTextApplier(Annotation annotation) {
		if(annotation.getName().equals("resulting") && annotation.getValue().size()==1) {
			String[] fileExt = {"*.xls"};
			String[] fileNames = {"Microsoft Excel Spreadsheet (xls)"};
			return new ChooseFileTextApplier(annotation,fileExt,fileNames,false);

		}
		return null;
	}

}
