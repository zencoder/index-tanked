module IndexTanked
  begin
    require 'system_timer'
    Timer = SystemTimer
  rescue LoadError
    require 'timeout'
    Timer = Timeout
  end
end

require 'indextank'
require 'will_paginate/collection'

require 'index-tanked/index_tanked'
require 'index-tanked/class_companion'
require 'index-tanked/class_methods'
require 'index-tanked/configuration'
require 'index-tanked/instance_companion'
require 'index-tanked/instance_methods'
require 'index-tanked/search_result'
require 'index-tanked/version'
require 'index-tanked/active_record_defaults/class_companion'
require 'index-tanked/active_record_defaults/class_methods'
require 'index-tanked/active_record_defaults/instance_companion'
require 'index-tanked/active_record_defaults/instance_methods'
require 'index-tanked/active_record_defaults/search_result'
require 'index-tanked/active_record_defaults/queue/document'
require 'index-tanked/active_record_defaults/queue/worker'
