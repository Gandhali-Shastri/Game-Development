extends KinematicBody

const MOVE_SPEED =   4
const MOUSE_SENS =   0.5
const MAX_ANGLE  =  88
const MIN_ANGLE  = -45
var MAX_HP = 10
var Current_hp = 3
# FOV for when we zoom using "telescopic sight".
const FOV_NORMAL = 70
const FOV_ZOOM   = 6

var zoomed = false

onready var anim_player = $AnimationPlayer
onready var raycast = $RayCast

#-----------------------------------------------------------
func _ready():
  Input.set_mouse_mode( Input.MOUSE_MODE_CAPTURED )

  yield( get_tree(), 'idle_frame' )

  get_tree().call_group( 'zombies', 'set_player', self )

#-----------------------------------------------------------
func _input( event ) :
  if Input.is_action_just_pressed( 'zoom' ) :
    zoomed = not zoomed

  if zoomed :
    get_node( 'Camera' ).fov = FOV_ZOOM
    get_node( 'View/Crosshair' ).visible = false
    get_node( 'View/Scopesight' ).visible = true

  else :
    get_node( 'Camera' ).fov = FOV_NORMAL
    get_node( 'View/Crosshair' ).visible = true
    get_node( 'View/Scopesight' ).visible = false

  if event is InputEventMouseMotion :
    rotation_degrees.y -= MOUSE_SENS * event.relative.x

    rotation_degrees.x -= MOUSE_SENS * event.relative.y
    rotation_degrees.x = min( MAX_ANGLE, max( MIN_ANGLE, rotation_degrees.x ) )

#-----------------------------------------------------------
func _process( __ ) :    # Not using delta so don't name it.
  if Input.is_action_pressed( 'restart' ) :
    kill()

#-----------------------------------------------------------
func _physics_process( delta ) :
  var move_vec = Vector3()

  if Input.is_action_pressed( 'move_forwards' ) :
    move_vec.z -= 1

  if Input.is_action_pressed( 'move_backwards' ) :
    move_vec.z += 1

  if Input.is_action_pressed( 'move_left' ) :
    move_vec.x -= 1

  if Input.is_action_pressed( 'move_right' ) :
    move_vec.x += 1

  move_vec = move_vec.normalized()
  move_vec = move_vec.rotated( Vector3( 0, 1, 0 ), rotation.y )

  # warning-ignore:return_value_discarded
  move_and_collide( move_vec * MOVE_SPEED * delta )

  if Input.is_action_just_pressed( 'shoot' ) and !anim_player.is_playing() :
    if $'../HUD Layer'._ammoUsed() :
      anim_player.play( 'shoot' )
      $'../Player Audio'._playSound( 'shoot' )

      var coll = raycast.get_collider()
     # print(coll.get_name())
      if raycast.is_colliding():  	    
        if coll.has_method( 'hurt' ) :
          coll.hurt()
        elif coll.has_method('explode'):
          coll.explode()

    else :
      $'../Player Audio'._playSound( 'empty' )

#-----------------------------------------------------------
func kill(damage =1) :
  Current_hp = Current_hp - damage
  if Current_hp != 0:
    $'../HUD Layer'._HpLost(1) 
    print( 'Player wounded by %d, now has %d.' % [ damage, Current_hp ] )
    $'../Zombie Audio'._playSound( 'grunt' )
  else:
    var timeStr = $'../HUD Layer'.getTimeStr()
    print( 'Player died at %s.' % timeStr )
    $'../Message Layer/Message'.activate( 'Player Died\n%s' % timeStr )
#-----------------------------------------------------------
func add_ammo(ammo):
  $'../HUD Layer'._resetAmmo(ammo) 

func add_health(hp):
  Current_hp += hp
  if Current_hp > MAX_HP:
    Current_hp = MAX_HP
    $'../HUD Layer'._resetHp(Current_hp) 
  
  print('hp after taking healthpack',Current_hp)
  $'../HUD Layer'._resetHp(Current_hp) 