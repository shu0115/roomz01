# coding: utf-8
class TweetsController < ApplicationController
  
  #-------#
  # index #
  #-------#
  def index
    @room = Room.where( id: params[:room_id] ).first
    @tweets = Tweet.where( room_id: params[:room_id] ).order( "created_at DESC" ).includes( :user )
    
    # アイコン配列生成用
    @tweet_hash = Hash.new{ |hash, key| hash[key] = Hash.new }
    @tweets.each{ |tweet|
      @tweet_hash[tweet.user_id][:screen_name] = tweet.user.try(:screen_name)
      @tweet_hash[tweet.user_id][:image] = tweet.user.try(:image)
    }
    
    @tweet = Tweet.new
    @str_count = @room.hash_tag.length + 1
  end

  #--------#
  # create #
  #--------#
  def create
    tweet = Tweet.new( params[:tweet] )
    tweet.room_id = params[:room_id]
    tweet.user_id = session[:user_id]
    
    room = Room.where( id: tweet.room_id ).first
    
    if room.hash_tag_position == "before"
      tweet.post = "#{room.try(:hash_tag)} #{tweet.post}"
    elsif room.hash_tag_position == "after"
      tweet.post = "#{tweet.post} #{room.try(:hash_tag)}"
    end
    
    ActiveRecord::Base.transaction do
      # 内部DB保存
      if tweet.save
        flash[:notice] = 'ポストが完了しました。'

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
          twitter_client.update( tweet.post )
        end
      else
        flash[:alert] = 'ポストが失敗しました。'
      end
    end
    
    redirect_to( action: "index", room_id: params[:room_id] ) and return
  rescue => ex
    flash[:notice] = ""
    flash[:alert] = ex.message
    
    @room = Room.where( id: params[:room_id] ).first
    @tweets = Tweet.where( room_id: params[:room_id] ).order( "created_at DESC" ).includes( :user )
    
    # アイコン配列生成用
    @tweet_hash = Hash.new{ |hash, key| hash[key] = Hash.new }
    @tweets.each{ |tweet|
      @tweet_hash[tweet.user_id][:screen_name] = tweet.user.try(:screen_name)
      @tweet_hash[tweet.user_id][:image] = tweet.user.try(:image)
    }
    
    @tweet = Tweet.new( params[:tweet] )
    @str_count = @room.hash_tag.length + @tweet.post.to_s.gsub("\r\n", " ").length + 1  # 改行が2文字カウントになるため半角スペースへ置換
    render action: "index" and return
  end

  #--------#
  # delete #
  #--------#
  def delete
    tweet = Tweet.where( id: params[:id], user_id: session[:user_id] ).first
    tweet.destroy

    redirect_to( action: "index", room_id: tweet.room_id ) and return
  end
  
  
  
=begin
  # GET /tweets
  # GET /tweets.json
  def index
    @tweets = Tweet.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @tweets }
    end
  end

  # GET /tweets/1
  # GET /tweets/1.json
  def show
    @tweet = Tweet.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @tweet }
    end
  end

  # GET /tweets/new
  # GET /tweets/new.json
  def new
    @tweet = Tweet.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @tweet }
    end
  end

  # GET /tweets/1/edit
  def edit
    @tweet = Tweet.find(params[:id])
  end

  # POST /tweets
  # POST /tweets.json
  def create
    @tweet = Tweet.new(params[:tweet])

    respond_to do |format|
      if @tweet.save
        format.html { redirect_to @tweet, notice: 'Tweet was successfully created.' }
        format.json { render json: @tweet, status: :created, location: @tweet }
      else
        format.html { render action: "new" }
        format.json { render json: @tweet.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /tweets/1
  # PUT /tweets/1.json
  def update
    @tweet = Tweet.find(params[:id])

    respond_to do |format|
      if @tweet.update_attributes(params[:tweet])
        format.html { redirect_to @tweet, notice: 'Tweet was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @tweet.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tweets/1
  # DELETE /tweets/1.json
  def destroy
    @tweet = Tweet.find(params[:id])
    @tweet.destroy

    respond_to do |format|
      format.html { redirect_to tweets_url }
      format.json { head :no_content }
    end
  end
=end
end
