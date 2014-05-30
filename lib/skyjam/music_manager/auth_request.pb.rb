##
# This file is auto-generated. DO NOT EDIT!
#
require 'protobuf/message'

module SkyJam
  module MusicManager

    ##
    # Message Classes
    #
    class AuthRequest < ::Protobuf::Message; end


    ##
    # Message Fields
    #
    class AuthRequest
      required :string, :id, 1
      optional :string, :name, 2
    end

  end

end

