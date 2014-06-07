module SkyJam
  class Library
    class << self
      def connect(path)
        library = new(path)

        library.instance_eval do
          @client = Client.new
          @client.oauth2_restore
        end

        library
      end
    end

    attr_reader :path

    def initialize(path)
      @path = path
    end

    def tracks
      @tracks ||= client.listtracks[:track_info].map do |info|
        track = SkyJam::Track.new(info)
        library = self
        track.instance_eval { @library = library }

        track
      end
    end

    private

    attr_reader :client
  end
end
