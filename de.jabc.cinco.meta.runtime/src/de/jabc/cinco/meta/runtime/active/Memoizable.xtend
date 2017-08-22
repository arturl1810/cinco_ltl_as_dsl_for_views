package de.jabc.cinco.meta.runtime.active

import java.util.HashMap
import java.util.List
import java.util.stream.Stream
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.TransformationParticipant
import org.eclipse.xtend.lib.macro.declaration.CompilationStrategy.CompilationContext
import org.eclipse.xtend.lib.macro.declaration.MutableMethodDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeReference
import org.eclipse.xtend.lib.macro.declaration.Visibility

@Active(MemoizeProcessor)
annotation Memoizable {
	int expectedSize = 666;
}

class MemoizeProcessor implements TransformationParticipant<MutableMethodDeclaration> {
	override doTransform(List<? extends MutableMethodDeclaration> methods, TransformationContext context) {
		methods.forEach [ it, index |
			switch (parameters.size) {
				case 0: new ParameterlessMethodMemoizer(it, context, index).generate
				case 1: new SingleParameterMethodMemoizer(it, context, index).generate
				default: new MultipleParameterMethodMemoizer(it, context, index).generate
			}
		]
	}
}

class ParameterlessMethodMemoizer extends MethodMemoizer {

	new(MutableMethodDeclaration method, TransformationContext context, int index) {
		super(method, context, index)
	}
	
	override cacheFieldType() {
    	wrappedReturnType
  	}

	override cacheFieldInit(CompilationContext context) '''null'''
	
	override cacheCall(extension CompilationContext context) '''
		if («cacheFieldName» == null) {
			// do the heavy work outside the critical section.
			final «wrappedReturnType.toJavaCode» cacheValue = «initMethodName»();
			«cacheFieldName» = cacheValue;
		}
		
		«IF !Stream.newTypeReference.isAssignableFrom(wrappedReturnType)»
			// for non-lazy return types, return the cached value.
			return «cacheFieldName»;
		«ELSE»
			«val typeArgument = wrappedReturnType.actualTypeArguments.head»
			// for lazy iterations use the duplicate feature of Jooq.
			final org.jooq.lambda.tuple.Tuple2<Seq<«typeArgument.toJavaCode»>, Seq<«typeArgument.toJavaCode»>> cacheValueDupe = 
				org.jooq.lambda.Seq.seq(«cacheFieldName»).duplicate();
			«cacheFieldName» = cacheValueDupe.v1;
			return cacheValueDupe.v2;
		«ENDIF»
	'''
	
}

class MultipleParameterMethodMemoizer extends ParametrizedMethodMemoizer {
	
	new(MutableMethodDeclaration method, TransformationContext context, int index) {
		super(method, context, index)
	}

	override parametersToCacheKey() '''
		java.util.Arrays.asList(«method.parameters.join("", ",", "")[ simpleName ]»);
	'''
}

class SingleParameterMethodMemoizer extends ParametrizedMethodMemoizer {
	
	new(MutableMethodDeclaration method, TransformationContext context, int index) {
		super(method, context, index)
	}

	override parametersToCacheKey() {
		method.parameters.head.simpleName
	}
}

/**
 * Parent type of all method memoizers with parameters
 */
abstract class ParametrizedMethodMemoizer extends MethodMemoizer {
	
	new(MutableMethodDeclaration method, TransformationContext context, int index) {
		super(method, context, index)
	}
	
	final override cacheFieldType() {
		HashMap.newTypeReference(
			Object.newTypeReference,
			wrappedReturnType
		)
	}

	final override cacheFieldInit(extension CompilationContext context) '''
		new «cacheFieldType.toJavaCode»((int)(«expectedSize»*1.5))
	'''
	
	def getExpectedSize() {
		method.findAnnotation(Memoizable.findTypeGlobally).getIntValue("expectedSize")
	}

	final override cacheCall(extension CompilationContext context) '''
		try {
			final Object cacheKey = «parametersToCacheKey»;
			if (!«cacheFieldName».containsKey(cacheKey)) {
				// do the heavy work outside the critical section.
				final «wrappedReturnType.toJavaCode» cacheValue = «initMethodName»(«initMethodParameters»);
				// we have a cache miss. hence we call the initializer method
				// and store the result for future calls. 
				«cacheFieldName».put(cacheKey, cacheValue);
			}
			«IF !Stream.newTypeReference.isAssignableFrom(wrappedReturnType)»
				// for non-lazy return types, return the cached value.
				return «cacheFieldName».get(cacheKey);
			«ELSE»
				«val typeArgument = wrappedReturnType.actualTypeArguments.head»
				// for lazy iterations use the duplicate feature of Jooq.
				final org.jooq.lambda.tuple.Tuple2<
					org.jooq.lambda.Seq<«typeArgument.toJavaCode»>, 
					org.jooq.lambda.Seq<«typeArgument.toJavaCode»>
				> cacheValueDupe = 
					org.jooq.lambda.Seq.seq(«cacheFieldName».get(cacheKey)).duplicate();
				«cacheFieldName».put(cacheKey, cacheValueDupe.v1);
				return cacheValueDupe.v2;
			«ENDIF»
		}
		catch (Throwable e) {
			throw «Exceptions.newTypeReference.toJavaCode».sneakyThrow(e.getCause());
		}
	'''

	/**
	 * Defines how a cache key object is created from method parameters.
	 */
	protected def CharSequence parametersToCacheKey()
	
	private def CharSequence initMethodParameters() {
		(method.parameters).join("", ",", "") [ simpleName ]
	}
}

/**
 * Parent type of all method memoizers.
 */
abstract class MethodMemoizer {

	protected val extension TransformationContext context
	protected val MutableMethodDeclaration method
	val int index

	new(MutableMethodDeclaration method, TransformationContext context, int index) {
		this.method = method
		this.context = context
		this.index = index
	}
	
	protected def TypeReference cacheFieldType()

	protected def CharSequence cacheFieldInit(CompilationContext context)
	
	protected def CharSequence cacheCall(CompilationContext context)

	def final generate() {
		// add a cache field and an initializer method.
		method.declaringType => [
			
			// cache field for storing memoized function return values.
			addField(cacheFieldName) [
				static = method.static
				type = cacheFieldType
				initializer = [cacheFieldInit]
			]
			
			// initializer method executes original method body for creating a cache value.
			addMethod(initMethodName) [ init |
				init.static = method.static
				init.visibility = Visibility.PRIVATE
				init.returnType = wrappedReturnType
				method.parameters.forEach[init.addParameter(simpleName, type)]
				init.exceptions = method.exceptions
				init.body = method.body
			]
		]
		
		// replace original method with one that tries to get the value
		// from cache first and if not existent executes the initializer method. 
		method => [
			body = [cacheCall]
			returnType = wrappedReturnType
		]
	}

	final protected def wrappedReturnType() {
		method.returnType.wrapperIfPrimitive
	}

	final protected def initMethodName() {
		method.simpleName + "_init"
	}

	final protected def String cacheFieldName() '''cache«index»_«method.simpleName»'''
}