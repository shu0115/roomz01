# coding: utf-8
class Tweet < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :room
  
  private
  
  #---------------------#
  # self.get_user_icons #
  #---------------------#
  # アイコン一覧生成
  def self.get_user_icons( room )
    icon_hash = Hash.new{ |hash, key| hash[key] = Hash.new }
    
    tweets = Tweet.where( room_id: room.id ).order( "created_at DESC" ).limit( PER_PAGE ).all
    
    tweets.each{ |tweet|
      icon_hash[tweet.from_twitter_user_id][:screen_name] = tweet.from_twitter_user
      icon_hash[tweet.from_twitter_user_id][:image] = tweet.user_image_url
      icon_hash[tweet.from_twitter_user_id][:from_twitter_user_id] = tweet.from_twitter_user_id
    }
    
    return icon_hash
  end
  
  #--------------------------------#
  # self.get_user_icons_from_tweet #
  #--------------------------------#
  # アイコン一覧生成(Twitterから)
  def self.get_user_icons_from_tweet( tweets )
    icon_hash = Hash.new{ |hash, key| hash[key] = Hash.new }
    
    tweets.each{ |tweet|
      icon_hash[tweet.from_user_id][:screen_name] = tweet.from_user
      icon_hash[tweet.from_user_id][:image] = tweet.profile_image_url
    }
    
    return icon_hash
  end
  
  #------------------------#
  # self.get_twitter_param #
  #------------------------#
  # Twitterツイート取得パラメータ設定
  def self.get_twitter_param( room )
    param_hash = Hash.new
    
    param_hash[:search_query] = room.search_query.presence || room.hash_tag
    param_hash[:options] = Hash.new
    param_hash[:options][:lang] = "ja"
    param_hash[:options][:result_type] = "recent"
    param_hash[:options][:rpp] = 100
    param_hash[:options][:page] = 1
    
    return param_hash
  end
  
  #--------------------#
  # self.absorb_tweets #
  #--------------------#
  # Twitterツイート取得／登録
  def self.absorb_tweets( room )
    page = 1
    per_page = 100
    last_max_id = room.last_max_id.presence || 1
    search_query = room.search_query.presence || room.hash_tag
    
    # 取得データが無くなるまでループ
    loop do
      # ツイートを取得
      get_tweets = Twitter.search( "#{search_query}", lang: "ja", result_type: "recent", since_id: room.last_max_id.to_i, rpp: per_page, page: page )

      get_tweets.each{ |tweet|
        # ツイートが既に登録済みで無ければ
        unless Tweet.where( room_id: room.id, from_twitter_id: tweet.id ).exists?
          # ツイートを登録
          add_tweet = Tweet.new
          add_tweet.room_id = room.id
          add_tweet.user_id = User.where( uid: tweet.from_user_id.to_s ).first.try(:id)
          add_tweet.post = tweet.text
          add_tweet.from_twitter_id = tweet.id
          add_tweet.from_twitter_user_id = tweet.from_user_id
          add_tweet.from_twitter_user = tweet.from_user
          add_tweet.user_image_url = tweet.profile_image_url
          add_tweet.created_at = tweet.created_at
          add_tweet.save
          
          last_max_id = tweet.id if last_max_id < tweet.id
        end
      }
      
      page += 1
      
      # 取得ツイートが無ければ
      if get_tweets.blank?
        # MaxIDを更新
        room.update_attributes( last_max_id: last_max_id )
        
        # ループを抜ける
        break 
      end
    end
  end
  
  #--------------------#
  # self.run_get_tweet #
  #--------------------#
  # バッチ呼び出し
  def self.run_get_tweet
    Tweet.get_all_room_tweet
  end

  #-------------------------#
  # self.get_all_room_tweet #
  #-------------------------#
  # 全Roomツイート取得&登録
  def self.get_all_room_tweet
    # バッチログ情報
    batch_log = BatchLog.new
    batch_log.name = "Tweet.get_all_room_tweet"
    batch_log.description = "ツイート取得／保存"
    batch_log.start_at = Time.now
    batch_log.save
    
    # Room全取得
    rooms = Room.where( worker_flag: true ).order( "id DESC" ).all
    
    # Roomループ
    rooms.each{ |room|
      batch_log.result ||= ""
      batch_log.result += "#{room.id}|"
      batch_log.result += "#{room.hash_tag}|"
      batch_log.result += "#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}|"
      
      page = 1
      per_page = 100
      last_max_id = 1
      search_query = room.search_query.presence || room.hash_tag
      total_count = 0
      batch_log.total_count ||= 0
      
      # 取得データが無くなるまでループ
      loop do
        # ツイートを取得
        get_tweets = Twitter.search( "#{search_query}", lang: "ja", result_type: "recent", since_id: room.last_max_id.to_i, rpp: per_page, page: page )

        get_tweets.each{ |tweet|
          # ツイートが既に登録済みで無ければ
          unless Tweet.where( room_id: room.id, from_twitter_id: tweet.id ).exists?
            # ツイートを登録
            add_tweet = Tweet.new
            add_tweet.room_id = room.id
            add_tweet.user_id = User.where( uid: tweet.from_user_id.to_s ).first.try(:id)
            add_tweet.post = tweet.text
            add_tweet.from_twitter_id = tweet.id
            add_tweet.from_twitter_user_id = tweet.from_user_id
            add_tweet.from_twitter_user = tweet.from_user
            add_tweet.user_image_url = tweet.profile_image_url
            add_tweet.created_at = tweet.created_at
            
            if add_tweet.save
              total_count += 1
            end
            
            # max_id更新
            last_max_id = tweet.id if last_max_id < tweet.id
          end
        }
        
        page += 1
        
        # 取得ツイートが無ければ
        if get_tweets.blank?
          # MaxIDを更新(1より大きくなっていれば)
          if last_max_id > 1
            room.update_attributes( last_max_id: last_max_id )
          end
        
          batch_log.total_count += total_count
          batch_log.result += "#{Time.now.strftime("%Y/%m/%d %H:%M:%S")}|"
          batch_log.result += "#{total_count}|\n"
          
          # ループを抜ける
          break 
        end
      end
    }
    
    # 終了時刻保存
    batch_log.end_at = Time.now
    batch_log.process_time = batch_log.end_at - batch_log.start_at
    batch_log.save
  end
end
