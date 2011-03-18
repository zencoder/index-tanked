begin
  require 'system_timer'
  IndexTankedTimer = SystemTimer
rescue LoadError
  require 'timeout'
  IndexTankedTimer = Timeout
end

require 'indextank'
require 'will_paginate/collection'

require 'index_tanked/index_tanked'
require 'index_tanked/class_companion'
require 'index_tanked/class_methods'
require 'index_tanked/configuration'
require 'index_tanked/instance_companion'
require 'index_tanked/instance_methods'
require 'index_tanked/search_result'
require 'index_tanked/version'
require 'index_tanked/active_record_defaults/class_companion'
require 'index_tanked/active_record_defaults/class_methods'
require 'index_tanked/active_record_defaults/instance_companion'
require 'index_tanked/active_record_defaults/instance_methods'
require 'index_tanked/active_record_defaults/search_result'
