DB = "rsei_historical_tracts"
PROJECT_ROOT = "#{File.dirname(File.expand_path(__FILE__))}"
DATA_ROOT = "#{PROJECT_ROOT}/data"

require 'bundler'
Bundler.require(:default)

Dir["#{File.dirname(File.expand_path(__FILE__))}/tasks/*.rake"].each do |task|
  load task
end