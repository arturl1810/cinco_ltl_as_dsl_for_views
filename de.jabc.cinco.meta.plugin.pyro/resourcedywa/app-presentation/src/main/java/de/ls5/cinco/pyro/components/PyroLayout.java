package de.ls5.cinco.pyro.components;

import org.apache.tapestry5.*;
import org.apache.tapestry5.annotations.*;
import org.apache.tapestry5.ioc.annotations.*;
import org.apache.tapestry5.BindingConstants;
import org.apache.tapestry5.SymbolConstants;

/**
 * Layout component for pages of application testapp-presentation.
 */
@Import(stylesheet = {
        "context:css/joint/joint.css",
        "context:css/pyro/pyro.core.css",
        "context:css/pyro/pyro.nodes.css",
        "context:css/plugins/jquery.contextMenu.css",
        "context:css/themes/bootstrap.min.css",
        "context:css/themes/bootstrap-theme.min.css"

},
        library = {
                "context:js/joint/joint.js",
                "context:js/plugins/base64.js",
                "context:js/plugins/jquery.ui.position.js",
                "context:js/plugins/FileSaver.min.js",
                "context:js/plugins/jquery.contextMenu.js",
                "context:js/plugins/jquery.event.drag-2.2.js",
                "context:js/plugins/jquery.event.drag.live-2.2.js",
                "context:js/plugins/jquery.event.drag-2.2.js",
                "context:js/plugins/jquery.event.drop.live-2.2.js",
                "context:js/plugins/jquery.numeric.min.js",

                "context:js/themes/bootstrap.min.js",
                "context:js/themes/bootswatch.js"
        }
)
public class PyroLayout
{
    /**
     * The page title, for the <title> element and the <h1> element.
     */
    @Property
    @Parameter(required = true, defaultPrefix = BindingConstants.LITERAL)
    private String title;

    @Property
    private String pageName;

    @Property
    @Parameter(defaultPrefix = BindingConstants.LITERAL)
    private String sidebarTitle;

    @Property
    @Parameter(defaultPrefix = BindingConstants.LITERAL)
    private Block sidebar;

    @Inject
    private ComponentResources resources;

    @Property
    @Inject
    @Symbol(SymbolConstants.APPLICATION_VERSION)
    private String appVersion;


    public String getClassForPageName()
    {
        return resources.getPageName().equalsIgnoreCase(pageName)
                ? "current_page_item"
                : null;
    }

    public String[] getPageNames()
    {
        return new String[]{"Index", "About", "Contact"};
    }
}
