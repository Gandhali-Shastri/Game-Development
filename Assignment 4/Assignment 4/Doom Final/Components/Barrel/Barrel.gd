extends StaticBody

var health = 3
var expl = false
var fire_particles
var blast_damage

func _ready():
  fire_particles = $Fire
  fire_particles.emitting = false
  blast_damage = $blast_area


func explode( howMuch = 1) :
  health -= howMuch
 
  if health <= 0 and expl == false :
    expl = true
    fire_particles.emitting = true
    print("boom")
  #  $'../Barrel Audio'._playSound( 'boom' )
    
    var bodies = blast_damage.get_overlapping_bodies()
    for body in bodies:
        if body.has_method("hurt"):
           body.hurt(Utils.dieRoll('1d2') )
        elif body.has_method("explode") :
           body.explode()
     