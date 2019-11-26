extends Spatial

var health = 3
var expl = false
var fire_particles
    
func _ready():
  fire_particles = $Fire
  fire_particles.emitting = false
  print("barrel")


func explode( howMuch = 1 ) :
  health -= howMuch
  if health <= 0 :
    print ("boom")
    $'../Zombie Audio'._playSound( 'boom' )
    expl = true
    $CollisionShape.disabled = true
    fire_particles.emitting = true
    
