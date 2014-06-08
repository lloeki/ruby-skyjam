module SkyJam
  class Library
    class << self
      def auth(path = nil)
        config = auth_config(path) || default_auth_config

        client = Client.new
        client.oauth2_setup
        client.uploader_auth

        FileUtils.mkdir_p(File.dirname(config))
        client.oauth2_persist(config)
      end

      def connect(path)
        library = new(path)

        config = default_auth_config if File.exist?(default_auth_config)
        config = auth_config(path) if File.exist?(auth_config(path))

        fail Client::Error, 'no auth' if config.nil?

        library.instance_eval do
          @client = Client.new
          @client.oauth2_restore(config)
        end

        library
      end

      private

      def default_auth_config
        File.join(ENV['HOME'], '.config/skyjam/skyjam.auth.yml')
      end

      def auth_config(path)
        File.join(path, '.skyjam.auth.yml') unless path.nil?
      end
    end

    attr_reader :path

    def initialize(path)
      @path = path
    end

    def tracks
      return @tracks unless @tracks.nil?

      @tracks = []
      continuation_token = nil

      loop do
        list = client.listtracks(continuation_token: continuation_token)

        continuation_token = list[:continuation_token]

        list[:track_info].each do |info|
          track = SkyJam::Track.new(info)
          library = self
          track.instance_eval { @library = library }

          @tracks << track
        end

        break if continuation_token == ''
      end

      @tracks
    end

    private

    attr_reader :client
  end
end
