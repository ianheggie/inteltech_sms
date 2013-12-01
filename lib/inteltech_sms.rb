require 'net/http'
require "rexml/document"

class InteltechSms

  SUCCESS_RESPONSE_CODE = '0000'
  UNAUTHORIZED_RESPONSE_CODE = '2006'
  ACCOUNT_NOT_ACTIVATED_RESPONSE_CODE = '2007'
  INVALID_NUMBER_RESPONSE_CODE = '2015'
  DUPLICATE_RESPONSE_CODE = '2016'
  NO_CREDIT_RESPONSE_CODE = '2018'
  UNAUTHORIZED_KEY_RESPONSE_CODE = '2022'
  EMPTY_MESSAGE_RESPONSE_CODE = '2051'
  TOO_MANY_RECIPIENTS_RESPONSE_CODE = '2052'

  # General failures
  INVALID_SENDER_RESPONSE_CODE = '2017'

  class FakeHTTPSuccess
    attr_accessor :body

    def initialize(body)
      @body = body
    end
  end


  class Error < StandardError
    attr_reader :response
    def initialize(response)
      @response = response
      super(response.to_s)
    end
  end

  class Response
    attr_reader :sms
    attr_reader :response_code

    def initialize(sms, response_code = '')
      @sms = sms.strip
      @response_code = response_code.strip
    end

    def self.factory(sms, response_code)
      case response_code.strip
      when SUCCESS_RESPONSE_CODE
        Success.new(sms, response_code)
      when UNAUTHORIZED_RESPONSE_CODE
        Unauthorized.new(sms, response_code)
      when INVALID_NUMBER_RESPONSE_CODE
        BadRequest.new(sms, response_code)
      when DUPLICATE_RESPONSE_CODE
        Duplicate.new(sms, response_code)
      when NO_CREDIT_RESPONSE_CODE
        NoCredit.new(sms, response_code)
      when UNAUTHORIZED_KEY_RESPONSE_CODE
        Unauthorized.new(sms, response_code)
      when EMPTY_MESSAGE_RESPONSE_CODE
        BadRequest.new(sms, response_code)
      when TOO_MANY_RECIPIENTS_RESPONSE_CODE
        BadRequest.new(sms, response_code)
      when ACCOUNT_NOT_ACTIVATED_RESPONSE_CODE
        Unauthorized.new(sms, response_code)
      else 
        Failure.new(sms, response_code)
      end
    end

    def ==(another)
      self.sms == another.sms and self.response_code == another.response_code
    end

    def to_s
      "#{self.class.name} sms: #{@sms}, response_code: #{@response_code}"
    end

  end

  class Success < Response
    def success?
      true
    end
  end

  class Failure < Response
    def success?
      false
    end
  end

  class BadRequest < Failure
  end

  class Unauthorized < Failure
  end

  class NoCredit < Failure
  end

  class Duplicate < Failure
  end

  # class InteltechSms


  def initialize(username, secret_key)
    @username = username
    @secret_key = secret_key
  end

  def get_credit
    uri = URI('http://inteltech.com.au/secure-api/credit.php')
    res = Net::HTTP.post_form(uri, 'username' => @username, 'key' => @secret_key, 'method' => 'ruby')
    process_get_credit_response(res)
  end

  def send_sms(sms, message, options = { })
    uri = URI('http://inteltech.com.au/secure-api/send.single.php')
    args = { :username => @username, :key => @secret_key, :sms => sms, :message => message, :method => 'ruby' }.merge(options)
    res = Net::HTTP.post_form(uri, args)
    process_send_sms_response(res, sms)
  end

  def send_multiple_sms(sms, message, options = { })
    uri = URI('http://inteltech.com.au/secure-api/send.php')
    sms_string = sms.respond_to?(:join) ? sms.join(',') : sms.to_s
    args = { :username => @username, :key => @secret_key, :sms => sms_string, :message => message, :method => 'ruby' }.merge(options)
    res = Net::HTTP.post_form(uri, args)
    process_send_multiple_sms_response(res)
  end

  protected

  def process_get_credit_response(res)
    case res
    when Net::HTTPSuccess, Net::HTTPRedirection, InteltechSms::FakeHTTPSuccess
      if res.body =~ /credit,(\d*)/
        $1.to_i 
      elsif res.body =~ /\d\d\d\d/
        raise InteltechSms::Error.new(Response.factory('', res.body))
      else
        raise StandardError.new("Response not formatted as expected: #{res.body}")
      end
    else
      res.error!
    end
  end

  def process_send_sms_response(res, sms)
    case res
    when Net::HTTPSuccess, Net::HTTPRedirection, InteltechSms::FakeHTTPSuccess
      r= Response.factory(sms, res.body)
      raise InteltechSms::Error.new(r) unless r.success?
      r
    else
      res.error!
    end
  end

  def process_send_multiple_sms_response(res)
    case res
    when Net::HTTPSuccess, Net::HTTPRedirection
      doc = REXML::Document.new res.body
      ret = [ ]
      doc.elements.each("xml/message") do |element| 
        sms = element.elements['sms'].text.strip
        response_code = element.elements['result'].text.strip
        ret << Response.factory(sms, response_code)
      end
      ret
    else
      res.error!
    end
  end

end

# vi:ai sw=2:
