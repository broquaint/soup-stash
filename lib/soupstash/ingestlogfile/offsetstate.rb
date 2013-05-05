require 'moped'

class IngestLogfile
  # Keep the state of where we were at in the logfile so we're not
  # forever playing catchup/scrollback when restarting keeping-up-with-the-logs.
  class OffsetState
    def initialize(logfile_uri)
      @uri = logfile_uri
      @mongo = Moped::Session.new([ "127.0.0.1:27017" ])
      @mongo.use "logfile_offsets"
    end

    def get_latest
      result = offset_in_db
      return result['offset'].to_i || 0
    end
    def update_to(offset)
      # TODO maybe check offset .is_a? Integer.
      offset_query.upsert(offset_in_db.merge('offset' => offset.to_i))
    end

    private

    def offset_query
      @mongo[:offsets].find(uri: @uri)
    end
    def offset_in_db
      offset_query.first || { uri: @uri }
    end
  end
end
