package de.jabc.cinco.meta.core.utils;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.xtext.util.StringInputStream;

public class BuildProperties {
	
	
	private Properties buildProperties;
	
	private static final String BIN_INCLUDES= "bin.includes";
	private static final String BIN_EXCLUDES= "bin.excludes";
	private static final String SRC_INCLUDES= "src.includes";
	private static final String SRC_EXCLUDES= "src.excludes";
	private static final String SOURCE ="source..";
	
	private BuildProperties(Properties buildProperties){
		this.buildProperties = buildProperties;
	}
	
	
	public static BuildProperties loadBuildProperties(IFile buildPropertiesFile) throws IOException, CoreException{
		Properties buildProperties = new Properties();
		buildProperties.load(buildPropertiesFile.getContents());
		return new BuildProperties(buildProperties);
	}
	
	
	public String getProperty(String key){
		return buildProperties.getProperty(key, "");
	}
	
	public String getProperty(String key, String defaultValue){
		return buildProperties.getProperty(key, defaultValue);
	}
	
	public void putProperty(String key, String value){
		this.buildProperties.setProperty(key, value);
	}
	
	public void appendBinIncludes(String value){
		appendProperty(value, BIN_INCLUDES);
	}
	
	public void setBinIncludes(String value){
		this.buildProperties.setProperty(BIN_INCLUDES,value);
	}
	
	public String getBinIncludes(){
		return getProperty(BIN_INCLUDES, "");
	}
	
	private void appendProperty(String value,String property){
		String oldValue = this.buildProperties.getProperty(property, "");
		if(!oldValue.equals(""))
			this.buildProperties.setProperty(property,String.format("%s,\\\n%s",oldValue,value));
		else
			this.buildProperties.setProperty(property, value);
	}
	
	public void setBinExcludes(String value){
		this.buildProperties.setProperty(BIN_EXCLUDES,value);
	}
	
	public String getBinExcludes(){
		return getProperty(BIN_EXCLUDES, "");
	}
	
	public void appendBinExcludes(String value){
		appendProperty(value, BIN_EXCLUDES);
	}

	
	public void appendSrcIncludes(String value){
		appendProperty(value, SRC_INCLUDES);
	}
	
	public void setSrcIncludes(String value){
		this.buildProperties.setProperty(SRC_INCLUDES,value);
	}
	
	public String getSrcIncludes(){
		return getProperty(SRC_INCLUDES, "");
	}
	
	
	public void setSrcExcludes(String value){
		this.buildProperties.setProperty(SRC_EXCLUDES,value);
	}
	
	public String getSrcExcludes(){
		return getProperty(SRC_EXCLUDES, "");
	}
	
	public void appendSrcExcludes(String value){
		appendProperty(value, SRC_EXCLUDES);
	}
	
	


	
	
	public boolean isCustom(){
		return getProperty("custom","false").equals("true");
	}
	
	public void setCustom(boolean custom){
		putProperty("custom",new StringBuilder().append(custom).toString());
	}
	
	
	public void store(IFile out,IProgressMonitor monitor) throws CoreException{
		InputStream input = new StringInputStream(this.toString());
		if(out.exists()){
			out.setContents(input, true, true, monitor);
		}else{
			out.create(input, true, monitor);
		}
		
	}

	@Override
	public String toString(){
		StringBuilder builder = new StringBuilder();
		for(Object keyObj: this.buildProperties.keySet()){
			String key = (String)keyObj;
			builder.append(String.format("%s = %s",key,getProperty(key)));
			builder.append("\n");
		}
		return builder.toString();
	}


	public void appendSource(String string) {
		appendProperty(string, SOURCE);
		
	}

}
