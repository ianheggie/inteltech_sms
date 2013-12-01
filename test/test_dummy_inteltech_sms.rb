require 'helper'
require 'net/http'

class TestDummyInteltechSms < Test::Unit::TestCase

  # ==================================================
  # Useful constants

  TEST_SMS = '0411111111'

  # ==================================================
  # Tests

  # Code 0000 Message added to queue OK.

  context "with credit" do

    setup do
      @good_gateway = DummyInteltechSms.new(123)
    end

    should "get_credit should return non zero credit" do
      assert_operator @good_gateway.get_credit, :>, 0
    end

    should "send a single test sms via send_sms" do
      expected = InteltechSms::Success.new(TEST_SMS, InteltechSms::SUCCESS_RESPONSE_CODE)
      assert_equal expected, @good_gateway.send_sms(TEST_SMS,'Test from Ruby - send a single test sms via send_sms')
    end
  end

# Not yet programmed
#  context "#send_multiple_sms" do
#    should "return an array with a response for each sms sent" do
#      @good_gateway = DummyInteltechSms.new(@@username, @@secure_key)
#      @res = @good_gateway.send_multiple_sms [TEST_SMS, TEST_SMS2],'Test from Ruby - return an array with a response for each sms sent'
#      assert_kind_of Array, @res
#      assert_equal 2, @res.length
#      assert_equal InteltechSms::Success.new(TEST_SMS, InteltechSms::SUCCESS_RESPONSE_CODE), @res[0], "send_multiple_sms returns success for 1st element"
#      assert_equal InteltechSms::Success.new(TEST_SMS2, InteltechSms::SUCCESS_RESPONSE_CODE), @res[1], "send_multiple_sms returns success for 2nd element"
#    end 
#
#    should "return an array with a response for each sms sent where a comma seperated string is provided" do
#      @good_gateway = InteltechSms.new(@@username, @@secure_key)
#      @res = @good_gateway.send_multiple_sms [TEST_SMS2, TEST_SMS].join(','),'Test from Ruby - return an array with a response for each sms sent where a comma seperated string is provided'
#      assert_kind_of Array, @res
#      assert_equal 2, @res.length
#      assert_equal InteltechSms::Success.new(TEST_SMS2, InteltechSms::SUCCESS_RESPONSE_CODE), @res[0], "send_multiple_sms returns success for 1st element"
#      assert_equal InteltechSms::Success.new(TEST_SMS, InteltechSms::SUCCESS_RESPONSE_CODE), @res[1], "send_multiple_sms returns success for 2nd element"
#    end 
#  end

  # --------------------------------------------------
  # Code 2006 Not enough information has been supplied for authentication. Please ensure that your Username and Unique Key are supplied in your request.

  context "with blank username" do
    setup do
      @bad_gateway = DummyInteltechSms.new(0, InteltechSms::UNAUTHORIZED_RESPONSE_CODE)
    end

    should "raise an Unauthorized Error exception when get_credit is called" do
      ex = assert_raises InteltechSms::Error do
        @bad_gateway.get_credit
      end
      assert_equal InteltechSms::Unauthorized.new('', InteltechSms::UNAUTHORIZED_RESPONSE_CODE), ex.response
    end

    should "raise an Unauthorized Error exception when send_sms is called" do
      ex = assert_raises InteltechSms::Error do
        @bad_gateway.send_sms TEST_SMS, 'Tests from ruby - with blank username raise an Unauthorized Error exception when send_sms is called'
      end
      assert_equal InteltechSms::Unauthorized.new(TEST_SMS, InteltechSms::UNAUTHORIZED_RESPONSE_CODE), ex.response
    end

