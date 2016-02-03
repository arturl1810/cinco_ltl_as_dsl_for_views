package de.ls5.cinco.pyro.pages;

import org.apache.tapestry5.ComponentResources;
import org.apache.tapestry5.SymbolConstants;
import org.apache.tapestry5.annotations.Import;
import org.apache.tapestry5.annotations.Property;
import org.apache.tapestry5.ioc.annotations.Inject;
import org.apache.tapestry5.ioc.annotations.Symbol;
import de.ls5.cinco.pyro.deployment.CincoDBController;
import org.apache.tapestry5.services.Request;
import org.apache.tapestry5.util.TextStreamResponse;

/**
 * Start page of application testapp-presentation.
 */
public class Index {

	@Property
	@Inject
	@Symbol(SymbolConstants.TAPESTRY_VERSION)
	private String tapestryVersion;

    @Inject
    private CincoDBController cincoDBController;

    @Inject
    private ComponentResources componentResources;

    @Inject
    private Request request;

    public void onActionFromCreateCincoSchema()
    {
        this.cincoDBController.createGraphModelDBTypes();
    }
    public void onActionFromDeleteCincoSchema()
    {
        this.cincoDBController.removeGraphModelDBTypes();
    }

}
