# coding: utf-8
class Room < ActiveRecord::Base
  belongs_to :user
  has_many :tweets, dependent: :delete_all
end
