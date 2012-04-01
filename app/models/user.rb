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

  #-----------#
  # is_super? #
  #-----------#
  # スーパーユーザ判定
  def is_super?
    if self.uid == SUPER_UID
      return true
    else
      return false
    end
  end
  
  private

  #---------------------------#
  # self.create_with_omniauth #
  #---------------------------#
  def self.create_with_omniauth( auth )
    user = User.new
    user.provider = auth["provider"]
    user.uid = auth["uid"]
    
    unless auth["info"].blank?
      user.name = auth["info"]["name"]
      user.screen_name = auth["info"]["nickname"]
      user.image = auth["info"]["image"]
    end

    unless auth["credentials"].blank?
      user.token = auth['credentials']['token']
      user.secret = auth['credentials']['secret']
    end

    user.save
    
    return user
  end

  #---------------------#
  # self.get_super_user #
  #---------------------#
  def self.get_super_user
    User.where( uid: SUPER_UID ).first
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
