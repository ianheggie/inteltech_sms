
require 'net/http'

require 'inteltech_sms'

# Dummy Class for testing

class DummyInteltechSms < InteltechSms 


  attr_accessor :credit, :response_code, :log_to_stdout

  def initialize(credit, response_code = InteltechSms::SUCCESS_RESPONSE_CODE)
    super('dummy_user', 'a_secret')
    @credit = credit.to_i
    @response_code = response_code
    @last_sms = ''
    @log_to_stdout = true
  end

  def get_credit
    res = InteltechSms::FakeHTTPSuccess.new(@response_code == InteltechSms::SUCCESS_RESPONSE_CODE ? "credit,#{@credit}" : @response_code)
    process_get_credit_response(res)
  end

  def send_sms(sms, message, options = { })
    this_response_code = response_code_for_sms(sms)
    @credit -= 1 if this_response_code == InteltechSms::SUCCESS_RESPONSE_CODE
    puts "WOULD HAVE SENT SMS TO #{sms}: #{message} AND RETURNED STATUS: #{this_response_code}" if @log_to_stdout
    res = InteltechSms::FakeHTTPSuccess.new(this_response_code)
    process_send_sms_response(res, sms)
  end

  def send_multiple_sms(sms, message, options = { })
    this_response_code = response_code_for_sms(sms)
    sms_array = (sms.is_a?(Array) ? sms : sms.split(','))
    puts "WOULD HAVE SENT SMS TO #{sms_array.join(', ')}: #{message} AND RETURNED STATUS: #{this_response_code}" if @log_to_stdout
    @credit -= sms_array.size if this_response_code == InteltechSms::SUCCESS_RESPONSE_CODE

    ret = [ ]
    sms_array.each do |this_sms|
      ret << Response.factory(this_sms.strip, this_response_code)
    end
    ret
  end

  private

  def response_code_for_sms(sms)
    ret = @response_code
    if ret == InteltechSms::SUCCESS_RESPONSE_CODE
      if @credit <= 0 
        ret = InteltechSms::NO_CREDIT_RESPONSE_CODE
      else
        ret = @last_sms == sms ? InteltechSms::DUPLICATE_RESPONSE_CODE : @response_code
        @last_sms = sms
      end
    end
    ret
  end

end

# vi:ai sw=2:
