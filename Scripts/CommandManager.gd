extends Node2D

# THINGS TO WORK OUT!
# 1. What happens if opposing factions move to each other's regions?
# 2. What happens if one unit assaults a region that another unit is moving out of?
# 3. Should defence values be removed altogether? This way all units should take damage on an assault. 
# 4. Combining units into a stack - multiple units in a region can combine to make up one big stack. 
# 5. Need to refactor the Unit node to be more generic. 
# 6. Need to find a way for the region command collection to be modified when units move. 
# 7. Need to display damage taken. 
# 8. Need to visualise stats when player makes decisions -> i.e: reinforcements and combined
# 	unit stats need to be shown.

signal turn_sequence_ended
signal finished_moving
var units_to_move = Array()