# Not yet programmed
#    should "return an array Unauthorized responses when send_multiple_sms is called" do
#      @res = @bad_gateway.send_multiple_sms [TEST_SMS, TEST_SMS2], 'Test from Ruby - with blank username return an array Unauthorized responses when send_multiple_sms is called'
#      assert_kind_of Array, @res
#      assert_equal 2, @res.length, "send_multiple_sms returns results for each sms sent"
#      assert_kind_of InteltechSms::Unauthorized, @res[0], "send_multiple_sms returns Unauthorized for 1st element"
#      assert_equal InteltechSms::Unauthorized.new(TEST_SMS, InteltechSms::UNAUTHORIZED_RESPONSE_CODE), @res[0]
#      assert_kind_of InteltechSms::Unauthorized, @res[1], "send_multiple_sms returns Unauthorized for 2nd element"
#      assert_equal InteltechSms::Unauthorized.new(TEST_SMS2, InteltechSms::UNAUTHORIZED_RESPONSE_CODE), @res[1]
#    end

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
#        assert_equal InteltechSms::BadRequest.new(BAD_SMS, InteltechSms::INVALID_NUMBER_RESPONSE_CODE), ex.response
#      end
#
#      should "return an array with BadRequest responses when send_multiple_sms is called with some bad numbers" do
#        @res = @good_gateway.send_multiple_sms [BAD_SMS, TEST_SMS, LANDLINE_SMS], 'Test from Ruby - return an array with BadRequest responses when send_multiple_sms is called with some bad numbers'
#        assert_kind_of Array, @res
#        assert_equal 3, @res.length, "send_multiple_sms returns results for each sms sent"
#        assert_kind_of InteltechSms::BadRequest, @res[0], "send_multiple_sms returns BadRequest for 1st element"
#        assert_equal InteltechSms::BadRequest.new(BAD_SMS, InteltechSms::INVALID_NUMBER_RESPONSE_CODE), @res[0]
#        assert_kind_of InteltechSms::Success, @res[1], "send_multiple_sms returns Success for 2nd element"
#        assert_equal InteltechSms::Success.new(TEST_SMS, InteltechSms::SUCCESS_RESPONSE_CODE), @res[1]
#        assert_kind_of InteltechSms::BadRequest, @res[2], "send_multiple_sms returns BadRequest for 2nd element"
#        assert_equal InteltechSms::BadRequest.new(LANDLINE_SMS, InteltechSms::INVALID_NUMBER_RESPONSE_CODE), @res[2]
#      end
#
#    end
#  end

  # --------------------------------------------------
  # Code 2016  Identical message sent to this recipient. Please try again in a few seconds.

  context "with a good username and secure_key" do

    setup do
      @good_gateway = DummyInteltechSms.new(123)
    end

    should "reject the second of a pair of indentical messages" do
      expected = InteltechSms::BadRequest.new(TEST_SMS, InteltechSms::DUPLICATE_RESPONSE_CODE)
      @good_gateway.send_sms(TEST_SMS,'Test from Ruby - send two copies of single test sms via send_sms')

      @good_gateway.response_code = InteltechSms::DUPLICATE_RESPONSE_CODE

      ex = assert_raises InteltechSms::Error do
        @good_gateway.send_sms(TEST_SMS,'Test from Ruby - send two copies of single test sms via send_sms')
      end
      assert_equal InteltechSms::Duplicate.new(TEST_SMS, InteltechSms::DUPLICATE_RESPONSE_CODE), ex.response
    end

  end

  # --------------------------------------------------
  # Code 2018 You have reached the end of your message credits. You will need to purchase more messages.

  context "With an account without credit" do
    setup do
      @nocredit_gateway = DummyInteltechSms.new(0)
    end

    should "have get_credit return zero credit" do
      assert_equal 0, @nocredit_gateway.get_credit
    end

    should "raise an NoCredit Error exception when send_sms is called" do
      @nocredit_gateway.response_code = InteltechSms::NO_CREDIT_RESPONSE_CODE
      ex = assert_raises InteltechSms::Error do
        @nocredit_gateway.send_sms TEST_SMS, 'Test from ruby - no credit on send_sms'
      end
      assert_equal InteltechSms::NoCredit.new(TEST_SMS, InteltechSms::NO_CREDIT_RESPONSE_CODE), ex.response
    end

# Not yet programmed
#    should "return an array NoCredit responses when send_multiple_sms is called" do
#      @res = @nocredit_gateway.send_multiple_sms [TEST_SMS, TEST_SMS2], 'Test from Ruby - return an array NoCredit responses when send_multiple_sms is called'
#      assert_kind_of Array, @res
#      assert_equal 2, @res.length, "send_multiple_sms returns results for each sms sent"
#      assert_kind_of InteltechSms::NoCredit, @res[0], "send_multiple_sms returns NoCredit for 1st element"
#      assert_equal InteltechSms::NoCredit.new(TEST_SMS, InteltechSms::NO_CREDIT_RESPONSE_CODE), @res[0]
#      assert_kind_of InteltechSms::NoCredit, @res[1], "send_multiple_sms returns NoCredit for 2nd element"
#      assert_equal InteltechSms::NoCredit.new(TEST_SMS2, InteltechSms::NO_CREDIT_RESPONSE_CODE), @res[1]
#    end

  end

  # --------------------------------------------------
  # Code 2022 Your Unique Key is incorrect. This may be caused by a recent password change.

  context "With an incorrect secure_key" do
    setup do
      @bad_gateway = DummyInteltechSms.new(0, InteltechSms::UNAUTHORIZED_KEY_RESPONSE_CODE)
    end

    should "raise an Unauthorized Error exception when get_credit is called" do
      ex = assert_raises InteltechSms::Error do
        @bad_gateway.get_credit
      end
      assert_equal InteltechSms::Unauthorized.new('', InteltechSms::UNAUTHORIZED_KEY_RESPONSE_CODE), ex.response
    end

    should "raise an Unauthorized Error exception when send_sms is called" do
      ex = assert_raises InteltechSms::Error do
        @bad_gateway.send_sms TEST_SMS, 'Test from ruby - incorrect secure key send_sms call'
      end
      assert_equal InteltechSms::Unauthorized.new(TEST_SMS, InteltechSms::UNAUTHORIZED_KEY_RESPONSE_CODE), ex.response
    end

