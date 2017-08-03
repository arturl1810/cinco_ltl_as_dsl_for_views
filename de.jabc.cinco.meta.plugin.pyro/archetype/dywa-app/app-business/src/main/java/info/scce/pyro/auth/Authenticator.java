package info.scce.pyro.auth;

import org.apache.shiro.authc.AuthenticationException;
import org.apache.shiro.authc.AuthenticationInfo;
import org.apache.shiro.authc.AuthenticationToken;
import org.apache.shiro.realm.AuthenticatingRealm;
import org.apache.shiro.realm.Realm;

import javax.enterprise.context.spi.CreationalContext;
import javax.enterprise.inject.spi.Bean;
import javax.enterprise.inject.spi.BeanManager;
import javax.enterprise.inject.spi.CDI;
import java.util.Set;

/**
 * Created by frohme on 25.11.15.
 */
public class Authenticator extends AuthenticatingRealm implements Realm {

	@Override
	protected AuthenticationInfo doGetAuthenticationInfo(AuthenticationToken token) throws AuthenticationException {

		final BeanManager bm = CDI.current().getBeanManager();
		final Set<Bean<?>> beans = bm.getBeans(AuthenticationInterface.class);

		if (beans.isEmpty()) {
			throw new AuthenticationException();
		}

		final Bean<AuthenticationInterface> bean = (Bean<AuthenticationInterface>) bm.resolve(beans);
		final CreationalContext<AuthenticationInterface> cctx = bm.createCreationalContext(bean);
		final AuthenticationInterface controller =
				(AuthenticationInterface) bm.getReference(bean, AuthenticationInterface.class, cctx);

		return controller.doGetAuthenticationInfo(token);
	}
}
