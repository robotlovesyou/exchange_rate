module ExchangeRate
  # Exception thrown when there is a problem calling the data_source *get* method
  # or when the data returned from the get method is of the wrong type
  class DataSourceError < Exception
  end
end
