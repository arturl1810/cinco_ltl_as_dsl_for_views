package de.ls5.cinco;

import org.xadisk.connector.outbound.XADiskConnectionFactory;

import javax.annotation.Priority;
import javax.enterprise.context.RequestScoped;
import javax.enterprise.inject.Alternative;
import javax.enterprise.inject.Disposes;
import javax.enterprise.inject.Produces;
import javax.persistence.EntityManager;
import javax.persistence.Persistence;
import java.util.HashMap;
import java.util.Map;

/**
 * Created by pyro cinco meta plugin
 */
@Alternative
@Priority(1)
public class BeanProducer {

	@Produces
	@de.ls5.dywa.core.qualifier.Persistence
	@RequestScoped
	public EntityManager produceEntityManager() {
		final Map<String, String> config = new HashMap<>();

		config.put("hibernate.connection.url", "jdbc:postgresql://localhost:5432/dywa");

		EntityManager em = Persistence.createEntityManagerFactory("pu", config).createEntityManager();
		em.getTransaction().begin();
		return em;
	}

	public void destroyEntityManager(@Disposes @de.ls5.dywa.core.qualifier.Persistence EntityManager em) {
		em.getTransaction().commit();
		em.flush();
		em.close();
	}

	@Produces
	public XADiskConnectionFactory produceConnectionFactory() {
		return null;
	}
}
