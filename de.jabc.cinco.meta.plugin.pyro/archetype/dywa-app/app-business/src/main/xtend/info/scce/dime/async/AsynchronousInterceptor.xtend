package info.scce.pyro.async

import java.io.Serializable
import java.util.concurrent.Future
import javax.annotation.Priority
import javax.annotation.Resource
import javax.enterprise.concurrent.ManagedExecutorService
import javax.enterprise.context.RequestScoped
import javax.interceptor.AroundInvoke
import javax.interceptor.Interceptor
import javax.interceptor.InvocationContext
import org.apache.deltaspike.cdise.api.ContextControl
import org.apache.deltaspike.core.api.provider.BeanProvider

import static javax.interceptor.Interceptor.Priority.LIBRARY_BEFORE

import static extension info.scce.pyro.util.TransactionUtil.*

@Interceptor
@Asynchronous
@Priority(LIBRARY_BEFORE)
class AsynchronousInterceptor implements Serializable {

    private static val long serialVersionUID = 1L;

    @Resource
    private ManagedExecutorService managedExecutorService;

    @AroundInvoke
    def Object submitAsync(InvocationContext ctx) throws Exception {
        new FutureDelegator(
                managedExecutorService.submit[
                    val tx = lookupTX
                    try {
                        tx.beginTX
                        val ctxControl = BeanProvider.getContextualReference(ContextControl)
                        ctxControl.startContext(RequestScoped)
                        ctx.proceed() as Future<Object> => [
                            ctxControl.stopContext(RequestScoped)
                            tx.commitTX
                        ]
                    }
                    catch(Throwable t) {
                        tx.rollbackTX
                        t.printStackTrace
                        return null
                    }
                ]
        )
    }
}
