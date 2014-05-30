##
# This file is auto-generated. DO NOT EDIT!
#
require 'protobuf/message'

module SkyJam
  module MusicManager

    ##
    # Message Classes
    #
    class Response < ::Protobuf::Message
      class Type < ::Protobuf::Enum
        define :METADATA, 1
        define :PLAYLIST, 2
        define :PLAYLIST_ENTRY, 3
        define :SAMPLE, 4
        define :JOBS, 5
        define :AUTH, 6
        define :CLIENT_STATE, 7
        define :UPDATE_UPLOAD_STATE, 8
        define :DELETE_UPLOAD_REQUESTED, 9
      end

      class AuthStatus < ::Protobuf::Enum
        define :OK, 8
        define :MAX_LIMIT_REACHED, 9
        define :CLIENT_BOUND_TO_OTHER_ACCOUNT, 10
        define :CLIENT_NOT_AUTHORIZED, 11
        define :MAX_PER_MACHINE_USERS_EXCEEDED, 12
        define :CLIENT_PLEASE_RETRY, 13
        define :NOT_SUBSCRIBED, 14
        define :INVALID_REQUEST, 15
      end

      class Status < ::Protobuf::Message
        class Code < ::Protobuf::Enum
          define :OK, 1
          define :ALREADY_EXISTS, 2
          define :SOFT_ERROR, 3
          define :METADATA_TOO_LARGE, 4
        end

      end


    end



    ##
    # Message Fields
    #
    class Response
      class Status
        required ::SkyJam::MusicManager::Response::Status::Code, :code, 1
      end

      optional ::SkyJam::MusicManager::Response::Type, :type, 1
      optional ::SkyJam::MusicManager::Response::AuthStatus, :auth_status, 11
      optional :bool, :auth_error, 12
    end

  end

end

