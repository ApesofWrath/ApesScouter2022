# Copyright 2022
# The Apes of Wrath
#
# @author Cody King
# cking@apesofwrath668.org

Sequel.migration do
    change do
        create_table(:matches) do
            primary_key :id
            Integer :comp_id, :null => false
            String :name, :null => false
            Integer :team_number, :null => false
            Integer :match_number, :null => false
            String :preload, :null => false
            String :taxi, :null => false
            Integer :auton_lower, :null => false
            Integer :auton_upper, :null => false
            Integer :auton_misses, :null => false
            Integer :tele_lower, :null => false
            Integer :tele_upper, :null => false
            Integer :tele_misses, :null => false
            Integer :dropped_balls, :null => false
            String :shooting_spot, :null => false
            String :hangar, :null => false
            String :result, :null => false
            Integer :own_score, :null => false
            Integer :opp_score, :null => false
            Integer :ranking_points, :null => false
            String :ball_pickup, :null => false
            String :ball_capacity, :null => false
            String :driver_skill, :null => false
            String :played_defense, :null => false
            Text :notes
        end
    end
end

