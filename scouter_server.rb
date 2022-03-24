# Copyright 2022
# The Apes of Wrath
#
# @author Cody King
# cking@apesofwrath668.org

require 'sinatra/base'

require './models.rb'

module ApesScouter
    class Server < Sinatra::Base

        get '/' do
            erb :competitions
        end

        # Competitions
        get '/competitions' do
            erb :competitions
        end

        # Create new competition
        get '/new_comp' do
            erb :new_competition
        end

        # Delete Competition
        get '/delete_comp' do
            erb :delete_comp
        end

        get '/competitions/:id/delete' do
            erb :delete_confirm
        end
        
        post '/competitions/:id/delete' do
            @competition.delete
            redirect "/competitions"
        end

        # List of competitions to choose from
        post '/competitions' do
            # Check for duplicate entry
            begin
                competition = Competition.create(:name => params[:name], :year => params[:year])
                competition.save
                rescue Sequel::UniqueConstraintViolation
                    halt(400, "Competition already exists.")
            end

            redirect "/competitions/#{competition.id}"
        end

        # Check that it is a valid project id
        before '/competitions/:id*' do
            @competition = Competition[params[:id]]
            halt(400, "Invalid competition (id).") if @competition.nil?
        end

        # Competition page with match entries
        get '/competitions/:id' do
            # Sorting 
            cols = [] 
            DB.fetch("SHOW COLUMNS FROM matches;").each do |col|
                cols.push(col[:Field])
            end
            if cols.include?(params[:sort])
                @match_sort = params[:sort].to_sym
            else
                @match_sort = :team_number
            end
            
            erb :competition
        end

        # Competition Stats
        get '/competitions/:id/stats' do
            @competition = Competition[params[:id]]
            erb :stats
        end

        # New Pit Scouting
        get '/competitions/:id/new_pit_scout' do
            erb :new_pit_scout
        end

        post '/pit_scouting' do
            # Check if entry exists for team
            if DB.fetch("SELECT COUNT(*) FROM pit_scouting WHERE comp_id = ? AND team_number = ?;", 
                        params[:comp_id], params[:team_number]).first[:"COUNT(*)"].to_i != 0
                halt(400, "Entry found with same team number. Please check your values.")
            end

            # Write image file
            if params[:file]
                @filename = params[:file][:filename]
                file = params[:file][:tempfile]
                File.open("./public/robots/#{params[:team_number]}_#{params[:comp_id]}", 'wb') do |f|
                f.write(file.read)
                end
            end
           
            # Check if it is the first entry for this team. If so, create entry in teams table.
            if Team.where(:number => params[:team_number]).all.length == 0
                Team.create(:number => params[:team_number])
            end

            #halt(400, "Did you make a selection for intake?") if params[:ball_intake].nil?

            intake_val = ""
            if(params[:intake])
                intake_val = params[:intake].join(', ')
            end
            team_data = Pit_Scouting.create(:comp_id => params[:comp_id], :scouter_name => params[:scouter_name],
                                            :team_name => params[:team_name], :team_number => params[:team_number],
                                            :drivetrain_type => params[:drivetrain_type], :drivetrain_history => params[:drivetrain_history],
                                            :camera_use => params[:camera_use], :shooting => params[:shooting],
                                            :shooter_mech => params[:shooter_mech], :climbing => params[:climbing],
                                            :climber_mech => params[:climber_mech], :climb_time => params[:climb_time],
                                            :intake => intake_val, :intake_mech => params[:intake_mech], 
                                            :auton_strategy => params[:auton_strategy], :game_strategy => params[:game_strategy],
                                            :endgame_strategy => params[:endgame_strategy], :most_proud => params[:most_proud],
                                            :first_time => params[:first_time], :most_difficult => params[:most_difficult],
                                            :other_comps => params[:other_comps], :comp_success => params[:comp_success],
                                            :confidence => params[:confidence], :other => params[:other])
           
            redirect "/competitions/#{team_data.comp_id}/teams/#{team_data.team_number}"
        end
        
        # Add new match entry
        get '/competitions/:id/new_match' do
            erb :new_match
        end

        # Add new match data to database
        post '/matches' do
            # Check if entry exists for team with same match number
            if DB.fetch("SELECT COUNT(*) FROM matches WHERE comp_id = ? AND team_number = ? AND match_number = ?;", 
                        params[:comp_id], params[:team_number], params[:match_number]).first[:"COUNT(*)"].to_i != 0
                halt(400, "Entry found with same team number and match number. Please check your values.")
            end

            # Check if it is the first entry for this team. If so, create entry in teams table.
            if Team.where(:number => params[:team_number]).all.length == 0
                Team.create(:number => params[:team_number])
            end

            intake_val = ""
            if(params[:ball_pickup])
                intake_val = params[:ball_pickup].join(', ')
            end

            match = Match.create(:comp_id => params[:comp_id], :team_number => params[:team_number], 
                                 :match_number => params[:match_number], 
                                 :name => params[:name], :preload => params[:preload], 
                                 :taxi => params[:taxi], :auton_lower => params[:auton_lower],
                                 :auton_upper => params[:auton_upper], :auton_misses => params[:auton_misses],
                                 :tele_lower => params[:tele_lower], :tele_upper => params[:tele_upper],
                                 :tele_misses => params[:tele_misses], :dropped_balls => params[:dropped_balls], 
                                 :shooting_spot => params[:shooting_spot], :hangar => params[:hangar],
                                 :result => params[:result], :own_score => params[:own_score], 
                                 :opp_score => params[:opp_score], 
                                 :ranking_points => params[:ranking_points],
                                 :ball_pickup => intake_val, 
                                 :ball_capacity => params[:ball_capacity],
                                 :driver_skill => params[:driver_skill], 
                                 :played_defense => params[:played_defense], :notes => params[:notes])
       
            redirect "/competitions/#{match.comp_id}"
        end

        # Check that it is a valid project id
        before '/matches/:id*' do
            @match = Match[params[:id]]
            halt(400, "Invalid match (id).") if @match.nil?
        end
        
        # Edit Match Data
        get '/matches/:id/edit' do
            erb :match_edit
        end

        post "/matches/:id/edit" do
            intake_val = ""
            if(params[:ball_pickup])
                intake_val = params[:ball_pickup].join(', ')
            end
            @match = Match[params[:id]]
            @match.team_number = params[:team_number]
            @match.match_number = params[:match_number]
            @match.preload = params[:preload]
            @match.taxi = params[:taxi]
            @match.auton_lower = params[:auton_lower]
            @match.auton_upper = params[:auton_upper]
            @match.auton_misses = params[:auton_misses]
            @match.tele_lower = params[:tele_lower]
            @match.tele_upper = params[:tele_upper]
            @match.tele_misses = params[:tele_misses]
            @match.dropped_balls = params[:dropped_balls]
            @match.hangar = params[:hangar]
            @match.result = params[:result]
            @match.own_score = params[:own_score]
            @match.opp_score = params[:opp_score]
            @match.ranking_points = params[:ranking_points]
            @match.shooting_spot = params[:shooting_spot]
            @match.ball_pickup = intake_val
            @match.ball_capacity = params[:ball_capacity]
            @match.driver_skill = params[:driver_skill]
            @match.played_defense = params[:played_defense]
            @match.notes = params[:notes]
            @match.save

            redirect "/competitions/#{@match.comp_id}"
        end

        # Check that it is a valid team
        before '/competitions/:id/teams/:number*' do
            @team = Team[params[:number]]
            halt(400, "Team \"#{params[:number]}\" was not found.") if @team.nil?
        end

        # Team page (with stats)
        get '/competitions/:id/teams/:number' do
            # Sorting 
            cols = [] 
            DB.fetch("SHOW COLUMNS FROM matches;").each do |col|
                cols.push(col[:Field])
            end
            if cols.include?(params[:sort])
                @match_sort = params[:sort].to_sym
            else
                @match_sort = :match_number
            end

            erb :team
        end

        # Change Team Picture
        post '/change_picture' do
            @filename = params[:file][:filename]
            file = params[:file][:tempfile]
            File.open("./public/robots/#{params[:team_number]}_#{params[:comp_id]}", 'wb') do |f|
                f.write(file.read)
            end

            redirect "/competitions/#{params[:comp_id]}/teams/#{params[:team_number]}"
        end
        
        # Teams List
        get '/teams' do
            erb :teams
        end

        get '/competitions/:id/teams_list' do
            erb :teams_list
        end
    end
end
