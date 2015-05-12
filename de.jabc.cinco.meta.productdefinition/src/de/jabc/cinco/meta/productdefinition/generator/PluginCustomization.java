package de.jabc.cinco.meta.productdefinition.generator;

public class PluginCustomization {

	public static enum PERSPECTIVE_BAR_POSITION {
		TOP_RIGHT {
			@Override
			public String toString() {
				return "topRight";
			}
		},
		TOP_LEFT {
			@Override
			public String toString() {
				return "topLeft";
			}
		},
		BOTTOM_RIGHT {
			@Override
			public String toString() {
				return "bottomRight";
			}
		},
		BOTTOM_LEFT {
			@Override
			public String toString() {
				return "bottomLeft";
			}
		};

	}

	private static final String PLUGIN_COSTUMIZATION = "org.eclipse.ui/SHOW_TRADITIONAL_STYLE_TABS=%s\n"
			+ "org.eclipse.ui/DOCK_PERSPECTIVE_BAR=%s\n"
			+ "org.eclipse.ui/SHOW_PROGRESS_ON_STARTUP=%s\n"
			+ "org.eclipse.ui.workbench/SHOW_BUILDID_ON_STARTUP=false\n"
			+ "org.eclipse.ui/USE_WINDOW_WORKING_SET_BY_DEFAULT=%s\n"
			+ "org.eclipse.core.resources/refresh.lightweight.enabled=%s\n"
			+ "org.eclipse.ui.editors/lineNumberRuler=%s\n";

	public static String customizeProject(String perspectiveId,
			boolean traditionalStyleTabs,
			PERSPECTIVE_BAR_POSITION perspectiveBarPosition,
			boolean showProgressOnStartUp,
			boolean useWindowWorkingSetByDefault, boolean refreshLightWeight,
			boolean lineNumberRuler) {
		return String.format(PLUGIN_COSTUMIZATION, perspectiveId,
				traditionalStyleTabs, perspectiveBarPosition.toString(),
				showProgressOnStartUp, useWindowWorkingSetByDefault,
				refreshLightWeight, lineNumberRuler);
	}

	public static String customizeProject(String perspectiveId) {
		return customizeProject(perspectiveId, false,
				PERSPECTIVE_BAR_POSITION.TOP_RIGHT, true, true, true, true);
	}
}
