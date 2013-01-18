# Require RubyGems by default.
require 'rubygems'
require 'irb/completion'

completion_path = File.expand_path("~/.irb/fixed_save_history.rb")
require completion_path if File.exist?(completion_path)
IRB.conf[:SAVE_HISTORY] = 10000000
IRB.conf[:HISTORY_FILE] = File.expand_path("~/.irb-save-history")

begin
  require "ap"
  IRB::Irb.class_eval do
    def output_value
      ap @context.last_value
    end
  end
rescue LoadError => e
  require 'pp'
  IRB::Irb.class_eval do
    def output_value
      pp @context.last_value
    end
  end
end

def diff(a, b, file = "current.diff")
  require 'rspec/expectations/differ'
  differ = RSpec::Expectations::Differ.new
  diff = differ.diff_as_object(a, b)
  File.open(file, "w+") { |f| f.write diff }
  system "mate", file
end

require 'pp'

# Benchmarking
require 'benchmark'
def bench(n=1e3,&b)
  Benchmark.bmbm do |r|
    r.report {n.to_i.times(&b)}
  end
end

class Object
  def local_methods(obj = self)
    (obj.methods - obj.class.superclass.instance_methods).sort
  end
end

# Use the simple prompt if possible.
IRB.conf[:PROMPT_MODE] = :SIMPLE if IRB.conf[:PROMPT_MODE] == :DEFAULT

if ENV['RAILS_ENV'] || defined?(Rails)

  def sql(query)
    ActiveRecord::Base.connection.select_all(query)
  end

  require 'logger'
  if defined?(Rails) && Rails.respond_to?(:logger=)
    new_logger = Logger.new(STDOUT)
    if defined?(ActiveSupport::TaggedLogging)
      new_logger = ActiveSupport::TaggedLogging.new(new_logger)
    end
    Rails.logger = new_logger
    defined?(ActiveRecord) && ActiveRecord::Base.logger = Rails.logger
    defined?(Mongoid)      && Mongoid.logger = Rails.logger
    if defined?(MongoMapper)
      MongoMapper.connection.instance_variable_set :@logger, Rails.logger
    end
  else
    Object.const_set(:RAILS_DEFAULT_LOGGER, Logger.new(STDOUT))
  end

  def loud_logger
    set_logger_to Logger.new(STDOUT)
  end

  def quiet_logger
    set_logger_to nil
  end

  def set_logger_to(logger)
    ActiveRecord::Base.logger = logger
    ActiveRecord::Base.clear_active_connections!
  end
end
