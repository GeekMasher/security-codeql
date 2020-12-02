/**
 * @name Double compilation
 * @description Recompiling an already compiled part of the DOM can lead to
 *              unexpected behavior of directives, performance problems, and memory leaks.
 * @kind problem
 * @problem.severity warning
 * @precision very-high
 * @id js/angular/double-compilation
 * @tags security
 *       frameworks/angularjs
 *       external/cwe/cwe-079
 *       external/cwe/cwe-116
 */

import javascript

DataFlow::SourceNode getAElementReference(SimpleParameter elem) {
  elem =
    any(AngularJS::CustomDirective d)
        .getALinkFunction()
        .(AngularJS::LinkFunction)
        .getElementParameter() and
  result = DataFlow::parameterNode(elem)
  or
  // TODO: Add more jQuery methods that return elements/children
  result = getAElementReference(elem).getAMemberCall(["contents", "children", "find", "filter"])
}

from AngularJS::ServiceReference compile, SimpleParameter elem, CallExpr c
where
  compile.getName() = "$compile" and
  c = compile.getACall() and
  getAElementReference(elem).flowsToExpr(c.getArgument(0)) and
  // don't flag $compile calls that specify a `maxPriority`
  c.getNumArgument() < 3
select c, "This call to $compile may cause double compilation of '" + elem + "'."