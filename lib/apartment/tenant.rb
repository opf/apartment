require 'forwardable'

module Apartment
  #   The main entry point to Apartment functions
  #
  module Tenant

    extend self
    extend Forwardable

    def_delegators :adapter, :create, :drop, :switch, :switch!, :each, :reset, :set_callback, :seed, :current_tenant, :default_tenant, :environmentify

    attr_writer :config

    #   Initialize Apartment config options such as excluded_models
    #
    def init
      adapter.process_excluded_models
    end

    def current
      adapter.current
    rescue => e
      # this will happen when the db was just created in which case it is safe to ignore
      raise e unless e.message.include?("nulldb_adapter")

      nil
    end

    #   Fetch the proper multi-tenant adapter based on Rails config
    #
    #   @return {subclass of Apartment::AbstractAdapter}
    #
    def adapter
      Thread.current[:apartment_adapter] ||= begin
        adapter_method = "#{config[:adapter]}_adapter"

        if defined?(JRUBY_VERSION)
          if config[:adapter] =~ /mysql/
            adapter_method = 'jdbc_mysql_adapter'
          elsif config[:adapter] =~ /postgresql/
            adapter_method = 'jdbc_postgresql_adapter'
          end
        end

        begin
          require "apartment/adapters/#{adapter_method}"
        rescue LoadError
          raise "The adapter `#{adapter_method}` is not yet supported"
        end

        unless respond_to?(adapter_method)
          raise AdapterNotFound, "database configuration specifies nonexistent #{config[:adapter]} adapter"
        end

        send(adapter_method, config)
      end
    end

    #   Reset config and adapter so they are regenerated
    #
    def reload!(config = nil)
      Thread.current[:apartment_adapter] = nil
      @config = config
    end

    private

    #   Fetch the rails database configuration
    #
    def config
      @config ||= Apartment.connection_config
    end
  end
end
