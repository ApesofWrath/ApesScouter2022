# Copyright 2022
# The Apes of Wrath
#
# @author Cody King
# cking@apesofwrath668.org

Sequel.migration do
    change do
        create_table(:pit_scouting) do
            primary_key :id
            Integer :comp_id, :null => false
            String :scouter_name, :null => false
            String :team_name, :null => false
            Integer :team_number, :null => false
            Text :drivetrain_type, :null => false
            Text :drivetrain_history, :null => false
            String :camera_use, :null => false
            String :shooting, :null => false
            Text :shooter_mech, :null => false
            String :climbing, :null => false
            Text :climber_mech, :null => false
            String :climb_time, :null => false
            String :intake, :null => false
            Text :intake_mech, :null => false
            String :auton_strategy, :null => false
            String :game_strategy, :null => false
            String :endgame_strategy, :null => false
            Text :most_proud, :null => false
            Text :first_time, :null => false
            Text :most_difficult, :null => false
            String :other_comps, :null => false
            Text :comp_success, :null => false
            Text :confidence, :null => false
            Text :other, :null => false
        end
    end
end
