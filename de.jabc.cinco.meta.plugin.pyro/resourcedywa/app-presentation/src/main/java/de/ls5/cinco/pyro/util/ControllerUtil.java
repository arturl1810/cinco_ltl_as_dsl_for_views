package de.ls5.cinco.pyro.util;

import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.transaction.*;

import org.apache.log4j.Logger;

public class ControllerUtil {

	private final static Logger log = Logger.getLogger(ControllerUtil.class.getName());

	public static UserTransaction getTransaction() throws NamingException {
		return (UserTransaction) new InitialContext().lookup("java:comp/UserTransaction");
	}

	public static void beginTransaction(final UserTransaction tx) throws SystemException, NotSupportedException {

		if (tx.getStatus() == Status.STATUS_NO_TRANSACTION || tx.getStatus() == Status.STATUS_ROLLEDBACK) {
			tx.begin();
		}
		else if (tx.getStatus() != Status.STATUS_ACTIVE) {
			throw new IllegalArgumentException("Transaction is neither in state '" + Status.STATUS_NO_TRANSACTION
					+ "' nor '" + Status.STATUS_ACTIVE + "', but: " + tx.getStatus());
		}
	}

	public static void commitOrRollbackTransaction(UserTransaction tx) throws SystemException,
			HeuristicRollbackException, HeuristicMixedException, RollbackException {

		if (tx != null) {
			if (tx.getStatus() == Status.STATUS_MARKED_ROLLBACK) {
				rollbackTransaction(tx);
			}
			else if (tx.getStatus() == Status.STATUS_ACTIVE) {
				tx.commit();
			}
		}
	}

	public static void rollbackTransaction(UserTransaction tx) throws SystemException {
		if (tx != null && (tx.getStatus() == Status.STATUS_ACTIVE || tx.getStatus() == Status.STATUS_MARKED_ROLLBACK)) {
			tx.rollback();
		}
	}
}
