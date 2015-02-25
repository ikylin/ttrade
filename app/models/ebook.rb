class Ebook < ActiveRecord::Base
  has_many  :everydaytips
  
  has_attached_file :frontcover, 
      :styles => { :poster => "960x1290", :large => "576x774", :medium => "480x645", :small => "96x129", :thumb => "160x215", :weixin => "258x258" }

      validates_attachment :frontcover,
      :content_type => { :content_type => /\Aimage\/.*\Z/ } ,
      :size => { :in => 0..10000.kilobytes }


	resourcify
end
