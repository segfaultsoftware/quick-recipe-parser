require "ipaddr"
require "uri"

class RecipeReferenceUrlPolicy
  class InvalidUrlError < StandardError
    attr_reader :reason

    def initialize(reason, message)
      @reason = reason
      super(message)
    end
  end

  SCHEMES = %w[http https].freeze
  HOSTNAME_PATTERN = /\A(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\z/i
  SCHEME_AND_AUTHORITY_PATTERN = /\A[a-z][a-z0-9+.-]*:\/\/([^\/?#]*)/i

  class << self
    def normalize(value)
      new.normalize(value)
    end

    def call(value)
      normalize(value)
    end

    def valid?(value)
      normalize(value)
      true
    rescue InvalidUrlError
      false
    end
  end

  def normalize(value)
    return if value.nil?
    invalid(:malformed, "Reference URL must be a string") unless value.is_a?(String)

    value = value.strip
    return if value.empty?

    scheme_and_authority = SCHEME_AND_AUTHORITY_PATTERN.match(value)
    authority = scheme_and_authority && scheme_and_authority[1]
    invalid(:host, "Reference URL host must use ASCII characters") if authority && !authority.ascii_only?
    invalid(:userinfo, "Reference URL must not include userinfo") if authority&.include?("@")
    invalid(:port, "Reference URL must not include an explicit port") if explicit_port?(authority) && !authority.start_with?("[")

    uri = URI.parse(value)
    scheme = uri.scheme&.downcase
    invalid(:scheme, "Reference URL scheme must be http or https") unless SCHEMES.include?(scheme)
    invalid(:host, "Reference URL must include a host") if uri.host.nil? || uri.host.empty?
    invalid(:userinfo, "Reference URL must not include userinfo") if uri.userinfo
    validate_host!(uri.host)
    invalid(:port, "Reference URL must not include an explicit port") if explicit_port?(authority)

    uri.scheme = scheme
    uri.host = uri.host.downcase
    uri.query = nil
    uri.fragment = nil
    uri.to_s
  rescue URI::InvalidURIError, ArgumentError
    invalid(:malformed, "Reference URL is malformed")
  end

  private

  def validate_host!(host)
    invalid(:host, "Reference URL host must be a normal ASCII hostname") unless host.ascii_only? && host.length <= 253 && HOSTNAME_PATTERN.match?(host)
    invalid(:host, "Reference URL host must not be an IP address") if ip_address?(host)
    invalid(:host, "Reference URL host must not use punycode") if host.split(".").any? { |label| label.downcase.start_with?("xn--") }
  end

  def ip_address?(host)
    IPAddr.new(host)
    true
  rescue IPAddr::InvalidAddressError
    host.match?(/\A\d+(?:\.\d+){3}\z/)
  end

  def explicit_port?(authority)
    return false unless authority

    authority_without_userinfo = authority.split("@", 2).last || ""
    authority_without_userinfo.include?(":")
  end

  def invalid(reason, message)
    raise InvalidUrlError.new(reason, message)
  end
end
