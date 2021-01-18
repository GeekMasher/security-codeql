/**
 * @name Deprecated Methods (MongoDB)
 * @description Deprecated Methods in MongoDB
 * @kind problem
 * @problem.severity note
 * @precision high
 * @id js/deprecated-methods
 * @tags security
 *       external/cwe/cwe-477
 */

import javascript
import semmle.javascript.dataflow.DataFlow

// http://mongodb.github.io/node-mongodb-native/3.6/api/Collection.html#insert

from CallExpr call, Expr expr
where
    call.getCalleeName() = "insert" and expr = call.getCallee()
select expr, "Deprecated Methods in MongoDB"
