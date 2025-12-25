extends CanvasLayer


var Dialogues = [
	"",
	"Play Correct Sound to Turn on the Power",
	"Press [tab] to adjust Horn",
]

@onready var text = $Label


# Called when the node enters the scene tree for the first time.
func _ready():
	text.text = Dialogues[0]
	Global.ShowUi.connect(_show_interact_ui)
	Global.HideUi.connect(_hide_ui)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _show_interact_ui(id: int):
	text.text = Dialogues[id]
	
func _hide_ui():
	text.text = Dialogues[0]
