# coding: utf-8
class Tweet < ActiveRecord::Base
  belongs_to :user
  belongs_to :room
end
