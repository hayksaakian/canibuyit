class Product
  include Mongoid::Document
  field :name, :type => String
  field :available, :type => Boolean
  field :url, :type => String
end
