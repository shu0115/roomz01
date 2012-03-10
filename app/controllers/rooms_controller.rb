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
    @tweets = Tweet.where( room_id: params[:id] ).order( "created_at DESC" ).includes( :user ).all
    @tweet = Tweet.new
  end

=begin
  #-----#
  # new #
  #-----#
  def new
    @room = Room.new
  end

  #------#
  # edit #
  #------#
  def edit
    @room = Room.where( id: params[:id] ).first
  end
=end

  #--------#
  # create #
  #--------#
  def create
    @room = Room.new( params[:room] )
    @room.user_id = session[:user_id]

    if @room.save
      redirect_to( action: "index", notice: 'Roomの作成が完了しました。') and return
    else
      redirect_to( action: "index", alert: 'Roomの作成に失敗しました。') and return
    end
  end

  #--------#
  # update #
  #--------#
  def update
    @room = Room.where( id: params[:id], user_id: session[:user_id] ).first

    if @room.update_attributes( params[:room] )
      redirect_to @room, notice: 'Room was successfully updated.'
    else
      render action: "edit"
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
  
  #-------#
  # throw #
  #-------#
  # Do Tweet
  def throw
    @tweet = Tweet.new( params[:tweet] )
    @tweet.room_id = params[:room_id]
    @tweet.user_id = session[:user_id]

    if @tweet.save
      flash[:notice] = 'ポストが完了しました。'
    else
      flash[:alert] = 'ポストが失敗しました。'
    end
    
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

end
