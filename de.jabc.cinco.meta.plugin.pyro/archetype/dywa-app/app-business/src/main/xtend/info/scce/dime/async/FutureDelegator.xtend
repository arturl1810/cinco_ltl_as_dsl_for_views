package info.scce.pyro.async

import java.util.concurrent.ExecutionException
import java.util.concurrent.Future
import java.util.concurrent.TimeUnit
import java.util.concurrent.TimeoutException

class FutureDelegator<T> implements Future<T> {

    private val Future<Future<T>> future;

    new(Future<Future<T>> future) {
        this.future = future
    }

    override get() throws InterruptedException, ExecutionException {
        future.get()?.get()
    }

    override get(long timeout, TimeUnit unit) throws InterruptedException, ExecutionException, TimeoutException {
        future.get(timeout, unit)?.get()
    }

    override cancel(boolean mayInterruptIfRunning) {
        future.cancel(mayInterruptIfRunning)
    }

    override boolean isCancelled() {
        future.cancelled
    }

    override boolean isDone() {
        future.done
    }
}
