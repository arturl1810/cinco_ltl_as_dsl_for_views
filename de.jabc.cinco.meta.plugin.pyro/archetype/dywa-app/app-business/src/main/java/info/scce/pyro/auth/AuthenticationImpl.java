package info.scce.pyro.auth;

@javax.transaction.Transactional
public class AuthenticationImpl
		implements
			info.scce.pyro.auth.AuthenticationInterface {

	@javax.inject.Inject
	private de.ls5.dywa.generated.controller.info.scce.pyro.core.PyroUserController controller;

	@Override
	public org.apache.shiro.authc.AuthenticationInfo doGetAuthenticationInfo(
			org.apache.shiro.authc.AuthenticationToken token)
			throws org.apache.shiro.authc.AuthenticationException {

		final org.apache.shiro.authc.UsernamePasswordToken upToken = (org.apache.shiro.authc.UsernamePasswordToken) token;
		final java.lang.String userName = upToken.getUsername();

        final de.ls5.dywa.generated.entity.info.scce.pyro.core.PyroUser searchObject = controller.createSearchObject(null);
        searchObject.setusername(userName);

        final java.util.List<de.ls5.dywa.generated.entity.info.scce.pyro.core.PyroUser> users = controller.findByProperties(searchObject);

        if (users.size() != 1) {
			throw new org.apache.shiro.authc.AuthenticationException();
		}

		final de.ls5.dywa.generated.entity.info.scce.pyro.core.PyroUser user = users.iterator()
				.next();

		return new org.apache.shiro.authc.SimpleAccount(user.getDywaId(),
				user.getpassword(),
				info.scce.pyro.auth.AuthenticationInterface.REALM);
	}
}