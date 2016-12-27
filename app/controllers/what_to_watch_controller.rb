class WhatToWatchController < ApplicationController

  def index
    @user_ids = params[:user_ids] || '907243067'
    @movie_format = 'dvd'
  end

  def display
    user_ids = (params[:user_ids] || '').chomp.split(/,\s*/)
    @user_ids = params[:user_ids]

    redirect_to index unless user_ids.present?

    # format should be 'theater' or 'dvd' or 'upcoming'
    @movie_format = params[:format] || 'dvd'
    num_results_to_display = params[:num_results_to_display] || 10

    users = user_ids.map {|uid| FlixsterUser.new(uid)}

    @best = {}
    users.each do |user|
      # print top n rated movies in category
      @best[user] = user.movies.select {|m| m.format == @movie_format}.sort_by(&:rating_ish).reverse[0..num_results_to_display-1]
    end

    # print top rated movies in common
    if users.length > 1
      in_common = nil
      users.each do |user|
        if in_common.nil?
          in_common = Set.new(user.movies)
        else
          in_common = in_common.intersection(user.movies)
        end
      end
      @best_common = in_common.select {|m| m.format == @movie_format}.sort_by(&:rating_ish).reverse[0..num_results_to_display-1]
    end
  end
end
