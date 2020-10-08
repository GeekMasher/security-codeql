/**
 * @name Server-Side Request Forgery (SSRF)
 * @description Server-Side Request Forgery (SSRF)
 * @kind problem
 * @problem.severity error
 * @precision high
 * @id java/ssrf
 * @tags security
 *       external/cwe/cwe-918
 */

import java
import semmle.code.java.dataflow.TaintTracking
import semmle.code.java.dataflow.FlowSources

// https://docs.spring.io/spring-framework/docs/3.0.x/javadoc-api/org/springframework/web/client/RestTemplate.html

predicate isRestTemplate(Expr argument) {
  exists(MethodAccess call |
    call.getMethod().getDeclaringType().hasQualifiedName("org.springframework.web.client", "RestTemplate")
    and
    argument = call.getArgument(0)
  )
}

predicate isUrl(Expr argument) {
  exists(MethodAccess call |
    call.getMethod().getDeclaringType().hasQualifiedName("java.net", "URL")
    and
    call.getMethod().getName() = "openConnection"
    and
    argument = call
  )
}

from Expr argv
where isUrl(argv) or isRestTemplate(argv)
select argv
