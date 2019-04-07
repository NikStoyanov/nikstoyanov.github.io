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

    start_at_year = 2019

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
        if activity.type == 'Run'
          activity = Strava.client.activity(activity.id)

          FileUtils.mkdir_p "content/runs/#{activity.start_date_local.year}"

          File.open activity.run_filename, 'w' do |file|
            tags = [
              "#{activity.type.downcase}s",
              "#{activity.rounded_distance_in_kilometres_s} km",
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
            file.write "\n|#{activity.distance_in_kilometers_s}|#{activity.moving_time_in_hours_s}|#{activity.pace_per_kilometer_s}|\n"

            file.write "\n#{activity.description}\n" if activity.description && !activity.description.empty?
            file.write "\n<img src='#{activity.map.image_url}'>\n" if activity.map && activity.map.image_url

            if activity.splits_metric && activity.splits_metric.any?
              file.write "\n### Splits\n"
              file.write "\n| Kilometre | Pace | Elevation |"
              file.write "\n|------|------|-----------|"
              activity.splits_metric.each do |split|
                file.write "\n|#{split.split}|#{split.pace_per_kilometer_s}|#{split.total_elevation_gain_in_meters_s}|"
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
          puts activity.run_filename

        elsif activity.type == 'Swim'
          activity = Strava.client.activity(activity.id)

          FileUtils.mkdir_p "content/swims/#{activity.start_date_local.year}"

          File.open activity.swim_filename, 'w' do |file|
            tags = [
              "#{activity.type.downcase}s",
              "#{activity.distance_s} m",
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
    parent: "swims"
    weight: 130
---
          EOS

            file.write "\n### Stats\n"
            file.write "\n| Distance | Time | Pace |"
            file.write "\n|----------|------|------|"
            file.write "\n|#{activity.distance_in_meters_s}|#{activity.moving_time_in_hours_s}|#{activity.pace_per_100_meters_s}|\n"

            file.write "\n#{activity.description}\n" if activity.description && !activity.description.empty?
            file.write "\n<img src='#{activity.map.image_url}'>\n" if activity.map && activity.map.image_url
          end
          puts activity.swim_filename

        else
          next
        end
      end
      page += 1
      activities = Strava.client.athlete_activities(activities_options.merge(page: page))
    end
  end
end
