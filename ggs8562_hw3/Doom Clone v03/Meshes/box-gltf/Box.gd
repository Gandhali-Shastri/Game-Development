extends Spatial

export var rotationRate = 150
export var quantity     = 20
var Ammo
const RESPAWN_TIME = 20
var respawn_timer = 0
var is_ready = false

func _ready():
  $box01objcleanermaterialmergergles/ammo_trigger.connect("body_entered", self, "trigger_body_entered")
  is_ready = true

func _physics_process(delta):
	if respawn_timer > 0:
		respawn_timer -= delta
  
  if respawn_timer <= 0:
    $box01objcleanermaterialmergergles/ammo_trigger.shape.disabled = 0
		$Box/box01objcleanermaterialmergergles.visible = 1
#-----------------------------------------------------------
func _process( delta ) :
  var rot_speed = deg2rad( rotationRate )
  rotate_y( rot_speed*delta )

#-----------------------------------------------------------
func setQuantity( qty ) :
  quantity = qty

#-----------------------------------------------------------
#func add_ammo(q = quantity):
#  print("amood")
#  get_node( 'HUD Layer' ).__resetAmmo( )
#
#  var bodies = Ammo.get_overlapping_bodies()
#  for body in bodies:
#      if body.has_method("get_ammo"):
#         body.get_ammo(q)
        
func trigger_body_entered(body):
  	if body.has_method("add_ammo"):
		  body.add_ammo(quantity)
		  respawn_timer = RESPAWN_TIME
		  $box01objcleanermaterialmergergles/ammo_trigger.shape.disabled = 0
		  $Box/box01objcleanermaterialmergergles.visible = 0