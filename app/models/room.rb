# coding: utf-8
class Room < ActiveRecord::Base
  belongs_to :user
end
