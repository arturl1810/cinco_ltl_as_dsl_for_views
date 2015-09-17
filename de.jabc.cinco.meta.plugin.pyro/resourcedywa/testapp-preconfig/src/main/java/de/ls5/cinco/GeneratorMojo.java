package de.ls5.cinco;

import de.ls5.cinco.deployment.CincoDBController;
import org.apache.deltaspike.cdise.api.CdiContainer;
import org.apache.deltaspike.cdise.api.CdiContainerLoader;
import org.apache.maven.plugin.AbstractMojo;
import org.apache.maven.plugin.MojoExecutionException;
import org.apache.maven.plugin.logging.Log;
import org.apache.maven.plugins.annotations.LifecyclePhase;
import org.apache.maven.plugins.annotations.Mojo;
import org.apache.maven.plugins.annotations.Parameter;

import javax.enterprise.context.spi.CreationalContext;
import javax.enterprise.inject.spi.Bean;
import javax.enterprise.inject.spi.BeanManager;

/**
 * A Maven plugin mojo to generate the domain of the dywa framework.
 */
@Mojo(name = "preconfig", defaultPhase = LifecyclePhase.INITIALIZE)
public class GeneratorMojo extends AbstractMojo {

	@Parameter(defaultValue = "pu", required = true)
	private String persistenceUnit;

	/**
	 * @see org.apache.maven.plugin.AbstractMojo#execute()
	 */
	public void execute() throws MojoExecutionException {

		Log log = getLog();

		CdiContainer cdiContainer = CdiContainerLoader.getCdiContainer();
		cdiContainer.boot();
		cdiContainer.getContextControl().startContexts();

		final BeanManager bmgr = cdiContainer.getBeanManager();
		final Bean<CincoDBController> bean = (Bean<CincoDBController>) bmgr.resolve(bmgr.getBeans(CincoDBController.class));
		final CreationalContext<CincoDBController> cctx = bmgr.createCreationalContext(bean);
		final CincoDBController controller = (CincoDBController) bmgr.getReference(bean, bean.getBeanClass(), cctx);

		controller.removeGraphModelDBTypes();
		controller.createGraphModelDBTypes();

		cdiContainer.getContextControl().stopContexts();
		cdiContainer.shutdown();

		log.info("Successfully imported dump");
	}

}
