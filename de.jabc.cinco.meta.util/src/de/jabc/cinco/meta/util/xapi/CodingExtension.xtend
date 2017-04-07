package de.jabc.cinco.meta.util.xapi

/**
 * Coding-specific extension methods.
 * 
 * @author Steve Bosselmann
 */
class CodingExtension {
	
	def <T> ?: ((Object) => T proc, T defaultVal) {
		proc?.onException[
			warn('''«message» + ". Defaulting to: «defaultVal»''')
		] ?: defaultVal
	}
	
	def <T> mapException((Object) => T proc, (Exception) => Class<? extends Exception> excls) {
		try proc.apply(null)
		catch (Exception e) throw [
			excls.apply(e)?.getConstructor(Throwable)?.newInstance(e)
		].onException[
			excls.apply(e)?.newInstance
		]
	}
	
	def mapException((Object) => void proc, (Exception) => Class<? extends Exception> excls) {
		try proc.apply(null)
		catch (Exception e) throw [
			excls.apply(e)?.getConstructor(Throwable)?.newInstance(e)
		].onException[
			excls.apply(e)?.newInstance
		]
	}
	
	def <T> onFail((Object) => T proc, T dflt) {
		try proc.apply(null)
		catch (Exception e) return dflt
	}
	
	def <T> onException((Object) => T proc, (Exception) => void handler) {
		try proc.apply(null)
		catch (Exception e) {
			handler.apply(e)
		}
	}
	
	def onException((Object) => void proc, (Exception) => void handler) {
		try proc.apply(null)
		catch (Exception e) {
			handler.apply(e)
		}
	}
	
	def <T> printException((Object) => T it) {
		onException[printStackTrace]
	}
	
	def printException((Object) => void it) {
		onException[printStackTrace]
	}
	
	def <T> ignoreException((Object) => T it) {
		onException[]
	}
	
	def ignoreException((Object) => void it) {
		onException[]
	}
	
	/**
	 * Print a warning message to System.err
	 * 
	 * @param caller  The object that triggers console output.
	 * @param msg  The message to be printed
	 */
	def warn(Object caller, CharSequence msg) {
		System.err.println('''[«caller?.class.simpleName»] WARN: «msg»''')
	}
	
	/**
	 * TODO Documentation and usage example.
	 * 
	 * <pre>
	 * 
	 * </pre>
	 * 
	 * @param it
	 * @param block
	 */
	def <T, U> let(T it, (T) => void block) {
		block.apply(it)
		it
	}
	
	/**
	 * TODO Documentation and usage example.
	 * 
	 * <pre>
	 * 
	 * </pre>
	 * 
	 * @param it
	 * @param block
	 */
	def <T> T guard(T it, () => void block) {
        if (it == null) {
        	block.apply()
        	throw new IllegalArgumentException("guarded value is null")
        }
        it
    }
    
    def <T> T guard(T it) {
    	if (it == null) throw new IllegalArgumentException("guarded value is null")
        it
    }
}