/**
 * Helper functions for debugging
 */

private import semmle.code.java.dataflow.DataFlow
private import semmle.code.java.dataflow.ExternalFlow
private import semmle.code.java.dataflow.FlowSources
// Sinks
private import semmle.code.java.security.QueryInjection
private import semmle.code.java.security.CommandLineQuery
private import semmle.code.java.security.LdapInjection
private import semmle.code.java.security.LogInjection
private import semmle.code.java.security.OgnlInjection
private import semmle.code.java.security.RequestForgery
private import semmle.code.java.security.TemplateInjection

/**
 * Filter nodes by its location (relative path or base name).
 */
bindingset[relative_path]
predicate findByLocation(DataFlow::Node node, string relative_path, int linenumber) {
  node.getLocation().getFile().getRelativePath().matches(relative_path) and
  node.getLocation().getStartLine() = linenumber
}

/**
 * This will only show sinks that are callable (method calls)
 */
predicate isCallable(DataFlow::Node sink) { sink.asExpr() instanceof MethodCall }

/**
 * Check if the source node is a method parameter.
 */
predicate checkSource(DataFlow::Node source) {
  // TODO: fix this
  source.asParameter() instanceof Parameter
  or
  source.asExpr() instanceof MethodCall
}

/**
 * List of all the souces
 */
class AllSources extends DataFlow::Node {
  AllSources() {
    this instanceof LocalUserInput or
    this instanceof RemoteFlowSource or
    this instanceof ActiveThreatModelSource
  }
}

/**
 * List of all the sinks that we want to check.
 */
class AllSinks extends DataFlow::Node {
  AllSinks() {
    this instanceof QueryInjectionSink or
    this instanceof CommandInjectionSink or
    this instanceof LdapInjectionSink or
    this instanceof LogInjectionSink or
    this instanceof OgnlInjectionSink or
    this instanceof RequestForgerySink or
    this instanceof TemplateInjectionSink or
    // All MaD sinks
    sinkNode(this, _)
  }
}
