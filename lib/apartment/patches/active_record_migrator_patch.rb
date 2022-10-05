##
# We patch this so switching between schemas during migrations doesn't take forever.
#
# Solution by Steven Schmid (stevschmid): https://github.com/rails-on-services/apartment/issues/147#issuecomment-779345751

module ActiveRecord
  # This class is used to create a connection that we can use for advisory
  # locks. This will take out a "global" lock that can't be accidentally
  # removed if a new connection is established during a migration.
  class AdvisoryLockBase < ActiveRecord::Base # :nodoc:
    self.abstract_class = true

    self.connection_specification_name = "AdvisoryLockBase"

    class << self
      def _internal?
        true
      end
    end
  end
end

module ActiveRecord
  class Migrator
    def with_advisory_lock_connection
      AdvisoryLockBase.establish_connection(ActiveRecord::Base.connection_db_config) unless AdvisoryLockBase.connected?
      yield(AdvisoryLockBase.connection)
    end
  end
end
