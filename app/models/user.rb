# coding: utf-8
class User < ActiveRecord::Base
  
  has_many :rooms
  has_many :tweets

  #----------#
  # get_name #
  #----------#
  def get_name
    if !self.screen_name.blank?
      return self.screen_name
    elsif !self.name.blank?
      return self.name
    else
      return self.id
    end
  end

  private

  #---------------------------#
  # self.create_with_omniauth #
  #---------------------------#
  def self.create_with_omniauth( auth )
    user = User.new
    user[:provider] = auth["provider"]
    user[:uid] = auth["uid"]
    
    unless auth["info"].blank?
      user[:name] = auth["info"]["name"]
      user[:screen_name] = auth["info"]["nickname"]
      user[:image] = auth["info"]["image"]
    end
    
    user.save
    
    return user
  end

=begin
  #----------------#
  # self.get_image #
  #----------------#
  def self.get_image( user_id )
    user = User.where( id: user_id ).select( "image" ).first
    user.image
  end
  
  #--------------#
  # self.get_uid #
  #--------------#
  def self.get_uid( user_id )
    user = User.where( id: user_id ).select( "uid" ).first
    user.uid
  end
=end

end
