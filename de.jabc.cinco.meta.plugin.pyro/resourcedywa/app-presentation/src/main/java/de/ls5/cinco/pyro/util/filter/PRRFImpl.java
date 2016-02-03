package de.ls5.cinco.pyro.util.filter;

import de.ls5.cinco.pyro.util.ControllerUtil;
import org.apache.tapestry5.services.PageRenderRequestFilter;
import org.apache.tapestry5.services.PageRenderRequestHandler;
import org.apache.tapestry5.services.PageRenderRequestParameters;

import javax.transaction.UserTransaction;
import java.io.IOException;


public final class PRRFImpl implements PageRenderRequestFilter {

	@Override
	public void handle(PageRenderRequestParameters parameters, PageRenderRequestHandler handler) throws IOException {

		try {
			final UserTransaction tx = ControllerUtil.getTransaction();

			// begin transaction, process page render request and commit the transaction.
			// rollback the transaction, if an exception is thrown.

			try {
				ControllerUtil.beginTransaction(tx);
				handler.handle(parameters);
				ControllerUtil.commitOrRollbackTransaction(tx);
			}
			catch (Throwable e) {
				ControllerUtil.rollbackTransaction(tx);
				throw e;
			}
		}
		catch (Throwable e) {
			throw new IllegalStateException(e);
		}
	}
}