package de.jabc.cinco.meta.core.mgl.valueconverters;

import org.eclipse.xtext.EcoreUtil2;
import org.eclipse.xtext.common.services.Ecore2XtextTerminalConverters;
import org.eclipse.xtext.conversion.IValueConverter;
import org.eclipse.xtext.conversion.ValueConverter;
import org.eclipse.xtext.conversion.ValueConverterException;
import org.eclipse.xtext.nodemodel.INode;

import de.jabc.cinco.meta.core.mgl.services.MGLGrammarAccess.EIntElements;

import org.eclipse.emf.codegen.util.CodeGenUtil.EclipseUtil;
import org.eclipse.emf.ecore.EDataType;
import org.eclipse.emf.ecore.EcoreFactory;
import org.eclipse.emf.ecore.EcorePackage;
import org.eclipse.emf.ecore.xmi.impl.EcoreResourceFactoryImpl;
import mgl.EDataTypeType;
public class BoundValueConverter extends Ecore2XtextTerminalConverters {
	@ValueConverter(rule = "BoundValue")
	public IValueConverter<Integer> BoundValue(){
		
		return new IValueConverter<Integer>(){

			@Override
			public Integer toValue(String string, INode node)
					throws ValueConverterException {
				if(string.trim().equals("*"))
					return -1;
				
				try{
					return Integer.parseInt(string.trim());
				}catch(NumberFormatException ne){
					throw new ValueConverterException("Can not convert "+string.trim() + "to integer", node, ne);
				}
			}

			@Override
			public String toString(Integer value)
					throws ValueConverterException {
				if(value.equals(-1))
					return "*";
				
				return value.toString();
			}
			
		};
		
	}
	@ValueConverter(rule = "URI")
	public IValueConverter<String> URI(){
		return new IValueConverter<String>(){

			@Override
			public String toValue(String string, INode node)
					throws ValueConverterException {
				// TODO Auto-generated method stub
				return string.replaceAll("\"", "");
			}

			@Override
			public String toString(String value) throws ValueConverterException {
				// TODO Auto-generated method stub
				return value;
			}
				
		};
	}
	
	
	
}
