##
# This file is auto-generated. DO NOT EDIT!
#
require 'protobuf/message'

module SkyJam
  module MusicManager

    ##
    # Message Classes
    #
    class ExportTracksResponse < ::Protobuf::Message
      class Status < ::Protobuf::Enum
        define :OK, 1
        define :TRANSIENT_ERROR, 2
        define :MAX_CLIENTS, 3
        define :CLIENT_AUTH_ERROR, 4
        define :CLIENT_REG_ERROR, 5
      end

      class TrackInfo < ::Protobuf::Message; end

    end



    ##
    # Message Fields
    #
    class ExportTracksResponse
      class TrackInfo
        optional :string, :id, 1
        optional :string, :title, 2
        optional :string, :album, 3
        optional :string, :album_artist, 4
        optional :string, :artist, 5
        optional :int32, :track_number, 6
        optional :int64, :track_size, 7
      end

      required ::SkyJam::MusicManager::ExportTracksResponse::Status, :status, 1
      repeated ::SkyJam::MusicManager::ExportTracksResponse::TrackInfo, :track_info, 2
      optional :string, :continuation_token, 3
      optional :int64, :updated_min, 4
    end

  end

end

