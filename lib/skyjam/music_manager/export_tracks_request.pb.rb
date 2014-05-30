##
# This file is auto-generated. DO NOT EDIT!
#
require 'protobuf/message'

module MusicManager

  ##
  # Message Classes
  #
  class ExportTracksRequest < ::Protobuf::Message
    class TrackType < ::Protobuf::Enum
      define :ALL, 1
      define :STORE, 2
    end

  end



  ##
  # Message Fields
  #
  class ExportTracksRequest
    required :string, :client_id, 2
    optional :string, :continuation_token, 3
    optional ::MusicManager::ExportTracksRequest::TrackType, :export_type, 4
    optional :int64, :updated_min, 5
  end

end

