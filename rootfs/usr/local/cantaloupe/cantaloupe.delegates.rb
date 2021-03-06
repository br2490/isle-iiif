##
# Cantaloupe ruby delegates file for Islandora Vagrant base box
# @modifiedby: Diego Pino, dpino@metro.org
# @stolenby: Benjamin Rosner, brosner@barnard.edu
# @use: ISLE image-services docker image.
#
# code may change from version to version. See the "Upgrading" section of
# Tested with 3.4.2.
#
##

module Cantaloupe

  ##
  # Tells the server whether the given request is authorized. Will be called
  # upon all image requests to any endpoint.
  #
  # Implementations should assume that the underlying resource is available,
  # and not try to check for it.
  #
  # @param identifier [String] Image identifier
  # @param full_size [Hash<String,Integer>] Hash with `width` and `height`
  #                                         keys corresponding to the pixel
  #                                         dimensions of the source image.
  # @param operations [Array<Hash<String,Object>>] Array of operations in
  #                   order of execution. Only operations that are not no-ops
  #                   will be included. Every hash contains a `class` key
  #                   corresponding to the operation class name, which will be
  #                   one of the e.i.l.c.operation.Operation implementations.
  # @param resulting_size [Hash<String,Integer>] Hash with `width` and `height`
  #                       keys corresponding to the pixel dimensions of the
  #                       resulting image after all operations are applied.
  # @param output_format [Hash<String,String>] Hash with `media_type` and
  #                                            `extension` keys.
  # @param request_uri [String] Full request URI
  # @param request_headers [Hash<String,String>]
  # @param client_ip [String]
  # @param cookies [Hash<String,String>]
  # @return [Boolean,Hash<String,Object] To allow or deny the request, return
  #         true or false. To perform a redirect, return a hash with
  #         `location` and `status_code` keys. `location` must be a URL;
  #         `status_code` must be an integer from 300 to 399.
  #
  def self.authorized?(identifier, full_size, operations, resulting_size,
                       output_format, request_uri, request_headers, client_ip,
                       cookies)
    true
  end

  ##
  # Used to add additional keys to an information JSON response, including
  # `attribution`, `license`, `logo`, `service`, and other custom keys. See
  # the [Image API specification](http://iiif.io/api/image/2.1/#image-information).
  #
  # @param identifier [String] Image identifier
  # @return [Hash] Hash that will be merged into IIIF Image API 2.x
  #                information responses. Return an empty hash to add nothing.
  #
  def self.extra_iiif2_information_response_keys(identifier)
=begin
    Example:
    {
        'attribution' =>  'Copyright My Great Organization. All rights '\
                          'reserved.',
        'license' =>  'http://example.org/license.html',
        'logo' =>  'http://example.org/logo.png',
        'service' => {
            '@context' => 'http://iiif.io/api/annex/services/physdim/1/context.json',
            'profile' => 'http://iiif.io/api/annex/services/physdim',
            'physicalScale' => 0.0025,
            'physicalUnits' => 'in'
        }
    }
