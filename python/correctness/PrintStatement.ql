/**
 * @name Using Print Statement in Production Code
 * @description Print Statement should not be used in Production Code, use logging instead.
 * @kind problem
 * @problem.severity recommendation
 * @id py/print-statement
 * @precision very-high
 * @tags correctness
 */

import python
import semmle.python.Concepts
import semmle.python.ApiGraphs
import semmle.python.dataflow.new.DataFlow

from DataFlow::Node print
where
  print = API::builtin("print").getACall() and
  print.getScope().inSource() and
  not print
      .getLocation()
      .getFile()
      .getRelativePath()
      .regexpMatch("^.*(?:(/examples/.*)|/__main__.py)$")
select print, "use of print statement"
