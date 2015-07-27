package de.ls5.cinco;

import org.xadisk.connector.outbound.XADiskConnectionFactory;

import javax.annotation.Priority;
import javax.enterprise.context.RequestScoped;
import javax.enterprise.inject.Alternative;
import javax.enterprise.inject.Disposes;
import javax.enterprise.inject.Produces;
import javax.persistence.EntityManager;
import javax.persistence.Persistence;

/**
 * Created by frohme on 22.06.15.
 */
@Alternative
@Priority(1)
public class BeanProducer {

	@Produces
	@de.ls5.dywa.core.qualifier.Persistence
	@RequestScoped
	public EntityManager produceEntityManager() {
		EntityManager em = Persistence.createEntityManagerFactory("pu").createEntityManager();
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
