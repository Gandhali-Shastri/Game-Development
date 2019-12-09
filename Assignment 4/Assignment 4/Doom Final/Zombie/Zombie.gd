extends KinematicBody

const MOVE_SPEED = 3
const COOLDOWN_TIME = 200

onready var raycast = $RayCast
onready var anim_player = $AnimationPlayer

var exploding_zombie = false
var IMPACT = 2
var BURST_RADIUS = 9

var player = null
var dead = false
var health = 1
var coolTime = 200

#-----------------------------------------------------------
func _ready() :
  anim_player.play( 'walk' )
  add_to_group( 'zombies' )

#-----------------------------------------------------------
func _physics_process( delta ) :
  if dead :
    return

  if player == null :
    return

  var vec_to_player  
  if coolTime > COOLDOWN_TIME:
    vec_to_player = player.translation - translation
  else:
    vec_to_player = - player.translation + translation
  coolTime += 1

  vec_to_player = vec_to_player.normalized()
  raycast.cast_to = vec_to_player * 1.5

  # warning-ignore:return_value_discarded
  move_and_collide( vec_to_player * MOVE_SPEED * delta )

  if raycast.is_colliding() :
    var coll = raycast.get_collider()
    if coll != null and coll.name == 'Player' and coolTime > COOLDOWN_TIME:
      coolTime = 0
      coll.hurt( 1 )

#-----------------------------------------------------------
func hurt( howMuch = 1 ) :
  health -= howMuch

  if health <= 0 :
    dead = true
    $CollisionShape.disabled = true
    anim_player.play( 'die' )
    print( '%s died.' % name )
    $'../Zombie Audio'._playSound( 'die' )
    $'../HUD Layer'._opponentDied()

    # Zombie Burst 
    print( exploding_zombie )
    if exploding_zombie:
      $'../Zombie Audio'._playSound( "burst" )

      player.burstImpact( translation, BURST_RADIUS, IMPACT )
      get_tree().call_group( 'zombies', 'burstImpact', translation, BURST_RADIUS, IMPACT )
      yield(get_tree().create_timer(1.0), "timeout")
      get_tree().call_group( 'obstacles', 'burstImpact', translation, BURST_RADIUS, IMPACT )
      get_tree().call_group( 'spawns', 'burstImpact', translation, BURST_RADIUS, IMPACT )

  else :
    anim_player.play( 'wounded' )
    print( '%s wounded by %d, now has %d.' % [ name, howMuch, health ] )
    $'../Zombie Audio'._playSound( 'grunt' )

#-----------------------------------------------------------
func setHealth( hp ) :
  health =  hp

#-----------------------------------------------------------
func set_player( p ) :
  player = p

#-----------------------------------------------------------
func burstImpact( burst_translation, radius = 1, impact = 1 ):
  var dist = translation.distance_to( burst_translation ) 
  if not dead and dist < radius:
    hurt( impact )

#-----------------------------------------------------------
func setExplosion( value ) :
  exploding_zombie = value