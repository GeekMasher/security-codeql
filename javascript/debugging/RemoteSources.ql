/**
 * @name Remote Sources
 * @kind problem
 * @problem.severity note
 * @precision low
 * @id js/debugging/remote-sources
 * @tags debugging
 */

import stdlib

from RemoteSources sources
where
  // Filter results to a specific file
  filterByLocation(sources, "app.js", _)
select sources, "Remote Sources"
