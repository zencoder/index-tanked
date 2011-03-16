begin
  require 'system_timer'
  IndexTankedTimer = SystemTimer
rescue LoadError
  require 'timeout'
  IndexTankedTimer = Timeout
end

require 'indextank'
require 'will_paginate/collection'

require 'index-tanked/index_tanked.rb'
require 'index-tanked/class_companion'
require 'index-tanked/class_methods'
require 'index-tanked/configuration'
require 'index-tanked/instance_companion'
require 'index-tanked/instance_methods'
require 'index-tanked/search_result'
require 'index-tanked/version'
require 'index-tanked/active_record_defaults/class_methods'
require 'index-tanked/active_record_defaults/class_companion'
require 'index-tanked/active_record_defaults/instance_methods'
require 'index-tanked/active_record_defaults/search_result'
