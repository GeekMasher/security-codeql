/**
 * @name Hard-coded password field
 * @description Hard-coding a password string may compromise security.
 * @kind problem
 * @problem.severity error
 * @security-severity 9.8
 * @precision low
 * @id java/hardcoded-password-field
 * @tags security
 *       external/cwe/cwe-798
 */

import java
import semmle.code.configfiles.ConfigFiles

private string getCredencialString() {
  // Regex?
  result = "jdbc.password" or
  result = "db.password"
}

class ConfigProperties extends ConfigPair {
  string getValue() { result = this.getValueElement().getValue().trim() }
}

class DatabaseProperties extends ConfigProperties {
  DatabaseProperties() { this.getNameElement().getName() = getCredencialString() }
}

from DatabaseProperties conf
select conf, "Hardcoded password in property file found"
