# coding: utf-8
class RoomsController < ApplicationController
  
  #-------#
  # index #
  #-------#
  def index
    @rooms = Room.order( "created_at DESC" ).includes( :user ).all
    @room = Room.new
  end
  
  #------#
  # show #
  #------#
  def show
    @room = Room.where( id: params[:id] ).first
    @tweets = Tweet.where( room_id: params[:id] ).order( "created_at DESC" ).includes( :user )

    # アイコン配列生成用
#    @tweet_hash = Tweet.get_user_icons( @tweets )
    @icon_hash = Tweet.get_user_icons( @room )
    
    # Twitterから取得
    get_twitter_hash = Tweet.get_twitter_param( @room )
    @get_tweets = Twitter.search( get_twitter_hash[:search_query], lang: get_twitter_hash[:options][:lang], result_type: get_twitter_hash[:options][:result_type], rpp: get_twitter_hash[:options][:rpp], page: get_twitter_hash[:options][:page] )
    
    # TwitterのツイートをRoomzへ登録
    # if @room.worker_flag == true
    #   Tweet.absorb_tweets( @room )
    # end
  end
  
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
#    update_room[:twitter_synchro] = false unless update_room[:twitter_synchro] == "true"
    update_room[:worker_flag] = false unless update_room[:worker_flag] == "true"
    
    room = Room.where( id: params[:id], user_id: session[:user_id] ).first

    unless room.update_attributes( update_room )
      redirect_to( { action: "edit", id: room.id }, alert: 'Roomの更新に失敗しました。' ) and return
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

end
