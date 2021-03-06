class Imgdepot < ActiveRecord::Base
  has_attached_file :imgfile, 
      :styles => { :poster => "1280x1280", :large => "900x600", :medium => "430x430", :small => "344x344", :thumb => "258x258" }

      validates_attachment :imgfile,
      :content_type => { :content_type => /\Aimage\/.*\Z/ } ,
      :size => { :in => 0..1000.kilobytes }

	resourcify
end
