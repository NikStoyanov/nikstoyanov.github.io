class Strava::Models::Activity < Strava::Model
    property :workout_type, from: 'workout_type', with: ->(data) {
      case data
      when 1 then 'race'
      when 2 then 'long run'
      when 3 then 'workout'
      else 'run'
      end
    }

    def to_s
      "name=#{name}, start_date=#{start_date}, distance=#{distance_s}, moving time=#{moving_time_in_hours_s}, pace=#{pace_s}, #{map}"
    end

    def run_filename
      [
        "content/runs/#{start_date_local.year}/#{start_date_local.strftime('%Y-%m-%d')}",
        type.downcase,
        distance_in_kilometers_s,
        moving_time_in_hours_s
      ].join('-') + '.md'
    end

    def swim_filename
      [
        "content/swims/#{start_date_local.year}/#{start_date_local.strftime('%Y-%m-%d')}",
        type.downcase,
        distance_in_meters_s,
        moving_time_in_hours_s
      ].join('-') + '.md'
    end

    def race?
      workout_type == 'race'
    end

    def rounded_distance_in_kilometres_s
      format('%d-%0d', distance_in_kilometers, distance_in_kilometers + 1)
    end

    def rounded_distance_in_hundred_metres_s
      rounded_distance = distance_in_meters / 100
      rounded_distance = rounded_distance.round
      format('%d', rounded_distance_up * 100)
    end
  end
