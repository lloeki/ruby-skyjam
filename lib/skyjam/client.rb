module SkyJam
  class Client
    def initialize
      @base_url = 'https://play.google.com/music/'
      @service_url = @base_url + 'services/'
      @android_url = 'https://android.clients.google.com/upsj/'

      load_config
    end

    ### Simple auth
    # login: with app-specific password, obtain auth token
    # cookie: with auth token, obtain cross token (xt)
    # loadalltracks: with auth token and cross token, obtain list of tracks

    def login
      uri = URI('https://www.google.com/accounts/ClientLogin')

      q = { 'service'      => 'sj',
            'account_type' => 'GOOGLE',
            'source'       => 'ruby-skyjam-%s' % SkyJam::VERSION,
            'Email'        => @account,
            'Passwd'       => @password }

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      req = Net::HTTP::Post.new(uri.path)
      req.set_form_data(q)
      res = http.request(req)
      puts 'fail' unless res.is_a? Net::HTTPSuccess
      tokens = Hash[*res.body
                        .split("\n")
                        .map { |r| r.split('=', 2) }
                        .flatten]
      @sid = tokens['SID']
      @auth = tokens['Auth']
    end

    def cookie
      uri = URI(@base_url + 'listen')

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      req = Net::HTTP::Head.new(uri.path)
      req['Authorization'] = 'GoogleLogin auth=%s' % @auth
      res = http.request(req)
      puts 'fail' unless res.is_a? Net::HTTPSuccess
      h = res.to_hash['set-cookie']
             .map { |e| e =~ /^xt=([^;]+);/ and $1 }
             .compact.first
      @cookie = h
    end

    ## Web Client API

    def loadalltracks
      uri = URI(@service_url + 'loadalltracks')

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      req = Net::HTTP::Post.new(uri.path)
      req.set_form_data('u' => 0, 'xt' => @cookie)
      req['Authorization'] = 'GoogleLogin auth=%s' % @auth
      res = http.request(req)
      puts 'fail' unless res.is_a? Net::HTTPSuccess
      JSON.parse(res.body)
    end

    ## OAuth2
    # https://developers.google.com/accounts/docs/OAuth2InstalledApp
    # https://code.google.com/apis/console

    def oauth2_access
      { client_id: '256941431767.apps.googleusercontent.com',
        client_secret: 'oHTZP8zhh7E8wF6NWsiDULhq' }
    end

    def oauth2_endpoint
      { site: 'https://accounts.google.com',
        authorize_url: '/o/oauth2/auth',
        token_url: '/o/oauth2/token' }
    end

    def oauth2_request
      { scope: 'https://www.googleapis.com/auth/musicmanager',
        access_type: 'offline',
        approval_prompt: 'force',
        redirect_uri: 'urn:ietf:wg:oauth:2.0:oob' }
    end

    def oauth2_client
      @oauth2_client ||= OAuth2::Client.new(oauth2_access[:client_id],
                                            oauth2_access[:client_secret],
                                            oauth2_endpoint)
      @oauth2_client
    end

    def oauth2_setup
      # ask for OOB auth code
      puts oauth2_client.auth_code.authorize_url(oauth2_request)
      # user gives code
      puts 'code: '
      code = gets.chomp.strip
      # exchange code for access token and refresh token
      uri = oauth2_request[:redirect_uri]
      access = oauth2_client.auth_code.get_token(code,
                                                 redirect_uri: uri,
                                                 token_method: :post)
      puts 'access: '  + access.token
      puts 'refresh: ' + access.refresh_token
      # expires_in
      # token_type: Bearer
      @oauth2_access_token = access
    end

    def oauth2_persist
      File.open('oauth2.token.yml', 'wb') do |f|
        f.write(YAML.dump(refresh_token: @oauth2_access_token.refresh_token))
      end
    end

    def oauth2_restore
      token_h = YAML.load(File.read('oauth2.token.yml'))
      oauth2_login(token_h[:refresh_token])
    end

    def oauth2_login(refresh_token)
      @oauth2_access_token = OAuth2::AccessToken
                              .from_hash(oauth2_client,
                                         refresh_token: refresh_token)
      oauth2_refresh_access_token
    end

    def oauth2_refresh_access_token
      @oauth2_access_token = @oauth2_access_token.refresh!
    end

    def oauth2_access_token_expired?
      @oauth2_access_token.expired?
    end

    def oauth2_authentication_header
      @oauth2_access_token.options[:header_format] % @oauth2_access_token.token
    end

    ## MusicManager Uploader identification

    def mac_addr
      case RUBY_PLATFORM
      when /darwin/
        if (m = `ifconfig en0`.match(/ether (\S{17})/))
          m[1].upcase
        end
      end
    end

    def hostname
      `hostname`.chomp.gsub(/\.local$/, '')
    end

    def uploader_id
      # TODO: overflow
      mac_addr.gsub(/\d{2}$/) { |s| '%02X' % (s.hex + 2) }
    end

    def uploader_name
      "#{hostname} (ruby-skyjam-#{VERSION})"
    end

    def uploader_auth
      # {'User-agent': 'Music Manager (1, 0, 55, 7425 HTTPS - Windows)'}'
      # uploader_id uploader_name
      pb_body = MusicManager::AuthRequest.new
      pb_body.id = uploader_id
      pb_body.name = uploader_name

      uri = URI(@android_url + 'upauth')

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      req = Net::HTTP::Post.new(uri.path)
      req.body = pb_body.serialize_to_string
      req['Content-Type'] = 'application/x-google-protobuf'
      req['Authorization'] = oauth2_authentication_header
      res = http.request(req)
      puts 'fail' unless res.is_a? Net::HTTPSuccess

      MusicManager::Response.new.parse_from_string(res.body)
    end

    ## MusicManager API

    def listtracks
      oauth2_refresh_access_token if oauth2_access_token_expired?

      pb_body = MusicManager::ExportTracksRequest.new
      pb_body.client_id = uploader_id
      pb_body.export_type = MusicManager::ExportTracksRequest::TrackType::ALL

      uri = URI('https://music.google.com/music/exportids')

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      req = Net::HTTP::Post.new(uri.path)
      req.body = pb_body.serialize_to_string
      req['Content-Type'] = 'application/x-google-protobuf'
      req['Authorization'] = oauth2_authentication_header
      req['X-Device-ID'] = uploader_id
      res = http.request(req)
      puts 'fail' unless res.is_a? Net::HTTPSuccess

      MusicManager::ExportTracksResponse.new.parse_from_string(res.body)
    end

    def download_url(song_id)
      uri = URI('https://music.google.com/music/export')
      q = { version: 2, songid: song_id }

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      qs = q.map { |k, v| "#{k}=#{v}" }.join('&')
      req = Net::HTTP::Get.new(uri.path + '?' + qs)
      req['Authorization'] = oauth2_authentication_header
      req['X-Device-ID'] = uploader_id
      res = http.request(req)
      puts 'fail' unless res.is_a? Net::HTTPSuccess

      JSON.parse(res.body)
    end

    def download_track(url)
      uri = URI(url)

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      req = Net::HTTP::Get.new(uri.path + '?' + uri.query)
      req['Authorization'] = oauth2_authentication_header
      #req['User-Agent'] = 'Music Manager (1, 0, 55, 7425 HTTPS - Windows)'
      req['X-Device-ID'] = uploader_id
      res = http.request(req)
      puts 'fail' unless res.is_a? Net::HTTPSuccess

      res.body
    end

    def read_config
      YAML.load(File.read('auth.yml'))
    end

    def load_config
      config = read_config
      @account = config['account']
      @password = config['password']
    end
  end
end
