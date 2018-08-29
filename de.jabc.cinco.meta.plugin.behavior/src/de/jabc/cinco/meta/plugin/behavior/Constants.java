package de.jabc.cinco.meta.plugin.behavior;

import mgl.Node;

public class Constants {
	public static final String PROJECT_ANNOTATION = "behavior";
	public static final String PROJECT_SUFFIX = "behave";
	public static final String HOOK_PACKAGE_SUFFIX = ".hooks";
	
	
	public static String getPostMoveHookClassName(Node node){
		return node.getName() + "PostMoveHook";
	}
	public static String getPostCreateHookClassName(Node node){
		return node.getName() + "PostCreateHook";
	}
	public static String projectPackage(Node node){
		return node.getGraphModel().getPackage() + "." + Constants.PROJECT_SUFFIX + HOOK_PACKAGE_SUFFIX;
	}
}
