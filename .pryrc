Pry.config.pager = false
Pry.config.prompt = [proc { ">> " },
                     proc { " | " }]

Pry.config.prompt_name = (ENV['USER'] || "pry")

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
