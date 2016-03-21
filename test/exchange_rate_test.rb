require 'test_helper'
require 'bigdecimal'

class ExchangeRateTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::ExchangeRate::VERSION
  end

  def make_mock_source(date, from_name, from_rate, to_name, to_rate)
    mock_source = MiniTest::Mock.new
    mock_source.expect :get, BigDecimal.new(from_rate), [date, from_name]
    mock_source.expect :get, BigDecimal.new(to_rate), [date, to_name]
    return mock_source
  end

  def test_that_it_calls_data_source_twice
    date = Date.today
    mock_source = make_mock_source date, 'GBP', 1, 'USD', 1

    calculator = ::ExchangeRate::Calculator.new mock_source
    calculator.at date, 'GBP', 'USD'

    mock_source.verify
  end

  def test_that_the_exchange_rate_is_calculated_correctly
    date = Date.today
    mock_source = make_mock_source date, 'GBP', '0.5', 'USD', '1.5'

    calculator = ::ExchangeRate::Calculator.new mock_source
    rate = calculator.at date, 'GBP', 'USD'

    assert_equal BigDecimal.new(3), rate

  end

  def test_that_at_throws_the_correct_error_when_data_souce_fails
    date = Date.today
    mock_source = MiniTest::Mock.new
    mock_source.expect(:get, BigDecimal.new(1))do
      raise Exception, "An Exception", caller
    end

    calculator = ::ExchangeRate::Calculator.new mock_source

    error = assert_raises(::ExchangeRate::DataSourceError) {
      calculator.at date, 'GBP', 'USD'
    }

    assert_equal error.message, "Error getting rate GBP: An Exception"
  end


  def test_it_ensures_the_data_source_returns_big_decimal_values
    date = Date.today
    mock_source = MiniTest::Mock.new
    mock_source.expect :get, 1, [date, 'GBP']
    calculator = ::ExchangeRate::Calculator.new mock_source

    error = assert_raises(::ExchangeRate::DataSourceError) {
      calculator.at date, 'GBP', 'USD'
    }

    assert_equal error.message, "get should return a BigDecimal"
  end
end
