# coding: utf-8
class TweetsController < ApplicationController
  
  #-------#
  # index #
  #-------#
  def index
    @room = Room.where( id: params[:room_id] ).first
    @tweets = Tweet.where( room_id: params[:room_id] ).order( "created_at DESC" ).includes( :user ).page( params[:page] ).per( PER_PAGE )
    
    @tweet = Tweet.new
    @str_count = @room.hash_tag.length + 1

    # TwitterのツイートをRoomzへ登録
    if @room.worker_flag == true
      Tweet.absorb_tweets( @room )
    end
    
    # アイコン配列生成用
    @icon_hash = Tweet.get_user_icons( @room )

    # ページタイトル
    @title = @room.hash_tag
  end

  #--------#
  # create #
  #--------#
  def create
    position_flag = params[:position_flag]
    room_id = params[:room_id]
    
    tweet = Tweet.new( params[:tweet] )
    tweet_text = ""
    
    room = Room.where( id: room_id ).first
    
    # ハッシュタグ付加
    if position_flag == "before"
      # 前付け
      tweet_text = "#{room.try(:hash_tag)} #{tweet.post}"
    elsif position_flag == "after"
      # 後付け
      tweet_text = "#{tweet.post} #{room.try(:hash_tag)}"
    else
      if room.hash_tag_position == "before"
        # 前付け
        tweet_text = "#{room.try(:hash_tag)} #{tweet.post}"
      elsif room.hash_tag_position == "after"
        # 後付け
        tweet_text = "#{tweet.post} #{room.try(:hash_tag)}"
      end
    end
    
    ActiveRecord::Base.transaction do
      # Twitterポスト
      if room.twitter_synchro == true
        # Twitter接続設定
        Twitter.configure do |config|
          config.consumer_key       = ENV['TWITTER_KEY']
          config.consumer_secret    = ENV['TWITTER_SECRET']
          config.oauth_token        = current_user.token
          config.oauth_token_secret = current_user.secret
        end

        # Twitterクライアント生成
        twitter_client = Twitter::Client.new
        
        # 投稿ポスト
        twitter_client.update( tweet_text )
      end
    end
    
    redirect_to( action: "index", room_id: room_id ) and return
  rescue => ex
    flash[:notice] = ""
    flash[:alert] = ex.message
    
    @room = Room.where( id: params[:room_id] ).first
    @tweets = Tweet.where( room_id: params[:room_id] ).order( "created_at DESC" ).includes( :user )
    
    # アイコン配列生成用
    @icon_hash = Tweet.get_user_icons( @room )
    
    @tweet = Tweet.new( params[:tweet] )
    @str_count = @room.hash_tag.length + @tweet.post.to_s.gsub("\r\n", " ").length + 1  # 改行が2文字カウントになるため半角スペースへ置換
    
    render action: "index" and return
  end

  #--------#
  # delete #
  #--------#
  def delete
    if current_user.is_super?
      tweet = Tweet.where( id: params[:id] ).first
    else
      tweet = Tweet.where( id: params[:id], user_id: session[:user_id] ).first
    end
    
    # 削除
    tweet.destroy

    redirect_to( action: "index", room_id: tweet.room_id ) and return
  end

  #-------#
  # batch #
  #-------#
  def batch
    # バッチログ取得
    @batch_logs = BatchLog.order( "created_at DESC" ).page( params[:page] ).per( PER_PAGE )
  end
end
