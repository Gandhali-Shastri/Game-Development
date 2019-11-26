extends Spatial

export var rotationRate = 150
export var quantity     = 20
const RESPAWN_TIME = 20
var respawn_timer = 0


func _ready():
  $Holder/Health_Pickup_Trigger.connect("body_entered", self, "trigger_body_entered")


func _physics_process(delta):
	if respawn_timer > 0:
		respawn_timer -= delta
  
  if respawn_timer <= 0:
      $Holder/Health_Kit.visible = true
    
#-----------------------------------------------------------
func _process( delta ) :
  var rot_speed = deg2rad( rotationRate )
  rotate_y( rot_speed*delta )

#-----------------------------------------------------------
func setQuantity( qty ) :
  quantity = qty

#-----------------------------------------------------------
      
func trigger_body_entered(body):
  	if body.has_method("add_health"):
		  body.add_health(quantity)
		  respawn_timer = RESPAWN_TIME
		  $Holder/Health_Pickup_Trigger/Shape_Kit.disabled = true
		  $Holder/Health_Kit.visible = false