require 'csv'

module Csvable
  extend ActiveSupport::Concern

  module ClassMethods
    def to_csv
      CSV.generate(headers: true) do |csv|
        csv << csv_attributes

        csv_collection.each do |user|
          csv << csv_attributes.map do |attr|
            attr.split(".").reduce(user) do |attr_val, attr_method|
              attr_val.send(attr_method)
            end
          end
        end
      end
    end

    def csv_attributes
      raise NotImplementedError, "self.csv_attributes must be implemented"
    end

    def csv_collection
      raise NotImplementedError, "self.csv_collection must be implemented"
    end
  end
end
