package info.scce.pyro.auth;

import org.apache.shiro.web.filter.authc.BasicHttpAuthenticationFilter;
import org.apache.shiro.web.util.WebUtils;

import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletResponse;

/**
 * Created by frohme on 04.01.16.
 */
public class RESTServiceAuthenticator extends BasicHttpAuthenticationFilter {

	@Override
	protected boolean sendChallenge(ServletRequest request, ServletResponse response) {
		HttpServletResponse httpResponse = WebUtils.toHttp(response);
		httpResponse.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
		/** set no {@link AUTHENTICATE_HEADER}-header, so the browser does nothing **/
		return false;
	}
}
