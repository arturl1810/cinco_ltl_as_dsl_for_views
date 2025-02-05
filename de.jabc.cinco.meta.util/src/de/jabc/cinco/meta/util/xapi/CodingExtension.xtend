package de.jabc.cinco.meta.util.xapi

import java.io.PrintWriter
import java.io.StringWriter

/**
 * Coding-specific extension methods.
 * 
 * @author Steve Bosselmann
 * @author Johannes Neubauer
 */
class CodingExtension {
	
	/**
	 * The Elvis operator {@code ?:} with extended behavior in terms of functions,
	 * i.e. providing default value in case a function returns {@code null}) or fails
	 * with an exception. Additionally, the incident is printed to the console in
	 * form of a warning along with a shortened stack trace.
	 * <p>
	 * The default behavior of the Elvis operator {@code ?:} for non-functions is
	 * not affected, i.e. the expression <code>person.name?:'Hans'</code> still
	 * evaluates in the usual manner.
	 * <p>
	 * A typical usage example is the guarded execution of code blocks by enclosing 
	 * it with square brackets {@code [ ]}. It is especially helpful in scenarios where
	 * a return value different from {@code null} is expected but the program may
	 * continue without it by falling back to a default value.
	 * <p>
	 * Example: <code>parseInt() ?: 42</code> points back to the usual behavior
	 * of the Elvis operator {@code ?:} and returns 42 if the method {@code parseInt()}
	 * returns {@code null}. The expression <code>[ parseInt() ] ?: 42</code> leads
	 * to the extended behavior, i.e. it returns 42 if either the method
	 * {@code parseInt()} returns {@code null} or fails with an exception.
	 * <p>
	 * This example does the same as the following code (warnings are simplified):
	 * <pre>
	 *  try {
	 *    parseInt() ?: {
	 *      System.err.println("WARN: null")
	 *      42
	 *    }
	 *  } catch(Exception e) {
	 *    System.err.println("WARN: exception")
	 *    42
	 *  }
	 * </pre>
	 * <p>
	 * Note that function arguments are not supported. However, in order to allow
	 * simple square brackets {@code [ ]} instead of the argument-less version
	 * {@code [| ]}, the function is declared with an anonymous argument that is set
	 * to {@code null} when the function is called internally. In order to avoid the
	 * use on functions with an argument, the type of the latter points to a final
	 * class that is not to be instantiated.
	 * 
	 * @param func - A function (might be {@code null}).
	 * @param defaultVal - A default value (might be {@code null}) to be returned if
	 *   the function fails or returns {@code null}.
	 * 
	 * @return  The result of the function if it neither fails nor is {@code null},
	 *   the specified default value otherwise. 
	 */
	def <T> ?: ((FunctionArgumentsNotSupported) => T func, T defaultVal) {
		try func?.apply(null) ?: {
			warn('''
				Computed value is null. Defaulting to: «defaultVal»
				  «new RuntimeException().trimmedStackTraceAsString»
			''')
			defaultVal
		} catch(Exception it) {
			warn('''
				Exception while computing value. Defaulting to: «defaultVal»
				  «trimmedStackTraceAsString»
			''')
			defaultVal
		}
	}
	
	/**
	 * <p>
	 * Concatenates an object and an iterable into a single iterable. The returned
	 * iterable has an iterator that traverses the element {@code a}, followed by
	 * the elements in {@code b}. The resulting iterable is effectivly a view on the
	 * source iterable. That is, the source iterator is not polled until necessary
	 * and the result will reflect changes in the sources.
	 * </p>
	 * <p>
	 * The returned iterable's iterator supports {@code remove()} when the
	 * corresponding input iterator supports it.
	 * </p>
	 *
	 * @param a
	 *            the first element. May not be <code>null</code>.
	 * @param b
	 *            the iterable to append. May not be <code>null</code>.
	 * @return a combined iterable. Never <code>null</code>.
	 */
	def <T> Iterable<T> plus(T a, Iterable<? extends T> b) {
		#[a] + b
	}