=end
    {}
  end

  ##
  # Tells which resolver to use for the given identifier.
  #
  # @param identifier [String] Image identifier
  # @return [String] Resolver name
  #
  def self.get_resolver(identifier)
  end

  module FilesystemResolver

    ##
    # @param identifier [String] Image identifier
    # @param context [Hash] Context for this request
    # @return [String,nil] Absolute pathname of the image corresponding to the
    #                      given identifier, or nil if not found.
    #
    def self.get_pathname(identifier, context)
    end

  end

  module AmazonS3Resolver

    ##
    # @param identifier [String] Image identifier
    # @param context [Hash] Context for this request
    # @return [String,Hash<String,Object>,nil] S3 object key of the image 
    #					corresponding to the given identifier, 
    #                   or Hash including bucket and key, or nil if not found.
    #
    def self.get_object_key(identifier, context)
    end

  end

  module AzureStorageResolver

    ##
    # @param identifier [String] Image identifier
    # @param context [Hash] Context for this request
    # @return [String,nil] Blob key of the image corresponding to the given
    #                      identifier, or nil if not found.
    #
    def self.get_blob_key(identifier, context)
    end

  end

  module HttpResolver

    ##
    # @param identifier [String] Image compound identifier from Islandora
    # @param context [Hash] Context for this request
    # @return [String,Hash<String,String>,nil] String URL of the image
    #         corresponding to the given identifier; or nil if not found.
    #
    def self.get_url(identifier, context)
      require 'cgi'
      values = CGI::unescape(identifier).split('~')
      if values.length != 3
        return nil
      end
      pid = values[0]
      dsid = values[1]
      token = values[2]
      return "http://apache/islandora/object/#{pid}/datastream/#{dsid}/view?token=#{token}"
    end

  end

  module JdbcResolver

    ##
    # @param identifier [String] Image identifier
    # @param context [Hash] Context for this request
    # @return [String] Identifier of the image corresponding to the given
    #                  identifier in the database.
    #
    def self.get_database_identifier(identifier, context)
    end

    ##
    # Returns either the media (MIME) type of an image, or an SQL statement
    # that can be used to retrieve it, if it is stored in the database. In the
    # latter case, the "SELECT" and "FROM" clauses should be in uppercase in
    # order to be autodetected. If nil is returned, the media type will be
    # inferred from the extension in the identifier (if present).
    #
    def self.get_media_type
    end

    ##
    # Returns an SQL statement that selects the BLOB corresponding to the
    # value returned by get_database_identifier().
    #
    def self.get_lookup_sql
    end

  end

  ##
  # Tells the server what overlay, if any, to apply to an image in response
  # to a particular request. Will be called upon all image requests to any
  # endpoint if `overlays.enabled` is set to `true` and `overlays.strategy`
  # is set to `ScriptStrategy` in the configuration file.
  #
  # N.B. When a string overlay is too large or long to fit entirely within the
  # image, it won't be drawn. Consider breaking long strings with LFs (\n).
  #
  # @param identifier [String] Image identifier
  # @param operations [Array<Hash<String,Object>>] Array of operations in
  #                   order of execution. Only operations that are not no-ops
  #                   will be included. Every hash contains a `class` key
  #                   corresponding to the operation class name, which will be
  #                   one of the e.i.l.c.operation.Operation implementations.
  # @param resulting_size [Hash<String,String>] Hash with `width` and `height`
  #                       keys corresponding to the pixel dimensions of the
  #                       resulting image after all operations are applied.
  # @param output_format [Hash<String,String>] Hash with `media_type` and
  #                                            `extension` keys.
  # @param request_uri [String] Full request URI
  # @param request_headers [Hash<String,String>]
  # @param client_ip [String]
  # @param cookies [Hash<String,String>]
  # @return [Hash<String,String>,Boolean] For image overlays, a hash with
  #         `image`, `position`, and `inset` keys.
  #         For string overlays, a hash with `background_color`,
  #         `color`, `font`, `font_min_size`, `font_size`, `font_weight`,
  #         `glyph_spacing`,`inset`, `position`, `string`, `stroke_color`, and
  #         `stroke_width` keys.
  #         Return false for no overlay.
  #
  def self.overlay(identifier, operations, resulting_size, output_format,
                   request_uri, request_headers, client_ip, cookies)
    false
  end

  ##
  # Tells the server what regions of an image to redact in response to a
  # particular request. Will be called upon all image requests to any
  # endpoint if `redaction.enabled` is set to `true` in the configuration
  # file.
  #
  # @param identifier [String] Image identifier
  # @param request_headers [Hash<String,String>]
  # @param client_ip [String]
  # @param cookies [Hash<String,String>]
  # @return [Array<Hash<String,Integer>>] Array of hashes, each with `x`, `y`,
  #         `width`, and `height` keys; or an empty array if no redactions are
  #         to be applied.
  #
  def self.redactions(identifier, request_headers, client_ip, cookies)
    []
  end

end

# Uncomment to test on the command line (`ruby delegates.rb`)
# puts Cantaloupe::FilesystemResolver::get_pathname('image.jpg')