# Not yet programmed
#    should "return an array Unauthorized responses when send_multiple_sms is called" do
#      @res = @bad_gateway.send_multiple_sms [TEST_SMS, TEST_SMS2], 'Test from Ruby - with incorrect key return an array Unauthorized responses when send_multiple_sms is called'
#      assert_kind_of Array, @res
#      assert_equal 2, @res.length, "send_multiple_sms returns results for each sms sent"
#      assert_kind_of InteltechSms::Unauthorized, @res[0], "send_multiple_sms returns Unauthorized for 1st element"
#      assert_equal InteltechSms::Unauthorized.new(TEST_SMS, InteltechSms::UNAUTHORIZED_KEY_RESPONSE_CODE), @res[0]
#      assert_kind_of InteltechSms::Unauthorized, @res[1], "send_multiple_sms returns Unauthorized for 2nd element"
#      assert_equal InteltechSms::Unauthorized.new(TEST_SMS2, InteltechSms::UNAUTHORIZED_KEY_RESPONSE_CODE), @res[1]
#    end

  end

  context "with blank secure_key" do
    setup do
      @bad_gateway = DummyInteltechSms.new(0, InteltechSms::UNAUTHORIZED_KEY_RESPONSE_CODE)
    end

    should "raise an Unauthorized Error exception when get_credit is called" do
      ex = assert_raises InteltechSms::Error do
        @bad_gateway.get_credit
      end
      assert_equal InteltechSms::Unauthorized.new('', InteltechSms::UNAUTHORIZED_KEY_RESPONSE_CODE), ex.response
    end

    should "raise an Unauthorized Error exception when send_sms is called" do
      ex = assert_raises InteltechSms::Error do
        @bad_gateway.send_sms TEST_SMS, 'Test from ruby - blank secure key send_sms call'
      end
      assert_equal InteltechSms::Unauthorized.new(TEST_SMS, InteltechSms::UNAUTHORIZED_KEY_RESPONSE_CODE), ex.response
    end

# Not yet programmed
#    should "return an array Unauthorized responses when send_multiple_sms is called" do
#      @res = @bad_gateway.send_multiple_sms [TEST_SMS, TEST_SMS2], 'Test from Ruby - with blank secure key return an array Unauthorized responses when send_multiple_sms is called'
#      assert_kind_of Array, @res
#      assert_equal 2, @res.length, "send_multiple_sms returns results for each sms sent"
#      assert_kind_of InteltechSms::Unauthorized, @res[0], "send_multiple_sms returns Unauthorized for 1st element"
#      assert_equal InteltechSms::Unauthorized.new(TEST_SMS, InteltechSms::UNAUTHORIZED_KEY_RESPONSE_CODE), @res[0]
#      assert_kind_of InteltechSms::Unauthorized, @res[1], "send_multiple_sms returns Unauthorized for 2nd element"
#      assert_equal InteltechSms::Unauthorized.new(TEST_SMS2, InteltechSms::UNAUTHORIZED_KEY_RESPONSE_CODE), @res[1]
#    end

  end

  # --------------------------------------------------
  # Code 2051 Message is empty.

  context "with an empty message" do

    setup do
      @good_gateway = DummyInteltechSms.new(0, InteltechSms::EMPTY_MESSAGE_RESPONSE_CODE)
    end

  should "raise an BadRequest Error exception when send_sms is called" do
    ex = assert_raises InteltechSms::Error do
      @good_gateway.send_sms TEST_SMS, ''
    end
    assert_equal InteltechSms::BadRequest.new(TEST_SMS, InteltechSms::EMPTY_MESSAGE_RESPONSE_CODE), ex.response
  end

# Not yet programmed
#    should "return an array BadRequest responses when send_multiple_sms is called" do
#      @res = @good_gateway.send_multiple_sms [TEST_SMS, TEST_SMS2, LANDLINE_SMS], ''
#      assert_kind_of Array, @res
#      assert_equal 3, @res.length, "send_multiple_sms returns results for each sms sent"
#      assert_kind_of InteltechSms::BadRequest, @res[0], "send_multiple_sms returns BadRequest for 1st element"
#      assert_equal InteltechSms::BadRequest.new(TEST_SMS, InteltechSms::EMPTY_MESSAGE_RESPONSE_CODE), @res[0]
#      assert_kind_of InteltechSms::BadRequest, @res[1], "send_multiple_sms returns BadRequest for 2nd element"
#      assert_equal InteltechSms::BadRequest.new(TEST_SMS2, InteltechSms::EMPTY_MESSAGE_RESPONSE_CODE), @res[1]
#      assert_kind_of InteltechSms::BadRequest, @res[2], "send_multiple_sms returns BadRequest for 2nd element"
#      assert_equal InteltechSms::BadRequest.new(LANDLINE_SMS, InteltechSms::EMPTY_MESSAGE_RESPONSE_CODE), @res[2]
#    end

  end


  # --------------------------------------------------
  # Code 2100-2199 Internal error

  # (Unable to trigger these errors to test them)

end

# vi: sw=2 sm ai:

