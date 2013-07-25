require 'helper'

class TestInteltechSms < Test::Unit::TestCase

  # ==================================================
  # Useful constants

  USERNAME_WITHOUT_CREDIT = 'nocredit'
  SECURE_KEY_WITHOUT_CREDIT = 'e7e62e1826d6f9ac1dcc208963b58b8cdad9aa12b53'

  BAD_SECURE_KEY = '00000000011111111122222222233333333334444444444445555555566666666'

  TEST_SMS = '0411111111'
  TEST_SMS2 = '+8611111111111'
  # http://www.acma.gov.au/Citizen/Consumer-info/All-about-numbers/Special-numbers/fictitious-numbers-for-radio-film-and-television-i-acma
  BAD_SMS = '0491570156'

  LANDLINE_SMS = '0862252608'  # InteltechSms's landline

  if ENV['SMS_USERNAME'].to_s.empty? or ENV['SMS_KEY'].to_s.empty?
    puts "Tests for non error conditions are disabled (missing SMS_USERNAME and SMS_KEY values for a valid account)"
  else
    @@username = ENV['SMS_USERNAME']
    puts "Tests for non error conditions have been enabled"
    @@secure_key = ENV['SMS_KEY']
    if ENV['MOBILE_NUMBER'].to_s.empty?
      puts "If MOBILE_NUMBER is supplied, then a test sms will be sent (using one credit)"
    else
      @@mobile_number = ENV['MOBILE_NUMBER']
    end
  end

  # ==================================================
  # Tests

  # Code 0000 Message added to queue OK.

  if defined? @@username

    context "with a good username and secure_key" do

      setup do
        @good_gateway = InteltechSms.new(@@username, @@secure_key)
      end

      should "get_credit should return non zero credit" do
        assert_operator @good_gateway.get_credit, :>, 0
      end

      should "send a single test sms via send_sms" do
        expected = InteltechSms::Success.new(TEST_SMS, "0000")
        assert_equal expected, @good_gateway.send_sms(TEST_SMS,'Test from Ruby - send a single test sms via send_sms')
      end

      should "reject an indentical message sent shortly after" do
        expected = InteltechSms::BadRequest.new(TEST_SMS, "2016")
        @good_gateway.send_sms(TEST_SMS,'Test from Ruby - send two copies of single test sms via send_sms')
        ex = assert_raises InteltechSms::Failure do
          @good_gateway.send_sms(TEST_SMS,'Test from Ruby - send two copies of single test sms via send_sms')
        end
        assert_equal InteltechSms::Failure.new('', "2006"), ex.response
      end

      if defined? @@mobile_number
        should "send a single real sms via send_sms" do
          expected = InteltechSms::Success.new(@@mobile_number, "0000")
          assert_equal expected, @good_gateway.send_sms(@@mobile_number,"Test sms from InteltechSms account #{@@username} - any replies will be emailed to account holder")
        end
      end

    end

    context "#send_multiple_sms" do
      should "return an array with a response for each sms sent" do
        @good_gateway = InteltechSms.new(@@username, @@secure_key)
        @res = @good_gateway.send_multiple_sms [TEST_SMS, TEST_SMS2],'Test from Ruby - return an array with a response for each sms sent'
        assert_kind_of Array, @res
        assert_equal 2, @res.length
        assert_equal InteltechSms::Success.new(TEST_SMS, "0000"), @res[0], "send_multiple_sms returns success for 1st element"
        assert_equal InteltechSms::Success.new(TEST_SMS2, "0000"), @res[1], "send_multiple_sms returns success for 2nd element"
      end 

      should "return an array with a response for each sms sent where a comma seperated string is provided" do
        @good_gateway = InteltechSms.new(@@username, @@secure_key)
        @res = @good_gateway.send_multiple_sms [TEST_SMS2, TEST_SMS].join(','),'Test from Ruby - return an array with a response for each sms sent where a comma seperated string is provided'
        assert_kind_of Array, @res
        assert_equal 2, @res.length
        assert_equal InteltechSms::Success.new(TEST_SMS2, "0000"), @res[0], "send_multiple_sms returns success for 1st element"
        assert_equal InteltechSms::Success.new(TEST_SMS, "0000"), @res[1], "send_multiple_sms returns success for 2nd element"
      end 
   end
  end

  # --------------------------------------------------
  # Code 2006 Not enough information has been supplied for authentication. Please ensure that your Username and Unique Key are supplied in your request.

  context "with blank username" do
    setup do
      @bad_gateway = InteltechSms.new('', SECURE_KEY_WITHOUT_CREDIT)
    end

    should "raise an Unauthorized Error exception when get_credit is called" do
      ex = assert_raises InteltechSms::Error do
        @bad_gateway.get_credit
      end
      assert_equal InteltechSms::Unauthorized.new('', "2006"), ex.response
    end

    should "raise an Unauthorized Error exception when send_sms is called" do
      ex = assert_raises InteltechSms::Error do
        @bad_gateway.send_sms TEST_SMS, 'Tests from ruby - with blank username raise an Unauthorized Error exception when send_sms is called'
      end
      assert_equal InteltechSms::Unauthorized.new(TEST_SMS, "2006"), ex.response
    end

    should "return an array Unauthorized responses when send_multiple_sms is called" do
      @res = @bad_gateway.send_multiple_sms [TEST_SMS, TEST_SMS2], 'Test from Ruby - with blank username return an array Unauthorized responses when send_multiple_sms is called'
      assert_kind_of Array, @res
      assert_equal 2, @res.length, "send_multiple_sms returns results for each sms sent"
      assert_kind_of InteltechSms::Unauthorized, @res[0], "send_multiple_sms returns Unauthorized for 1st element"
      assert_equal InteltechSms::Unauthorized.new(TEST_SMS, "2006"), @res[0]
      assert_kind_of InteltechSms::Unauthorized, @res[1], "send_multiple_sms returns Unauthorized for 2nd element"
      assert_equal InteltechSms::Unauthorized.new(TEST_SMS2, "2006"), @res[1]
    end

  end

  # --------------------------------------------------
  # Code 2015 The destination mobile number is invalid.

