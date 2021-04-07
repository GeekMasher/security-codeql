import python
import semmle.python.security.Paths
import semmle.python.web.HttpRequest
import semmle.python.dataflow.TaintTracking
import semmle.python.security.strings.Untrusted

abstract class TemplateSinks extends TaintSink { }

class FlaskSinks extends TemplateSinks {
  override string toString() { result = "flask.render_template_string" }

  override predicate sinks(TaintKind kind) { kind instanceof ExternalStringKind }

  FlaskSinks() {
    exists(CallNode call |
      call = Value::named("flask.render_template_string").getACall() and
      this = call.getArg(0)
    )
  }
}
