require 'tempfile'

module SkyJam
  class Track
    module Source
      STORE = 1
      UPLOAD = 2
      MATCH = 6
    end

    attr_reader :id,
                :title,
                :album,
                :album_artist,
                :artist,
                :number,
                :size

    def initialize(info)
      @id = info[:id]
      @title = info[:title]
      @album = info[:album]
      @album_artist = info[:album_artist] unless info[:album_artist].nil? || info[:album_artist].empty?
      @artist = info[:artist]
      @number = info[:track_number]
      @size = info[:track_size]
    end

    def filename
      escape_path_component("%02d - #{title}" % number) << extname
    end

    def extname
      '.mp3'
    end

    def dirname
      path_components = [library.path,
                         escape_path_component(album_artist || artist),
                         escape_path_component(album)]
      File.join(path_components)
    end

    def path
      File.join(dirname, filename)
    end

    def local?
      File.exist?(path)
    end

    def download(lazy: false)
      return if !lazy || (lazy && local?)

      file = Tempfile.new(filename)
      begin
        file << data(remote: true)
      rescue SkyJam::Client::Error
        file.close!
        raise
      else
        make_dir
        FileUtils.mv(file.path, path)
      end
    end

    def data(remote: false)
      if remote || !local?
        url = client.download_url(id)
        client.download_track(url)
      else
        File.binread(path)
      end
    end

    def upload
      fail NotImplementedError
    end

    private

    attr_reader :library

    def client
      library.send(:client)
    end

    def make_dir
      FileUtils.mkdir_p(dirname)
    end

    def escape_path_component(component)
      # OSX:   : -> FULLWIDTH COLON (U+FF1A)
      # OSX:   / -> : (translated as / in Cocoa)
      # LINUX: / -> DIVISION SLASH (U+2215)
      component = component.dup

      component.gsub!(':', "\uFF1A")
      component.gsub!('/', ':')

      component
    end
  end
end
