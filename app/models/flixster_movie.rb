# a Flixster movie people want to see
class FlixsterMovie < OpenStruct
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