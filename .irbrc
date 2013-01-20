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

if ENV['RAILS_ENV'] || defined?(Rails)

  def sql(query)
    ActiveRecord::Base.connection.select_all(query)
  end

  require 'logger'
  if defined?(Rails) && Rails.respond_to?(:logger=)
    tagged_logger = defined?(ActiveSupport::TaggedLogging) && Rails.logger.is_a?(ActiveSupport::TaggedLogging)
    Rails.logger = Logger.new(STDOUT)
    Rails.logger = ActiveSupport::TaggedLogging.new(Rails.logger) if tagged_logger
    defined?(ActiveRecord) && ActiveRecord::Base.logger = Rails.logger
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