	/**
	 * <p>
	 * Concatenates an iterable and an object into a single iterable. The returned
	 * iterable has an iterator that traverses the elements in {@code a}, followed by
	 * the element {@code b}. The resulting iterable is effectivly a view on the
	 * source iterable. That is, the source iterator is not polled until necessary
	 * and the result will reflect changes in the sources.
	 * </p>
	 * <p>
	 * The returned iterable's iterator supports {@code remove()} when the
	 * corresponding input iterator supports it.
	 * </p>
	 *
	 * @param a
	 *            the first iterable. May not be <code>null</code>.
	 * @param b
	 *            the element to append. May not be <code>null</code>.
	 * @return a combined iterable. Never <code>null</code>.
	 */
	def <T> Iterable<T> plus(Iterable<? extends T> a, T b) {
		a + #[b]
	}

	/**
	 * Convenience method for concise exception handling.
	 * <p>
	 * Executes the specified function, catches an eventual exception, maps it on an
	 * exception of another type as specified in the respective mapping function and
	 * throws this one instead.
	 * <p>
	 * A typical usage example is the guarded execution of code blocks by enclosing 
	 * it with square brackets {@code [ ]}. It is especially helpful in scenarios where
	 * exceptions may occur that should be mapped on a single common exception of
	 * specific type.
	 * <p>
	 * Example:
	 * <pre>
	 *  val num = [ parseInt() ].mapException[ switch it {
	 *    NumberFormatException, NullPointerException: ApplicationException
	 *  }]
	 * </pre>
	 * <p>
	 * Note that function arguments are not supported. However, in order to allow
	 * simple square brackets {@code [ ]} instead of the argument-less version
	 * {@code [| ]}, the function is declared with an anonymous argument that is set
	 * to {@code null} when the function is called internally. In order to avoid the
	 * use on functions with an argument, the type of the latter points to a final
	 * class that is not to be instantiated.
	 * 
	 * @param func - A function. 
	 * @param mapping - A mapping function that maps exceptions on exception types.
	 * @return  The result of the function if it does not fail.
	 * @throws Exception  If the specified function fails with an exception an exception
	 *   according to the mapping function is created and thrown instead. If the result of
	 *   the mapping function is {@code null} the original exception is thrown.
	 */
	def <T> mapException((FunctionArgumentsNotSupported) => T func, (Exception) => Class<? extends Exception> mapping) {
		try func.apply(null)
		catch (Exception e) throw [
			mapping.apply(e)?.getConstructor(Throwable)?.newInstance(e)
		].onException[
			mapping.apply(e)?.newInstance
		] ?: e
	}

	/**
	 * Convenience method for concise exception handling.
	 * <p>
	 * Executes the specified function, catches an eventual exception, maps it on an
	 * exception of another type as specified in the respective mapping function and
	 * throws this one instead.
	 * <p>
	 * A typical usage example is the guarded execution of code blocks by enclosing 
	 * it with square brackets {@code [ ]}. It is especially helpful in scenarios where
	 * exceptions may occur that should be mapped on a single common exception of
	 * specific type.
	 * <p>
	 * Example:
	 * <pre>
	 *  [ doSomething() ].mapException[ switch it {
	 *    NumberFormatException, NullPointerException: ApplicationException
	 *  }]
	 * </pre>
	 * <p>
	 * Note that function arguments are not supported. However, in order to allow
	 * simple square brackets {@code [ ]} instead of the argument-less version
	 * {@code [| ]}, the function is declared with an anonymous argument that is set
	 * to {@code null} when the function is called internally. In order to avoid the
	 * use on functions with an argument, the type of the latter points to a final
	 * class that is not to be instantiated.
	 * 
	 * @param func - A function. 
	 * @param mapping - A mapping function that maps exceptions on exception types.
	 * @throws Exception  If the specified function fails with an exception an exception
	 *   according to the mapping function is created and thrown instead. If the result of
	 *   the mapping function is {@code null} the original exception is thrown.
	 */
	def mapException((FunctionArgumentsNotSupported) => void func, (Exception) => Class<? extends Exception> excls) {
		try func.apply(null)
		catch (Exception e) throw [
			excls.apply(e)?.getConstructor(Throwable)?.newInstance(e)
		].onException[
			excls.apply(e)?.newInstance
		] ?: e
	}
	
