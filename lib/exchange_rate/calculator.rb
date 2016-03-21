require 'bigdecimal'

module ExchangeRate
  #Calculates the exchange rate between two currencies
  class Calculator

    # data_source should be an instance of a class with a function *get* which when
    # called with a Date and a currency string returns the exchange rate for that
    # currency with the base currency
    def initialize(data_source)
      @data_source = data_source
    end

    # given a date and two currency strings returns the exchange rate between those two
    # currencies on the day given
    def at(date, from, to)
      from_rate = rate_for(date, from)
      to_rate = rate_for(date, to)
      to_rate / from_rate
    end

    private

      def rate_for(date, name)
        begin
          rate = @data_source.get(date, name)
        rescue Exception => error
          raise DataSourceError, "Error getting rate #{name}: #{error.message}"
        end

        check_rate_type rate
        return rate
      end

      def check_rate_type(from_rate)
        unless from_rate.is_a? BigDecimal
          raise DataSourceError, "get should return a BigDecimal", caller
        end
      end

  end
end
