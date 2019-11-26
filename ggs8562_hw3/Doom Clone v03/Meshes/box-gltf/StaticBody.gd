#extends StaticBody
#
#export var rotationRate = 150
#export var quantity     = 20
#var Ammo
#
#func _ready():
#  Ammo = $Ammo_box
##-----------------------------------------------------------
#func _process( delta ) :
#  var rot_speed = deg2rad( rotationRate )
#  rotate_y( rot_speed*delta )
#
##-----------------------------------------------------------
#func setQuantity( qty ) :
#  quantity = qty
#
##-----------------------------------------------------------
#func add_ammo(q = quantity):
#  print("amood")
#  get_node( 'HUD Layer' ).__resetAmmo( )
#
#  var bodies = Ammo.get_overlapping_bodies()
#  for body in bodies:
#      if body.has_method("get_ammo"):
#         body.get_ammo(q)