	/**
	 * Convenience method for concise exception handling.
	 * <p>
	 * Executes the specified function, catches an eventual exception, maps it on the
	 * specified exception and throws this one instead.
	 * <p>
	 * A typical usage example is the guarded execution of code blocks by enclosing 
	 * it with square brackets {@code [ ]}. It is especially helpful in scenarios where
	 * exceptions may occur that should be mapped on a single common exception of
	 * specific type.
	 * <p>
	 * Example:
	 * <pre>
	 *  val num = [ parseInt() ].mapException(
	 *    new RuntimeException("parsing failed")
	 *  )
	 * </pre>
	 * <p>
	 * Note that function arguments are not supported. However, in order to allow
	 * simple square brackets {@code [ ]} instead of the argument-less version
	 * {@code [| ]}, the function is declared with an anonymous argument that is set
	 * to {@code null} when the function is called internally. In order to avoid the
	 * use on functions with an argument, the type of the latter points to a final
	 * class that is not to be instantiated.
	 * 
	 * @param func - A function. 
	 * @param exception - The exception to be thrown if the function fails.
	 * @return  The result of the function if it does not fail.
	 * @throws Exception  If the specified function fails with an exception the
	 *   specified exception is thrown instead. If the latter is {@code null} the
	 *   original exception is thrown.
	 */
	def <T> mapException((FunctionArgumentsNotSupported) => T func, Exception exception) {
		try func.apply(null)
		catch (Exception e) throw exception ?: e
	}
	
	/**
	 * Convenience method for concise exception handling.
	 * <p>
	 * Executes the specified function, catches an eventual exception, maps it on the
	 * specified exception and throws this one instead.
	 * <p>
	 * A typical usage example is the guarded execution of code blocks by enclosing 
	 * it with square brackets {@code [ ]}. It is especially helpful in scenarios where
	 * exceptions may occur that should be mapped on a single common exception of
	 * specific type.
	 * <p>
	 * Example:
	 * <pre>
	 *  [ doSomething() ].mapException(
	 *    new RuntimeException("doing something failed")
	 *  )
	 * </pre>
	 * <p>
	 * Note that function arguments are not supported. However, in order to allow
	 * simple square brackets {@code [ ]} instead of the argument-less version
	 * {@code [| ]}, the function is declared with an anonymous argument that is set
	 * to {@code null} when the function is called internally. In order to avoid the
	 * use on functions with an argument, the type of the latter points to a final
	 * class that is not to be instantiated.
	 * 
	 * @param func - A function. 
	 * @param exception - The exception to be thrown if the function fails.
	 * @throws Exception  If the specified function fails with an exception the
	 *   specified exception is thrown instead. If the latter is {@code null} the
	 *   original exception is thrown.
	 */
	def mapException((FunctionArgumentsNotSupported) => void func, Exception exception) {
		try func.apply(null)
		catch (Exception e) throw exception ?: e
	}
	
	/**
	 * Convenience method for concise exception handling.
	 * <p>
	 * Executes the specified function, catches an eventual exception and returns
	 * the default value.
	 * <p>
	 * A typical usage example is the guarded execution of code blocks by enclosing 
	 * it with square brackets {@code [ ]}. It is especially helpful in scenarios where
	 * a return value is expected but the program may continue without it by falling
	 * back to a default value.
	 * <p>
	 * Example:
	 * <pre>
	 *  val num = [ parseInt() ].onFail(42)
	 * </pre>
	 * <p>
	 * Note that the result {@code null} is allowed. If additionally the value {@code null}
	 * should be excluded, use the extended Elvis operator {@link #operator_elvis ?:} instead. 
	 * <p>
	 * Note that function arguments are not supported. However, in order to allow
	 * simple square brackets {@code [ ]} instead of the argument-less version
	 * {@code [| ]}, the function is declared with an anonymous argument that is set
	 * to {@code null} when the function is called internally. In order to avoid the
	 * use on functions with an argument, the type of the latter points to a final
	 * class that is not to be instantiated.
	 * 
	 * @param func - A function. 
	 * @param defaultVal - A default value. 
	 * @return  The result of the function if it does not fail, the specified default value
	 *   otherwise.
	 */
	def <T> onFail((FunctionArgumentsNotSupported) => T func, T defaultVal) {
		try func.apply(null)
		catch (Exception e) return defaultVal
	}
	
