extends CanvasLayer

var elapsedTime = 0
var lastTime    = 0
var currentLevel = 1

#-----------------------------------------------------------
func _ready() :
  elapsedTime = 0

#-----------------------------------------------------------
func _process( delta ) :
  _updateHUDTime( delta )

#-----------------------------------------------------------
func _updateHUDTime( delta ) :
  elapsedTime += delta

  if elapsedTime - lastTime > 1 :
    lastTime = elapsedTime

    get_node( 'LevelTime' ).text = getTimeStr()

func getTimeStr() :
  var minutes = int( elapsedTime / 60 )
  var seconds = int( elapsedTime - minutes*60 )

  return '%02d:%02d' % [ minutes, seconds ]

#-----------------------------------------------------------
var maxAmmo = 50
var numAmmo = 0

func _resetAmmo( qty ) :
  
 # maxAmmo += qty
  numAmmo += qty
  if numAmmo > maxAmmo:
    numAmmo = 50
    
  _setAmmoMessage()

func _setAmmoMessage() :
  get_node( 'Ammo' ).text = '%d / %d' % [ numAmmo, maxAmmo ]

func _ammoUsed() :
  var success = numAmmo != 0

  if success :
    numAmmo -= 1

  _setAmmoMessage()
  return success

#-----------------------------------------------------------

var maxHp = 10
var numHp = 3

func _resetHp( qty ) :
  numHp += qty
  
  if numHp > maxHp:
    numHp = maxHp
 
  _setHpMessage()

func _setHpMessage() :
  get_node( 'HP' ).text = '%d' % [ numHp]

func _HpLost(qty) :
  numHp -= qty
  if numHp <= 0:
    numHp = 0
  _setHpMessage()


#-----------------------------------------------------------
var maxOpponents = 0
var numOpponents = 0

func _resetOpponents( qty ) :
  maxOpponents = qty
  numOpponents = qty
  _setOpponentMessage()

func _setOpponentMessage() :
  get_node( 'Opponents' ).text = '%d / %d' % [ numOpponents, maxOpponents ]

func _opponentDied() :
  numOpponents -= 1
  _setOpponentMessage()

  if numOpponents == 0 :
    var timeStr = $'../HUD Layer'.getTimeStr()
  
    print( 'Last opponent died at %s.' % timeStr )
    $'../../World'._updateLevel()

#-----------------------------------------------------------

func _getLevel() :
  return currentLevel

func _setLevel(val):
  currentLevel = val