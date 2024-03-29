extends TileMap

const BOUNCINESS = {
	"tile_rock": 0.5,
	"tile_brick": 0.5,
	"tile_bouncy": 0.8,
	"tile_mud": 0.25
}
const ROUGHNESS = {
	"tile_rock": 0.01,
	"tile_brick": 0.01,
	"tile_bouncy": 0.01,
	"tile_mud": 0.1
}

const FIX_HOLES = [
	"tile_brick",
	"tile_rock",
	"tile_bouncy",
	"tile_mud",
	"spikes_left",
	"spikes_right",
	"spikes_up",
	"spikes_down"
]

export var Tile : PackedScene
export var Start : PackedScene
export var Goal : PackedScene
export var Spikes : PackedScene


func _ready():
	var tiles = get_used_cells()
	for i in tiles.size():
		var pos = map_to_world(tiles[i]) + Vector2(6, 6)
		var tile_name = tile_set.tile_get_name(get_cellv(tiles[i]))
		
		# Instance based on tile id
		if tile_name != "border":
			var t
			match tile_name:
				"tile_rock", "tile_brick", "tile_bouncy", "tile_mud":
					t = Tile.instance()
					t.init(BOUNCINESS[tile_name], ROUGHNESS[tile_name])
				"start":
					t = Start.instance()
					pos += Vector2(6, 6)
					set_cellv(tiles[i], -1)
				"goal_all", "goal_right", "goal_left", "goal_down", "goal_up":
					t = Goal.instance()
					pos += Vector2(6, 6)
					set_cellv(tiles[i], -1)
				"spikes_left", "spikes_right", "spikes_up", "spikes_down":
					t = Spikes.instance()
					match tile_name:
						"spikes_left":
							t.rotation_degrees = 270
						"spikes_right":
							t.rotation_degrees = 90
						"spikes_up":
							t.rotation_degrees = 0
						"spikes_down":
							t.rotation_degrees = 180
			
			if t != null:
				t.position = pos
				get_parent().call_deferred("add_child", t)
		else:
			# Delete border
			set_cellv(tiles[i], -1)
		
		# Fix holes (dude wtf is this shit, why am i doing this)
		# Ben, in case you need to change this- you might need to change the grid size
		# of the "FixHoles" tilemap in the TileMapMain scene. But trust me, and DONT CHANGE IT.
		# JUST PICK ONE FREAKIN ART STYLE DUDE, STOP CHANGING IT EVERY FEW DAYS. JESUS CHRIST
		if tile_name == "tile_rock" or tile_name == "tile_bouncy" or tile_name == "tile_mud":
			for adjacent in [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]:
				if get_cellv(tiles[i] + adjacent) != -1:
					var adj_name = tile_set.tile_get_name(get_cellv(tiles[i] + adjacent))
					var fixpos = tiles[i] * 6
					if adj_name in FIX_HOLES and tile_name != adj_name:
						match adjacent:
							Vector2.LEFT:
								if not adj_name in ["spikes_right", "spikes_up", "spikes_down"]:
									$FixHoles.set_cell(fixpos.x, fixpos.y, 0)
									$FixHoles.set_cell(fixpos.x, fixpos.y+5, 0)
							Vector2.RIGHT:
								if not adj_name in ["spikes_left", "spikes_up", "spikes_down"]:
									$FixHoles.set_cell(fixpos.x+5, fixpos.y, 0)
									$FixHoles.set_cell(fixpos.x+5, fixpos.y+5, 0)
							Vector2.UP:
								if not adj_name in ["spikes_left", "spikes_right", "spikes_down"]:
									$FixHoles.set_cell(fixpos.x, fixpos.y, 0)
									$FixHoles.set_cell(fixpos.x+5, fixpos.y, 0)
							Vector2.DOWN:
								if not adj_name in ["spikes_left", "spikes_right", "spikes_up"]:
									$FixHoles.set_cell(fixpos.x, fixpos.y+5, 0)
									$FixHoles.set_cell(fixpos.x+5, fixpos.y+5, 0)