	/**
	 * Convenience method for concise exception handling.
	 * <p>
	 * Executes the specified function, catches an eventual exception and executes the
	 * specified handler.
	 * <p>
	 * A typical usage example is the guarded execution of code blocks by enclosing 
	 * it with square brackets {@code [ ]}. It is especially helpful in scenarios where
	 * exceptions may occur that should be handled locally and the program can proceed.
	 * <p>
	 * Example:
	 * <pre>
	 *  val num = [ parseInt() ].onException[
	 *    System.err.println("parsing failed")
	 *  ]
	 * </pre>
	 * <p>
	 * Note that function arguments are not supported. However, in order to allow
	 * simple square brackets {@code [ ]} instead of the argument-less version
	 * {@code [| ]}, the function is declared with an anonymous argument that is set
	 * to {@code null} when the function is called internally. In order to avoid the
	 * use on functions with an argument, the type of the latter points to a final
	 * class that is not to be instantiated.
	 * 
	 * @param func - A function. 
	 * @param handler - The handler to be executed if an exception occurs.
	 * @return  The result of the function if it does not fail, {@code null} otherwise.
	 */
	def <T> onException((FunctionArgumentsNotSupported) => T func, (Exception) => void handler) {
		try func.apply(null)
		catch (Exception e) {
			handler.apply(e)
		}
	}
	
	/**
	 * Convenience method for concise exception handling.
	 * <p>
	 * Executes the specified function, catches an eventual exception and executes the
	 * specified handler.
	 * <p>
	 * A typical usage example is the guarded execution of code blocks by enclosing 
	 * it with square brackets {@code [ ]}. It is especially helpful in scenarios where
	 * exceptions may occur that should be handled locally and the program can proceed.
	 * <p>
	 * Example:
	 * <pre>
	 *  [ doSomething() ].onException[
	 *    System.err.println("doing something failed")
	 *  ]
	 * </pre>
	 * <p>
	 * Note that function arguments are not supported. However, in order to allow
	 * simple square brackets {@code [ ]} instead of the argument-less version
	 * {@code [| ]}, the function is declared with an anonymous argument that is set
	 * to {@code null} when the function is called internally. In order to avoid the
	 * use on functions with an argument, the type of the latter points to a final
	 * class that is not to be instantiated.
	 * 
	 * @param func - A function. 
	 * @param handler - The handler to be executed if an exception occurs.
	 */
	def onException((FunctionArgumentsNotSupported) => void func, (Exception) => void handler) {
		try func.apply(null)
		catch (Exception e) {
			handler.apply(e)
		}
	}
	
	/**
	 * Convenience method for concise exception handling.
	 * <p>
	 * Shorthand for <code>onException[printStackTrace]</code>, see:
	 * {@link #onException onException}
	 * 
	 * @param it - A function.
	 */
	def <T> printException((FunctionArgumentsNotSupported) => T it) {
		onException[printStackTrace]
	}
	
	/**
	 * Convenience method for concise exception handling.
	 * <p>
	 * Shorthand for <code>onException[printStackTrace]</code>, see:
	 * {@link #onException onException}
	 * 
	 * @param it - A function.
	 */
	def printException((FunctionArgumentsNotSupported) => void it) {
		onException[printStackTrace]
	}
	
	/**
	 * Convenience method for concise exception handling.
	 * <p>
	 * Shorthand for <code>onException[]</code>, see:
	 * {@link #onException onException}
	 * 
	 * @param it - A function.
	 */
	def <T> ignoreException((FunctionArgumentsNotSupported) => T it) {
		onException[]
	}
	
	/**
	 * Convenience method for concise exception handling.
	 * <p>
	 * Shorthand for <code>onException[]</code>, see:
	 * {@link #onException onException}
	 * 
	 * @param it - A function.
	 */
	def ignoreException((FunctionArgumentsNotSupported) => void it) {
		onException[]
	}
	
	/**
	 * Helper class for the exception handling extension methods.
	 */
	public static final class FunctionArgumentsNotSupported {
	    def private FunctionArgumentsNotSupported() {
	        throw new UnsupportedOperationException("Instantiation is not supported");
	    }
	}
	
