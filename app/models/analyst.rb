class Analyst < ActiveRecord::Base
	has_many	:reserves
	#has_many	:follows
	#has_many	:accounts, through: :follows
	has_many	:accounts
  belongs_to :user

	resourcify
end
