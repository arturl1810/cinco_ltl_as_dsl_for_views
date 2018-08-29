package de.jabc.cinco.meta.plugin.stack;

import mgl.Node;

public class Constants {
	public static final String PROJECT_ANNOTATION = "stackable";
	public static final String PROJECT_SUFFIX = "stack";
	public static final String HOOK_PACKAGE_SUFFIX = ".hooks";
	
	
	public static String getPostMoveHookClassName(Node node){
		return node.getName() + "PostMoveStacker";
	}
	public static String getPostCreateHookClassName(Node node){
		return node.getName() + "PostCreateStacker";
	}
	public static String projectPackage(Node node){
		return node.getGraphModel().getPackage() + "." + Constants.PROJECT_SUFFIX + HOOK_PACKAGE_SUFFIX;
	}
}
