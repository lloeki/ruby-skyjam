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
      File.join(library.path,
                album_artist || artist,
                album,
                "#{number} - #{title}"
      ).gsub(':', '_') << '.mp3'
    end

    def local?
      File.exist?(filename)
    end

    def download(lazy: true)
      if !lazy || (lazy && !local?)
        make_dir
        File.open(filename, 'wb') do |f|
          f << data(remote: true)
        end
      end
    end

    def data(remote: false)
      if remote || !local?
        url = client.download_url(id)
        client.download_track(url)
      else
        File.binread(filename)
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

    def dirname
      File.dirname(filename)
    end

    def make_dir
      FileUtils.mkdir_p(dirname)
    end
  end
end
