/**
 * @name Uncontrolled command line
 * @description Using externally controlled strings in a command line may allow a malicious
 *              user to change the meaning of the command.
 * @kind path-problem
 * @problem.severity error
 * @sub-severity high
 * @precision low
 * @id py/command-line-injection-local
 * @tags correctness
 *       security
 *       external/owasp/owasp-a1
 *       external/cwe/cwe-078
 *       external/cwe/cwe-088
 */

import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.dataflow.new.TaintTracking
import semmle.python.Concepts
import semmle.python.dataflow.new.BarrierGuards
import semmle.python.ApiGraphs
import DataFlow::PathGraph

// ========== Sources ==========
abstract private class LocalSources extends DataFlow::Node { }

class STDInputSources extends LocalSources {
  STDInputSources() {
    exists(DataFlow::Node call |
      (
        // v = input("Input?")
        call = API::builtin("input").getACall()
        or
        // https://docs.python.org/3/library/fileinput.html
        call = API::moduleImport("fileinput").getMember("input").getACall()
      ) and
      this = call
    )
  }
}

class ArgumentsSources extends LocalSources {
  ArgumentsSources() {
    exists(DataFlow::Node call |
      (
        // v = sys.args[1]
        call = API::moduleImport("sys").getMember("argv").getAUse()
        or
        // parser = argparse.ArgumentParser(__name__)
        // ...
        // arguments = parser.parse_args()
        // v = arguments.t     # source
        call = API::moduleImport("argparse").getMember("ArgumentParser").getACall()
      ) and
      this = call
    )
  }
}

class EnviromentVariablesSources extends LocalSources {
  EnviromentVariablesSources() {
    exists(DataFlow::Node call |
      (
        // os.getenv('abc')
        call = API::moduleImport("os").getMember("getenv").getACall()
        or
        // os.environ['abc']
        call = API::moduleImport("os").getMember("environ").getAUse()
        // or
        // os.environ.get('abc')
        // TODO: Seems to get us a duplicate due to the `.getAUse()`
        // call = API::moduleImport("os").getMember("environ").getMember("get").getACall()
      ) and
      this = call
    )
  }
}

class FileReadSource extends LocalSources {
  FileReadSource() {
    exists(DataFlow::Node call |
      (
        // var = open('abc.txt')
        call = API::builtin("open").getACall()
      ) and
      this = call
    )
  }
}

// ========== Configuration ==========
class CommandInjectionConfiguration extends TaintTracking::Configuration {
  CommandInjectionConfiguration() { this = "LocalCommandInjectionConfiguration" }

  override predicate isSource(DataFlow::Node source) { source instanceof LocalSources }

  override predicate isSink(DataFlow::Node sink) {
    sink = any(SystemCommandExecution e).getCommand() and
    not sink.getScope().getEnclosingModule().getName() in ["os", "subprocess", "platform", "popen2"]
  }

  override predicate isSanitizerGuard(DataFlow::BarrierGuard guard) {
    guard instanceof StringConstCompare
  }
}

from CommandInjectionConfiguration config, DataFlow::PathNode source, DataFlow::PathNode sink
where config.hasFlowPath(source, sink)
select sink.getNode(), source, sink, "This command depends on $@.", source.getNode(),
  "a user-provided value"
