extends StaticBody

var health = Utils.dieRoll('6d6')
var portal_status = true

func _ready():
  pass

func explode( howMuch = 1) :
  health -= howMuch
  print(health)
  if health <= 0 :
    portal_status = true
    $"smoke-green".visible = false
    $"smoke-green2".visible = false
    $"smoke-red".visible = true
    $"smoke-red2".visible = true
    print("portal down")
    return portal_status