private import semmle.python.dataflow.new.DataFlow
// Import Sinks
private import semmle.python.security.dataflow.CommandInjectionCustomizations
private import semmle.python.security.dataflow.CodeInjectionCustomizations
private import semmle.python.security.dataflow.ServerSideRequestForgeryCustomizations
private import semmle.python.security.dataflow.SqlInjectionCustomizations
private import semmle.python.security.dataflow.UnsafeDeserializationCustomizations

/**
 * Dangerous Sinks
 */
predicate dangerousSinks(DataFlow::Node sink) {
  (
    sink instanceof CommandInjection::Sink or
    sink instanceof CodeInjection::Sink or
    sink instanceof ServerSideRequestForgery::Sink or
    sink instanceof SqlInjection::Sink or
    sink instanceof UnsafeDeserialization::Sink
  ) and
  sink.getScope().inSource()
}
