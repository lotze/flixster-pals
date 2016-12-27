require 'json'
require 'net/http'
require 'ostruct'
require 'set'
require 'time'

user_ids = ['907243067']
#, '790365789', '910903946'] # David Molnar, Ashley Newton
# format should be 'theater' or 'dvd' or 'upcoming'
format = 'dvd'
n = 100

# a Flixster movie people want to see
class WtsMovie < OpenStruct
  # attr_accessor :id, :title, :rating, :movietype, :tomatometer, :audiencescore, :theaterReleaseDate, :dvdReleaseDate
  # movietype can be "TopBoxOffice", "Upcoming", "DvdOther", "DvdUpcoming", "DvdNewRelease"

  def eql?(other)
    id == other.id
  end

  def theater_release
    return nil unless theaterReleaseDate
    Time.parse(theaterReleaseDate)
  end

  def dvd_release
    return nil unless dvdReleaseDate
    Time.parse(dvdReleaseDate)
  end

  def format
    if theater_release && theater_release > Time.now
      'upcoming'
    elsif movietype !~ /^Dvd/
      'theater'
    elsif dvd_release && dvd_release < Time.now
      'dvd'
    else
      'unavailable'
    end
  end

  def rating_ish
    tomatometer || 0
  end
end

class WtsUser
  attr_accessor :user_id, :name, :wts_json, :movies

  def initialize(user_id)
    @user_id = user_id
    refresh
  end

  def refresh
    # friends from https://www.flixster.com/api/users/907243067/friends/
    # ratings from https://www.flixster.com/api/users/790365789/movies/ratings
    wts_uri = URI("https://www.flixster.com/api/users/#{user_id}/movies/ratings?scoreTypes=wts")
    result = Net::HTTP.get(wts_uri)
    @wts_json = JSON.parse(result)
    reparse
  end

  def reparse
    user_json = wts_json.first['user']
    @name = "#{user_json['firstName']} #{user_json['lastName']}"
    @movies = wts_json.map {|m| WtsMovie.new(m['movie'])}
  end
end

uid = user_ids.first
friend_uri = URI("https://www.flixster.com/api/users/#{uid}/friends/")
result = Net::HTTP.get(friend_uri)
friend_json = JSON.parse(result)
# exit(0)

users = user_ids.map {|uid| WtsUser.new(uid)}

users.each do |user|
  # print top n rated movies in category
  best = user.movies.select {|m| m.format == format}.sort_by(&:rating_ish).reverse[0..n-1]
  print "Top #{n} movies #{user.name} wants to see:\n"
  best.each do |movie|
    print "#{movie.title}: #{movie.tomatometer}\n"
  end
  print "\n\n"
end

# print top 10 rated movies in common
if users.length > 1
  in_common = nil
  users.each do |user|
    if in_common.nil?
      in_common = Set.new(user.movies)
    else
      in_common = in_common.intersection(user.movies)
    end
  end
  best = in_common.select {|m| m.format == format}.sort_by(&:rating_ish).reverse[0..n-1]
  if best.length > 0
    print "Top #{n} movies everyone wants to see:\n"
    best.each do |movie|
      print "#{movie.title}: #{movie.tomatometer}\n"
    end
  end
end