#  if defined? @@username
#    context "with a bad sms number" do
#      setup do
#        @good_gateway = InteltechSms.new(@@username, @@secure_key)
#      end
#
#      should "raise a BadRequest Error exception when send_sms is called" do
#        ex = assert_raises InteltechSms::Error do
#          @good_gateway.send_sms BAD_SMS, 'Test from ruby - bad sms number'
#        end
#        assert_equal InteltechSms::BadRequest.new(BAD_SMS, "2015"), ex.response
#      end
#
#      should "return an array with BadRequest responses when send_multiple_sms is called with some bad numbers" do
#        @res = @good_gateway.send_multiple_sms [BAD_SMS, TEST_SMS, LANDLINE_SMS], 'Test from Ruby - return an array with BadRequest responses when send_multiple_sms is called with some bad numbers'
#        assert_kind_of Array, @res
#        assert_equal 3, @res.length, "send_multiple_sms returns results for each sms sent"
#        assert_kind_of InteltechSms::BadRequest, @res[0], "send_multiple_sms returns BadRequest for 1st element"
#        assert_equal InteltechSms::BadRequest.new(BAD_SMS, "2015"), @res[0]
#        assert_kind_of InteltechSms::Success, @res[1], "send_multiple_sms returns Success for 2nd element"
#        assert_equal InteltechSms::Success.new(TEST_SMS, "0000"), @res[1]
#        assert_kind_of InteltechSms::BadRequest, @res[2], "send_multiple_sms returns BadRequest for 2nd element"
#        assert_equal InteltechSms::BadRequest.new(LANDLINE_SMS, "2015"), @res[2]
#      end
#
#    end
#  end

  # --------------------------------------------------
  # Code 2018 You have reached the end of your message credits. You will need to purchase more messages.

  context "With an account without credit" do
    setup do
      @nocredit_gateway = InteltechSms.new(USERNAME_WITHOUT_CREDIT, SECURE_KEY_WITHOUT_CREDIT)
    end

    should "have get_credit return zero credit" do
      assert_equal 0, @nocredit_gateway.get_credit
    end

    should "raise an NoCredit Error exception when send_sms is called" do
      ex = assert_raises InteltechSms::Error do
        @nocredit_gateway.send_sms TEST_SMS, 'Test from ruby - no credit on send_sms'
      end
      assert_equal InteltechSms::NoCredit.new(TEST_SMS, "2018"), ex.response
    end

    should "return an array NoCredit responses when send_multiple_sms is called" do
      @res = @nocredit_gateway.send_multiple_sms [TEST_SMS, TEST_SMS2], 'Test from Ruby - return an array NoCredit responses when send_multiple_sms is called'
      assert_kind_of Array, @res
      assert_equal 2, @res.length, "send_multiple_sms returns results for each sms sent"
      assert_kind_of InteltechSms::NoCredit, @res[0], "send_multiple_sms returns NoCredit for 1st element"
      assert_equal InteltechSms::NoCredit.new(TEST_SMS, "2018"), @res[0]
      assert_kind_of InteltechSms::NoCredit, @res[1], "send_multiple_sms returns NoCredit for 2nd element"
      assert_equal InteltechSms::NoCredit.new(TEST_SMS2, "2018"), @res[1]
    end

  end

  # --------------------------------------------------
  # Code 2022 Your Unique Key is incorrect. This may be caused by a recent password change.

  context "With an incorrect secure_key" do
    setup do
      @bad_gateway = InteltechSms.new(USERNAME_WITHOUT_CREDIT, BAD_SECURE_KEY)
    end

    should "raise an Unauthorized Error exception when get_credit is called" do
      ex = assert_raises InteltechSms::Error do
        @bad_gateway.get_credit
      end
      assert_equal InteltechSms::Unauthorized.new('', "2022"), ex.response
    end

    should "raise an Unauthorized Error exception when send_sms is called" do
      ex = assert_raises InteltechSms::Error do
        @bad_gateway.send_sms TEST_SMS, 'Test from ruby - incorrect secure key send_sms call'
      end
      assert_equal InteltechSms::Unauthorized.new(TEST_SMS, "2022"), ex.response
    end

    should "return an array Unauthorized responses when send_multiple_sms is called" do
      @res = @bad_gateway.send_multiple_sms [TEST_SMS, TEST_SMS2], 'Test from Ruby - with incorrect key return an array Unauthorized responses when send_multiple_sms is called'
      assert_kind_of Array, @res
      assert_equal 2, @res.length, "send_multiple_sms returns results for each sms sent"
      assert_kind_of InteltechSms::Unauthorized, @res[0], "send_multiple_sms returns Unauthorized for 1st element"
      assert_equal InteltechSms::Unauthorized.new(TEST_SMS, "2022"), @res[0]
      assert_kind_of InteltechSms::Unauthorized, @res[1], "send_multiple_sms returns Unauthorized for 2nd element"
      assert_equal InteltechSms::Unauthorized.new(TEST_SMS2, "2022"), @res[1]
    end

  end

  context "with blank secure_key" do
    setup do
      @bad_gateway = InteltechSms.new(USERNAME_WITHOUT_CREDIT, '')
    end

    should "raise an Unauthorized Error exception when get_credit is called" do
      ex = assert_raises InteltechSms::Error do
        @bad_gateway.get_credit
      end
      assert_equal InteltechSms::Unauthorized.new('', "2022"), ex.response
    end

    should "raise an Unauthorized Error exception when send_sms is called" do
      ex = assert_raises InteltechSms::Error do
        @bad_gateway.send_sms TEST_SMS, 'Test from ruby - blank secure key send_sms call'
      end
      assert_equal InteltechSms::Unauthorized.new(TEST_SMS, "2022"), ex.response
    end

    should "return an array Unauthorized responses when send_multiple_sms is called" do
      @res = @bad_gateway.send_multiple_sms [TEST_SMS, TEST_SMS2], 'Test from Ruby - with blank secure key return an array Unauthorized responses when send_multiple_sms is called'
      assert_kind_of Array, @res
      assert_equal 2, @res.length, "send_multiple_sms returns results for each sms sent"
      assert_kind_of InteltechSms::Unauthorized, @res[0], "send_multiple_sms returns Unauthorized for 1st element"
      assert_equal InteltechSms::Unauthorized.new(TEST_SMS, "2022"), @res[0]
      assert_kind_of InteltechSms::Unauthorized, @res[1], "send_multiple_sms returns Unauthorized for 2nd element"
      assert_equal InteltechSms::Unauthorized.new(TEST_SMS2, "2022"), @res[1]
    end
  end

  # --------------------------------------------------
  # Code 2051 Message is empty.

  if defined? @@username

    context "with an empty message" do

      setup do
        @good_gateway = InteltechSms.new(@@username, @@secure_key)
      end

    should "raise an BadRequest Error exception when send_sms is called" do
      ex = assert_raises InteltechSms::Error do
        @good_gateway.send_sms TEST_SMS, ''
      end
      assert_equal InteltechSms::BadRequest.new(TEST_SMS, "2051"), ex.response
    end

    should "return an array BadRequest responses when send_multiple_sms is called" do
      @res = @good_gateway.send_multiple_sms [TEST_SMS, TEST_SMS2, LANDLINE_SMS], ''
      assert_kind_of Array, @res
      assert_equal 3, @res.length, "send_multiple_sms returns results for each sms sent"
      assert_kind_of InteltechSms::BadRequest, @res[0], "send_multiple_sms returns BadRequest for 1st element"
      assert_equal InteltechSms::BadRequest.new(TEST_SMS, "2051"), @res[0]
      assert_kind_of InteltechSms::BadRequest, @res[1], "send_multiple_sms returns BadRequest for 2nd element"
      assert_equal InteltechSms::BadRequest.new(TEST_SMS2, "2051"), @res[1]
      assert_kind_of InteltechSms::BadRequest, @res[2], "send_multiple_sms returns BadRequest for 2nd element"
      assert_equal InteltechSms::BadRequest.new(LANDLINE_SMS, "2051"), @res[2]
    end

   end
  end


  # --------------------------------------------------
  # Code 2100-2199 Internal error

  # (Unable to trigger these errors to test them)

end

# vi: sw=2 sm ai:
