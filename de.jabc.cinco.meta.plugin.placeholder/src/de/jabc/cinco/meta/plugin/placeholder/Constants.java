package de.jabc.cinco.meta.plugin.placeholder;

import mgl.Node;

public class Constants {
	public static final String PROJECT_ACRONYM = "placeholder";
	public static final String PROJECT_SUFFIX = "placeholder";
	public static final String PROJECT_ANNOTATION = "placeholder";
	public static final String HOOK_PACKAGE_SUFFIX = ".hooks";
	public static String getPostCreateHookClassName(Node node){
		return node.getName() + "PlaceholderPostCreateHook";
	}
	public static String getPostMoveHookClassName(Node node){
		return node.getName() + "PlaceholderPostMoveHook";
	}
}