	/**
	 * Convenience method for concise exception handling.
	 * <p>
	 * Creates a String from the stack trace of the specified exception.
	 * 
	 * @param e - An exception
	 * @return  A String with the stack trace of the specified exception.
	 */
	def getStackTraceAsString(Exception e) {
		val sw = new StringWriter();
		val pw = new PrintWriter(sw);
		e.printStackTrace(pw)
		sw.toString ?: ""
	}
	
	/**
	 * Convenience method for concise exception handling.
	 * <p>
	 * Creates a String from the stack trace of the specified exception and
	 * trims it to only show the first lines down to the Cinco-specific class
	 * where the exception has occurred.
	 * 
	 * @param e - An exception
	 * @return  A String with the stack trace of the specified exception.
	 */
	def getTrimmedStackTraceAsString(Exception it) {
		val trace = stackTraceAsString
		val cinco = trace.indexOf("cinco", trace.lastIndexOf('''.«this.class.simpleName».'''))
		val index = if (cinco >= 0) trace.indexOf("\n", cinco) else -1
		if (index < 0 || index >= trace.length)
			trace
		else
			trace.substring(0, index)
	}
	
	/**
	 * Print a warning message to System.err
	 * 
	 * @param caller - The object that triggers console output.
	 * @param msg - The message to be printed
	 */
	def warn(Object caller, CharSequence msg) {
		System.err.println('''[«caller.class.simpleName»] WARN «msg»''')
	}
	
	/**
	 * This is an slightly adapted alternative to the <code>=></code> operator 
	 * in order to create a let-block. A benefit of this extension method is, that it 
	 * allows <strong>optional execution</strong> if the left expression evaluates to 
	 * <code>null</code>. Instead of returning the left-hand side, it returns the result 
	 * of the block or <code>null</code> if the left-hand side is <code>null</code>.
	 * 
	 * <pre>
	 * nullableStuff?.let [ 
	 *   // do something with `it` as it will never be null
	 * ]?.workOnTheResultOfBlock
	 * </pre>
	 * 
	 * @param it the object used as receiver.
	 * @param block the let lambda expression.
	 * @return the receiver.
	 */
	def <T, U> let(T it, (T) => U block) {
		block.apply(it)
	}
	
	/**
	 * This is an alternative to the <code>=></code> operator 
	 * in order to create a with-block. A benefit of this extension method is, that it 
	 * allows <strong>optional execution</strong> if the left expression evaluates to 
	 * <code>null</code>. like the double arrow operator it will return the left-hand 
	 * side and the lambda expression is of type <code>void</code>. 
	 * 
	 * <pre>
	 * nullableStuff?.let [ 
	 *   // do something with `it` as it will never be null
	 * ]?.workOnNullableStuff
	 * </pre>
	 * 
	 * @param it the object used as receiver.
	 * @param block the let lambda expression.
	 * @return the receiver.
	 */
	def <T> with(T it, (T) => void block) {
		block.apply(it)
		it
	}
	
	/**
	 * Performs/forces an early exit of the calling method (via an illegal argument exception) if the left expression evaluates to 
	 * <code>null</code>. The code block may be used to do some cleanup before exiting. 
	 * 
	 * <pre>
	 * val a = nullableStuff.guard [ 
	 * 	// do some cleanup.
	 * ]
	 * // this will be executed, iff `nullableStuff` is not `null`.
	 * </pre>
	 * 
	 * @param it the object to be checked for being a null pointer.
	 * @param block a lambda expression for doing some cleanup.
	 * @return the receiver (if it wasn't <code>null</code>).
	 */
	def <T> T guard(T it, () => void block) {
        if (it == null) {
        	block.apply()
        	throw new IllegalArgumentException("guarded value is null")
        }
        it
    }
    
    /**
     * Performs/forces an early exit of the calling method (via an illegal argument exception) if the left expression evaluates to 
	 * <code>null</code>.
	 * 
	 * <pre>
	 * val a = nullableStuff.guard
	 * // this will be executed, iff `nullableStuff` is not `null`.
	 * </pre>
	 * 
	 * @param it the object to be checked for being a null pointer.
	 * @return the receiver (if it wasn't <code>null</code>).
     */
    def <T> T guard(T it) {
    	if (it == null) throw new IllegalArgumentException("guarded value is null")
        it
    }
}