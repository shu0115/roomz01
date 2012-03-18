# coding: utf-8
class RoomsController < ApplicationController
  
  #-------#
  # index #
  #-------#
  def index
    @rooms = Room.order( "created_at DESC" ).includes( :user ).all
    @room = Room.new
  end
  
=begin
  #------#
  # show #
  #------#
  def show
    @room = Room.where( id: params[:id] ).first
    @tweets = Tweet.where( room_id: params[:id] ).order( "created_at DESC" ).includes( :user )
    
    # アイコン配列生成用
    @tweet_hash = Hash.new{ |hash, key| hash[key] = Hash.new }
    @tweets.each{ |tweet|
      @tweet_hash[tweet.user_id][:screen_name] = tweet.user.try(:screen_name)
      @tweet_hash[tweet.user_id][:image] = tweet.user.try(:image)
    }
    
    @tweet = Tweet.new
  end
=end

=begin
  #-----#
  # new #
  #-----#
  def new
    @room = Room.new
  end
=end

  #------#
  # edit #
  #------#
  def edit
    @room = Room.where( user_id: session[:user_id], id: params[:id] ).first
  end

  #--------#
  # create #
  #--------#
  def create
    @room = Room.new( params[:room] )
    @room.user_id = session[:user_id]

    if @room.save
      redirect_to( { action: "index" } ) and return
    else
      redirect_to( { action: "index" }, alert: 'Roomの作成に失敗しました。') and return
    end
  end

  #--------#
  # update #
  #--------#
  def update
    update_room = params[:room]
    update_room[:twitter_synchro] = false unless update_room[:twitter_synchro] == "true"
    
    room = Room.where( id: params[:id], user_id: session[:user_id] ).first

    unless room.update_attributes( update_room )
      redirect_to( { action: "edit", id: room.id }, alert: 'Roomの作成に失敗しました。' ) and return
    else
      redirect_to( { action: "index" } ) and return
    end
  end

  #--------#
  # delete #
  #--------#
  def delete
    @room = Room.where( id: params[:id], user_id: session[:user_id] ).first
    @room.destroy

    redirect_to( action: "index" ) and return
  end

=begin
  #-------#
  # throw #
  #-------#
  # Do Tweet
  def throw
    tweet = Tweet.new( params[:tweet] )
    tweet.room_id = params[:room_id]
    tweet.user_id = session[:user_id]

    if tweet.save
      flash[:notice] = 'ポストが完了しました。'
    
      # Twitterポスト
      Twitter.configure do |config|
        config.consumer_key       = ENV['TWITTER_KEY']
        config.consumer_secret    = ENV['TWITTER_SECRET']
        config.oauth_token        = current_user.token
        config.oauth_token_secret = current_user.secret
      end

      room = Room.where( id: tweet.room_id ).first
      twitter_post = "#{tweet.post} #{room.try(:hash_tag)}"
      
      twitter_client = Twitter::Client.new
      twitter_client.update( twitter_post )
    else
      flash[:alert] = 'ポストが失敗しました。'
    end
    
    redirect_to( action: "show", id: params[:room_id] ) and return
  rescue => ex
    print "[ ex ] : " ; p ex ;
    print "[ ex.message ] : " ; p ex.message ;
    flash[:alert] = ex.message
    redirect_to( action: "show", id: params[:room_id] ) and return
  end

  #---------#
  # retract #
  #---------#
  # Delete Tweet
  def retract
    @tweet = Tweet.where( id: params[:id], user_id: session[:user_id] ).first
    @tweet.destroy

    redirect_to( action: "show", id: params[:room_id] ) and return
  end
=end

end
