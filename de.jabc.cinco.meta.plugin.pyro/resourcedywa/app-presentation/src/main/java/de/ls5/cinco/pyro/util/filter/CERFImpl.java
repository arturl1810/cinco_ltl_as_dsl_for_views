package de.ls5.cinco.pyro.util.filter;

import de.ls5.cinco.pyro.util.ControllerUtil;
import org.apache.tapestry5.services.ComponentEventRequestFilter;
import org.apache.tapestry5.services.ComponentEventRequestHandler;
import org.apache.tapestry5.services.ComponentEventRequestParameters;

import javax.transaction.UserTransaction;
import java.io.IOException;


public final class CERFImpl implements ComponentEventRequestFilter {

	@Override
	public void handle(ComponentEventRequestParameters parameters, ComponentEventRequestHandler handler)
			throws IOException {

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
