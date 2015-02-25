class Indexfilter < ActiveRecord::Base
  has_many :reserves
  
  resourcify
end
