package de.ls5.cinco.pyro;

import de.ls5.dywa.adapter.events.EventHandler;
import de.ls5.dywa.adapter.plugin.WebPlugin;
import de.ls5.dywa.api.event.EventDispatcher;
import de.ls5.dywa.api.plugin.PluginController;

import javax.annotation.PostConstruct;
import javax.annotation.PreDestroy;
import javax.ejb.Singleton;
import javax.ejb.Startup;
import javax.inject.Inject;
import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

/**
 * Created by frohme on 06.07.15.
 */
@Singleton
@Startup
public class ConfigurationBean {

	private final static String ARTIFACT_NAME;

	static {
		final Properties config = new Properties();
		final InputStream inputStream = ConfigurationBean.class.getResourceAsStream("/META-INF/config.properties");

		try {
			config.load(inputStream);
		}
		catch (IOException ioe) {
			throw new RuntimeException(ioe);
		}

		ARTIFACT_NAME = config.getProperty("finalName");
	}

	private static final String WEBPLUGIN_JNDI = "java:global/" +
			ARTIFACT_NAME +
			'/' +
			WebPluginRegistry.class.getSimpleName() +
			'!' +
			WebPlugin.class.getName();

	@Inject
	private EventDispatcher eventDispatcher;

	@Inject
	private PluginController pluginController;

	@PostConstruct
	public void registerPlugins() {
		try {
			pluginController.registerPlugin(WEBPLUGIN_JNDI);
		} catch (Exception e) {
			this.unregisterPlugins();
			throw new RuntimeException(e);
		}
	}

	@PreDestroy
	public void unregisterPlugins() {
		try {
			pluginController.unregisterPlugin(WEBPLUGIN_JNDI);
		} catch (Exception e) {
			throw new RuntimeException(e);
		}
	}
}
