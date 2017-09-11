package info.scce.pyro;

import de.ls5.dywa.adapter.plugin.WebPlugin;

import javax.ejb.Stateless;

/**
 * Created by frohme on 25.03.15.
 */
@Stateless
public class WebPluginRegistry implements WebPlugin {

	@Override
	public String getName() {
		return "Application";
	}

	@Override
	public String getURL() {
		return "app";
	}
}
