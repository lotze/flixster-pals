class FlixsterUser
  attr_accessor :user_id, :name, :wts_json, :movies

  def initialize(user_id)
    @user_id = user_id
    refresh
  end

  def refresh
    # friends from https://www.flixster.com/api/users/907243067/friends/ -- if authorized
    # ratings from https://www.flixster.com/api/users/790365789/movies/ratings -- anyone
    wts_uri = URI("https://www.flixster.com/api/users/#{user_id}/movies/ratings?scoreTypes=wts")
    result = Net::HTTP.get(wts_uri)
    @wts_json = JSON.parse(result)
    reparse
  end

  def reparse
    user_json = wts_json.first['user']
    @name = "#{user_json['firstName']} #{user_json['lastName']}"
    @movies = wts_json.map {|m| FlixsterMovie.new(m['movie'])}
  end
end
