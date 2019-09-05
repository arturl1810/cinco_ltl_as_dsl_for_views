package de.jabc.cinco.meta.plugin.modelchecking.runtime.formulas

import java.util.Set
import de.jabc.cinco.meta.plugin.modelchecking.runtime.core.Result
import graphmodel.Node

class CheckFormula {
	String expression
	String description
	boolean toCheck
	Result result
	Set<Node> satisfyingNodes
	String errorMessage
	final String id

	new(String id) {
		this.id = id
		result = Result.NOT_CHECKED
		errorMessage = ""
		satisfyingNodes = newHashSet
		expression = ""
		description = ""
		toCheck = true
	}

	new(String id, String expression) {
		this(id)
		setExpression(expression)
	}

	def getErrorMessage() {
		errorMessage
	}

	def setErrorMessage(String errorMessage) {
		this.errorMessage = errorMessage
	}

	def resetCheckResult() {
		result = Result.NOT_CHECKED
		satisfyingNodes.clear
	}

	def getExpression() {
		expression
	}

	def setExpression(String expression) {
		this.result = Result.NOT_CHECKED
		this.expression = expression
	}

	def getDescription() {
		description
	}

	def setDescription(String description) {
		this.description = description
	}

	def isToCheck() {
		toCheck
	}

	def setToCheck(boolean toCheck) {
		this.toCheck = toCheck
	}

	def getResult() {
		result
	}

	def setResult(Result result) {
		this.result = result
	}

	def hasSatisfyingNodes() {
		!satisfyingNodes.isEmpty()
	}

	def getSatisfyingNodes() {
		satisfyingNodes
	}

	def setSatisfyingNodes(Set<Node> satisfyingNodes) {
		if (satisfyingNodes !== null) {
			this.satisfyingNodes = satisfyingNodes
		} else {
			resetCheckResult
		}
	}

	def getId() {
		id
	}
}
