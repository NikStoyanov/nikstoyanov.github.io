desc 'Generate runs from Strava.'
namespace :strava do
  task :update do
    require 'hashie'

    require 'strava-ruby-client'

    require './_lib/strava'
    require './_lib/map'
    require './_lib/activity'

    require 'fileutils'
    require 'polylines'

    require 'dotenv/load'

    start_at_year = 2015

    activities_options = { per_page: 10, after: Time.new(start_at_year).to_i }
    activities = Strava.client.athlete_activities(activities_options.merge(page: 1))

    Dir['content/runs/*'].each do |folder|
      year = folder.split('/').last
      next if year.to_i < start_at_year

      FileUtils.rm(Dir.glob("#{folder}/#{year}-*-run-*mi-*s.md"))
    end

    page = 1
    loop do
      break unless activities.any?

      activities.each do |activity|
        next unless activity.type == 'Run'
        activity = Strava.client.activity(activity.id)

        FileUtils.mkdir_p "content/runs/#{activity.start_date_local.year}"

        File.open activity.filename, 'w' do |file|
          tags = [
            "#{activity.type.downcase}s",
            "#{activity.rounded_distance_in_miles_s} miles",
            activity.race? ? 'races' : nil
          ].compact

          file.write <<-EOS
---
title: "#{activity.name}"
date: "#{activity.start_date_local.strftime('%F %T')}"
tags: [#{tags.join(', ')}]
menu:
  nav:
    identifier: "#{activity.start_date_local.strftime('%F %T')}"
    parent: "runs"
    weight: 130
---
          EOS

          file.write "\n### Stats\n"
          file.write "\n| Distance | Time | Pace |"
          file.write "\n|----------|------|------|"
          file.write "\n|#{activity.distance_in_miles_s}|#{activity.moving_time_in_hours_s}|#{activity.pace_per_mile_s}|\n"

          file.write "\n#{activity.description}\n" if activity.description && !activity.description.empty?
          file.write "\n<img src='#{activity.map.image_url}'>\n" if activity.map && activity.map.image_url

          if activity.splits_standard && activity.splits_standard.any?
            file.write "\n### Splits\n"
            file.write "\n| Mile | Pace | Elevation |"
            file.write "\n|------|------|-----------|"
            activity.splits_standard.each do |split|
              file.write "\n|#{split.split}|#{split.pace_per_mile_s}|#{split.total_elevation_gain_in_feet_s}|"
            end
            file.write "\n"
          end

          photos = Strava.client.activity_photos(activity.id, size: '600')
          if photos.any?
            file.write "\n### Photos"
            photos.each do |photo|
              url = photo.urls['600']
              file.write "\n<img src='#{url}'>\n"
            end
          end
        end
        puts activity.filename
      end
      page += 1
      activities = Strava.client.athlete_activities(activities_options.merge(page: page))
    end
  end
end